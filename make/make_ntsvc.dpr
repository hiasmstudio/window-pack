library make_ntsvc;

uses kol,windows,CGTShare in '..\..\CGTShare.pas';

type
  TCGrec = record
    MainForm:string;
    Units,IBody:PStrList;
  end;
  PCGrec = ^TCGrec;

  SERVICE_STATUS = record
    dwServiceType:DWORD;
    dwCurrentState:DWORD;
    dwControlsAccepted:DWORD;
    dwWin32ExitCode:DWORD;
    dwServiceSpecificExitCode:DWORD;
    dwCheckPoint:DWORD;
    dwWaitHint:DWORD;
  end;

const
  SERVICE_QUERY_CONFIG           = $001;
  SERVICE_CHANGE_CONFIG          = $002;
  SERVICE_QUERY_STATUS           = $004;
  SERVICE_ENUMERATE_DEPENDENTS   = $008;
  SERVICE_START                  = $010;
  SERVICE_STOP                   = $020;
  SERVICE_PAUSE_CONTINUE         = $040;
  SERVICE_INTERROGATE            = $080;
  SERVICE_USER_DEFINED_CONTROL   = $100;

  SERVICE_STOPPED          = $1;
  SERVICE_START_PENDING    = $2;
  SERVICE_STOP_PENDING     = $3;
  SERVICE_RUNNING          = $4;
  SERVICE_CONTINUE_PENDING = $5;
  SERVICE_PAUSE_PENDING    = $6;
  SERVICE_PAUSED           = $7;

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

  SC_MANAGER_CONNECT             = $1;
  SC_MANAGER_CREATE_SERVICE      = $2;
  SC_MANAGER_ENUMERATE_SERVICE   = $4;
  SC_MANAGER_LOCK                = $8;
  SC_MANAGER_QUERY_LOCK_STATUS   = $10;
  SC_MANAGER_MODIFY_BOOT_CONFIG  = $20;

  SERVICE_ALL_ACCESS = $F01FF;

function CloseServiceHandle(scHandle:THandle):boolean; stdcall; forward;
function OpenSCManager(lpszMachineName,lpszDatabaseName:PChar; dwAccess:DWORD):THandle; stdcall; forward;
function OpenService(hSCM:THandle; lpServiceName:PChar; dwDesiredAccess:DWORD):THandle; stdcall; forward;
function StartService(hSvc:THandle; dwNumArgs:DWORD; lplpszArgs:pointer):boolean; stdcall; forward;
function QueryServiceStatus(hSvc:THandle; var lpStatus:SERVICE_STATUS):boolean; stdcall; forward;
function ControlService(hSvc:THandle; dwControl:DWORD; var lpStatus:SERVICE_STATUS):boolean; stdcall; forward;

function CloseServiceHandle; external 'ADVAPI32.DLL' name 'CloseServiceHandle';
function OpenSCManager; external 'ADVAPI32.DLL' name 'OpenSCManagerA';
function OpenService; external 'ADVAPI32.DLL' name 'OpenServiceA';
function StartService; external 'ADVAPI32.DLL' name 'StartServiceA';
function QueryServiceStatus; external 'ADVAPI32.DLL' name 'QueryServiceStatus';
function ControlService; external 'ADVAPI32.DLL' name 'ControlService';

function buildGetParamsProc(var params:TBuildParams):integer; cdecl;
begin
  params.flags := CGMP_RUN+CGMP_RUN_DEBUG;
  Result := CG_SUCCESS;
end;

