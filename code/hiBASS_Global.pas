unit hiBASS_Global;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_Global = class(TDebug)
   private
    procedure Err;
   public
    _prop_Device:integer;
    _prop_Freq:integer;

    _data_Freq:THI_Event;
    _data_Device:THI_Event;
    _event_onError:THI_Event;

    procedure _work_doInit(var _Data:TData; Index:word);
    procedure _work_doStart(var _Data:TData; Index:word);
    procedure _work_doPause(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_Global.Err;
begin
   if BASS_ErrorGetCode > 0 then
    _hi_OnEvent(_event_onError,integer(BASS_ErrorGetCode));
end;

procedure THIBASS_Global._work_doInit;
begin
  BASS_Init(ReadInteger(_Data,_data_Device,_prop_Device),ReadInteger(_Data,_data_Freq,_prop_Freq),
    0,ReadHandle,nil);
  Err;
end;

procedure THIBASS_Global._work_doStart;
begin
  BASS_Start;
  Err;
end;

procedure THIBASS_Global._work_doPause;
begin
  BASS_Pause;
  Err;
end;

procedure THIBASS_Global._work_doStop;
begin
  BASS_Stop;
  Err;
end;

end.
