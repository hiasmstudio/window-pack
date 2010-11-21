unit hiBASS_ChlState;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_ChlState = class(TDebug)
   private
    procedure Err;
   public
    _data_Handle:THI_Event;
    _event_onCheck:THI_Event;
    _event_onError:THI_Event;

    procedure _work_doCheck(var _Data:TData; Index:word);
    procedure _var_State(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_ChlState.Err;
begin
   if BASS_ErrorGetCode > 0 then
    _hi_OnEvent(_event_onError,integer(BASS_ErrorGetCode));
end;

procedure THIBASS_ChlState._work_doCheck;
begin
  _hi_OnEvent(_event_onCheck,integer(BASS_ChannelIsActive(ReadInteger(_Data,_data_Handle))));
  Err;
end;

procedure THIBASS_ChlState._var_State;
begin            
  dtInteger(_Data,BASS_ChannelIsActive(ReadInteger(_Data,_data_Handle)));
  Err;
end;

end.
