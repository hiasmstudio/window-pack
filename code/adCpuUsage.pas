unit adCpuUsage;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
CPU Usage Measurement routines for Delphi and C++ Builder

Author:       Alexey A. Dynnikov
EMail:        aldyn@chat.ru
WebSite:      http://www.aldyn.ru/
Support:      Use the e-mail aldyn@chat.ru
                          or support@aldyn.ru

Creation:     Jul 8, 2000
Version:      1.02
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

interface

uses
    Windows, KOL; //  SysUtils;

// Call CollectCPUData to refresh information about CPU usage
procedure CollectCPUData;

// Call it to obtain the number of CPU's in the system
function GetCPUCount: Integer;

// Call it to obtain the % of usage for given CPU
function GetCPUUsage(Index: Integer): Double;

// For Win9x only: call it to stop CPU usage monitoring and free system resources
procedure ReleaseCPUData;

procedure OpenCPU_Mon;
procedure CloseCPU_Mon;

implementation

{$ifndef ver110}

    {$ifndef ver90}
    {$ifndef ver100}
    {$define UseInt64}
    {$endif}
    {$endif}


    {$ifdef UseInt64}
    type TInt64 = Int64;
    {$else}
    type TInt64 = Comp;
    {$endif}

{$else}

    type TInt64 = TLargeInteger;

{$endif}

type
    PInt64 = ^TInt64;

type
    TPERF_DATA_BLOCK = record
        Signature : array[0..4 - 1] of WCHAR;
        LittleEndian : DWORD;
        Version : DWORD;
        Revision : DWORD;
        TotalByteLength : DWORD;
        HeaderLength : DWORD;
        NumObjectTypes : DWORD;
        DefaultObject : Longint;
        SystemTime : TSystemTime;
        Reserved: DWORD;
        PerfTime : TInt64;
        PerfFreq : TInt64;
        PerfTime100nSec : TInt64;
        SystemNameLength : DWORD;
        SystemNameOffset : DWORD;
    end;

    PPERF_DATA_BLOCK = ^TPERF_DATA_BLOCK;

    TPERF_OBJECT_TYPE = record
        TotalByteLength : DWORD;
        DefinitionLength : DWORD;
        HeaderLength : DWORD;
        ObjectNameTitleIndex : DWORD;
        ObjectNameTitle : LPWSTR;
        ObjectHelpTitleIndex : DWORD;
        ObjectHelpTitle : LPWSTR;
        DetailLevel : DWORD;
        NumCounters : DWORD;
        DefaultCounter : Longint;
        NumInstances : Longint;
        CodePage : DWORD;
        PerfTime : TInt64;
        PerfFreq : TInt64;
    end;

    PPERF_OBJECT_TYPE = ^TPERF_OBJECT_TYPE;

type
    TPERF_COUNTER_DEFINITION = record
        ByteLength : DWORD;
        CounterNameTitleIndex : DWORD;
        CounterNameTitle : LPWSTR;
        CounterHelpTitleIndex : DWORD;
        CounterHelpTitle : LPWSTR;
        DefaultScale : Longint;
        DetailLevel : DWORD;
        CounterType : DWORD;
        CounterSize : DWORD;
        CounterOffset : DWORD;
    end;

    PPERF_COUNTER_DEFINITION = ^TPERF_COUNTER_DEFINITION;

    TPERF_COUNTER_BLOCK = record
        ByteLength : DWORD;
    end;

    PPERF_COUNTER_BLOCK = ^TPERF_COUNTER_BLOCK;

    TPERF_INSTANCE_DEFINITION = record
        ByteLength : DWORD;
        ParentObjectTitleIndex : DWORD;
        ParentObjectInstance : DWORD;
        UniqueID : Longint;
        NameOffset : DWORD;
        NameLength : DWORD;
    end;

    PPERF_INSTANCE_DEFINITION = ^TPERF_INSTANCE_DEFINITION;

