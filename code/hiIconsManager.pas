unit hiIconsManager;

interface
     
uses Messages,Windows,Kol,Share,Debug;

const
  SKIP = -1;

type
  TIIconsManager = record
    iconList   : function : PImageList of object;
    imgsz      : function: byte of object;
    setprop    : procedure of object;
    clearicons : procedure of object;
    counticons : function: integer of object;
    geticon    : function(Var Item: TData; var Val: TData):boolean of object;
    addicon    : procedure(var Val: TData) of object;
    seticon    : procedure(var Item: TData; var Val: TData) of object;
    iconarray  : procedure(var _Data: TData) of object;    
  end;
  IIconsManager = ^TIIconsManager;

  THIIconsManager = class(TDebug)
  private
    FBkColor: TColor;
    Icon: PIcon;
    fImgSize: byte;
    im: TIIconsManager;
    IList: PImageList;
    ICArray: PArray;
    function imgsz: byte;
    function iconList: PImageList;     
    procedure SetIListProp; 
    procedure SetIcons(const value: PStrListEx);
    procedure SetSize(const value: integer);
    procedure _SetIcon(var Item: TData; var Val: TData);
    function _GetIcon(Var Item: TData; var Val: TData):boolean;
    procedure _AddIcon(var Val: TData);
    function  _CountIcons: integer;
    procedure ClearIcons;     
    procedure IconArray(var _Data: TData);
  public
    _prop_Name:string;

    constructor Create;
    destructor Destroy;override;
    function getInterfaceIcons:IIconsManager;
    property _prop_ImgBkColor:TColor write FBkColor;
    property _prop_Icons:PStrListEx write SetIcons;
    property _prop_ImgSize:integer write SetSize;
    procedure _work_doClearIcons(var _Data:TData; Index:word);
    procedure _work_doImgBkColor(var _Data:TData; Index:word);         
    procedure _var_IconArray(var _Data:TData; Index:word);
    procedure _var_CountIcons(var _Data:TData; Index:word);
    procedure _var_EndIdxIcons(var _Data:TData; Index:word);     
    procedure _var_ImgSize(var _Data:TData; Index:word);          
 end;

implementation

procedure THIIconsManager.SetSize;
begin
  fImgSize := value;
  if fImgSize = 0 then
    fImgSize := GetSystemMetrics(SM_CXICON);
end;

//--------   Управление основными свойствами списка иконок   ----------

procedure THIIconsManager.SetIListProp;
begin
  IList.BkColor := FBkColor;
  IList.Colors := ilcColor24;
  IList.ImgWidth := fImgSize;
  IList.ImgHeight := fImgSize;
  IList.DrawingStyle := [dsTransparent];
end;

procedure THIIconsManager.SetIcons;
var
  i: integer;
begin
  IList:= NewImageList(nil);
  SetIListProp;
  for i:= 0 to Value.Count - 1 do
    IList.AddIcon(Value.Objects[i]);   
end;

constructor THIIconsManager.Create;
begin
  inherited;
  im.imgsz      := imgsz;
  im.iconList   := iconList;
  im.setprop    := SetIListProp;
  im.clearicons := ClearIcons;
  im.counticons := _CountIcons;
  im.geticon    := _GetIcon;
  im.seticon    := _SetIcon;
  im.addicon    := _AddIcon;
  im.iconarray  := IconArray;   
  Icon:= NewIcon;   
end;

destructor THIIconsManager.Destroy;
begin
  Icon.free;
  if Assigned(IList) then
    IList.free;
  if ICArray <> nil  then
    Dispose(ICArray);   
  inherited;
end;

function THIIconsManager.getInterfaceIcons;
begin
  Result := @im;
end;

function THIIconsManager.imgsz;
begin
  Result := fImgSize;
end;

function THIIconsManager.iconList;
begin
  if not Assigned(IList) then
  begin
    IList := NewImageList(nil);
    SetIListProp;
  end;
  Result:= IList;  
end;

//-------------------   Доступ к массиву иконок   ---------------------

//IconArray - Массив иконок
//
procedure THIIconsManager._var_IconArray;
begin
  IconArray(_Data); 
end;

procedure THIIconsManager.IconArray;
begin
  if not Assigned(Ilist) then
    IList := NewImageList(nil);
  if not Assigned(ICArray) then
    ICArray := CreateArray(_SetIcon, _GetIcon, _CountIcons, _AddIcon);
  dtArray(_Data, ICArray);
end;

procedure THIIconsManager._SetIcon;
var
  ind: integer;
begin
  if not Assigned(Ilist) then
    IList := NewImageList(nil);
  SetIListProp;
  ind := ToIntIndex(Item);
  if (ind >= 0) and (ind < IList.Count) and _IsIcon(Val) then
    IList.ReplaceIcon(ind, ToIcon(val).handle);
end;

function THIIconsManager._GetIcon;
var
  ind: integer;
begin
  Result := false;
  if not Assigned(Ilist) then
    IList := NewImageList(nil);
  SetIListProp;
  ind := ToIntIndex(Item);
  if (ind >= 0) and (ind < IList.Count) then
  begin
    Icon.Clear;
    Icon.Handle:= IList.ExtractIcon(ind);
    dtIcon(Val, Icon);
    Result:= true;
  end;
end;

function THIIconsManager._CountIcons:integer;
begin
  Result := 0;
  if not Assigned(Ilist) then exit;
  Result := IList.Count;
end;

procedure THIIconsManager._AddIcon;
begin
  if not Assigned(Ilist) then
    IList := NewImageList(nil);
  SetIListProp;
  if _IsIcon(Val) then
    IList.AddIcon(ToIcon(Val).Handle);
end;

procedure THIIconsManager._work_doClearIcons;
begin
  ClearIcons;
end;

procedure THIIconsManager._work_doImgBkColor;
begin
  FBkColor := ToInteger(_Data);
  SetIListProp;
end;

procedure THIIconsManager.ClearIcons;
begin
   if not Assigned(Ilist) or (Ilist.Count = 0) then exit;
   repeat
     IList.Delete(Ilist.Count - 1);
   until Ilist.Count = 0;
end;

// Количество иконок в списке иконок
//
procedure THIIconsManager._var_CountIcons;
begin
  dtInteger(_Data, _CountIcons);
end;

// Размер иконок в списке иконок
//
procedure THIIconsManager._var_ImgSize;
begin
  dtInteger(_Data, fImgSize);
end;

//EndIdxIcons - Содержит индекс последней иконки в списке иконок
//
procedure THIIconsManager._var_EndIdxIcons;
begin
  if _CountIcons <> 0 then
    dtInteger(_Data, _CountIcons - 1)
end;

end.