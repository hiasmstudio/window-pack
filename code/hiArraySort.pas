unit hiArraySort;

interface

uses Windows, Kol, Share, Debug, ArrayWorkFunctions;

type
  THIArraySort = class(TDebug)
  private
    ArrOut: PArray;
    ArrIn: PArray;    
    StrArray: PStrList;
    IntArray: Array of Integer;
    RealArray: Array of Real;

    function _Count: integer;
    function _aGet(Var Item: TData; var Val: TData): boolean;
  public
    _prop_ArrayType: byte;
    _prop_CaseSensitive: boolean;
    _event_onEndSort: THI_Event;
    _data_Array: THI_Event;

    constructor Create;
    destructor Destroy; override;

    procedure _work_doSort0(var _Data: TData; Index: word); // String
    procedure _work_doSort1(var _Data: TData; Index: word); // Integer
    procedure _work_doSort2(var _Data: TData; Index: word); // Real
    procedure _work_doCaseSensitive(var _Data: TData; Index: word);  
    procedure _var_ArraySort(var _Data: TData; Index: word);
    procedure _var_Count(var _Data: TData; Index: word);
  end;

implementation

constructor THIArraySort.Create;
begin
  inherited;
  StrArray := NewStrList;
end; 

destructor THIArraySort.Destroy;
begin
  if ArrOut <> nil then
    Dispose(ArrOut);
  StrArray.free;
  SetLength(IntArray, 0);
  SetLength(RealArray, 0);  
  inherited;
end;

procedure THIArraySort._work_doCaseSensitive;
begin
  _prop_CaseSensitive := ReadBool(_Data);
end;

procedure THIArraySort._work_doSort0;
var
  i: integer;
  ind, dt: TData;
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;

  StrArray.Clear;
  for i := 0 to ArrIn._Count - 1 do
  begin
    Ind := _DoData(i);
    ArrIn._Get(Ind, dt);
    StrArray.Add(ToString(dt));
  end;
// ќбращение к переделанному методу сортировки строк в StrList-e, 
// тк штатный Sort понимает Case только дл€ латиницы 
  SortStrList(StrArray, _prop_CaseSensitive);
  _hi_CreateEvent_(_Data, @_event_onEndSort);
end;

procedure THIArraySort._work_doSort1;
var
  i: integer;
  ind, dt: TData;  
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;

  SetLength(IntArray, 0);
  for i := 0 to ArrIn._Count - 1 do
  begin
    Ind := _DoData(i);
    ArrIn._Get(Ind, dt);
    SetLength(IntArray, Length(IntArray) + 1);
    IntArray[High(IntArray)] := ToInteger(dt);
  end;
  SortIntegerArray(IntArray);
  _hi_CreateEvent_(_Data, @_event_onEndSort);
end;

procedure THIArraySort._work_doSort2;
var
  i: integer;
  ind, dt: TData;
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;

  SetLength(RealArray, 0);
  for i := 0 to ArrIn._Count - 1 do
  begin
    Ind := _DoData(i);
    ArrIn._Get(Ind, dt);
    SetLength(RealArray, Length(RealArray) + 1);
    RealArray[High(RealArray)] := ToReal(dt);
  end;
  SortRealArray(RealArray);  
  _hi_CreateEvent_(_Data, @_event_onEndSort);
end;

procedure THIArraySort._var_ArraySort;
begin
  if ArrOut = nil then
     ArrOut := CreateArray(nil, _aGet, _Count, nil);
  dtArray(_Data, ArrOut);
end;

function THIArraySort._aGet;
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

function THIArraySort._Count;
begin
  Result := 0;
  case _prop_ArrayType of
    0: Result := StrArray.Count;
    1: Result := Length(IntArray);
    2: Result := Length(RealArray);
  end;
end;

procedure THIArraySort._var_Count;
begin
  dtInteger(_Data, _Count);
end;

end.