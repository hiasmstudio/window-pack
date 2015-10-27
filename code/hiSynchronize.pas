unit hiSynchronize;

interface

uses
  Windows, Kol, Share;


type

  TSyncMethod = procedure (UserData: Pointer) of object;
  
  
  ThiSynchronize = class
    private
      procedure SyncMethod(UserData: Pointer);
    public
      _data_Data: THI_Event;   
      _event_onSync: THI_Event;   
      procedure _work_doSynchronize(var _Data: TData; Index: Word);
  end;
  
  procedure CallSynchronized(Mthd: TSyncMethod; UserData: Pointer = nil);
  

implementation

uses 
  Messages;
  
const
  AM_SYNC_METHOD = WM_APP + 2; // Сменить, если будет обнаружен конфликт с другими компонентами

var
  ProcAttached: Boolean = False;


function WndProcSyncMethod(Sender: PControl; var Msg: TMsg; var Rslt: Integer): Boolean;
var 
  Mthd: TSyncMethod;
begin
  Result := False;
  if Msg.Message = AM_SYNC_METHOD then
  begin
    Mthd := TSyncMethod(Pointer(Msg.wParam)^);
    Mthd(Pointer(Msg.lParam));
    Rslt := 0;
  end;
end;

procedure CallSynchronized(Mthd: TSyncMethod; UserData: Pointer = nil);
begin
  if Assigned(Applet) then
  begin
    if not ProcAttached then
    begin
      Applet.AttachProc(WndProcSyncMethod);
      ProcAttached := True;
    end;
    SendMessage(Applet.Handle, AM_SYNC_METHOD, Integer(@@Mthd), Integer(UserData));
  end
  else
  begin
    // Если нет возможности синхронизации - вызываем метод стандартно
    Mthd(UserData);
  end;
end;

procedure ThiSynchronize.SyncMethod(UserData: Pointer);
var
  Dt: TData;
begin
  Dt := ReadData(PData(UserData)^, _data_Data);
  _hi_OnEvent(_event_onSync, Dt);
end;

procedure ThiSynchronize._work_doSynchronize(var _Data: TData; Index: Word);
begin
  CallSynchronized(SyncMethod, @_Data);
end;

end.
