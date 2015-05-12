unit hiMTStrTbl; { MT-потоковая таблица строк }

interface

uses Windows, Messages, Share, Win, Debug, ListEdit, Kol,
     hiIconsManager, hiMST_DrawManager;

const
  AColor: array [0..15] of TColor = (clBlack, clMaroon, clGreen, clOlive,
                                     clNavy, clPurple, clTeal, clGray,
                                     clSilver, clRed, clLime, clYellow,
                                     clBlue, clFuchsia, clAqua, clWhite);

const
  ITM_ADD     =  -3;
  ITM_INSERT  =  -4;
  ITM_REPLACE =  -5;

  COL_NAME    =  -9;
  COL_WIDTH   = -10;
  COL_IMAGE   = -11;
  COL_ALIGN   = -12;

type
  TIMSTControl = record
    ctrlpoint:      function: pointer of object;
    actionitm:      procedure(var Data: TData; Mode: integer) of object;
    actioncol:      procedure(var Data: TData; Mode: integer) of object;    
    propercol:      procedure(var Data: TData; Mode: integer) of object;
    textalign:      function(idx: integer): TTextAlign of object;    
    smiconlist:     function: PImageList of object;
    lgiconlist:     function: PImageList of object;    
    colcount:       function: integer of object;
    imgsize:        function: byte of object;
    coloritems:     function: boolean of object;
    scoloritems:    procedure(val: boolean) of object;
    textbkcolor:    function: TColor of object;
    textcolor:      function: TColor of object;
    bkcolor:        function: TColor of object;
    shadowcolor:    function: TColor of object;
    iconcolcolor:   function: TColor of object;
    addcols:        procedure(var _Data: TData) of object;
    stextbkcolor:   procedure(Value: TColor) of object;
    stextcolor:     procedure(Value: TColor) of object;
    sbkcolor:       procedure(Value: TColor) of object;
    sshadowcolor:   procedure(Value: TColor) of object;
    siconcolcolor:  procedure(Value: TColor) of object;
    deletecol:      procedure(var _Data: TData) of object;
    clistclear:     procedure of object;
    clistcount:     function: integer of object;
    clistitems:     function(ind: integer): string of object;
    style:          function: TListViewStyle of object;
    setfocus:       procedure(var _Data: TData; Index: word) of object;
    getnewcuridx:   function: integer of object;
    setnewcuridx:   procedure(value: integer) of object;
    getfredaction:  function: boolean of object;
    getfctl3d:      function: boolean of object;
    matrix:         procedure(var _Data: TData) of object;
    mxget:          function(x, y: integer): TData of object;
    mxset:          procedure(x, y: integer; var Val: TData) of object;
    detachwndproc:  procedure of object;
    getstring:      function(index: integer): TData of object;
    columnarray:    procedure(var _Data: TData) of object;
    nidxicon:       function: integer of object;
    ncolorrow:      function: integer of object;
    codepageget:    function(str: string): string of object;    
  end;
  IMSTControl = ^TIMSTControl;

