unit hiComboBox;

interface

{$I share.inc}

uses Kol,Share,LWinList,Windows,Messages,hiBoxDrawManager,hiIconsManager,hiIndexManager;

const
  MODE_COMBOBOX = 0;
  MODE_LISTBOX  = 1;

type
  THIComboBox = class(THILWinList)
    private
      fIdxMgr:IIndexManager;
      fBoxDrawManager:IBoxDrawManager;
      fIconsManager:IIconsManager;
      function  _OnMeasureItem( Sender: PObj; Idx: Integer ):Integer;
      function  _OnDrawItem(Sender: PObj; DC: HDC; const Rect: TRect; ItemIdx: Integer;
                            DrawAction: TDrawAction; ItemState: TDrawState ): Boolean;
      procedure SetIndexManager(value:IIndexManager);
      procedure SetInitBoxDrawManager(value:IBoxDrawManager);
      procedure SetIconsManager(value:IIconsManager);        
    protected
      function  Add(const Text:string):integer; override;
      procedure SetStringsBefore(len:cardinal); override;
    public
      _prop_ReadOnly:byte;
      _prop_Text:string;
      _prop_Strings:string;
      _prop_Sort:boolean;
      _prop_ItemHeight:integer;
    
      procedure Init; override;
      destructor Destroy; override;
      procedure _work_doEditText(var _Data:TData; Index:word);
      procedure _var_EditText(var _Data:TData; Index:word);
      procedure _var_Index(var _Data:TData; Index:word);

      property _prop_IndexManager:IIndexManager read fIdxMgr write SetIndexManager;
      property _prop_BoxDrawManager:IBoxDrawManager read fBoxDrawManager write SetInitBoxDrawManager;
      property _prop_IconsManager:IIconsManager read fIconsManager write SetIconsManager;      
  end;

implementation

procedure THIComboBox.Init;
var  Flags:TComboOptions;
begin
  Flags := [{coNoIntegralHeight}];
  if (_prop_ReadOnly = 0) then include(Flags,coReadOnly);
  if _prop_Sort then include(Flags,coSort);
  if ManFlags and $8 > 0 then include(Flags,coOwnerDrawFixed);
  Control := NewCombobox(FParent,Flags);
  Control.OnMeasureItem:= _OnMeasureItem;    
  inherited;
  SetStrings(_prop_Strings);
  with Control{$ifndef F_P}^{$endif} do
  begin
    Text := _prop_Text;
    OnSelChange := _OnClick;
    if ManFlags and $8 > 0 then OnDrawItem  := _OnDrawItem;
    if (Count > 0) and (_prop_ReadOnly = 0) then CurIndex := 0; 
  end;
end;

destructor THIComboBox.Destroy;
begin
  if (Assigned(_prop_IndexManager)) then
    _prop_IndexManager.removeControl(Control);
  inherited;
end;     

procedure THIComboBox.SetIndexManager;
begin
  if value <> nil then
  begin
    fIdxMgr := value;  
    _prop_IndexManager.addControl(Control);
  end;
end;

procedure THIComboBox.SetInitBoxDrawManager;
begin
  if value <> nil then fBoxDrawManager := value;
end;

procedure THIComboBox.SetIconsManager;
begin
  if value <> nil then 
    fIconsManager := value;
end;

procedure THIComboBox._work_doEditText;
begin
  Control.Caption := ToString(_Data);
end;

procedure THIComboBox._var_EditText;
begin
  dtString(_Data, Control.Caption);
end;

procedure THIComboBox._var_Index;
begin
  dtInteger(_Data, Control.CurIndex);
end;

function THIComboBox._OnDrawItem;
var  idx : integer;
     imgsz : integer;
     cbRect : TRect;
     IList : PImageList;
begin
  Result := false;
  if Assigned(_prop_BoxDrawManager) then
  begin
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
        if (odsComboboxEdit in ItemState) then inc(Left);
        Bottom:= Top + imgsz; 
        Right:= Left + imgsz;
      end;
      if (idx < 0) or (idx > IList.Count - 1) then idx := SKIP;      
      IList.StretchDraw(idx, DC, cbRect);   
    end;
  end;
end;

function THIComboBox._OnMeasureItem;
begin
  Result := _prop_ItemHeight;
end;

procedure THIComboBox.SetStringsBefore;
begin
   inherited;
   Control.Perform(CB_INITSTORAGE, 0, len);
end;

function  THIComboBox.Add(const Text:string):integer;
begin
   Result := Control.Perform(CB_ADDSTRING, 0, cardinal(PChar(Text)));
   if (_prop_ReadOnly = 0) and (Control.CurIndex < 0) then Control.CurIndex := 0;    
end;

end.