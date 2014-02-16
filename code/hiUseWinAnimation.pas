unit hiUseWinAnimation;

interface
     
uses Windows,Kol,Share,Debug,Win;

type
  THIUseWinAnimation = class(TDebug)
   private
   public
     _prop_Time: integer;
     _prop_ActivationMode: byte;
     _prop_CENTER: boolean;
     _prop_SLIDE: boolean;
     _prop_HOR_POSITIVE: boolean;
     _prop_HOR_NEGATIVE: boolean;
     _prop_VER_POSITIVE: boolean;
     _prop_VER_NEGATIVE: boolean;     

     _prop_ControlManager:IControlManager;
     procedure _work_doAnimation(var _Data:TData; Index:word);
     procedure _work_doRedrawWindow(var _Data:TData; Index:word);     
     procedure _work_doActivationMode(var _Data:TData; Index:word);
     procedure _work_doCENTER(var _Data:TData; Index:word);
     procedure _work_doSLIDE(var _Data:TData; Index:word);
     procedure _work_doHOR_POSITIVE(var _Data:TData; Index:word);
     procedure _work_doHOR_NEGATIVE(var _Data:TData; Index:word);
     procedure _work_doVER_POSITIVE(var _Data:TData; Index:word);
     procedure _work_doVER_NEGATIVE(var _Data:TData; Index:word);                                   
  end;

implementation

function AnimateWindow(hWnd: HWND; dwTime: DWORD; dwFlags: DWORD): BOOL; stdcall; external 'user32.dll' name 'AnimateWindow';

procedure THIUseWinAnimation._work_doAnimation;
var
  sControl: PControl;
  dwFlags: DWord;
begin
  if not Assigned(_prop_ControlManager) then exit;
  sControl := _prop_ControlManager.ctrlpoint;
  case _prop_ActivationMode of
    0: dwFlags := AW_ACTIVATE;
    1: dwFlags := AW_HIDE;
  end;
  if _prop_CENTER then dwFlags := AW_CENTER or dwFlags;  
  if _prop_SLIDE then dwFlags := AW_SLIDE or dwFlags;
  if _prop_HOR_POSITIVE then dwFlags := AW_HOR_POSITIVE or dwFlags;
  if _prop_HOR_NEGATIVE then dwFlags := AW_HOR_NEGATIVE or dwFlags;             
  if _prop_VER_POSITIVE then dwFlags := AW_VER_POSITIVE or dwFlags;
  if _prop_VER_NEGATIVE then dwFlags := AW_VER_NEGATIVE or dwFlags;             
  AnimateWindow(sControl.Handle, _prop_Time, dwFlags);
end;

procedure THIUseWinAnimation._work_doRedrawWindow;
var
  sControl: PControl;
begin
  if not Assigned(_prop_ControlManager) then exit;
  sControl := _prop_ControlManager.ctrlpoint;
  RedrawWindow(sControl.Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_FRAME or RDW_ALLCHILDREN);
end;  

procedure THIUseWinAnimation._work_doActivationMode;
begin
  _prop_ActivationMode := ToInteger(_Data);
end;

procedure THIUseWinAnimation._work_doCENTER;
begin
  _prop_CENTER := ReadBool(_Data);
end;

procedure THIUseWinAnimation._work_doSLIDE;
begin
  _prop_SLIDE := ReadBool(_Data);
end;

procedure THIUseWinAnimation._work_doHOR_POSITIVE;
begin
  _prop_HOR_POSITIVE := ReadBool(_Data);
end;

procedure THIUseWinAnimation._work_doHOR_NEGATIVE;
begin
  _prop_HOR_NEGATIVE := ReadBool(_Data);
end;

procedure THIUseWinAnimation._work_doVER_POSITIVE;
begin
  _prop_VER_POSITIVE := ReadBool(_Data);
end;

procedure THIUseWinAnimation._work_doVER_NEGATIVE;                                   
begin
  _prop_VER_NEGATIVE := ReadBool(_Data);
end;

end.