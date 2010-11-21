unit hiServiceTools;

interface

uses Windows,Kol,Share,Debug;
type
  THIServiceTools = class(TDebug)
   private
     StatusService: integer;
     procedure EnumService(Name:string);
   public
    _prop_Name:string;
    _prop_FileName:string;
    _prop_ServiceType:byte;
    _prop_ServiceState:byte;
    _data_Name:THI_Event;
    _data_FileName:THI_Event;
    _event_onStatus:THI_Event;
    _event_onEnumServices:THI_Event;
    _event_onGetStatus:THI_Event;
    _event_onExecService:THI_Event;    
    _event_onExecError:THI_Event;

    procedure _work_doStart(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _work_doContinue(var _Data:TData; Index:word);
    procedure _work_doPause(var _Data:TData; Index:word);
    procedure _work_doShutdown(var _Data:TData; Index:word);
    procedure _work_doInstall(var _Data:TData; Index:word);
    procedure _work_doUninstall(var _Data:TData; Index:word);
    procedure _work_doGetStatus(var _Data:TData; Index:word);
    procedure _work_doEnumServices(var _Data:TData; Index:word);
    procedure _var_StatusService(var _Data:TData; Index:word);            
  end;

implementation

const
  SERVICE_ACTIVE                 = $00000001;
  SERVICE_INACTIVE               = $00000002;
  SERVICE_STATE_ALL              = (SERVICE_ACTIVE   or
                                    SERVICE_INACTIVE);
                                    
  SERVICE_KERNEL_DRIVER         = $00000001;
  SERVICE_FILE_SYSTEM_DRIVER    = $00000002;
  SERVICE_ADAPTER               = $00000004;
  SERVICE_RECOGNIZER_DRIVER     = $00000008;
  SERVICE_DRIVER                = (SERVICE_KERNEL_DRIVER or
                                   SERVICE_FILE_SYSTEM_DRIVER or
                                   SERVICE_RECOGNIZER_DRIVER);
  
  SERVICE_WIN32_OWN_PROCESS     = $00000010;
  SERVICE_WIN32_SHARE_PROCESS   = $00000020;
  SERVICE_WIN32                 = (SERVICE_WIN32_OWN_PROCESS or
                                   SERVICE_WIN32_SHARE_PROCESS);

  SERVICE_STOPPED                = $00000001;
  SERVICE_START_PENDING          = $00000002;
  SERVICE_STOP_PENDING           = $00000003;
  SERVICE_RUNNING                = $00000004;
  SERVICE_CONTINUE_PENDING       = $00000005;
  SERVICE_PAUSE_PENDING          = $00000006;
  SERVICE_PAUSED                 = $00000007;
  
//
// Service Control Manager object specific access types
//
  SC_MANAGER_CONNECT             = $0001;
  SC_MANAGER_CREATE_SERVICE      = $0002;
  SC_MANAGER_ENUMERATE_SERVICE   = $0004;
  SC_MANAGER_LOCK                = $0008;
  SC_MANAGER_QUERY_LOCK_STATUS   = $0010;
  SC_MANAGER_MODIFY_BOOT_CONFIG  = $0020;

  SC_MANAGER_ALL_ACCESS          = (STANDARD_RIGHTS_REQUIRED or
                                    SC_MANAGER_CONNECT or
                                    SC_MANAGER_CREATE_SERVICE or
                                    SC_MANAGER_ENUMERATE_SERVICE or
                                    SC_MANAGER_LOCK or
                                    SC_MANAGER_QUERY_LOCK_STATUS or
                                    SC_MANAGER_MODIFY_BOOT_CONFIG);
//
// Service object specific access type
//
  SERVICE_QUERY_CONFIG           = $0001;
  SERVICE_CHANGE_CONFIG          = $0002;
  SERVICE_QUERY_STATUS           = $0004;
  SERVICE_ENUMERATE_DEPENDENTS   = $0008;
  SERVICE_START                  = $0010;
  SERVICE_STOP                   = $0020;
  SERVICE_PAUSE_CONTINUE         = $0040;
  SERVICE_INTERROGATE            = $0080;
  SERVICE_USER_DEFINED_CONTROL   = $0100;

  SERVICE_ALL_ACCESS             = (STANDARD_RIGHTS_REQUIRED or
                                    SERVICE_QUERY_CONFIG or
                                    SERVICE_CHANGE_CONFIG or
                                    SERVICE_QUERY_STATUS or
                                    SERVICE_ENUMERATE_DEPENDENTS or
                                    SERVICE_START or
                                    SERVICE_STOP or
                                    SERVICE_PAUSE_CONTINUE or
                                    SERVICE_INTERROGATE or
                                    SERVICE_USER_DEFINED_CONTROL);
//
// Controls
//
  SERVICE_CONTROL_STOP           = $00000001;
  SERVICE_CONTROL_PAUSE          = $00000002;
  SERVICE_CONTROL_CONTINUE       = $00000003;
  SERVICE_CONTROL_INTERROGATE    = $00000004;
  SERVICE_CONTROL_SHUTDOWN       = $00000005;

type
  SC_HANDLE = Cardinal;
  _SERVICE_STATUS = record
    dwServiceType: DWORD;
    dwCurrentState: DWORD;
    dwControlsAccepted: DWORD;
    dwWin32ExitCode: DWORD;
    dwServiceSpecificExitCode: DWORD;
    dwCheckPoint: DWORD;
    dwWaitHint: DWORD;
  end;
  TServiceStatus = _SERVICE_STATUS;

  TEnumServiceStatus = record
    lpServiceName: PAnsiChar;
    lpDisplayName: PAnsiChar;
    ServiceStatus: TServiceStatus;
  end;

function EnumServicesStatus(hSCManager: SC_HANDLE; dwServiceType,
  dwServiceState: DWORD; var lpServices: TEnumServiceStatus; cbBufSize: DWORD;
  var pcbBytesNeeded, lpServicesReturned, lpResumeHandle: DWORD): BOOL; stdcall; external 'advapi32.dll' name 'EnumServicesStatusA';
function OpenSCManager(lpMachineName, lpDatabaseName: PChar;
  dwDesiredAccess: cardinal): SC_HANDLE; stdcall;  external 'advapi32.dll' name 'OpenSCManagerA';
function OpenService(hSCManager: SC_HANDLE; lpServiceName: PChar;
  dwDesiredAccess: DWORD): SC_HANDLE; stdcall; external 'advapi32.dll' name 'OpenServiceA';
function StartService(hService: SC_HANDLE; dwNumServiceArgs: DWORD;
  var lpServiceArgVectors: PChar): BOOL; stdcall; external 'advapi32.dll' name 'StartServiceA';
function CloseServiceHandle(hSCObject: SC_HANDLE): BOOL; stdcall; external 'advapi32.dll' name 'CloseServiceHandle';
function ControlService(hService: SC_HANDLE; dwControl: DWORD;
  var lpServiceStatus: TServiceStatus): BOOL; stdcall; external 'advapi32.dll' name 'ControlService';

procedure THIServiceTools._work_doStart;
var   schService,schSCManager: cardinal;
      p: PChar;
begin
   p := nil;
   schSCManager := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
   if schSCManager = 0 then
      _hi_CreateEvent(_Data,@_event_onStatus,1)
   else begin
      schService := OpenService(schSCManager, PChar(ReadString(_Data,_data_Name,_prop_Name)), SERVICE_ALL_ACCESS);
      if schService = 0 then
         _hi_CreateEvent(_Data,@_event_onStatus,2)
      else if not startService(schService, 0, p) then
         _hi_CreateEvent(_Data,@_event_onStatus,3)
      else begin
         _hi_CreateEvent(_Data,@_event_onStatus,0);
         CloseServiceHandle(schService);
      end;
      CloseServiceHandle(schSCManager);
   end;
end;

function ServiceCntl(const Name:string; Cmd:DWORD):byte;
var   schService, schSCManager: DWORD;
      ss: _SERVICE_STATUS;
begin
   schSCManager := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
   if schSCManager = 0 then
      Result := 1
   else begin
      schService := OpenService(schSCManager, PChar(Name), SERVICE_ALL_ACCESS);
      if schService = 0 then
         Result := 2
      else if not ControlService(schService,Cmd , SS) then
         Result := 3
      else begin
         CloseServiceHandle(schService);
         Result := 0;
      end;
      CloseServiceHandle(schSCManager);
   end;
end;

procedure THIServiceTools._work_doStop;
begin
   _hi_OnEvent(_event_onStatus,ServiceCntl(ReadString(_Data,_data_Name,_prop_Name),SERVICE_CONTROL_STOP));
end;

procedure THIServiceTools._work_doContinue;
begin
   _hi_CreateEvent(_Data,@_event_onStatus,ServiceCntl(ReadString(_Data,_data_Name,_prop_Name),SERVICE_CONTROL_CONTINUE));
end;

procedure THIServiceTools._work_doPause;
begin
   _hi_CreateEvent(_Data,@_event_onStatus,ServiceCntl(ReadString(_Data,_data_Name,_prop_Name),SERVICE_CONTROL_PAUSE));
end;

procedure THIServiceTools._work_doShutdown;
begin
   _hi_CreateEvent(_Data,@_event_onStatus,ServiceCntl(ReadString(_Data,_data_Name,_prop_Name),SERVICE_CONTROL_SHUTDOWN));
end;

function GetFullPath(s:string) : string;
var   FName: PChar;
      Buffer: array[0..MAX_PATH - 1] of Char;
begin
   SetString(Result, Buffer, GetFullPathName(PChar(s), SizeOf(Buffer), Buffer, FName));
end;

procedure THIServiceTools._work_doInstall;
var   Fn:string;
begin
   Fn := GetFullPath(ReadString(_Data,_data_FileName,_prop_FileName));
   if WinExec(PChar(trim(Fn + ' /install')),SW_HIDE) > 31 then
      _hi_CreateEvent(_Data,@_event_onExecService)
   else
      _hi_CreateEvent(_Data,@_event_onExecError);      
end;

procedure THIServiceTools._work_doUnInstall;
var   Fn:string;
begin
   Fn := GetFullPath(ReadString(_Data,_data_FileName,_prop_FileName));
   if WinExec(PChar(trim(Fn + ' /uninstall')),SW_HIDE) > 31 then
      _hi_CreateEvent(_Data,@_event_onExecService)
   else
      _hi_CreateEvent(_Data,@_event_onExecError);      
end;

procedure THIServiceTools._work_doGetStatus;
begin
  EnumService(ReadString(_Data,_data_Name,_prop_Name));
end;

procedure THIServiceTools._work_doEnumServices;
begin
  EnumService('');
end;

procedure THIServiceTools._var_StatusService;
begin
  dtInteger(_Data, StatusService);
end;

procedure THIServiceTools.EnumService;
var
 SCManagerHandle : THandle;
 lpServices : array of TEnumServiceStatus;
 pcbBytesNeeded, lpServicesReturned, lpResumeHandle: Cardinal;
 ServiceMode, ServiceStatus : integer;
 i : integer;
 dt, dn, ds: TData;
 FoundName: boolean;
begin
  // 1. Подключение к менеджеру сервисов
  SCManagerHandle := OpenSCManager(nil, nil, SC_MANAGER_ENUMERATE_SERVICE);
  case _prop_ServiceType of
    0: ServiceMode := SERVICE_WIN32;
    1: ServiceMode := SERVICE_DRIVER;
    2: ServiceMode := SERVICE_WIN32 or SERVICE_DRIVER
  else
    ServiceMode := SERVICE_WIN32 or SERVICE_DRIVER;  
  end;  
  case _prop_ServiceState of
    0: ServiceStatus := SERVICE_ACTIVE;
    1: ServiceStatus := SERVICE_INACTIVE;
    2: ServiceStatus := SERVICE_STATE_ALL
  else
    ServiceStatus := SERVICE_STATE_ALL;  
  end;          
  // ResumeHandle := 0 !! Это важно, т.к. это задает пречисление сервисов с начала
  lpResumeHandle := 0;
  FoundName := false;

  repeat
    // 2. Установка размера массива
    SetLength(lpServices, 50);
    // 3. Запрос списка сервисов
    EnumServicesStatus(SCManagerHandle,
                       ServiceMode,
                       ServiceStatus,
                       lpServices[0],
                       Length(lpServices) * SizeOf(TEnumServiceStatus),
                       pcbBytesNeeded,
                       lpServicesReturned,
                       lpResumeHandle);
    // 4. Вывод полученных данных
    if Name = '' then
    begin
      for i := 0 to lpServicesReturned - 1 do
      begin
        dtString(dt, lpServices[i].lpServiceName);
        dtString(dn, lpServices[i].lpDisplayName);
        dtInteger(ds, lpServices[i].ServiceStatus.dwCurrentState); 
        dt.ldata:= @dn;
        dn.ldata:= @ds;
        _hi_onEvent_(_event_onEnumServices, dt);
      end;  
    end
    else
    begin    
      StatusService := 0; 
      for i := 0 to lpServicesReturned - 1 do
        if lpServices[i].lpServiceName = Name then
        begin
          StatusService := lpServices[i].ServiceStatus.dwCurrentState;
          FoundName := true;        
          break;
        end;  
    end;  
    SetLength(lpServices, 0);
  until (lpResumeHandle = 0) or FoundName;
  if Name <> '' then _hi_onEvent(_event_onGetStatus, StatusService);
  // 5. Закрытие менеджера
  CloseServiceHandle(SCManagerHandle);
end;

end.