type
  ThiMTStrTbl = class(THIWin)
  protected
    procedure _OnDestroy(Sender:PObj); override;

  private
    mtstc: TIMSTControl; 

    FData_1: TData;

    CBvalue: integer;
    GMouse: boolean;
    FLargIconsManager,
    FSmallIconsManager,
    FStateIconsManager: IIconsManager;

    Sel,
    FNIdxIcon,
    FNColorRow,
    NewCurIdx,
    NewLine,
    FColumnWidth: integer;

    LgIList,
    SmIList,
    StIList: PImageList;

    _ColDlm: Char;
    
    FColorItems,
    FGrid,
    FTrackSelect,
    FMultiSelect,
    FImgColumn,
    FRedaction,
    FEnableOnClick,
    FChangeWidth,    
    FInfoTip: boolean;    

    FImgSize,
    FColumnClick: byte;

    FTextColor,
    FTextBkColor,
    FBkColor,
    FIconColColor: TColor;

    CList: PStrList;
    Obj: PMatrix;
    CLArray: PArray;
    FStyle: TListViewStyle;
    FTextAlign: TTextAlign;

    function  ctrlpoint: pointer;
    function  smiconlist: PImageList;
    function  lgiconlist: PImageList;
    function  textalign(idx: integer): TTextAlign;
    function  colcount: integer;
    function  imgsize: byte;    
    function  coloritems: boolean;
    procedure scoloritems(val: boolean);    
    function  textbkcolor: TColor;
    function  textcolor: TColor;
    function  bkcolor: TColor;
    function  iconcolcolor: TColor;
    procedure addcols(var _Data: TData);
    procedure stextcolor(Value: TColor);
    procedure stextbkcolor(Value: TColor);
    procedure sbkcolor(Value: TColor);
    procedure siconcolcolor(Value: TColor);
    procedure deletecol(var _Data: TData);
    procedure clistclear;
    function  clistcount: integer;
    function  clistitems(ind: integer): string;
    function  style: TListViewStyle;
    function  getnewcuridx: integer;
    procedure setnewcuridx(value: integer);
    function  getfredaction: boolean;
    function  getfctl3d: boolean;
    procedure detachwndproc;    
    procedure matrix(var _Data: TData);
    procedure columnarray(var _Data: TData);
    function  nidxicon: integer;
    function  ncolorrow: integer;

    procedure ColDlm(Val: string);    
     
    procedure _OnClick(Obj:PObj);
    procedure _OnMouseDown(Sender: PControl; var Mouse: TMouseEventData); override;
    procedure _OnMouseUp(Sender: PControl; var Mouse: TMouseEventData); override;         
    procedure _onDblClick(Sender: PControl; var Mouse: TMouseEventData); override;

    procedure SetColumns(const ListCol: PStrList; Mode:integer);
    procedure _OnColumnClick(Sender: PControl; Idx: Integer);
    procedure _OnBeforeLineChange(Sender: PControl; Idx: Integer);
    procedure _OnLineChange(Sender: PControl; Idx: Integer);
    function  _OnLVCustomDraw(Sender: PControl; DC: HDC; Stage: Cardinal;
                              ItemIdx, SubItemIdx: Integer; const Rect: TRect;
                              ItemState: TDrawState;
                              var TextColor, BackColor: TColor): Cardinal;

    procedure MX_Set(x, y: integer; var Val: TData);
    function  MX_Get(x, y: integer): TData;
    function  _mRows: integer;
    function  _mCols: integer;

    function  InitColStr(var Val: string):string;
    procedure _SetCol(var Item: TData; var Val: TData);
    function  _GetCol(Var Item: TData; var Val: TData):boolean;
    procedure _AddCol(var Val: TData);
    function  _CountCol: integer;
    procedure SetTextColLst(const Value: string);
    function  Get(index: integer): TData;
    function  CodePageGet(str: string): string;

    procedure SetOption(OSet: boolean; Option: TListViewOption); 

    procedure _OnSelState(Sender: PControl; IdxFrom, IdxTo: Integer; OldState, NewState: cardinal);

    procedure ActionItm(var Data: TData; Mode: integer);
    procedure ActionCol(var Data: TData; Mode: integer);
    procedure ProperCol(var Data: TData; Mode: integer);

    procedure SetLargIconsManager(value: IIconsManager);
    procedure SetSmallIconsManager(value: IIconsManager);
    procedure SetStateIconsManager(value: IIconsManager);
    
    function  AssignIList: boolean;

  public
    _data_CodePageSet,
    _data_CodePageGet,
    _data_Row,
    _data_Col,
    _event_onSelect,
    _event_onClientRect,
    _event_onClick,
    _event_onColumnClick,
    _event_onCheck,
    _event_onChangeWidth,
    _event_onLineChange,
    _event_onBeforeLineChange: THI_Event;

    _prop_Scroll,
    _prop_FlatScroll,
    _prop_CheckBoxes,
    _prop_RowSelect,
    _prop_VirtualTab,
    _prop_HeaderDragDrop: boolean;

    _prop_Row,
    _prop_Col: integer;

    _prop_DrawManager: IDrawManager;
    _prop_DoubleBuffered: boolean;    

    property _prop_LargIconsManager:IIconsManager   read FLargIconsManager  write SetLargIconsManager;
    property _prop_SmallIconsManager:IIconsManager  read FSmallIconsManager write SetSmallIconsManager;
    property _prop_StateIconsManager:IIconsManager  read FStateIconsManager write SetStateIconsManager;

    property _prop_NIdxIcon: integer        write FNIdxIcon;
    property _prop_NColorRow: integer       write FNColorRow;

    property _prop_ColorItems: boolean      write FColorItems;
    property _prop_InfoTip: boolean         write FInfoTip;
    property _prop_EnableOnClick: boolean   write FEnableOnClick;
    property _prop_ColumnWidth: integer     write FColumnWidth;
    property _prop_Redaction: boolean       write FRedaction;
    property _prop_ImgColumn: boolean       write FImgColumn;
    property _prop_ColumnClick: byte        write FColumnClick;
    property _prop_TextAlign: TTextAlign    write FTextAlign;
    property _prop_Style: TListViewStyle    write FStyle;
    property _prop_Grid: boolean            write FGrid;
    property _prop_TrackSelect: boolean     write FTrackSelect;
    property _prop_MultiSelect: boolean     write FMultiSelect;
    property _prop_ColDelimiter: string     write ColDlm;
    property _prop_Columns: string          write SetTextColLst;
    property _prop_ChangeWidth: boolean     write FChangeWidth;    

    procedure Init; override;

    function getInterfaceMSTControl: IMSTControl;

    procedure _work_doStyle(var _Data: TData; Index: word);
    procedure _work_doGrid(var _Data: TData; Index: word);
    procedure _work_doInfoTip(var _Data: TData; Index: word);
    procedure _work_doTrackSelect(var _Data: TData; Index: word);
    procedure _work_doMultiSelect(var _Data: TData; Index: word);
    procedure _work_doEnableOnClick(var _Data: TData; Index: word);
    procedure _work_doColor(var _Data: TData; Index: word);
    procedure _work_doClientRect(var _Data: TData; Index: word);
    procedure _work_doChangeWidth(var _Data: TData; Index: word);    

    procedure _work_doNIdxIcon(var _Data: TData; Index: word);
    procedure _work_doNColorRow(var _Data: TData; Index: word);

    procedure _var_MTStrTbl(var _Data: TData; Index: word);
    procedure _var_TopItem(var _Data: TData; Index: word);
    procedure _var_PerPage(var _Data: TData; Index: word);
    procedure _var_ItemAtPos(var _Data: TData; Index: word);
    procedure _var_Count(var _Data: TData; Index: word);
    procedure _var_Index(var _Data: TData; Index: word);
    procedure _var_Select(var _Data: TData; Index: word);
    procedure _var_CountCol(var _Data: TData; Index: word);
    procedure _var_EndIdx(var _Data: TData; Index: word);     
    procedure _var_EndIdxCol(var _Data: TData; Index: word); 
  end;

implementation

function ThiMTStrTbl.AssignIList;
begin
  Result := (Assigned(SmIlist) and (Control.LVStyle <> lvsIcon)) or
            (Assigned(LgIlist) and (Control.LVStyle = lvsIcon));
end;

function ThiMTStrTbl.getInterfaceMSTControl;
begin
  Result := @mtstc;
end;

function ThiMTStrTbl.ctrlpoint;
begin
  Result := Control;
end;

function ThiMTStrTbl.textalign;
begin
  Result := Control.LVColAlign[idx];
end;

function ThiMTStrTbl.smiconlist;
begin
   if Assigned(SmIList) then
     Result := SmIList
   else
     Result := nil;
end;

function ThiMTStrTbl.lgiconlist;
begin
   if Assigned(LgIList) then
     Result := LgIList
   else
     Result := nil;
end;

function ThiMTStrTbl.colcount;
begin
  Result := CList.Count;
end;

function ThiMTStrTbl.clistitems;
begin
  Result := Clist.Items[ind];
end;