function buildMakePrj(const params:TBuildMakePrjRec):integer; cdecl;
var Res:PStrList; P:PCGrec; i:integer; s:string;
begin
  Res := NewStrList; P := params.result;
  for i := 0 to p.IBody.Count-1 do if pos('_prop_ServiceName',p.IBody.Items[i])>0 then begin
    s := p.IBody.Items[i]; GetTok(s,''''); s := GetTok(s,'''');
    SetEnvironmentVariable('HiAsmServiceName',PChar(s));
    break;
  end;
  Res.Add('Program HiAsm;');
  Res.Add('{$R allres.res}');
  Res.Add('uses');
  for i := 0 to p.Units.Count-1 do
    Res.Add('  ' + p.Units.Items[i] + ',');
  Res.Add('  kol,Share;');     
  Res.Add('');
  Res.Add('procedure DestroyClassMain;');
  Res.Add('begin');
  Res.Add('   ClassMain.Destroy;');
  Res.Add('end;');
  Res.Add('');
  Res.Add('begin');
  Res.Add('   ClassMain := TClass' + p.MainForm + '.Create;');
  Res.Add('   if ParamStr(1)=''/install'' then');
  Res.Add('     ClassMain.' + p.MainForm + '.Install');
  Res.Add('   else if ParamStr(1)=''/uninstall'' then');
  Res.Add('     ClassMain.' + p.MainForm + '.Uninstall');
  Res.Add('   else begin');
  Res.Add('     ClassMain.' + p.MainForm + '.CleanUp := @DestroyClassMain;');
  Res.Add('     ClassMain.' + p.MainForm + '.Start;');
  Res.Add('   end;');
  Res.Add('end.');
  Res.SaveToFile(params.prjFileName);
  Res.Free;
  Result := CG_SUCCESS;
end;

function buildCompliteProc(const params:TBuildCompliteRec):integer; cdecl;
var src:string;
begin
  src := ExtractFilePath(params.prjFilename) + ExtractFileNameWOext(params.prjFilename) + '.exe';
  MoveFile(PChar(src), PChar(params.appFilename));
  Result := CG_SUCCESS;
end;

function buildRunProc(var params:TBuildRunRec):integer; cdecl;
var hSCMgr,hSvc:THandle; ServiceName:string; ssStatus:SERVICE_STATUS;
begin
  Result := CG_APP_NOT_FOUND;
  hSCMgr := OpenSCManager(nil,nil,SC_MANAGER_ENUMERATE_SERVICE);
  if hSCMgr=0 then begin
    MessageBox(0,'Can''t open service database.','Error',MB_ICONSTOP);
    exit;
  end;
  SetLength(ServiceName,256);
  SetLength(ServiceName,GetEnvironmentVariable('HiAsmServiceName',@ServiceName[1],256));
  hSvc := OpenService(hSCMgr,PChar(ServiceName),SERVICE_ALL_ACCESS);
  if hSvc=0 then begin
    if GetLastError()=ERROR_SERVICE_DOES_NOT_EXIST then
      MessageBox(0,'Service not found.','Error',MB_ICONSTOP)
    else
      MessageBox(0,'Can''t open service.','Error',MB_ICONSTOP);
  end else begin
    StartService(hSvc,0,nil);
    QueryServiceStatus(hSvc,ssStatus);
    while ssStatus.dwCurrentState=SERVICE_START_PENDING do begin
      Sleep(ssStatus.dwWaitHint);
      QueryServiceStatus(hSvc,ssStatus);
    end;
    CloseServiceHandle(hSvc);
    repeat
      Sleep(200);
      hSvc := OpenService(hSCMgr,PChar(ServiceName),SERVICE_QUERY_STATUS);
      QueryServiceStatus(hSvc,ssStatus);
      CloseServiceHandle(hSvc);
    until ssStatus.dwCurrentState=SERVICE_STOPPED;
  end;
  CloseServiceHandle(hSCMgr);
  Result := CG_SUCCESS;
end;

function buildStopProc(var params:TBuildRunRec):integer; cdecl;
var hSCMgr,hSvc:THandle; ServiceName:string; ssStatus:SERVICE_STATUS;
begin
  Result := CG_APP_NOT_FOUND;
  hSCMgr := OpenSCManager(nil,nil,SC_MANAGER_ENUMERATE_SERVICE);
  if hSCMgr=0 then begin
    MessageBox(0,'Can''t open service database.','Error',MB_ICONSTOP);
    exit;
  end;
  SetLength(ServiceName,256);
  SetLength(ServiceName,GetEnvironmentVariable('HiAsmServiceName',@ServiceName[1],256));
  hSvc := OpenService(hSCMgr,PChar(ServiceName),SERVICE_ALL_ACCESS);
  if hSvc=0 then begin
    if GetLastError()=ERROR_SERVICE_DOES_NOT_EXIST then
      MessageBox(0,'Service not found.','Error',MB_ICONSTOP)
    else
      MessageBox(0,'Can''t open service.','Error',MB_ICONSTOP);
  end else begin
    ControlService(hSvc,SERVICE_CONTROL_STOP,ssStatus);
    QueryServiceStatus(hSvc,ssStatus);
    while ssStatus.dwCurrentState=SERVICE_STOP_PENDING do begin
      Sleep(ssStatus.dwWaitHint);
      QueryServiceStatus(hSvc,ssStatus);
    end;
    CloseServiceHandle(hSvc);
  end;
  CloseServiceHandle(hSCMgr);
  Result := CG_SUCCESS;
end;

exports
    buildGetParamsProc,
    buildMakePrj,
    buildCompliteProc,
    buildRunProc,
    buildStopProc;

begin
end.
