unit hiStringTableMT; { Расширенная таблица строк с поддержкой MT-потоков ver MT_671 }

interface

uses Windows,Messages,{for new}Share,Win,Debug,ListEdit,Kol,ShellAPI;

const
   CLEAR_FULL         = 0;
   CLEAR_COLUMNS      = 1;
   CLEAR_TABLE        = 2;

   _Flags_NEV         = DT_NOPREFIX or DT_END_ELLIPSIS or DT_VCENTER;
   _Flags_WL          = DT_NOPREFIX or DT_END_ELLIPSIS or DT_VCENTER or DT_WORDBREAK or DT_LEFT; 
   _Flags_WR          = DT_NOPREFIX or DT_END_ELLIPSIS or DT_VCENTER or DT_WORDBREAK or DT_RIGHT;
   _Flags_WC          = DT_NOPREFIX or DT_END_ELLIPSIS or DT_VCENTER or DT_WORDBREAK or DT_CENTER;
   _Flags_SL          = DT_NOPREFIX or DT_END_ELLIPSIS or DT_VCENTER or DT_SINGLELINE or DT_LEFT;
   _Flags_SR          = DT_NOPREFIX or DT_END_ELLIPSIS or DT_VCENTER or DT_SINGLELINE or DT_RIGHT;
   _Flags_SC          = DT_NOPREFIX or DT_END_ELLIPSIS or DT_VCENTER or DT_SINGLELINE or DT_CENTER;

   LOAD_TABLE         =  0 ;
   LOAD_ICON          =  2 ;
   LOAD_PAK_ICONS     =  4 ;
   LOAD_ILIST         =  5 ;
   LOAD_EXTICON       =  7 ;
   LOAD_STRING_LIST   =  10;
   LOAD_FSTREAM       =  13;

   SAVE_TABLE         =  1 ;
   SAVE_ICON_FILE     =  3 ;
   SAVE_ILIST         =  6 ;
   SAVE_STRING_LIST   =  8 ;
   APPEND_STRING_FILE =  9 ;
   SAVE_FSTREAM       =  14;

   SKIP               =  -1;

   ITM_ADD            =  -3;
   ITM_INSERT         =  -4;
   ITM_REPLACE        =  -5;

   EMATRIX            =  -6;
   CHK_EMATRIX        =  -7;
   SEL_EMATRIX        =  -8;

   COL_NAME           =  -9;
   COL_WIDTH          = -10;
   COL_IMAGE          = -11;
   COL_ALIGN          = -12;

   AColor: array [0..15] of TColor =
		   (clBlack, clMaroon, clGreen, clOlive, clNavy, clPurple, clTeal, clGray,
		   clSilver, clRed, clLime, clYellow, clBlue, clFuchsia, clAqua, clWhite);

type   PColor = ^TColor;
       COLOR16 = $0000..$FF00;
       TTriVertex = packed record
          x, y: DWORD;
          Red, Green, Blue, Alpha: COLOR16;
       end;