function ThiMTStrTbl.imgsize;
begin
  Result := FImgSize;
end;

function ThiMTStrTbl.coloritems;
begin
  Result := FColorItems;
end;

procedure ThiMTStrTbl.scoloritems;
begin
  FColorItems := val;
end;

function ThiMTStrTbl.textcolor;
begin
  Result := FTextColor;
end;

function ThiMTStrTbl.textbkcolor;
begin
  Result := FTextBkColor;
end;

function ThiMTStrTbl.bkcolor;
begin
  Result := FBkColor;
end;

function ThiMTStrTbl.iconcolcolor;
begin
  Result := FIconColColor;
end;

function ThiMTStrTbl.style;
begin
  Result := FStyle;
end;

function ThiMTStrTbl.getnewcuridx;
begin
  Result := NewCurIdx;
end;

procedure ThiMTStrTbl.setnewcuridx;
begin
   NewCurIdx := Value;
end;

function ThiMTStrTbl.getfredaction;
begin
  Result := FRedaction;
end;

procedure ThiMTStrTbl.siconcolcolor;
begin
  FIconColColor := Value;
  if Assigned(SmIList) then
    SmIList.BkColor := FIconColColor;
  SetColumns(CList, 1);      
end;

function ThiMTStrTbl.clistcount;
begin
  Result := CList.Count;
end;

function ThiMTStrTbl.getfctl3d;
begin
  Result := not boolean(_prop_CTL3D);
end;

procedure ThiMTStrTbl.addcols; // проверен
var
  s: string;
  ColIdx: integer;
begin
  case _Data.Data_type of
    data_null: exit;
  end;

  ColIdx := 0;

  while not _IsNULL(_Data) do
  begin
    s := ReadString(_Data, Null);
    if ((ColIdx <> FNColorRow) or not FColorItems) and ((ColIdx <> FNIdxIcon) or not AssignIList) then
    begin
      Control.LVColAdd('', FTextAlign, FColumnWidth);
      CList.Add(InitColStr(s));
    end;  
    Inc(ColIdx);
  end;
  SetColumns(CList, 1);
end;

procedure ThiMTStrTbl.clistclear;
begin
  Clist.Clear;
end;

function ThiMTStrTbl.nidxicon;
begin
  Result := FNIdxIcon;
end;

function ThiMTStrTbl.ncolorrow;
begin
  Result := FNColorRow;
end;

procedure ThiMTStrTbl._onDestroy;
var
  Item: integer;
begin
  for Item := 0 to Control.Count - 1 do
  begin
    if Assigned(PData(Control.LVItemData[Item])) then
    begin
      FreeData(PData(Control.LVItemData[Item]));
      Dispose(PData(Control.LVItemData[Item]));
    end;
  end;
  CList.free;
  if Obj <> nil then
    Dispose(Obj);
  if CLArray <> nil then
    Dispose(CLArray);
  FreeData(@FData_1);  
  inherited;
end;

function ThiMTStrTbl.CodePageGet;
var
  ds: TData;
begin
  if Assigned(_data_CodePageGet.Event) then
  begin
    dtString(ds, str);
    _ReadData(ds, _data_CodePageGet);
    Result := ToString(ds);
  end  
  else
    Result := str;
end;

procedure ThiMTStrTbl._OnColumnClick;
begin
  case FColumnClick of
    0: _hi_OnEvent(_event_onColumnClick, Control.LVColText[Idx]);
    1: _hi_OnEvent(_event_onColumnClick, Idx);
  end;
end;

procedure ThiMTStrTbl._OnBeforeLineChange;
var
  dt: TData;
begin
  if _prop_CheckBoxes then CBvalue := Control.LVItemStateImgIdx[idx]; //сохраним
  dt := Get(Idx); 
  _hi_OnEvent_(_event_onBeforeLineChange, dt);
end;

procedure ThiMTStrTbl._OnLineChange;
var
  dt: TData;
begin
  if _prop_CheckBoxes then Control.LVItemStateImgIdx[idx] := CBvalue; //восстановим
  dt := Get(Idx);
  _hi_OnEvent_(_event_onLineChange, dt);
end;

//---------------------   Селекторный обработчик   -----------------------

procedure ThiMTStrTbl._OnClick;
begin
   if (Control.LVCurItem <> -1)and (sel = Control.LVCurItem) and FEnableOnClick then
     _hi_OnEvent(_event_onClick,Control.LVCurItem)
end;

procedure ThiMTStrTbl._OnMouseDown;
begin
   sel := Control.LVCurItem;
   GMouse := true;
   inherited;
end;

procedure ThiMTStrTbl._OnMouseUp;
begin
   GMouse := false;
   inherited;
end;

procedure ThiMTStrTbl._onDblClick;
begin
   GMouse := true;
   inherited;
end;

procedure ThiMTStrTbl._OnSelState;
var
  dt, Data: TData;
begin
  dtNull(Data);
TRY
  if (Newstate = 3) or (Newstate = 1) then
  begin
    if  FEnableOnClick then _hi_OnEvent(_event_onClick, IdxFrom);
    _hi_OnEvent(_event_onSelect, IdxFrom);
    exit;
  end;
  if GMouse and (OldState = 0) then
  begin 
    Sender.LVItemStateImgIdx[IdxFrom] := 0;
    exit;    
  end;

  if (Newstate = $3000) and ((OldState = $1000) or (OldState = $2000)) then
    dtInteger(dt, 2)
  else if (Newstate = $2000) and ((OldState = $1000) or (OldState = $3000)) then
    dtInteger(dt, 1)
  else if (Newstate = $1000) and ((OldState = $2000) or (OldState = $3000)) then
    dtInteger(dt, 0)
  else
    exit;         
  dtInteger(Data, IdxFrom);
  Data.ldata := @dt;
  _hi_onEvent_(_event_onCheck, Data);
FINALLY
  GMouse := false;
END;  
end;

//---------------------   Графический обработчик   -----------------------

function ThiMTStrTbl._OnLVCustomDraw;
var
  Color, bkColor: TColor;
  idxColor: Cardinal;
  FData: TData;
