unit hiDSKSwitch;

interface

uses Windows, Messages, Kol, Share, Debug;
const
  MOD_NONE = 0;
  CLS_ID   = '{ED526154-8DD8-4CDF-B553-F1036BE63DE9}';
  
type
 ThiDSKSwitch = class(TDebug)
   private
     procedure StopDSKSwitch;
     procedure ReInit;
     function ActivateHotKey: boolean;
     procedure DeactivateHotKey;               
   public
     _prop_DSK: integer;
     _prop_Alt,
     _prop_Ctrl,
     _prop_Shift,
     _prop_Win: byte;
     _data_DSK,
     _event_onDSKSwitch,
     _event_onStartDSKSwitch: THI_Event;
     destructor Destroy; override;
     procedure _work_doStartDSKSwitch(var _Data:TData; Index:word);
     procedure _work_doStopDSKSwitch(var _Data:TData; Index:word);
     procedure _work_doDSKSwitch(var _Data:TData; Index:word);     
     procedure _work_doAlt(var _Data:TData; Index:word);     
     procedure _work_doCtrl(var _Data:TData; Index:word);
     procedure _work_doShift(var _Data:TData; Index:word);
     procedure _work_doWin(var _Data:TData; Index:word);               
 end;

implementation

var
  _WndClass: TWNDClassEx;
  hWindow: HWND;
  D1,
  D2,
  D3,
  D4,
  D5: ATOM;
  //----------------------
  //номер предыдущего desktop-а
  PrevDsk,
  //номер текущего desktop-а
  CurrentDsk: integer;
  //список все desktop-ов и их окон верхнего уровня
  DESKTOPS: array [0..4, 0..511] of HWND;
  ACTIVEAPP: array [0..4] of HWND; 

  //три системных окна которые не подлежат изменениям
  DskWindow1,
  DskWindow2,
  DskWindow3: HWND;

  //счетчик окон верхнего уровня для текущего desktop-а
  HWNDCNT: integer;

function EnumWindowsProc(Wnd: HWND; Param: lParam): bool; stdcall;
var
  aName: array [0..255] of Char;
begin
  if IsWindowVisible(Wnd) and (Wnd <> DskWindow1) and (Wnd <> DskWindow2) and (Wnd <> DskWindow3) then
  begin
    GetClassName(wnd, aName, 256);
    // сохраняем дескрипторы окон, отсеивая ненужные
    if (string(aName) <> 'tooltips_class32') and
       (string(aName) <> 'SysShadow')        and
       (string(aName) <> 'DV2ControlHost')   then
    begin                 
      DESKTOPS[PrevDsk, HWNDCNT] := Wnd;
      ShowWindow(Wnd, SW_HIDE);
      inc(HWNDCNT);
    end
    else if (string(aName) = 'tooltips_class32') then
      PostMessage(wnd, TTM_POP, 0, 0)
    else if (string(aName) = 'DV2ControlHost') then
      PostMessage(wnd, WM_SYSCOMMAND, SC_CLOSE, 0);
  end;
  Result := TRUE;
end;

procedure SwitchDesktops;
var
  tmp: integer;
begin
  if CurrentDsk = PrevDsk then exit;
  //обнуляем счетчик окон для текущего desktop-а
  HWNDCNT := 0;
  //достаем хэндлы системных окон
  DskWindow1 := GetDesktopWindow;
  DskWindow2 := FindWindow('Progman', nil);
  DskWindow3 := FindWindow('Shell_TrayWnd', nil);

  ACTIVEAPP[PrevDsk] := GetForegroundWindow;
  FillChar(DESKTOPS[PrevDsk], SizeOf(DESKTOPS[PrevDsk]), 0);
  EnumWindows(@EnumWindowsProc, 0);
  for tmp := High(DESKTOPS[CurrentDsk]) downto Low(DESKTOPS[CurrentDsk]) do
    if DESKTOPS[CurrentDsk, tmp] <> 0 then
      ShowWindow(DESKTOPS[CurrentDsk, tmp], SW_SHOWNA);
  SetForegroundWindow(ACTIVEAPP[CurrentDsk]);      
end;

function WindowProc(WND: HWND; MSG, wParam, LParam: Cardinal):LongInt; stdcall;
var
  _HiClass: ThiDSKSwitch;
begin
  _HiClass := ThiDSKSwitch(Pointer(GetWindowLong(WND, GWL_USERDATA)));
  if _HiClass <> nil then 
  begin
    case MSG of
      WM_HOTKEY:
      begin
        if HiWord(lParam)=Word('1') then
        begin
          PrevDsk := CurrentDsk;
          CurrentDsk := 0;
          SwitchDesktops;
          _hi_onEvent(_HiClass._event_onDSKSwitch, CurrentDsk + 1);
        end;
        if HiWord(lParam) = Word('2') then
        begin
          PrevDsk := CurrentDsk;
          CurrentDsk := 1;
          SwitchDesktops;
          _hi_onEvent(_HiClass._event_onDSKSwitch, CurrentDsk + 1);
        end;
        if HiWord(lParam) = Word('3') then
        begin
          PrevDsk := CurrentDsk;
          CurrentDsk := 2;
          SwitchDesktops;
          _hi_onEvent(_HiClass._event_onDSKSwitch, CurrentDsk + 1);
        end;
        if HiWord(lParam) = Word('4') then
        begin
          PrevDsk := CurrentDsk;
          CurrentDsk := 3;
          SwitchDesktops;
          _hi_onEvent(_HiClass._event_onDSKSwitch, CurrentDsk + 1);
        end;
        if HiWord(lParam) = Word('5') then
        begin
          PrevDsk := CurrentDsk;
          CurrentDsk := 4;
          SwitchDesktops;
          _hi_onEvent(_HiClass._event_onDSKSwitch, CurrentDsk + 1);
        end;      
      end; //WM_HOTKEY
    end;// case
  end;
  Result := DefWindowProc(Wnd, Msg, wParam, lParam);
