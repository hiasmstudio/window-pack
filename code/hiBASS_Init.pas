unit hiBASS_Init;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_Init = class(TDebug)
   private
   public
    _prop_Device:integer;
    _prop_Freq:integer;
    _prop_Flags:integer;

    _data_Handle:THI_Event;
    _data_Freq:THI_Event;
    _data_Device:THI_Event;
    _event_onError:THI_Event;
    _event_onInit:THI_Event;

    procedure _work_doInit(var _Data:TData; Index:word);
    procedure _work_doFree(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_Init._work_doInit;
var d,f,h:integer;
begin    
//   if _prop_Device = -1 then              
//     d := Readinteger(_Data, _data_Device, 0)
//   else
   d := _prop_Device;
   f := Readinteger(_Data, _data_Freq, _prop_Freq);
   h := Readinteger(_Data, _data_Handle, 0);  
   if BASS_Init(d,f,_prop_Flags,h,nil) then
     _hi_onEvent(_event_onInit)
   else _hi_onEvent(_event_onError, BASS_ErrorGetCode());
   BASS_Start();
end;

procedure THIBASS_Init._work_doFree;
begin
   BASS_Free();
end;

end.
