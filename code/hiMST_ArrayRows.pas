unit hiMST_ArrayRows;

interface

uses Kol, Share, Debug, hiMTStrTbl;

const
  ITM_ADD     = -3;
  ITM_REPLACE = -5;

type
  THIMST_ArrayRows = class(TDebug)
  private
    FData_1: TData;
    Arr: PArray;
    function _Count: integer;
    procedure _aSet(var Item: TData; var Val: TData);
    function _aGet(Var Item: TData; var Val: TData): boolean;
    procedure _aAdd(var Val: TData);
  public
    _prop_MSTControl: IMSTControl;

    destructor Destroy; override;
    procedure _var_Strings(var _Data: TData; Index: word);
    procedure _var_Count(var _Data: TData; Index: word);
    procedure _var_EndIdx(var _Data: TData; Index: word);    
  end;

implementation

destructor THIMST_ArrayRows.Destroy;
begin
  if Arr <> nil then
    Dispose(Arr);
  FreeData(@FData_1);
  inherited;
end;

// Содержит массив строк, где каждая строка - это набор MT-элементов со значениями каждой колонки
//
procedure THIMST_ArrayRows._var_Strings;
begin
  if Arr = nil then
     Arr := CreateArray(_aSet, _aGet, _Count, _aAdd);
  dtArray(_Data, Arr);
end;

procedure THIMST_ArrayRows._aSet;
var
  ind: integer;
  sControl: PControl;
  dt, di: TData;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  ind := ToIntIndex(Item);
  if (ind >= 0) and (ind < sControl.Count) then
  begin
    CopyData(@dt, @val);
    dtInteger(di, ind);
    di.ldata := @dt;
    _prop_MSTControl.actionitm(di, ITM_REPLACE);
    FreeData(@dt);
  end;  
end;

procedure THIMST_ArrayRows._aAdd;
var
  dt: TData;
begin
  if not Assigned(_prop_MSTControl) then exit;
  dt := val;
  _prop_MSTControl.actionitm(dt, ITM_Add);
end;

function THIMST_ArrayRows._aGet;
var
  Index: integer;
  sControl: PControl;
  d, s: PData;
  dt: TData;
  FColorItems: boolean;
  ColCount, Col, Colidx: integer;  

  function AssignIList: boolean;
  begin
    Result := ((_prop_MSTControl.smiconlist <> nil) and (sControl.LVStyle <> lvsIcon)) or
              ((_prop_MSTControl.lgiconlist <> nil) and (sControl.LVStyle = lvsIcon));
  end;

begin
  Result := false;
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  FColorItems := _prop_MSTControl.coloritems; 

  Index := ToIntIndex(Item);
  if not ((Index >= 0) and (Index < sControl.Count) and (sControl.LVColCount > 0)) then exit;
  FreeData(@FData_1);
  dtNull(FData_1);

  ColCount := sControl.LVColCount;
  if AssignIList then
    inc(ColCount);
  if FColorItems then   
    inc(ColCount);               

  Col := 0;
  ColIdx := 0;
  new(s);
  FillChar(s^, sizeof(TData), 0);
TRY
  if Assigned(PData(sControl.LVItemData[Index])) then
    CopyData(s, PData(sControl.LVItemData[Index])); 

  while Col < ColCount do 
  begin
    if (Col = _prop_MSTControl.nidxicon) and AssignIList then
    begin
      dtInteger(dt, sControl.LVItemImageIndex[Index]);
      AddMtData(@FData_1, @dt, d);
    end 
    else if (Col = _prop_MSTControl.ncolorrow) and FColorItems then
    begin
      dtInteger(dt, 0);
      if Assigned(PData(sControl.LVItemData[Index])) then
      begin
        dt := s^;
        dt.ldata := nil;
      end;
      AddMtData(@FData_1, @dt, d);
    end
    else if ColIdx < sControl.LVColCount then
    begin
      dtString(dt, sControl.LVItems[Index, ColIdx]);
      AddMtData(@FData_1, @dt, d);
      inc(ColIdx);
    end;
    inc(Col);
  end;

  if AssignIList and (_prop_MSTControl.nidxicon < 0) then
  begin
    dtInteger(dt, sControl.LVItemImageIndex[Index]);
    AddMtData(@FData_1, @dt, d);
  end;

  if Assigned(PData(sControl.LVItemData[Index])) and (FColorItems and not (_prop_MSTControl.ncolorrow < 0)) and (s^.ldata <> nil) then
    AddMtData(@FData_1, s^.ldata, d)
  else if Assigned(PData(sControl.LVItemData[Index])) and (not FColorItems or (_prop_MSTControl.ncolorrow < 0)) then
    AddMtData(@FData_1, s, d);

  FreeData(@Val);
  dtNull(Val);
  CopyData(@Val, @FData_1);

  Result := true;

FINALLY
  case s^.Data_type of
    data_null: ;
    else
      FreeData(s);
  end;    
  Dispose(s);
END;

end;

//_Count - Счетчик строк
//
function THIMST_ArrayRows._Count;
var
  sControl: PControl;
begin
  Result := 0;
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  Result := sControl.Count;
end;

// Содержит количество строк в таблице
//
procedure THIMST_ArrayRows._var_Count;
var
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  dtInteger(_Data, sControl.Count);
end;


// Содержит индекс последний строки в таблице
//
procedure THIMST_ArrayRows._var_EndIdx;
var
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  dtInteger(_Data, sControl.Count - 1);
end;

end.