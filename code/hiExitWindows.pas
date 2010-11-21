unit hiExitWindows;

interface

uses Windows,Share,Debug;

type
  THIExitWindows = class(TDebug)
   private
    procedure WinExit(iFlags: integer);
   public
    _prop_QuickForce:boolean;
    procedure _work_doLogOff(var _Data:TData; Index:word);
    procedure _work_doReboot(var _Data:TData; Index:word);
    procedure _work_doShutdown(var _Data:TData; Index:word);
    procedure _work_doSuspend(var _Data:TData; Index:word);
    procedure _work_doHibernate(var _Data:TData; Index:word);
    procedure _work_doLockStation(var _Data:TData; Index:word);
    procedure _work_doPowerOff(var _Data:TData; Index:word);
  end;

function SetPrivilege(const aPrivilegeName: string;  aEnabled: boolean): boolean;

implementation

function SetPrivilege(const aPrivilegeName: string;  aEnabled: boolean): boolean;
var
  TPPrev,TP: TTokenPrivileges;
  Token: THandle;
  dwRetLen: DWord;
begin
  Result := False;
  OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, Token);

  TP.PrivilegeCount := 1;
  if (LookupPrivilegeValue(nil, PChar(aPrivilegeName),TP.Privileges[0].LUID)) then
   begin
    if (aEnabled) then
         TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
    else TP.Privileges[0].Attributes := 0;

    dwRetLen := 0;
    Result := AdjustTokenPrivileges(Token, False, TP, SizeOf(TPPrev), TPPrev, dwRetLen);
   end;
  CloseHandle(Token);
end;

procedure THIExitWindows.WinExit;
begin
  SetPrivilege('SeShutdownPrivilege', true);
  if _prop_QuickForce then 
     iFlags := iFlags or EWX_FORCE;
  ExitWindowsEx(iFlags, 0);
  SetPrivilege('SeShutdownPrivilege', False);
end;

procedure THIExitWindows._work_doLogOff;
begin
  WinExit(EWX_LOGOFF);
end;

procedure THIExitWindows._work_doReboot;
begin
  WinExit(EWX_REBOOT);
end;

procedure THIExitWindows._work_doShutdown;
begin
  WinExit(EWX_SHUTDOWN);
end;

procedure THIExitWindows._work_doPowerOff;
begin
  WinExit(EWX_POWEROFF);
end;

procedure THIExitWindows._work_doSuspend;
begin
  SetPrivilege('SeShutdownPrivilege', true);
  SetSystemPowerState(true,true);
  SetPrivilege('SeShutdownPrivilege', False);
end;

procedure THIExitWindows._work_doHibernate;
begin
  SetPrivilege('SeShutdownPrivilege', true);
  SetSystemPowerState(false,true);
  SetPrivilege('SeShutdownPrivilege', False);
end;

{$ifdef F_P}
function LockWorkStation: BOOL; stdcall; external 'user32.dll' name 'LockWorkStation';
{$endif}

procedure THIExitWindows._work_doLockStation;
begin
   LockWorkStation;
end;

end.
