unit hiStrPad;

interface

uses kol,Share,Debug;
const
  STR_PAD_LEFT    = 0;
  STR_PAD_RIGHT   = 1;
  STR_PAD_BOTH    = 2;
  STR_PAD_MIRROR  = 3;

type
 THiStrPad = class(TDebug)
   private
     str: string;
     padtype: integer;
   public
     _prop_String: string;
     _prop_PadString: string;
     _prop_PadLength: integer;

     _data_String,
     _data_PadString,
     _data_PadLength,
     _data_PadType,
     _event_onStrPad: THI_Event;
     property _prop_PadType: integer write padtype;
     procedure _work_doStrPad(var _Data:TData; Index:word);
     procedure _work_doPadType(var _Data:TData; Index:word);
     procedure _var_Result(var _Data:TData; Index:word);

 end;

implementation

procedure THiStrPad._work_doStrPad;
var
  half, halfm, padstring: string;
  pad_to_go, padlength: integer;

  function str_revers(s: string): string;
  var
    i: integer;
  begin
    result := '';
    for i := length(s) downto 1 do
      result := result + s[i];
  end;

  function str_pad_repeater(s: string; len:integer): string;
  begin
    result := '';
    while length(result) < len do
      result := result + s;
    setlength(result, len);
  end;

begin
  str := ReadString(_Data, _data_String);
  padstring := ReadString(_Data, _data_PadString);
  if padstring ='' then padstring := ' ';
  padlength := ReadInteger(_Data, _data_PadLength);

  pad_to_go := padlength - length(str);
  if pad_to_go > 0 then
  begin
    if padtype = STR_PAD_LEFT then
      str := str_pad_repeater(padstring, pad_to_go) + str
    else if padtype = STR_PAD_RIGHT then
      str := str + str_pad_repeater(padstring, pad_to_go)
    else if (padtype = STR_PAD_BOTH) or (padtype = STR_PAD_MIRROR) then
    begin
      if odd(pad_to_go) then inc(pad_to_go);
      half := str_pad_repeater(padstring, pad_to_go div 2);
      if padtype = STR_PAD_MIRROR then
      begin
        halfm := str_revers(half);
        str := half + str + halfm;
      end
      else
        str := half + str + half;
      setlength(str, padlength);
    end;
  end;
  _hi_CreateEvent(_Data, @_event_onStrPad, str);
end;

procedure THiStrPad._var_Result;
begin
  dtString(_Data, str);
end;

procedure THiStrPad._work_doPadType;
begin
  padtype := ToInteger(_Data);
  if (padtype > STR_PAD_MIRROR) or (padtype < STR_PAD_LEFT) then 
    padtype := STR_PAD_RIGHT;
end;

end.