unit hiMST_CheckBoxes;

interface
     
uses Windows, Messages, Kol, Share, Debug, hiMTStrTbl;

type
  THIMST_CheckBoxes = class(TDebug)
   private
    FData,
    FData_2: TData;
    CBArray: PArray;
    function _Count:integer;
    procedure CB_Set(var Item:TData; var Val:TData);
    function CB_Get(Var Item:TData; var Val:TData):boolean;
   public
     _prop_IndexRow: integer;
     _prop_MSTControl:IMSTControl;

     _event_onCheckBox: THI_Event;

     _data_Mode,
     _data_IndexRow: THI_Event;

     destructor Destroy; override;
     procedure _work_doCheckBox(var _Data: TData; Index: word);
     procedure _var_AllCheck(var _Data: TData; Index: word);
     procedure _var_CheckBoxes(var _Data: TData; Index: word);
  end;

implementation

destructor THIMST_CheckBoxes.Destroy;
begin
  if CBArray <> nil then
    Dispose(CBArray);
  FreeData(@FData);      
  FreeData(@FData_2);
  inherited;
end; 

// Снимает/устанавливает флажок
// ARG(IndexRow(-1 - All), Mode(0 - UnSelect, 1 - Select))
//
procedure THIMST_CheckBoxes._work_doCheckBox; // проверен
var
  idx, val: integer;
  sControl: PControl;  
begin
//  if _IsNULL(_Data) then exit;
  
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint; 
  
  idx := ReadInteger(_Data, _data_IndexRow, _prop_IndexRow);
  val := ReadInteger(_Data, _data_Mode);
  if (idx >= -1) and (idx < sControl.Count ) then
  begin
    sControl.LVItemStateImgIdx[idx] := val + 1;
    _hi_onEvent(_event_onCheckBox);
  end;  
end;

// Содержит MT-элементы индексов пунктов с установленными флажками
// ARG(IndexRowCheck1, IndexRowCheck2 ... IndexRowCheckN)
//
procedure THIMST_CheckBoxes._var_AllCheck; // проверен
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
  if sControl.Count > 0 then
  begin
    for i := 0 to sControl.Count - 1 do
    begin
      j := sControl.LVItemStateImgIdx[i];
      if j > 1 then 
        dtInteger(FData_2, i)
      else
        dtNull(FData_2); 
      AddMTData(@FData, @FData_2, d);
    end;
  end;
  _Data := FData;
end;

// Массив значений флажков (0 - не установлен, 1 - установлен)
//
procedure THIMST_CheckBoxes._var_CheckBoxes;
begin
   if not Assigned(CBArray) then
      CBArray := CreateArray(CB_Set, CB_Get, _Count, nil);
   dtArray(_Data, CBArray);
end;

procedure THIMST_CheckBoxes.CB_Set(var Item:TData; var Val:TData);
var
  ind: integer;
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint; 
  ind := ToIntIndex(Item);
  if (ind >= 0) and (ind < sControl.Count) then
    sControl.LVItemStateImgIdx[ind] := toInteger(Val) + 1;
end;

function THIMST_CheckBoxes.CB_Get(Var Item:TData; var Val:TData):boolean;
var
  ind: integer;
  sControl: PControl;
begin
  Result := false;
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint; 
  ind:= ToIntIndex(Item);
  if (ind < 0) or (ind > sControl.Count - 1) then exit;
  dtInteger(Val, sControl.LVItemStateImgIdx[ind] - 1);
  Result := true;
end;

function THIMST_CheckBoxes._Count;
var
  sControl: PControl;
begin
  Result := 0;
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint; 
  Result := sControl.Count;
end;

end.