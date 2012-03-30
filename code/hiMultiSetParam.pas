unit hiMultiSetParam;

interface

uses Kol,Share,Debug;

type
  THIMultiSetParam = class(TDebug)
  private
    FOutCount: byte;
    procedure SetCount(Value: Word);    
  public
    _prop_Parameters: string;
    _prop_OutType: byte;
    _prop_Index: integer;
    _prop_Char: string;

    _data_Parameters: THI_Event;
    _data_Index: THI_Event;
    
    onSet: array of THI_Event;

    property _prop_Count: Word write SetCount;
    procedure _work_doSet(var _Data: TData; Index: Word);
    procedure _work_doChar(var _Data: TData; Index: Word);
  end;

implementation

uses hiStr_Enum;

procedure THIMultiSetParam.SetCount;
begin
  SetLength(onSet, Value);
  FOutCount := Value;
end;

procedure THIMultiSetParam._work_doSet;
var
  idx, i: integer;
  str: string;
  Param: PStrList;
begin
  Param := NewStrList;
TRY
  Param.Text := ReadString(_Data, _data_Parameters, _prop_Parameters);
  idx := ReadInteger(_Data, _data_Index, _prop_Index);

  if (idx < 0) or (idx > Param.Count - 1) then exit;
  str := Param.Items[idx];
  
  if str = '' then exit;
  if (_prop_Char <> '') then
  begin  
    for i := 0 to FOutCount - 1 do
    case _prop_OutType of
      0: _hi_OnEvent(onSet[i], str2int(fparse(Str, _prop_Char[1])));
      1: _hi_OnEvent(onSet[i], fparse(Str, _prop_Char[1]));
    end;
  end
  else
  begin
    for i := 0 to min(Length(Str) - 1, FOutCount - 1) do
    case _prop_OutType of
      0: _hi_OnEvent(onSet[i], str2int(Str[i + 1]));
      1: _hi_OnEvent(onSet[i], Str[i + 1]);
    end;
  end;  
FINALLY
  Param.free;
END;
end;

procedure THIMultiSetParam._work_doChar;
begin
  _prop_Char := ToString(_Data);
end;

end.