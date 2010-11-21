unit hiGHotKey;

interface

uses Windows, Messages, Kol, Share, Debug;

const
  MOD_NONE = 0;
  
type
 ThiGHotKey = class(TDebug)
   private

     _WndClass: TWNDClassEx;
     hWindow: HWND;
     KeyID: ATOM;
     fClassName: string;

     procedure StopHotKey;
     procedure ReInit;
     function ActivateHotKey: boolean;
     procedure DeactivateHotKey;               
   public

     _prop_Key,
     _prop_Alt,
     _prop_Ctrl,
     _prop_Shift,
     _prop_Win: byte;

     _data_Key,
     _event_onError,
     _event_onEventHotKey,     
     _event_onStopHotKey,
     _event_onStartHotKey: THI_Event;
     destructor Destroy; override;
     procedure _work_doStartHotKey(var _Data:TData; Index:word);
     procedure _work_doStopHotKey(var _Data:TData; Index:word);
     procedure _work_doAlt(var _Data:TData; Index:word);
     procedure _work_doCtrl(var _Data:TData; Index:word);
     procedure _work_doShift(var _Data:TData; Index:word);
     procedure _work_doWin(var _Data:TData; Index:word);
     procedure _work_doKey(var _Data:TData; Index:word);     
 end;

implementation

function WindowProc(WND: HWND; MSG, wParam, LParam: Cardinal):LongInt; stdcall;
var
  _HiClass: ThiGHotKey;
begin
  _HiClass := ThiGHotKey(Pointer(GetWindowLong(WND, GWL_USERDATA)));
  if _HiClass <> nil then 
  begin
    case MSG of
      WM_HOTKEY:
        if HiWord(lParam) = Word(_HiClass._prop_Key) then
          _hi_onEvent(_HiClass._event_onEventHotKey);
    end;// case
  end;  
  Result := DefWindowProc(Wnd, Msg, wParam, lParam);
end;

//==============================================================================
function ThiGHotKey.ActivateHotKey: boolean;
var
  _MOD: Word;
begin
  KeyID := GlobalAddAtom('KeyID');

  _MOD := MOD_NONE;
  case _prop_Alt of
    1: _MOD := _MOD or MOD_ALT;
  end;   
  case _prop_Ctrl of
    1: _MOD := _MOD or MOD_CONTROL;
  end;   
  case _prop_Shift of
    1: _MOD := _MOD or MOD_SHIFT;
  end;   
  case _prop_Win of
    1: _MOD := _MOD or MOD_WIN;
  end;   

  Result := RegisterHotKey(hWindow, KeyID, _MOD, WORD(_prop_Key));            
end;  

procedure ThiGHotKey.DeactivateHotKey;
begin
  UnRegisterHotKey(hWindow, KeyID);
  GlobalDeleteAtom(KeyID);
end;

procedure ThiGHotKey.StopHotKey;
begin
  DeactivateHotKey;
  SetWindowLong(hWindow, GWL_USERDATA, 0);
  if hWindow <> 0 then
    DestroyWindow(hWindow);
  hWindow := 0;  
  UnregisterClass(@fClassName[1], hInstance);  
end;

destructor ThiGHotKey.Destroy;
begin
  StopHotKey;
  inherited;
end;  

procedure ThiGHotKey._work_doStartHotKey;
begin

  with _WndClass do
  begin
    cbSize := SizeOf(_WndClass);
    lpfnWndProc := @WindowProc;
    cbClsExtra := 0;
    cbWndExtra := 0;
    hInstance := hInstance;
    fClassName := 'HotKeyWindows' + '_' + int2str(_prop_Key);  
    lpszClassName := @fClassName[1];
  end;

  StopHotKey;
  if RegisterClassEx(_WndClass) = 0 then
  begin
    _hi_CreateEvent(_Data, @_event_onError, 1);
    exit;
  end;

  hWindow := CreateWindow(@fClassName[1], nil, 0, 0, 0, 0, 0, 0, 0, hInstance, nil);
  if hWindow = 0 then
  begin
    StopHotKey;
    _hi_CreateEvent(_Data, @_event_onError, 2);
    exit;
  end;
  SetWindowLong(hWindow, GWL_USERDATA, LongInt(Self));
  if not ActivateHotKey then
  begin
    StopHotKey;
    _hi_CreateEvent(_Data, @_event_onError, 3);
    exit;
  end;
  _hi_onEvent(_event_onStartHotKey);
end;

procedure ThiGHotKey._work_doStopHotKey;
begin
  StopHotKey;
  _hi_onEvent(_event_onStopHotKey);    
end;

procedure ThiGHotKey.ReInit;
begin
  DeactivateHotKey;
  if ActivateHotKey then exit;
  _hi_onEvent(_event_onError, 3);
end;

procedure ThiGHotKey._work_doAlt;
begin
  _prop_Alt := ToInteger(_Data);
  ReInit;
end;

procedure ThiGHotKey._work_doCtrl;
begin
  _prop_Ctrl := ToInteger(_Data);
  ReInit;
end;

procedure ThiGHotKey._work_doShift;
begin
  _prop_Shift := ToInteger(_Data);
  ReInit;
end;

procedure ThiGHotKey._work_doWin;
begin
  _prop_Win := ToInteger(_Data);
  ReInit;  
end;

procedure ThiGHotKey._work_doKey;
begin
  _prop_Key := ToInteger(_Data);
  ReInit;  
end;

end.