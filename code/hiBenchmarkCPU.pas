unit hiBenchmarkCPU;

interface

uses Windows,Kol,Share,Debug;

type
  THIBenchmarkCPU = class(TDebug)
   private
     FCount:integer;
     FEvents:array of cardinal;
   public
    _prop_ThreadCount:integer;
    _prop_Iterations:integer;

    _data_ThreadCount:THI_Event;
    _event_onBenchmark:THI_Event;

    procedure _work_doStartBenchmark(var _Data:TData; Index:word);
    procedure _var_State(var _Data:TData; Index:word);
  end;

implementation

type
 TThreadRec = record
   handle:cardinal;
   parent:THIBenchmarkCPU;
 end;
 PThreadRec = ^TThreadRec;
 
var max_for:integer;

function proc(l:pointer):Integer; stdcall;
var i:integer;
begin
  Result := 0;
  i := 1000*1000*max_for;
  asm
    push ecx
    mov ecx, [i]
   @1:
    loop @1 
    pop ecx
  end;
end;

procedure THIBenchmarkCPU._work_doStartBenchmark;
var 
    i:integer;
    id:LongWord;
    rc:PThreadRec;
    timeStart:cardinal;
    lst:PList;
//    lpSystemInfo:_SYSTEM_INFO;
begin
   max_for := _prop_Iterations;
   FCount := ReadInteger(_Data,_data_ThreadCount,_prop_ThreadCount);
   
   SetLength(FEvents, FCount);
   
   lst := NewList;
      
//   GetSystemInfo(lpSystemInfo);
   timeStart := getTickCount();
   for i := 1 to FCount do
     begin
       new(rc);
       rc.parent := self;
       rc.handle := CreateThread(0, 0, @proc, rc, 0, id);
       //SetThreadAffinityMask(rc.handle, i mod lpSystemInfo.dwNumberOfProcessors + 1);
       SetThreadPriority(rc.handle, THREAD_PRIORITY_HIGHEST); 
       FEvents[i-1] := rc.handle;
       lst.Add(rc);
     end;
   WaitForMultipleObjects(FCount, PWOHandleArray(@FEvents[0]), true, cardinal(-1));
   _hi_onEvent(_event_onBenchmark, integer(getTickCount() - timeStart));
   for i := 0 to FCount-1 do
     begin
       CloseHandle(FEvents[i]);
       dispose(PThreadRec(lst.Items[i]));
     end;
   lst.Free;  
   FCount := 0;    
end;

procedure THIBenchmarkCPU._var_State;
begin
   if FCount > 0 then
     dtInteger(_Data, 1)
   else  
     dtInteger(_Data, 0);
end;

end.
