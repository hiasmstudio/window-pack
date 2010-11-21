unit hiArraySum;

interface

uses Windows, Kol, Share, Debug;

type
  PReal = ^Real;

type  
  THIArraySum = class(TDebug)
  private
    ArrIn: PArray;
    s: string;
    v: integer;
    r: real;
  public
    _prop_ArrayType: byte;
    _prop_Delimiter: string;
    _event_onSum: THI_Event;
    _data_Array: THI_Event;

    procedure _work_doSum0(var _Data: TData; Index: word); // String
    procedure _work_doSum1(var _Data: TData; Index: word); // Integer
    procedure _work_doSum2(var _Data: TData; Index: word); // Real
    procedure _work_doDelimiter(var _Data: TData; Index: word);
    procedure _var_Sum(var _Data: TData; Index: word);
  end;

implementation

procedure THIArraySum._work_doDelimiter;
begin
  _prop_Delimiter := ToString(_Data);
end;

procedure THIArraySum._work_doSum0;
var
  i: integer;
  ind, dt: TData;
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;

  s := '';
  for i := 0 to ArrIn._Count - 1 do
  begin
    Ind := _DoData(i);
    ArrIn._Get(Ind, dt);
    s := s + ToString(dt) + _prop_Delimiter;
  end;
  DeleteTail(s, Length(_prop_Delimiter));
  _hi_CreateEvent(_Data, @_event_onSum, s);
end;

procedure THIArraySum._work_doSum1;
var
  i: integer;
  ind, dt: TData;  
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;

  v := 0;
  for i := 0 to ArrIn._Count - 1 do
  begin
    Ind := _DoData(i);
    ArrIn._Get(Ind, dt);
    v := v + ToInteger(dt);
  end;
  _hi_CreateEvent(_Data, @_event_onSum, v);
end;

procedure THIArraySum._work_doSum2;
var
  i: integer;
  ind, dt: TData;
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;

  r := 0;
  for i := 0 to ArrIn._Count - 1 do
  begin
    Ind := _DoData(i);
    ArrIn._Get(Ind, dt);
    r := r + ToReal(dt);
  end;
  _hi_CreateEvent(_Data, @_event_onSum, r);
end;

procedure THIArraySum._var_Sum;
begin
  case _prop_ArrayType of
    0: dtString(_Data, s);
    1: dtInteger(_Data, v);
    2: dtReal(_Data, r);
  end;
end;

end.