unit hiEnumProcess; { Расширенное управление процессами в линейке Windows NT }

interface

uses Windows, Messages, Kol, Share, tlhelp32, Debug;

const     
   NORMAL_PRIORITY_CLASS        = $00000020;
   IDLE_PRIORITY_CLASS          = $00000040;
   HIGH_PRIORITY_CLASS          = $00000080;
   REALTIME_PRIORITY_CLASS      = $00000100;
   BELOW_NORMAL_PRIORITY_CLASS  = $00004000;
   ABOVE_NORMAL_PRIORITY_CLASS  = $00008000;
   OBJ_KERNEL_HANDLE            = $00000200;
   SYSTEM_PROCESSES_AND_THREAD_INFORMATION = 5;
   SE_KERNEL_OBJECT             = 6;

type
   PPSID = ^PSID;
   PPACL = ^PACL;
   SIZE_T = LONGWORD;
   NTStatus = DWORD;
   PPSECURITY_DESCRIPTOR = ^PSECURITY_DESCRIPTOR;

type
  PUnicodeString = ^TUnicodeString;
  TUnicodeString = packed record
    Length: Word;
    MaximumLength: Word;
    Buffer: PWideChar;
  end;

type
  PObjectAttributes = ^TObjectAttributes;
  TObjectAttributes = packed record
    Length: DWORD;
    RootDirectory: THandle;
    ObjectName: PUnicodeString;
    Attributes: DWORD;
    SecurityDescriptor: Pointer;
    SecurityQualityOfService: Pointer;
  end;

type
  PClientID = ^TClientID;
  TClientID = packed record
    UniqueProcess:cardinal;
    UniqueThread:cardinal;
  end;

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

type 
  PPerfDataBlock = ^TPerfDataBlock; 
  TPerfDataBlock = record 
    Signature: array[0..3] of WCHAR; 
    LittleEndian: DWORD; 
    Version: DWORD; 
    Revision: DWORD; 
    TotalByteLength: DWORD; 
    HeaderLength: DWORD; 
    NumObjectTypes: DWORD; 
    DefaultObject: Longint; 
    SystemTime: TSystemTime; 
    PerfTime: TLargeInteger; 
    PerfFreq: TLargeInteger; 
    PerfTime100nSec: TLargeInteger; 
    SystemNameLength: DWORD; 
    SystemNameOffset: DWORD; 
  end; 

  PPerfObjectType = ^TPerfObjectType; 
  TPerfObjectType = record 
    TotalByteLength: DWORD; 
    DefinitionLength: DWORD; 
    HeaderLength: DWORD; 
    ObjectNameTitleIndex: DWORD; 
    ObjectNameTitle: LPWSTR; 
    ObjectHelpTitleIndex: DWORD; 
    ObjectHelpTitle: LPWSTR; 
    DetailLevel: DWORD; 
    NumCounters: DWORD; 
    DefaultCounter: Longint; 
    NumInstances: Longint; 
    CodePage: DWORD; 
    PerfTime: TLargeInteger; 
    PerfFreq: TLargeInteger; 
  end; 

  PPerfCounterDefinition = ^TPerfCounterDefinition; 
  TPerfCounterDefinition = record 
    ByteLength: DWORD; 
    CounterNameTitleIndex: DWORD; 
    CounterNameTitle: LPWSTR; 
    CounterHelpTitleIndex: DWORD; 
    CounterHelpTitle: LPWSTR; 
    DefaultScale: Longint; 
    DetailLevel: DWORD; 
    CounterType: DWORD; 
    CounterSize: DWORD; 
    CounterOffset: DWORD; 
  end; 

  PPerfInstanceDefinition = ^TPerfInstanceDefinition; 
  TPerfInstanceDefinition = record 
    ByteLength: DWORD; 
    ParentObjectTitleIndex: DWORD; 
    ParentObjectInstance: DWORD; 
    UniqueID: Longint; 
    NameOffset: DWORD; 
    NameLength: DWORD; 
  end; 

  PPerfCounterBlock = ^TPerfCounterBlock; 
  TPerfCounterBlock = record 
    ByteLength: DWORD; 
  end;

  PPROCESS_BASIC_INFORMATION = ^PROCESS_BASIC_INFORMATION;
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
      FProcessUsage: Real;
      FThread: PThread;
      FDebugPrivilege: boolean;
      ID, ScanID: Cardinal;
      PName, FFullPath: string;
      ovi: TOSVersionInfo;
      procEntry: PROCESSENTRY32;
      procedure Enum(CallBack: TCB);
      procedure EnumNT(CallBack: TCB);
      function GetProcessAccount(proc: THandle): string;
      procedure SetDebugPrivilege(Value: boolean);
      function EnumAll: boolean;
      function FindID: boolean;
      function FindName: boolean;
      function GetProcessUsage(PID:cardinal): Real;     
      function Execute(Sender: PThread): Integer;
      procedure SyncExec;      
   public
     _prop_Name: string;
     _prop_TimeOut: integer;
     _prop_TimeScan: integer;

     _data_ID,
     _data_Name,
     _data_AffinityMask,
     _data_PriorityBoost,
     _data_PriorityClass:THI_Event;

     _event_onProcess,
     _event_onTerminateApp,
     _event_onGetPriority,
     _event_onGetProc,
     _event_onGetProcBoost,
     _event_onGetMemoryInfo,
     _event_onGetProcessAccount,
     _event_onFind,
     _event_onNotFind,
     _event_onCPUUsage,
     _event_onEndEnum:THI_Event;

   constructor Create;
   destructor Destroy; override;   
   
   procedure _work_doDebugPrivilege(var _Data:TData; Index:word);
   procedure _work_doEnum(var _Data: TData; Index: Word);
   procedure _work_doFindID(var _Data: TData; Index: Word);
   procedure _work_doFindName(var _Data: TData; Index: Word);
   procedure _work_doKill(var _Data: TData; Index: Word);
   procedure _work_doTerminateApp(var _Data: TData; Index: Word);   
   procedure _work_doSetPriority(var _Data: TData; Index: Word);
   procedure _work_doSetProc(var _Data: TData; Index: Word);
   procedure _work_doSetProcBoost(var _Data: TData; Index: Word);
   procedure _work_doGetPriority(var _Data: TData; Index: Word);
   procedure _work_doGetMemoryInfo(var _Data: TData; Index: Word);
   procedure _work_doGetProcessAccount(var _Data: TData; Index: Word);
   procedure _work_doGetProc(var _Data: TData; Index: Word);
   procedure _work_doGetProcBoost(var _Data: TData; Index: Word);
   procedure _work_doStartCPUUsage(var _Data: TData; Index: Word);
   procedure _work_doStopCPUUsage(var _Data: TData; Index: Word);
   procedure _var_CurrentID(var _Data: TData; Index: Word);
   procedure _var_CurrParentID(var _Data: TData; Index: Word);   
   procedure _var_FileName(var _Data: TData; Index: Word);
   procedure _var_CPUCount(var _Data: TData; Index: Word);
   procedure _var_FullPath(var _Data: TData; Index: Word);
   procedure _var_MajorVersion(var _Data: TData; Index: Word);
   procedure _var_MinorVersion(var _Data: TData; Index: Word);   
   property _prop_DebugPrivilege: boolean write FDebugPrivilege;
