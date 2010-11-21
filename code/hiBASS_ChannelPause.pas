unit hiBASS_ChannelPause;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_ChannelPause = class(TDebug)
   private
   public
    _prop_Channel:^cardinal;

    _event_onPause:THI_Event;

    procedure _work_doPause(var _Data:TData; Index:word);
  end;

implementation


procedure THIBASS_ChannelPause._work_doPause;
begin
   BASS_ChannelPause(_prop_Channel^);
   _hi_onEvent(_event_onPause);
end;

end.
