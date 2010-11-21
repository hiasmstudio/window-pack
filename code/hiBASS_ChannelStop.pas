unit hiBASS_ChannelStop;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_ChannelStop = class(TDebug)
   private
   public
    _prop_Channel:^cardinal;

    _event_onStop:THI_Event;

    procedure _work_doStop(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_ChannelStop._work_doStop;
begin
   BASS_ChannelStop(_prop_Channel^);
   _hi_onEvent(_event_onStop);
end;

end.