begin
  Result := CDRF_DODEFAULT;
  if (Stage = CDDS_PREPAINT) then
    Result := CDRF_NOTIFYITEMDRAW
  else if (Stage = CDDS_ITEMPREPAINT) then
  begin 
TRY
    BackColor := Color2RGB(FTextBkColor);
    TextColor := Color2RGB(FTextColor);
    if Assigned(PData(Sender.LVItemData[ItemIdx])) and FColorItems and (Sender.Count <> 0) then
      if (Sender.LVItemData[ItemIdx] > 65535) then
      begin
        CopyData(@FData, PData(Sender.LVItemData[ItemIdx]));
        Color := ToInteger(FData);
        bkColor := $00FFFFFF and Color;
        idxColor := ($0F000000 and Color) shr 24;
        if bkColor <> 0 then
          BackColor := bkColor;
        if idxColor <> 0 then
          TextColor := AColor[idxColor];
        FreeData(@FData);  
      end;
    Result := CDRF_NOTIFYSUBITEMDRAW OR CDRF_NOTIFYPOSTPAINT;
EXCEPT
END;
  end
  else if ((Stage = CDDS_SUBITEM OR CDDS_ITEMPREPAINT) or (Stage = CDDS_ITEMPOSTPAINT))
          and ((Sender.LVStyle = lvsDetail) or (Sender.LVStyle = lvsDetailNoHeader))
          and Assigned(_prop_DrawManager) then
    Result := _prop_DrawManager.customdraw(Sender, DC, Stage, ItemIdx, SubItemIdx, Rect, ItemState,
                                           TextColor, BackColor, NewCurIdx, SmIList, StIList);
end;
//------------------- Конец графического обработчика ---------------------

//------------------------------------------------------------------------

procedure ThiMTStrTbl.ColDlm;
begin
  if Val = '' then
    _ColDlm := '='
  else
    _ColDlm := Val[1];
end;
//==============================================================================

function WndProcTabGrid(Sender: PControl; var Msg: TMsg; var Rslt: Integer): Boolean;
type
  TMouseDownPt = packed record
    X: Word;
    Y: Word;
  end;
var
  R, ARect: TRect;
  Pt: TMouseDownPt; 
  HTI: TLVHitTestInfo;
  fClass: ThiMTStrTbl;
  l: TListViewOptions;

  procedure EscCell(NewLine: integer);
  begin
    R := Sender.LVItemRect(NewLine, lvipBounds);
    ARect := Sender.LVItemRect(NewLine, lvipLabel);
    R.Left := ARect.Left;
    InvalidateRect(Sender.Handle, @R, false);
  end;
  
begin
  Result := FALSE;
  l:= Sender.LVOptions;
  fClass := ThiMTStrTbl(Sender.Tag);
  with fClass do
  begin
    case Msg.message of
      WM_RBUTTONDOWN, WM_LBUTTONDOWN:
      begin
        Pt:= TMouseDownPt(Msg.lParam);
        HTI.pt.x := Pt.X;
        HTI.pt.y := Pt.Y;
        Sender.Perform(LVM_SUBITEMHITTEST, 0, Integer(@HTI));
        if HTI.flags <> LVHT_ONITEMSTATEICON then
        begin 
          NewLine := HTI.iItem;
          NewCurIdx := HTI.iSubItem;             
        end;
        EscCell(NewLine);
      end;
      WM_KEYDOWN:
      begin
        Case Msg.WParam of
          VK_LEFT, VK_RIGHT:
          begin
            if (lvoRowSelect in l) then
            begin
              NewCurIdx := NewCurIdx + Msg.wParam - $26;
              if NewCurIdx >= Sender.LVColCount then
                NewCurIdx := Sender.LVColCount - 1
              else
                if NewCurIdx < 0 then NewCurIdx := 0;
              EscCell(NewLine);
            end;
          end;
          VK_UP, VK_DOWN:
          begin
            NewLine := NewLine + Msg.wParam - $27;                  
            if NewLine >= Sender.Count then
              NewLine := Sender.Count - 1
            else
              if NewLine < 0 then
                NewLine := 0;
            EscCell(NewLine);
          end;
        end;
      end;
    end;
  end;
end;

//==============================================================================

function WndHDR(Sender: PControl; var Msg: TMsg; var Rslt: Integer): Boolean;
const
  HDN_FIRST            = -300;           { Header }
  HDN_ITEMCHANGINGA    = HDN_FIRST - 0;
  HDN_ITEMCHANGEDA     = HDN_FIRST - 1;
  HDN_DIVIDERDBLCLICKA = HDN_FIRST - 5;
  HDN_BEGINTRACKA      = HDN_FIRST - 6;
  HDN_ENDTRACKA        = HDN_FIRST - 7;  
  HDN_ITEMCHANGINGW    = HDN_FIRST - 20;
  HDN_ITEMCHANGEDW     = HDN_FIRST - 21;
  HDN_DIVIDERDBLCLICKW = HDN_FIRST - 25;
  HDN_BEGINTRACKW      = HDN_FIRST - 26;
  HDN_ENDTRACKW        = HDN_FIRST - 27;  
type
  tagNMHEADERA = packed record
    Hdr: TNMHdr;
    Item: Integer;
    Button: Integer;
    PItem: PHDItemA;
  end;
  HD_NOTIFY = tagNMHEADERA;
  PHDNotify = ^HD_NOTIFY; 
  PNMHEADER = ^tagNMHEADERA;  
var
  fClass: ThiMTStrTbl;
  ind: integer;
  di, dw: TData;
  s: string;
