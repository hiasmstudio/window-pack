unit hiNTService;

interface

uses Kol,Share,Debug,Windows,ActiveX;

type

  TServiceStatus = record
    dwServiceType:DWORD;
    dwCurrentState:DWORD;
    dwControlsAccepted:DWORD;
    dwWin32ExitCode:DWORD;
    dwServiceSpecificExitCode:DWORD;
    dwCheckPoint:DWORD;
    dwWaitHint:DWORD;
  end;

  PServiceTableEntry = ^TServiceTableEntry;
  TServiceTableEntry = record
    lpServiceName: PChar;
    lpServiceProc: pointer;
  end;

  PPChar = ^PChar;

  THINTService = class(TDebug)
   private
    fHandle:THandle;
    fStat:TServiceStatus;
    fStop:THandle;

    procedure ControlHandler(fdwControl:DWORD);
    procedure ServiceMain(argc:DWORD; argv:PPChar);

   public
    _prop_Icon:HICON;
    _prop_RunType:byte;
    _prop_ServiceName:string;
    _prop_Description:string;
    _prop_StepTime:DWORD;
    _event_onStart:THI_Event;    
    _event_onStep:THI_Event;    
    _event_onStop:THI_Event;
    _event_onPause:THI_Event;    
    _event_onContinue:THI_Event;    
    _event_onInstall:THI_Event;    
    _event_onUninstall:THI_Event;    
    _event_StepTime:THI_Event;
    CleanUp:procedure;

    procedure Start;
    procedure _work_doStepTime(var _Data:TData; Index:word);
    procedure Install;
    procedure Uninstall;
  end;

  SERVICE_DESCRIPTION = record
    lpDescription:PChar;
  end;

const

  SC_MANAGER_CONNECT             = $1;
  SC_MANAGER_CREATE_SERVICE      = $2;
  SC_MANAGER_ENUMERATE_SERVICE   = $4;
  SC_MANAGER_LOCK                = $8;
  SC_MANAGER_QUERY_LOCK_STATUS   = $10;
  SC_MANAGER_MODIFY_BOOT_CONFIG  = $20;

  SERVICE_CONTROL_STOP           = $1;
  SERVICE_CONTROL_PAUSE          = $2;
  SERVICE_CONTROL_CONTINUE       = $3;
  SERVICE_CONTROL_INTERROGATE    = $4;
  SERVICE_CONTROL_SHUTDOWN       = $5;
  SERVICE_CONTROL_PARAMCHANGE    = $6;
  SERVICE_CONTROL_NETBINDADD     = $7;
  SERVICE_CONTROL_NETBINDREMOVE  = $8;
  SERVICE_CONTROL_NETBINDENABLE  = $9;
  SERVICE_CONTROL_NETBINDDISABLE = $A;

  SERVICE_STOPPED          = $1;
  SERVICE_START_PENDING    = $2;
  SERVICE_STOP_PENDING     = $3;
  SERVICE_RUNNING          = $4;
  SERVICE_CONTINUE_PENDING = $5;
  SERVICE_PAUSE_PENDING    = $6;
  SERVICE_PAUSED           = $7;

  SERVICE_ACCEPT_STOP            = $1;
  SERVICE_ACCEPT_PAUSE_CONTINUE  = $2;
  SERVICE_ACCEPT_SHUTDOWN        = $4;
  SERVICE_ACCEPT_PARAMCHANGE     = $8;
  SERVICE_ACCEPT_NETBINDCHANGE   = $10;

  SERVICE_KERNEL_DRIVER          = $1;
  SERVICE_FILE_SYSTEM_DRIVER     = $2;
  SERVICE_ADAPTER                = $4;
  SERVICE_RECOGNIZER_DRIVER      = $8;
  SERVICE_DRIVER                 = SERVICE_KERNEL_DRIVER +
                                   SERVICE_FILE_SYSTEM_DRIVER +
                                   SERVICE_RECOGNIZER_DRIVER;
  SERVICE_WIN32_OWN_PROCESS      = $10;
  SERVICE_WIN32_SHARE_PROCESS    = $20;
  SERVICE_WIN32                  = SERVICE_WIN32_OWN_PROCESS +
                                   SERVICE_WIN32_SHARE_PROCESS;
  SERVICE_INTERACTIVE_PROCESS    = $100;

  SERVICE_ERROR_IGNORE           = $0;
  SERVICE_ERROR_NORMAL           = $1;
  SERVICE_ERROR_SEVERE           = $2;
  SERVICE_ERROR_CRITICAL         = $3;

  SERVICE_BOOT_START             = $0;
  SERVICE_SYSTEM_START           = $1;
  SERVICE_AUTO_START             = $2;
  SERVICE_DEMAND_START           = $3;
  SERVICE_DISABLED               = $4;

  SERVICE_CONFIG_DESCRIPTION     = 1;
  SERVICE_CONFIG_FAILURE_ACTIONS = 2;

  SERVICE_ALL_ACCESS = $F01FF;
  
