unit hiMutexThread;

interface

{$I def.inc}
{$I share.inc}

uses Kol,Share,Windows,Debug;

type
  THIMutexThread = class(TDebug)
   private
    th:PThread;
    FStop:boolean;
    FMutex:boolean;
    FDelay:cardinal;
{$ifndef F_P}    
    MutexHandle: THandle;

    function waitqueue(Sender:PThread; Delay:cardinal):DWord;
    procedure endmutex;
    procedure WaitSyncExec;
{$endif}   
    procedure SyncExec;
    procedure _OnSuspend;
    procedure _OnResume(Obj:PObj);
    function  _Execute(Sender:PThread): Integer;
 
   public
    _prop_FastStop:boolean;
    _prop_BusyEvent:byte;
    _prop_PrefixName:string;
    _prop_OneWaitSyncExec:boolean;        

    _event_onSyncExec:THI_Event;
    _event_onWaitSyncExec:THI_Event;    
    _event_onExec:THI_Event;
    _event_onError:THI_Event;
    _event_onWaitqueue:THI_Event;
    _event_onSuspend:THI_Event;
    _event_onResume:THI_Event;

    property _prop_Mutex:boolean write FMutex;
    property _prop_Delay:cardinal write FDelay;

    destructor Destroy; override;
    procedure _work_doStart(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _work_doStopFlag(var _Data:TData; Index:word);
    procedure _work_doDelay(var _Data:TData; Index:word);
    procedure _work_doMutex(var _Data:TData; Index:word);
    procedure _work_doSuspend(var _Data:TData; Index:word);
    procedure _work_doResume(var _Data:TData; Index:word);    
    procedure _var_Busy(var _Data:TData; Index:word);
  end;

implementation

destructor THIMutexThread.Destroy;
var dt:TData;
begin
  _work_doStop(dt,0);
{$ifndef F_P}
  if MutexHandle <> 0 then CloseHandle(MutexHandle);
{$endif}  
  inherited;
end;

function THIMutexThread._Execute(Sender:PThread): Integer;
begin
  Result := 0;
TRY
  FStop := false;
  repeat
{$ifndef F_P}
    waitqueue(Sender, FDelay);
{$else}
    Sleep(FDelay);
{$endif}    
    _hi_OnEvent(_event_onExec);
{$ifndef F_P}
    endmutex;
{$endif}    
    if Assigned(_event_onSyncExec.Event) then
      Sender.Synchronize(SyncExec);
  until Sender.Terminated or _prop_FastStop or FStop;
FINALLY
  Sender.Tag := 0;
END;  
end;

procedure THIMutexThread.SyncExec;
begin
  _hi_OnEvent(_event_onSyncExec);
end;

procedure THIMutexThread._work_doStart;
begin
{$ifndef F_P}
  if MutexHandle = 0 then   
    MutexHandle := CreateMutex(nil, false, PChar(_prop_PrefixName + '_' + int2str(GetCurrentProcessID)));
{$endif}
  if Assigned(th) then
  begin
    if (_prop_BusyEvent = 0) and (th.Tag = 1) then exit;
    th.Terminate;
    th.WaitFor;
    free_and_nil(th);
  end;
  th := {$ifdef F_P}NewThreadforFPC{$else}NewThread{$endif};
  th.OnExecute := _Execute;
  th.OnSuspend := _OnSuspend; 
  th.OnResume  := _OnResume;   
  th.Resume;
  th.Tag := 1;
end;

procedure THIMutexThread._work_doStop;
begin
  if Assigned(th) then
  begin
    th.Terminate;
    th.WaitFor;
    free_and_nil(th);
  end;
end;

procedure THIMutexThread._work_doStopFlag;
begin
  FStop := true;
end;

procedure THIMutexThread._work_doDelay;
begin
  FDelay := ToInteger(_Data);
end;

procedure THIMutexThread._work_doMutex;
begin
  FMutex := ReadBool(_Data);
end;

procedure THIMutexThread._work_doSuspend;
begin
 if Assigned(th) then th.Suspend;
end;

procedure THIMutexThread._work_doResume;
begin
 if Assigned(th) then th.Resume;
end;

procedure THIMutexThread._OnSuspend;
begin
 if Assigned(th) then _hi_OnEvent(_event_onSuspend);
end;

procedure THIMutexThread._OnResume;
begin
 if Assigned(th) then _hi_OnEvent(_event_onResume);
end;

procedure THIMutexThread._var_Busy;
begin
  dtInteger(_Data, integer(Assigned(th) and (th.Tag = 1)));
end;

{$ifndef F_P}
function THIMutexThread.waitqueue;
var  First:boolean;
     OneWaitSyncExec:boolean;
begin
  First := true;
  OneWaitSyncExec := false;
  Result := WAIT_OBJECT_0;
  repeat
    Sleep(Delay);
    if FMutex then
    begin 
      Result := WaitForSingleObject(MutexHandle, 0);
      if First and (Result <> WAIT_OBJECT_0) then
        _hi_OnEvent(_event_onWaitqueue);
      First := false;  
      if Assigned(_event_onWaitSyncExec.Event) and
         (Result <> WAIT_OBJECT_0) and not OneWaitSyncExec then
        Sender.Synchronize(WaitSyncExec);
      if _prop_OneWaitSyncExec then OneWaitSyncExec := true;
    end;
  until Result = WAIT_OBJECT_0;
end;

procedure THIMutexThread.endmutex;
begin
  if FMutex then ReleaseMutex(MutexHandle);
end;

procedure THIMutexThread.WaitSyncExec;
begin
  _hi_OnEvent(_event_onWaitSyncExec);
end;
{$endif}

initialization
{$ifdef F_P}
  {$ifndef _PROTECT_STD_}
    _debug('Компонент MutexThread под FPC не поддерживает мультипоточность.');
  {$endif}
  {$ifdef _PROTECT_MAX_}
    _debug('Компонент MutexThread под FPC не поддерживает мультипоточность.');
  {$endif}
{$endif F_P}
end.