begin
  Result := false;
  fClass := ThiMTStrTbl(Sender.Tag);
  with fClass do
  begin
    case Msg.message of
      WM_NOTIFY:
        case HD_NOTIFY(Pointer(Msg.LParam)^).Hdr.code of
        HDN_ITEMCHANGINGA, HDN_ITEMCHANGINGW:
          _hi_onEvent(_event_onChangeWidth, Sender.LVColWidth[HD_NOTIFY(Pointer(Msg.LParam)^).Item]);        
        HDN_ENDTRACKA, HDN_ENDTRACKW:
        begin
          ind := HD_NOTIFY(Pointer(Msg.LParam)^).Item;
          s := Sender.LVColText[ind] + _ColDlm +
               int2str(PHDNotify(PNMHEADER(Msg.LParam))^.pItem^.cxy) + _ColDlm +
               int2str(Sender.LVColImage[ind]) + _ColDlm +
               int2str(ord(Sender.LVColAlign[ind]));
          CList.Items[ind] := InitColStr(s);
          dtInteger(di, ind);
          dtInteger(dw, PHDNotify(PNMHEADER(Msg.LParam))^.pItem^.cxy);
          di.ldata := @dw;
//          _hi_onEvent_(_event_onChangeWidth, di);
        end;
        HDN_BEGINTRACKA, HDN_BEGINTRACKW, HDN_DIVIDERDBLCLICKA, HDN_DIVIDERDBLCLICKW:
          if not FChangeWidth then
          begin
            Rslt := 1;
            Result := True;
          end;          
        end;  
    end;      
  end;   
end;

//==============================================================================

procedure ThiMTStrTbl.detachwndproc;
begin
  if Control.IsProcAttached(WndProcTabGrid) then
    Control.DetachProc(WndProcTabGrid);
end;

procedure ThiMTStrTbl.Init;
var
  l: TListViewOptions;
begin
  l := [lvoUnderlineHot, lvoAutoArrange];

  if not _prop_Scroll then
    include(l, lvoNoScroll);
  if FInfoTip then
    include(l, lvoInfoTip);
  if FTrackSelect then
    include(l, lvoTrackSelect);
  if _prop_HeaderDragDrop then
    include(l, lvoHeaderDragDrop);
  if _prop_CheckBoxes then
    include(l, lvoCheckBoxes);
  if FMultiSelect then
    include(l, lvoMultiSelect);
  if FGrid then
    include(l, lvoGridLines);
  if _prop_RowSelect then
    include(l, lvoRowSelect);
  if _prop_FlatScroll then
    include(l, lvoFlatsb);
  if _prop_VirtualTab then
    include(l, lvoOwnerData);

  FIconColColor  := clBtnFace;

  if _prop_StateIconsManager = nil then
    StIList := nil
  else 
    StIList := _prop_StateIconsManager.iconlist;

  if _prop_SmallIconsManager = nil then
    SmIList := nil
  else
  begin 
    SmIList  := _prop_SmallIconsManager.iconlist;
    FImgSize := _prop_SmallIconsManager.imgsz;
    SmIList.BkColor := FIconColColor;
  end;

  if _prop_LargIconsManager = nil then
    LgIList := nil
  else 
    LgIList := _prop_LargIconsManager.iconlist;

  if FRedaction then
    Control := NewListEdit(FParent, FStyle, l, LgIList, SmIList, StIList,
                           _OnLineChange, _OnBeforeLineChange)
  else
    Control := NewListView(FParent, FStyle, l, LgIList, SmIList, StIList);

  mtstc.ctrlpoint      := ctrlpoint;
  mtstc.actionitm      := ActionItm;
  mtstc.actioncol      := actioncol;
  mtstc.propercol      := ProperCol;
  mtstc.textalign      := textalign;
  mtstc.smiconlist     := smiconlist;
  mtstc.lgiconlist     := lgiconlist;  
  mtstc.colcount       := colcount;
  mtstc.imgsize        := imgsize;     
  mtstc.coloritems     := coloritems;
  mtstc.scoloritems    := scoloritems;
  mtstc.textbkcolor    := textbkcolor;
  mtstc.textcolor      := textcolor;
  mtstc.bkcolor        := bkcolor;
  mtstc.addcols        := addcols;
  mtstc.stextbkcolor   := stextbkcolor;
  mtstc.stextcolor     := stextcolor;
  mtstc.sbkcolor       := sbkcolor;
  mtstc.siconcolcolor  := siconcolcolor;
  mtstc.iconcolcolor   := iconcolcolor;  
  mtstc.deletecol      := deletecol;
  mtstc.clistclear     := clistclear;
  mtstc.clistcount     := clistcount;
  mtstc.style          := style;
  mtstc.setfocus       := _work_doSetFocus;
  mtstc.matrix         := matrix;
  mtstc.mxget          := MX_Get;
  mtstc.mxset          := MX_Set;  
  mtstc.getnewcuridx   := getnewcuridx;
  mtstc.setnewcuridx   := setnewcuridx;
  mtstc.getfredaction  := getfredaction;
  mtstc.getfctl3d      := getfctl3d;
  mtstc.detachwndproc  := detachwndproc;
  mtstc.getstring      := Get;
  mtstc.columnarray    := columnarray;
  mtstc.clistitems     := clistitems;
  mtstc.nidxicon       := nidxicon;
  mtstc.ncolorrow      := ncolorrow;
  mtstc.codepageget    := CodePageGet;
  
  GMouse := false;
  Control.OnMouseDown     := _OnMouseDown;
  Control.OnMouseUp       := _OnMouseUp;
  Control.OnMouseDblClk   := _onDblClick;
  Control.OnColumnClick   := _OnColumnClick;
  Control.OnClick         := _OnClick;
  Control.OnLVStateChange := _OnSelState;
  Control.OnLVCustomDraw  := _OnLVCustomDraw;
  
  SetColumns(CList,0);

  inherited;

  FBkColor                := Control.Color;
  FTextColor              := Control.Font.Color;
  FTextBkColor            := Control.Color;
  Control.LVBkColor       := FBkColor;
  Control.LVTextColor     := FTextColor;
  Control.LVTextBkColor   := FTextBkColor;
  Control.Tag             := Cardinal(Self);
  Control.AttachProc(WndProcTabGrid);
  Control.AttachProc(WndHDR);  
  Control.DoubleBuffered := _prop_DoubleBuffered;
end;

procedure ThiMTStrTbl.SetTextColLst;
begin
  CList := NewStrList;
  Clist.Text := Value;
end;

