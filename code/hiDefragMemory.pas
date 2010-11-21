unit HiDefragMemory;

interface

uses Windows, Kol, Share, Debug;

type
  TMemoryStatusEx = record
    dwLength: DWORD;
    dwMemoryLoad: DWORD;
    ullTotalPhys: Int64;
    ullAvailPhys: Int64;
    ullTotalPageFile: Int64;
    ullAvailPageFile: Int64;
    ullTotalVirtual: Int64;
    ullAvailVirtual: Int64;
    ullAvailExtendedVirtual: Int64;
  end;

type
 THiDefragMemory = class(TDebug)
   private
     Pointers: Array of Pointer;
     Limit: integer;
     FAbort, FWorking: boolean;
     pDiv: integer;
     procedure SetModeSize(val: byte);
     procedure GetMemoryInfo(var Data: TData);
     function GetTotalMemory: integer;
     function GetAvailVirtual: integer;     
     procedure SetProgramPriority;
     procedure DefragMemory(MemoryLimit:Integer);
   public
     _data_MemoryLimit,
     _event_onProgress,
     _event_onDefragMemory: THI_Event;
     destructor Destroy; override;
     procedure _work_doDefragMemory(var _Data:TData; Index:word);
     procedure _work_doStop(var _Data:TData; Index:word);
     procedure _work_doDimension(var _Data:TData; Index:word);     
     procedure _var_MemoryInfo(var _Data:TData; Index:word);
     property _prop_Dimension: byte write SetModeSize;
 end;

implementation

function GlobalMemoryStatusEx(var lpBuffer: TMemoryStatusEx): Boolean; stdcall; external 'kernel32.dll' name 'GlobalMemoryStatusEx';

procedure THiDefragMemory.SetModeSize;
begin
  case val of
    0: pDiv := 1;
    1: pDiv := 1024;
    2: pDiv := 1048576;
  end;  
end;

destructor THiDefragMemory.Destroy;
var
  i: integer;
begin
  for i := 0 to Limit - 1 do
    if Pointers[i] <> nil then
      VirtualFree(Pointers[i], 0, MEM_RELEASE);
  inherited;
end;

procedure THiDefragMemory.GetMemoryInfo(var Data: TData);
var
  MemoryStatus : TMemoryStatusEx;
  dtph, daph, duph, dmld,
  dtpg, dapg, dupg,
  dtvr, davr, duvr: TData;
begin
  MemoryStatus.dwLength := sizeof(MemoryStatus);
  GlobalMemoryStatusEx(MemoryStatus);

  with MemoryStatus do
  begin
    dtInteger(dmld, dwMemoryLoad);
    dtReal(dtph, ullTotalPhys div pDiv);
    dtReal(daph, ullAvailPhys div pDiv);
    dtReal(duph, (ullTotalPhys - ullAvailPhys) div pDiv);
    dtReal(dtpg, ullTotalPageFile div pDiv);
    dtReal(dapg, ullAvailPageFile div pDiv);
    dtReal(dupg, (ullTotalPageFile - ullAvailPageFile) div pDiv);
    dtReal(dtvr, ullTotalVirtual div pDiv);
    dtReal(davr, ullAvailVirtual div pDiv);
    dtReal(duvr, (ullTotalVirtual - ullAvailVirtual) div pDiv);
  end;
  dmld.ldata := @dtph;
  dtph.ldata := @daph;
  daph.ldata := @duph;
  duph.ldata := @dtpg;
  dtpg.ldata := @dapg;
  dapg.ldata := @dupg;
  dupg.ldata := @dtvr;
  dtvr.ldata := @davr;
  davr.ldata := @duvr;
  Data := dmld;
end;

function THiDefragMemory.GetTotalMemory;
var
  MemoryStatus : TMemoryStatusEx;
begin
  MemoryStatus.dwLength := sizeof(MemoryStatus);
  GlobalMemoryStatusEx(MemoryStatus);
  Result := MemoryStatus.ullTotalPhys div 1048576;
