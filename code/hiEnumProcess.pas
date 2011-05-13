unit hiEnumProcess; { Расширенное управление процессами в 32х разрядных ОС ver 3.10 }

interface

uses Windows,Messages,Kol,Share,tlhelp32,Debug;

const     
   NORMAL_PRIORITY_CLASS       = $00000020;
   IDLE_PRIORITY_CLASS         = $00000040;
   HIGH_PRIORITY_CLASS         = $00000080;
   REALTIME_PRIORITY_CLASS     = $00000100;
   BELOW_NORMAL_PRIORITY_CLASS = $00004000;
   ABOVE_NORMAL_PRIORITY_CLASS = $00008000;
   LIST_MODULES_ALL            = $00000003;
   PROCESS_QUERY_LIMITED_INFORMATION = $1000;      

type
  PROCESS_BASIC_INFORMATION = packed record
    ExitStatus: DWORD;
    PebBaseAddress: Pointer;
    AffinityMask: DWORD;
    BasePriority: DWORD;
    uUniqueProcessId: Ulong;
    uInheritedFromUniqueProcessId: Ulong;
  end;
  
type
   TCB = function: boolean of object;
   ThiEnumProcess = class(TDebug)
   private
      DebugPrivilege: boolean;
      ID:Cardinal;
      PName, FFullPath:string;
      OCMajorVersion: Cardinal;
      procEntry:PROCESSENTRY32;
      procedure Enum(CallBack:TCB);
      procedure EnumNT(CallBack:TCB);
      function EnumAll: boolean;
      function FindID: boolean;
      function FindName: boolean;
   public
      _prop_Name: string;
      _prop_TimeOut:integer;
      _data_ID:THI_Event;
      _data_Name:THI_Event;
      _data_AffinityMask:THI_Event;
      _data_PriorityBoost:THI_Event;
      _data_PriorityClass:THI_Event;
      _event_onProcess:THI_Event;
      _event_onTerminateApp:THI_Event;
      _event_onGetPriority:THI_Event;
      _event_onGetProc:THI_Event;
      _event_onGetProcBoost:THI_Event;
      _event_onGetMemoryInfo:THI_Event;
      _event_onGetProcessAccount:THI_Event;
      _event_onFind:THI_Event;
      _event_onNotFind:THI_Event;
      _event_onEndEnum:THI_Event;

   property  _prop_DebugPrivilege:boolean write DebugPrivilege;
   procedure _work_doDebugPrivilege(var _Data:TData; Index:word);
   procedure _work_doEnum(var _Data:TData; Index:word);
   procedure _work_doFindID(var _Data:TData; Index:word);
   procedure _work_doFindName(var _Data:TData; Index:word);
   procedure _work_doKill(var _Data:TData; Index:word);
   procedure _work_doTerminateApp(var _Data:TData; Index:word);   
   procedure _work_doSetPriority(var _Data:TData; Index:word);
   procedure _work_doSetProc(var _Data:TData; Index:word);
   procedure _work_doSetProcBoost(var _Data:TData; Index:word);
   procedure _work_doGetPriority(var _Data:TData; Index:word);
   procedure _work_doGetMemoryInfo(var _Data:TData; Index:word);
   procedure _work_doGetProcessAccount(var _Data:TData; Index:word);
   procedure _work_doGetProc(var _Data:TData; Index:word);
   procedure _work_doGetProcBoost(var _Data:TData; Index:word);
   procedure _var_CurrentID(var _Data:TData; Index:word);
   procedure _var_CurrParentID(var _Data:TData; Index:word);   
   procedure _var_FileName(var _Data:TData; Index:word);
   procedure _var_CPUCount(var _Data:TData; Index:word);
   procedure _var_FullPath(var _Data:TData; Index:word);   
end;

type
   PPSID = ^PSID;
   PPACL = ^PACL;
   SIZE_T = LONGWORD;

type
  PPROCESS_MEMORY_COUNTERS = ^PROCESS_MEMORY_COUNTERS;
  _PROCESS_MEMORY_COUNTERS = packed record
     cb: DWORD;
     PageFaultCount: DWORD;
     PeakWorkingSetSize: SIZE_T;
     WorkingSetSize: SIZE_T;
     QuotaPeakPagedPoolUsage: SIZE_T;
     QuotaPagedPoolUsage: SIZE_T;
     QuotaPeakNonPagedPoolUsage: SIZE_T;
     QuotaNonPagedPoolUsage: SIZE_T;
     PagefileUsage: SIZE_T;
     PeakPagefileUsage: SIZE_T;
  end;
  PROCESS_MEMORY_COUNTERS = _PROCESS_MEMORY_COUNTERS;
  TProcessMemoryCounters = PROCESS_MEMORY_COUNTERS;
  PProcessMemoryCounters = PPROCESS_MEMORY_COUNTERS;