end;

//==============================================================================
function ThiDSKSwitch.ActivateHotKey: boolean;
var
  _MOD: Word;
begin
  D1 := GlobalAddAtom('DSK1');
  D2 := GlobalAddAtom('DSK2');
  D3 := GlobalAddAtom('DSK3');
  D4 := GlobalAddAtom('DSK4');
  D5 := GlobalAddAtom('DSK5');  

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

  Result := RegisterHotKey(hWindow, D1, _MOD, WORD('1')) and
            RegisterHotKey(hWindow, D2, _MOD, WORD('2')) and
            RegisterHotKey(hWindow, D3, _MOD, WORD('3')) and
            RegisterHotKey(hWindow, D4, _MOD, WORD('4')) and
            RegisterHotKey(hWindow, D5, _MOD, WORD('5'));            
end;  

procedure ThiDSKSwitch.DeactivateHotKey;
begin
  UnRegisterHotKey(hWindow, D1);
  UnRegisterHotKey(hWindow, D2);
  UnRegisterHotKey(hWindow, D3);
  UnRegisterHotKey(hWindow, D4);
  UnRegisterHotKey(hWindow, D5);  
  GlobalDeleteAtom(D1);
  GlobalDeleteAtom(D2);
  GlobalDeleteAtom(D3);    
  GlobalDeleteAtom(D4);
  GlobalDeleteAtom(D5);  
end;

procedure ThiDSKSwitch.StopDSKSwitch;
var
  x, y: integer;
begin
  //перед завершением работы отображаем все окна со всех desktop-ов
  for x := 0 to 4 do
    for y := 0 to 511 do
      if DESKTOPS[x, y] <> 0 then ShowWindow(DESKTOPS[x, y], SW_SHOW);
  SetForegroundWindow(ACTIVEAPP[CurrentDsk]); 
  FillChar(DESKTOPS, SizeOf(DESKTOPS), 0);
  FillChar(ACTIVEAPP, SizeOf(ACTIVEAPP), 0);        
  DeactivateHotKey;
  SetWindowLong(hWindow, GWL_USERDATA, 0);
  if hWindow <> 0 then
    DestroyWindow(hWindow);
  hWindow := 0;  
  PrevDsk := -1;
  CurrentDsk := 0;  
  UnregisterClass(PChar(CLS_ID), hInstance);  
end;

destructor ThiDSKSwitch.Destroy;
begin
  StopDSKSwitch;
  inherited;
end;  

procedure ThiDSKSwitch._work_doStartDSKSwitch;
begin
  with _WndClass do
  begin
    cbSize := SizeOf(_WndClass);
    lpfnWndProc := @WindowProc;
    cbClsExtra := 0;
    cbWndExtra := 0;
    hInstance := hInstance;
    lpszClassName := PChar(CLS_ID);
  end;

  StopDSKSwitch;
  if RegisterClassEx(_WndClass) = 0 then
  begin
    _hi_CreateEvent(_Data, @_event_onStartDSKSwitch, 1);
    exit;
  end;

  CurrentDsk := max(min(ReadInteger(_Data, _data_DSK, _prop_DSK) - 1, 4), 0);
  PrevDsk := CurrentDsk - 1; 

  hWindow := CreateWindow(PChar(CLS_ID), nil, 0, 0, 0, 0, 0, 0, 0, hInstance, nil);
  if hWindow = 0 then
  begin
    StopDSKSwitch;
    _hi_CreateEvent(_Data, @_event_onStartDSKSwitch, 2);
    exit;
  end;
  SetWindowLong(hWindow, GWL_USERDATA, LongInt(Self));
  if not ActivateHotKey then
  begin
    StopDSKSwitch;
    _hi_CreateEvent(_Data, @_event_onStartDSKSwitch, 3);
    exit;
  end;
  _hi_onEvent(_event_onStartDSKSwitch, 0);
  _hi_CreateEvent(_Data, @_event_onDSKSwitch, CurrentDsk + 1);
end;

procedure ThiDSKSwitch._work_doStopDSKSwitch;
begin
  StopDSKSwitch;
end;

procedure ThiDSKSwitch._work_doDSKSwitch;
begin
  PrevDsk := CurrentDsk;
  CurrentDsk := max(min(ReadInteger(_Data, _data_DSK, _prop_DSK) - 1, 4), 0);
  SwitchDesktops;
  _hi_CreateEvent(_Data, @_event_onDSKSwitch, CurrentDsk + 1); 
end;

procedure ThiDSKSwitch.ReInit;
begin
  DeactivateHotKey;
  if ActivateHotKey then exit;
  _hi_onEvent(_event_onStartDSKSwitch, 3);
end;

procedure ThiDSKSwitch._work_doAlt;
begin
  _prop_Alt := ToInteger(_Data);
  ReInit;
end;

procedure ThiDSKSwitch._work_doCtrl;
begin
  _prop_Ctrl := ToInteger(_Data);
  ReInit;
end;

procedure ThiDSKSwitch._work_doShift;
begin
  _prop_Shift := ToInteger(_Data);
  ReInit;
end;

procedure ThiDSKSwitch._work_doWin;
begin
  _prop_Win := ToInteger(_Data);
  ReInit;  
end;

end.