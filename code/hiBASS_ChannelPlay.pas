unit hiBASS_ChannelPlay;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_ChannelPlay = class(TDebug)
   private
   public
    _prop_Channel:^cardinal;
    _prop_Restart:byte;

    _event_onPlay:THI_Event;

    procedure _work_doPlay(var _Data:TData; Index:word);
    procedure _var_State(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_ChannelPlay._work_doPlay;
begin
   BASS_ChannelPlay(_prop_Channel^, _prop_Restart = 0);
   _hi_onEvent(_event_onPlay);
end;

procedure THIBASS_ChannelPlay._var_State;
begin            
  dtInteger(_Data, BASS_ChannelIsActive(_prop_Channel^));
end;

end.