function GetSecurityInfo(handle: THandle; ObjectType: DWORD; SecurityInfo: DWORD;
         ppsidOwner, ppsidGroup: PPSID; ppDacl, ppSacl: PPACL; var ppSecurityDescriptor:
         PSecurityDescriptor): DWORD; stdcall; external 'advapi32.dll';
function GetProcessPriorityBoost(hThread: THandle; var DisablePriorityBoost: Bool): BOOL; stdcall; external kernel32 name 'GetProcessPriorityBoost';
function SetProcessPriorityBoost(hThread: THandle; DisablePriorityBoost: Bool): BOOL; stdcall;  external kernel32 name 'SetProcessPriorityBoost';
function GetProcessAffinityMask(hProcess: THandle; var lpProcessAffinityMask, lpSystemAffinityMask: DWORD): BOOL; stdcall;  external kernel32 name 'GetProcessAffinityMask';
function SetProcessAffinityMask(hProcess: THandle; dwProcessAffinityMask: DWORD): BOOL; stdcall;  external kernel32 name 'SetProcessAffinityMask';

implementation

type
   TEnumProcesses = function (lpidProcess: LPDWORD; cb: DWORD; var cbNeeded: DWORD): BOOL stdcall;
   TEnumProcessModules = function (hProcess: THandle; lphModule: LPDWORD; cb: DWORD;  var lpcbNeeded: DWORD): BOOL stdcall;
   TEnumProcessModulesEx = function (hProcess: THandle; lphModule: LPDWORD; cb: DWORD;  var lpcbNeeded: DWORD; dwFilterFlag: DWORD): BOOL stdcall;
   TGetModuleFileNameExA = function (hProcess: THandle; hModule: HMODULE;lpFilename: PAnsiChar; nSize: DWORD): DWORD stdcall;
   TGetProcessMemoryInfo = function (hProcess: THandle; ppsmemCounters: PPROCESS_MEMORY_COUNTERS; cb: DWORD): BOOL; stdcall;
   TNtQueryInformationProcess = function(ProcessHandle: THandle; ProcessInformationClass: Byte; ProcessInformation: Pointer; ProcessInformationLength: ULONG; ReturnLength : PULONG): DWORD; stdcall;
   TQueryFullProcessImageNameA = function(Process: THandle; Flags: DWORD; Buffer: PChar; Size: PDWORD): DWORD; stdcall;
var
   hPSAPI: THandle;
   hNTDLL: THandle;
   hKRNL: THandle;     
   EnumProcesses: TEnumProcesses;
   EnumProcessModules: TEnumProcessModules;
   EnumProcessModulesEx: TEnumProcessModulesEx;   
   GetModuleFileNameEx: TGetModuleFileNameExA;
   GetProcessMemoryInfo: TGetProcessMemoryInfo;
   NtQueryInformationProcess : TNtQueryInformationProcess;   
   QueryFullProcessImageNameA : TQueryFullProcessImageNameA;

procedure SetDebugPrivilege(Enabled : Boolean);
var   hToken : THandle;
      TokenPriv, PrevTokenPriv : TOKEN_PRIVILEGES;
      Tmp : Cardinal;
begin
   OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken);
   LookupPrivilegeValue(nil, 'SeDebugPrivilege', TokenPriv.Privileges[0].Luid);
   TokenPriv.PrivilegeCount := 1;
   TokenPriv.Privileges[0].Attributes := 0;
   if Enabled then TokenPriv.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
   Tmp := 0;
   PrevTokenPriv := TokenPriv;
   AdjustTokenPrivileges(hToken, False, TokenPriv, SizeOf(PrevTokenPriv), PrevTokenPriv, Tmp);
   CloseHandle(hToken);
end;

function GetProcessAccount(proc: THandle) : string;
const SE_KERNEL_OBJECT = 6;
var   sd : PSecurityDescriptor;
      snu : SID_NAME_USE;
      DomainName, UserName : PChar;
      UserNameSize, DomainNameSize : cardinal;
      sid : PSid;
begin
   Result := '';
   if GetSecurityInfo(proc, SE_KERNEL_OBJECT, OWNER_SECURITY_INFORMATION, @sid, nil, nil, nil, sd) = ERROR_SUCCESS then
   begin
      UserNameSize := 1024; GetMem(UserName, UserNameSize);
      DomainNameSize := 1024; GetMem(DomainName, DomainNameSize);
      if LookupAccountSid(nil, sid, UserName, UserNameSize, DomainName, DomainNameSize, snu) then Result := UpperCase(DomainName);
      if Result = 'BUILTIN' then Result := 'SYSTEM' else Result := UserName;  
      LocalFree(Integer(sd));
      FreeMem(UserName);
      FreeMem(DomainName);
   end;
