unit HiTimeOnHost;

interface

uses Windows, Kol, Share, Debug;

type
  PTIME_OF_DAY_INFO = ^TIME_OF_DAY_INFO;
  TIME_OF_DAY_INFO = record
    tod_elapsedt : Longint;
    tod_msecs    : Longint;
    tod_hours    : Longint;
    tod_mins     : Longint;
    tod_secs     : Longint;
    tod_hunds    : Longint;
    tod_timezone : Longint;
    tod_tinterval: Longint;
    tod_day      : Longint;
    tod_month    : Longint;
    tod_year     : Longint;
    tod_weekday  : Longint;
  end;

type
  THiTimeOnHost = class(TDebug)
   private

   public
    _prop_Host: string;
    _event_onTimeOnHost,
    _data_Host: THI_Event;
    procedure _work_doTimeOnHost(var _Data:Tdata; index:word);
  end;

  function NetRemoteTOD(Server: PWChar; var pBuffer: PTIME_OF_DAY_INFO): DWORD;
     stdcall; external 'NETAPI32.DLL';
  function NetApiBufferFree(pBuffer: Pointer): DWORD;
     stdcall; external 'NETAPI32.DLL';

implementation

function StringToWideString(const s: String): WideString;
var
  l: integer;
begin
  if s = '' then
    Result := ''
  else
  begin
    l := MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, PChar(s), -1, nil, 0);
    SetLength(Result, l - 1);
    if l > 1 then
      MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, PChar(s), -1, PWChar(Result), l - 1);
  end;
end;

procedure THiTimeOnHost._work_doTimeOnHost;
var
  dt: TData;
  mt: PMT;
  TOD: PTIME_OF_DAY_INFO;
begin
  if NetRemoteTOD(PWChar(StringToWideString(ReadString(_Data, _data_Host, _prop_Host))), TOD) = 0 then
  with TOD^ do
  begin
    dtInteger(dt, tod_day);
    mt := mt_make(dt);
    mt_int(mt, tod_month);
    mt_int(mt, tod_year);
    mt_int(mt, tod_hours - (tod_timezone div 60));
    mt_int(mt, tod_mins);
    mt_int(mt, tod_secs);
    _hi_onEvent_(_event_onTimeOnHost, dt);
    mt_free(mt);
    NetApiBufferFree(TOD);
  end;
end;

end.