end;

implementation

type
   TQueryFullProcessImageName  = function(Process: THandle; Flags: DWORD; Buffer: PChar; Size: PDWORD): DWORD; stdcall;
   TGetModuleFileNameExA       = function (hProcess: THandle; hModule: HMODULE;lpFilename: PAnsiChar; nSize: DWORD): DWORD stdcall;
   TGetProcessPriorityBoost    = function(hThread: THandle; var DisablePriorityBoost: Bool): BOOL; stdcall;
   TSetProcessPriorityBoost    = function(hThread: THandle; DisablePriorityBoost: Bool): BOOL; stdcall;
   TGetProcessAffinityMask     = function(hProcess: THandle; var lpProcessAffinityMask, lpSystemAffinityMask: DWORD): BOOL; stdcall;
   TSetProcessAffinityMask     = function(hProcess: THandle; dwProcessAffinityMask: DWORD): BOOL; stdcall;
   TGetProcessMemoryInfo       = function (hProcess: THandle; ppsmemCounters: PPROCESS_MEMORY_COUNTERS; cb: DWORD): BOOL; stdcall;
   TGetSecurityInfo            = function(Handle: THandle; ObjectType: DWORD; SecurityInfo: SECURITY_INFORMATION; ppsidOwner, ppsidGroup: PPSID;
                                          ppDacl, ppSacl: PPACL; var ppSecurityDescriptor:  PSecurityDescriptor): DWORD; stdcall;
   TZwQueryInformationProcess = function(hProcess: THandle; InformationClass: DWORD; Buffer: PChar; BufferLength : DWORD;ReturnLength: PDWORD): DWORD; stdcall;
   TZwQuerySystemInformation  = function(ASystemInformationClass: DWORD; ASystemInformation: Pointer; ASystemInformationLength: DWORD;
                                         AReturnLength: PDWORD): NTStatus; stdcall;
   TGetProcessImageFileName   = function(Process: THandle; Buffer: PChar; Size: DWORD): DWORD; stdcall;                                         

