unit hiArrayFind;

interface

uses Windows, Kol, Share, Debug;

type
  THIArrayFind = class(TDebug)
  private
    ArrIn: PArray;
    ItemIdx: integer;
    function GetArrayVal(idx: integer): TData;
  public
    _prop_ArrayType: byte;
    _prop_Index: integer;
    _prop_Value: TData;
    _prop_CaseSensitive: boolean;
    _prop_Partial: boolean;    
    _event_onFind: THI_Event;
    _data_Array: THI_Event;
    _data_Index: THI_Event;
    _data_Value: THI_Event;

    procedure _work_doFind0(var _Data: TData; Index: word); // String
    procedure _work_doFind1(var _Data: TData; Index: word); // Integer
    procedure _work_doFind2(var _Data: TData; Index: word); // Real
    procedure _work_doCaseSensitive(var _Data: TData; Index: word);
    procedure _work_doPartial(var _Data: TData; Index: word);        
    procedure _var_ItemIdx(var _Data: TData; Index: word);
  end;

implementation

procedure THIArrayFind._work_doCaseSensitive;
begin
  _prop_CaseSensitive := ReadBool(_Data);
end;

procedure THIArrayFind._work_doPartial;
begin
  _prop_Partial := ReadBool(_Data);
end;

function THIArrayFind.GetArrayVal;
var
  ind, dt: TData;
begin
  ind := _DoData(idx);
  ArrIn._Get(ind, dt);
  Result := dt;
end;

procedure THIArrayFind._work_doFind0;
var
  i, idx: integer;
  s: string;
  S1, S2: PChar;
  dt: TData;
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;
  idx := ReadInteger(_Data, _data_Index, _prop_Index);
  dt := ReadData(_Data, _data_Value, @_prop_Value);
  if idx < 0 then exit;  

  s := ToString(dt) + #0;
  S1 := PChar(s);
  if not _prop_CaseSensitive  and (Length(S1) <> 0) then
    CharLower(S1);

  ItemIdx := -1;
  for i := idx to ArrIn._Count - 1 do
  begin
    S2 := PChar(ToString(GetArrayVal(i)));
    if not _prop_CaseSensitive and (Length(S2) <> 0) then CharLower(S2);
    if _prop_Partial and (Pos(S1, S2) <> 0) then
    begin
      ItemIdx := i;
      break;
    end
    else if StrComp(S1, S2) = 0 then
    begin
      ItemIdx := i;
      break;
    end;
  end;  
  _hi_CreateEvent(_Data, @_event_onFind, ItemIdx);
end;

procedure THIArrayFind._work_doFind1;
var
  i, idx, v: integer;
  dt: TData;
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;
  idx := ReadInteger(_Data, _data_Index, _prop_Index);
  dt := ReadData(_Data, _data_Value, @_prop_Value);
  if idx < 0 then exit;  

  v := ToInteger(dt);
  ItemIdx := -1;
  for i := idx to ArrIn._Count - 1 do
    if (v = ToInteger(GetArrayVal(i))) then
    begin
      ItemIdx := i;
      break;
    end;
  _hi_CreateEvent(_Data, @_event_onFind, ItemIdx);
end;

procedure THIArrayFind._work_doFind2;
var
  i, idx: integer;
  r: real;
  dt: TData;
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;
  idx := ReadInteger(_Data, _data_Index, _prop_Index);
  dt := ReadData(_Data, _data_Value, @_prop_Value);
  if idx < 0 then exit;  

  r := ToReal(dt);
  ItemIdx := -1;
  for i := idx to ArrIn._Count - 1 do
    if (r = ToReal(GetArrayVal(i))) then
    begin
      ItemIdx := i;
      break;
    end;
  _hi_CreateEvent(_Data, @_event_onFind, ItemIdx);
end;

procedure THIArrayFind._var_ItemIdx;
begin
  dtInteger(_Data, ItemIdx);
end;

end.