unit hiWinExec;

interface

uses Kol,Share,Windows,ShellApi,Debug;

type
  THIWinExec = class(TDebug)
   private
     hProcess: THandle;
     hPipeInputWrite: THandle;
     hPipeOutputRead: THandle;
     hPipeErrorsRead: THandle;
     hPipeInputRead: THandle;
     hPipeOutputWrite: THandle;
     hPipeErrorsWrite: THandle;
     
     dwReadThreadID: dword;
     hReadThread: THandle;
     FRead: boolean;

     procedure Read;
     procedure Terminate;
   public
    _prop_Param:string;
    _prop_FileName:string;
    _prop_Mode:byte;
    _prop_RunEvent:procedure(const Fn,Params:string) of object;

    _data_Params:THI_Event;
    _data_FileName:THI_Event;
    _event_onExec:THI_Event;
    _event_onConsoleResult:THI_Event;
    _event_onConsoleError:THI_Event;
    _event_onConsoleTerminate:THI_Event;

    procedure Wait(const Fn,Params:string);
    procedure Async(const Fn,Params:string);

    procedure _work_doExec(var _Data:TData; Index:word);
    procedure _work_doRunCpl(var _Data:TData; Index:word);
    procedure _work_doShellExec(var _Data:TData; Index:word);
    procedure _work_doConsoleExec(var _Data:TData; Index:word);
    procedure _work_doConsoleInput(var _Data:TData; Index:word);
    procedure _work_doConsoleTerminate(var _Data:TData; Index:word);
    
    destructor Destroy; override;
  end;

implementation

procedure THIWinExec.Wait;
var
  si: Tstartupinfo;
  p: Tprocessinformation;
begin
  FillChar( Si, SizeOf( Si ) , 0 );
  with Si do
   begin
    cb := SizeOf( Si);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := _prop_Mode;
   end;

  CreateProcess(nil,PChar(trim(Fn + ' ' + Params)), nil, nil,
             false, CREATE_DEFAULT_ERROR_MODE, nil, nil, si, p);
  WaitForSingleObject(p.hProcess, INFINITE);
   _hi_onEvent(_event_onExec);
end;

procedure THIWinExec.Async;
begin
   if WinExec(PChar(trim(Fn + ' ' + Params)),_prop_Mode)>31 then
     _hi_onEvent(_event_onExec);
end;

procedure THIWinExec._work_doRunCpl;
var FN:string;
begin
   Fn := ReadString(_Data,_data_FileName,_prop_FileName);
   WinExec(PChar('rundll32.exe shell32.dll,Control_RunDLL ' + fn),_prop_Mode)
end;

procedure THIWinExec._work_doExec;
var FN,params:string;
begin
   Fn := ReadString(_Data,_data_FileName,_prop_FileName);
   Params := ReadString(_Data,_data_Params,_prop_Param);
   _prop_RunEvent(Fn,Params);
end;

procedure THIWinExec._work_doShellExec;
var FN,params:string;
begin
   Fn := ReadString(_Data,_data_FileName,_prop_FileName);
   Params := ReadString(_Data,_data_Params,_prop_Param);
   ShellExecute(0,'open',pchar(fn),PChar(Params), '',_prop_Mode);
end;

function ReadFunc(Parent:THIWinExec):cardinal; stdcall;
begin
   Parent.Read;
   Result := 0;
end;

procedure THIWinExec.Read;
var Total:dword; bWait:boolean; hWait:THandle; bError:boolean; 
  pBuffer: array[0..1024] of char;
begin
  hWait := CreateEvent(nil,false,false,nil); bError := false;
  while FRead and not bError do begin
    bWait := true;
    if not PeekNamedPipe(hPipeErrorsRead,nil,0,nil,@Total,nil) then bError := true;
    if Total>0 then begin
      bWait := false;
      if ReadFile(hPipeErrorsRead, pBuffer, 1024, Total, nil) then begin
         pBuffer[Total] := #0;
        _hi_OnEvent(_event_onConsoleError, pBuffer);
      end;
    end;
    if not PeekNamedPipe(hPipeOutputRead,nil,0,nil,@Total,nil) then bError := true;
    if Total>0 then begin
      bWait := false;
      if ReadFile(hPipeOutputRead, pBuffer, 1024, Total, nil) then begin
         pBuffer[Total] := #0;
        _hi_OnEvent(_event_onConsoleResult, pBuffer);
      end;
    end;
    if bWait then WaitForSingleObject(hWait,1);
  end;
  CloseHandle(hWait);
  if bError then begin
    Terminate;
    _hi_OnEvent(_event_onConsoleTerminate);
  end;
end;

procedure THIWinExec.Terminate;
begin
  if hProcess<>0 then begin
    FRead := false;
    TerminateProcess(hProcess, 0);
    CloseHandle(hProcess);
    CloseHandle(hPipeInputRead);
    CloseHandle(hPipeOutputWrite);
    CloseHandle(hPipeErrorsWrite);
    CloseHandle(hPipeInputWrite);
    CloseHandle(hPipeOutputRead);
    CloseHandle(hPipeErrorsRead);
    CloseHandle(hReadThread);
    hProcess := 0;
  end;
end;

procedure THIWinExec._work_doConsoleExec;
var
  sa: TSECURITYATTRIBUTES;
  si: TSTARTUPINFO;
  pi: TPROCESSINFORMATION;
  Res: Boolean;
  CommandLine:string;
  FN,params:string;
begin
  Fn := ReadString(_Data,_data_FileName,_prop_FileName);
  Params := ReadString(_Data,_data_Params,_prop_Param);
  CommandLine := Fn + ' ' + Params;
  
  Terminate;
  
  sa.nLength := sizeof(sa);
  sa.bInheritHandle := true;
  sa.lpSecurityDescriptor := nil;
  
  CreatePipe(hPipeInputRead, hPipeInputWrite, @sa, 0);
  CreatePipe(hPipeOutputRead, hPipeOutputWrite, @sa, 0);
  CreatePipe(hPipeErrorsRead, hPipeErrorsWrite, @sa, 0);
  
  ZeroMemory(@si, SizeOf(si));
  ZeroMemory(@pi, SizeOf(pi));
  
  si.cb := SizeOf(si);
  si.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
  si.wShowWindow := SW_HIDE;
  si.hStdInput := hPipeInputRead;
  si.hStdOutput := hPipeOutputWrite;
  si.hStdError := hPipeErrorsWrite;

  Res := CreateProcess(nil, PChar(CommandLine), nil, nil, true,
    CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil, si, pi);

  // Procedure will exit if CreateProcess fail
  if not Res then
  begin
    CloseHandle(hPipeInputRead);
    CloseHandle(hPipeOutputWrite);
    CloseHandle(hPipeErrorsWrite);
    CloseHandle(hPipeInputWrite);
    CloseHandle(hPipeOutputRead);
    CloseHandle(hPipeErrorsRead);
    hProcess := 0;
    Exit;
  end;
  
  hProcess := pi.hProcess; FRead := true;
  hReadThread := CreateThread(nil,1024,@ReadFunc,Self,0,dwReadThreadID);

  _hi_onEvent(_event_onExec);
end;

procedure THIWinExec._work_doConsoleInput;
var Total:dword; s:string;
begin
  if hProcess=0 then Exit;
  s := ToString(_Data);
  WriteFile(hPipeInputWrite, PChar(s)^, Length(s), Total, nil);
end;

procedure THIWinExec._work_doConsoleTerminate;
begin
  Terminate;
  _hi_OnEvent(_event_onConsoleTerminate);
end;

destructor THIWinExec.Destroy;
begin
  Terminate;
  inherited;
end;

end.
