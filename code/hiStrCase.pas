unit hiStrCase;

interface

uses Windows, Kol, Share, Debug;

type
  THIStrCase = class(TDebug)
  private

  public
    _prop_Type: procedure(var Str: string) of object;

    _data_Str: THI_Event;
    _event_onModify: THI_Event;

    procedure _work_doModify(var _Data: TData; Index: word);
    procedure Lower(var Str: string);
    procedure Upper(var Str: string);
    procedure ProperCase(var Str: string);
    procedure FirstChar(var Str: string);
    procedure Inversion(var Str: string);             
  end;

implementation

procedure THIStrCase._work_doModify;
var
  str: string;
begin
  str := ReadString(_Data, _data_Str) + #0;
  _prop_Type(str);
  SetLength(str, length(str) - 1); 
  _hi_CreateEvent(_Data, @_event_onModify, str);
end;

procedure THIStrCase.Lower;
begin
  CharLower(@Str[1]);
end;

procedure THIStrCase.Upper;
begin
  CharUpper(@Str[1]);
end;

procedure THIStrCase.ProperCase;
var
  i: integer;
begin
  CharLower(@Str[1]);
  for i := 1 to length(Str) do
    if (i = 1) or (Str[i - 1] = ' ') then
      CharUpperBuff(@Str[i], 1)
end;

procedure THIStrCase.Inversion;
var
  i: integer;
begin
  for i := 1 to length(Str) do
    if IsCharLower(Str[i]) then
      CharUpperBuff(@Str[i], 1)
    else  
      CharLowerBuff(@Str[i], 1)
end;

procedure THIStrCase.FirstChar;
var
  i: integer;
begin
  CharLower(@Str[1]);
  for i := 1 to length(Str) do
    if (Str[i] = ' ') then
      continue
    else  
    begin
      CharUpperBuff(@Str[i], 1);
      break;
    end;
end;

end.