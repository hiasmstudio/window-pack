unit hiKeyHook;

interface

uses Kol,Share,Windows,Messages,Debug;

{$I def.inc}

type
  THIKeyHook = class(TDebug)
   private
    FID:cardinal;
    OldMessage:TOnMessage;
    Parent:PControl;
    flag:integer;

    function _OnMessage( var Msg: TMsg; var Rslt: Integer ): Boolean;
    procedure Init;
   public
    _event_onRepeat:THI_Event;
    _event_onKeyUp:THI_Event;
    _event_onKeyDown:THI_Event;

    constructor Create(_Parent:PControl);
    destructor Destroy; override;
    procedure _var_Handle(var _Data:TData; Index:word);
    procedure _work_doKillKey(var _Data:TData; Index:word);
  end;

implementation

constructor THIKeyHook.Create;
begin
   inherited Create;
   Parent := _Parent;
   OldMessage := Parent.OnMessage;
   Parent.OnMessage := _OnMessage;
   InitAdd(Init);
end;

procedure THIKeyHook.Init;
type
  SetHook = procedure(Handle:HWND); cdecl;
begin
   {if FileExists('Plug\Hook.dll') then
    FID := LoadLibrary('Plug\Hook.dll')
   else }if FileExists(GetStartDir + 'Hook.dll') then
    FID := LoadLibrary(PChar(GetStartDir + 'Hook.dll'))
   else FID := LoadLibrary('Hook.dll');

   if FID > 0 then
     SetHook( GetProcAddress(FID,'SetHook') )(Parent.GetWindowHandle)
   {$ifdef _ERROR_STD_}
   else MessageBox(Parent.Handle,'File Hook.dll not found!','KeyHook error',MB_OK);
   {$endif}
end;

destructor THIKeyHook.Destroy;
type
  ClearHook = procedure; cdecl;
begin
   if FID > 0 then
    begin
     ClearHook(GetProcAddress(FID,'ClearHook'))();
     FreeLibrary(FID);
    end;
   inherited Destroy;
end;

procedure THIKeyHook._work_doKillKey;
begin
  flag := 0;
end;

function THIKeyHook._OnMessage;
begin
   if Msg.message = WM_USER + 33 then
    begin
     flag := 1;
     if HiWord(Msg.lParam) and KF_UP = KF_UP then
          _hi_OnEvent(_event_onKeyUp,Msg.wParam)
     else if HiWord(Msg.lParam) and KF_REPEAT = KF_REPEAT then
          _hi_OnEvent(_event_onRepeat,Msg.wParam)
     else _hi_OnEvent(_event_onKeyDown,Msg.wParam);
     Result := true;
     Rslt := flag;
    end
   else  Result := _hi_OnMessage(OldMessage,Msg,Rslt);
end;

procedure THIKeyHook._var_Handle;
begin
   dtInteger(_Data, GetForegroundWindow);
end;

end.
