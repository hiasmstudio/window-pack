unit hiBASS_ChlControl;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_ChlControl = class(TDebug)
   private
    procedure Err;
   public
    _data_Handle:THI_Event;
    _event_onError:THI_Event;

    procedure _work_doPause(var _Data:TData; Index:word);
    procedure _work_doResume(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_ChlControl.Err;
begin
   if BASS_ErrorGetCode > 0 then
    _hi_OnEvent(_event_onError,integer(BASS_ErrorGetCode));
end;

procedure THIBASS_ChlControl._work_doPause;
begin
   BASS_ChannelPause( ReadInteger(_Data,_data_Handle) );
   Err;
end;

procedure THIBASS_ChlControl._work_doResume;
begin
   BASS_ChannelPlay( ReadInteger(_Data,_data_Handle),false );
   Err;
end;

procedure THIBASS_ChlControl._work_doStop;
begin
   BASS_ChannelStop( ReadInteger(_Data,_data_Handle) );
   Err;
end;

end.
