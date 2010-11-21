unit hiArrayCountRepeats;

interface

uses Windows, Kol, Share, Debug;

type
  THIArrayCountRepeats = class(TDebug)
  private
    FList:PList;
    ArrOut: PArray;
    ArrIn: PArray;    

    procedure _Clear;    
    function GetArrayVal(idx: integer): TData;
    function _Count: integer;
    function _aGet(Var Item: TData; var Val: TData): boolean;
  public
    _prop_ArrayType: byte;
    _event_onCount: THI_Event;
    _event_onEndCount: THI_Event;
    _data_Array: THI_Event;

    constructor Create;
    destructor Destroy; override;

    procedure _work_doCount0(var _Data: TData; Index: word); // String
    procedure _work_doCount1(var _Data: TData; Index: word); // Integer
    procedure _work_doCount2(var _Data: TData; Index: word); // Real
    procedure _var_ArrayCount(var _Data: TData; Index: word);
    procedure _var_Count(var _Data: TData; Index: word);
  end;

implementation

constructor THIArrayCountRepeats.Create;
begin
  inherited;
  FList := newlist;
end; 

destructor THIArrayCountRepeats.Destroy;
begin
  _Clear;
  FList.Free;
  if ArrOut <> nil then
    Dispose(ArrOut);
  inherited;
end;

function THIArrayCountRepeats.GetArrayVal;
var
  ind, dt: TData;
begin
  ind := _DoData(idx);
  ArrIn._Get(ind, dt);
  Result := dt;
end;

procedure THIArrayCountRepeats._work_doCount0;
var
  i, j: integer;
  ds, di: TData;
  dt: PData;
  s: string;
  Repeats: boolean;  
  Count: integer;
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;

  _Clear;

  for i := 0 to ArrIn._Count - 1 do
  begin
    s := ToString(GetArrayVal(i)); 
    Repeats := false;
    for j := 0 to FList.Count - 1 do
      if ToString(PData(FList.Items[j])^) = s then
      begin
        Repeats := true;
        break;
      end;
    if Repeats then continue;

    Count := 1;
    for j := i + 1 to ArrIn._Count - 1 do    
      if s = ToString(GetArrayVal(j)) then Count := Count + 1;
    dtString(ds, s);
    dtInteger(di, Count);
    ds.ldata := @di;
    new(dt);
    CopyData(dt, @ds);
    FList.Add(dt);
    _hi_onEvent_(_event_onCount, ds);
  end;
  _hi_CreateEvent_(_Data, @_event_onEndCount);
end;

procedure THIArrayCountRepeats._work_doCount1;
var
  i, j, v: integer;
  ds, di: TData;
  dt: PData;
  Repeats: boolean;  
  Count: integer;
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;

  _Clear;

  for i := 0 to ArrIn._Count - 1 do
  begin
    v := ToInteger(GetArrayVal(i)); 
    Repeats := false;
    for j := 0 to FList.Count - 1 do
      if ToInteger(PData(FList.Items[j])^) = v then
      begin
        Repeats := true;
        break;
      end;
    if Repeats then continue;

    Count := 1;
    for j := i + 1 to ArrIn._Count - 1 do    
      if v = ToInteger(GetArrayVal(j)) then Count := Count + 1;
    dtInteger(ds, v);
    dtInteger(di, Count);
    ds.ldata := @di;
    new(dt);
    CopyData(dt, @ds);
    FList.Add(dt);
    _hi_onEvent_(_event_onCount, ds);
  end;
  _hi_CreateEvent_(_Data, @_event_onEndCount);
end;

procedure THIArrayCountRepeats._work_doCount2;
var
  i, j: integer;
  ds, di: TData;
  dt: PData;
  r: real;
  Repeats: boolean;  
  Count: integer;
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;

  _Clear;

  for i := 0 to ArrIn._Count - 1 do
  begin
    r := ToReal(GetArrayVal(i)); 
    Repeats := false;
    for j := 0 to FList.Count - 1 do
      if ToReal(PData(FList.Items[j])^) = r then
      begin
        Repeats := true;
        break;
      end;
    if Repeats then continue;

    Count := 1;
    for j := i + 1 to ArrIn._Count - 1 do    
      if r = ToReal(GetArrayVal(j)) then Count := Count + 1;
    dtReal(ds, r);
    dtInteger(di, Count);
    ds.ldata := @di;
    new(dt);
    CopyData(dt, @ds);
    FList.Add(dt);
    _hi_onEvent_(_event_onCount, ds);
  end;
  _hi_CreateEvent_(_Data, @_event_onEndCount);
end;

procedure THIArrayCountRepeats._var_ArrayCount;
begin
  if ArrOut = nil then
     ArrOut := CreateArray(nil, _aGet, _Count, nil);
  dtArray(_Data, ArrOut);
end;

procedure THIArrayCountRepeats._Clear;
var
  i: integer;
begin
  for i := 0 to FList.Count-1 do
  begin 
    FreeData(PData(FList.Items[i]));
    dispose(PData(FList.Items[i]));
  end;
  FList.Clear;
end;

function THIArrayCountRepeats._aGet;
var
  ind:integer;
begin
  ind := ToIntIndex(Item);
  if(ind >= 0) and (ind < _Count) then begin
    Result := true;
    FreeData(@Val);
    dtNull(Val);
    CopyData(@Val, PData(FList.Items[ind]));
  end
  else
    Result := false;
end;

function THIArrayCountRepeats._Count;
begin
  Result := FList.Count;
end;

procedure THIArrayCountRepeats._var_Count;
begin
  dtInteger(_Data, FList.Count);
end;

end.