var
   hPSAPI, hNTDLL, hADVAP, hKRNL  : THandle;   
   GetProcessMemoryInfo           : TGetProcessMemoryInfo;
   GetSecurityInfo                : TGetSecurityInfo;
   ZwQueryInformationProcess      : TZwQueryInformationProcess;
   ZwQuerySystemInformation       : TZwQuerySystemInformation;
   GetProcessPriorityBoost        : TGetProcessPriorityBoost;
   SetProcessPriorityBoost        : TSetProcessPriorityBoost;
   GetProcessAffinityMask         : TGetProcessAffinityMask;
   SetProcessAffinityMask         : TSetProcessAffinityMask;
   GetModuleFileNameEx            : TGetModuleFileNameExA;
   QueryFullProcessImageName      : TQueryFullProcessImageName;
   GetProcessImageFileName        : TGetProcessImageFileName;
//**********************************************************************************

function Trim(const Str : string): string;
var
  L: integer;
begin
  Result := Str;
  L := Length(Result);
  while (L > 0) and (Result[L] <= ' ') do Dec(L);
  SetLength(Result, L);
  L := 1;
  while (L <= Length(Result)) and (Result[L] <= ' ') do Inc(L);
  Result := string(PChar(integer(@Result[1]) + L - 1)); 
end;

function WideStringToString(const ws: WideString): String;
var
  l: integer;
begin
  if ws = '' then
    Result := ''
  else
  begin
    l := WideCharToMultiByte(CP_ACP, 0, PWChar(ws), -1, nil, 0, nil, nil);
    SetLength(Result, l - 1);
    if l > 1 then
      WideCharToMultiByte(CP_ACP, 0, PWChar(ws), -1, PChar(Result), l - 1, nil, nil);
  end;
end;

//**********************************************************************************