type
  ThiStringTableMT = class(THIWin)
   private
    FStrFind, FStrReplace: String;
    Sel, FCol, FRow: Integer;
    NewCurIdx,NewLine: integer;
    FData,FData_1,FData_2: TData;
    SortCol:integer;
    Icon:PIcon;
    Obj:PMatrix;
    Arr,CBArray,SAArray,CLArray,ICArray,SLArray:PArray;
    IDList:PStrListEx;
    IList,IChList:PImageList;
    CList,FList:PStrList;
    _StrDlm:char;
    _ColorDlm:char;
    _MTColDlm:char;
    LoadStream, LICLStream, LTblStream:PStream;
    SICLStream, STblStream, FTblStream:PStream;

    FCTL3D,FTabGrid,FTabGridFrame,FGradient,FSingleString: boolean;
    FTextColor,FTextBkColor,FBkColor,FTransparent,FIconColColor,FGradientColor,FShadowColor: TColor;
    FAutoMakeVisible: boolean;
    FStyle: TListViewStyle;
    FTextAlign: TTextAlign;
    FSaveColProp,FSaveWidth,FSaveImgIndex,FSaveItemsColor,FSaveColor,FClearAll: boolean;
    FStaticColumn: boolean;
    FTableWBreak,FGrid3D,FBumpText,FExtIconsCheck,FColorItems,FAllMT_AddCol: boolean;
    FMethodSort,FModeMakeVisible,FStyleGrid3D,FColumnClick,FImgSize: byte;
    FGrid,FHeaderDragDrop,FTrackSelect,FRowSelect,FCheckBoxes,FMultiSelect,FFlat: boolean;
    FMaxColWidth,FMinColWidth,FColumnWidth:integer;
    FImgColumn,FIconToBmp,FFullSelect,FAppTxtStrLst,FAutoTblStrLst,FSelectFind :boolean;
    FAssignedIList,FRedaction,FAutoAddItem,FEnableOnClick,FFindReplace,FInfoTip: boolean;

    procedure StrDlm(Val:string);
    procedure ColorDlm(Val:string);
    procedure MTColDlm(Val:string);    
     
    procedure SetIListProp();
    procedure SetIcons(const value:PStrListEx);
    procedure SetIconsCheck(const value:PStrListEx);
    procedure SetMiscIcons(const value:PStrListEx);
    procedure SaveIListToFile(const FileName:string; Index:word);
    procedure LoadIListFromFile(const FileName:string; Index:word);
    procedure SetColumns(const ListCol:PStrList; Mode:integer);
    procedure _OnClick(Obj:PObj);    
    procedure _OnMouseDown(Sender: PControl; var Mouse: TMouseEventData); override; 
    function _OnCmpText( Sender: PControl; Idx1, Idx2: Integer ): Integer;
    function _OnCmpReal( Sender: PControl; Idx1, Idx2: Integer ): Integer;
    function _OnCmpExt( Sender: PControl; Idx1, Idx2: Integer ): Integer;
    procedure _OnColumnClick( ender: PControl; Idx: Integer);
    procedure _OnBeforeLineChange(Sender: PControl; Idx: Integer);
    procedure _OnLineChange(Sender: PControl; Idx: Integer);
    function  _OnLVCustomDraw(Sender: PControl; DC: HDC; Stage: DWORD;
                  ItemIdx, SubItemIdx: Integer; const Rect: TRect;
                  ItemState: TDrawState; var TextColor, BackColor: TColor): DWORD;
    procedure Add(const Data:string; Index:integer = -1; _Replace:boolean = false);
    function _Count:integer;
    procedure MX_Set(x,y:integer; var Val:TData);
    function MX_Get(x,y:integer):TData;
    function _mRows:integer;
    function _mCols:integer;
    procedure CB_Set(var Item:TData; var Val:TData);
    function CB_Get(Var Item:TData; var Val:TData):boolean;
    procedure SA_Set(var Item:TData; var Val:TData);
    function SA_Get(Var Item:TData; var Val:TData):boolean;
    procedure _SetIcon(var Item:TData; var Val:TData);
    function _GetIcon(Var Item:TData; var Val:TData):boolean;
    procedure _AddIcon(var Val:TData);
    function  _CountIcon:integer;
    function InitColStr(var Val:string):string;
    procedure InsertIcon(Data:TData; Index:word);
    procedure _SetCol(var Item:TData; var Val:TData);
    function _GetCol(Var Item:TData; var Val:TData):boolean;
    procedure _AddCol(var Val:TData);
    function _CountCol:integer;
    procedure ClearIcons();
    procedure SetTextStrLst(const Value:string);
    procedure SetTextColLst(const Value:string);
    procedure _SetStrLst(var Item:TData; var Val:TData);
    function _GetStrLst(Var Item:TData; var Val:TData):boolean;
    function _CountStrLst:integer;
    procedure _AddStrLst(var Val:TData);
    function Get(index:integer):string;
    procedure _aSet(var Item:TData; var Val:TData);
    function _aGet(Var Item:TData; var Val:TData):boolean;
    procedure _aAdd(var Val:TData);
    function PakColor2Str(data:dword):string;
    procedure SetOption(OSet:boolean; Option:TListViewOption); 

    procedure _OnSelState( Sender: PControl; IdxFrom, IdxTo: Integer; OldState, NewState: cardinal );
    function LFileExists_MT(FileName:string;FileOperation:integer):boolean;
    function SFileExists_MT(FileName:string;FileOperation:integer):boolean;

    procedure MT_ActionItm(var Data:TData; Mode:integer);
    procedure MT_ActionCol(var Data:TData; Mode:integer);
    procedure MT_ProperCol(var Data:TData; Mode:integer);
    procedure MT_ActionIco(var Data:TData; Mode:integer);
    procedure MT_EMatrix(var Data:TData; Mode:integer);

   public

    _prop_DoubleBuffered:boolean;
    _prop_FileName:string;
    _prop_IconFileName:string;
    _prop_IconsFileName:string;
    _prop_IListFileName:string;
    _prop_StrLstFName:string;
    
    _data_FileName:THI_Event;
    _data_IconFileName:THI_Event;
    _data_IconsFileName:THI_Event;
    _data_IListFileName:THI_Event;
    _data_EndEdit:THI_Event;
    _data_SFileExists_MT:THI_Event;
    _data_LFileExists_MT:THI_Event;
    _data_Str:THI_Event;
    _data_ExtCmp:THI_Event;
    _data_FTblStream:THI_Event;
    _data_StrLstFName:THI_Event;
    _data_StrLst:THI_Event;
    
    _event_onSelect:THI_Event;
    _event_onClick:THI_Event;
    _event_onEscCell:THI_Event;
    _event_onColumnClick:THI_Event;
    _event_onChange:THI_Event;
    _event_onChangeImgLst:THI_Event;
    _event_onChangeColLst:THI_Event;
    _event_onGetIcon:THI_Event;
    _event_onGetMiscIcon:THI_Event; 
    _event_onGetIconIdx:THI_Event;
    _event_onMT_GetCol:THI_Event;
    _event_onMT_GetColors:THI_Event;
    _event_onMT_EMatrix:THI_Event;
    _event_onMT_Check:THI_Event;
    _event_onMT_CellClick:THI_Event;
    _event_onMT_FindText:THI_Event;
    _event_onExtIcon:THI_Event;
    _event_onChangeStrLst:THI_Event;
    _event_onGetStrList:THI_Event;
    _event_onBeforeLineChange:THI_Event;
    _event_onLineChange:THI_Event;

    property _prop_SingleString:boolean    write FSingleString;
    property _prop_TabGrid:boolean         write FTabGrid;
    property _prop_TabGridFrame:boolean    write FTabGridFrame;
    property _prop_Gradient:boolean        write FGradient;
    property _prop_InfoTip:boolean         write FInfoTip;
    property _prop_ReplaceFind:boolean     write FFindReplace;
    property _prop_EnableOnClick:boolean   write FEnableOnClick;
    property _prop_SelectFind:boolean      write FSelectFind;
    property _prop_AutoAddItem:boolean     write FAutoAddItem;
    property _prop_ColumnWidth:integer     write FColumnWidth;
    property _prop_MaxColWidth:integer     write FMaxColWidth;
    property _prop_MinColWidth:integer     write FMinColWidth;
    property _prop_Redaction:boolean       write FRedaction;
    property _prop_AssignedIList:boolean   write FAssignedIList;
    property _prop_ImgColumn:boolean       write FImgColumn;
    property _prop_IconToBmp:boolean       write FIconToBmp;
    property _prop_FullSelect:boolean      write FFullSelect;
    property _prop_AppTxtStrLst:boolean    write FAppTxtStrLst;
    property _prop_AutoTblStrLst:boolean   write FAutoTblStrLst;
    property _prop_ImgSize:byte            write FImgSize;
    property _prop_ClearAll:boolean        write FClearAll;
    property _prop_ColumnClick:byte        write FColumnClick;
    property _prop_AllMT_AddCol:boolean    write FAllMT_AddCol;
    property _prop_ColorItems:boolean      write FColorItems;
    property _prop_ExtIconsCheck:boolean   write FExtIconsCheck;
    property _prop_AutoMakeVisible:boolean write FAutoMakeVisible;
    property _prop_StaticColumn:boolean    write FStaticColumn;
    property _prop_MethodSort:byte         write FMethodSort;
    property _prop_ModeMakeVisible:byte    write FModeMakeVisible;
    property _prop_StyleGrid3D:byte        write FStyleGrid3D;
    property _prop_TextAlign:TTextAlign    write FTextAlign;
    property _prop_Style:TListViewStyle    write FStyle;
    property _prop_TableWBreak:boolean     write FTableWBreak;
    property _prop_Grid3D:boolean          write FGrid3D;    
    property _prop_BumpText:boolean        write FBumpText;
    property _prop_SaveColProp:boolean     write FSaveColProp;
    property _prop_SaveWidth:boolean       write FSaveWidth;
    property _prop_SaveImgIndex:boolean    write FSaveImgIndex;
    property _prop_SaveItemsColor:boolean  write FSaveItemsColor;
    property _prop_SaveColor:boolean       write FSaveColor;
    property _prop_TranspColor:TColor      write FTransparent ;
    property _prop_Grid:boolean            write FGrid;
    property _prop_HeaderDragDrop:boolean  write FHeaderDragDrop;
    property _prop_TrackSelect:boolean     write FTrackSelect;
    property _prop_RowSelect:boolean       write FRowSelect;
    property _prop_CheckBoxes:boolean      write FCheckBoxes;
    property _prop_MultiSelect:boolean     write FMultiSelect;
    property _prop_TextColor:TColor        write FTextColor;
    property _prop_TextBkColor:TColor      write FTextBkColor;
    property _prop_BkColor:TColor          write FBkColor;
    property _prop_IconColColor:TColor     write FIconColColor;
    property _prop_GradientColor:TColor    write FGradientColor;
    property _prop_ShadowColor:TColor      write FShadowColor;

    property _prop_StrDelimiter:string     write StrDlm;
    property _prop_ColorDelimiter:string   write ColorDlm;
    property _prop_MT_ColDelimiter:string  write MTColDlm;
    property _prop_Icons:PStrListEx        write SetIcons;
    property _prop_IconsCheck:PStrListEx   write SetIconsCheck;
    property _prop_MiscIcons:PStrListEx    write SetMiscIcons;
    property _prop_StringsStrLst:string    write SetTextStrLst;
    property _prop_Columns:string          write SetTextColLst;

    procedure Init; override;
    destructor Destroy; override;

    procedure _work_doAdd(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doInsert(var _Data:TData; Index:word);
    procedure _work_doAddColumn(var _Data:TData; Index:word);
    procedure _work_doSort(var _Data:TData; Index:word);
    procedure _work_doSortDigit(var _Data:TData; Index:word);
    procedure _work_doSortExtCmp(var _Data:TData; Index:word);
    procedure _work_doSelect(var _Data:TData; Index:word);
    procedure _work_doEnsureVisible(var _Data:TData; Index:word);
    procedure _work_doInitTxtTab(var _Data:TData; Index:word);
    procedure _work_doReplace(var _Data:TData; Index:word);
    procedure _work_doLoadIcon(var _Data:TData; Index:word);
    procedure _work_doSaveIcon(var _Data:TData; Index:word);
    procedure _work_doSaveIList(var _Data:TData; Index:word);
    procedure _work_doLoadIList(var _Data:TData; Index:word);
    procedure _work_doLoadPakIcons(var _Data:TData; Index:word);
    procedure _work_doSaveFStream(var _Data:TData; Index:word);
    procedure _work_doLoadFStream(var _Data:TData; Index:word);
    procedure _work_doGetColors_MT(var _Data:TData; Index:word);
    procedure _work_doMT_Add(var _Data:TData; Index:word);
    procedure _work_doMT_AddCols(var _Data:TData; Index:word);
    procedure _work_doMT_Insert(var _Data:TData; Index:word);
    procedure _work_doMT_Replace(var _Data:TData; Index:word);    
    procedure _work_doMT_InsertCol(var _Data:TData; Index:word);
    procedure _work_doMT_ReplaceCol(var _Data:TData; Index:word);
    procedure _work_doMT_NameCol(var _Data:TData; Index:word);
    procedure _work_doMT_WidthCol(var _Data:TData; Index:word);
    procedure _work_doMT_ImageCol(var _Data:TData; Index:word);
    procedure _work_doMT_AlignTxtCol(var _Data:TData; Index:word);
    procedure _work_doMT_IconStr(var _Data:TData; Index:word);
    procedure _work_doMT_IconCol(var _Data:TData; Index:word);
    procedure _work_doMT_EMatrix(var _Data:TData; Index:word);
    procedure _work_doMT_ChkEMatrix(var _Data:TData; Index:word);
    procedure _work_doMT_SelEMatrix(var _Data:TData; Index:word);
    procedure _work_doMT_ColorsStr(var _Data:TData; Index:word);
    procedure _work_doMT_CheckBox(var _Data:TData; Index:word);
    procedure _work_doMT_ReplaceIcon(var _Data:TData; Index:word);
    procedure _work_doMT_InsertIcon(var _Data:TData; Index:word);
    procedure _work_doMT_LoadExtIcon(var _Data:TData; Index:word);
    procedure _work_doMT_FindText(var _Data:TData; Index:word);
    procedure _work_doMT_FindNext(var _Data:TData; Index:word);
    procedure _work_doClearCol(var _Data:TData; Index:word);
    procedure _work_doDeleteCol(var _Data:TData; Index:word);
    procedure _work_doGetCol_MT(var _Data:TData; Index:word);
    procedure _work_doCheckBoxes(var _Data:TData; Index:word);
    procedure _work_doTextColor(var _Data:TData; Index:word);
    procedure _work_doTextBkColor(var _Data:TData; Index:word);
    procedure _work_doBkColor(var _Data:TData; Index:word);
    procedure _work_doAutoMakeVisible(var _Data:TData; Index:word);
    procedure _work_doStyle(var _Data:TData; Index:word);
    procedure _work_doTextAlign(var _Data:TData; Index:word);
    procedure _work_doSaveColProp(var _Data:TData; Index:word);
    procedure _work_doSaveImgIndex(var _Data:TData; Index:word);
    procedure _work_doSaveItemsColor(var _Data:TData; Index:word);
    procedure _work_doSaveColor(var _Data:TData; Index:word);
    procedure _work_doSaveWidth(var _Data:TData; Index:word);
    procedure _work_doFlat(var _Data:TData; Index:word);
    procedure _work_doGrid(var _Data:TData; Index:word);
    procedure _work_doStaticColumn(var _Data:TData; Index:word);
    procedure _work_doHeaderDragDrop(var _Data:TData; Index:word);
    procedure _work_doInfoTip(var _Data:TData; Index:word);
    procedure _work_doTrackSelect(var _Data:TData; Index:word);
    procedure _work_doRowSelect(var _Data:TData; Index:word);
    procedure _work_doMultiSelect(var _Data:TData; Index:word);
    procedure _work_doGetIcon(var _Data:TData; Index:word);
    procedure _work_doGetIconIdx(var _Data:TData; Index:word);
    procedure _work_doDeleteIcon(var _Data:TData; Index:word);
    procedure _work_doTranspColor(var _Data:TData; Index:word);
    procedure _work_doClearIcons(var _Data:TData; Index:word);
    procedure _work_doMethodSort(var _Data:TData; Index:word);
    procedure _work_doSelEndStr(var _Data:TData; Index:word);
    procedure _work_doEndEdit(var _Data:TData; Index:word);
    procedure _work_doGetMiscIcon(var _Data:TData; Index:word);    
    procedure _work_doAddStrLst(var _Data:TData; Index:word);
    procedure _work_doClearStrLst(var _Data:TData; Index:word);
    procedure _work_doDeleteStrLst(var _Data:TData; Index:word);
    procedure _work_doLoadStrLst(var _Data:TData; Index:word);
    procedure _work_doSaveStrLst(var _Data:TData; Index:word);
    procedure _work_doAppendStrFile(var _Data:TData; Index:word);
    procedure _work_doInsertStrLst(var _Data:TData; Index:word);
    procedure _work_doTextStrLst(var _Data:TData; Index:word);
    procedure _work_doTblStrLst(var _Data:TData; Index:word);    
    procedure _work_doAddTextStrLst(var _Data:TData; Index:word);
    procedure _work_doSortStrLst(var _Data:TData; Index:word);
    procedure _work_doGetStrList(var _Data:TData; Index:word);
    procedure _work_doTableWBreak(var _Data:TData; Index:word);
    procedure _work_doGrid3D(var _Data:TData; Index:word);
    procedure _work_doBumpText(var _Data:TData; Index:word);
    procedure _work_doModeMakeVisible(var _Data:TData; Index:word);
    procedure _work_doStyleGrid3D(var _Data:TData; Index:word);
    procedure _work_doAutoColWidth(var _Data:TData; Index:word);
    procedure _work_doSelectFind(var _Data:TData; Index:word);
    procedure _work_doEnableOnClick(var _Data:TData; Index:word);
    procedure _work_doReplaceFind(var _Data:TData; Index:word);
    procedure _work_doRefresh(var _Data:TData; Index:word);
    procedure _work_doTabGrid(var _Data:TData; Index:word);    
    procedure _work_doTabGridFrame(var _Data:TData; Index:word); 
    procedure _work_doGradient(var _Data:TData; Index:word);
    procedure _work_doGradientColor(var _Data:TData; Index:word);
    procedure _work_doShadowColor(var _Data:TData; Index:word);
    procedure _work_doSingleString(var _Data:TData; Index:word);    

    procedure _var_GenColors_MT(var _Data:TData; Index:word);
    procedure _var_AllSelect_MT(var _Data:TData; Index:word);
    procedure _var_AllCheck_MT(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_EndIdx(var _Data:TData; Index:word);    
    procedure _var_Select(var _Data:TData; Index:word);
    procedure _var_Matrix(var _Data:TData; Index:word);
    procedure _var_Strings(var _Data:TData; Index:word);
    procedure _var_Cell(var _Data:TData; Index:word);
    procedure _var_TopItem(var _Data:TData; Index:word);
    procedure _var_PerPage(var _Data:TData; Index:word);
    procedure _var_ItemAtPos(var _Data:TData; Index:word);    
    procedure _var_Index(var _Data:TData; Index:word);
    procedure _var_SubItem(var _Data:TData; Index:word);
    procedure _var_StringTable(var _Data:TData; Index:word);
    procedure _var_SelectArray(var _Data:TData; Index:word);
    procedure _var_ColumnArray(var _Data:TData; Index:word);
    procedure _var_IconArray(var _Data:TData; Index:word);
    procedure _var_CheckBoxes(var _Data:TData; Index:word);
    procedure _var_CountIcons(var _Data:TData; Index:word);
    procedure _var_EndIdxIcons(var _Data:TData; Index:word);    
    procedure _var_CountCol(var _Data:TData; Index:word);
    procedure _var_EndIdxCol(var _Data:TData; Index:word);    
    procedure _var_FullTextTab(var _Data:TData; Index:word);    
    procedure _var_FStream(var _Data:TData; Index:word);
    procedure _var_CountStrLst(var _Data:TData; Index:word);
    procedure _var_EndIdxStrLst(var _Data:TData; Index:word);    
    procedure _var_TextStrLst(var _Data:TData; Index:word);
    procedure _var_StrLstArray(var _Data:TData; Index:word);
    procedure _var_ImgSize(var _Data:TData; Index:word);
    
    function FullSaveColumns(_Dlm: Char): string;
    procedure FullLoadColumns(StrCol: string; _Dlm: Char); 
    function FullSaveTable(_CellDlm, _Dlm: Char): string;
    procedure FullLoadTable(var StrTbl: string; _CellDlm, _Dlm: Char);
    procedure FullClear(Mode: Cardinal = CLEAR_FULL);
  end;

implementation


function GradientFill(DC: HDC; Vertex: Pointer; NumVertex: Cardinal;
                      Mesh: Pointer; NumMesh, Mode: DWORD): BOOL; stdcall;
                      external 'msimg32.dll' name 'GradientFill';
function GetLightColor(Color: TColor; Light: Byte) : TColor;
var   fFrom: TRGB;
begin
   PColor(@fFrom)^:= Color2RGB(Color);
   Result := RGB(
      (FFrom.R*100 + (255 - FFrom.R) * Light) div 100,
      (FFrom.G*100 + (255 - FFrom.G) * Light) div 100,
      (FFrom.B*100 + (255 - FFrom.B) * Light) div 100
      );
end;
            
procedure _Gradient(DC:HDC; cbRect:TRect; Gradient:boolean; StartColor,EndColor:TColor; Horizontal:boolean);
var   vert: array[0..1] of TTriVertex;
      gRect: TGradientRect;
begin

  if not Gradient then EndColor := StartColor;

   vert[0].x      := cbRect.Left;
   vert[0].y      := cbRect.Top;
   vert[1].x      := cbRect.Right;
   vert[1].y      := cbRect.Bottom;
   vert[0].Alpha  := $ff00; // ???
   vert[1].Alpha  := vert[0].Alpha;

   vert[0].Red    := GetRValue(StartColor) shl 8;
   vert[0].Green  := GetGValue(StartColor) shl 8;
   vert[0].Blue   := GetBValue(StartColor) shl 8;
   vert[1].Red    := GetRValue(EndColor) shl 8;
   vert[1].Green  := GetGValue(EndColor) shl 8;
   vert[1].Blue   := GetBValue(EndColor) shl 8;

   gRect.UpperLeft  := 0;
   gRect.LowerRight := 1;

   if Horizontal then
      GradientFill(DC, @vert, 2, @gRect, 1, GRADIENT_FILL_RECT_H)
   else
      GradientFill(DC, @vert, 2, @gRect, 1, GRADIENT_FILL_RECT_V);
end;

destructor ThiStringTableMT.Destroy;
begin
   Icon.free;
   IList.free;
   IChList.free;
   CList.free;
   FList.free;
   IDList.free;
   FTblStream.free;
   if Obj <> nil           then Dispose(Obj);
   if Arr <> nil           then Dispose(Arr);
   if CBArray <> nil       then Dispose(CBArray);
   if SAArray <> nil       then Dispose(SAArray);
   if CLArray <> nil       then Dispose(CLArray);
   if ICArray <> nil       then Dispose(ICArray);
   if SLArray <> nil       then Dispose(SLArray);
   FreeData(@FData);      
   FreeData(@FData_1);
   FreeData(@FData_2);
   inherited Destroy;
end;

procedure ThiStringTableMT._OnColumnClick;
begin
   case FColumnClick of
     0: _hi_OnEvent(_event_onColumnClick,Control.LVColText[Idx]);
     1: _hi_OnEvent(_event_onColumnClick,Idx);
   end;
end;

procedure ThiStringTableMT._OnBeforeLineChange;begin _hi_OnEvent(_event_onBeforeLineChange,Idx);end;
procedure ThiStringTableMT._OnLineChange;begin _hi_OnEvent(_event_onLineChange,Idx);end;

//---------------------   Селекторный обработчик   -----------------------

procedure ThiStringTableMT._OnClick;
begin
   if (Control.LVCurItem <> -1)and (sel = Control.LVCurItem) and FEnableOnClick then
     _hi_OnEvent(_event_onClick,Control.LVCurItem)
end;

procedure ThiStringTableMT._OnMouseDown;
begin
   sel := Control.LVCurItem;
   inherited;
end;

procedure ThiStringTableMT._OnSelState;
var   dt,Data:TData;
begin
   dtNull(Data);
   if (Newstate = 3) or (Newstate = 1) then begin
      if  FEnableOnClick then _hi_OnEvent(_event_onClick, IdxFrom);
      _hi_OnEvent(_event_onSelect,IdxFrom);
      exit;
   end;
   if (Newstate = $2000) and (OldState =  $1000) then
      dtInteger(dt,1)
   else if (Newstate = $1000) and (OldState =  $2000) then
      dtInteger(dt,0)
   else exit;         
   dtInteger(Data,IdxFrom);
   Data.ldata:= @dt;
   _hi_onEvent_(_event_onMT_Check,Data);
end;

//---------------------   Графический обработчик   -----------------------

function ThiStringTableMT._OnLVCustomDraw;
var    Color,bkColor: TColor;
       idxColor: dword;
       str: string;
       ARect,BRect,CRect: TRect;
       _Flags: dword;
       SCT_cx, SCT_cy: integer;
       ColorText: TColor;
       fw: integer;
       l:TListViewOptions;
       _Color: TColor;
begin

   Result:= CDRF_DODEFAULT;
   if (Stage = CDDS_PREPAINT) then Result:= CDRF_NOTIFYITEMDRAW
   else if (Stage = CDDS_ITEMPREPAINT) then begin 
      if (Sender.LVItemData[ItemIdx] <> 0) and FColorItems then begin
         Color:= Sender.LVItemData[ItemIdx];
         bkColor:= $00FFFFFF and Color;
         if bkColor <> 0 then BackColor:= bkColor else BackColor:= Color2RGB(FTextBkColor);
         idxColor:= ($0F000000 and Color) shr 24;
         if idxColor <> 0 then TextColor:= AColor[idxColor] else TextColor:= Color2RGB(FTextColor);
      end else begin 
         BackColor:= Color2RGB(FTextBkColor);
         TextColor:= Color2RGB(FTextColor);
      end;
      Result:=CDRF_NOTIFYSUBITEMDRAW
   end
   else if (Stage = CDDS_SUBITEM + CDDS_ITEMPREPAINT) and ((Sender.LVStyle = lvsDetail) or (Sender.LVStyle = lvsDetailNoHeader))  and FTableWBreak then begin
      l:= Sender.LVOptions;
      ARect:= Sender.LVSubItemRect(ItemIdx,SubItemIdx);
      if SubItemIdx = 0 then ARect.Right:= Arect.Left + Sender.LVColWidth[SubItemIdx];
      _Color := Color2RGB(FGradientColor);
      str:= Sender.LVItems[ItemIdx,SubItemIdx];
      if (odsSelected in ItemState) and ((lvoRowSelect in l) or (not (lvoRowSelect in l)) and (SubItemIdx = 0)) then begin
         if (FTabGrid and FRowSelect and (SubItemIdx <> NewCurIdx)) then begin
            Sender.Canvas.Brush.Color := GetLightColor(_Color,80);
            _Gradient(DC, ARect,FGradient,GetLightColor(_Color,70),GetLightColor(_Color,20),false);
         end else begin
            Sender.Canvas.Brush.Color := _Color;
            if FGradient then
               _Gradient(DC, ARect,FGradient,GetLightColor(_Color,70),GetLightColor(_Color,20),false)
            else
               FillRect(DC,ARect,Sender.Canvas.Brush.Handle);
            if (FTabGrid and FTabGridFrame) then begin 
               Sender.Canvas.Brush.Color := Color2RGB(clInfoBk);
               if FGrid then
                  if FGrid3D then fw := 3 else fw := 2  
               else fw := 1;
               FillRect(DC,MakeRect(ARect.Left+fw,ARect.Top+fw,ARect.Right-fw,ARect.Bottom-fw),Sender.Canvas.Brush.Handle);
            end;
         end;
      end else begin
         Sender.Canvas.Brush.Color := Color2RGB(BackColor);
         FillRect(DC,ARect,Sender.Canvas.Brush.Handle);
      end;
      BRect:= ARect;
      SCT_cx := Sender.Canvas.TextExtent('M').cx; 
      SCT_cy := Sender.Canvas.TextExtent('W').cy; 
      ARect.Left:= ARect.Left + SCT_cx;
      ARect.Right:= ARect.Right - SCT_cx; 
      case ord(Sender.LVColAlign[SubItemIdx]) of
         0: _Flags := _Flags_SL; 
         1: _Flags := _Flags_SR;
         2: _Flags := _Flags_SC
         else _Flags := _Flags_NEV; 
      end;
      if (Sender.Canvas.TextExtent(Sender.LVItems[ItemIdx,SubItemIdx]).cx > ARect.Right - ARect.Left) and not FSingleString then begin
         CRect:= ARect;
         ARect.Top:= ARect.Top + SCT_cy div 2;
         ARect.Bottom:= ARect.Bottom - SCT_cy div 2;
         if ARect.Bottom - ARect.Top < SCT_cy then ARect:= CRect;   
         case ord(Sender.LVColAlign[SubItemIdx]) of
            0: _Flags := _Flags_WL; 
            1: _Flags := _Flags_WR;
            2: _Flags := _Flags_WC
            else _Flags := _Flags_NEV; 
         end;
      end;
      CRect:= ARect;
      inc(CRect.Left);
      inc(CRect.Top);
      inc(CRect.Right);
      inc(CRect.Bottom);
      if FBumpText then begin
         ColorText:= FShadowColor;
         if (odsSelected in ItemState) and ((lvoRowSelect in l) or (not (lvoRowSelect in l)) and (SubItemIdx = 0)) then CRect:=ARect;    
         SetBkMode(DC, Windows.TRANSPARENT);
         SetTextColor(DC,Color2RGB(ColorText));
         DrawText(DC,PChar(str),-1,CRect,_Flags);
      end;
      if (odsSelected in ItemState) and ((lvoRowSelect in l) or (not (lvoRowSelect in l)) and (SubItemIdx = 0)) then
         if (FTabGrid and FRowSelect and ((SubItemIdx <> NewCurIdx) or FTabGridFrame)) then
            ColorText:= TextColor
         else
            ColorText:= clHighlightText
      else
         ColorText:= TextColor;
      SetBkMode(DC, Windows.TRANSPARENT);
      SetTextColor(DC,Color2RGB(ColorText));
      DrawText(DC,PChar(str),-1,ARect,_Flags);
      if (lvoGridLines in l) and FGrid3D then begin
         case FStyleGrid3D of
            0: DrawEdge(DC, BRect,EDGE_RAISED, BF_RECT);
            1: DrawEdge(DC, BRect,EDGE_SUNKEN, BF_RECT)
            else DrawEdge(DC, BRect,EDGE_RAISED, BF_RECT);
         end;
      end else if (lvoGridLines in l) then
         DrawEdge(DC, BRect,BDR_RAISEDINNER, BF_RECT or BF_FLAT);
      Result:= CDRF_SKIPDEFAULT;
   end;
end;

function ThiStringTableMT.PakColor2Str;
var   hcl,lcl:string;
      idxcl:dword;
begin
   lcl:= int2str($FFFFFF and data);
   idxcl:= $0F000000 and data;
   hcl:= int2str(idxcl shr 24);
   Result:= hcl + _ColorDlm + lcl;
end;

procedure ThiStringTableMT.StrDlm;   begin if Val = '' then _StrDlm:= ' ' else _StrDlm:= Val[1];     end;
procedure ThiStringTableMT.ColorDlm; begin if Val = '' then _ColorDlm:= '#' else _ColorDlm:= Val[1]; end;
procedure ThiStringTableMT.MTColDlm; begin if Val = '' then _MTColDlm:= '_' else _MTColDlm:= Val[1]; end;

function WndProcTabGrid( Sender: PControl; var Msg: TMsg; var Rslt: Integer ): Boolean;
type   TMouseDownPt = packed record
          X: WORD;
          Y: WORD;
       end;
var   R: TRect;
      Pt: TMouseDownPt; 
      HTI: TLVHitTestInfo;
      fControl: ThiStringTableMT;
      dTop,dWidth,dHeight,Data:TData;

      procedure InitOnEvent(NewLine,NewCurIdx: integer; FCTL3D: boolean);
      var   b: integer;
      begin
         R := Sender.LVSubItemRect(NewLine, NewCurIdx);
         if FCTL3D then b := 2 else b := 1;
         dtInteger(Data,R.Left + Sender.Left + b);
         dtInteger(dTop,R.Top + Sender.Top + b);

         dtInteger(dWidth,Sender.LVColWidth[NewCurIdx]);
         dtInteger(dHeight,R.Bottom - R.Top);  
         Data.ldata:= @dTop;
         dTop.ldata:= @dWidth;
         dWidth.ldata:= @dHeight;
      end;

      procedure EscCell(NewLine: integer; fControl: ThiStringTableMT);
      begin
         R := Sender.LVSubItemRect(NewLine, 0);
         InvalidateRect(Sender.Handle,@R,FALSE);
         _hi_OnEvent(fControl._event_onEscCell);
      end;

begin
   Result := FALSE;
   fControl := ThiStringTableMT(Sender.Tag); 
   with fControl do begin
      case Msg.message of
         WM_LBUTTONDOWN: begin
            Pt:= TMouseDownPt(Msg.lParam);
            HTI.pt.x := Pt.X;
            HTI.pt.y := Pt.Y;
            Sender.Perform( LVM_SUBITEMHITTEST, 0, Integer( @HTI ) );
            NewLine := HTI.iItem;
            NewCurIdx := HTI.iSubItem;             
            EscCell(NewLine, fControl);
         end;
         WM_LBUTTONDBLCLK: begin
            if FRowSelect and not FRedaction then begin
               InitOnEvent(NewLine,NewCurIdx,FCTL3D);
               _hi_OnEvent_(fControl._event_onMT_CellClick,Data); 
            end;
         end;
         WM_HSCROLL,WM_VSCROLL: if FRowSelect and not FRedaction then EscCell(NewLine, fControl);
         WM_KEYDOWN: begin
            Case Msg.WParam of
               VK_LEFT,VK_RIGHT: begin
                  if FRowSelect then begin
                     NewCurIdx := NewCurIdx + Msg.wParam - $26;
                     if NewCurIdx >= Sender.LVColCount then NewCurIdx := Sender.LVColCount - 1
                     else if NewCurIdx < 0 then NewCurIdx := 0;
                     EscCell(NewLine, fControl);
                  end;
               end;
               VK_UP,VK_DOWN: begin
                  if FRowSelect then begin
                     NewLine := NewLine + Msg.wParam - $27;                  
                     if NewLine >= Sender.Count then NewLine := Sender.Count - 1
                     else if NewLine < 0 then NewLine := 0;
                     EscCell(NewLine, fControl);
                  end;
               end;
               VK_RETURN,VK_F2: begin
                  if FRowSelect and not FRedaction then begin
                     InitOnEvent(NewLine,NewCurIdx,FCTL3D);
                     _hi_OnEvent_(fControl._event_onMT_CellClick,Data); 
                  end;
               end;
               VK_ESCAPE: if FRowSelect and not FRedaction then EscCell(NewLine, fControl);
            end;
         end;
      end;
   end;
end;

procedure ThiStringTableMT.Init;
var   l:TListViewOptions;
      ind:integer;
begin
   Icon:= NewIcon;
   FFlat := _prop_Flat;
   l:= [lvoUnderlineHot, lvoAutoArrange];

   if FInfoTip then include(l,lvoInfoTip);
   if FTrackSelect then include(l,lvoTrackSelect);
   if FHeaderDragDrop then include(l,lvoHeaderDragDrop);
   if FCheckBoxes then include(l,lvoCheckBoxes);
   if FMultiSelect then include(l,lvoMultiSelect);
   if FGrid then include(l,lvoGridLines);
   if FRowSelect then include(l,lvoRowSelect);
   if FFlat then include(l,lvoFlatsb);
   
   if not Assigned (IDList) then IDList:= NewStrListEx;

   if (not Assigned (IList)) and FAssignedIList then begin
      IList:= NewImageList(nil);
      if FImgsize = 0 then FImgsize:= GetSystemMetrics(SM_CXICON);
      SetIListProp;
   end;

   if FRedaction then
      if (Assigned (IChList)) and (FExtIconsCheck) then
           Control := NewListEdit(FParent,FStyle,l,IList,IList,IChList,_OnLineChange,_OnBeforeLineChange)
      else Control := NewListEdit(FParent,FStyle,l,IList,IList,nil,_OnLineChange,_OnBeforeLineChange)
   else
      if (Assigned (IChList)) and (FExtIconsCheck) then
           Control := NewListView(FParent,FStyle,l,IList,IList,IChList)
      else Control := NewListView(FParent,FStyle,l,IList,IList,nil);

   Control.Tag := LongInt(Self);
   Control.AttachProc(WndProcTabGrid);

   Control.OnMouseDown     := _OnMouseDown;
   Control.OnColumnClick   := _OnColumnClick;
   Control.OnClick         := _OnClick;
   Control.OnLVStateChange := _OnSelState;
   Control.OnLVCustomDraw  := _OnLVCustomDraw;

   SetColumns(CList,0);

   inherited;

   FCTL3D := not boolean(_prop_CTL3D);

   Control.LVTextColor:= FTextColor;
   Control.LVTextBkColor:= FTextBkColor;
   Control.LVBkColor:= FBkColor;
   Control.LVStyle:= FStyle;
 
   Control.DoubleBuffered := _prop_DoubleBuffered;

   if FAutoTblStrLst then for ind:= 0 to FList.Count - 1 do Add(FList.Items[ind]);
   Control.SubClassName := 'obj_StringTableMT';
   Control.InvaliDate;
end;

procedure ThiStringTableMT.SetTextColLst;
begin
   CList:= NewStrList;
   Clist.Text:= Value;
end;

procedure ThiStringTableMT.SetColumns;
var   i:integer;
      s,str,sd:string;
begin
   if ListCol.Count = 0 then exit;
   i:= 0;
   Control.BeginUpdate;
   repeat
      s:= ListCol.Items[i] + '=';
      sd:= GetTok(s,'=');
      if sd <> '' then begin
         str:= sd;
         case Mode of
            0:  Control.LVColAdd(sd,FTextAlign,FColumnWidth);
            1:  Control.LVColText[i]:= sd;
         end;
         sd:= GetTok(s,'=');
         if sd = '' then
            sd:= int2str(FColumnWidth)
         else
            Control.LVColWidth[i]:= str2int(sd);
         str:= str + '=' + sd;
         sd:= GetTok(s,'=');
         if FImgColumn and Assigned(Ilist) and (IList.Count <> 0) then
            Control.LVColImage[i]:= str2int(sd);
         str:= str + '=' + sd;
         sd:= GetTok(s,'=');
         if sd <> '' then
            Control.LVColAlign[i]:= TTextAlign(str2int(sd))
         else begin
            Control.LVColAlign[i]:= FTextAlign;
            sd:= int2str(ord(Control.LVColAlign[i]));
         end;
         str:= str + '=' + sd;
         ListCol.Items[i]:= str;
      end;
      inc(i);
   until i = ListCol.Count; 
   Control.EndUpDate;
end;

//doAdd - Добавляет запись в таблицу
//
procedure ThiStringTableMT._work_doAdd;
begin
   Add(ReadString(_Data,_data_Str,''));
   _hi_CreateEvent_(_Data,@_event_onChange);
end;

//doInsert - Вставляет строку Str перед строкой с индексом из потока
//
procedure ThiStringTableMT._work_doInsert;
begin
   Add(ToStringEvent(_data_Str),ToInteger(_Data),false);
   _hi_CreateEvent_(_Data,@_event_onChange);
end;

//doReplace - Заменяет строку с индексом из потока на строку Str
//
procedure ThiStringTableMT._work_doReplace;
begin
   Add(ToStringEvent(_data_Str),ToInteger(_Data),true);
   _hi_CreateEvent_(_Data,@_event_onChange);
end;

//Универсальный метод работы со строками таблицы
//
procedure ThiStringTableMT.Add;
var   s,ss:string;
      i,ico{,ind}:integer;
      DColor:dword;       
begin
   s:= Data + _StrDlm;
   i:= 0;
   ico:= I_SKIP;
   DColor:= 0;
   if (((Index < -1) or (Index > Control.Count)) and not _replace) or (((Index < 0) or (Index > Control.Count - 1)) and _replace) then exit
   else if (Index = -1) and not _replace then
   begin
      Index:= Control.Count;
      Control.LVItemInsert(Index,'');
   end
   else if not _replace then
      Control.LVItemInsert(Index,'');    

   if Assigned(Ilist) then ico:= Str2Int(gettok(s,_StrDlm));
   if FColorItems then begin
      ss:= gettok(s,_StrDlm) + _ColorDlm;
      DColor:= dword(Str2Int(GetTok(ss,_ColorDlm)) shl 24 + Str2int(ss));
   end;
//   ind := Control.LVCurItem; // сохранение текущей позиции 
   repeat
      Control.LVSetItem(Index,i,gettok(s,_StrDlm),ico,[],I_SKIP,I_SKIP,DColor);
      inc(i);
   until s = '';
//   Control.LVCurItem := ind; // восстановление текущей позиции
end;

//doInitTxtTab - Инициализирует таблицу внешним списком строк из потока или поля StrList
//
procedure ThiStringTableMT._work_doInitTxtTab;
var   List:PStrList;
      ind:integer;
begin
   List:= NewStrList;
   List.Text:= ReadString(_Data,_data_StrLst,'');
   for ind:= 0 to List.Count - 1 do Add(List.Items[ind]);
   List.free;
   _hi_CreateEvent_(_Data,@_event_onChange);
end;

//doRefresh - Перерисовывает окно таблицы
//
procedure ThiStringTableMT._work_doRefresh;
begin
   Control.Invalidate;
end;

procedure ThiStringTableMT._work_doClear;
begin
   Control.BeginUpdate;
   Control.Clear;
   if FClearAll then begin
      repeat
         Control.LVColDelete(Control.LVColCount-1);
      until Control.LVColCount <= 0;
      CList.Clear;
   end;
   Control.EndUpDate;
   _hi_CreateEvent_(_Data,@_event_onChange);
end;

//doSelect - Выделяет строку таблицы с индексом из потока
//
procedure ThiStringTableMT._work_doSelect;
var   ind,begitm:integer;
begin
   ind:= ToInteger(_Data);
   Control.LVCurItem:= ind; 
   If not FAutoMakeVisible then Exit;
   if (FStyle = lvsDetail) or (FStyle = lvsDetailNoHeader) then
      case FModeMakeVisible of
         1: begin
               begitm:= ind + Control.LVPerPage;
               if begitm > Control.Count - 1 then begitm:= Control.Count - 1; 
               ind:= begitm - Control.LVPerPage; 
               Control.LVMakeVisible(begitm,false);
            end;
         2: begin 
               begitm:= ind + Control.LVPerPage div 2;
               if begitm > Control.Count - 1 then begitm:= Control.Count - 1; 
               ind:= begitm - Control.LVPerPage; 
               if ind < 0 then ind:= 0;
               Control.LVMakeVisible(begitm,false);
            end;
         3: begin
               begitm:= ind - Control.LVPerPage;
               if begitm < 0 then begitm:= 0;
               Control.LVMakeVisible(begitm,false);
            end;
      end; 
   Control.LVMakeVisible(ind,false);
end;

//doEnsureVisible - Делает видимой строку с номером из потока
//
procedure ThiStringTableMT._work_doEnsureVisible;
begin
   If FAutoMakeVisible then exit;
   Control.LVMakeVisible(ToInteger(_Data), False);
end;

//doDelete - Удаляет строку из таблицы с индексом из потока
//
procedure ThiStringTableMT._work_doDelete;
begin
   Control.LVDelete(ToInteger(_Data));
   _hi_CreateEvent_(_Data,@_event_onChange);
end;

//Обработчик метода doSort;
//
function ThiStringTableMT._OnCmpText;
var   S1,S2:string;
begin
   S1 := Sender.LVItems[ Idx1, SortCol ];
   S2 := Sender.LVItems[ Idx2, SortCol ];
   if FMethodSort = 1 then
      Result := AnsiCompareStrNoCase( S2, S1 )
   else
      Result := AnsiCompareStrNoCase( S1, S2 );
end;

//Обработчик метода doSortDigit;
//
function ThiStringTableMT._OnCmpReal;
var   S1,S2:string; r:real;
begin
   S1 := Sender.LVItems[ Idx1, SortCol ];
   S2 := Sender.LVItems[ Idx2, SortCol ];
   r := str2double(S1)-str2double(S2);
   if FMethodSort = 1 then
      Result := ord(r<0)-ord(r>0)
   else
      Result := ord(r>0)-ord(r<0);
end;

//Обработчик метода doSortExtCmp;
//
function ThiStringTableMT._OnCmpExt;
var dt1,dt2:TData; r:real;
begin
   dtString(dt1, Sender.LVItems[ Idx1, SortCol ]);
   dtString(dt2, Sender.LVItems[ Idx2, SortCol ]);
   dt1.ldata := @dt2;
   _ReadData(dt1, _data_ExtCmp);
   r := ToReal(dt1);
   if FMethodSort = 1 then
      Result := ord(r<0)-ord(r>0)
   else
      Result := ord(r>0)-ord(r<0);
end;

//doSort - Сортирует столбец с индексом из потока, согласно выбрнного MethodSort
//
procedure ThiStringTableMT._work_doSort;
begin
   Control.OnCompareLVItems := _OnCmpText;
   SortCol := ToInteger(_Data);
   Control.LVSort;
   _hi_CreateEvent_(_Data,@_event_onChange);
end;

//doSortDigit - Сортирует колонку с индексом из потока, как число, согласно выбрнного MethodSort
//
procedure ThiStringTableMT._work_doSortDigit;
begin
   Control.OnCompareLVItems := _OnCmpReal;
   SortCol := ToInteger(_Data);
   Control.LVSort;
   _hi_CreateEvent_(_Data,@_event_onChange);
end;

//doSortExtCmp - Сортирует колонку с индексом из потока, используя для сравнения значение из ExtCmp: >0, =0, или <0, согласно выбрнного MethodSort
//
procedure ThiStringTableMT._work_doSortExtCmp;
begin
   Control.LVMakeVisible(Control.LVCurItem,false);
   Control.OnCompareLVItems := _OnCmpExt;
   SortCol := ToInteger(_Data);
   Control.LVSort;
   _hi_CreateEvent_(_Data,@_event_onChange);
end;

//doSelEndStr - Выделяет и показывает последнюю строку таблицы при AutoMakeVisible=True
//
procedure ThiStringTableMT._work_doSelEndStr;
begin
   If not FAutoMakeVisible Then Exit;
   Control.LVCurItem:= Control.Count - 1;
   Control.LVMakeVisible(Control.Count - 1,True);
end;

function ThiStringTableMT.Get;
var   i:integer;
      s:string;
begin
   Result := '';
   if Control.LVColCount > 0 then
      begin
         s:= '';
         if (Assigned(Ilist)) and FFullSelect then
            s:= int2str(Control.LVItemImageIndex[Index]) + _StrDlm;
         if FColorItems and FFullSelect  then
            s:= s + PakColor2Str(Control.LVItemData[Index]) + _StrDlm;;
         for i:= 0 to Control.LVColCount - 1 do
            begin
               s:= s + Control.LVItems[Index,i];
               if i < Control.LVColCount - 1 then
                  s:= s + _StrDlm;
            end;
         Result:= s;   
      end;
end;

procedure ThiStringTableMT._aSet;
var ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < Control.Count)then
      Add(ToString(val),ind, true);
end;

procedure ThiStringTableMT._aAdd;
begin
   Add(ToString(val), -1);
end;

function ThiStringTableMT._aGet;
var ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < Control.Count)then
     begin
        Result := true;
        dtString(Val,Get(ind));
     end
   else Result := false;
