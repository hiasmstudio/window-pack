unit hiCPU;

interface

uses mmsystem,windows,Kol,Share,Debug;

type
  THICPU = class(TDebug)
   private
   public
    procedure _var_Vendor(var _Data:TData; Index:word);
    procedure _var_Frequency(var _Data:TData; Index:word);
    procedure _var_ExtendedCpuName(var _Data:TData; Index:word);
    procedure _var_ExtendedL1DCache(var _Data:TData; Index:word);
    procedure _var_ExtendedL1ICache(var _Data:TData; Index:word);
    procedure _var_ExtendedL2Cache(var _Data:TData; Index:word);

    procedure _var_CPUCount(var _Data:TData; Index:word);    
  end;

implementation

uses hiMathParse;

function GetVendorString:string;
var
  s1, s2, s3: array [0..3] of char;
  TempVendor: string;
  i: integer;
begin
  asm
    push eax
    push ebx
    push ecx
    push edx
    mov eax,0
    db $0F,$A2 /// cpuid
    mov s1,ebx
    mov s2,edx
    mov s3,ecx
    pop edx
    pop ecx
    pop ebx
    pop eax
  end;
  TempVendor:='';
  for i:=0 to 3 do
    TempVendor:=TempVendor+s1[i];
  for i:=0 to 3 do
    TempVendor:=TempVendor+s2[i];
  for i:=0 to 3 do
    TempVendor:=TempVendor+s3[i];
  Result := TempVendor;
end;

function GetCPUFrequency: word;
var
  TimeStart: integer;
  TimeStop: integer;
  StartTicks: dword;
  EndTicks: dword;
  TotalTicks: dword;
  cpuSpeed: dword;
  NeverExit: Boolean;
begin
  TimeStop:=0;
  StartTicks:=0;
  EndTicks:=0;
  NeverExit:=True;
  TimeStart:=timeGetTime;
  while NeverExit do
  begin
    TimeStop:=timeGetTime;
    if ((TimeStop-TimeStart)>1) then
    begin
      asm
        xor eax,eax
        xor ebx,ebx
        xor ecx,ecx
        xor edx,edx
        db $0F,$A2 /// cpuid
        db $0F,$31 /// rdtsc
        mov StartTicks,eax
      end;
      Break;
    end;
  end;
  TimeStart:=TimeStop;
  while NeverExit do
  begin
    TimeStop:=timeGetTime;
    if ((TimeStop-TimeStart)>1000) then
    begin
      asm
        xor eax,eax
        xor ebx,ebx
        xor ecx,ecx
        xor edx,edx
        db $0F,$A2 /// cpuid
        db $0F,$31 /// rdtsc
        mov EndTicks,eax
      end;
      Break;
    end;
  end;
  TotalTicks:=EndTicks-StartTicks;
  cpuSpeed:=TotalTicks div 1000000;
  Result := cpuSpeed;
end;

function GetExtendedCpuName: string; 
var
  s:array[0..4*12-1] of char;
  p:pointer;
begin
  p := @s;
  asm
    push eax
    push ebx
    push ecx
    push edx
    push esi
    mov esi, p
       
    mov eax,$80000001
   @1: 
    inc eax    
    push eax
    mov ebx,0
    mov ecx,0
    mov edx,0
    db $0F,$A2
    mov [esi + 0], eax
    mov [esi + 4], ebx
    mov [esi + 8], ecx
    mov [esi + 12], edx
    add esi, 16
    pop eax
    cmp eax, $80000004
    jnz @1 
        
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
  end;
  Result := s;
end;

function GetExtendedL1DCache: word;
var
  L1D, TempL1D: integer;
  BinArray: array [0..31] of byte;
  i, p: integer;
begin
  asm
    push eax
    push ebx
    push ecx
    push edx
    mov eax,$80000005
    mov ebx,0
    mov ecx,0
    mov edx,0
    db $0F,$A2 /// cpuid
    mov L1D,ecx
    pop edx
    pop ecx
    pop ebx
    pop eax
  end;
  for i:=0 to 31 do
  begin
    BinArray[i]:=L1D mod 2;
    L1D:=L1D div 2;
  end;
  TempL1D:=0;
  p:=0;
  for i:=24 to 31 do
  begin
    TempL1D:=TempL1D+(BinArray[i]*Str2Int(Double2Str(IntPower(2,p))));
    inc(p);
  end;
  Result := TempL1D;
end;

function GetExtendedL1ICache: word;
var
  L1I, TempL1I: integer;
  BinArray: array [0..31] of byte;
  i, p: integer;
begin
  asm
    push eax
    push ebx
    push ecx
    push edx
    mov eax,$80000005
    mov ebx,0
    mov ecx,0
    mov edx,0
    db $0F,$A2 /// cpuid
    mov L1I,edx
    pop edx
    pop ecx
    pop ebx
    pop eax
  end;
  for i:=0 to 31 do
  begin
    BinArray[i]:=L1I mod 2;
    L1I:=L1I div 2;
  end;
  TempL1I:=0;
  p:=0;
  for i:=24 to 31 do
  begin
    TempL1I:=TempL1I+(BinArray[i]*Str2Int(Double2Str(IntPower(2,p))));
    inc(p);
  end;
  Result:=TempL1I;
end;

function GetExtendedL2Cache: word;
var
  L2, TempL2: integer;
  BinArray: array [0..31] of byte;
  i, p: integer;
begin
  asm
    push eax
    push ebx
    push ecx
    push edx
    mov eax,$80000006
    mov ebx,0
    mov ecx,0
    mov edx,0
    db $0F,$A2 /// cpuid
    mov L2,ecx
    pop edx
    pop ecx
    pop ebx
    pop eax
  end;
  for i:=0 to 31 do
  begin
    BinArray[i]:=L2 mod 2;
    L2:=L2 div 2;
  end;
  TempL2:=0;
  p:=0;
  for i:=16 to 31 do
  begin
    TempL2:=TempL2+(BinArray[i]*Str2Int(Double2Str(IntPower(2,p))));
    inc(p);
  end;
  Result:=TempL2;
end;

procedure THICPU._var_Vendor;
begin
   dtString(_Data, GetVendorString);
end;

procedure THICPU._var_Frequency;
begin
   dtInteger(_Data, GetCPUFrequency);
end;

procedure THICPU._var_ExtendedCpuName;
begin
   dtString(_Data, GetExtendedCpuName);
end;

procedure THICPU._var_ExtendedL1DCache;
begin
   dtInteger(_Data, GetExtendedL1DCache);
end;

procedure THICPU._var_ExtendedL1ICache;
begin
   dtInteger(_Data, GetExtendedL1ICache);
end;

procedure THICPU._var_ExtendedL2Cache;
begin
   dtInteger(_Data, GetExtendedL2Cache);
end;

procedure THICPU._var_CPUCount;
var lpSystemInfo:_SYSTEM_INFO;
begin
   GetSystemInfo(lpSystemInfo);
   dtInteger(_Data, lpSystemInfo.dwNumberOfProcessors);
end;

end.