procedure ThiMTStrTbl.SetColumns;
var
  i: integer;
  s, str, sd: string;
begin
  if ListCol.Count = 0 then exit;
  i:= 0;
  Control.BeginUpdate;
  repeat
    s := ListCol.Items[i] + _ColDlm;
    sd := GetTok(s, _ColDlm);
    if sd <> '' then
    begin
      str := sd;
      case Mode of
        0: Control.LVColAdd(sd, FTextAlign, FColumnWidth);
        1: Control.LVColText[i] := sd;
      end;
      sd := GetTok(s, _ColDlm);
      if sd = '' then
        sd:= int2str(FColumnWidth)
      else
        Control.LVColWidth[i] := str2int(sd);
      str := str + _ColDlm + sd;
      sd := GetTok(s, _ColDlm);
      if FImgColumn and Assigned(SmIlist) and (SmIList.Count <> 0) then
        if sd = '' then
          Control.LVColImage[i] := I_SKIP
        else  
          Control.LVColImage[i] := str2int(sd);
      str := str + _ColDlm + sd;
      sd := GetTok(s, _ColDlm);
      if sd <> '' then
        Control.LVColAlign[i] := TTextAlign(str2int(sd))
      else
      begin
        Control.LVColAlign[i] := FTextAlign;
        sd := int2str(ord(Control.LVColAlign[i]));
      end;
      str := str + _ColDlm + sd;
      ListCol.Items[i] := str;
    end;
    inc(i);
  until i = ListCol.Count; 
  Control.EndUpDate;
end;

function ThiMTStrTbl.Get;
var
  d, s: PData;
  dt: TData;
  ColCount, Col, Colidx: integer;
begin
  dtNull(Result);
  if not ((Index >= 0) and (Index < Control.Count) and (Control.LVColCount > 0)) then exit;

  FreeData(@FData_1);
  dtNull(FData_1);
 
  ColCount := Control.LVColCount;
  if AssignIList then
    inc(ColCount);
  if FColorItems then   
    inc(ColCount);               

  Col := 0;
  ColIdx := 0;
  new(s);
  FillChar(s^, sizeof(TData), 0);
TRY
  if Assigned(PData(Control.LVItemData[Index])) then
    CopyData(s, PData(Control.LVItemData[Index])); 

  while Col < ColCount do 
  begin
    if (Col = FNIdxIcon) and AssignIList then
    begin
      dtInteger(dt, Control.LVItemImageIndex[Index]);
      AddMtData(@FData_1, @dt, d);
    end 
    else if (Col = FNColorRow) and FColorItems then
    begin
      dtInteger(dt, 0);
      if Assigned(PData(Control.LVItemData[Index])) then
      begin
        dt := s^;
        dt.ldata := nil;
      end;
      AddMtData(@FData_1, @dt, d);
    end
    else
     if ColIdx < Control.LVColCount then
    begin
      dtString(dt, CodePageGet(Control.LVItems[Index, ColIdx]));
      AddMtData(@FData_1, @dt, d);
      inc(ColIdx);
    end;
    inc(Col);
  end;

  if AssignIList and (FNIdxIcon < 0) then
  begin
    dtInteger(dt, Control.LVItemImageIndex[Index]);
    AddMtData(@FData_1, @dt, d);
  end;

  if Assigned(PData(Control.LVItemData[Index])) and (FColorItems and not (FNColorRow < 0)) and (s^.ldata <> nil) then
    AddMtData(@FData_1, s^.ldata, d)
  else if Assigned(PData(Control.LVItemData[Index])) and (not FColorItems or (FNColorRow < 0)) then
    AddMtData(@FData_1, s, d);

  Result := FData_1;

FINALLY
  case s^.Data_type of
    data_null: ;
    else
      FreeData(s);
  end;    
  Dispose(s);
END;
end;

//ItemAtPos - Содержит индекс элемента, находящегося по координатам PosX, PosY в окне
//
procedure ThiMTStrTbl._var_ItemAtPos;
begin
   dtInteger(_Data, Control.LVItemAtPos(Ms.X, Ms.Y));
end;

//StringTable - Содержит указатель на компонент
//
procedure ThiMTStrTbl._var_MTStrTbl;
begin
  _Data.Data_type := data_int;
  _Data.sdata := 'StringTable';
  _Data.idata := integer(Control);
end;

//#####################################################################
//#                                                                   #
//#                        Установка свойств                          #
//#                                                                   #
//#####################################################################

procedure ThiMTStrTbl._work_doNIdxIcon;
begin
  FNIdxIcon := ToInteger(_Data);
end;

procedure ThiMTStrTbl._work_doNColorRow;
begin
  FNColorRow := ToInteger(_Data);
end;

procedure ThiMTStrTbl.stextcolor;
begin
  FTextColor := value;
  Control.LVTextColor := Value;
end;

procedure ThiMTStrTbl.stextbkcolor;
begin
  FTextBkColor := Value;
  Control.LVTextBkColor := Value;
end;

procedure ThiMTStrTbl.sbkcolor;
begin
  FBkColor := Value;
  Control.LVBkColor := Value;
end;

procedure ThiMTStrTbl._work_doColor;
begin
  FBkColor := ToInteger(_Data);
  Control.LVBkColor := FBkColor;
end;

procedure ThiMTStrTbl._work_doStyle;
begin
  FStyle := TListViewStyle(ToInteger(_Data));
  Control.LVStyle := FStyle;
  SetColumns(Clist, 1);
end;

procedure ThiMTStrTbl._work_doEnableOnClick;
begin
  FEnableOnClick := ReadBool(_Data);
end;

procedure ThiMTStrTbl._work_doChangeWidth;
begin
  FChangeWidth := ReadBool(_Data);
end;

procedure ThiMTStrTbl._work_doGrid;
begin
  FGrid := ReadBool(_Data);
  SetOption(FGrid, lvoGridLines);
end;

procedure ThiMTStrTbl._work_doTrackSelect;
begin
  FTrackSelect := ReadBool(_Data);
  SetOption(FTrackSelect, lvoTrackSelect);