end;

//_Count - Счетчик строк
//
function ThiStringTableMT._Count;
begin
   Result := Control.Count;
end;

//Strings - Содержит массив строк, где каждая строка это набор колонок, разделенных StrDelimiter'ом
//
procedure ThiStringTableMT._var_Strings;
begin
  if arr = nil then
     arr := CreateArray(_aset,_aget,_Count,_aadd);
  dtArray(_Data,Arr);
end;

//Count - Содержит количество строк в таблице
//
procedure ThiStringTableMT._var_Count;
begin
   dtInteger(_Data,Control.Count);
end;

//EndIdx - Содержит индекс последний строки в таблице
//
procedure ThiStringTableMT._var_EndIdx;
begin
  dtInteger(_Data,Control.Count - 1);
end;

//Select - Содержит выбранную строку со столбцами, разделенными подстрокой StrDelimiter
//
procedure ThiStringTableMT._var_Select;
begin
   if Control.LVCurItem = -1 then
      dtString(_Data,'')
   else
      dtString(_Data,Get(Control.LVCurItem));
end;

//FullTextTab - Хранит весь список строк таблицы с индексами иконок
//              при непустом списке иконок и разделенных символами 10 и 13
//
procedure ThiStringTableMT._var_FullTextTab;
var   i,j:integer;
      s:string;
