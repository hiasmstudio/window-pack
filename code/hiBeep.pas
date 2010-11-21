unit hiBeep;

interface

uses Kol,Share,Windows,Debug;

type
  THIBeep = class(TDebug)
   private
   public
    _prop_Freq:integer;
    _prop_Duration:integer;
    _data_Duration:THI_Event;
    _data_Freq:THI_Event;
    _event_onBeep:THI_Event;

    procedure _work_doBeep(var _Data:TData; Index:word);
  end;

implementation

procedure THIBeep._work_doBeep;
var fr,dr:integer;
begin
   fr := ReadInteger(_Data,_data_Freq,_prop_Freq);
   dr := ReadInteger(_Data,_data_Duration,_prop_Duration);
   if fr = 0 then sleep(dr) else Beep(fr,dr);
   _hi_CreateEvent(_Data, @_event_onBeep);
end;

end.
