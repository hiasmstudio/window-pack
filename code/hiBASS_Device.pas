unit hiBASS_Device;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_Device = class(TDebug)
   private
   public
    _prop_Index:integer;

    _data_Index:THI_Event;
    _event_onDevice:THI_Event;

    procedure _work_doDevice(var _Data:TData; Index:word);
    procedure _var_CuIndex(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_Device._work_doDevice;
begin
  BASS_SetDevice(ReadInteger(_Data, _data_Index, _prop_Index));
  _hi_onEvent(_event_onDevice);
end;

procedure THIBASS_Device._var_CuIndex;
begin
  dtInteger(_Data, BASS_GetDevice());
end;

end.