begin
   if (Control.Count = 0) or (Control.LVColCount = 0) then Exit;
   s:= '';
   j:= 0;
   repeat
      if Assigned(Ilist) then s:= s + int2str(Control.LVItemImageIndex[j]) + _StrDlm;
      if FColorItems then s:= s + PakColor2Str(Control.LVItemData[j]) + _StrDlm;
      i:= 0;
      repeat
         s:= s + Control.LVItems[j,i];
         if i < Control.LVColCount - 1 then s:= s + _StrDlm;
         inc(i);
      until i > Control.LVColCount - 1; 
      s:= s + #13#10;
      inc(j);
   until j > Control.Count - 1;
   dtString(_Data,s);
end;

//Index - Содержит индекс выделенной строки
//
procedure ThiStringTableMT._var_Index;
begin
   dtInteger(_Data,Control.CurIndex);
end;

//SubItem - Содержит индекс столбца выделенной ячейки
//
procedure ThiStringTableMT._var_SubItem;
begin
   dtInteger(_Data,NewCurIdx);
end;

//Cell - Содержит значение выбранной ячейки под курсором
//
procedure ThiStringTableMT._var_Cell;
begin
   dtString(_Data,Control.LVItems[Control.LVCurItem,NewCurIdx]);
end;

//TopItem - Содержит индекс элемента, отображаемого в первой строке списка
//
procedure ThiStringTableMT._var_TopItem;
begin
   dtInteger(_Data,Control.LVTopItem);
end;

//PerPage - Содержит количество целых элементов, вмещающихся в одну страницу
//
procedure ThiStringTableMT._var_PerPage;
begin
   dtInteger(_Data,Control.LVPerPage);
end;

//ItemAtPos -Содержит индекс элемента, находящегося по координатам PosX, PosY в окне
//
procedure ThiStringTableMT._var_ItemAtPos;
begin
   dtInteger(_Data, Control.LVItemAtPos(Ms.X, Ms.Y));
end;

//StringTable - Содержит указатель на компонент
//
procedure ThiStringTableMT._var_StringTable;
begin
   _Data.Data_type := data_int;
   _Data.sdata := 'StringTable';
   _Data.idata := integer(Control);
end;

//SelectArray - Массив флажков выделения
//
procedure ThiStringTableMT._var_SelectArray;
begin
   if not Assigned(SAArray) then
      SAArray := CreateArray(SA_Set,SA_Get,_Count,nil);
   dtArray(_Data,SAArray);
end;

procedure ThiStringTableMT.SA_Set(var Item:TData; var Val:TData);
var   ind:integer;
begin
   ind:= ToIntIndex(Item);
   if (ind >= 0)and(ind < Control.Count)and(ToInteger(Val) = 1) then
     Control.LVItemState[ind]:= [lvisSelect]
   else if (ind >= 0)and(ind < Control.Count)and(ToInteger(Val) = 0) then
     Control.LVItemState[ind] := []; 
end;

function ThiStringTableMT.SA_Get(Var Item:TData; var Val:TData):boolean;
var  ind:integer;
begin
   ind:= ToIntIndex(Item);
   Result:= True;
   if (ind >= 0)and(ind < Control.Count) then
      if lvisSelect in Control.LVItemState[ind] then dtInteger(Val,1) else dtInteger(Val,0)
   else Result:= False;
end;

//CheckBoxes - Массив значений флажков (0 - не установлен, 1 - установлен)
//
procedure ThiStringTableMT._var_CheckBoxes;
begin
   if not Assigned(CBArray) then
      CBArray := CreateArray(CB_Set,CB_Get,_Count,nil);
   dtArray(_Data,CBArray);
end;

procedure ThiStringTableMT.CB_Set(var Item:TData; var Val:TData);
var   ind:integer;
begin
   ind:= ToIntIndex(Item);
   if (ind >= 0)and(ind < Control.Count) then
      Control.LVItemStateImgIdx[ind]:= toInteger(Val) + 1;
end;

function ThiStringTableMT.CB_Get(Var Item:TData; var Val:TData):boolean;
var   ind:integer;
begin
   ind:= ToIntIndex(Item);
   if (ind >= 0)and(ind < Control.Count) then
      begin
         dtInteger(Val,Control.LVItemStateImgIdx[ind] - 1);
         Result:= True;
      end
   else Result:= False;
end;

//#####################################################################
//#                                                                   #
//#                        Установка свойств                          #
//#                                                                   #
//#####################################################################

procedure ThiStringTableMT._work_doTextColor;begin FTextColor:= ToInteger(_Data);Control.LVTextColor:= FTextColor;Control.Invalidate;end;
procedure ThiStringTableMT._work_doTextBkColor;begin FTextBkColor:= ToInteger(_Data);Control.LVTextBkColor:= FTextBkColor;Control.Invalidate;end;
procedure ThiStringTableMT._work_doBkColor;begin FBkColor:= ToInteger(_Data);Control.LVBkColor:= FBkColor;Control.Invalidate;end;
procedure ThiStringTableMT._work_doGradientColor;begin FGradientColor:= ToInteger(_Data);Control.Invalidate;end;
procedure ThiStringTableMT._work_doShadowColor;begin FShadowColor:= ToInteger(_Data);Control.Invalidate;end;
procedure ThiStringTableMT._work_doTranspColor;begin FTransparent:= ToInteger(_Data);end;
procedure ThiStringTableMT._work_doAutoMakeVisible;begin FAutoMakeVisible:= ReadBool(_Data);end;
procedure ThiStringTableMT._work_doStyle;begin FStyle:= TListViewStyle(ToInteger(_Data));Control.LVStyle:= FStyle;SetColumns(Clist,1);end;
procedure ThiStringTableMT._work_doTextAlign;begin FTextAlign:= TTextAlign(ToInteger(_Data));end;
procedure ThiStringTableMT._work_doSaveColProp;begin FSaveColProp:= ReadBool(_Data);end;
procedure ThiStringTableMT._work_doSaveWidth;begin FSaveWidth:= ReadBool(_Data);end;
procedure ThiStringTableMT._work_doSaveImgIndex;begin FSaveImgIndex:= ReadBool(_Data);end;
procedure ThiStringTableMT._work_doSaveItemsColor;begin FSaveItemsColor:= ReadBool(_Data);end;
procedure ThiStringTableMT._work_doSaveColor;begin FSaveColor:= ReadBool(_Data);end;
procedure ThiStringTableMT._work_doStaticColumn;begin FStaticColumn:= ReadBool(_Data);end;
procedure ThiStringTableMT._work_doSelectFind;begin FSelectFind:= ReadBool(_Data);end;
procedure ThiStringTableMT._work_doMethodSort;begin FMethodSort:= ToInteger(_Data);end;
procedure ThiStringTableMT._work_doTableWBreak;begin FTableWBreak:= ReadBool(_Data);Control.Invalidate;end;
procedure ThiStringTableMT._work_doGrid3D;begin FGrid3D:= ReadBool(_Data);Control.Invalidate;end;
procedure ThiStringTableMT._work_doBumpText;begin FBumpText:= ReadBool(_Data);Control.Invalidate;end;
procedure ThiStringTableMT._work_doModeMakeVisible;begin FModeMakeVisible:= ToInteger(_Data);end;
procedure ThiStringTableMT._work_doStyleGrid3D;begin FStyleGrid3D:= ToInteger(_Data);Control.Invalidate;end;
procedure ThiStringTableMT._work_doEnableOnClick;begin FEnableOnClick:= ReadBool(_Data);end;
procedure ThiStringTableMT._work_doReplaceFind;begin FFindReplace:= ReadBool(_Data);end;
procedure ThiStringTableMT._work_doTabGrid;begin FTabGrid:= ReadBool(_Data);Control.Invalidate;end;
procedure ThiStringTableMT._work_doTabGridFrame;begin FTabGridFrame:= ReadBool(_Data);Control.Invalidate;end;
procedure ThiStringTableMT._work_doSingleString;begin FSingleString:= ReadBool(_Data);Control.Invalidate;end;
procedure ThiStringTableMT._work_doGradient;begin FGradient:= ReadBool(_Data);Control.Invalidate;end;

procedure ThiStringTableMT._work_doGrid;
begin
   FGrid:= ReadBool(_Data);
   SetOption(FGrid,lvoGridLines);
end;

procedure ThiStringTableMT._work_doFlat;
begin
   FFlat:= ReadBool(_Data);
   SetOption(FFlat,lvoFlatsb);
end;

procedure ThiStringTableMT._work_doHeaderDragDrop;
begin
   FHeaderDragDrop:= ReadBool(_Data);
   SetOption(FHeaderDragDrop,lvoHeaderDragDrop);
end;

procedure ThiStringTableMT._work_doTrackSelect;
begin
   FTrackSelect:= ReadBool(_Data);
   SetOption(FTrackSelect,lvoTrackSelect);
end;

procedure ThiStringTableMT._work_doRowSelect;
begin
   FRowSelect:= ReadBool(_Data);
   SetOption(FRowSelect,lvoRowSelect);
end;

procedure ThiStringTableMT._work_doCheckBoxes;
begin
   if FExtIconsCheck then exit;
   FCheckBoxes:= ReadBool(_Data);
   SetOption(FCheckBoxes,lvoCheckBoxes);
end;

procedure ThiStringTableMT._work_doMultiSelect;
begin
   FMultiSelect:= ReadBool(_Data);
   SetOption(FMultiSelect,lvoMultiSelect);
end;

procedure ThiStringTableMT._work_doInfoTip;
begin
   FInfoTip:= ReadBool(_Data);
   SetOption(FInfoTip,lvoInfoTip);
end;

procedure ThiStringTableMT.SetOption;
var   l:TListViewOptions;
begin
   l:= Control.LVOptions;
   if OSet then include(l,Option)
   else exclude(l,Option);
   Control.LVOptions:= l;
end;

//#####################################################################
//#                                                                   #
//#            Управление и доступ к параметрам столбцов              #
//#                                                                   #
//#####################################################################

//------------------   Доступ к массиву столбцов   --------------------

//ColumnArray - Массив форматных свойств столбцов
//
procedure ThiStringTableMT._var_ColumnArray;
begin
  if not Assigned(CLArray) then
     CLArray := CreateArray(_SetCol,_GetCol,_CountCol,_AddCol);
  dtArray(_Data,CLArray);
end;

procedure ThiStringTableMT._SetCol(var Item:TData; var Val:TData);
var   s:string;
      ind:integer;
begin
   ind:= ToIntIndex(Item);
   s:= ToString(Val);
   if(ind >= 0)and(ind < CList.Count) then CList.Items[ind]:=InitColStr(s);
   SetColumns(CList,1);
end;

function ThiStringTableMT._GetCol(Var Item:TData; var Val:TData):boolean;
var   ind:integer;
begin
   ind:= ToIntIndex(Item);
   Result:= True;
   if(ind >= 0)and(ind < CList.Count) then
      dtString(Val,Clist.Items[ind])
   else Result:= False;
end;

function ThiStringTableMT._CountCol:integer;
begin
   Result:= CList.Count;
end;

procedure ThiStringTableMT._AddCol(var Val:TData);
begin
   _work_doAddColumn(Val,0);
end;

//--------------------   Управление столбцами   -----------------------

//doAddColumn - Добавляет новый столбец в таблицу. Строка инициализации в потоке
//             (формат: Название=Ширина=Индекс иконки=Индекс выравнивания (0 - taLeft; 1 - taRight; 2 - taCenter))
//
procedure ThiStringTableMT._work_doAddColumn;
var   s:string;
begin
   s:= ToString(_Data);
   Control.LVColAdd('',FTextAlign,FColumnWidth);
   CList.Add(InitColStr(s));
   SetColumns(CList,1);
   if integer(Index) = 0 then exit;
   _hi_CreateEvent_(_Data,@_event_onChangeColLst);
end;

//doDeleteCol - Удаляет столбец из таблицы по индексу из потока
//
procedure ThiStringTableMT._work_doDeleteCol;
var   ind:integer;
begin
   ind:= ToInteger(_Data);
   if(ind >= 0)and(ind < CList.Count) then
      begin
         Control.LVColDelete(ind);
         CList.Delete(ind);
      end;
   SetColumns(CList,1);
   _hi_CreateEvent_(_Data,@_event_onChangeColLst);
end;

//doClearCol - Удаляет содержимое столбца по индексу из потока
//
procedure ThiStringTableMT._work_doClearCol;
var   x,y:integer;
      dt:TData;
begin
    dtNull(dt);
    x:= ToInteger(_Data);
    if(x >= 0)and(x < CList.Count) then
       for y:= 0 to Control.Count - 1 do MX_Set(x,y,dt);
   Control.Invalidate;
   _hi_CreateEvent_(_Data,@_event_onChange);
end;

function ThiStringTableMT.InitColStr;
var   s,ss,sd,se,sf,sh:string;
begin
   s:= val;
   sf:= s + '=';
   ss:= GetTok(sf,'=');
   sd:= GetTok(sf,'=');
   sh:= GetTok(sf,'=');
   se:= GetTok(sf,'=');
   if s = '' then s:= '=' + int2str(FColumnWidth) + '=' + int2str(integer(FTextAlign))
   else begin
      if sd = '' then sd:= int2str(FColumnWidth);
      if se = '' then se:= int2str(integer(FTextAlign));
      s:= ss + '=' + sd + '=' + sh + '=' + se;
   end;
   Result:= s;
end;

//--------------------   Переменные столбцаов   ----------------------

//CountCol - Содержит количество столбцов
//
procedure ThiStringTableMT._var_CountCol;
begin
   dtInteger(_Data,CList.Count);
end;

//EndIdxCol - Содержит индекс последнего столбца
//
procedure ThiStringTableMT._var_EndIdxCol;
begin
  dtInteger(_Data,CList.Count - 1);
end;

