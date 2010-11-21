unit hiCryptography;

interface

uses Windows,Kol,Share,Debug;

type
 TThreadRec = record
   handle:cardinal;
   ss:cardinal;
   size:cardinal;     
   key:PChar;
 end;
 PThreadRec = ^TThreadRec;
 
  THICryptography = class(TDebug)
   private
    FResult:string;
    FEvents:array of cardinal;
   public
    _prop_Mode:byte;
    _prop_Key:string;

    _data_Key:THI_Event;
    _data_Data:THI_Event;
    _event_onCrypt:THI_Event;

    procedure _work_doCrypt0(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

function xor_proc(l:pointer):Integer; stdcall;
var mx:cardinal;
    str,ps,len:cardinal; 
begin
  Result := 0;
  mx := PThreadRec(l).size shr 2; 
  str := PThreadRec(l).ss;
  ps := cardinal(PThreadRec(l).key);
  len := length(PThreadRec(l).key);
  asm
    push ecx
    push edx
    push eax
    push esi
    push edi
    
    mov ecx, [mx]
    mov esi, [str]
    mov edx, [ps]
    xor edi, edi    
   @1:
    mov eax, [edx + edi]
    xor [esi], eax
    add esi, 4
    add edi, 4
    cmp edi, [len]
    jnz @2
    xor edi, edi
   @2: 
    loop @1
    
    pop edi 
    pop esi 
    pop eax    
    pop edx
    pop ecx
  end;
  ExitThread(0);
end;

procedure THICryptography._work_doCrypt0;
var rc:PThreadRec;
    i,c,a:integer;
    id:LongWord;
    key:string;
    lpSystemInfo:_SYSTEM_INFO;
    lst:PList;
begin
   FResult := ReadString(_Data, _data_Data);
   key := ReadString(_Data, _data_Key, _prop_Key);
   while length(key) mod 4 > 0 do
     key := key + ' ';
   a := 0;
   while length(FResult) mod 4 > 0 do
     begin
       FResult := FResult + ' ';
       inc(a);
     end;
   if length(FResult) > 64*1024 then
     begin
       GetSystemInfo(lpSystemInfo);
       c := lpSystemInfo.dwNumberOfProcessors;
     end
   else c := 1;
   lst := NewList;
   SetLength(FEvents, c);
   for i := 1 to c do
     begin
       new(rc);
       rc.ss := cardinal(@FResult[1 + (i - 1)*(length(FResult) div c)]);
       rc.size := length(FResult) div c;
       rc.key := @key[1];
       //rc.handle := BeginThread(nil, 0, xor_proc, rc, 0, id);
       rc.handle := CreateThread(0, 0, @xor_proc, rc, 0, id);
       FEvents[i-1] := rc.handle;
       lst.Add(rc); 
       SetThreadPriority(rc.handle, THREAD_PRIORITY_HIGHEST);
     end;
   WaitForMultipleObjects(c, PWOHandleArray(@FEvents[0]), true, cardinal(-1));
   if a > 0 then
     delete(FResult, Length(FResult) - a + 1, a);
   
   _hi_onEvent(_event_onCrypt, FResult);
   
   for i := 0 to c-1 do
     begin
       CloseHandle(FEvents[i]);
       dispose(PThreadRec(lst.Items[i]));
     end;
   lst.Free;   
end;

procedure THICryptography._var_Result;
begin
   dtString(_Data, FResult);
end;

end.