end;

function TerminateApp(ProcessID: DWORD; Timeout: DWORD): Integer;
var
  ProcessHandle: THandle;

  function EnumWindowsProc(Wnd: HWND; ProcessID: DWORD): Boolean; stdcall;
  var
    PID: DWORD;
  begin
    GetWindowThreadProcessId(Wnd, @PID);
    if ProcessID = PID then
      PostMessage(Wnd, WM_CLOSE, 0, 0);
    Result := True;
  end;

begin
  Result := -1;
  if ProcessID <> GetCurrentProcessId then
  begin
    ProcessHandle := OpenProcess(SYNCHRONIZE or PROCESS_TERMINATE, False, ProcessID);
    try
      if ProcessHandle <> 0 then
      begin
        EnumWindows(@EnumWindowsProc, LPARAM(ProcessID));
        if WaitForSingleObject(ProcessHandle, Timeout) = WAIT_OBJECT_0 then
          Result := 0
        else
          if TerminateProcess(ProcessHandle, 1) then
            Result := 1;
      end;
    finally
      CloseHandle(ProcessHandle);
    end;
  end;
end;

procedure ThiEnumProcess._work_doKill;
var
  proc: THandle;
begin
  SetDebugPrivilege(DebugPrivilege);
  proc := OpenProcess(PROCESS_TERMINATE,true,procEntry.th32ProcessID);
  TerminateProcess(proc, 1);
  CloseHandle(proc);
end;

procedure ThiEnumProcess._work_doTerminateApp;
begin
  SetDebugPrivilege(DebugPrivilege);
  _hi_onEvent(_event_onTerminateApp, TerminateApp(procEntry.th32ProcessID, _prop_TimeOut)); 
end;

procedure Init(OCMajorVersion: DWORD);
begin
   if hPSAPI = 0 then
   begin
     hPSAPI := LoadLibrary('PSAPI.dll');
     @EnumProcesses        := GetProcAddress(hPSAPI, 'EnumProcesses');
     if OCMajorVersion < 6 then
       @EnumProcessModules   := GetProcAddress(hPSAPI, 'EnumProcessModules')
     else  
       @EnumProcessModulesEx := GetProcAddress(hPSAPI, 'EnumProcessModulesEx');
     @GetModuleFileNameEx    := GetProcAddress(hPSAPI, 'GetModuleFileNameExA');
     @GetProcessMemoryInfo   := GetProcAddress(hPSAPI, 'GetProcessMemoryInfo');
   end;
   if hNTDLL = 0 then
   begin
     hNTDLL := LoadLibrary('ntdll.dll');
     @NtQueryInformationProcess := GetProcAddress(hNTDLL, 'NtQueryInformationProcess');
   end;
   if (hKRNL = 0) and (OCMajorVersion >= 6) then
   begin
     hKRNL := LoadLibrary('kernel32.dll');
     @QueryFullProcessImageNameA := GetProcAddress(hKRNL, 'QueryFullProcessImageNameA');
   end;  
    
end;

procedure ThiEnumProcess.EnumNT;
var   PIDArray: array [0..1023] of DWORD;
      cb: DWORD;
      i: Integer;
      ProcCount: Integer;
      hProcess: THandle;
      S: DWORD;      
begin
   Init(OCMajorVersion);
   EnumProcesses(@PIDArray, SizeOf(PIDArray), cb);
   ProcCount := cb div SizeOf(DWORD);
   for I := 0 to ProcCount - 1 do
   begin
     hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, PIDArray[I]);
     if (hProcess <> 0) then
     begin
       if OCMajorVersion < 6 then
         GetModuleFilenameEx(hProcess, 0, procEntry.szExeFile, SizeOf(procEntry.szExeFile))
       else
       begin
         CloseHandle(hProcess);
         hProcess := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, PIDArray[I]);
         S := SizeOf(procEntry.szExeFile);  
         QueryFullProcessImageNameA(hProcess, 0, procEntry.szExeFile, @S);
       end;
       procEntry.th32ProcessID := PIDArray[I];
       if not CallBack() then Break;
       CloseHandle(hProcess);
     end;
   end;
    _hi_OnEvent(_event_onEndEnum);
end;

procedure ThiEnumProcess.Enum;
var   hSnapshot: Cardinal;
      res: boolean;
      ovi: TOSVersionInfo;
