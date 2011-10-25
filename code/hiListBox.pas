unit hiListBox;

interface

{$I share.inc}

uses Kol,Share,LWinList,WIndows,Messages,hiBoxDrawManager,hiIconsManager,hiIndexManager;

const
  MODE_COMBOBOX      = 0;
  MODE_LISTBOX       = 1;
  MODE_LISTBOXTRANS  = 2;

type
  THIListBox = class(THILWinList)
    private
      Arr,ValArr:PArray;
      fIdxMgr:IIndexManager;
      fBoxDrawManager:IBoxDrawManager;
      fIconsManager:IIconsManager;
      procedure Select(idx:integer); override;
      function  _OnMeasureItem( Sender: PObj; Idx: Integer ):Integer;
      function  _OnDrawItem(Sender: PObj; DC: HDC; const Rect: TRect; ItemIdx: Integer;
                            DrawAction: TDrawAction; ItemState: TDrawState ): Boolean;
      procedure _arr_set(var Item:TData; var Val:TData);
      function  _arr_get(Var Item:TData; var Val:TData):boolean;
      function  _arr_count:integer;
      procedure _val_arr_set(var Item:TData; var Val:TData);
      function  _val_arr_get(Var Item:TData; var Val:TData):boolean;
    
      procedure SetIndexManager(value:IIndexManager);
      procedure SetInitBoxDrawManager(value:IBoxDrawManager);
      procedure SetIconsManager(value:IIconsManager);
    protected
      function  Add(const Text:string):integer; override;
      procedure SetStringsBefore(len:cardinal); override;
    public
      _prop_Strings:string;
      _prop_Sort:boolean;
      _prop_MultiSelect:boolean;
      _prop_ItemHeight:integer;

      procedure Init; override;
      destructor Destroy; override;
      procedure _work_doSelectAll(var _Data:TData; Index:word);
      procedure _work_doEnsureVisible(var _Data:TData; Index:word);      
      procedure _work_doUp(var _Data:TData; Index:word);
      procedure _work_doDown(var _Data:TData; Index:word);
      procedure _work_doInsert(var _Data:TData; Index:word);      
      procedure _var_Index(var _Data:TData; Index:word);
      procedure _var_SelectArray(var _Data:TData; Index:word);
      procedure _var_ValueArray(var _Data:TData; Index:word);
  
      property _prop_IndexManager:IIndexManager read fIdxMgr write SetIndexManager;
      property _prop_BoxDrawManager:IBoxDrawManager read fBoxDrawManager write SetInitBoxDrawManager;
      property _prop_IconsManager:IIconsManager read fIconsManager write SetIconsManager;     
  end;

implementation

procedure THIListBox.Init;
var  Fl:TListOptions;
begin
  fl := [loNoIntegralHeight, loNoExtendSel];
  if _prop_Sort then include(Fl,loSort);
  if _prop_MultiSelect then include(Fl,loMultiSelect);
  if ManFlags and $8 > 0 then include(Fl,loOwnerDrawFixed);
  Control := NewListbox(FParent,fl);
  Control.OnMeasureItem:= _OnMeasureItem;
  inherited;
  SetStrings(_prop_Strings);
  Control.OnSelChange := _OnClick;
  if ManFlags and $8 > 0 then Control.OnDrawItem  := _OnDrawItem;
  SendMessage(Control.GetWindowHandle,LB_SETHORIZONTALEXTENT, 200, 0);
  //ShowScrollBar(Control.GetWindowHandle,SB_HORZ,true);
end;

destructor THIListBox.Destroy;
begin
  if Arr <> nil then dispose(Arr);
  if ValArr <> nil then dispose(ValArr);
  if (Assigned(_prop_IndexManager)) then
    _prop_IndexManager.removeControl(Control);
  inherited;   
end; 

procedure THIListBox.SetIndexManager;
begin
  if value <> nil then
  begin
    fIdxMgr := value;  
    _prop_IndexManager.addControl(Control);
  end;
end;

procedure THIListBox.SetInitBoxDrawManager;
begin
  if value <> nil then fBoxDrawManager := value;
end;

procedure THIListBox.SetIconsManager;
begin
  if value <> nil then 
    fIconsManager := value;
end;

function THIListBox._OnDrawItem;
var  idx : integer;
     imgsz : integer;
     cbRect : TRect;
     IList : PImageList;
begin
   Result := false;
   if Assigned(_prop_BoxDrawManager) then begin
      Result := _prop_BoxDrawManager.draw(Sender, DC, Rect, ItemIdx, ItemState, false, PControl(Sender).Font.Handle);
      if (Assigned(_prop_IndexManager)) and (Assigned(_prop_IconsManager)) then
      begin
         IList := _prop_IconsManager.iconList;
         if not Assigned(IList) then exit;
         cbRect := Rect;
         idx := _prop_IndexManager.outidx(ItemIdx);
         imgsz := _prop_IconsManager.imgsz;         
         with cbRect do
         begin
            Top:= Top + (Bottom - Top - imgsz) div 2;
            Left:= _prop_BoxDrawManager.shift;
            Bottom:= Top + imgsz; 
            Right:= Left + imgsz;
         end;
         if (idx < 0) or (idx > IList.Count - 1) then
           idx := SKIP;      
         IList.StretchDraw(idx, DC, cbRect);   
      end;
   end;