constructor ThiEnumProcess.Create;
begin
  inherited;
  FillChar(ovi, SizeOf(TOSVersionInfo), #0); 
  ovi.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(ovi);
  if hPSAPI = 0 then
  begin
    hPSAPI := LoadLibrary('psapi.dll');
    @GetProcessMemoryInfo    := GetProcAddress(hPSAPI, 'GetProcessMemoryInfo');
    if ovi.dwMajorVersion < 6 then
      @GetModuleFileNameEx   := GetProcAddress(hPSAPI, 'GetModuleFileNameExA');
    @GetProcessImageFileName := GetProcAddress(hPSAPI, 'GetProcessImageFileNameA');       
  end;
  if hNTDLL = 0 then
  begin
    hNTDLL := LoadLibrary('ntdll.dll');
    @ZwQueryInformationProcess := GetProcAddress(hNTDLL, 'ZwQueryInformationProcess');
    @ZwQuerySystemInformation  := GetProcAddress(hNTDLL, 'ZwQuerySystemInformation');
  end;
  if hADVAP = 0 then
  begin
    hADVAP := LoadLibrary(advapi32);
    @GetSecurityInfo := GetProcAddress(hADVAP, 'GetSecurityInfo');
  end;
  if hKRNL = 0 then
  begin
    hKRNL := LoadLibrary(kernel32);
    @GetProcessPriorityBoost    := GetProcAddress(hKRNL, 'GetProcessPriorityBoost');
    @SetProcessPriorityBoost    := GetProcAddress(hKRNL, 'SetProcessPriorityBoost');
    @GetProcessAffinityMask     := GetProcAddress(hKRNL, 'GetProcessAffinityMask');
    @SetProcessAffinityMask     := GetProcAddress(hKRNL, 'SetProcessAffinityMask');
    @QueryFullProcessImageName  := GetProcAddress(hKRNL, 'QueryFullProcessImageNameA');
  end;
end;

destructor ThiEnumProcess.Destroy;
begin
  if FThread <> nil then free_and_nil(FThread);
  inherited;
end;

function ThiEnumProcess.GetProcessUsage;
var 
  pHandle : THandle;
  mCreationTime, mExitTime, mKernelTime, mUserTime: _FILETIME;
  TotalTime1, TotalTime2: int64;
begin
  SetDebugPrivilege(FDebugPrivilege);
  {We need to get a handle of the process with PROCESS_QUERY_INFORMATION privileges.}
  pHandle := OpenProcess(PROCESS_QUERY_INFORMATION, false, PID);

  {We can use the GetProcessTimes() function to get the amount of time the process has spent in kernel mode and user mode.}
  GetProcessTimes(pHandle, mCreationTime, mExitTime, mKernelTime, mUserTime);
  TotalTime1 := int64(mKernelTime.dwLowDateTime or (mKernelTime.dwHighDateTime shr 32)) +
                int64(mUserTime.dwLowDateTime or (mUserTime.dwHighDateTime shr 32));

  {Wait a little}
  Sleep(_prop_TimeScan); 

  GetProcessTimes(pHandle, mCreationTime, mExitTime, mKernelTime, mUserTime);
  TotalTime2 := int64(mKernelTime.dwLowDateTime or (mKernelTime.dwHighDateTime shr 32)) +
                int64(mUserTime.dwLowDateTime or (mUserTime.dwHighDateTime shr 32));

  {This should work out nicely, as there were approx. _prop_TimeScan between the calls
  and the result will be a percentage between 0 and 100}
  Result := ((TotalTime2 - TotalTime1) / _prop_TimeScan) / 100;

  CloseHandle(pHandle);
end;

procedure ThiEnumProcess.Execute;
begin
  repeat
    FProcessUsage := GetProcessUsage(ScanID);
    if Assigned(_event_onCPUUsage.Event) then Sender.Synchronize(SyncExec);
  until Sender.Terminated;
  Result := 0;
end;

procedure ThiEnumProcess.SyncExec;
begin
  if ScanID <> procEntry.th32ProcessID then
    free_and_nil(FThread)
  else
    _hi_onEvent(_event_onCPUUsage, FProcessUsage);
end;

procedure ThiEnumProcess._work_doStartCPUUsage;
begin
  ScanID := procEntry.th32ProcessID;
  if FThread <> nil then free_and_nil(FThread);
  FThread := {$ifdef F_P}NewThreadforFPC{$else}NewThread{$endif};
  FThread.OnExecute := Execute;
  FThread.Resume; 
end;

procedure ThiEnumProcess._work_doStopCPUUsage;
begin
  if FThread <> nil then free_and_nil(FThread);
end;

procedure ThiEnumProcess.SetDebugPrivilege;
var
  hToken: THandle;
  TokenPriv, PrevTokenPriv: TOKEN_PRIVILEGES;
  Tmp: Cardinal;
begin
  OpenProcessToken(GetCurrentProcess, TOKEN_ALL_ACCESS, hToken);
  TokenPriv.PrivilegeCount := 1;
  if Value then
    TokenPriv.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
  else
    TokenPriv.Privileges[0].Attributes := 0;    
  LookupPrivilegeValue(nil, 'SeDebugPrivilege', TokenPriv.Privileges[0].Luid);
  Tmp := 0;
  PrevTokenPriv := TokenPriv;
  AdjustTokenPrivileges(hToken, False, TokenPriv, SizeOf(PrevTokenPriv), PrevTokenPriv, Tmp);
  CloseHandle(hToken);
end;

function ThiEnumProcess.GetProcessAccount;
var
  sd: PSecurityDescriptor;
  snu: SID_NAME_USE;
  DomainName, UserName: string;
  UserNameSize, DomainNameSize: cardinal;
  sid: PSid;
begin
  Result := '';
  if GetSecurityInfo(proc, SE_KERNEL_OBJECT, OWNER_SECURITY_INFORMATION, @sid, nil, nil, nil, sd) = ERROR_SUCCESS then
  begin
    UserNameSize := 1024;
    DomainNameSize := 1024;
    SetLength(UserName, UserNameSize);
    SetLength(DomainName, DomainNameSize);
    FillChar(UserName[1], UserNameSize, #0);
    FillChar(DomainName[1], DomainNameSize, #0);         

    if LookupAccountSid(nil, sid, @UserName[1], UserNameSize, @DomainName[1], DomainNameSize, snu) then
      Result := Trim(DomainName);

    if ovi.dwMajorVersion < 6 then
      if Result = 'BUILTIN' then
        Result := 'SYSTEM'
      else
        Result := Trim(UserName)  
    else
      Result := Trim(UserName);
        
    LocalFree(Integer(sd));
  end;
end;

function EnumWindowsProc(Wnd: HWND; ProcessID: DWORD): Boolean; stdcall;
var
  PID: DWORD;
begin
  GetWindowThreadProcessId(Wnd, @PID);
  if ProcessID = PID then
    PostMessage(Wnd, WM_CLOSE, 0, 0);
  Result := True;
end;

function KillProcess(ProcessID: DWORD): Boolean;
var
  proc: THandle;
begin
  proc := OpenProcess(PROCESS_TERMINATE, true, ProcessID);
  Result := TerminateProcess(proc, 1);
  CloseHandle(proc);
end;

function TerminateApp(ProcessID: DWORD; Timeout: DWORD): Integer;
var
  ProcessHandle: THandle;
begin
  Result := -1;
  if ProcessID = GetCurrentProcessId then exit;
  ProcessHandle := OpenProcess(SYNCHRONIZE or PROCESS_TERMINATE, true, ProcessID);
  if ProcessHandle <> 0 then
  begin
    EnumWindows(@EnumWindowsProc, Lparam(ProcessID));
    if WaitForSingleObject(ProcessHandle, Timeout) = WAIT_OBJECT_0 then
      Result := 0;
  end;
  CloseHandle(ProcessHandle);

  if Result <> 0 then
    if KillProcess(ProcessHandle) then Result := 1;
end;

procedure ThiEnumProcess._work_doTerminateApp;
begin
  SetDebugPrivilege(FDebugPrivilege);
  _hi_onEvent(_event_onTerminateApp, TerminateApp(procEntry.th32ProcessID, _prop_TimeOut)); 
end;

procedure ThiEnumProcess._work_doKill;
begin
  SetDebugPrivilege(FDebugPrivilege);
  KillProcess(procEntry.th32ProcessID);
end;

//------------------------------------------------------------------------------

procedure ThiEnumProcess.EnumNT;
const
  INCREMENTAL_SIZE     = 32768; // Шаг увеличения буфера
  INITIAL_BUFFER_SIZE  = 65536; // Начальный размер буфера
  PROCESS_OBJECT_INDEX = 230;   // Индекс объекта Process
  PID_OBJECT_INDEX     = 784;   // Индекс счетчика ID Process (PID)

var
  hProcess: THandle;
  S: DWORD;
  buflen: DWORD; // текущий размер буфера
  PerfData: PPerfDataBlock; // PERF_DATA_BLOCK
  PerfObj: PPerfObjectType; // PERF_OBJECT_TYPE
  PerfCntr, CurCntr: PPerfCounterDefinition;  // PERF_COUNTER_DEFINITION
  PerfInst: PPerfInstanceDefinition;  // PERF_INSTANCE_DEFINITION
  PerfCntrBlk, PtrToCntr: PPerfCounterBlock;   // PERF_COUNTER_BLOCK
  i,k,j: Integer; // счетчики в циклах
  process_name: String; // выходная строка
  pData: PLargeInteger; // Указатель на данные счетчика
  FPart: string;
  hSnapshot: Cardinal;
  res: boolean;  
  procEnt: PROCESSENTRY32;
  path, pathstr: string;
  DeviceList: PStrListEx;    
  
  function GetOwnedProcessID(const dwProcessHandle: DWORD): DWORD;
  var
    Info: PROCESS_BASIC_INFORMATION;
  begin
    Result := 0;
    if ZwQueryInformationProcess(dwProcessHandle, 0, @Info, SizeOf(Info), nil) = NO_ERROR then
      Result := Info.uInheritedFromUniqueProcessId;
  end;

  procedure GetDeviceList(List: PStrListEx);
  var
    Root: string; 
    DeviceName: string; 
    Drives: DWORD;
    len: integer;
  begin
    Drives := GetLogicalDrives();
    Root := 'A:';
    while Drives <> 0 do
    begin 
      if (Drives and 1) = 1 then
      begin 
        SetLength(DeviceName, 256); 
        len := QueryDosDevice(@Root[1], @DeviceName[1], 256);
        if len <> 0 then
        begin 
          SetLength(DeviceName, len);
          DeviceList.AddObject(Trim(DeviceName), ord(Root[1]));
        end;  
      end;
      inc(Root[1]); 
      Drives:= Drives shr (1); 
    end;    
  end;

  function GetDeviceName(NTDevice: string): string;
  var
    ii, jj: integer;
  begin
    for ii := 0 to DeviceList.Count - 1 do
    begin
      if DeviceList.Items[ii] = Trim(NTDevice) then
      begin
        jj := DeviceList.Objects[ii]; 
        Result := char(jj) + ':\';
        break;
      end;
    end;  
  end;

begin
  SetDebugPrivilege(FDebugPrivilege);
  DeviceList := NewStrListEx;
  GetDeviceList(DeviceList); 
  buflen := INITIAL_BUFFER_SIZE;
  // Выделяем начальный буфер
  GetMem(PerfData, buflen);
TRY
  // Пытаемся заполнить буфер данными
  while RegQueryValueEx(HKEY_PERFORMANCE_DATA, PChar(Int2Str(PROCESS_OBJECT_INDEX)),
                        nil, nil, Pointer(PerfData), @buflen) = ERROR_MORE_DATA do
  begin
    // Если буфер маленький, то увеличиваем его и снова пытаемся
    inc(buflen, INCREMENTAL_SIZE);
    ReallocMem(PerfData, buflen);
  end;
  RegCloseKey(HKEY_PERFORMANCE_DATA); // Обязательно закрываем этот ключ.
  // Получаем указатель на первую структуру PERF_OBJECT_TYPE (первый инфоблок)
  PerfObj := PPerfObjectType(DWORD(PerfData) + PerfData.HeaderLength);
  // Перебираем все полученные типы объектов
  for i := 0 to PerfData.NumObjectTypes - 1 do
  begin
    // Ищем объект Process (индекс 230)
    if PerfObj.ObjectNameTitleIndex = PROCESS_OBJECT_INDEX then
    begin
      // Запоминаем расположение описаний счетчиков PERF_COUNTER_DEFINITION
      PerfCntr := PPerfCounterDefinition(DWORD(PerfObj) + PerfObj.HeaderLength);
      // Получаем экземпляры объекта Process, если они есть
      if PerfObj.NumInstances > 0 then
      begin
        // Получаем указатель на первую структуру PERF_INSTANCE_DEFINITION
        PerfInst := PPerfInstanceDefinition(DWORD(PerfObj) + PerfObj.DefinitionLength);
        // Перебираем все экземпляры объекта
        for k := 0 to PerfObj.NumInstances - 1 do
        begin
          // Получаем имя текущего экземпляра (имя процесса)
          process_name := WideCharToString(PWideChar(DWORD(PerfInst) + PerfInst.NameOffset));
          // Если имя равно '_Total', то пропускаем этот экземпляр
          // т.к. это суммарные данные для всех процессов
          if process_name = '_Total' then Continue;
          // Получаем указатель на первый счетчик PERF_COUNTER_DEFINITION
          CurCntr := PerfCntr;
          // Получаем указатель на данные счетчиков текущего экземпляра PERF_COUNTER_BLOCK
          PtrToCntr := PPerfCounterBlock(DWORD(PerfInst) + PerfInst.ByteLength);
          //Перебираем все счетчики для каждого объекта
          for j := 0 to PerfObj.NumCounters - 1 do
          begin
            // Получаем указатель на данные счетчика
            pData := Pointer(DWORD(PtrToCntr) + CurCntr.CounterOffset);
            // Если счетчик - это ID Process, то читаем его и добавляем в выходную строку
            if CurCntr.CounterNameTitleIndex = PID_OBJECT_INDEX then
            begin
              S := SizeOf(procEntry.szExeFile);
              FillChar(procEntry.szExeFile, SizeOf(procEntry.szExeFile), #0); 

              hProcess := OpenProcess(PROCESS_ALL_ACCESS, false, Integer(pData^));

              if (ovi.dwMajorVersion = 5) and (ovi.dwMinorVersion = 0) then
                GetModuleFilenameEx(hProcess, 0, procEntry.szExeFile, S)
              else if (ovi.dwMajorVersion = 5) and (ovi.dwMinorVersion > 0) then 
              begin
                SetLength(path, S);
                GetProcessImageFileName(hProcess, @path[1], S);
                delete(path, 1, 1);
                pathstr := GetTok(path, '\') + '\';
                pathstr := pathstr + GetTok(path, '\');
                path := Trim(GetDeviceName('\' + pathstr) + path);
                Move(path[1], procEntry.szExeFile, length(path));
              end
              else
                QueryFullProcessImageName(hProcess, 0, procEntry.szExeFile, @S);

              procEntry.th32ProcessID := Integer(pData^);
              procEntry.th32ParentProcessID := GetOwnedProcessID(hProcess);
              CloseHandle(hProcess);                
//------------------------------------------------------------------------------

              FPart := ExtractFilePath(string(procEntry.szExeFile));
              if FPart = '' then
              begin
                hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
                if(hSnapshot <> INVALID_HANDLE_VALUE) then
                begin
                  FillChar(procEnt.szExeFile, SizeOf(procEnt.szExeFile), #0);
                  procEnt.dwSize := sizeof(PROCESSENTRY32);
                  res := Process32First(hSnapshot, procEnt);
                  while res do
                  begin
                    if procEnt.th32ProcessID = procEntry.th32ProcessID then break; 
                    res := Process32Next(hSnapshot, procEnt);
                  end;
                end;  
                CloseHandle(hSnapshot);

                FillChar(procEntry.szExeFile, SizeOf(procEntry.szExeFile), #0);
                if procEnt.szExeFile[0] = '[' then
                  Move(process_name[1], procEntry.szExeFile, SizeOf(procEntry.szExeFile))
                else                    
                  Move(procEnt.szExeFile, procEntry.szExeFile, SizeOf(procEntry.szExeFile));
              end;  

//------------------------------------------------------------------------------
              if not CallBack() then exit;
            end;
            // Получаем указатель на следующий счетчик
            CurCntr := PPerfCounterDefinition(DWORD(CurCntr) + CurCntr.ByteLength); 
          end;  
          // Получаем указатель на следующий экземпляр объекта
          // Он находится сразу за данными текущего экземпляра
          PerfCntrBlk := PPerfCounterBlock(DWORD(PerfInst) + PerfInst.ByteLength);
          PerfInst := PPerfInstanceDefinition(DWORD(PerfCntrBlk) + PerfCntrBlk.ByteLength);
        end;
      end;
    end;
    // Получаем указатель на следующий тип объекта
    PerfObj := PPerfObjectType(DWORD(PerfObj) + PerfObj.TotalByteLength);
  end;
FINALLY
  // В любом случае освобождаем память, занятую буфером
  FreeMem(PerfData);
  DeviceList.free;  
  _hi_OnEvent(_event_onEndEnum);
END;
end;

//------------------------------------------------------------------------------

procedure ThiEnumProcess.Enum;
begin
  if ovi.dwMajorVersion < 5 then exit;
  EnumNT(CallBack);
end;

function ThiEnumProcess.EnumAll;
begin
  if procEntry.szExeFile <> '' then
    _hi_OnEvent(_event_onProcess, procEntry.szExeFile);
  Result := true;
end;

procedure ThiEnumProcess._work_doEnum;
begin
  Enum(EnumAll);
  FillChar(procEntry, sizeof(procEntry), 0);
end;

function ThiEnumProcess.FindID;
begin
  Result := ID <> procEntry.th32ProcessID;
end;

procedure ThiEnumProcess._work_doFindID;
begin
  ID := ReadInteger(_Data, _data_ID, 0);
  Enum(FindID);
  if ID = procEntry.th32ProcessID then
  begin
    FFullPath := procEntry.szExeFile;
    _hi_CreateEvent(_Data, @_event_onFind);
  end   
  else
  begin
    FFullPath := '';
    _hi_CreateEvent(_Data, @_event_onNotFind);
  end;
end;

function ThiEnumProcess.FindName;
begin
  Result := PName <> ExtractFileName(LowerCase(procEntry.szExeFile));
end;

procedure ThiEnumProcess._work_doFindName;
begin
  PName := LowerCase(ReadString(_Data,_data_Name,_prop_Name));
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

//-------------------------------------------------------------------------------

procedure ThiEnumProcess._work_doGetMemoryInfo;
var
  proc: THandle;
  pmc: TProcessMemoryCounters;
begin
  SetDebugPrivilege(FDebugPrivilege);
  proc := OpenProcess(PROCESS_QUERY_INFORMATION, false, procEntry.th32ProcessID);
  if GetProcessMemoryInfo(proc, @pmc, sizeof(TProcessMemoryCounters)) then
    _hi_CreateEvent(_Data, @_event_onGetMemoryInfo, {$ifdef F_P}integer{$endif}(pmc.WorkingSetSize));
  CloseHandle(proc);
end;

procedure ThiEnumProcess._work_doGetProcessAccount;
var
  proc: THandle;
begin
  SetDebugPrivilege(FDebugPrivilege);
  proc := OpenProcess(PROCESS_ALL_ACCESS, false, procEntry.th32ProcessID);
  _hi_CreateEvent(_Data,@_event_onGetProcessAccount, GetProcessAccount(proc));
  CloseHandle(proc);
end;

//-------------------------------------------------------------------------------

procedure ThiEnumProcess._work_doGetPriority;
var
  proc: THandle;
  pc: Cardinal;
  Priority: Integer;  
begin
  SetDebugPrivilege(FDebugPrivilege);
  proc := OpenProcess(PROCESS_QUERY_INFORMATION, false, procEntry.th32ProcessID);
  pc:= integer(GetPriorityClass(proc));
  CloseHandle(proc);
  case pc of
    NORMAL_PRIORITY_CLASS       : Priority := 0;
    IDLE_PRIORITY_CLASS         : Priority := 1;
    HIGH_PRIORITY_CLASS         : Priority := 2;
    REALTIME_PRIORITY_CLASS     : Priority := 3;
    BELOW_NORMAL_PRIORITY_CLASS : Priority := 4;
    ABOVE_NORMAL_PRIORITY_CLASS : Priority := 5;
    else Priority := 0;
  end;
  _hi_CreateEvent(_Data, @_event_onGetPriority, Priority);  
end;

procedure ThiEnumProcess._work_doGetProc;
var
  proc: THandle;
  lpProcessAffinityMask, lpSystemAffinityMask: dword;
begin
  SetDebugPrivilege(FDebugPrivilege);
  proc := OpenProcess(PROCESS_QUERY_INFORMATION, false, procEntry.th32ProcessID);
  GetProcessAffinityMask(proc, lpProcessAffinityMask, lpSystemAffinityMask);
  CloseHandle(proc);
  _hi_CreateEvent(_Data, @_event_onGetProc, integer(lpProcessAffinityMask));
end;

procedure ThiEnumProcess._work_doGetProcBoost;
var
  proc: THandle;
  DisablePriorityBoost: Bool;
begin
  SetDebugPrivilege(FDebugPrivilege);
  proc := OpenProcess(PROCESS_QUERY_INFORMATION, false, procEntry.th32ProcessID);
  GetProcessPriorityBoost(proc, DisablePriorityBoost);
  if DisablePriorityBoost then
    _hi_CreateEvent(_Data, @_event_onGetProcBoost, 0)
  else
    _hi_CreateEvent(_Data, @_event_onGetProcBoost, 1);
  CloseHandle(proc);
end;

//-------------------------------------------------------------------------------

procedure ThiEnumProcess._work_doSetPriority;
var
  proc: THandle;
  pc: cardinal;
begin
  SetDebugPrivilege(FDebugPrivilege);
  proc := OpenProcess(PROCESS_SET_INFORMATION, false, procEntry.th32ProcessID);
  case Readinteger(_Data, _data_PriorityClass, 0) of
    0: pc := NORMAL_PRIORITY_CLASS;
    1: pc := IDLE_PRIORITY_CLASS;
    2: pc := HIGH_PRIORITY_CLASS;
    3: pc := REALTIME_PRIORITY_CLASS;
    4: pc := BELOW_NORMAL_PRIORITY_CLASS;
    5: pc := ABOVE_NORMAL_PRIORITY_CLASS;
    else pc := NORMAL_PRIORITY_CLASS;
  end;
  SetPriorityClass(proc, pc);
  CloseHandle(proc);
end;

procedure ThiEnumProcess._work_doSetProc;
var
  proc: THandle;
  pc: byte;
begin
  pc := Readinteger(_Data,_data_AffinityMask,0);
  if pc = 0 then Exit;
  SetDebugPrivilege(FDebugPrivilege);
  proc := OpenProcess(PROCESS_SET_INFORMATION, false, procEntry.th32ProcessID);
  SetProcessAffinityMask(proc, pc);
  CloseHandle(proc);
end;

procedure ThiEnumProcess._work_doSetProcBoost;
var
  proc: THandle;
  DisablePriorityBoost:bool;
begin
  DisablePriorityBoost := not boolean(Readinteger(_Data,_data_PriorityBoost,0));
  SetDebugPrivilege(FDebugPrivilege);
  proc := OpenProcess(PROCESS_SET_INFORMATION, false, procEntry.th32ProcessID);
  SetProcessPriorityBoost(proc, DisablePriorityBoost);
  CloseHandle(proc);
end;

//-------------------------------------------------------------------------------

procedure ThiEnumProcess._var_CurrentID;
begin
  dtInteger(_Data, procEntry.th32ProcessID);
end;

procedure ThiEnumProcess._var_CurrParentID;
begin
  dtInteger(_Data, procEntry.th32ParentProcessID);
end;

procedure ThiEnumProcess._var_FileName;
begin
  dtString(_Data, procEntry.szExeFile);
end;

procedure ThiEnumProcess._var_CPUCount;
var
  lpSystemInfo: _SYSTEM_INFO;
begin
  GetSystemInfo(lpSystemInfo);
  dtInteger(_Data, lpSystemInfo.dwNumberOfProcessors);
end;

procedure ThiEnumProcess._var_FullPath;
begin
  dtString(_Data, FFullPath);
end;

procedure ThiEnumProcess._var_MajorVersion;
begin
  dtInteger(_Data, ovi.dwMajorVersion);
end;

procedure ThiEnumProcess._var_MinorVersion;
begin
  dtInteger(_Data, ovi.dwMinorVersion);
end;   

procedure ThiEnumProcess._work_doDebugPrivilege;
begin
   FDebugPrivilege := ReadBool(_Data);
end;

end.