unit hiBASS_ChlFX;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_ChlFX = class(TDebug)
   private
    FXHandle:cardinal;
   public
    _prop_Index:byte;
    _data_Handle:THI_Event;
    _data_Index:THI_Event;
    _data_FXHandle:THI_Event;
    _event_onFXHandle:THI_Event;

    procedure _work_doSetFX(var _Data:TData; Index:word);
    procedure _work_doRemoveFX(var _Data:TData; Index:word);
    procedure _var_LastFXHandle(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_ChlFX._work_doSetFX;
begin
  FXHandle := BASS_ChannelSetFX( ReadInteger(_Data,_data_Handle),ReadInteger(_Data,_data_Index),1 );
  _hi_CreateEvent(_Data,@_event_onFXHandle,integer(FXHandle));
end;

procedure THIBASS_ChlFX._work_doRemoveFX;
begin
   BASS_ChannelRemoveFX( ReadInteger(_Data,_data_Handle),ReadInteger(_Data,_data_FXHandle) );
end;

procedure THIBASS_ChlFX._var_LastFXHandle;
begin
   dtInteger(_Data,FXHandle);
end;

end.
