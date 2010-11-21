unit hiTreeViewEx;

interface

uses Windows,Kol,Share,Win;

type
  THITreeViewEx = class(THIWin)
   private
    _Arr,ICArray,ICStArray,CBArray:PArray;
    IList,IListSt:PImageList;
    IconsIdx:TIconsIdx;
    fImgSize:integer;
    Matrix:PMatrix;

    procedure _OnClick(Obj:PObj);
    function _OnBeginEdit(Sender: PControl; Item: THandle): Boolean;
    function _OnEndEdit(Sender: PControl; Item: THandle; const NewTxt: String): Boolean;
    function _OnExpanding(Sender: PControl; Item: THandle; Expand: Boolean): Boolean;
    procedure LoadFromText(Lst:PStrList);
    function IndexToHandle(Index:integer):THandle;
    function HandleToIndex(Handle:THandle):integer;
    procedure Add(var _Data:TData; Child:boolean = false);

    procedure _Set(var Item:TData; var Val:TData);
    function _Get(Var Item:TData; var Val:TData):boolean;
    function _Count:integer;
    procedure _Add(var Val:TData);
    procedure _SetIcon(var Item:TData; var Val:TData);
    function _GetIcon(Var Item:TData; var Val:TData):boolean;
    procedure _AddIcon(var Val:TData);
    function  _CountIcon:integer;
    procedure SetIListParametrs(IconsList:PImageList);
    procedure SetImgSize(const value:integer);    
    procedure SetIcons(const value:PStrListEx);
    procedure SetIconsState(const value:PStrListEx);
    function IndexToStr(prn:THandle; s: string):string;
    procedure _SetStIcon(var Item: TData; var Val: TData);
    function _GetStIcon(Var Item: TData; var Val: TData): boolean;
    procedure _AddStIcon(var Val:TData);
    function  _CountStIcon:integer;
    procedure CB_Set(var Item:TData; var Val:TData);
    function CB_Get(Var Item:TData; var Val:TData):boolean;
    procedure MX_Set(x,y:integer; var Val:TData);
    function MX_Get(x,y:integer):TData;
    function _mRows:integer;
    function _mCols:integer;
        
   public
    _prop_Strings:string;
    _prop_Lines:boolean;
    _prop_LinesRoot:boolean;
    _prop_Tooltips:boolean;
    _prop_EditLabels:boolean;
    _prop_TrackSelect:boolean;
    _prop_CheckBoxes:boolean;
    _prop_OverlayIcon:boolean;
    _prop_SingleExpand:boolean;    
    _prop_FileName:string;
    _prop_IconByIndex:boolean;
    _prop_Delimiter:string;
    _prop_AlwaysUseIcons:boolean;

    _data_FileName:THI_Event;
    _data_str:THI_Event;
    _data_Parent:THI_Event;
    _data_Child:THI_Event;
    _event_onClick:THI_Event;
    _event_onChange:THI_Event;
    _event_onBeginEdit:THI_Event;
    _event_onEndEdit:THI_Event;        
    _event_onSelectChanging:THI_Event; 
    _event_onExpand:THI_Event;
    _event_onCollapse:THI_Event;
    _event_onItemPath:THI_Event;
    
    {icons}
    _data_IconID:THI_Event;
    property _prop_ImgSize:integer write SetImgSize;
    property _prop_IconsState:PStrListEx write SetIconsState;
    property _prop_Icons:PStrListEx write SetIcons;
    
    procedure Init; override;
    destructor Destroy; override;
    procedure _work_doAdd(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);
    procedure _work_doInsert(var _Data:TData; Index:word);
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doLoadFromText(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
    procedure _work_doSelect(var _Data:TData; Index:word);
    procedure _work_doItemBold(var _Data:TData; Index:word);
    procedure _work_doAddChild(var _Data:TData; Index:word);    
    procedure _work_doAddIcon(var _Data:TData; Index:word);
    procedure _work_doAddStIcon(var _Data:TData; Index:word);
    procedure _work_doRename(var _Data:TData; Index:word);
    procedure _work_doSort(var _Data:TData; Index:word);
    procedure _work_doItemHasChild(var _Data:TData; Index:word);
    procedure _work_doItemPath(var _Data:TData; Index:word);
    procedure _work_doClearIcons(var _Data:TData; Index:word);
    procedure _work_doClearStIcons(var _Data:TData; Index:word);
    procedure _work_doExpand(var _Data:TData; Index:word);
    procedure _work_doCollapse(var _Data:TData; Index:word);    
    procedure _work_doExpandToggle(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_Array(var _Data:TData; Index:word);
    procedure _var_IconArray(var _Data:TData; Index:word);
    procedure _var_IconStArray(var _Data:TData; Index:word);
    procedure _var_CheckArray(var _Data:TData; Index:word);
    procedure _var_Index(var _Data:TData; Index:word);
    procedure _var_ItemAtPos(var _Data:TData; Index:word);  
    procedure _var_ItemParent(var _Data:TData; Index:word);
    procedure _var_ItemChild(var _Data:TData; Index:word);
    procedure _var_Matrix(var _Data:TData; Index:word);    
  end;

implementation

procedure THITreeViewEx.Init;
var Lst:PStrList;
    Fl:TTreeViewOptions;
begin
   SetLength(IconsIdx, 4);
   
   if _prop_Lines then fl := [] else fl := [tvoNoLines];
   if not _prop_Tooltips then include(fl,tvoNoTooltips);
   if _prop_LinesRoot    then include(fl,tvoLinesRoot);
   if _prop_EditLabels   then include(fl,tvoEditLabels);
   if _prop_TrackSelect  then include(fl,tvoTrackSelect);
   if _prop_CheckBoxes   then include(fl,tvoCheckBoxes);
   if _prop_SingleExpand then include(fl,tvoSingleExpand);

   if _prop_AlwaysUseIcons and not Assigned(IList) then begin
      IList:= NewImageList(nil);    
      SetIListParametrs(IList);
   end;

   Control := NewTreeView(FParent,fl,IList,IListSt);
   Control.OnTVExpanding := _OnExpanding;
   Control.OnSelChange   := _OnClick;
   Control.OnTVBeginEdit := _OnBeginEdit;
   Control.OnTVEndEdit   := _OnEndEdit;
   Lst := NewStrList;
   Lst.Text := _prop_Strings;
   LoadFromText(Lst);
   inherited;
end;

destructor THITreeViewEx.Destroy;
begin
   if Assigned(IList)   then IList.free;
   if Assigned(IListSt) then IListSt.free;
   if _Arr      <> nil  then dispose(_Arr);
   if ICArray   <> nil  then dispose(ICArray);
   if ICStArray <> nil  then dispose(ICStArray);
   if CBArray   <> nil  then dispose(CBArray);
   if Matrix    <> nil  then dispose(Matrix);
   inherited;
end;

procedure THITreeViewEx._OnClick;
begin
   _hi_OnEvent(_event_onClick,Control.TVItemText[Control.TVSelected])
end;

function THITreeViewEx._OnBeginEdit;
begin
   Result := true;
   _hi_OnEvent(_event_onBeginEdit, Control.TVItemText[Item]);
end;

function THITreeViewEx._OnEndEdit;
begin
   Result := true;
   _hi_OnEvent(_event_onEndEdit, NewTxt)
end;

function THITreeViewEx._OnExpanding;
begin
   Result := true;
   if Expand then
      _hi_OnEvent(_event_onExpand, HandleToIndex(Item))
   else
      _hi_OnEvent(_event_onCollapse, HandleToIndex(Item));
end;

//------------------------------------------------------------------------------

function THITreeViewEx.IndexToHandle;
var   i:smallint;
      p:THandle;
begin
   p := 0;
   i := 0;
   while i <= Index do begin
      if Control.TVItemChild[p] > 0 then
         p := Control.TVItemChild[p]
      else if Control.TVItemNext[p] > 0 then
         p := Control.TVItemNext[p]
      else begin
         repeat
            p := Control.TVItemParent[p];
         until (p = 0)or(Control.TVItemNext[p] > 0);
         if p > 0 then
            p := Control.TVItemNext[p];
      end;
      inc(i);
   end;
   Result := p;
end;

function THITreeViewEx.HandleToIndex;
var   ind:integer;

      function HTI(prn:THandle):boolean;
      begin
         repeat
            if prn = Handle then
               Result := true
            else if prn = 0 then
               Result := false
            else if Control.TVItemChild[prn] > 0 then
               Result := HTI( Control.TVItemChild[prn] )
            else
               Result := false;
            inc(ind);
            prn := Control.TVItemNext[prn];
         until Result or( prn = 0 );
      end;

begin
   ind := 0;
   if HTI(Control.TVRoot) then Result := Ind-1 else Result := -1;
end;

//------------------------------------------------------------------------------

procedure THITreeViewEx.LoadFromText;
var   i:smallint;
      Last,Prn:cardinal;
      ind_0, ind_1, ind_2, ind_3 :integer;
      s:string;
begin
   Control.Clear;
   Last := 0;
   Prn := 0;
   for i := 0 to Lst.Count-1 do begin
      s := Lst.Items[i];
      if s = '(' then
         Prn := Last
      else if s = ')' then begin
         last := Prn;
         Prn := Control.TVItemParent[Prn];
      end else begin
         if not _prop_IconByIndex then begin
            Last  := Control.TVInsert(Prn,Control.Count-1,s);
            ind_0 := Control.Count-1;
            ind_1 := ind_0;
            ind_2 := I_SKIP;
            ind_3 := 0;  
         end else begin
            ParseIconsIdx(s,IconsIdx,true);
            Last  := Control.TVInsert(Prn,Control.Count-1,s);
            ind_0 := IconsIdx[0];
            ind_1 := IconsIdx[1];
            if ind_1 < 0 then ind_1 := ind_0; 
            ind_2 := IconsIdx[2];
            ind_3 := IconsIdx[3];
            if ind_3 < 0 then ind_3 := 0;            
         end;
         Control.TVItemImage[Last]  := ind_0;
         Control.TVItemSelImg[Last] := ind_1;
         if Assigned(IListSt) and not _prop_CheckBoxes then Control.TVItemStateImg[Last] := ind_2;
         if _prop_OverlayIcon then Control.TVItemOverlay[Last] := ind_3;
      end;
   end;
   Lst.Free;
   _hi_OnEvent(_event_onChange);
end;

//doAdd - Добавляет узел в список с именем из потока или поля str
//
procedure THITreeViewEx._work_doAdd;
begin
   Add(_Data);
end;

//doAddChild - Добавляет узел, дочерний по отношению к узлу Parent
//
procedure THITreeViewEx._work_doAddChild;
begin
   Add(_Data,true);
end;

procedure THITreeViewEx.Add;
var   item:THandle;
      s:string;
      ind_0, ind_1, ind_2, ind_3 :integer;
begin
   s := ReadString(_Data,_data_str,'');
   if not _prop_IconByIndex then begin
      ind_0 := ReadInteger(_Data,_data_IconID);
      ind_1 := ind_0;
      ind_2 := I_SKIP;
      ind_3 := 0;  
   end else begin
      ParseIconsIdx(s,IconsIdx,true);
      ind_0 := IconsIdx[0];
      ind_1 := IconsIdx[1];
      if ind_1 < 0 then ind_1 := ind_0;
      ind_2 := IconsIdx[2];
      ind_3 := IconsIdx[3];
      if ind_3 < 0 then ind_3 := 0;            
   end;

   if not Child then
      item := Control.TVInsert(Control.TVSelected, 0, s)
   else
      item := Control.TVInsert(IndexToHandle(ReadInteger(_Data,_data_Parent)), 0, s);   
   Control.TVItemImage[item]  := ind_0;
   Control.TVItemSelImg[item] := ind_1;
   if Assigned(IListSt) and not _prop_CheckBoxes then Control.TVItemStateImg[item] := ind_2;
   if _prop_OverlayIcon then Control.TVItemOverlay[item]  := ind_3;
   _hi_CreateEvent(_Data,@_event_onChange);
end;
//------------------------------------------------------------------------------

//doInsert - Вставляет узел в список. Номер узла, после которого будет добавлен новый узел,
//           извлекается из потока или поля Child(0 - первый узел)
//
procedure THITreeViewEx._work_doInsert;
var   par, idx, item:THandle;
      s:string;
      ind_0, ind_1, ind_2, ind_3 :integer;
begin
   idx := IndexToHandle(ReadInteger(_Data,_data_Child));
   par := Control.TVItemParent[idx];
   s := ReadString(_Data,_data_str,'');
   if not _prop_IconByIndex then begin
      ind_0 := ReadInteger(_Data,_data_IconID);
      ind_1 := ind_0;
      ind_2 := I_SKIP;
      ind_3 := 0;
   end else begin
      ParseIconsIdx(s,IconsIdx,true);
      ind_0 := IconsIdx[0];
      ind_1 := IconsIdx[1];
      if ind_1 < 0 then ind_1 := ind_0;
      ind_2 := IconsIdx[2];
      ind_3 := IconsIdx[3];
      if ind_3 < 0 then ind_3 := 0;
   end;

   item := Control.TVInsert(par, idx, s);
   Control.TVItemImage[item]  := ind_0;
   Control.TVItemSelImg[item] := ind_1;
   if Assigned(IListSt) and not _prop_CheckBoxes then Control.TVItemStateImg[item] := ind_2;
   if _prop_OverlayIcon then Control.TVItemOverlay[item]  := ind_3;
   _hi_CreateEvent(_Data,@_event_onChange);
end;

//doClear - Очищает список узлов
//
procedure THITreeViewEx._work_doClear;
begin
   Control.BeginUpdate;
   Control.Clear;
   Control.EndUpdate;
   _hi_CreateEvent(_Data,@_event_onChange);
end;

//doClearIcons - Очищает список основных иконок
//
procedure THITreeViewEx._work_doClearIcons;
begin
   if not Assigned(Ilist) then exit;
   Control.BeginUpdate;
   repeat
      IList.Delete(Ilist.Count - 1);
   until Ilist.Count = 0;
   Control.EndUpdate;
   _hi_CreateEvent(_Data,@_event_onChange);
end;

//doClearStIcons - Очищает список иконок состояния
//
procedure THITreeViewEx._work_doClearStIcons;
begin
   if not Assigned(IListSt) then exit;
   Control.BeginUpdate;
   repeat
      IListSt.Delete(IlistSt.Count - 1);
   until IlistSt.Count = 0;
   Control.EndUpdate;
   _hi_CreateEvent(_Data,@_event_onChange);
end;

//doDelete - Удаляет узел из списка. Номер узла извлекается из потока (0 - первый узел)
//
procedure THITreeViewEx._work_doDelete;
begin
   Control.TVDelete(IndexToHandle(ToInteger(_Data)));
   _hi_CreateEvent(_Data,@_event_onChange);
end;

//doLoad - Загружает список узлов из файла
//
procedure THITreeViewEx._work_doLoad;
var   Lst:PStrList;
begin
   Lst := NewStrList;
   Lst.LoadFromFile(ReadFileName(ReadString(_Data,_data_FileName,_prop_FileName)));
   LoadFromText(Lst);
end;

//doLoadFromText - Загружает список узлов из текста в потоке
//
procedure THITreeViewEx._work_doLoadFromText;
var   Lst:PStrList;
begin
   Lst := NewStrList;
   Lst.Text := ToString(_Data);
   LoadFromText(Lst);
end;

//------------------------------------------------------------------------------

function THITreeViewEx.IndexToStr;
const _dlm = ',';
var   l, ind_0, ind_1, ind_2, ind_3: integer;
      sind:string;
begin
   Result := s;
   if not _prop_IconByIndex then exit; 
   ind_0 := Control.TVItemImage[prn];
   ind_1 := Control.TVItemSelImg[prn];
   if Assigned(IListSt) then ind_2 := Control.TVItemStateImg[prn] else ind_2 := I_SKIP;
   ind_3 := Control.TVItemOverlay[prn];
   if ind_0 > $FFEF then sind := _dlm else sind := int2str(ind_0) + _dlm; 
   if ind_1 > $FFEF then sind := sind + _dlm else sind := sind + int2str(ind_1) + _dlm; 
   if ind_2 < 0 then sind := sind + _dlm else sind := sind + int2str(ind_2) + _dlm;
   if ind_3 > 0 then sind := sind + int2str(ind_3);
   l := length(sind); 
   repeat
      if sind[l] <> _dlm then Continue;
      delete(sind,l,1);
      dec(l);
   until (length(sind) = 0) or (sind[l] <> _dlm); 
   if sind = '' then exit;
   Result := '<' + sind + '>' + s;  
end;

//Save - Сохраняет список узлов в файле
//
procedure THITreeViewEx._work_doSave;
var   Lst:PStrList;

      procedure Save(prn:THandle);
      begin
         if prn > 0 then begin
            Lst.Add(IndexToStr(prn, Control.TVItemText[prn]));
            if Control.TVItemChild[prn] > 0 then begin
               Lst.Add('(');
               Save(Control.TVItemChild[prn]);
               Lst.Add(')');
            end;
            Save(Control.TVItemNext[prn]);
         end;
      end;

begin
   Lst := NewStrList;
   Save(Control.TVRoot);
   Lst.SaveToFile(ReadFileName(ReadString(_Data,_data_FileName,_prop_FileName)));
   Lst.Free;
end;

//------------------------------------------------------------------------------

//Select - Выделяет узел, индекс которой указан в потоке
//
procedure THITreeViewEx._work_doSelect;
begin
   Control.TVSelected := IndexToHandle(ToInteger(_Data));
end;

//Rename - Переименовывает выделенный узел
//
procedure THITreeViewEx._work_doRename;
begin
   Control.TVItemText[Control.TVSelected] := ToString(_Data);
end;

//Count - Хранит число всех узлов в списке
//
procedure THITreeViewEx._var_Count;
begin
   dtInteger(_Data, Control.Count);
end;

//------------------------------------------------------------------------------

procedure THITreeViewEx._Set(var Item:TData; var Val:TData);
var   ind:integer;
      s:string;
      ind_0, ind_1, ind_2, ind_3 :integer;
      prn:THandle;
begin
   ind := ToInteger(Item);
   if (ind < 0 ) or (ind > Control.Count-1) then exit;
   prn := IndexToHandle(ind);
   s := ToString(Val);
TRY
   if not _prop_IconByIndex then exit
   else begin
      ParseIconsIdx(s,IconsIdx,true);
      ind_0 := IconsIdx[0];
      ind_1 := IconsIdx[1];
      if ind_1 < 0 then ind_1 := ind_0;
      ind_2 := IconsIdx[2];
      ind_3 := IconsIdx[3];
      if ind_3 < 0 then ind_3 := 0;            
   end;
   Control.TVItemImage[prn]  := ind_0;
   Control.TVItemSelImg[prn] := ind_1;
   if Assigned(IListSt) and not _prop_CheckBoxes then Control.TVItemStateImg[prn] := ind_2;
   if _prop_OverlayIcon then Control.TVItemOverlay[prn] := ind_3;
FINALLY
   Control.TVItemText[prn] := s;
   Control.Invalidate;
END;
end;

function THITreeViewEx._Get(Var Item:TData; var Val:TData):boolean;
var   ind:integer;
begin
   ind := ToInteger(Item);
   if(ind >= 0) and (ind < Control.Count) then begin
      dtString(Val,IndexToStr(IndexToHandle(ind), Control.TVItemText[IndexToHandle(ind)]));
      Result := true;
   end else
      Result := false;
end;

function THITreeViewEx._Count:integer;
begin
   Result := Control.Count;
end;

procedure THITreeViewEx._Add(var Val:TData);
begin
   Add(Val);
end;

procedure THITreeViewEx._var_Array;
begin
   if _Arr = nil then
      _Arr := CreateArray(_Set,_Get,_Count,_Add);
   dtArray(_Data,_Arr);
end;

procedure THITreeViewEx._var_Index;
begin
   dtInteger(_Data,HandleToIndex(Control.TVSelected));
end;

procedure THITreeViewEx.SetIcons;
var   i:integer;
begin
   IList := NewImageList(nil);
   SetIListParametrs(IList);
   for i := 0 to Value.Count-1 do
      IList.AddIcon(Value.Objects[i]);
   if _prop_OverlayIcon then
      for i := 0 to Min(14, IList.Count-1) do
         ImageList_SetOverlayImage(IList.Handle, i, i + 1);
end;

procedure THITreeViewEx.SetIconsState;
var   i:integer;
begin
   IListSt := NewImageList(nil);
   SetIListParametrs(IListSt);
   if _prop_CheckBoxes then begin
      for i := 0 to Min(2, Value.Count-1) do IListSt.AddIcon(Value.Objects[i]);
   end else begin   
      for i := 0 to Min(13, Value.Count-1) do IListSt.AddIcon(Value.Objects[i]);
   end;   
end;

procedure THITreeViewEx.SetIListParametrs;
begin
   IconsList.BkColor := clWindow;
   IconsList.ImgWidth := fImgSize;
   IconsList.ImgHeight := fImgSize;
   IconsList.DrawingStyle := [dsTransparent];
   IconsList.Colors := ilcColor32;
end;

procedure THITreeViewEx.SetImgSize;
begin
   If Value < 16 then fImgSize := 16 else fImgSize := Value;       
end;

//-----------------------   Доступ к массивам иконок   -------------------------

//IconArray - Массив основных иконок
//
procedure THITreeViewEx._var_IconArray;
begin
   if not Assigned(ICArray) then ICArray := CreateArray(_SetIcon,_GetIcon,_CountIcon,_AddIcon);
   dtArray(_Data,ICArray);
end;

procedure THITreeViewEx._SetIcon(var Item:TData; var Val:TData);
var   ind:integer;
begin
   if not Assigned(IList) then exit;
   SetIListParametrs(IList);
   ind:= ToIntIndex(Item);
   if (ind >= 0) and (ind < IList.Count) and _IsIcon(Val) then
      IList.ReplaceIcon(ind, ToIcon(val).handle);
   Control.Invalidate;
end;

function THITreeViewEx._GetIcon(Var Item:TData; var Val:TData):boolean;
begin
   Result:= False;
end;

procedure THITreeViewEx._AddIcon(var Val:TData);
begin
   if not Assigned(IList) then exit;
   SetIListParametrs(IList);
   if _IsIcon(Val) then IList.AddIcon(ToIcon(Val).Handle);
   Control.Invalidate;
end;

function THITreeViewEx._CountIcon:integer;
begin
   if Assigned(IList) then 
      Result := IList.Count
   else
      Result := 0;      
end;

//------------------------------------------------------------------------------

//IdxArray - Массив иконок состояния
//
procedure THITreeViewEx._SetStIcon(var Item:TData; var Val:TData);
var   ind:integer;
begin
   if not Assigned(IListSt) then exit;
   SetIListParametrs(IListSt);
   ind:= ToIntIndex(Item);
   if Assigned(IListSt) and (ind >= 0) and (ind < IListSt.Count) and _IsIcon(Val) then
      IListSt.ReplaceIcon(ind, ToIcon(val).handle);
   Control.Invalidate;
end;

function THITreeViewEx._GetStIcon(Var Item:TData; var Val:TData):boolean;
begin
   Result:= False;
end;

procedure THITreeViewEx._AddStIcon(var Val:TData);
begin
   if not Assigned(IListSt) then exit;
   SetIListParametrs(IListSt);
   if Assigned(IListSt) and (IListSt.Count < 14) and _IsIcon(Val) then
      IListSt.AddIcon(ToIcon(Val).Handle);
   Control.Invalidate;
end;

function THITreeViewEx._CountStIcon:integer;
begin
   if Assigned(IListSt) then
      Result := IListSt.Count
   else
      Result := 0;   
end;

procedure THITreeViewEx._var_IconStArray;
begin
   if ICStArray = nil then
      ICStArray := CreateArray(_SetStIcon,_GetStIcon,_CountStIcon,_AddStIcon);
   dtArray(_Data, ICStArray);
end;

//------------------------------------------------------------------------------

//ItemAtPos - Содержит индекс элемента в окне, находящегося по координатам MouseX, MouseY
//
procedure THITreeViewEx._var_ItemAtPos;
var   where:dword;
begin
   dtInteger(_Data, HandleToIndex(Control.TVItemAtPos(Ms.X, Ms.Y, where)));
end;

//doAddIcon - Добавляет иконку из потока в основной список иконок
//
procedure THITreeViewEx._work_doAddIcon;
begin
   if not _IsIcon(_Data) or not Assigned(IList) then exit;
   SetIListParametrs(IList);
   IList.AddIcon(ToIcon(_Data).handle);
   Control.Invalidate;
end;

//doAddStIcon - Добавляет иконку из потока в список иконок состояния
//
procedure THITreeViewEx._work_doAddStIcon;
begin
   if not Assigned(IListSt) or (IListSt.Count >= 14) or (not _IsIcon(_Data)) then exit;
   SetIListParametrs(IListSt);
   IListSt.AddIcon(ToIcon(_Data).handle);
   Control.Invalidate;
end;

//doItemBold - Включает/выключает отображаение пункта с индексом из потока жирным шрифтом
//
procedure THITreeViewEx._work_doItemBold;
var   item:THandle;
begin
   item := IndexToHandle(ToInteger(_Data)); 
   Control.TVItemBold[item] := not Control.TVItemBold[item];
end;

//ItemPath - Получает "путь" разделенный символом Delimiter
//           от корневого узла к указанному узлу с индексом из потока
//
procedure THITreeViewEx._work_doItemPath;
var   idx:integer;
      s:string;
begin
   idx := ToInteger(_Data);
   if _prop_Delimiter[1] = '\' then s := '\' else s := '';  
   _hi_OnEvent(_event_onItemPath, Control.TVItemPath(IndexToHandle(idx), _prop_Delimiter[1]) + s); 
end;

//------------------------------------------------------------------------------

//CheckArray - Массив значений флажков (0 - не установлен, 1 - установлен)
//
procedure THITreeViewEx._var_CheckArray;
begin
   if not Assigned(CBArray) then
      CBArray := CreateArray(CB_Set,CB_Get,_Count,nil);
   dtArray(_Data,CBArray);
end;

procedure THITreeViewEx.CB_Set(var Item:TData; var Val:TData);
var   ind:integer;
begin
   ind:= ToIntIndex(Item);
   if not _prop_CheckBoxes then exit;
   if (ind >= 0) and (ind < Control.Count) then
      Control.TVItemStateImg[IndexToHandle(ind)] := ToInteger(Val) + 1;
end;

function THITreeViewEx.CB_Get(Var Item:TData; var Val:TData):boolean;
var   ind:integer;
begin
   Result:= False;
   if not _prop_CheckBoxes then exit;
   ind:= ToIntIndex(Item);
   if (ind >= 0) and (ind < Control.Count) then begin
      dtInteger(Val, Control.TVItemStateImg[IndexToHandle(ind)] - 1);
      Result:= True;
   end;
end;

//------------------------------------------------------------------------------

//doItemHasChild - Назначает узел с индексом из потока родительским
//
procedure THITreeViewEx._work_doItemHasChild;
begin
   Control.TVItemHasChildren[IndexToHandle(ToInteger(_Data))] := true;
end;

//doSort - Сортирует все дерево
//
procedure THITreeViewEx._work_doSort;
begin
   Control.TVSort(0);
end;

//ItemParent - Содержит номер родительского узла для дочернего узла с номером из поля Child
//
procedure THITreeViewEx._var_ItemParent;
begin
   dtInteger(_Data, HandleToIndex(Control.TVItemParent[IndexToHandle(ToIntegerEvent(_data_Child))]));
end;

//ItemChild - Содержит номер первого дочернего узла для узла с номером из поля Parent
//
procedure THITreeViewEx._var_ItemChild;
begin
   dtInteger(_Data, HandleToIndex(Control.TVItemChild[IndexToHandle(ToIntegerEvent(_data_Parent))]));
end;

//doExpandToggle - Eсли узел раскрыт, закрывает его, и, если он раскрыт, то захлопывает.
//                 Номер узла извлекается из потока
procedure THITreeViewEx._work_doExpandToggle;
begin
   Control.TVExpand(IndexToHandle(ToInteger(_Data)), TVE_TOGGLE);
end;

//doExpand - Раскрывает узел. Номер узла извлекается из потока
//
procedure THITreeViewEx._work_doExpand;
begin
   Control.TVExpand(IndexToHandle(ToInteger(_Data)), TVE_EXPAND);
end;

//doCollapse - Захлопывает узел. Номер узла извлекается из потока
//
procedure THITreeViewEx._work_doCollapse;
begin
   Control.TVExpand(IndexToHandle(ToInteger(_Data)), TVE_COLLAPSE);
end;

//------------------------------------------------------------------------------

//Matrix - Матрица индексов иконок
//
procedure THITreeViewEx._var_Matrix;
begin
   if not Assigned(Matrix) then begin
      New(Matrix);
      Matrix._Set:= MX_Set;
      Matrix._Get:= MX_Get;
      Matrix._Rows := _mRows; 
      Matrix._Cols := _mCols; 
   end;
   dtMatrix(_Data,Matrix);
end;

function THITreeViewEx.MX_Get;
var   ind:integer;
      item:THandle;
begin
   if (x >= 0) and (x < Length(IconsIdx)) and (y >= 0) and (y < Control.Count) then begin
      item := IndexToHandle(y); 
      case x of
         0: ind := Control.TVItemImage[item]; 
         1: ind := Control.TVItemSelImg[item];
         2: if Assigned(IListSt) and (Control.TVItemStateImg[item] < 14) then
               ind := Control.TVItemStateImg[item]
            else
               ind := I_SKIP;
         3: ind := Control.TVItemOverlay[item]
         else ind := I_SKIP;    
      end;   
      dtInteger(Result,ind);
   end else dtNull(Result);
end;

procedure THITreeViewEx.MX_Set;
var   item:THandle;
begin
   if (x < 0) or (x > High(IconsIdx)) or (y < 0) or (y > Control.Count-1) then exit;
   item := IndexToHandle(y); 
   case x of
      0: Control.TVItemImage[item] := ToInteger(Val); 
      1: Control.TVItemSelImg[item] := ToInteger(Val);
      2: if Assigned(IListSt) and not _prop_CheckBoxes then
            Control.TVItemStateImg[item] := ToInteger(Val);
      3: if _prop_OverlayIcon then Control.TVItemOverlay[item] := ToInteger(Val);
   end;   
   Control.Invalidate;
end;

function THITreeViewEx._mRows;
begin
  Result := Control.Count; 
end;

function THITreeViewEx._mCols;
begin
  Result := Length(IconsIdx); 
end;

//------------------------------------------------------------------------------

end.