//#####################################################################
//#                                                                   #
//#                      Доступ к матрице строк                       #
//#                                                                   #
//#####################################################################

//Matrix - Матрица строк
//
procedure ThiStringTableMT._var_Matrix;
begin
   if not Assigned(Obj) then begin
      New(Obj);
      Obj._Set  := MX_Set;
      Obj._Get  := MX_Get;
      Obj._Rows := _mRows; 
      Obj._Cols := _mCols; 
   end;
   dtMatrix(_Data,Obj);
end;

function ThiStringTableMT.MX_Get;
begin
   if(x >= 0)and(y >= 0)and(y < Control.Count)and(x < Control.LVColCount) then
      dtString(Result,Control.LVItems[y,x])
   else dtNull(Result);
end;

procedure ThiStringTableMT.MX_Set;
begin
   if(x >= 0)and(y >= 0)and(y < Control.Count)and(x < Control.LVColCount) then
     Control.LVItems[y,x]:= ToString(Val);
end;

function ThiStringTableMT._mRows;
begin
  Result := Control.Count; 
end;

function ThiStringTableMT._mCols;
begin
  Result := Control.LVColCount; 
end;

//#####################################################################
//#                                                                   #
//#               Управление и доступ к списку иконок                 #
//#                                                                   #
//#####################################################################

//-----------------   Инициализация списка иконок   -------------------

procedure ThiStringTableMT.SetIcons;
var i:integer;
begin
   if not FAssignedIList then exit;
   IList:= NewImageList(Control);
   if FImgsize = 0 then FImgsize:= GetSystemMetrics(SM_CXICON);
   SetIListProp;
   for i:= 0 to Value.Count - 1 do IList.AddIcon(Value.Objects[i]);
end;

//-------------   Инициализация списка иконок флажков  ----------------

procedure ThiStringTableMT.SetIconsCheck;
var i:integer;
begin
   IChList:= NewImageList(Control);
   IChList.BkColor:= FBkColor;
   IChList.ImgWidth:= FImgSize;
   IChList.ImgHeight:= FImgSize;
   for i:= 0 to Value.Count - 1 do IChList.AddIcon(Value.Objects[i]);
end;

//----------   Инициализация списка дополнительных иконок  ------------

procedure ThiStringTableMT.SetMiscIcons;
begin
   IDList:= NewStrListEx;
   IDList.Assign(Value);
end;

//--------   Управление основными свойствами списка иконок   ----------

procedure ThiStringTableMT.SetIListProp;
begin
   IList.BkColor:= FIconColColor;
   IList.ImgWidth:= FImgSize;
   IList.ImgHeight:= FImgSize;
end;

//-------------------   Доступ к массиву иконок   ---------------------

//IconArray - Массив иконок
//
procedure ThiStringTableMT._var_IconArray;
begin
  if Assigned(Ilist) then
     begin
        if not Assigned(ICArray) then ICArray := CreateArray(_SetIcon,_GetIcon,_CountIcon,_AddIcon);
        dtArray(_Data,ICArray);
     end
  else dtArray(_Data,nil);
end;

procedure ThiStringTableMT._SetIcon(var Item:TData; var Val:TData);
var   ind:integer;
begin
   if not Assigned(Ilist) then Exit;
   SetIListProp;
   ind:= ToIntIndex(Item);
   if (ind >= 0)and(ind < IList.Count) and _IsIcon(Val) then
      IList.ReplaceIcon(ind, ToIcon(val).handle);
   Control.Invalidate;
end;

function ThiStringTableMT._GetIcon(Var Item:TData; var Val:TData):boolean;
var   ind:integer;
begin
   Result:= False;
   if not Assigned(Ilist) then Exit;
   SetIListProp;
   ind:= ToIntIndex(Item);
   if (ind >= 0)and(ind < IList.Count) then begin
      Icon.Clear;
      Icon.Handle:= IList.ExtractIcon(ind);
      dtIcon(Val,Icon);
      Result:= True;
   end;
end;

function ThiStringTableMT._CountIcon:integer;
begin
   Result:=0;
   if not Assigned(Ilist) then Exit;
   Result:= IList.Count;
end;

procedure ThiStringTableMT._AddIcon(var Val:TData);
begin
   if not Assigned(Ilist) then Exit;
   SetIListProp;
   if _IsIcon(Val) then IList.AddIcon(ToIcon(Val).Handle);
   Control.Invalidate;
end;

//-----------------   Управление списком иконок   ---------------------

//doDeleteIcon - Удаляет иконку из списка иконок по индексу из потока
//
procedure ThiStringTableMT._work_doDeleteIcon;
var   ind:integer;
begin
   ind:= ToInteger(_Data);
   if not (Assigned(IList) and (ind >= 0) and (ind < IList.Count)) then Exit;
   IList.Delete(ind);
   SetColumns(CList,1);
   _hi_CreateEvent_(_Data,@_event_onChangeImgLst);
end;

//doGetIcon - Полуает иконку из списка иконок таблицы по индексу из потока
//
procedure ThiStringTableMT._work_doGetIcon;
var   dt,di:TData;
      bmp:PBitmap;
begin
   dtNull(di);
   bmp:= nil;
   Icon.Clear;
   if Assigned(IList) and (Ilist.Count <> 0) then
      if _GetIcon(_Data,dt) then Icon{$ifndef F_P}^{$endif} := ToIcon(dt){$ifndef F_P}^{$endif} ;
   if Icon.Handle <> 0 then
      if FIconToBmp then begin
         bmp:= NewDIBBitmap(Icon.Size,Icon.Size,pf32bit);
         bmp.Handle:= Icon.Convert2Bitmap(FTransparent);
         dtBitmap(di,bmp);
      end
      else dtIcon(di,Icon);
   _hi_onEvent(_event_onGetIcon,di);
   bmp.free;
end;

//doGetIconIdx - Получает индекс иконки для строки по индексу из потока
//
procedure ThiStringTableMT._work_doGetIconIdx;
var   idx,ind:integer;
begin
   ind:= ToInteger(_Data);
   idx:= -1;
   if Assigned(IList)and(Ilist.Count <> 0)and(Control.Count<>0) then
      idx:= Control.LVItemImageIndex[ind]; 
   _hi_CreateEvent(_Data,@_event_onGetIconIdx,idx);
end;

procedure ThiStringTableMT.InsertIcon;
var   dt:TData;
      i,ind:integer;
begin
   dt:= Data;
   ind:= integer(Index);
   if not (Assigned(IList)and _IsIcon(dt)and(ind >= 0)and(ind < IList.Count)) then exit;
   i:= IList.Count - 1;
   IList.AddIcon(IList.ExtractIcon(i));
   repeat
      IList.ReplaceIcon(i,IList.ExtractIcon(i-1));
      dec(i);            
   until i <= ind;
   IList.ReplaceIcon(ind, ToIcon(dt).handle);
   SetColumns(CList,1);
end;

//doClearIcons - Очищает список иконок
//
procedure ThiStringTableMT._work_doClearIcons;
begin
   ClearIcons;
   SetColumns(CList,1);
   _hi_CreateEvent_(_Data,@_event_onChangeImgLst);
end;

procedure ThiStringTableMT.ClearIcons;
begin
   if (not Assigned(IList)) or (Ilist.Count = 0) then Exit;
   repeat
     IList.Delete(Ilist.Count - 1);
   until Ilist.Count = 0;
//   IList.Clear;
   Control.Invalidate;
end;

//--------------   Извлечение дополнительной иконки   -----------------

//doGetMiscIcon - Полуает иконку из списка нередактируемых дополнительных иконок по индексу из потока
//
Procedure ThiStringTableMT._work_doGetMiscIcon;
var   ind:integer;
      bmp:PBitmap;
      di:TData;
begin
   dtNull(di);
   bmp:= nil;
   ind:= ToInteger(_Data);
   if ind > IDList.Count - 1 then exit;
   Icon.Clear;
   Icon.Handle:= IDList.Objects[ind];
   if Icon.Handle <> 0 then
      if FIconToBmp then
         begin
            bmp:= NewDIBBitmap(Icon.Size,Icon.Size,pf32bit);
            bmp.Handle:= Icon.Convert2Bitmap(FTransparent);
            dtBitmap(di,bmp);
         end
      else dtIcon(di,Icon);
   _hi_onEvent(_event_onGetMiscIcon,di);
   bmp.free;
end;

//----------------   Загрузка и сохранение иконок   -------------------

//doLoadPakIcons - Импортирует иконки из файлов ресурсов (*.exe,*.dll,*.ocx,*.icl) в список иконок
//
procedure ThiStringTableMT._work_doLoadPakIcons;
var   i,IconCount:integer;
      fn:string;
begin
   if not Assigned(IList) then exit;
   fn:= ReadString(_Data,_data_IconsFileName,_prop_IconsFileName);
   if not LFileExists_MT(fn,LOAD_PAK_ICONS) then Exit;
   Icon.Clear;
   IconCount:= GetFileIconCount(fn);
   if IconCount <> 0 then begin
      ClearIcons;
      i:= 0;
      repeat
         Icon.LoadFromExecutable(fn,i);
         SetIListProp;
         IList.AddIcon(Icon.Handle);
         inc(i);
      until i = IconCount;
   end;
   SetColumns(CList,1);
   _hi_CreateEvent_(_Data,@_event_onChangeImgLst);
end;

//doLoadIcon - Загружает иконку из файла, вставляя ее на место в списке с индексом из потока,
//             если индекс больше длины списка, то вставляет в конец списка
//
procedure ThiStringTableMT._work_doLoadIcon;
var   ind:integer;
      fn:string;
      dt:TData;
begin
   if not Assigned(IList) then exit;
   ind:=Tointeger(_Data);
   fn:= ReadString(_Data,_data_IconFileName,_prop_IconFileName);
   if not LFileExists_MT(fn,LOAD_ICON) then Exit;
   Icon.Clear;
   Icon.LoadFromFile(fn);
   dtIcon(dt,Icon);
   if (ind >= IList.Count) or (ind < 0) then _AddIcon(dt)
   else if (ind >= 0 ) and (ind < IList.Count ) then InsertIcon(dt,ind);
   SetColumns(CList,1);
   _hi_CreateEvent_(_Data,@_event_onChangeImgLst);
end;

//doSaveIcon - Сохраняет иконку с индексом из потока в файле
//
procedure ThiStringTableMT._work_doSaveIcon;
var   dt,di:TData;
      fn:string;
      Pos:Integer;
      Bitmaps:array of HBitmap;
      II:TIconInfo;
      Strm, st:PStream;
begin
   if not Assigned(IList) then exit;
   di:= _Data;
   fn:= ReadString(_Data,_data_IconFileName,_prop_IconFileName);
   if SFileExists_MT(fn,SAVE_ICON_FILE) then Exit;
   Icon.Clear;
   if _GetIcon(di,dt) then Icon{$ifndef F_P}^{$endif} := ToIcon(dt){$ifndef F_P}^{$endif} ;
   st:= NewWriteFileStream(fn);
   Strm:= NewMemoryStream;
   Pos:= Strm.Position;
   SetLength(Bitmaps, 2);
   GetIconInfo(Icon.Handle,II);
   Bitmaps[0]:= II.hbmColor;
   Bitmaps[1]:= II.hbmMask;
   if not SaveIcons2StreamEx(Bitmaps,Strm) then Strm.Seek(Pos,spBegin);
   Strm.Position:= 0;
   Stream2Stream(st,Strm,Strm.Size);
   st.free;
   Strm.free;
end;

//-------------------   Сохранние списка иконок   ---------------------

//doSaveIList - Сохраняет список иконок в файле
//
procedure ThiStringTableMT._work_doSaveIList;
var   fn:string;
begin
   fn:= ReadString(_Data,_data_IListFileName,_prop_IListFileName);
   if SFileExists_MT(fn,SAVE_ILIST) then Exit;
   SaveIListToFile(fn,Index);
end;

procedure ThiStringTableMT.SaveIListToFile;
var   Strm, st:PStream;
      i,Pos:Integer;
      Bitmaps:array of HBitmap;
      II:TIconInfo;
      Bmp:HBitmap;
begin
   if not Assigned(Ilist) then Exit;
   for I:= 0 to IList.Count - 1 do if IList.ExtractIcon(I) = 0 then Exit;
   Strm:= NewMemoryStream;
   Pos:= Strm.Position;
   SetLength(Bitmaps, IList.Count * 2);
   for I:= 0 to IList.Count - 1 do begin
      GetIconInfo(IList.ExtractIcon(I),II);
      Bitmaps[I * 2]:= II.hbmColor;
      Bitmaps[I * 2 + 1]:= II.hbmMask;
   end;
   if not SaveIcons2StreamEx(Bitmaps,Strm) then Strm.Seek(Pos,spBegin);
   for i:= 0 to High(Bitmaps) do begin
      Bmp:= Bitmaps[i];
      if Bmp <> 0 then DeleteObject(Bmp);
   end;
   If Index <> 0 then begin
      st:= NewWriteFileStream(FileName);
      Strm.Position:= 0;
      Stream2Stream(st,Strm,Strm.Size);
      st.free;
   end
   else begin
      Strm.Position:= 0;
      Stream2Stream(SICLStream,Strm,Strm.Size);
   end;
   Strm.free;
end;

//-------------------   Загрузка списка иконок   ----------------------

//doLoadIList - Загружает список иконк из файла
//
procedure ThiStringTableMT._work_doLoadIList;
var   fn:string;
begin
   fn:= ReadString(_Data,_data_IListFileName,_prop_IListFileName);
   if not LFileExists_MT(fn,LOAD_PAK_ICONS) then Exit;
   LoadIListFromFile(fn,1);
   SetColumns(CList,1);
end;

procedure ThiStringTableMT.LoadIListFromFile;
var   Strm, st: PStream;
      Pos: DWord;
      Data: TStreamData;

   function ReadIcon : Boolean;
   var   IDI, FoundIDI : TIconDirEntry;
         I, j: Integer;
         II : TIconInfo;
         BIH : TBitmapInfoheader;
         IH : TIconHeader;
         Mem: PStream;
         ImgBmp, MskBmp : PBitmap;
   begin
      ImgBmp:= nil;
      MskBmp:= nil;
      Result:= False;
      if Strm.Read(IH, Sizeof(IH)) <> Sizeof(IH) then Exit;
      if (IH.idReserved <> 0) or ((IH.idType <> 1) and (IH.idType <> 2)) or
         (IH.idCount < 1) then exit;
      for j:= 1 to IH.idCount do begin
         if Strm.Read(IDI, Sizeof(IDI)) <> Sizeof(IDI) then Exit;
         if (IDI.bWidth <> IDI.bHeight) and (IDI.bWidth * 2 <> IDI.bHeight) or 
            (IDI.bWidth = 0) then exit;
         FoundIDI:= IDI;
         Strm.Seek(Integer(Pos) + (FoundIDI.dwImageOffset), spBegin);
         Data.fSize:= FoundIDI.bWidth;
         if Strm.Read(BIH, Sizeof(BIH)) <> Sizeof(BIH) then Exit;
         if (BIH.biWidth <> integer(Data.fSize)) or (BIH.biHeight <> integer(Data.fSize) * 2) and
            (BIH.biHeight <> integer(Data.fSize)) then exit;
         BIH.biHeight:= Data.fSize;
         Mem:= NewMemoryStream;
      TRY
         Mem.Write(BIH, Sizeof(BIH));
         if (FoundIDI.bColorCount >= 2) or (FoundIDI.bReserved = 1) or (FoundIDI.bColorCount = 0) then begin
            I:= 0;
            if BIH.biBitCount <= 8 then I := (1 shl BIH.biBitCount) * Sizeof(TRGBQuad);
            if I > 0 then if Stream2Stream(Mem, Strm, I) <> DWORD(I) then exit;
            I:= ((BIH.biBitCount * Data.fSize + 31) div 32) * 4 * Data.fSize;
            if Stream2Stream(Mem, Strm, I) <> DWORD(I) then exit;
            ImgBmp:= NewDIBBitmap(Data.fSize, Data.fSize,pf32bit);
            Mem.Seek(0, spBegin);
            ImgBmp.LoadFromStream(Mem);
            if ImgBmp.Empty then exit;
         end;
         BIH.biBitCount:= 1;
         Mem.Seek(0, spBegin);
         Mem.Write(BIH, Sizeof(BIH));
         I:= 0;
         Mem.Write(I, Sizeof(I));
         I:= $FFFFFF;
         Mem.Write(I, Sizeof(I));
         I:= ((Data.fSize + 31) div 32) * 4 * Data.fSize;
         if Stream2Stream(Mem, Strm, I) <> DWORD(I) then exit;
         MskBmp:= NewDIBBitmap(Data.fSize,Data.fSize,pf32bit);
         Mem.Seek(0, spBegin);
         MskBmp.LoadFromStream(Mem);
         if MskBmp.Empty then exit;
         FillChar(II, Sizeof(II), 0);
         II.fIcon:= True;
         II.xHotspot:= 0;
         II.yHotspot:= 0;
         II.hbmMask:= MskBmp.ReleaseHandle;
         II.hbmColor:= ImgBmp.ReleaseHandle;
         Data.fHandle:= CreateIconIndirect(II);
         SetIListProp;
         IList.AddIcon(Data.fHandle);
         DestroyIcon(Data.fHandle);
         DeleteObject(II.hbmMask);
         DeleteObject(II.hbmColor);         
         Strm.Seek(integer(Pos) + Sizeof(IH) +  Sizeof(IDI)*j, spBegin);
      FINALLY
         ImgBmp.free;
         MskBmp.free;
         Mem.free;      
      END;
      end;
      Result:= Data.fHandle <> 0;
   end;