//------------------------------------------------------------------------------
{$ifdef ver130}
{$L-}         // The L+ causes internal error in Delphi 5 compiler
{$O-}         // The O+ causes internal error in Delphi 5 compiler
{$Y-}         // The Y+ causes internal error in Delphi 5 compiler
{$endif}

{$ifndef ver110}
type
    TInt64F = TInt64;
{$else}
type
    TInt64F = Extended;
{$endif}

{$ifdef ver110}
function FInt64(Value: TInt64): TInt64F;
function Int64D(Value: DWORD): TInt64;
{$else}
type
    FInt64 = TInt64F;
    Int64D = TInt64;
{$endif}

{$ifdef ver110}
function FInt64(Value: TInt64): TInt64F;
var V: TInt64;
begin
    if (Value.HighPart and $80000000) = 0 then // positive value
    begin
        result:=Value.HighPart;
        result:=result*$10000*$10000;
        result:=result+Value.LowPart;
    end else
    begin
        V.HighPart:=Value.HighPart xor $FFFFFFFF;
        V.LowPart:=Value.LowPart xor $FFFFFFFF;
        result:= -1 - FInt64(V);
    end;
end;

function Int64D(Value: DWORD): TInt64;
begin
    result.LowPart:=Value;
    result.HighPart := 0; // positive only
end;
{$endif}

//------------------------------------------------------------------------------

const
    Processor_IDX_Str = '238';
    Processor_IDX = 238;
    CPUUsageIDX = 6;

type
    AInt64F = array[0..$FFFF] of TInt64F;
    PAInt64F = ^AInt64F;

var
    _PerfData : PPERF_DATA_BLOCK;
    _BufferSize: Integer;
    _POT : PPERF_OBJECT_TYPE;
    _PCD: PPerf_Counter_Definition;
    _ProcessorsCount: Integer;
    _Counters: PAInt64F;
    _PrevCounters: PAInt64F;
    _SysTime: TInt64F;
    _PrevSysTime: TInt64F;
    _IsWinNT: Boolean;

    _W9xCollecting: Boolean;
    _W9xCpuUsage: DWORD;
    _W9xCpuKey: HKEY;

//------------------------------------------------------------------------------
function GetCPUCount: Integer;
begin
    if _IsWinNT then
     begin
        if _ProcessorsCount < 0 then CollectCPUData;
        result := _ProcessorsCount;
     end
    else  result:=1;
end;

//------------------------------------------------------------------------------
procedure ReleaseCPUData;
var H: HKEY;
    R: DWORD;
    dwDataSize, dwType: DWORD;
begin
    if _IsWinNT then exit;
    if not _W9xCollecting then exit;
    _W9xCollecting:=False;
    RegCloseKey(_W9xCpuKey);
    R:=RegOpenKeyEx( HKEY_DYN_DATA, 'PerfStats\StopStat', 0, KEY_ALL_ACCESS, H );
    if R <> ERROR_SUCCESS then exit;
    dwDataSize:=sizeof(DWORD);
    RegQueryValueEx ( H, 'KERNEL\CPUUsage', nil, @dwType, PBYTE(@_W9xCpuUsage), @dwDataSize);
    RegCloseKey(H);
end;

//------------------------------------------------------------------------------
function GetCPUUsage(Index: Integer): Double;
begin
    if _IsWinNT then
     begin
        if _ProcessorsCount < 0 then CollectCPUData;
        if _PrevSysTime = _SysTime then result:=0 else
        result:=1-(_Counters[index] - _PrevCounters[index])/(_SysTime-_PrevSysTime);
      end
    else
     begin
        if not _W9xCollecting then CollectCPUData;
        result:=_W9xCpuUsage / 100;
     end;
end;

var VI: TOSVERSIONINFO;

//------------------------------------------------------------------------------
procedure CollectCPUData;
var BS: integer;
    i: Integer;
    _PCB_Instance: PPERF_COUNTER_BLOCK;
    _PID_Instance: PPERF_INSTANCE_DEFINITION;
    ST: TFileTime;

var H: HKEY;
    R: DWORD;
    dwDataSize, dwType: DWORD;
