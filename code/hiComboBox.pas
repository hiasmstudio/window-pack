unit hiComboBox;

interface

{$I share.inc}

uses Kol,Share,LWinList,Windows,Messages,hiBoxDrawManager,hiIconsManager,hiIndexManager;

const
  MODE_COMBOBOX = 0;
  MODE_LISTBOX  = 1;
  CB_SETMINVISIBLE = 5889;

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
      procedure _OnChange(Obj:PObj);
      procedure _OnDropDown( Sender: PObj );  // === DropDownCount
    protected
      function  Add(const Text:string):integer; override;
      procedure SetStringsBefore(len:cardinal); override;
    public
      _prop_ReadOnly:byte;
      _prop_Text:string;
      _prop_Strings:string;
      _prop_Sort:boolean;
      _prop_ItemHeight:integer;     
      _prop_DropDownCount:integer; // === DropDownCount
    
      _event_onChangeText: THI_Event;
      procedure Init; override;
      destructor Destroy; override;
      procedure _work_doEditText(var _Data:TData; Index:word);
      procedure _var_EditText(var _Data:TData; Index:word);
      procedure _var_Index(var _Data:TData; Index:word);
      procedure _work_doDropDownCount(var _Data:TData; Index:word);

      property _prop_IndexManager:IIndexManager read fIdxMgr write SetIndexManager;
      property _prop_BoxDrawManager:IBoxDrawManager read fBoxDrawManager write SetInitBoxDrawManager;
      property _prop_IconsManager:IIconsManager read fIconsManager write SetIconsManager;      
  end;

implementation

var
  ComCtlVersion: integer = 0;

function GetComCtlVersion: Integer;
var
  FileName: string;
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  FI: PVSFixedFileInfo;
  VerSize: DWORD;
begin
  if ComCtlVersion = 0 then
  begin
    // GetFileVersionInfo modifies the filename parameter data while parsing.
    // Copy the string const into a local variable to create a writeable copy.
    FileName := 'comctl32.dll';
    InfoSize := GetFileVersionInfoSize(PChar(FileName), Wnd);
    if InfoSize <> 0 then
    begin
      GetMem(VerBuf, InfoSize);
      try
        if GetFileVersionInfo(PChar(FileName), Wnd, InfoSize, VerBuf) then
          if VerQueryValue(VerBuf, '\', Pointer(FI), VerSize) then
            ComCtlVersion := FI.dwFileVersionMS;
      finally
        FreeMem(VerBuf);
      end;
    end;
  end;
  Result := ComCtlVersion;
end;


procedure THIComboBox.Init;
var  Flags:TComboOptions;
begin
  Flags := [{coNoIntegralHeight}];
  if (_prop_ReadOnly = 0) then include(Flags,coReadOnly);
  if _prop_Sort then include(Flags,coSort);
  if ManFlags and $8 > 0 then include(Flags,coOwnerDrawFixed);
  Control := NewCombobox(FParent,Flags);
  Control.OnMeasureItem:= _OnMeasureItem; 
  
  // === DropDownCount === //
   Control.OnDropDown := _OnDropDown;
  // === ============ === //
     
  inherited;
  SetStrings(_prop_Strings);
  with Control{$ifndef F_P}^{$endif} do
  begin
    if (_prop_ReadOnly <> 0) then OnChange := _OnChange;
    Text := _prop_Text;
    OnSelChange := _OnClick;
    if ManFlags and $8 > 0 then OnDrawItem  := _OnDrawItem;
    if (Count > 0) and (_prop_ReadOnly = 0) then CurIndex := 0; 
  end;
end;

// === DropDownCount === //
procedure THIComboBox._OnDropDown( Sender: PObj );
var
  CB: PControl;
  IC: Integer;
  H: Integer;
begin
  CB := PControl( Sender );
  IC := CB.Count;
  if IC > _prop_DropDownCount then IC := _prop_DropDownCount;
  if IC < 1 then IC := 1;
  
  if (GetComCtlVersion and $FFFF0000) shr 16 >= 6 then
    CB.Perform(CB_SETMINVISIBLE, IC, 0);   
  begin
    H := CB.Perform(CB_GETITEMHEIGHT, 0, 0);
    MoveWindow(CB.Handle, CB.Left, CB.Top, CB.Width, H * (IC + 2) + 2, false);
  end
end;

procedure THIComboBox._work_doDropDownCount;
begin
  _prop_DropDownCount := ToInteger(_Data); 
end;

// === ============ === //

procedure THIComboBox._OnChange;
begin
  _hi_onEvent(_event_onChangeText, Control.Caption);
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
  _hi_onEvent(_event_onChangeText, Control.Caption);  
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