begin
   Strm:= NewMemoryStream;
   if ((Index = 0) and not Assigned(LICLStream)) or not Assigned(IList) then exit;
   if ((Index = 0) and (LICLStream.Size = 0)) then exit; 
   if (Index = 0) then begin
     LICLStream.Position:= 0;
     Stream2Stream(Strm,LICLStream,LICLStream.Size);
   end
   else begin
      st:= NewReadFileStream(Filename);
      Stream2Stream(Strm,st,st.Size);
      st.free;
   end;
   ClearIcons;
   Strm.Position:= 0;
   Data:= Strm.Data;
   Pos:= Data.fPosition;
   ReadIcon;
   Strm.free;
   Control.Invalidate;
   _hi_onEvent(_event_onChangeImgLst);
end;

//------------------   Переменные списка иконок   ---------------------

//CountIcons - Содержит количество иконок в списке иконок таблицы
//
procedure ThiStringTableMT._var_CountIcons;
begin
   dtInteger(_Data,IList.Count);
end;

//EndIdxIcons - Содержит индекс последней иконки в списке иконок таблицы
//
procedure ThiStringTableMT._var_EndIdxIcons;
begin
  dtInteger(_Data,IList.Count - 1);
end;

//ImgSize - Содержит размер иконок в списках иконок Icons и IconsCheck
//
procedure ThiStringTableMT._var_ImgSize;
begin
   dtInteger(_Data,FImgSize);
end;

//#####################################################################
//#                                                                   #
//#                     Проверка наличия файлов                       #
//#                                                                   #
//#####################################################################

//--------------   Проверка наличия загружаемых файлов   --------------

//LFileExists_MT - При отсутствии загружаемого файла выдает событие для генерации сообщения,
//                 после чего отменяет операцию загрузки. MT-поток запроса содержит -
//                 - (Код файловой операции (0 - Load, 2 - LoadIcon, 4 - LoadPakIcons,
//                 5 - LoadIList, 7 - LoadExtIcon, 10 - LoadStrLst)(Имя файла)
//
function ThiStringTableMT.LFileExists_MT;
var dt1,dt2:TData;
begin
   Result:= True;
   if FileExists(FileName) then Exit;
   dtInteger(dt1, FileOperation);
   dtString(dt2, FileName);
   dt1.ldata := @dt2;
   _ReadData(dt1, _data_LFileExists_MT);
   Result:=False;
end;

//--------------   Проверка наличия сохраняемых файлов   --------------

//SFileExists_MT - Если при сохранении в файле эта точка содержит 0,
//                 то операция сохранения будет продолжена, иначе - отменена,
//                 MT-поток запроса содержит - (Код файловой операции (1 - Save,
//                 3 - SaveIcon, 6 - SaveIList, 8 - SaveStrLst, 9 - AppendStrLst)(Имя файла)
//
function ThiStringTableMT.SFileExists_MT;
var dt1,dt2:TData;
begin
   Result:= False;
   if not FileExists(FileName) then Exit;
   dtInteger(dt1, FileOperation);
   dtString(dt2, FileName);
   dt1.ldata := @dt2;
   _ReadData(dt1, _data_SFileExists_MT); 
   if ToInteger(dt1) <> 0 then Result:= True;
end;

//---------------   Завершение редактирования таблицы   ---------------

//EndEdit - Если при выходе из редактирования эта точка содержит 0,
//          то операция текущего редактирования будет отменена
//
procedure ThiStringTableMT._work_doEndEdit;
begin
   if not FRedaction then Exit;
   if  ReadInteger(_Data,_data_EndEdit,0) = 0 then
      Control.Perform(WM_KEYDOWN,27,0)
   else
      Control.Perform(WM_JUSTFREE,0,0);
end;

//#####################################################################
//#                                                                   #
//#                    Загрузка/сохранение таблицы                    #
//#                                                                   #
//#####################################################################

//----------------------   Сохранение таблицы   -----------------------

//doSave - Сохраняет таблицу в файле
//
procedure ThiStringTableMT._work_doSave;
var   i,j,p:integer;
      lst:PStrList;
      str,fn,s,sa,sb:string;
      Count:dword;
begin
   lst:= NewStrList;
   lst.Add('');
   FTblStream.free;
   FTblStream:= NewMemoryStream;
   STblStream:= NewMemoryStream;
   SIClStream:= NewMemoryStream;
TRY
   if Index <> 0 then begin
      fn:= ReadString(_Data,_data_FileName,_prop_FileName);
      if SFileExists_MT(fn,SAVE_TABLE) then Exit;
   end;
   if not FSaveWidth then
      str:= CList.text
   else begin
      for i:= 0 to CList.Count - 1 do begin
         s:= CList.Items[i];
         sa:= GetTok(s,'=');
         sb:= GetTok(s,'=');
         sb:= int2str(Control.LVColWidth[i]);
         CList.Items[i]:= sa + '=' + sb + '=' + s; 
      end;
      str:= CList.text;
   end;
   Replace(str,#13#10,_StrDlm);
   if not FStaticColumn then begin
      if FSaveColProp then
         if FSaveColor then
            lst.Items[0]:= int2str(Color2RGB(FTextColor)) + _ColorDlm + int2str(Color2RGB(FTextBkColor)) + _ColorDlm + int2str(Color2RGB(FBkColor)) + _ColorDlm + int2str(Color2RGB(FTransparent)) + _ColorDlm + str
         else lst.Items[0]:= str
      else begin
         for i:= 0 to Control.LVColCount - 1 do
            if i = 0 then lst.Items[0]:= Control.LVColText[i]
            else lst.Items[0]:= lst.Items[0] + _StrDlm + Control.LVColText[i];
      end;
      p:= 1;
      end
   else p:= 0;
   if (Control.Count > 0)and(Control.LVColCount > 0) then
      for i:= 0 to Control.Count - 1 do begin
         lst.Add('');
         for j:= 0 to Control.LVColCount - 1 do
            if j = 0 then begin
               lst.Items[i+p]:= '';
               if FSaveImgIndex then lst.Items[i+p]:= int2str(Control.LVItemImageIndex[i]) + _StrDlm;
               if FSaveItemsColor then lst.Items[i+p]:= lst.Items[i+p] + PakColor2Str(Control.LVItemData[i]) + _StrDlm;         
               lst.Items[i+p]:= lst.Items[i+p] + Control.LVItems[i,j];
            end
            else lst.Items[i+p]:= lst.Items[i+p] + _StrDlm + Control.LVItems[i,j];
      end;
   if p = 0 then lst.Delete(Control.Count);
   if Index = 0 then
      lst.SaveToStream(STblStream)
   else
      lst.SaveToFile(fn);
   if Index <> 0 then Exit;
   SaveIListToFile('',0);
   STblStream.Position:= 0;
   SICLStream.Position:= 0;
   Count:= STblStream.Size; 
   FTblStream.Write(Count,4);
   Stream2Stream(FTblStream,STblStream,STblStream.Size);
   Count:= SICLStream.Size;
   FTblStream.Write(Count,4);
   Stream2Stream(FTblStream,SICLStream,SICLStream.Size);   
FINALLY
   lst.free;
   STblStream.free;
   SICLStream.free;
END;
end;

//-----------------------   Загрузка таблицы   ------------------------

//doLoad - Загружает таблицу из файла
//
procedure ThiStringTableMT._work_doLoad;
var   i,p:integer;
      lst:PStrList;
      s,sa,tc,tbc,bc,tr,fn:string;
      dt:TData;
      Count:dword;
begin
   if Index = 0 then begin
      dtNull(dt);
      LoadStream:= ReadStream(dt,_data_FTblStream,nil);
      if LoadStream = nil then exit; 
      LTblStream:= NewMemoryStream;
      LICLStream:= NewMemoryStream; 
      LoadStream.Position:= 0;
      LoadStream.Read(Count,4);
      Stream2Stream(LTblStream,LoadStream,Count);
      LoadStream.Read(Count,4);               
      Stream2Stream(LICLStream,LoadStream,Count);
      if LICLStream.Size <> 0 then LoadIListFromFile('',0);
      if LTblStream.Size = 0 then exit;
      LTblStream.Position:= 0;
      lst:= NewStrList;
      lst.LoadFromStream(LTblStream,False);
      LICLStream.free;
      LTblStream.free;
   end
   else begin
      fn:= ReadString(_Data,_data_FileName,_prop_FileName);
      if not LFileExists_MT(fn,LOAD_TABLE) then Exit; 
      lst:= NewStrList;
      lst.LoadFromFile(fn);
   end;
   Control.Clear;
   if not FStaticColumn then begin
      while Control.LVColCount > 0 do Control.LVColDelete(0);
      if lst.Count > 0 then begin
         sa:= lst.Items[0];
         s := sa + _ColorDlm;
         tc:= gettok(s,_ColorDlm);
         tbc:=gettok(s,_ColorDlm);
         if (tc <> '') and (tbc ='') then begin
            tc:= ''; bc:= ''; tr:= ''; s:= sa;
         end
         else begin
            bc:= gettok(s,_ColorDlm);
            tr:= gettok(s,_ColorDlm);
            if (tc <> '') and (tbc <> '') and (bc <> '') and (tr <> '') then begin
               dtString(dt,tc); _work_doTextColor(dt,0);
               dtString(dt,tbc); _work_doTextBkColor(dt,0);
               dtString(dt,bc); _work_doBkColor(dt,0);
               dtString(dt,tr); _work_doTranspColor(dt,0);
            end;
         end;         
         Replace(s,_ColorDlm,'');
         Replace(s,_StrDlm,#13#10);
         CList.text:= s;
         SetColumns(CList,0);
      end;
      p:= 1;
   end else p:= 0;
   if lst.Count > 0 then begin
      for i:= p to lst.Count - 1 do Add(lst.Items[i]);
      Control.Invalidate;
   end;
   lst.free;
   _hi_CreateEvent_(_Data,@_event_onChange);
end;

//doSaveFStream - Сохраняет полную таблицу в потоке данных
//
procedure ThiStringTableMT._work_doSaveFStream;
begin
   _work_doSave(_Data,0);
end;

//doLoadFStream - Загружает полную таблицу из потока данных
//
procedure ThiStringTableMT._work_doLoadFStream;
begin
   _work_doLoad(_Data,0);
end;

//FStream - Содержит данные полной таблицы после выполнения методов doLoadFStream и doSaveFStream
//
procedure ThiStringTableMT._var_FStream;
begin
   if not Assigned(FTblStream) then exit; 
   dtNull(_Data);
   dtStream(_Data,FTblStream);
end;

//---------------------   Строковый накопитель   ----------------------

procedure ThiStringTableMT.SetTextStrLst;
begin
   FList:= NewStrList;
   Flist.Text:= Value;
end;

//doAddStrLst - Добавляет запись в строковый накопитель
//
procedure ThiStringTableMT._work_doAddStrLst;
begin
   FList.Add(ReadString(_Data,_data_StrLst,''));
   _hi_CreateEvent_(_Data,@_event_onChangeStrLst);
end;

//doTblStrLst - Инициализирует таблицу строками из строкового накопителя
//
procedure ThiStringTableMT._work_doTblStrLst;
var   ind:integer;
begin
   if not FAppTxtStrLst then Control.Clear;
   for ind:= 0 to FList.Count - 1 do Add(FList.Items[ind]);
   _hi_CreateEvent_(_Data,@_event_onChange);
end;

//doGetStrList - Получает строку из строкового накопителя по индексу из потока
//
procedure ThiStringTableMT._work_doGetStrList;
var   ind:integer;
      s:string;
begin
   ind := ToIntIndex(_Data);
   s:= '';
   if(ind >= 0)and(ind < FList.Count)then s:= FList.Items[ind];
   _hi_onEvent(_event_onGetStrList,s);
end;

//doClearStrLst - Очищает строковый накопитель
//
procedure ThiStringTableMT._work_doClearStrLst;
begin
   FList.Clear;
   _hi_CreateEvent_(_Data,@_event_onChangeStrLst);
end;

//doDeleteStrLst - Удаляет строку строкового накопителя с индексом из потока
//
procedure ThiStringTableMT._work_doDeleteStrLst;
var   ind:integer;
begin
   ind := ToIntIndex(_Data);
   if not ((ind >= 0)and(ind < FList.Count)) then exit;
   FList.Delete(ind);
   _hi_CreateEvent_(_Data,@_event_onChangeStrLst);
end;

//doLoadStrLst - Загружает список строк из файла в строковый накопитель
//
procedure ThiStringTableMT._work_doLoadStrLst;
var   fn:string;
      Strm:PStream;
begin
   fn:= ReadString(_Data,_data_StrLstFName,_prop_StrLstFName);
   if not LFileExists_MT(fn,LOAD_STRING_LIST) then Exit;
   Strm:= NewReadFileStream(fn);
   Strm.Position:= 0;
   FList.LoadFromStream(Strm, false);
   Strm.free;
   _hi_CreateEvent_(_Data,@_event_onChangeStrLst);
end;

//doSaveStrLst - Сохраняет список строк из строкового накопителя в файл
//
procedure ThiStringTableMT._work_doSaveStrLst;
var   fn:string;
      Strm:PStream;
begin
   fn:= ReadString(_Data,_data_StrLstFName,_prop_StrLstFName);
   if SFileExists_MT(fn,SAVE_STRING_LIST) then Exit;
   Strm:= NewWriteFileStream(fn);
   Strm.Position:= 0;
   FList.SaveToStream(Strm);
   Strm.free;
end;

//doAppendStrFile - Добавляет список строк строкового накопителя к файлу
//
procedure ThiStringTableMT._work_doAppendStrFile;
var   fn:string;
begin
   fn:= ReadString(_Data,_data_StrLstFName,_prop_StrLstFName);
   if SFileExists_MT(fn,APPEND_STRING_FILE) then Exit;
   FList.AppendToFile(fn);
end;

//doInsertStrLst - Вставляет в строковый накопитель строку StrList перед строкой с индексом из потока
//
procedure ThiStringTableMT._work_doInsertStrLst;
var   ind:integer;
begin
   ind := ToIntIndex(_Data);
   if not ((ind >= 0) and (ind < FList.Count)) then Exit;
   FList.Insert(ind, ReadString(_Data,_data_StrLst,''));
   _hi_CreateEvent_(_Data,@_event_onChangeStrLst);
end;

//doTextStrLst - Инициализирует строковый накопитель строками в виде: <Строка1,Строка2,...>
//
procedure ThiStringTableMT._work_doTextStrLst;
begin
   FList.Text:= ReadString(_Data,_data_StrLst,'');
   _hi_CreateEvent_(_Data,@_event_onChangeStrLst);
end;

//doAddTextStrLst - Добавляет текст из потока к строкам строкового накопителя
//
procedure ThiStringTableMT._work_doAddTextStrLst;
begin
   FList.Text:= FList.Text + ReadString(_Data,_data_StrLst,'');
   _hi_CreateEvent_(_Data,@_event_onChangeStrLst);
end;

//doSortStrLst - Сортирует строки строкового накопителя
//
procedure ThiStringTableMT._work_doSortStrLst;
begin
   FList.Sort(false);
   _hi_CreateEvent_(_Data,@_event_onChangeStrLst);
end;

//CountStrLst - Содержит количество строк в строковом накопителе
//
procedure ThiStringTableMT._var_CountStrLst;
begin
   dtInteger(_Data,FList.Count);
end;

//EndIdxStrLst - Содержит индекс последний строки в строковом накопителе
//
procedure ThiStringTableMT._var_EndIdxStrLst;
begin
  dtInteger(_Data,FList.Count - 1);
end;

//TextStrLst - Содержит список строк строкового накопителя, разделенных символами 10 и 13
//
procedure ThiStringTableMT._var_TextStrLst;
begin
   dtString(_Data,FList.Text);     
end;

//StrLstArray - Массив строк строкового накопителя
//
procedure ThiStringTableMT._var_StrLstArray;
begin
   if SLArray = nil then
      SLArray:= CreateArray(_SetStrLst, _GetStrLst, _CountStrLst, _AddStrLst);
   dtArray(_Data,SLArray);
end;

procedure ThiStringTableMT._SetStrLst;
var   ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < FList.Count)then
      FList.Items[ind]:= ToString(Val);
end;

function ThiStringTableMT._GetStrLst;
var   ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < FList.Count)then begin
      Result:= true;
      dtString(Val,FList.Items[ind]);
   end
   else Result:= false;