begin
    if _IsWinNT then
    begin
        BS:=_BufferSize;
        while RegQueryValueEx( HKEY_PERFORMANCE_DATA, Processor_IDX_Str, nil, nil,
                PByte(_PerfData), @BS ) = ERROR_MORE_DATA do
        begin
            // Get a buffer that is big enough.
            INC(_BufferSize,$1000);
            BS:=_BufferSize;
            ReallocMem( _PerfData, _BufferSize );
        end;

        // Locate the performance object
        _POT := PPERF_OBJECT_TYPE(DWORD(_PerfData) + _PerfData.HeaderLength);
        for i := 1 to _PerfData.NumObjectTypes do
        begin
            if _POT.ObjectNameTitleIndex = Processor_IDX then Break;
            _POT := PPERF_OBJECT_TYPE(DWORD(_POT) + _POT.TotalByteLength);
        end;

        if _ProcessorsCount < 0 then
        begin
            _ProcessorsCount:=_POT.NumInstances;
            GetMem(_Counters,_ProcessorsCount*SizeOf(TInt64));
            GetMem(_PrevCounters,_ProcessorsCount*SizeOf(TInt64));
        end;

        // Locate the "% CPU usage" counter definition
        _PCD := PPERF_Counter_DEFINITION(DWORD(_POT) + _POT.HeaderLength);
        for i := 1 to _POT.NumCounters do
        begin
            if _PCD.CounterNameTitleIndex = CPUUsageIDX then break;
            _PCD := PPERF_COUNTER_DEFINITION(DWORD(_PCD) + _PCD.ByteLength);
        end;

        _PID_Instance := PPERF_INSTANCE_DEFINITION(DWORD(_POT) + _POT.DefinitionLength);
        for i := 0 to _ProcessorsCount-1 do
        begin
            _PCB_Instance := PPERF_COUNTER_BLOCK(DWORD(_PID_Instance) + _PID_Instance.ByteLength );

            _PrevCounters[i]:=_Counters[i];
            _Counters[i]:=FInt64(PInt64(DWORD(_PCB_Instance) + _PCD.CounterOffset)^);

            _PID_Instance := PPERF_INSTANCE_DEFINITION(DWORD(_PCB_Instance) + _PCB_Instance.ByteLength);
        end;

        _PrevSysTime:=_SysTime;
        SystemTimeToFileTime(_PerfData.SystemTime, ST);
        _SysTime:=FInt64(TInt64(ST));
    end else
    begin
        if not _W9xCollecting then
        begin
            R:=RegOpenKeyEx( HKEY_DYN_DATA, 'PerfStats\StartStat', 0, KEY_ALL_ACCESS, H );
            dwDataSize:=sizeof(DWORD);
            RegQueryValueEx( H, 'KERNEL\CPUUsage', nil, @dwType, PBYTE(@_W9xCpuUsage), @dwDataSize );
            RegCloseKey(H);
            R:=RegOpenKeyEx( HKEY_DYN_DATA, 'PerfStats\StatData', 0,KEY_READ, _W9xCpuKey );
            _W9xCollecting:=True;
        end;

        dwDataSize:=sizeof(DWORD);
        RegQueryValueEx( _W9xCpuKey, 'KERNEL\CPUUsage', nil,@dwType, PBYTE(@_W9xCpuUsage), @dwDataSize );
    end;
end;

procedure OpenCPU_Mon;
begin
    if _ProcessorsCount > 0 then exit;
    _ProcessorsCount:= -1;
    _BufferSize:= $2000;
    _PerfData := AllocMem(_BufferSize);
    VI.dwOSVersionInfoSize:=SizeOf(VI);
    GetVersionEx(VI);
    _IsWinNT := VI.dwPlatformId = VER_PLATFORM_WIN32_NT;
end;

procedure CloseCPU_Mon;
begin
   if _ProcessorsCount > 0 then
    begin
     ReleaseCPUData;
     FreeMem(_PerfData);
     _ProcessorsCount:= -1;
    end;
end;

end.