function StartServiceCtrlDispatcher(lpServiceStartTable:PServiceTableEntry):boolean; stdcall;
function RegisterServiceCtrlHandler(lpServiceName:PChar; lpHandlerProc:pointer):THandle; stdcall;
function SetServiceStatus(hServiceStatus:THandle; var lpServiceStatus:TServiceStatus):boolean; stdcall;

function CloseServiceHandle(scHandle:THandle):boolean; stdcall;
function OpenSCManager(lpszMachineName,lpszDatabaseName:PChar; dwAccess:DWORD):THandle; stdcall;
function CreateService(hSCM:THandle; lpServiceName,lpDisplayName:PChar; dwDesiredAccess,dwServiceType,dwStartType,dwErrorControl:DWORD; lpBinaryPathName,lpLoadOrderGroup:PChar; lpdwTagId:PDWORD; lpDependencies,lpServiceStartName,lpPassword:PChar):THandle; stdcall;
function OpenService(hSCM:THandle; lpServiceName:PChar; dwDesiredAccess:DWORD):THandle; stdcall;
function DeleteService(hSvc:THandle):boolean; stdcall;
function ChangeServiceConfig2(hSvc:THandle; dwInfoLevel:DWORD; lpInfo:pointer):boolean; stdcall;

implementation

function StartServiceCtrlDispatcher; external 'ADVAPI32.DLL' name 'StartServiceCtrlDispatcherA';
function RegisterServiceCtrlHandler; external 'ADVAPI32.DLL' name 'RegisterServiceCtrlHandlerA';
function SetServiceStatus; external 'ADVAPI32.DLL' name 'SetServiceStatus';

function CloseServiceHandle; external 'ADVAPI32.DLL' name 'CloseServiceHandle';
function OpenSCManager; external 'ADVAPI32.DLL' name 'OpenSCManagerA';
function CreateService; external 'ADVAPI32.DLL' name 'CreateServiceA';
function OpenService; external 'ADVAPI32.DLL' name 'OpenServiceA';
function DeleteService; external 'ADVAPI32.DLL' name 'DeleteService';
function ChangeServiceConfig2; external 'ADVAPI32.DLL' name 'ChangeServiceConfig2A';

var Svc:THINTService; dispTbl: array[0..1] of TServiceTableEntry;

procedure ControlHandlerProc(fdwControl:DWORD); stdcall;
begin
  Svc.ControlHandler(fdwControl);
end;

procedure THINTService.ControlHandler;
begin
  case fdwControl of
  SERVICE_CONTROL_PAUSE:
    begin
      fStat.dwCurrentState := SERVICE_PAUSE_PENDING;
      fStat.dwCheckPoint := 0;
    end;
  SERVICE_CONTROL_CONTINUE:
    begin
      fStat.dwCurrentState := SERVICE_CONTINUE_PENDING;
      fStat.dwCheckPoint := 0;
    end;
  SERVICE_CONTROL_STOP, SERVICE_CONTROL_SHUTDOWN:
    begin
      fStat.dwCurrentState := SERVICE_STOP_PENDING;
      fStat.dwCheckPoint := 0;
      SetEvent(fStop);
    end;
  end;
  SetServiceStatus(fHandle, fStat);
end;
  
procedure ServiceMainProc(argc:DWORD; argv:PPChar); stdcall;
begin
  Svc.ServiceMain(argc, argv);
end;

