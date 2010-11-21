unit hiBASS_Volume;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_Volume = class(TDebug)
   private
   public
    _prop_Volume:real;

    _data_Volume:THI_Event;
    _event_onVolume:THI_Event;

    procedure _work_doVolume(var _Data:TData; Index:word);
    procedure _var_CurVolume(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_Volume._work_doVolume;
begin
  BASS_SetVolume(ReadReal(_Data, _data_Volume, _prop_Volume));
  _hi_onEvent(_event_onVolume);
end;

procedure THIBASS_Volume._var_CurVolume;
begin
  dtReal(_Data, BASS_GetVolume());
end;

end.