begin
   ovi.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
   GetVersionEx(ovi);
   OCMajorVersion := ovi.dwMajorVersion;
   if ovi.dwPlatformId = VER_PLATFORM_WIN32_NT then begin
      EnumNT(CallBack);
      Exit;
   end;
   hSnapshot := CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );
   if( hSnapshot = INVALID_HANDLE_VALUE ) then exit;
   procEntry.dwSize := sizeof( PROCESSENTRY32 );
   res := Process32First( hSnapshot, procEntry );
   while res and CallBack do res := Process32Next( hSnapshot, procEntry );
   CloseHandle( hSnapshot );
end;

function ThiEnumProcess.EnumAll;
begin
   if procEntry.szExeFile <> '' then _hi_OnEvent( _event_onProcess, procEntry.szExeFile );
   Result := true;
end;

procedure ThiEnumProcess._work_doEnum;
begin
   SetDebugPrivilege(DebugPrivilege);
   Enum(EnumAll);
   FillChar(procEntry,sizeof(procentry),0);
end;

procedure ThiEnumProcess._work_doDebugPrivilege;
begin
   DebugPrivilege := ReadBool(_Data);
end;

function ThiEnumProcess.FindID;
begin
   Result := ID <> procEntry.th32ProcessID;
end;

procedure ThiEnumProcess._work_doFindID;
begin
   ID := ReadInteger(_Data,_data_ID,0);
   SetDebugPrivilege(DebugPrivilege);
   Enum(FindID);
   if ID = procEntry.th32ProcessID then
   begin
      FFullPath := procEntry.szExeFile;
      _hi_CreateEvent(_Data,@_event_onFind);
   end   
   else
   begin
      FFullPath := '';
      _hi_CreateEvent(_Data,@_event_onNotFind);
   end;
end;

function ThiEnumProcess.FindName;
begin
   Result := PName <> ExtractFileName(LowerCase(procEntry.szExeFile));
end;

procedure ThiEnumProcess._work_doFindName;
begin
   PName := LowerCase(ReadString(_Data,_data_Name,_prop_Name));
   SetDebugPrivilege(DebugPrivilege);
   Enum(FindName);
   if PName = ExtractFileName(LowerCase(procEntry.szExeFile)) then
   begin
      FFullPath := procEntry.szExeFile; 
      _hi_CreateEvent(_Data,@_event_onFind);
   end   
   else
   begin
      FFullPath := '';
      _hi_CreateEvent(_Data,@_event_onNotFind);
   end;   
end;

procedure ThiEnumProcess._work_doGetPriority;
var   proc: THandle;
      pc: Cardinal;
begin
   SetDebugPrivilege(DebugPrivilege);
   proc := OpenProcess(PROCESS_QUERY_INFORMATION,true,procEntry.th32ProcessID);
   pc:= integer(GetPriorityClass(proc));
   case pc of
      NORMAL_PRIORITY_CLASS       : _hi_OnEvent(_event_onGetPriority,0);
      IDLE_PRIORITY_CLASS         : _hi_OnEvent(_event_onGetPriority,1);
      HIGH_PRIORITY_CLASS         : _hi_OnEvent(_event_onGetPriority,2);
      REALTIME_PRIORITY_CLASS     : _hi_OnEvent(_event_onGetPriority,3);
      BELOW_NORMAL_PRIORITY_CLASS : _hi_OnEvent(_event_onGetPriority,4);
      ABOVE_NORMAL_PRIORITY_CLASS : _hi_OnEvent(_event_onGetPriority,5);
   end;
   CloseHandle(proc);
end;

procedure ThiEnumProcess._work_doGetProc;
var   proc: THandle;
      lpProcessAffinityMask, lpSystemAffinityMask: dword;
begin
   SetDebugPrivilege(DebugPrivilege);
   proc := OpenProcess(PROCESS_QUERY_INFORMATION,true,procEntry.th32ProcessID);
   GetProcessAffinityMask(proc, lpProcessAffinityMask, lpSystemAffinityMask);
   _hi_CreateEvent(_Data,@_event_onGetProc, {$ifdef F_P}integer{$endif}(lpProcessAffinityMask));
   CloseHandle(proc);
end;

procedure ThiEnumProcess._work_doGetMemoryInfo;
var   proc: THandle;
      pmc: TProcessMemoryCounters;
begin
   SetDebugPrivilege(DebugPrivilege);
   proc := OpenProcess(PROCESS_ALL_ACCESS,true,procEntry.th32ProcessID);
   if GetProcessMemoryInfo(proc, @pmc, sizeof(TProcessMemoryCounters)) then
      _hi_CreateEvent(_Data,@_event_onGetMemoryInfo, {$ifdef F_P}integer{$endif}(pmc.WorkingSetSize));
   CloseHandle(proc);
