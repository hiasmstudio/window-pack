unit hiBASS_RecordDevices;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_RecordDevices = class(TDebug)
   private
   public
     _event_onEnum:THI_Event;

     procedure _work_doEnum(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_RecordDevices._work_doEnum;
var inf:BASS_DEVICEINFO;
    i:integer;
    d,dt:TData;
    f:PData;
begin
  i := 0;
  while BASS_RecordGetDeviceInfo(i, inf) do
   begin
     dtString(d, inf.name);
     dtString(dt, inf.driver);
     AddMTData(@d, @dt, f);
     dtInteger(dt, inf.flags);
     AddMTData(@d, @dt, f);
     _hi_onEvent(_event_onEnum, d);
     FreeData(f);
     inc(i);
   end;
end;

end.
