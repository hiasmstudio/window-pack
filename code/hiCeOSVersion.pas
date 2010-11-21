unit hiCeOSVersion;

interface

uses Kol,KolRapi,Share,Windows,Debug;

type
  THICeOSVersion = class(TDebug)
   private
     lpOSVersion: TCeOSVersionInfo;
   public
    _event_onVersion:THI_Event;

    procedure _work_doGetVersion(var _Data:TData; Index:word);
    procedure _var_MajorVersion(var _Data:TData; Index:word);
    procedure _var_MinorVersion(var _Data:TData; Index:word);
    procedure _var_BuildNumber(var _Data:TData; Index:word);
    procedure _var_CSDVersion(var _Data:TData; Index:word);
  end;

implementation

procedure THICeOSVersion._work_doGetVersion;
begin
  lpOSVersion.dwOSVersionInfoSize := SizeOf(lpOSVersion);
  CeGetVersionEx(@lpOSVersion);
  _hi_onEvent(_event_onVersion);
end;

procedure THICeOSVersion._var_MajorVersion;
begin
   dtInteger(_Data,lpOSVersion.dwMajorVersion);
end;

procedure THICeOSVersion._var_MinorVersion;
begin
   dtInteger(_Data,lpOSVersion.dwMinorVersion);
end;

procedure THICeOSVersion._var_BuildNumber;
begin
   dtInteger(_Data,lpOSVersion.dwBuildNumber);
end;

procedure THICeOSVersion._var_CSDVersion;
var s:string;
begin
   s := LStrFromPWCharLen(@lpOSVersion.szCSDVersion,sizeof(lpOSVersion.szCSDVersion));
   dtString(_Data,s);
end;

end.