end;

procedure ThiMTStrTbl._work_doMultiSelect;
begin
  FMultiSelect := ReadBool(_Data);
  SetOption(FMultiSelect, lvoMultiSelect);
end;

procedure ThiMTStrTbl._work_doInfoTip;
begin
  FInfoTip := ReadBool(_Data);
  SetOption(FInfoTip, lvoInfoTip);
end;

procedure ThiMTStrTbl.SetOption;
var
  l:TListViewOptions;
begin
  l := Control.LVOptions;
  if OSet then
    include(l, Option)
  else
    exclude(l, Option);
  Control.LVOptions := l;
end;

//#####################################################################
//#                                                                   #
//#            Управление и доступ к параметрам столбцов              #
//#                                                                   #
//#####################################################################

//------------------   Доступ к массиву столбцов   --------------------

//ColumnArray - Массив форматных свойств столбцов
//
procedure ThiMTStrTbl.columnarray;
begin
  if not Assigned(CLArray) then
    CLArray := CreateArray(_SetCol, _GetCol, _CountCol, _AddCol);
  dtArray(_Data, CLArray);
end;

procedure ThiMTStrTbl._SetCol;
var
  s: string;
  ind: integer;
begin
  ind := ToIntIndex(Item);
  s := ToString(Val);
  if (ind >= 0) and (ind < CList.Count) then
    CList.Items[ind] := InitColStr(s);
  SetColumns(CList, 1);
end;

function ThiMTStrTbl._GetCol;
var
  ind: integer;
begin
  ind := ToIntIndex(Item);
  Result := True;
  if (ind >= 0) and (ind < CList.Count) then
    dtString(Val, Clist.Items[ind])
  else
    Result := False;
end;

procedure ThiMTStrTbl._AddCol;
var
  s: string;
begin
  s := ToString(Val);
  Control.LVColAdd('', FTextAlign, FColumnWidth);
  CList.Add(InitColStr(s));
  SetColumns(CList, 1);
end;

function ThiMTStrTbl._CountCol;
begin
  Result := CList.Count;
end;

//--------------------   Управление столбцами   -----------------------

// Удаляет столбец из таблицы
//
procedure ThiMTStrTbl.deletecol;
var
  ind: integer;
begin
  ind := ToInteger(_Data);
  if (ind >= 0) and (ind < CList.Count) then
  begin
    Control.LVColDelete(ind);
    CList.Delete(ind);
  end;
  SetColumns(CList,1);
end;

function ThiMTStrTbl.InitColStr;
var
  s, ss, sd, se, sf, sh: string;
begin
  s := val;
  sf := s + _ColDlm;
  ss := GetTok(sf, _ColDlm);
  sd := GetTok(sf, _ColDlm);
  sh := GetTok(sf, _ColDlm);
  se := GetTok(sf, _ColDlm);
  if s <> '' then
  begin
    if sd = '' then sd := int2str(FColumnWidth);
    if se = '' then se := int2str(integer(FTextAlign));
    s := ss + _ColDlm + sd + _ColDlm + sh + _ColDlm + se;
  end;
  Result := s;
end;

//#####################################################################
//#                                                                   #
//#                      Доступ к матрице строк                       #
//#                                                                   #
//#####################################################################

//Matrix - Матрица строк
//
procedure ThiMTStrTbl.Matrix;
begin
  if not Assigned(Obj) then
  begin
    New(Obj);
    Obj._Set  := MX_Set;
    Obj._Get  := MX_Get;
    Obj._Rows := _mRows; 
    Obj._Cols := _mCols; 
  end;
  dtMatrix(_Data, Obj);
end;

function ThiMTStrTbl.MX_Get;
begin
  if (x >= 0) and (y >= 0) and (y < Control.Count) and (x < Control.LVColCount) then
    dtString(Result, Control.LVItems[y,x])
  else
    dtNull(Result);
end;

procedure ThiMTStrTbl.MX_Set;
begin
  if (x >= 0) and (y >= 0) and (y < Control.Count) and (x < Control.LVColCount) then
    Control.LVItems[y,x] := ToString(Val);
end;

function ThiMTStrTbl._mRows;
begin
  Result := Control.Count; 
end;

function ThiMTStrTbl._mCols;
begin
  Result := Control.LVColCount; 
end;

//#####################################################################
//#                                                                   #
//#                           MT-методы                               #
//#                                                                   #
//#####################################################################

// Универсальный MT-метод работы со строками таблицы
//
procedure ThiMTStrTbl.ActionItm; // проверен
var
  Row, Col, ColIdx, ColCount: integer;
  fd, s: PData;
  dc, ds: TData;
begin
  case Data.Data_type of
    data_null: exit;
  end;
  dtNull(dc);
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
  Col := 0;
  ColIdx := 0;
  ColCount := Control.LVColCount; 

  if AssignIList then
    inc(ColCount);
  if FColorItems then   
    inc(ColCount);               

  while Col < ColCount do
  begin
    if ((ColIdx <> FNIdxIcon) or not AssignIList) and ((ColIdx <> FNColorRow) or not FColorItems) then
    begin 
      if Col < Control.LVColCount then
      begin
        if Assigned(_data_CodePageSet.Event) then
        begin
          dtString(ds, ReadString(Data, Null));
          _ReadData(ds, _data_CodePageSet);
          Control.LVItems[Row, Col] := ToString(ds);
        end  
        else
          Control.LVItems[Row, Col] := ReadString(Data, Null);
      end;
      inc(Col);
    end  
    else if (ColIdx = FNIdxIcon) and AssignIList then
      Control.LVItemImageIndex[Row]:= ReadInteger(Data, Null)
    else if (ColIdx = FNColorRow) and FColorItems then
      dc := ReadData(Data, Null);
    inc(ColIdx);
  end;

  case Data.Data_type of
    data_null: ;
    else
    begin
      if AssignIList and (FNIdxIcon < 0) then
        Control.LVItemImageIndex[Row]:= ReadInteger(Data, Null);
    end        
  end;
  AddMTData(@dc, @Data, s);

