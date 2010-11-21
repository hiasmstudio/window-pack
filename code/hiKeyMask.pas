unit hiKeyMask;

interface

uses Kol,Share,Windows,Debug;

type
  THIKeyMask = class(TDebug)
   private
   public
    _prop_Shift:byte;
    _prop_Ctrl:byte;
    _prop_Alt:byte;
    _prop_Key:integer;
    _data_Key:THI_Event;
    _event_onTrue:THI_Event;
    _event_onFalse:THI_Event;

    procedure _work_doCheckMask(var _Data:TData; Index:word);
  end;

implementation

function CheckKeyMask(State:byte; Code:byte):boolean;
begin
   case State of
    0: Result := true;
    1: Result := GetKeyState(Code) < 0;
    else Result := GetKeyState(Code) >= 0;
   end;
end;

procedure THIKeyMask._work_doCheckMask;
var key:byte;
     dt:TData;
begin
    dt := _Data;
    key := ReadInteger(dt,_data_Key);
     if CheckKeyMask(_prop_Shift,VK_SHIFT) then
       if CheckKeyMask(_prop_Ctrl,VK_CONTROL) then
         if CheckKeyMask(_prop_Alt,VK_ALT) then
           if _prop_Key = Key then begin
             _hi_CreateEvent(_Data,@_event_onTrue,dt);
             Exit;
           end;
    _hi_CreateEvent_(_Data,@_event_onFalse);
end;

end.