end;

procedure ThiEnumProcess._work_doGetProcessAccount;
var   proc: THandle;
begin
   SetDebugPrivilege(DebugPrivilege);
   proc := OpenProcess(PROCESS_ALL_ACCESS,true,procEntry.th32ProcessID);
   _hi_CreateEvent(_Data,@_event_onGetProcessAccount, GetProcessAccount(proc));
   CloseHandle(proc);
end;

procedure ThiEnumProcess._work_doGetProcBoost;
var   proc: THandle;
      DisablePriorityBoost: Bool;
begin
   SetDebugPrivilege(DebugPrivilege);
   proc := OpenProcess(PROCESS_QUERY_INFORMATION,true,procEntry.th32ProcessID);
   GetProcessPriorityBoost(proc,DisablePriorityBoost);
   if DisablePriorityBoost then
      _hi_CreateEvent(_Data,@_event_onGetProcBoost,0)
   else
      _hi_CreateEvent(_Data,@_event_onGetProcBoost,1);
   CloseHandle(proc);
end;

procedure ThiEnumProcess._work_doSetPriority;
var   proc: THandle;
      pc: cardinal;
begin
   SetDebugPrivilege(DebugPrivilege);
   proc := OpenProcess(PROCESS_SET_INFORMATION,true,procEntry.th32ProcessID);
   case Readinteger(_Data,_data_PriorityClass,0) of
      0: pc := NORMAL_PRIORITY_CLASS;
      1: pc := IDLE_PRIORITY_CLASS;
      2: pc := HIGH_PRIORITY_CLASS;
      3: pc := REALTIME_PRIORITY_CLASS;
      4: pc := BELOW_NORMAL_PRIORITY_CLASS;
      5: pc := ABOVE_NORMAL_PRIORITY_CLASS;
      else pc := NORMAL_PRIORITY_CLASS;
   end;
   SetPriorityClass(proc,pc);
   CloseHandle(proc);
end;

procedure ThiEnumProcess._work_doSetProc;
var   proc: THandle;
      pc: byte;
begin
   pc:= Readinteger(_Data,_data_AffinityMask,0);
   if pc = 0 then Exit;
   SetDebugPrivilege(DebugPrivilege);
   proc := OpenProcess(PROCESS_SET_INFORMATION,true,procEntry.th32ProcessID);
   SetProcessAffinityMask(proc,pc);
   CloseHandle(proc);
end;

procedure ThiEnumProcess._work_doSetProcBoost;
var   proc: THandle;
      pc: byte;
      DisablePriorityBoost:bool;
begin
   pc:= Readinteger(_Data,_data_PriorityBoost,0);
   DisablePriorityBoost:= not boolean(pc);
   SetDebugPrivilege(DebugPrivilege);
   proc := OpenProcess(PROCESS_SET_INFORMATION,true,procEntry.th32ProcessID);
   SetProcessPriorityBoost(proc,DisablePriorityBoost);
   CloseHandle(proc);
end;

procedure ThiEnumProcess._var_CurrentID;
begin
   dtInteger(_Data, procEntry.th32ProcessID);
end;

procedure ThiEnumProcess._var_CurrParentID;
var
  dwProcessHandle: DWORD;
  
  function GetOwnedProcessID(const dwProcessHandle: DWORD): DWORD;
  var
    Info: PROCESS_BASIC_INFORMATION;
  begin
    Result := 0;
    if NtQueryInformationProcess(dwProcessHandle, 0, @Info, SizeOf(Info), nil) = NO_ERROR then
      Result := Info.uInheritedFromUniqueProcessId;
end;
begin
  SetDebugPrivilege(DebugPrivilege);
  dwProcessHandle := OpenProcess(PROCESS_ALL_ACCESS, false, procEntry.th32ProcessID);
  dtInteger(_Data, GetOwnedProcessID(dwProcessHandle));
  CloseHandle(dwProcessHandle);
end;

procedure ThiEnumProcess._var_FileName;
begin
   dtString(_Data, procEntry.szExeFile);
end;

procedure ThiEnumProcess._var_CPUCount;
var   lpSystemInfo: _SYSTEM_INFO;
begin
   GetSystemInfo(lpSystemInfo);
   dtInteger(_Data, lpSystemInfo.dwNumberOfProcessors);
end;

procedure ThiEnumProcess._var_FullPath;
begin
   dtString(_Data, FFullPath);
end;

end.