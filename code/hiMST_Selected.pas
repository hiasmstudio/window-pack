unit hiMST_Selected;

interface
     
uses Windows, Messages, Kol, Share, Debug, hiMTStrTbl;

type
  THIMST_Selected = class(TDebug)
   private
    SAArray: PArray;
    FData,
    FData_2: TData;
    procedure SA_Set(var Item: TData; var Val: TData);
    function SA_Get(Var Item: TData; var Val: TData):boolean;
    function _Count: integer;
   public
     _prop_MSTControl: IMSTControl;

     destructor Destroy; override;
     procedure _var_SelectArray(var _Data: TData; Index: word);
     procedure _var_AllSelect(var _Data: TData; Index: word);
     procedure _var_SelCount(var _Data: TData; Index: word);
  end;

implementation

destructor THIMST_Selected.Destroy;
begin
  if SAArray <> nil then
    Dispose(SAArray);
  FreeData(@FData);      
  FreeData(@FData_2);
  inherited;
end; 

//SelectArray - Массив флажков выделения
//
procedure THIMST_Selected._var_SelectArray;
begin
  if not Assigned(SAArray) then
    SAArray := CreateArray(SA_Set, SA_Get, _Count, nil);
  dtArray(_Data,SAArray);
end;

procedure THIMST_Selected.SA_Set;
var
  ind: integer;
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;   
  ind := ToIntIndex(Item);
  if (ind >= 0) and (ind < sControl.Count) and (ToInteger(Val) = 1) then
    sControl.LVItemState[ind] := [lvisSelect]
  else if (ind >= 0) and (ind < sControl.Count) and (ToInteger(Val) = 0) then
    sControl.LVItemState[ind] := [];
end;

function THIMST_Selected.SA_Get;
var
  ind: integer;
  sControl: PControl;
begin
  Result:= false;
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;   
  ind:= ToIntIndex(Item);
  if (ind < 0) or (ind > sControl.Count - 1) then exit;
  if lvisSelect in sControl.LVItemState[ind] then  
    dtInteger(Val, 1)
  else
    dtInteger(Val, 0);
  Result:= true;
end;
 
function THIMST_Selected._Count;
var
  sControl: PControl;
begin
  Result := 0;
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint; 
  Result := sControl.Count;
end;

//
// Содержит MT-элементы индексов выделенных пунктов
//
procedure THIMST_Selected._var_AllSelect; // проверен
var
  i, j: integer;
  d: PData;
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;   
  FreeData(@FData);
  FreeData(@FData_2);
  dtNull(FData);
  dtNull(FData_2);
  i := sControl.LVCurItem;
  if sControl.LVSelCount > 0 then
  begin
    repeat
      dtInteger(FData_2, i);
      AddMTData(@FData, @FData_2, d); 
      j := sControl.LVNextSelected(i);
      i := j;
    until j < 0;
  end;
  _Data := FData;
end;

procedure THIMST_Selected._var_SelCount;
var   sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  dtInteger(_data, sControl.LVSelCount);
end;

end.