unit hiBASS_RecordInput;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_RecordInput = class(TDebug)
   private
   public     
    _event_onEnumInputs:THI_Event;

    procedure _work_doEnumInputs(var _Data:TData; Index:word);
  end;

implementation


procedure THIBASS_RecordInput._work_doEnumInputs;
var inf:BASS_DEVICEINFO;
    i,s:integer;
    n:pchar;
    vol:float;
    dt,d:TData;
    f:PData;
begin
  i := 0;
  while BASS_RecordGetInputName(i) <> nil do
   begin     
     s := BASS_RecordGetInput(i, vol);

     dtString(dt, BASS_RecordGetInputName(i));
     dtReal(d, vol);
     AddMTData(@dt, @d, f);
     dtInteger(d, integer(s and BASS_INPUT_OFF = 0));
     AddMTData(@dt, @d, f);
          
     _hi_onEvent(_event_onEnumInputs, dt);
     FreeData(f);
     
     inc(i);
   end;        
end;

end.
