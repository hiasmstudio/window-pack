unit hiArrayFilterRepeats;

interface

uses Windows, Kol, Share, Debug;

type
  THIArrayFilterRepeats = class(TDebug)
  private
    ArrOut: PArray;
    ArrIn: PArray;    
    StrArray: PStrList;
    IntArray: Array of Integer;
    RealArray: Array of Real;

    function GetArrayVal(idx: integer): TData;    
    function _Count: integer;
    function _aGet(Var Item: TData; var Val: TData): boolean;
  public
    _prop_ArrayType: byte;
    _event_onFilter: THI_Event;
    _event_onEndFilter: THI_Event;
    _data_Array: THI_Event;

    constructor Create;
    destructor Destroy; override;

    procedure _work_doFilter0(var _Data: TData; Index: word); // String
    procedure _work_doFilter1(var _Data: TData; Index: word); // Integer
    procedure _work_doFilter2(var _Data: TData; Index: word); // Real
    procedure _var_ArrayFilter(var _Data: TData; Index: word);
    procedure _var_Count(var _Data: TData; Index: word);
  end;

implementation

constructor THIArrayFilterRepeats.Create;
begin
  inherited;
  StrArray := NewStrList;
end; 

destructor THIArrayFilterRepeats.Destroy;
begin
  if ArrOut <> nil then
    Dispose(ArrOut);
  StrArray.free;
  SetLength(IntArray, 0);
  SetLength(RealArray, 0);  
  inherited;
end;

function THIArrayFilterRepeats.GetArrayVal;
var
  ind, dt: TData;
begin
  ind := _DoData(idx);
  ArrIn._Get(ind, dt);
  Result := dt;
end;

procedure THIArrayFilterRepeats._work_doFilter0;
var
  i, j: integer;
  Repeats: boolean;
  s:string;
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;

  StrArray.Clear;

  for i := 0 to ArrIn._Count - 1 do
  begin
    s := ToString(GetArrayVal(i)); 
    Repeats := false;
    for j := 0 to StrArray.Count - 1 do
      if StrArray.Items[j] = s then
        begin
          Repeats := true;
          break;
        end;
    if Repeats then continue;

    StrArray.Add(s);
    _hi_onEvent(_event_onFilter, s);
  end;
  _hi_CreateEvent_(_Data, @_event_onEndFilter);
end;

procedure THIArrayFilterRepeats._work_doFilter1;
var
  i, j, v: integer;
  Repeats: boolean;
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;

  SetLength(IntArray, 0);

  for i := 0 to ArrIn._Count - 1 do
  begin
    v := ToInteger(GetArrayVal(i));
    Repeats := false;
    for j := 0 to High(IntArray) do
      if IntArray[j] = v then
        begin
          Repeats := true;
          break;
        end;
    if Repeats then continue;

    SetLength(IntArray, Length(IntArray) + 1);
    IntArray[High(IntArray)] := v; 
    _hi_onEvent(_event_onFilter, v);
  end;
  _hi_CreateEvent_(_Data, @_event_onEndFilter);
end;

procedure THIArrayFilterRepeats._work_doFilter2;
var
  i, j: integer;
  r: real;
  Repeats: boolean;
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;

  SetLength(RealArray, 0);
  
  for i := 1 to ArrIn._Count - 1 do
  begin
    r := ToReal(GetArrayVal(i)); 
    Repeats := false;
    for j := 0 to High(RealArray) do
      if RealArray[j] = r then
        begin
          Repeats := true;
          break;
        end;
    if Repeats then continue;

    SetLength(RealArray, Length(RealArray) + 1);
    RealArray[High(RealArray)] := r; 
    _hi_onEvent(_event_onFilter, r);
  end;
  _hi_CreateEvent_(_Data, @_event_onEndFilter);
end;

procedure THIArrayFilterRepeats._var_ArrayFilter;
begin
  if ArrOut = nil then
     ArrOut := CreateArray(nil, _aGet, _Count, nil);
  dtArray(_Data, ArrOut);
end;

function THIArrayFilterRepeats._aGet;
var
  Index: integer;
begin
  Result := false;
  
  Index := ToIntIndex(Item);
  if (Index < 0) or (Index > _Count - 1) then exit;
  case _prop_ArrayType of
    0: dtString(Val, StrArray.Items[Index]);
    1: dtInteger(Val, IntArray[Index]);
    2: dtReal(Val, RealArray[Index]);
  end;
  Result := true;
end;

function THIArrayFilterRepeats._Count;
begin
  Result := 0;
  case _prop_ArrayType of
    0: Result := StrArray.Count;
    1: Result := Length(IntArray);
    2: Result := Length(RealArray);
  end;
end;

procedure THIArrayFilterRepeats._var_Count;
begin
  dtInteger(_Data, _Count);
end;

end.