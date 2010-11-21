unit hiBASS_RecordCenter;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_RecordCenter = class(TDebug)
   private
    procedure error;
   public
    _prop_Device:integer;

    _data_Device:THI_Event;
    _event_onError:THI_Event;
    _event_onInit:THI_Event;

    procedure _work_doInit(var _Data:TData; Index:word);
    procedure _work_doFree(var _Data:TData; Index:word);
    procedure _work_doDevice(var _Data:TData; Index:word);
    procedure _var_CurDevice(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_RecordCenter.Error;
begin
  _hi_onEvent(_event_onError, BASS_ErrorGetCode());
end;

procedure THIBASS_RecordCenter._work_doInit;
var d:integer;
begin
  if _prop_Device = -1 then
    d := ReadInteger(_Data, _data_Device,0)
  else d := _prop_Device; 
  if not BASS_RecordInit(d) then
    error;
  _hi_onEvent(_event_onInit);
end;

procedure THIBASS_RecordCenter._work_doFree;
begin
  if not BASS_RecordFree() then
    error;
end;

procedure THIBASS_RecordCenter._work_doDevice;
begin
  if not BASS_RecordSetDevice(ToInteger(_Data)) then
    error;
end;

procedure THIBASS_RecordCenter._var_CurDevice;
begin
   dtInteger(_Data, BASS_RecordGetDevice());
end;

end.
