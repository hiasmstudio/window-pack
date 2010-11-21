unit hiBenchmarkRAM;

interface

uses Windows,Kol,Share,Debug;

type
  THIBenchmarkRAM = class;
  TThreadRec = record    
    handle:cardinal;
    parent:THIBenchmarkRAM;
    Result:real;
  end;
  PThreadRec = ^TThreadRec;
 
  THIBenchmarkRAM = class(TDebug)
   private
    rc:PThreadRec;
   public
    _prop_MemoryCount:integer;
    _prop_Mode:function(l:pointer):Integer; stdcall;

    _event_onBenchmark:THI_Event;

    procedure _work_doStartBenchmark(var _Data:TData; Index:word);
    procedure _var_State(var _Data:TData; Index:word);
  end;

function ramRead(l:pointer):Integer; stdcall;
function ramWrite(l:pointer):Integer; stdcall;
function ramCopy(l:pointer):Integer; stdcall;
function ramFill(l:pointer):Integer; stdcall;

implementation

function ramRead(l:pointer):Integer; stdcall;
var 
    i:integer;
    mc:cardinal;
    mem1:pointer;
    timeStart,endTime,tmp:int64;
begin
  Result := 0;
  mc := PThreadRec(l).Parent._prop_MemoryCount*1024*1024;
  GetMem(mem1, mc);
  QueryPerformanceCounter(timeStart);
  for i := 1 to 100 do
   asm
     push ecx
     push esi
     push eax
     mov ecx, [mc]
     mov esi, [mem1]
    @1:
     mov al,[esi]
     mov al,[esi]
     mov al,[esi]
     mov al,[esi]

     mov al,[esi]
     mov al,[esi]
     mov al,[esi]
     mov al,[esi]
     
     mov al,[esi]
     mov al,[esi]
     mov al,[esi]
     mov al,[esi]

     mov al,[esi]
     mov al,[esi]
     mov al,[esi]
     mov al,[esi]
     
     inc esi 
     loop @1
     pop eax
     pop esi
     pop ecx
   end;
  QueryPerformanceCounter(tmp);
  endTime := tmp - timeStart;
  
  QueryPerformanceCounter(timeStart);
  for i := 0 to 99 do
   asm
     push ecx
     push esi
     push eax
     mov ecx, [mc]
     mov esi, [mem1]
    @1:
     //...
     loop @1
     pop eax
     pop esi
     pop ecx
   end;
  QueryPerformanceCounter(tmp);
  endTime := endTime - (tmp - timeStart);

  QueryPerformanceFrequency(tmp);
  PThreadRec(l).Result := PThreadRec(l).Parent._prop_MemoryCount*100*16 / (endTime/tmp);
  FreeMem(mem1);
end;

function ramWrite(l:pointer):Integer; stdcall;
var 
    i:integer;
    mc:cardinal;
    mem1:pointer;
    timeStart,endTime,tmp:int64;
begin
  Result := 0;
  mc := PThreadRec(l).Parent._prop_MemoryCount*1024*1024;
  GetMem(mem1, mc);
  QueryPerformanceCounter(timeStart);
  for i := 1 to 100 do
   asm
     push ecx
     push esi
     push eax
     mov ecx, [mc]
     mov esi, [mem1]
    @1:
     mov [esi], al
     mov [esi], al
     mov [esi], al
     mov [esi], al

     mov [esi], al
     mov [esi], al
     mov [esi], al
     mov [esi], al
     
     mov [esi], al
     mov [esi], al
     mov [esi], al
     mov [esi], al

     mov [esi], al
     mov [esi], al
     mov [esi], al
     mov [esi], al
     
     inc esi 
     loop @1
     pop eax
     pop esi
     pop ecx
   end;
  QueryPerformanceCounter(tmp);
  endTime := tmp - timeStart;
  
  QueryPerformanceCounter(timeStart);
  for i := 0 to 99 do
   asm
     push ecx
     push esi
     push eax
     mov ecx, [mc]
     mov esi, [mem1]
    @1:
     //... 
     loop @1
     pop eax
     pop esi
     pop ecx
   end;
  QueryPerformanceCounter(tmp);
  endTime := endTime - (tmp - timeStart);

  QueryPerformanceFrequency(tmp);
  PThreadRec(l).Result := PThreadRec(l).Parent._prop_MemoryCount*100*16 / (endTime/tmp);
  FreeMem(mem1);
end;

function ramCopy(l:pointer):Integer; stdcall;
var 
    i:integer;
    mc:cardinal;
    mem1,mem2:pointer;
    timeStart,endTime,tmp:int64;
begin
  Result := 0;
  mc := PThreadRec(l).Parent._prop_MemoryCount*1024*1024;
  GetMem(mem1, mc);
  GetMem(mem2, mc);
  QueryPerformanceCounter(timeStart);
  for i := 1 to 100 do
    CopyMemory(mem1, mem2, mc);
  QueryPerformanceCounter(tmp);
  endTime := tmp - timeStart;

  QueryPerformanceFrequency(tmp);
  PThreadRec(l).Result := PThreadRec(l).Parent._prop_MemoryCount*100 / (endTime/tmp);
  FreeMem(mem1);
  FreeMem(mem2);
end;

function ramFill(l:pointer):Integer; stdcall;
var 
    i:integer;
    mc:cardinal;
    mem1:pointer;
    timeStart,endTime,tmp:int64;
begin
  Result := 0;
  mc := PThreadRec(l).Parent._prop_MemoryCount*1024*1024;
  GetMem(mem1, mc);
  QueryPerformanceCounter(timeStart);
  for i := 1 to 100 do
    FillChar(mem1^, mc, 0);

  QueryPerformanceCounter(tmp);
  endTime := tmp - timeStart;

  QueryPerformanceFrequency(tmp);
  PThreadRec(l).Result := PThreadRec(l).Parent._prop_MemoryCount*100 / (endTime/tmp);
  FreeMem(mem1);
end;

procedure THIBenchmarkRAM._work_doStartBenchmark;
var 
    id:LongWord;
begin
   new(rc);
   rc.parent := self;
   rc.Result := 0;
   rc.handle := CreateThread(0, 0, @_prop_Mode, rc, 0, id);
   SetThreadAffinityMask(rc.handle, 1);
   SetThreadPriority(rc.handle, THREAD_PRIORITY_HIGHEST); 
   WaitForSingleObject(rc.handle, cardinal(-1));
   _hi_onEvent(_event_onBenchmark, rc.Result);
   CloseHandle(rc.handle);
   dispose(rc);
end;

procedure THIBenchmarkRAM._var_State;
begin
   if rc = nil then
     dtInteger(_Data, 0)
   else  
     dtInteger(_Data, 1);
end;

end.
