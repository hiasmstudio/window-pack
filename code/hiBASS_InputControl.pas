unit hiBASS_InputControl;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_InputControl = class(TDebug)
   private
   public
    _prop_Volume:real;
    _prop_State:integer;

    _data_State:THI_Event;
    _data_Volume:THI_Event;
    _data_Index:THI_Event;
    _event_onSetInput:THI_Event;

    procedure _work_doSetInput(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_InputControl._work_doSetInput;
var i:integer;
    vol:float;
    s:integer;
begin          
   i := ReadInteger(_Data, _data_Index, 0);
   vol := ReadReal(_Data, _data_Volume, _prop_Volume);
   s := ReadInteger(_Data, _data_State, _prop_State);
   if s = 0 then s := BASS_INPUT_OFF else s := BASS_INPUT_ON;  
   BASS_RecordSetInput(i, s, vol);
   _hi_onEvent(_event_onSetInput);
end;

end.
