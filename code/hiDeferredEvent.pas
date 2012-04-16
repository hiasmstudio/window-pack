unit hiDeferredEvent;

interface

uses Windows, Messages, Kol, Share, Debug;

type
 ThiDeferredEvent = class(TDebug)
   private
    FData: TData;
   public
     _prop_InData: boolean;
     _prop_Delay: cardinal;
     _prop_Data: TData;     
     _data_Data: THI_Event;
     _event_onDeferredEvent: THI_Event;
     procedure _work_doDeferredEvent(var _Data:TData; Index:word);
 end;

implementation

const
  WM_DEFERREDEVENT = WM_USER + 5555;

var
  MyWindowClass: TWndClass;
  FWnd: THandle;

procedure ThiDeferredEvent._work_doDeferredEvent;
begin
  if _prop_InData then
    FData := ReadData(_Data, _data_Data, @_prop_Data)
  else
    dtNull(FData);
  Sleep(_prop_Delay);  
  PostMessage(FWnd, WM_DEFERREDEVENT, LongInt(Self), 0);
end;

//******************************************************************************

function NullWndProc(wnd: THandle; wMsg: Cardinal; wParam, lParam: DWORD): DWORD; stdcall;
begin
  Result := DefWindowProc(wnd, wMsg, wParam, lParam);
end;

function MyWndProc(wnd: THandle; wMsg: Cardinal; wParam, lParam: DWORD): DWORD; stdcall;
var
  MySelf: ThiDeferredEvent;
begin
  Result := 0;
  case wMsg of
     WM_DEFERREDEVENT:
     begin
       MySelf := ThiDeferredEvent(wParam);
       if Assigned(MySelf) then _hi_onEvent(MySelf._event_onDeferredEvent, MySelf.FData);
       Result := 1;
     end;   
  end;
end;

initialization

  MyWindowClass.style := 0;
  MyWindowClass.lpfnWndProc := @NullWndProc;
  MyWindowClass.cbClsExtra := 0;
  MyWindowClass.cbWndExtra := 0;
  MyWindowClass.hInstance := hInstance;
  MyWindowClass.hIcon := 0;
  MyWindowClass.hCursor := 0;
  MyWindowClass.hbrBackground := 0;
  MyWindowClass.lpszMenuName := nil;
  MyWindowClass.lpszClassName := 'Deferred_Event';
  RegisterClass(MyWindowClass);
  FWnd := CreateWindowEx(0, 'Deferred_Event', '', 0, 0, 0, 0, 0, dword(HWND_MESSAGE), 0, hInstance, nil);
  SetWindowLong(FWnd, GWL_WNDPROC, cardinal(@MyWndProc));
  
finalization
  Windows.DestroyWindow(FWnd);
  UnregisterClass('DeferredEvent', hInstance);
  
end.