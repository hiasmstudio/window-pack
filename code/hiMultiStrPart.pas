unit hiMultiStrPart;

interface

uses Kol,Share,Debug;

type
  THIMultiStrPart = class(TDebug)
  private
    l: array of string;
    procedure SetCount(Value: Word);
    procedure ClearAll;
  public

    _prop_Direct: byte;
    _prop_Char: string;
    _prop_From: integer;

    _data_Str: THI_Event;
    _event_onNotFound: THI_Event;
    _event_onSplit: THI_Event;

    procedure _work_doSplit0(var _Data: TData; Index: Word);
    procedure _work_doSplit1(var _Data: TData; Index: Word);
    
    procedure _work_doChar(var _Data: TData; Index: Word);
    procedure _work_doFrom(var _Data: TData; Index: Word);
        
    procedure _work_doClear(var _Data: TData; Index: Word);
    procedure Part(var _Data: TData; Index: Word);
    property _prop_Count: Word write SetCount;

  end;

implementation

uses hiStr_Enum;

Procedure THIMultiStrPart.ClearAll;
var
  i: integer;
begin
  for i:=0 to High(l) do
    l[i] := '';
end;  

procedure THIMultiStrPart.SetCount;
begin
  SetLength(l, Value);
end;

procedure THIMultiStrPart._work_doClear;
begin
  ClearAll;
end;

procedure THIMultiStrPart._work_doSplit0;
var
  str: string;
  i: integer;
begin
  ClearAll;
  str := ReadString(_Data, _data_Str);
  {$ifdef _PROTECT_MAX_}
  if (_prop_Char = '') or (str = '') then exit;
  {$endif}
  if (pos(_prop_Char[1], str) = 0) then
    _hi_CreateEvent(_Data, @_event_onNotFound, str)
  else  
  begin
    for i := 0 to _prop_From  - 1 do
      fparse(Str, _prop_Char[1]);
    for i := 0 to High(l) do
      l[i] := fparse(Str, _prop_Char[1]);
    _hi_CreateEvent(_Data, @_event_onSplit, str);
  end;
end;

procedure THIMultiStrPart._work_doSplit1;
var
  str: string;
  i: integer;
begin
  ClearAll;
  str := ReadString(_Data, _data_Str);
  {$ifdef _PROTECT_MAX_}
  if (_prop_Char = '') or (str = '') then exit;
  {$endif}
  if (pos(_prop_Char[1], str) = 0) then
    _hi_CreateEvent(_Data, @_event_onNotFound, str)
  else  
  begin
    for i := 0 to _prop_From  - 1 do
      rparse(Str, _prop_Char[1]);
    for i := 0 to High(l) do
      l[i] := rparse(Str, _prop_Char[1]);
    _hi_CreateEvent(_Data, @_event_onSplit, str);
  end;
end;

procedure THIMultiStrPart.Part;
begin
  dtString(_data, l[index]);
end;

procedure THIMultiStrPart._work_doChar;
begin
  _prop_Char := ToString(_Data);
end;

procedure THIMultiStrPart._work_doFrom;
begin
  _prop_From := ToInteger(_Data);
end;

end.