end;

function THiDefragMemory.GetAvailVirtual;
var
  MemoryStatus : TMemoryStatusEx;
begin
  MemoryStatus.dwLength := sizeof(MemoryStatus);
  GlobalMemoryStatusEx(MemoryStatus);
  Result := MemoryStatus.ullAvailVirtual div 1048576;
end;

procedure THiDefragMemory.SetProgramPriority;
var
  ProcessID         : DWORD;
  ProcessHandle     : THandle;
  ThreadHandle      : THandle;
begin
  ProcessID := GetCurrentProcessID;
  ProcessHandle := OpenProcess(PROCESS_SET_INFORMATION, False, ProcessID);
  SetPriorityClass(ProcessHandle, IDLE_PRIORITY_CLASS);
  ThreadHandle := GetCurrentThread;
  SetThreadPriority(ThreadHandle, THREAD_PRIORITY_LOWEST);
  CloseHandle(ProcessHandle);
end;

procedure THiDefragMemory.DefragMemory(MemoryLimit: Integer);
var
  i2, i        : integer;
  P            : Pointer;
  Step         : integer;
  Steps        : integer;
begin
  if FWorking or (MemoryLimit > GetTotalMemory) then exit;
  FAbort := False;
  FWorking := True;
  Limit := min(MemoryLimit, min(GetTotalMemory, GetAvailVirtual) - 16); 
  SetLength(Pointers, Limit);

  { Calculating how many steps...}
  Steps := (Limit * 2);
  Step := 0;

  _hi_onEvent(_event_onDefragMemory, 0); // Filling
  { Clean pointer...}
  for i := 0 to Limit - 1 do Pointers[i] := nil;

  { Allocating Memory }
  for i := 0 to Limit - 1 do
  begin
    P := VirtualAlloc(nil, 1048576, MEM_COMMIT, PAGE_READWRITE OR PAGE_NOCACHE);
    Pointers[i] := P;
    asm
      pushad
      pushfd
      mov   edi, P
      mov   ecx, 262144
      xor   eax, eax
      cld
      repz  stosd
      popfd
      popad
    end;
    inc(Step);
    _hi_onEvent(_event_onProgress, Round((Step / Steps) * 100));
    if FAbort then
    begin
      for i2 := 0 to i do
        VirtualFree(Pointers[i2], 0, MEM_RELEASE);
      Step:=(Limit * 2);
      FWorking := false;
      _hi_onEvent(_event_onProgress, Round((Step / Steps) * 100));
      _hi_onEvent(_event_onDefragMemory, 3); // Abort
      exit;
    end;
  end;

  { DeAllocating Memory }
  _hi_onEvent(_event_onDefragMemory, 1); // Cleaning

  for i := 0 to Limit - 1 do
  begin
    VirtualFree(Pointers[i], 0, MEM_RELEASE);
    inc(Step);
    _hi_onEvent(_event_onProgress, Round((Step / Steps) * 100));
    if FAbort then
    begin
      { Warning! : Force abort, w/o de-allocating memory }
      Step := (Limit * 2);
      FWorking := False;
      _hi_onEvent(_event_onProgress, Round((Step / Steps) * 100));
      _hi_onEvent(_event_onDefragMemory, 3); // Abort
      exit;
    end;
  end;
  FWorking := False;
  _hi_onEvent(_event_onDefragMemory, 2);  // Done;
end;

procedure THiDefragMemory._work_doDefragMemory;
begin
  SetProgramPriority;
  DefragMemory(Round(ReadReal(_Data, _data_MemoryLimit) * pDiv / 1048576));
end;

procedure THiDefragMemory._work_doStop;
begin
  FAbort := true;
end;

procedure THiDefragMemory._var_MemoryInfo;
begin
  GetMemoryInfo(_Data);
end;

procedure THiDefragMemory._work_doDimension;
begin
  SetModeSize(ToInteger(_Data));
end;

end.