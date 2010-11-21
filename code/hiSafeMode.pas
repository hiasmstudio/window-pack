unit hiSafeMode;

interface

uses Windows, Kol, Share, Debug;

type
 ThiSafeMode = class(TDebug)
   private
     Mtx: THandle;
     PCS: PRTLCriticalSection; 
     procedure SetName(const Value:string);virtual;
   public
    _prop_Delay: Integer;
    _prop_Wait_Abandoned: boolean;
    _prop_WaitMode: byte;
    _event_onSafeMode:THI_Event;
    _prop_Mode: procedure(var dt:TData) of object;

    property _prop_Name: string write SetName;
    procedure Global(var dt:TData);
    procedure Local(var dt:TData);

    destructor Destroy; override;
    procedure _work_doSafeMode(var _Data:TData; Idx:word);
 end;

var CSList: PStrListEx;

function ForceCS(const Name: string): PRTLCriticalSection;

implementation

function InitializeCriticalSectionAndSpinCount(var lpCriticalSection: TRTLCriticalSection;
                                               dwSpinCount: DWORD): BOOL; stdcall;
                                               external 'kernel32.dll' name 'InitializeCriticalSectionAndSpinCount';
function TryEnterCriticalSection(var lpCriticalSection: TRTLCriticalSection): BOOL; stdcall;
                                 external 'kernel32.dll' name 'TryEnterCriticalSection';

function ForceCS(const Name:string): PRTLCriticalSection;
var
  i: integer;
  s: string;
begin
  Result := nil;
  if Name = '' then exit;
  s := LowerCase(Name);
  i := CSList.IndexOf(s);
  if i >= 0 then
    Result := PRTLCriticalSection(CSList.Objects[i])
  else
  begin
    new(Result);
    FillChar(Result^, sizeof(Result^), #0);
    InitializeCriticalSection(Result^);
    CSList.AddObject(s, Cardinal(Result));
  end;
end;

procedure ThiSafeMode.SetName;
begin
  PCS := ForceCS(Value); 
  Mtx := CreateMutex(nil, false, PChar(Value));  
end;

destructor ThiSafeMode.Destroy;
begin
  if Mtx <> 0 then CloseHandle(Mtx);
  inherited Destroy;  
end;

procedure ThiSafeMode._work_doSafeMode;
begin
  _prop_Mode(_Data);
end;

procedure ThiSafeMode.Global;
var
  MS: Cardinal;
begin
  case _prop_WaitMode of
    0: repeat
         MS := WaitForSingleObject(Mtx, INFINITE);    
       until (MS = WAIT_OBJECT_0) OR ((MS = WAIT_ABANDONED_0) AND _prop_Wait_Abandoned);
    1: begin
         MS := WaitForSingleObject(Mtx, 0);
         if (MS <> WAIT_OBJECT_0) OR ((MS <> WAIT_ABANDONED_0) AND _prop_Wait_Abandoned) then exit;
       end;
  end;    
  _hi_onEvent(_event_onSafeMode, dt);
  ReleaseMutex(Mtx);
end;

procedure ThiSafeMode.Local;
begin
  case _prop_WaitMode of
    0: EnterCriticalSection(PCS^);
    1: if not TryEnterCriticalSection(PCS^) then exit;
  end;  
  _hi_onEvent(_event_onSafeMode, dt);  
  LeaveCriticalSection(PCS^);
end;

procedure ClearCS;
var
  i: integer;
  PCS: PRTLCriticalSection;
begin
  for i := 0 to CSList.Count-1 do
  begin 
    PCS := PRTLCriticalSection(CSList.Objects[i]); 
    DeleteCriticalSection(PCS^);
    dispose(PCS);
  end;
  CSList.free;
end;

initialization CSList := NewStrListEx;
finalization ClearCS;

end.