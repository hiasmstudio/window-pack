unit hiBenchmarkHDD;

interface

uses Windows,Kol,Share,Debug;

type
  THIBenchmarkHDD = class;
  TThreadRec = record    
    Drive:char;
    handle:cardinal;
    parent:THIBenchmarkHDD;
    Result:real;
  end;
  PThreadRec = ^TThreadRec;
  THIBenchmarkHDD = class(TDebug)
   private
     rc:PThreadRec;
   public   
    _prop_HDD:string;    
    _prop_Mode:function(l:pointer):Integer; stdcall;
    _prop_Cache:boolean;
    
    _data_HDD:THI_Event;

    _event_onBenchmark:THI_Event;

    procedure _work_doStartBenchmark(var _Data:TData; Index:word);
    procedure _var_State(var _Data:TData; Index:word);
  end;

function hddRead(l:pointer):Integer; stdcall;
function hddWrite(l:pointer):Integer; stdcall;

implementation

function hddRead(l:pointer):Integer; stdcall;
var 
    i:integer;
    timeStart,endTime,tmp:int64;
    f:string;
    blk:pointer;
    h, rd, flg:cardinal;
begin
  Result := 0;
  //-------prepare ------------------
  GetMem(blk, 1024*1024); //1Mb
  f := PThreadRec(l).Drive + ':\_hdd_test.bin';
  h := CreateFile(PChar(f), GENERIC_WRITE, FILE_SHARE_WRITE, nil, CREATE_NEW, FILE_ATTRIBUTE_NORMAL, 0);
  for i := 1 to 200 do
    WriteFile(h, blk^, 1024*1024, rd, nil);
  CloseHandle(h);
  
  //-------test ------------------
  if PThreadRec(l).Parent._prop_Cache then
    flg := 0
  else flg := FILE_FLAG_NO_BUFFERING; 
  h := CreateFile(PChar(f), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, flg or FILE_ATTRIBUTE_READONLY, 0);   
  QueryPerformanceCounter(timeStart);
  for i := 1 to 200 do
    ReadFile(h, blk^, 1024*1024, rd, nil);  
  CloseHandle(h);
    
  QueryPerformanceCounter(tmp);
  endTime := tmp - timeStart;
  QueryPerformanceFrequency(tmp);
  DeleteFile(PChar(f)); 
  FreeMem(blk);
  PThreadRec(l).Result := 200/(endTime/tmp);
end;

function hddWrite(l:pointer):Integer; stdcall;
var 
    i:integer;
    timeStart,endTime,tmp:int64;
    f:string;
    blk:pointer;
    h,rd,flg:cardinal;
begin
  Result := 0;
  //-------prepare ------------------
  f := PThreadRec(l).Drive + ':\_hdd_test.bin';
  GetMem(blk, 1024*1024); //1Mb
  
  //-------test ------------------
  if PThreadRec(l).Parent._prop_Cache then
    flg := 0
  else flg := FILE_FLAG_WRITE_THROUGH or FILE_FLAG_NO_BUFFERING; 
  h := CreateFile(PChar(f), GENERIC_WRITE, FILE_SHARE_WRITE, nil, CREATE_NEW, flg or FILE_ATTRIBUTE_NORMAL, 0);
  QueryPerformanceCounter(timeStart);
  for i := 1 to 64 do
    WriteFile(h, blk^, 1024*1024, rd, nil);
  QueryPerformanceCounter(tmp);
  CloseHandle(h);

  endTime := tmp - timeStart;
  QueryPerformanceFrequency(tmp);
  DeleteFile(PChar(f)); 
  FreeMem(blk);
  PThreadRec(l).Result := 64/(endTime/tmp);
end;

procedure THIBenchmarkHDD._work_doStartBenchmark;
var 
    id:LongWord;
    s:string;
begin
   new(rc);
   s := ReadString(_Data, _data_HDD, _prop_HDD);
   if s = '' then 
     rc.Drive := 'C'
   else
     rc.Drive := s[1];
      
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

procedure THIBenchmarkHDD._var_State;
begin
   if rc = nil then
     dtInteger(_Data, 0)
   else  
     dtInteger(_Data, 1);
end;

end.