end;

function ThiStringTableMT._CountStrLst;
begin
   Result:= FList.Count;
end;

procedure ThiStringTableMT._AddStrLst;
begin
   FList.Add(ToString(val));
end;

//#####################################################################
//#                                                                   #
//#                           MT-методы                               #
//#                                                                   #
//#####################################################################

//doMT_Add - Добавляет запись в таблицу, используя MT-потоки,
//           где каждый элемент - это значение одного столбца
//
procedure ThiStringTableMT._work_doMT_Add;begin MT_ActionItm(_Data, ITM_ADD);end;

//doMT_Insert - Вставляет запись в таблицу, используя MT-потоки,
//              где первый элемент - (Индекс строки), перед которой будет осуществляться вставка
//
procedure ThiStringTableMT._work_doMT_Insert;begin MT_ActionItm(_Data, ITM_INSERT);end;

//doMT_Replace - Заменяет запись в таблице, используя MT-потоки,
//               где первый элемент - (Индекс строки), которая будет заменена
//
procedure ThiStringTableMT._work_doMT_Replace;begin MT_ActionItm(_Data, ITM_REPLACE);end;

//doMT_InsertCol - Вставляет столбец в таблицу, используя MT-потоки,
//                 где последовательность элементов -
//                 - (Индекс столбца)(Название=Ширина=Индекс иконки=Индекс выравнивания (0 - taLeft; 1 - taRight; 2 - taCenter))
//
procedure ThiStringTableMT._work_doMT_InsertCol;begin MT_ActionCol(_Data, ITM_INSERT);end;

//doMT_ReplaceCol - Заменяет столбец в таблице, используя MT-потоки,
//                  где последовательность элементов -
//                  - (Индекс столбца)(Название=Ширина=Индекс иконки=Индекс выравнивания (0 - taLeft; 1 - taRight; 2 - taCenter))
//
procedure ThiStringTableMT._work_doMT_ReplaceCol;begin MT_ActionCol(_Data, ITM_REPLACE);end;

//doMT_InsertIcon - Вставляет иконку в список иконок, используя MT-потоки,
//                  где последовательность элементов -
//                  - (Индекс местоположения иконки в списке)(Иконка).
//                  При параметре индекса большем длины списка иконок, иконка добавляется в конец списка
//
procedure ThiStringTableMT._work_doMT_InsertIcon;begin MT_ActionIco(_Data,ITM_INSERT);end;

//doMT_ReplaceIcon - Заменяет иконку в списке иконок, используя MT-потоки,
//                   где последовательность элементов -
//                   - (Индекс местоположения иконки в списке)(Иконка)
//
procedure ThiStringTableMT._work_doMT_ReplaceIcon;begin MT_ActionIco(_Data,ITM_REPLACE);end;

//doMT_NameCol - Устанавливает имя столбца, используя MT-потоки,
//               где последовательность элементов -
//               - (Индекс столбца)(Имя)
//
procedure ThiStringTableMT._work_doMT_NameCol;begin MT_ProperCol(_Data, COL_NAME);end;

//doMT_WidthCol - Устанавливает ширину столбца, используя MT-потоки,
//                где последовательность элементов - 
//                - (Индекс столбца)(Ширина)
//
procedure ThiStringTableMT._work_doMT_WidthCol;begin MT_ProperCol(_Data, COL_WIDTH);end;

//doMT_ImageCol - Присваивает столбцу иконку из списка иконок, используя MT-потоки,
//                где последовательность элементов - 
//                - (Индекс столбца)(Индекс иконки)
//
procedure ThiStringTableMT._work_doMT_ImageCol;begin MT_ProperCol(_Data, COL_IMAGE);end;

//doMT_AlignTxtCol - назначает выравнивание текста в столбце, используя MT-потоки,
//                   где последовательность элементов - 
//                   - (Индекс столбца)(Индекс выравнивания (0 - taLeft; 1 - taRight; 2 - taCenter))
//
procedure ThiStringTableMT._work_doMT_AlignTxtCol;begin MT_ProperCol(_Data, COL_ALIGN);end;

//doMT_EMatrix - Читает элемент(ы) матрицы строк по координатам, используя MT-потоки,
//               где последовательность элементов - 
//               - (X - индекс столбца)(Y - индекс строки).
//               При отрицательном параметре X - выдается вся строка.
//               При отрицательном параметре Y - весь столбец
//
procedure ThiStringTableMT._work_doMT_EMatrix;begin MT_EMatrix(_Data,EMATRIX);end;

//doMT_ChkEMatrix - Читает элемент(ы) матрицы строк с установленными флажками по координатам, используя MT-потоки,
//                  где последовательность элементов - 
//                  - (X - индекс столбца)(Y - индекс строки).
//                  При отрицательном параметре X - выдается вся строка.
//                  При отрицательном параметре Y - весь столбец
//
procedure ThiStringTableMT._work_doMT_ChkEMatrix;begin MT_EMatrix(_Data,CHK_EMATRIX);end;

//doMT_SelEMatrix - Читает выбранные элемент(ы) матрицы строк по координатам, используя MT-потоки,
//                  где последовательность элементов -
//                  - (X - индекс столбца)(Y - индекс строки).
//                  При отрицательном параметре X - выдается вся строка.
//                  При отрицательном параметре Y - весь столбец
//
procedure ThiStringTableMT._work_doMT_SelEMatrix;begin MT_EMatrix(_Data,SEL_EMATRIX);end;

//Универсальный MT-метод работы со строками таблицы
//
procedure ThiStringTableMT.MT_ActionItm; // проверен
var   Row,Col,iconum{,ind}:integer;
      ss:string;
      DColor:dword;
begin
  case Data.Data_type of
    data_null: exit;
  end;
  case Mode of
    ITM_REPLACE:
    begin
      Row := ReadInteger(Data, Null);
      if (Row > Control.Count - 1) and (Row < 0) then exit;
    end;
    ITM_INSERT:
    begin
      Row := ReadInteger(Data, Null);
      if (Row > Control.Count) and (Row < -1) then exit
      else if Row = -1 then
        Row := Control.Count; 
      Control.LVItemInsert(Row, '');
    end    
    else
    begin
      Row := Control.Count;
      Control.LVItemInsert(Row, '');
    end;  
  end;
  Col:= 0;
  iconum:= I_SKIP;
  DColor:= 0;
  if Assigned(Ilist) and not _IsNULL(Data) then begin
     iconum:= ReadInteger(Data,Null);
     if iconum > IList.Count - 1 then iconum:= I_SKIP;
  end;
  if FColorItems and not _IsNULL(Data) then begin
     ss:= ReadString(Data,Null) + _ColorDlm;
     DColor:= dword(Str2Int(GetTok(ss,_ColorDlm)) shl 24 + Str2int(ss));
  end;
  case Data.Data_type of
    data_null: exit;
  end;
//     ind := Control.LVCurItem; // сохранение текущей позиции
  while not _IsNULL(Data) and (Row < Control.Count) do begin
     Control.LVSetItem(Row,Col,ReadString(Data,Null),iconum,[],I_SKIP,I_SKIP,DColor);
     inc(Col);
  end;
//     Control.LVCurItem := ind; // восстановление текущей позиции
  _hi_CreateEvent_(Data,@_event_onChange);
end;

//Универсальный MT-метод работы со столбцами
//
procedure ThiStringTableMT.MT_ActionCol; // проверен
var   s:string;
      ind:integer;
begin
   if _IsNULL(Data) then exit;

   ind:=ReadInteger(Data,Null); 
   s:=ReadString(Data,Null);   
   if (Mode = ITM_INSERT) and (ind >= 0) then begin
      if (ind > CList.Count - 1) then begin
         Control.LVColAdd('',FTextAlign,FColumnWidth);
         CList.Add(InitColStr(s));
      end
      else begin
         Control.LVColInsert(ind,'',FTextAlign,FColumnWidth);
         CList.Insert(ind,InitColStr(s));
      end;
   end
   else if (Mode = ITM_REPLACE) and not ((ind < 0)or(ind > CList.Count - 1)) then
      CList.Items[ind]:= InitColStr(s)
   else exit;
   SetColumns(CList,1);
   _hi_CreateEvent_(Data,@_event_onChangeColLst);
end;

//Универсальный MT-метод работы со свойствами столбцов
//
procedure ThiStringTableMT.MT_ProperCol; // проверен
var   s,name,width,imgidx,aligntxt:string;
      ind:integer;
begin
   if _IsNULL(Data) then exit;

   ind:=ReadInteger(Data,Null);   
   s:=ReadString(Data,Null);   

   if (ind < 0) or (ind > CList.Count - 1) then exit;
   name:= Control.LVColText[ind];
   width:= int2str(Control.LVColWidth[ind]);
   imgidx:=int2str(Control.LVColImage[ind]);
   aligntxt:=int2str(ord(Control.LVColAlign[ind]));  
   if Mode = COL_NAME then name:= s
   else if Mode = COL_WIDTH then width:= s
   else if Mode = COL_IMAGE then imgidx:= s
   else if Mode = COL_ALIGN then aligntxt:= s
   else exit;   
   s:= name + '=' + width + '=' + imgidx + '=' + aligntxt;
   CList.Items[ind]:= InitColStr(s);
   SetColumns(CList,1);
   _hi_CreateEvent_(Data,@_event_onChangeColLst);   
end;

//Универсальный MT-метод работы со списком иконок
//
procedure ThiStringTableMT.MT_ActionIco; // проверен
var   idx:integer;
      di:TData;
begin
   if _IsNULL(Data) then exit;

   idx:= ReadInteger(Data,Null);
   di:= ReadData(Data,Null);
   if not _IsIcon(di) or not Assigned(Ilist) or (idx < 0) then exit;

   if (Mode = ITM_INSERT) and (idx > IList.Count - 1) then
      _AddIcon(di)
   else if (Mode = ITM_INSERT) and (idx < IList.Count) then 
      InsertIcon(di,idx)
   else if (Mode = ITM_REPLACE) and (idx < IList.Count) then
      IList.ReplaceIcon(idx, ToIcon(di).handle)
   else exit;
   SetColumns(CList,1);
   _hi_CreateEvent_(Data,@_event_onChangeImgLst);
end;

//Универсальный MT-метод работы с матрицей
//
procedure ThiStringTableMT.MT_EMatrix; // проверен
var   x,y:integer;
      d:PData;
begin
   if _IsNULL(Data) then exit;
   
   FreeData(@FData_1);
   FreeData(@FData_2);
   dtNull(FData_1);   
   dtNull(FData_2);
   x:= ReadInteger(Data,Null);
   y:= ReadInteger(Data,Null);

   if (x >= 0) and (y >= 0) then begin
      if (((Control.LVItemStateImgIdx[y] - 1) > 0) and (Mode = CHK_EMATRIX))  or
         ((lvisSelect in Control.LVItemState[y])   and (Mode  = SEL_EMATRIX)) or
         (Mode = EMATRIX) then begin
            FData_2:= MX_Get(x,y);
            AddMTData(@FData_1,@FData_2,d); 
      end;
   end
   else if (x < 0) and (y >= 0) then begin
      for x:= 0 to Control.LVColCount - 1 do
         if (((Control.LVItemStateImgIdx[y] - 1) > 0) and (Mode = CHK_EMATRIX))  or
            ((lvisSelect in Control.LVItemState[y])   and (Mode  = SEL_EMATRIX)) or
            (Mode = EMATRIX) then begin              
               FData_2:= MX_Get(x,y);
               AddMTData(@FData_1,@FData_2,d); 
         end;
   end
   else if (x >= 0) and (y < 0) then begin
      for y:= 0 to Control.Count - 1 do
         if (((Control.LVItemStateImgIdx[y] - 1) > 0) and (Mode = CHK_EMATRIX))  or
            ((lvisSelect in Control.LVItemState[y])   and (Mode  = SEL_EMATRIX)) or
            (Mode = EMATRIX) then begin
                FData_2:= MX_Get(x,y);
               AddMTData(@FData_1,@FData_2,d); 
         end;
   end;
   _hi_onEvent_(_event_onMT_EMatrix,FData_1);
   if (d <> nil) and not _IsNULL(d^) then FreeData(d);
end;

//doMT_AddCols - Добавляет столбцы в таблицу, используюя MT-потоки,
//               где формат одного элемента - 
//               - (Название_Ширина_Индекс иконки_Индекс выравнивания (0 - taLeft; 1 - taRight; 2 - taCenter))
//
procedure ThiStringTableMT._work_doMT_AddCols; // проверен
var   s:string;
begin
   if _IsNULL(_Data) then exit;

   if not FAllMT_AddCol then begin
      ReadString(_Data,Null);
      ReadString(_Data,Null);
   end;      
   while not _IsNULL(_Data) do begin
      s := ReadString(_Data,Null);
      Replace(s, _MTColDlm, '=');
      Control.LVColAdd('',FTextAlign,FColumnWidth);
      CList.Add(InitColStr(s));
   end; 
   SetColumns(CList,1);
   _hi_CreateEvent_(_Data,@_event_onChangeColLst);
end;

//doMT_CheckBox - Снимает/устанавливает флажок, используя MT-потоки,
//                где последовательность элементов - 
//                - (Индекс строки (-1 - все))(Режим (0 - скрыт; 1 - снят; 2 - установлен))
//
procedure ThiStringTableMT._work_doMT_CheckBox; // проверен
var   idx,val:integer;
begin
   if _IsNULL(_Data) then exit;

   idx := ReadInteger(_Data,Null);
   val := ReadInteger(_Data,Null);

   if (idx>=-1)and(idx<Control.Count) then Control.LVItemStateImgIdx[idx]:= val;
end;

//doMT_IconStr - Заменяет иконку в таблице на иконку из списка, используя MT-потоки,
//               где последовательность элементов - 
//               - (Индекс строки)(Индекс иконки)
//
procedure ThiStringTableMT._work_doMT_IconStr; // проверен
var   idx,newico:integer;
begin
   if _IsNULL(_Data) then exit;
   
   idx := ReadInteger(_Data,Null);
   newico := ReadInteger(_Data,Null);
   if Assigned(IList)and(idx>=0)and(idx<Control.Count)and(newico<IList.Count) then
      Control.LVItemImageIndex[idx]:= newico;
   Control.Invalidate;
end;

//doMT_IconCol - Заменяет иконку в заголовке столбца на иконку из списка, используя MT-потоки,
//               где последовательность элементов - 
//               - (Индекс столбца)(Индекс иконки). Изменения в файле не сохраняются
//
procedure ThiStringTableMT._work_doMT_IconCol; // проверен
var   idx,newico:integer;
      ta:TTextAlign;
begin
   if _IsNULL(_Data) then exit;
   
   idx := ReadInteger(_Data,Null);
   newico := ReadInteger(_Data,Null);
   ta:= Control.LVColAlign[idx];
   if Assigned(IList)and(idx>=0)and(idx<Control.LVColCount)and(newico<IList.Count)and(FImgColumn) then
      Control.LVColImage[idx]:= newico;
   Control.LVColAlign[idx]:= ta;
   Control.Invalidate;
end;

//doMT_ColorsStr - Устанавливает цвет текста строки и цвет строки, используя MT-потоки,
//                 где последовательность элементов - 
//                 - (Индекс строки)(Индекс цвета текста строки (если 0 - TextColor))(Цвет строки (если 0 - TextBkColor)).
//                 Если в качестве параметров цвета будет передана -1, параметр меняться не будет
//
procedure ThiStringTableMT._work_doMT_ColorsStr; // проверен
var   idx,idxcolortxt,colorback:integer;
begin
   if _IsNULL(_Data) then exit;

   idx := ReadInteger(_Data,Null);
   idxcolortxt := ReadInteger(_Data,Null);
   colorback := ReadInteger(_Data,Null);      

   if (idx < 0) or (idx > Control.Count - 1) or not FColorItems then exit; 
   if (idxcolortxt >= 0) and (idxcolortxt <= 15) then begin 
      Control.LVItemData[idx]:= $00FFFFFF and Control.LVItemData[idx];
      Control.LVItemData[idx]:= dword(idxcolortxt shl 24) or Control.LVItemData[idx];
   end;
   if colorback >= 0 then begin
      Control.LVItemData[idx]:= $0F000000 and Control.LVItemData[idx];
      Control.LVItemData[idx]:= Control.LVItemData[idx] or dword(colorback);
   end;
   Control.Invalidate; 
