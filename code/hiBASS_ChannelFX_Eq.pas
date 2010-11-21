unit hiBASS_ChannelFX_Eq;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_ChannelFX_Eq = class(TDebug)
   private
    Ffx:HFX;
   public
    _prop_Channel:^cardinal;
    _prop_Center:integer;
    _prop_Bandwidth:integer;
    _prop_Gain:integer;

    _data_Gain:THI_Event;
    _data_Bandwidth:THI_Event;
    _data_Center:THI_Event;
    _event_onSet:THI_Event;

    procedure _work_doSet(var _Data:TData; Index:word);
  end;

implementation

procedure SyncProc(handle:HSYNC; channel:DWORD; data:DWORD; user:pointer); stdcall;
begin
   with THIBASS_ChannelFX_Eq(user) do
    begin 
      BASS_ChannelRemoveFX(_prop_Channel^, Ffx);
      Ffx := 0;
    end;
end;

procedure THIBASS_ChannelFX_Eq._work_doSet;
var inf:BASS_DX8_PARAMEQ;
begin
   if Ffx = 0 then
    begin
      Ffx := BASS_ChannelSetFX(_prop_Channel^, BASS_FX_DX8_PARAMEQ, 1);
      BASS_ChannelSetSync(_prop_Channel^, BASS_SYNC_FREE, 0, SyncProc, self);
    end;
   inf.fCenter := ReadInteger(_Data, _data_Center, _prop_Center);
   inf.fBandwidth := ReadInteger(_Data, _data_Bandwidth, _prop_Bandwidth); 
   inf.fGain := ReadInteger(_Data, _data_Gain, _prop_Gain);
   BASS_FXSetParameters(Ffx, @inf); 
   _hi_onEvent(_event_onSet);
end;

end.
