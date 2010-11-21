unit hiMultiStrData;

interface

uses Kol,Share,Debug;

type
  THIMultiStrData = class(TDebug)
  private
    FOutCount: byte;
    Str: string;
    procedure SetCount(Value: Word);
  public
    _prop_Direct: byte;
    _prop_Char: string;
    _prop_From: integer;

    _data_Str: THI_Event;
        
    onPart:array of THI_Event;

    procedure _work_doSplit0(var _Data: TData; Index: Word);
    procedure _work_doSplit1(var _Data: TData; Index: Word);

    procedure _work_doChar(var _Data: TData; Index: Word);
    procedure _work_doFrom(var _Data: TData; Index: Word);

    procedure _var_RemaindStr(var _Data:TData; Index:word);
    property _prop_Count: Word write SetCount;

  end;

implementation

uses hiStr_Enum;

procedure THIMultiStrData.SetCount;
begin
  SetLength(onPart, Value);
  FOutCount := Value;
end;

procedure THIMultiStrData._work_doSplit0;
var
  i: integer;
begin
  Str := ReadString(_Data, _data_Str);
  {$ifdef _PROTECT_MAX_}
  if (_prop_Char = '') or (str = '') then exit;
  {$endif}
  if (pos(_prop_Char[1], str) = 0) then exit;
  
  for i := 0 to _prop_From  - 1 do
    fparse(Str, _prop_Char[1]);
  for i := 0 to FOutCount - 1 do
    _hi_OnEvent(onPart[i], fparse(Str, _prop_Char[1]));
   
end;

procedure THIMultiStrData._work_doSplit1;
var
  i: integer;
begin
  Str := ReadString(_Data, _data_Str);
  {$ifdef _PROTECT_MAX_}
  if (_prop_Char = '') or (str = '') then exit;
  {$endif}
  if (pos(_prop_Char[1], str) = 0) then exit;
 
  for i := 0 to _prop_From  - 1 do
    rparse(Str, _prop_Char[1]);
  for i := 0 to FOutCount - 1 do
    _hi_OnEvent(onPart[i], rparse(Str, _prop_Char[1]));
    
end;

procedure THIMultiStrData._var_RemaindStr;
begin
  dtString(_data, Str);
end;

procedure THIMultiStrData._work_doChar;
begin
  _prop_Char := ToString(_Data);
end;

procedure THIMultiStrData._work_doFrom;
begin
  _prop_From := ToInteger(_Data);
end;

end.