TRY  
  case dc.Data_type of
    data_null: exit;
  end;
  if Assigned(PData(Control.LVItemData[Row])) then
  begin
    fd := PData(Control.LVItemData[Row]);
    FreeData(fd);
  end
  else
  begin
    new(fd);
    FillChar(fd^, sizeof(TData), 0);
  end;    
  CopyData(fd, @dc);
  Control.LVItemData[Row] := cardinal(fd);
FINALLY  
  FreeData(s);
END;
end;

//Универсальный MT-метод работы со столбцами
//
procedure ThiMTStrTbl.ActionCol; // проверен
var
  s: string;
  ind: integer;
begin
  case Data.Data_type of
    data_null: exit;
  end;
  ind := ReadInteger(Data, Null); 
  s := ReadString(Data, Null);   
  case Mode of
    ITM_INSERT:
      if ind >= 0 then
        if (ind > CList.Count - 1) then
        begin
          Control.LVColAdd('', FTextAlign, FColumnWidth);
          CList.Add(InitColStr(s));
        end
        else
        begin
          Control.LVColInsert(ind, '', FTextAlign, FColumnWidth);
          CList.Insert(ind, InitColStr(s));
        end;
    ITM_REPLACE:
      if (ind >= 0) and (ind < CList.Count) then
        CList.Items[ind] := InitColStr(s)
    else
      exit;
  end;    
  SetColumns(CList, 1);
end;

//Универсальный MT-метод работы со свойствами столбцов
//
procedure ThiMTStrTbl.ProperCol; // проверен
var
  s, name, width, imgidx, aligntxt: string;
  ind: integer;
begin
  case Data.Data_type of
    data_null: exit;
  end;
  ind := ReadInteger(Data, Null);   
  s := ReadString(Data, Null);   
  if (ind < 0) or (ind > CList.Count - 1) then exit;
  name := Control.LVColText[ind];
  width := int2str(Control.LVColWidth[ind]);
  imgidx := int2str(Control.LVColImage[ind]);
  aligntxt := int2str(ord(Control.LVColAlign[ind]));  
  case Mode of 
    COL_NAME:  name := s;
    COL_WIDTH: width := s;
    COL_IMAGE: imgidx := s;
    COL_ALIGN: aligntxt := s;
    else
      exit;   
  end;
  s := name + _ColDlm + width + _ColDlm + imgidx + _ColDlm + aligntxt;
  CList.Items[ind] := InitColStr(s);
  SetColumns(CList, 1);
end;

// Содержит индекс элемента, отображаемого в первой строке списка
//
procedure ThiMTStrTbl._var_TopItem;
begin
  dtInteger(_Data, Control.LVTopItem);
end;

// Содержит количество целых элементов, вмещающихся в одну страницу
//
procedure ThiMTStrTbl._var_PerPage;
begin
  dtInteger(_Data, Control.LVPerPage);
end;

// Содержит количество строк в таблице
//
procedure ThiMTStrTbl._var_Count;
begin
  dtInteger(_Data, Control.Count);
end;

// Содержит индекс последний строки в таблице
//
procedure ThiMTStrTbl._var_EndIdx;
begin
  dtInteger(_Data, Control.Count - 1);
end;

// Содержит выбранную строку,
// где строка - это набор MT-элементов со значениями каждой колонки
//
procedure ThiMTStrTbl._var_Select;
begin
  if Control.LVCurItem = -1 then
     dtNull(_Data)
   else
     _Data := Get(Control.LVCurItem); 
end;

// Содержит индекс выделенной строки
//
procedure ThiMTStrTbl._var_Index;
begin
  dtInteger(_Data, Control.CurIndex);
end;

// Содержит количество столбцов
//
procedure ThiMTStrTbl._var_CountCol;
begin
  dtInteger(_Data, CList.Count);
end;

// Содержит индекс последнего столбца в таблице
//
procedure ThiMTStrTbl._var_EndIdxCol;
begin
  dtInteger(_Data, CList.Count - 1);
end;

//  Установка свойств менеджеров
//
procedure ThiMTStrTbl.SetLargIconsManager;
begin
  if value <> nil then
  begin
    FLargIconsManager := value;
    LgIList := value.iconList;
    if Assigned(Control) then
      Control.ImageListNormal := LgIList;
  end;
end;

procedure ThiMTStrTbl.SetSmallIconsManager;
begin
  if value <> nil then
  begin
    FSmallIconsManager := value;
    SmIList := value.iconList; 
    FImgSize := value.imgsz;
    SmIList.BkColor := FIconColColor;
    Control.ImageListSmall := SmIList;
    SetColumns(CList,1);  
  end;
end;

procedure ThiMTStrTbl.SetStateIconsManager;
begin
  if value <> nil then
  begin
    FStateIconsManager := value;
    StIList := value.iconList;
    if Assigned(Control) then
      Control.ImageListState := StIList;
  end;
end;

procedure ThiMTStrTbl._work_doClientRect;
var
  Row,Col: integer;
  R, ARect: TRect;
  dTop, dWidth, dHeight, Data: TData;
  b: integer;
begin
  Row := ReadInteger(_Data, _data_Row, _prop_Row);
  Col := ReadInteger(_Data, _data_Col, _prop_Col);
  R := Control.LVSubItemRect(Row, Col);
  if Col = 0 then
  begin
    ARect := Control.LVItemRect(Row, lvipLabel);
    R.Left := ARect.Left;
    R.Right := ARect.Right;
  end; 
  if not boolean(_prop_CTL3D) then
    b := 2
  else
    b := 1;

  dtInteger(Data, R.Left + Control.Left + b);
  dtInteger(dWidth, R.Right - R.Left - 1);
  dtInteger(dTop, R.Top + Control.Top + b);
  dtInteger(dHeight, R.Bottom - R.Top - 1);

  Data.ldata:= @dTop;
  dTop.ldata:= @dWidth;
  dWidth.ldata:= @dHeight;
  _hi_OnEvent_(_event_onClientRect, Data);
end;

//
//----------------------------   Конец   ------------------------------
end.