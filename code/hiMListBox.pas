unit hiMListBox;

interface

uses Windows, Kol, Share, Debug, Win, hiDS_StaticData, hiBoxDrawManager, hiIconsManager, hiIndexManager;

type
  THIMListBox = class(THIWin)
   private
    fIdxMgr:IIndexManager;
    fBoxDrawManager:IBoxDrawManager;
    fIconsManager:IIconsManager;

    fCapIndex:integer;
    fInitIndex:boolean;
    fCache:TDataArray;
    function  _OnMeasureItem( Sender: PObj; Idx: Integer ):Integer;
    function  _OnDrawItem(Sender: PObj; DC: HDC; const Rect: TRect; ItemIdx: Integer;
                          DrawAction: TDrawAction; ItemState: TDrawState ): Boolean;
    
    procedure _OnClick(Obj:PObj);
    procedure SetIndexManager(value:IIndexManager);
    procedure SetInitBoxDrawManager(value:IBoxDrawManager);
    procedure SetIconsManager(value:IIconsManager);

   public
    _prop_DataSource:IDS_Table;
    _prop_CaptionField:string;
    _prop_DataType:byte;
    _prop_DataField:string;
    _prop_ItemHeight:integer;

    _event_onSelectChange:THI_Event;
    
    procedure Init; override;
    destructor Destroy; override;
    procedure _work_doRefresh(var _Data:TData; index:word);
    procedure _work_doCaptionField(var _Data:TData; index:word);
    procedure _work_doDataType(var _Data:TData; index:word);
    procedure _work_doDataField(var _Data:TData; index:word);            

    property _prop_IndexManager:IIndexManager read fIdxMgr write SetIndexManager;
    property _prop_BoxDrawManager:IBoxDrawManager read fBoxDrawManager write SetInitBoxDrawManager;
    property _prop_IconsManager:IIconsManager read fIconsManager write SetIconsManager;     

  end;

implementation

destructor THIMListBox.Destroy;
begin
  if (Assigned(_prop_IndexManager)) then
    _prop_IndexManager.removeControl(Control);
  inherited;   
end; 

procedure THIMListBox.Init;
var  Fl:TListOptions;
begin
   Fl := [loNoIntegralHeight, loNoExtendSel];
   if ManFlags and 16 > 0 then include(Fl,loOwnerDrawFixed);
   Control := NewListBox(FParent, Fl);
   Control.OnSelChange := _OnClick;
   Control.OnMeasureItem:= _OnMeasureItem;
   inherited;
   if ManFlags and 16 > 0 then Control.OnDrawItem  := _OnDrawItem;
end;

procedure THIMListBox._OnClick(Obj:PObj);
var dt:TData;
begin
   case _prop_DataType of
    0: dtString(dt, Control.Items[Control.CurIndex]);
    1: dtInteger(dt, Control.CurIndex);
    2: dt := PData(Control.ItemData[Control.CurIndex])^; 
   end;
   _hi_onEvent(_event_onSelectChange, dt);
end;

procedure THIMListBox._work_doRefresh;
var id:pointer;
    data:TDataArray;
    di,i:integer;    
begin
  Control.Clear;
  if assigned(_prop_DataSource) then
   begin
     id := _prop_DataSource.init();
     di := 0;
     if not fInitIndex then
      begin
         fInitIndex := true;
         with _prop_DataSource.columns(id){$ifndef F_P}^{$endif} do
          begin
            fCapIndex := indexOf(_prop_CaptionField);
            if _prop_DataType = 2 then
             begin
               di := indexOf(_prop_DataField);
               SetLength(fCache, _prop_DataSource.count(id)); 
             end;
          end;
      end; 
     i := 0;
     while _prop_DataSource.row(id, data) do
      begin
        Control.Add(ToString(data[fCapIndex]));
        if _prop_DataType = 2 then
         begin
           dtData(fCache[i], data[di]);
           Control.ItemData[i] := integer(@fCache[i]);
           inc(i);
         end;
      end;
     _prop_DataSource.close(id); 
   end;
end;

procedure THIMListBox._work_doCaptionField;
begin
  _prop_CaptionField := ToString(_Data);
  fInitIndex := false;
end;

procedure THIMListBox._work_doDataType;
begin
  _prop_DataType := ToInteger(_Data);
  fInitIndex := false;  
end;

procedure THIMListBox._work_doDataField;
begin
  _prop_DataField := ToString(_Data);
  fInitIndex := false;  
end;            

procedure THIMListBox.SetIndexManager;
begin
  if value <> nil then
  begin
    fIdxMgr := value;  
    _prop_IndexManager.addControl(Control);
  end;
end;

procedure THIMListBox.SetInitBoxDrawManager;
begin
  if value <> nil then fBoxDrawManager := value;
end;

procedure THIMListBox.SetIconsManager;
begin
  if value <> nil then 
    fIconsManager := value;
end;

function THIMListBox._OnDrawItem;
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

function THIMListBox._OnMeasureItem;
begin
  Result := _prop_ItemHeight;
end;

end.
