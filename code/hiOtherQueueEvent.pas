unit hiOtherQueueEvent;

interface

uses Windows, Messages, Kol, Share, Debug;

const
  WM_NEXTQUEUE = WM_USER + 5555;

type
 ThiOtherQueueEvent = class(TDebug)
   private
    FData: TData;   
    OldMessage: TOnMessage;
    function OnMessage( var Msg: TMsg; var Rslt: Integer ): Boolean;
   public
     _prop_InData: boolean;
     _event_onOtherQueueEvent: THI_Event;
     constructor Create;
     procedure _work_doOtherQueueEvent(var _Data:TData; Index:word);
 end;

implementation

constructor ThiOtherQueueEvent.Create;
begin
  inherited;
  OldMessage := Applet.OnMessage;
  Applet.OnMessage := OnMessage;                                            
end;

procedure ThiOtherQueueEvent._work_doOtherQueueEvent;
begin
  Applet.OnMessage := OnMessage;
  if _prop_InData then
    FData := ReadData(_Data, Null)
  else
    dtNull(FData);  
  PostMessage(Applet.Handle, WM_NEXTQUEUE, 0, 0)
end;

function ThiOtherQueueEvent.OnMessage;
begin
  Result := false;
  Case Msg.message Of
    WM_NEXTQUEUE:
    begin
      Applet.OnMessage := OldMessage;
      Result := true;
      _hi_onEvent(_event_onOtherQueueEvent, FData)
    end; 
  end;
  Result := Result or _hi_OnMessage(OldMessage, Msg,Rslt);
end;

end.