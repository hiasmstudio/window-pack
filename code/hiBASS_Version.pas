unit hiBASS_Version;

interface

uses Windows,Kol,Share,Debug,BASS;

type
  THIBASS_Version = class(TDebug)
   private
   public 
    _event_onCheckFailed:THI_Event;
    _event_onCheckOk:THI_Event;

    procedure _work_doCheck(var _Data:TData; Index:word);
    procedure _var_Version(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_Version._work_doCheck;
begin
  if HIWORD(BASS_GetVersion()) = BASSVERSION then
    _hi_onEvent(_event_onCheckOk)
  else _hi_onEvent(_event_onCheckFailed);
end;

procedure THIBASS_Version._var_Version;
begin
  dtInteger(_Data, BASS_GetVersion());
end;

end.