end;

//doGetColors_MT - Получает цвет текста строки и цвет строки по индексу из потока в MT-поток на onMT_GetColors
//
procedure ThiStringTableMT._work_doGetColors_MT; // проверен
var   idx:integer;
      dt,di,dj,dk:TData;
      idxcolor:byte;
begin
   idx:= ToInteger(_Data);
   dtInteger(dt,idx);
   if (idx < 0) or (idx > Control.Count - 1) and FColorItems then exit; 
   idxcolor:= ($0F000000 and Control.LVItemData[idx]) shr 24;
   dtInteger(di,idxcolor);
   if idxcolor = 0 then
      dtInteger(dj,Color2RGB(FTextColor))  
   else
      dtInteger(dj,AColor[idxcolor]);
   if $FFFFFF and Control.LVItemData[idx] = 0 then
      dtInteger(dk,Color2RGB(FTextBkColor))
   else
      dtInteger(dk,$FFFFFF and Control.LVItemData[idx]);       
   dt.ldata:= @di;
   di.ldata:= @dj;
   dj.ldata:= @dk;
   _hi_onEvent_(_event_onMT_GetColors, dt);
end;

//doGetCol_MT - Получает столбец из таблицы по индексу из потока в MT-поток на onMT_GetCol
//
procedure ThiStringTableMT._work_doGetCol_MT; // проверен
var   idx:integer;
      dt,di,dj,dk,dl:TData;
begin
   idx:= ToInteger(_Data);
   if (idx < 0) or (idx > Control.LVColCount - 1) then exit;
   dtInteger(dt,idx);
   dtString(di,Control.LVColText[idx]);
   dtInteger(dj,Control.LVColWidth[idx]);
   dtInteger(dk,Control.LVColImage[idx]);
   dtInteger(dl,ord(Control.LVColAlign[idx]));
   dt.ldata:= @di;
   di.ldata:= @dj;
   dj.ldata:= @dk;
   dk.ldata:= @dl;
   _hi_onEvent_(_event_onMT_GetCol, dt);
end;

//-----------------   MT-извлечение отдельной иконки   -------------------
//
//doMT_LoadExtIcon - Извлекает отдельную иконку из файлов ресурсов (*.exe,*.dll,*.ocx,*.icl),
//                   где последовательность элементов -
//                   - (Имя файла ресурса)(Номер извлекаемой иконки)(Размер иконки)(Иконка замены)
//
procedure ThiStringTableMT._work_doMT_LoadExtIcon; // проверен
var   ico: PIcon;
      fn:string;
      dt,di:TData;
      idx:word;
      bmp:PBitmap;
      Licon,sIcon:hIcon;
      iSize:integer;
      Flags: Integer;
      SFI: TShFileInfo;      
begin
   if _IsNULL(_Data) then exit;

   bmp :=nil;
   fn := ReadString(_Data,Null);
   idx := ReadInteger(_Data,Null);
   iSize :=  ReadInteger(_Data,Null);
   di := ReadData(_Data,Null);

   if iSize = 0 then iSize := FImgSize;
   
   if not LFileExists_MT(fn,LOAD_EXTICON) then Exit;
   ico:= NewIcon;
 
   ExtractIconEx(PChar(fn),idx,Licon,sIcon,1);
   if iSize < 24 then
      ico.handle:= sIcon
    else
      ico.handle:= LIcon;

   if ico.Handle <> 0 then
      dtIcon(dt,ico)
   else if (_IsIcon(di)) and (ico.Handle = 0) then begin
      ico.free;
      ico:= NewIcon;
      dtData(dt,di);
      ico{$ifndef F_P}^{$endif} := ToIcon(dt){$ifndef F_P}^{$endif} ;
   end else begin
      if iSize < 24 then  
         Flags:= SHGFI_ICON or SHGFI_ICONLOCATION or SHGFI_SMALLICON or SHGFI_TYPENAME or SHGFI_SYSICONINDEX
      else
         Flags:= SHGFI_ICON or SHGFI_ICONLOCATION or SHGFI_LARGEICON or SHGFI_TYPENAME or SHGFI_SYSICONINDEX;
         ShGetFileInfo(PChar(fn), 0, SFI, SizeOf(SFI), Flags);
         ico.handle:= SFI.hIcon; 
         if ico.Handle <> 0 then dtIcon(dt,ico)
   end;
   if FIconToBmp then begin
      bmp:= NewDIBBitmap(Ico.Size,Ico.Size,pf32bit);
      bmp.Handle:= Ico.Convert2Bitmap(FTransparent);
      dtBitmap(dt,bmp);
   end;
   _hi_onEvent_(_event_onExtIcon, dt);
   bmp.free;
   ico.free;
end;

//--------------------   MT-поиск вхождений текста   ---------------------
//
//doMT_FindText - Ищет вхождения текста из потока в таблице (метод не чувствителен к регистру),
//                где последовательность элементов -
//                - (Текст поиска)(Стартовая строка)(Стартовый столбец)(Текст замещения для ReplaceFind=True).
//                Поиск ведется слева направо и сверху вниз до ближайшего вхождения
//
procedure ThiStringTableMT._work_doMT_FindText; // проверен
var sstr, str, strrepl, S2, S3:string;
    Row,Col,FPos:integer;
    dp,dt,ds:TData;
    d:PData;

begin
   if _IsNULL(_Data) then exit;

   sstr := ReadString(_Data,Null);
   str := sstr + #0; 
   Delete(str, length(str), 1);
   CharLower(PChar(str));
   
   Row := ReadInteger(_Data,Null);
   Col := ReadInteger(_Data,Null); 

   if FFindReplace then
      strrepl := ReadString(_Data,Null)
   else 
      strrepl :='';
   FStrReplace := strrepl; 
   FStrFind := str;

   FreeData(@FData_1);
   FreeData(@FData_2);
   dtNull(FData_1);   
   dtNull(FData_2);
TRY
   if (Col = -1) or (Row = -1) or (str = '') then begin
      Row:= -1;
      Col:= -1;
      S3:= '';
      exit;
   end;   
   repeat
      repeat
         FPos := 1;
         S3:= Control.LVItems[Row,Col];
         Delete(S2, length(S2), 1);
         S2 := S3 + #0;
         CharLower(PChar(S2));
         FPos := PosEx(str,S2,FPos);
         if FPos <> 0 then begin
            if FSelectFind then Control.LVCurItem:= Row;
            while FPos <> 0 do begin 
               if FFindReplace then begin
                  Delete(S3,FPos,Length(str));
                  if strrepl <> '' then Insert(strrepl,S3,FPos);
                  Control.LVItems[Row,Col] := S3;
                  S2 := S3 + #0;
                  Delete(S2, length(S2), 1);
                  CharLower(PChar(S2));
               end;
               if (not FFindReplace) or (FFindReplace and (strrepl <> '')) then begin
                  dtInteger(FData_2,FPos);            
                  AddMTData(@FData_1,@FData_2,d);
               end;
               if not FFindReplace then
                  inc(FPos,Length(str))
               else if FFindReplace and (strrepl <> '') then
                  inc(FPos,Length(strrepl));
               FPos := PosEx(str,S2,FPos);
            end;
            exit;
         end;
         inc(Col);
      until Col = Control.LVColCount;   
      inc(Row);
      Col:= 0;
   until Row = Control.Count;   
   Row:= -1;
   Col:= -1;
   S3:= '';
FINALLY
   dtInteger(dp,Row);
   dtInteger(dt,Col);
   FCol := Col;
   FRow := Row;
   dtString(ds,S3);
   dp.ldata:= @dt;
   dt.ldata:= @ds;
   ds.ldata:= @FData_1;
   _hi_onEvent_(_event_onMT_FindText,dp);
   if (d <> nil) and not _IsNULL(FData_2) then FreeData(d);
END;
end;

//-------------   MT-поиск следующего вхождений текста   --------------
//
//doMT_FindNext - Обрабаытывает и передает параметры методу doMT_FindText
//                для поиска(замены) следующего вхождения текста
//
procedure ThiStringTableMT._work_doMT_FindNext; // проверен
var   dp,dt,ds:TData;

begin
   dtNull(_Data);
   if (FRow <> -1) or (FCol <> -1) then begin
      inc(FCol);
      if FCol = CList.Count then begin
         FCol := 0;
         inc(FRow);
         if FRow = Control.Count then begin
            FRow := -1;
            FCol := -1;
            FStrFind := '';
         end;
      end;
   end;
   dtString(_Data,FStrFind);
   dtInteger(dt,FRow);
   dtInteger(ds,FCol);
   _Data.ldata:= @dt;
   dt.ldata:= @ds;
   if FFindReplace then begin
      dtString(dp,FStrReplace);
      ds.ldata:= @dp;      
   end;
   _work_doMT_FindText(_Data,0);
end;
//-----------------   Автоустановка ширины столбцов   -----------------
//
//doAutoColWidth - Автоматически подстраивает ширину столбца по индексу из потока
//                 (все столбцы при -1) по данным из строк
//
procedure ThiStringTableMT._work_doAutoColWidth; // проверен
var   FCol,Col,Row:integer;
      _Length, TempLength:integer;
      dt,di:TData;
begin
  FCol := ToInteger(_Data);
  if (Control.LVColCount <= 0) or (Control.Count <= 0) or (FCol > Control.LVColCount - 1) then exit;
  Control.BeginUpdate;
  if FCol < 0 then
  begin
    FCol := Control.LVColCount;
    Col:= 0;
  end
  else
  begin
    Col := FCol;
    inc(FCol);
  end;
  repeat
    Control.LVColWidth[Col] := LVSCW_AUTOSIZE;
    if (Control.LVStyle = lvsDetail) or (Control.LVStyle = lvsDetailNoHeader) then
      _Length:= Control.LVColWidth[Col] + 2 * Control.Canvas.TextExtent('M').cx
    else
    begin   
      Row:= 0;
      _Length:= 0;
      repeat
         TempLength:= (Control.Canvas.TextWidth(Control.LVItems[Row,Col])) + 2 * Control.Canvas.TextExtent('M').cx;
         if Col = 0 then begin
            if FCheckBoxes then TempLength:= TempLength + GetSystemMetrics(SM_CXICON);
            if Assigned(IList) then TempLength:= TempLength + FImgSize;              
         end;
         _Length:= max(_Length,TempLength);
         inc(Row);                                                     
      until Row = Control.Count;
    end;
    _Length:= min(_Length, FMaxColWidth);
    _Length:= max(_Length, FMinColWidth);
    dtInteger(dt,Col);
    dtInteger(di,_Length);
    dt.ldata:= @di;
    MT_ProperCol(dt, COL_WIDTH);
    inc(Col);
  until Col = FCol;
  Control.EndUpDate;
end;

//-----------------------   MT-переменные   ---------------------------
//
//GenColors_MT - Содержит MT-элементы главных цветов таблицы,
//               где последовательность элементов -
//               - (BkColor)(TextColor)(TextBkColor)(TranspColor)(Gradient)(Shadow)
//
procedure ThiStringTableMT._var_GenColors_MT; // проверен
var   da,db,dc,dd,de,ds:TData;
begin
   FreeData(@FData);
   dtNull(FData);
   dtInteger(da,Color2RGB(FBkColor));
   dtInteger(db,Color2RGB(FTextColor));
   dtInteger(dc,Color2RGB(FTextBkColor));
   dtInteger(dd,Color2RGB(FTransparent));
   dtInteger(de,Color2RGB(FGradientColor));   
   dtInteger(ds,Color2RGB(FShadowColor));
   da.ldata := @db;
   db.ldata := @dc;
   dc.ldata := @dd;
   dd.ldata := @de;
   de.ldata := @ds;
   CopyData(@FData,@da);
   _Data := FData;
end;
//
//AllSelect_MT - Содержит MT-элементы индексов выделенных пунктов
//
procedure ThiStringTableMT._var_AllSelect_MT; // проверен
var   i,j:integer;
      d:PData;
begin
   FreeData(@FData);
   FreeData(@FData_2);
   dtNull(FData);
   dtNull(FData_2);
   i:= Control.LVCurItem;
   if Control.LVSelCount > 0 then begin
      repeat
         dtInteger(FData_2,i);
         AddMTData(@FData,@FData_2,d); 
         j:= Control.LVNextSelected(i);
         i:= j;
      until j < 0;
   end;
   _Data := FData;
end;
//
//AllCheck_MT - Содержит MT-элементы индексов пунктов с установленными флажками
//
procedure ThiStringTableMT._var_AllCheck_MT; // проверен
var   i,j: word;
      d:PData;
begin
   FreeData(@FData);
   FreeData(@FData_2);
   dtNull(FData);
   dtNull(FData_2);
   if Control.Count > 0 then begin
      for i:=0 to Control.Count - 1 do begin
         j:= Control.LVItemStateImgIdx[i];
         if j > 1 then 
            dtInteger(FData_2,i)
         else
            dtNull(FData_2); 
         AddMTData(@FData,@FData_2,d);
      end;
   end;
   _Data := FData;
end;

function ThiStringTableMT.FullSaveColumns;
var
  i: integer;
begin
  Result := '';
  if Control.LVColCount > 0 then
  begin
    for i := 0 to Control.LVColCount - 1 do
    begin
      Result := Result + Control.LVColText[i]  + '=' + 
                int2str(Control.LVColWidth[i]) + '=' +
                int2str(Control.LVColImage[i]) + '=' +
                int2str(ord(Control.LVColAlign[i])) + _Dlm;
    end;
    deleteTail(Result, 1);
  end;
end;

procedure ThiStringTableMT.FullLoadColumns; 
var
  s: string;
begin
  FullClear(CLEAR_COLUMNS);
  s := StrCol;
  Replace(s, _Dlm, #13#10);
  CList.SetText(s, false);
  SetColumns(CList, 0);
end;

function ThiStringTableMT.FullSaveTable;
var
  i, j: integer;
  s: string;
begin
  Result := '';
  if (Control.Count <= 0) or (Control.LVColCount <= 0) then exit;
  for i := 0 to Control.Count - 1 do
  begin
    s := int2str(Control.LVItemStateImgIdx[i] - 1) + _CellDlm +
         int2str(Control.LVItemImageIndex[i])      + _CellDlm + 
         PakColor2Str(Control.LVItemData[i])       + _CellDlm;   
    for j := 0 to Control.LVColCount - 1 do
      s := s + Control.LVItems[i,j] + _CellDlm;
    deleteTail(s, 1);
    Result := Result + s + _Dlm;
  end;
  deleteTail(Result, 1);  
end;

procedure ThiStringTableMT.FullLoadTable;
var
  i, chk: integer;
  d: PData;
  dt, dp: TData;
  st: string;
  SList: PStrList;  
begin
  FullClear(CLEAR_TABLE);
  SList := NewStrList;
  dtNull(dt);
TRY    
  Replace(StrTbl, _Dlm, #13#10);
  SList.SetText(StrTbl, false);
  if SList.Count = 0 then exit; 
  for i := 0 to SList.Count - 1 do
  begin 
    d := @dt;
    St := SList.Items[i] + _CellDlm; 
    chk := str2int(GetTok(St, _CellDlm)) + 1; 
    while St <> '' do
    begin   
      dtString(d^, GetTok(St, _CellDlm));
      if St <> '' then
      begin
        new(d.ldata);
        d := d.ldata;
      end;    
    end;
    dp := dt;
    MT_ActionItm(dp, ITM_ADD);
    freedata(@dt);
    Control.LVItemStateImgIdx[i] := chk;
  end;      
FINALLY
  SList.free;
END;    
end;

procedure ThiStringTableMT.FullClear;  
begin
  Control.BeginUpdate;
  if (Mode = CLEAR_FULL) or (Mode = CLEAR_TABLE) then Control.Clear;
  if (Mode = CLEAR_FULL) or (Mode = CLEAR_COLUMNS) then
  begin
    repeat
      Control.LVColDelete(Control.LVColCount-1);
    until Control.LVColCount <= 0;
    CList.Clear;
  end;
  Control.EndUpDate;
end;

//
//----------------------------   Конец   ------------------------------
end.