end;

function THIListBox._OnMeasureItem;
begin
  Result := _prop_ItemHeight;
end;

procedure THIListBox._work_doSelectAll;
var  a:boolean; i:integer;
begin
  a := ReadBool(_Data);
  if _prop_MultiSelect then
    Control.ItemSelected[-1] := a
  else for i := 0 to Control.Count-1 do
    Control.ItemSelected[i] := a;
end;

procedure THIListBox._work_doUp;
var
  str2: string;
  data2: integer;
begin
  if Control.CurIndex <= 0 then exit;

  str2 := Control.Items[Control.CurIndex - 1];
  data2 := Control.ItemData[Control.CurIndex - 1];
  
  Control.Items[Control.CurIndex - 1] := Control.Items[Control.CurIndex];
  Control.ItemData[Control.CurIndex - 1] := Control.ItemData[Control.CurIndex];    

  Control.Items[Control.CurIndex] := str2;
  Control.ItemData[Control.CurIndex] := data2;

  Control.CurIndex := Control.CurIndex - 1;
end;

procedure THIListBox._work_doDown;
var
  str2: string;
  data2: integer;
begin
  if (Control.CurIndex = (Control.Count - 1)) or (Control.CurIndex < 0) then exit;

  str2 := Control.Items[Control.CurIndex + 1];
  data2 := Control.ItemData[Control.CurIndex + 1];
  
  Control.Items[Control.CurIndex + 1] := Control.Items[Control.CurIndex];
  Control.ItemData[Control.CurIndex + 1] := Control.ItemData[Control.CurIndex];    

  Control.Items[Control.CurIndex] := str2;
  Control.ItemData[Control.CurIndex] := data2;

  Control.CurIndex := Control.CurIndex + 1;
end;

procedure THIListBox.Select;
begin
  if  _prop_MultiSelect then
    Control.ItemSelected[idx] := not Control.ItemSelected[idx]
  else inherited;
end;

procedure THIListBox._work_doEnsureVisible;
begin
  Control.Perform(LB_SETTOPINDEX, ToInteger(_Data), 0);
end;

procedure THIListBox._var_Index;
begin
  dtInteger(_Data,Control.CurIndex);
end;

procedure THIListBox._arr_set;
var  ind:integer;
begin
  ind := ToIntIndex(Item);
  if(ind >=0)and(ind < Control.Count)then
    Control.ItemSelected[ind] := ReadBool(Val);
end;

function THIListBox._arr_get;
var  ind:integer;
begin
  ind := ToIntIndex(Item);
  Result := (ind >=0 )and(ind < Control.Count);
  if Result then
    dtInteger(Val,byte(Control.ItemSelected[ind]));
end;

function THIListBox._arr_count;
begin
  Result := Control.Count;
end;

procedure THIListBox._val_arr_set;
var  ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >=0 )and(ind < Control.Count)then
     Control.ItemData[ind] := ToInteger(Val);
end;

function THIListBox._val_arr_get;
var  ind:integer;
begin
  ind := ToIntIndex(Item);
  Result := (ind >=0 )and(ind < Control.Count);
  if Result then
    dtInteger(Val,Control.ItemData[ind]);
end;

procedure THIListBox._var_SelectArray;
begin
  if Arr = nil then
    Arr := CreateArray(_arr_set,_arr_get,_arr_count,nil);
  dtArray(_Data,Arr);
end;

procedure THIListBox._var_ValueArray;
begin
  if ValArr = nil then
    ValArr := CreateArray(_val_arr_set,_val_arr_get,_arr_count,nil);
  dtArray(_Data,ValArr);
end;

procedure THIListBox.SetStringsBefore;
begin
   inherited;
   Control.Perform(LB_INITSTORAGE, 0, len);
end;

function  THIListBox.Add(const Text:string):integer;
begin
   Result := Control.Perform(LB_ADDSTRING, 0, cardinal(PChar(Text)));
end;

procedure THIListBox._work_doInsert;
var
  ind: integer;
  dt: TData;
begin
   ind := ToIntIndex(_Data);
   if (ind < -1) or (ind > Control.Count) then
     exit
   else if ind = -1 then
     ind := Control.Count;
  Control.Insert(ind, ReadString(_Data, _data_Str));
  if _prop_SelectAdd then Control.CurIndex := ind;
  dt := ReadData(_Data,_data_Value);
  Control.ItemData[ind] := ToInteger(dt);  
  _hi_CreateEvent(_Data,@_event_onChange);
end;

end.