procedure THINTService.ServiceMain;
var Msg: TMsg;
begin
  fStat.dwServiceType := SERVICE_WIN32_OWN_PROCESS or SERVICE_INTERACTIVE_PROCESS;
  fStat.dwCurrentState := SERVICE_STOPPED;
  fStat.dwControlsAccepted := 0;
  fStat.dwWin32ExitCode := NO_ERROR;
  fStat.dwWaitHint  := 1000;

  fHandle := RegisterServiceCtrlHandler(PChar(_prop_ServiceName),@ControlHandlerProc);

  if fHandle<>0 then begin 

    fStop := CreateEvent(nil,False,False,nil);

    fStat.dwCurrentState := SERVICE_START_PENDING;
    fStat.dwCheckPoint := 0;
    SetServiceStatus(fHandle, fStat);

    CoInitialize(nil);
    EventOn;
    InitDo;

    _hi_OnEvent(_event_onStart);

    fStat.dwControlsAccepted := SERVICE_ACCEPT_PAUSE_CONTINUE or
      SERVICE_ACCEPT_STOP or SERVICE_ACCEPT_SHUTDOWN;
    fStat.dwCurrentState := SERVICE_RUNNING;
    SetServiceStatus(fHandle, fStat);

    repeat
      case fStat.dwCurrentState of
      SERVICE_RUNNING:
        _hi_OnEvent(_event_onStep);
      SERVICE_PAUSE_PENDING:
        begin
          _hi_OnEvent(_event_onPause);
          fStat.dwCurrentState := SERVICE_PAUSED;
          SetServiceStatus(fHandle, fStat);
        end;
      SERVICE_CONTINUE_PENDING:
        begin
          _hi_OnEvent(_event_onContinue);
          fStat.dwCurrentState := SERVICE_RUNNING;
          SetServiceStatus(fHandle, fStat);
        end;
      end;
      while PeekMessage( Msg, 0, 0, 0, PM_REMOVE ) do begin
        TranslateMessage( Msg );
        DispatchMessage( Msg );
      end;
    until WaitForSingleObject(fStop,_prop_StepTime)=WAIT_OBJECT_0;

    _hi_OnEvent(_event_onStop);

    EventOff;
    CoUninitialize;

    fStat.dwControlsAccepted := 0;
    fStat.dwCurrentState := SERVICE_STOPPED;
    fStat.dwWin32ExitCode := NO_ERROR;
    SetServiceStatus(fHandle, fStat);

    CloseHandle(fStop);
  end;

  CleanUp;
end;

procedure THINTService.Start;
begin
  Svc := Self;
  dispTbl[0].lpServiceName := PChar(_prop_ServiceName);
  dispTbl[0].lpServiceProc := @ServiceMainProc;
  dispTbl[1].lpServiceName := nil;
  dispTbl[1].lpServiceProc := nil;
  StartServiceCtrlDispatcher(@dispTbl[0]);
end;

procedure THINTService._work_doStepTime;
begin
  _prop_StepTime := ReadInteger(_Data,_event_StepTime,0);
end;

procedure THINTService.Install;
var hSCMgr,hSvc:THandle; sPath:string; desc:SERVICE_DESCRIPTION;
    runtype: dword;
begin
  hSCMgr := OpenSCManager(nil,nil,SC_MANAGER_CREATE_SERVICE);
  if hSCMgr=0 then begin
    MessageBox(0,'Can''t open service database.'#13#10'You must have Administrator rights.','Error',MB_ICONSTOP);
    exit;
  end;
  SetLength(sPath,1024); SetLength(sPath,GetModuleFileName(0,@sPath[1],1024));
  case _prop_RunType of
     0: runtype   := SERVICE_AUTO_START;
     1: runtype   := SERVICE_DEMAND_START;
     2: runtype   := SERVICE_DISABLED
     else runtype := SERVICE_DEMAND_START;
  end;
  hSvc := CreateService(hSCMgr,PChar(_prop_ServiceName),PChar(_prop_ServiceName),
    SERVICE_ALL_ACCESS,SERVICE_WIN32_OWN_PROCESS or SERVICE_INTERACTIVE_PROCESS,runtype,SERVICE_ERROR_NORMAL,
    PChar(sPath),nil,nil,nil,nil,nil);
  if hSvc=0 then begin
    MessageBox(0,'Can''t create service.','Error',MB_ICONSTOP);
  end else begin
    desc.lpDescription := PChar(_prop_Description);
    ChangeServiceConfig2(hSvc,SERVICE_CONFIG_DESCRIPTION,@desc);
    CloseServiceHandle(hSvc);
    EventOn; InitDo;
    _hi_OnEvent(_event_onInstall);
  end;
  CloseServiceHandle(hSCMgr);
end;

procedure THINTService.Uninstall;
var hSCMgr,hSvc:THandle;
begin
  hSCMgr := OpenSCManager(nil,nil,SC_MANAGER_ENUMERATE_SERVICE);
  if hSCMgr=0 then begin
    MessageBox(0,'Can''t open service database.','Error',MB_ICONSTOP);
    exit;
  end;
  hSvc := OpenService(hSCMgr,PChar(_prop_ServiceName),$10000); //DELETE
  if hSvc=0 then begin
    if GetLastError()=ERROR_SERVICE_DOES_NOT_EXIST then
      MessageBox(0,'Service not found.','Error',MB_ICONSTOP)
    else
      MessageBox(0,'Can''t open service.'#13#10'You must have Administrator rights.','Error',MB_ICONSTOP);
  end else begin
    if not DeleteService(hSvc) then begin
      MessageBox(0,'Can''t delete service.','Error',MB_ICONSTOP);
      CloseServiceHandle(hSvc);
    end else begin
      CloseServiceHandle(hSvc);
      EventOn; InitDo;
      _hi_OnEvent(_event_onUninstall);
    end;
  end;
  CloseServiceHandle(hSCMgr);
end;

end.