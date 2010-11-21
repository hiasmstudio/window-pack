unit hiLedKey;

interface

uses Windows,Share,Debug;

type
  THILedKey = class(TDebug)
   private
    procedure Key(Code:byte);
   public
    procedure _work_doNumLock(var _Data:TData; Index:word);
    procedure _work_doCapsLock(var _Data:TData; Index:word);
    procedure _work_doScrollLock(var _Data:TData; Index:word);
    procedure _work_doReset(var _Data:TData; Index:word);
    procedure _work_doOn(var _Data:TData; Index:word);
    procedure _work_doNumLockOn(var _Data:TData; Index:word);
    procedure _work_doCapsLockOn(var _Data:TData; Index:word);
    procedure _work_doScrollLockOn(var _Data:TData; Index:word);
    procedure _work_doNumLockOff(var _Data:TData; Index:word);
    procedure _work_doCapsLockOff(var _Data:TData; Index:word);
    procedure _work_doScrollLockOff(var _Data:TData; Index:word);
    procedure _var_NumLock(var _Data:TData; Index:word);
    procedure _var_CapsLock(var _Data:TData; Index:word);
    procedure _var_ScrollLock(var _Data:TData; Index:word);
  end;

implementation

procedure THILedKey.Key;
begin
   keybd_event(Code,$45,1,0);
   keybd_event(Code,$45,3,0);
end;

procedure THILedKey._work_doNumLock;
begin
   if ReadBool(_Data) = (GetKeyState(VK_NUMLOCK) = 0) then
    Key(VK_NUMLOCK);
end;

procedure THILedKey._work_doCapsLock;
begin
   if ReadBool(_Data) = (GetKeyState(VK_CAPITAL) = 0) then
    key(VK_CAPITAL);
end;

procedure THILedKey._work_doScrollLock;
begin
   if ReadBool(_Data) = (GetKeyState(VK_SCROLL) = 0) then
    key(VK_SCROLL);
end;

procedure THILedKey._work_doReset;
begin
   _work_doNumLockOff(_Data,0);
   _work_doCapsLockOff(_Data,0);
   _work_doScrollLockOff(_Data,0);
end;

procedure THILedKey._work_doOn;
begin
   _work_doNumLockOn(_Data,1);
   _work_doCapsLockOn(_Data,1);
   _work_doScrollLockOn(_Data,1);
end;

procedure THILedKey._work_doNumLockOn;
begin
   if GetKeyState(VK_NUMLOCK) = 0 then
    Key(VK_NUMLOCK);
end;

procedure THILedKey._work_doCapsLockOn;
begin
   if GetKeyState(VK_CAPITAL) = 0 then
    key(VK_CAPITAL);
end;

procedure THILedKey._work_doScrollLockOn;
begin
   if GetKeyState(VK_SCROLL) = 0 then
    key(VK_SCROLL);
end;

procedure THILedKey._work_doNumLockOff;
begin
   if GetKeyState(VK_NUMLOCK) = 1 then
    key(VK_NUMLOCK);
end;

procedure THILedKey._work_doCapsLockOff;
begin
   if GetKeyState(VK_CAPITAL) = 1 then
    key(VK_CAPITAL);
end;

procedure THILedKey._work_doScrollLockOff;
begin
   if GetKeyState(VK_SCROLL)  = 1 then
    key(VK_SCROLL);
end;

procedure THILedKey._var_NumLock;
begin
  dtInteger(_Data,GetKeyState(VK_NUMLOCK)and 1);
end;

procedure THILedKey._var_CapsLock;
begin
   dtInteger(_Data,GetKeyState(VK_CAPITAL)and 1);
end;

procedure THILedKey._var_ScrollLock;
begin
   dtInteger(_Data,GetKeyState(VK_SCROLL)and 1);
end;

end.
