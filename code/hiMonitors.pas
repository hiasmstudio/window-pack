unit HiMonitors;

interface

uses Windows, kol, Share, Debug;

const
  { GetSystemMetrics() codes }
  SM_XVIRTUALSCREEN  = 76;
  SM_YVIRTUALSCREEN  = 77;
  SM_CXVIRTUALSCREEN = 78;
  SM_CYVIRTUALSCREEN = 79;
  
type
  HMONITOR = type Integer;

  tagMONITORINFOA = record
    cbSize: DWORD;
    rcMonitor: TRect;
    rcWork: TRect;
    dwFlags: DWORD;
  end;
  tagMONITORINFO = tagMONITORINFOA;
  MONITORINFOA = tagMONITORINFOA;
  MONITORINFO = MONITORINFOA;
  LPMONITORINFOA = ^tagMONITORINFOA;
  LPMONITORINFO = LPMONITORINFOA;
  PMonitorInfoA = ^tagMONITORINFO;
  PMonitorInfo = PMonitorInfoA;
  TMonitorInfoA = tagMONITORINFO;
  TMonitorInfo = TMonitorInfoA;

TMonitorEnumProc = function(hm: HMONITOR; dc: HDC; r: PRect; l: LPARAM): Boolean; stdcall;

function GetMonitorInfo(hMonitor: HMONITOR; lpMonitorInfo: PMonitorInfoA): Boolean; stdcall;
         external 'USER32.DLL' name 'GetMonitorInfoA';

function EnumDisplayMonitors(hdc: HDC; lprcIntersect: PRect; lpfnEnumProc: TMonitorEnumProc;
         lData: LPARAM): Boolean; stdcall; external 'USER32.DLL' name 'EnumDisplayMonitors';
    

type
  TMonitor = class;
  PMonitor = TMonitor;
  TMonitor = class(TDebug)
  private
    FHandle: HMONITOR;
    FMonitorNum: Integer;
    function GetLeft: Integer;
    function GetHeight: Integer;
    function GetTop: Integer;
    function GetWidth: Integer;
    function GetRect: TRect;
    
    function GetWorkLeft: Integer;
    function GetWorkHeight: Integer;
    function GetWorkTop: Integer;
    function GetWorkWidth: Integer;
    function GetWorkRect: TRect;

    function GetStatus: Integer;	    
  end;

type
 THiMonitors = class(TDebug)
   private
    FMonitors: PList;
   public
	_prop_WorkArea: boolean;
	_prop_Monitor: integer;
	_data_Monitor: THI_Event;
    _event_onScreenShort: THI_Event;
    _event_onParametrs: THI_Event;
    constructor Create;
    destructor Destroy; override;
    procedure _work_doScreenShortMonitor(var _Data:TData; idx:word);
    procedure _work_doMonitorParametrs(var _Data:TData; idx:word);
    procedure _work_doWorkArea(var _Data:TData; idx:word);    
    procedure _var_Count(var _Data:TData; idx:word);
 end;

implementation

function TMonitor.GetLeft: Integer;
var
  MonInfo: TMonitorInfo;
begin
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(FHandle, @MonInfo);
  Result := MonInfo.rcMonitor.Left;
end;

function TMonitor.GetWorkLeft: Integer;
var
  MonInfo: TMonitorInfo;
begin
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(FHandle, @MonInfo);
  Result := MonInfo.rcWork.Left;
end;

function TMonitor.GetHeight: Integer;
var
  MonInfo: TMonitorInfo;
begin
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(FHandle, @MonInfo);
  Result := MonInfo.rcMonitor.Bottom - MonInfo.rcMonitor.Top;
end;

function TMonitor.GetWorkHeight: Integer;
var
  MonInfo: TMonitorInfo;
begin
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(FHandle, @MonInfo);
  Result := MonInfo.rcWork.Bottom - MonInfo.rcWork.Top;
end;

function TMonitor.GetTop: Integer;
var
  MonInfo: TMonitorInfo;
begin
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(FHandle, @MonInfo);
  Result := MonInfo.rcMonitor.Top;
end;

function TMonitor.GetWorkTop: Integer;
var
  MonInfo: TMonitorInfo;
begin
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(FHandle, @MonInfo);
  Result := MonInfo.rcWork.Top;
end;

function TMonitor.GetWidth: Integer;
var
  MonInfo: TMonitorInfo;
begin
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(FHandle, @MonInfo);
  Result := MonInfo.rcMonitor.Right - MonInfo.rcMonitor.Left;
end;

function TMonitor.GetWorkWidth: Integer;
var
  MonInfo: TMonitorInfo;
begin
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(FHandle, @MonInfo);
  Result := MonInfo.rcWork.Right - MonInfo.rcWork.Left;
end;

function TMonitor.GetRect: TRect;
var
  MonInfo: TMonitorInfo;
begin
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(FHandle, @MonInfo);
  Result := MonInfo.rcMonitor;
end;

function TMonitor.GetWorkRect: TRect;
var
  MonInfo: TMonitorInfo;
begin
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(FHandle, @MonInfo);
  Result := MonInfo.rcWork;
end;

function TMonitor.GetStatus: Integer;
var
  MonInfo: TMonitorInfo;
begin
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(FHandle, @MonInfo);
  Result := MonInfo.dwFlags;
end;

//------------------------------------------------------------------------------

function EnumMonitorsProc(hm: HMONITOR; dc: HDC; r: PRect; Data: Pointer): Boolean; stdcall;
var
  L: PList;
  M: TMonitor;
begin
  L := PList(Data);
  M := TMonitor.Create;
  M.FHandle := hm;
  M.FMonitorNum := L.Count;
  L.Add(M);
  Result := True;
end;

constructor THiMonitors.Create;
begin
  inherited;
  FMonitors := NewList;
  EnumDisplayMonitors(0, nil, @EnumMonitorsProc, LongInt(FMonitors));
end;  

destructor THiMonitors.Destroy;
begin
  FMonitors.free;
  inherited;
end;

procedure THiMonitors._work_doMonitorParametrs;
var
  dt: TData;
  mt: PMT;
  M: TMonitor;
  i: integer;
begin
  i := ToInteger(_Data);
  if (i < -1) or (i > FMonitors.Count - 1) then exit;
  if i = -1 then
  begin
    dtInteger(dt, GetSystemMetrics(SM_XVIRTUALSCREEN));  
    mt := mt_make(dt);
    mt_int(mt, GetSystemMetrics(SM_YVIRTUALSCREEN));
    mt_int(mt, GetSystemMetrics(SM_CXVIRTUALSCREEN));
    mt_int(mt, GetSystemMetrics(SM_CYVIRTUALSCREEN));    
  end
  else
  begin
    M := TMonitor(FMonitors.Items[i]);
    dtInteger(dt, M.GetLeft);
    mt := mt_make(dt);
    mt_int(mt, M.GetTop);
    mt_int(mt, M.GetWidth);
    mt_int(mt, M.GetHeight);

    mt_int(mt, M.GetWorkLeft);
    mt_int(mt, M.GetWorkTop);
    mt_int(mt, M.GetWorkWidth);
    mt_int(mt, M.GetWorkHeight);

    mt_int(mt, M.GetStatus);
  end;
  _hi_onEvent_(_event_onParametrs, dt);
  mt_free(mt);            
end;

procedure THiMonitors._work_doScreenShortMonitor;
var
  M: TMonitor;
  i: integer;
  DC: HDC;
  bmp, tmp: PBitmap;
begin
  i := ReadInteger(_Data, _data_Monitor, _prop_Monitor);
  if (i < -1) or (i > FMonitors.Count - 1) then exit;
  DC := GetDC(0);
  tmp := NewBitmap(GetSystemMetrics(SM_CXVIRTUALSCREEN), GetSystemMetrics(SM_CYVIRTUALSCREEN));
  BitBlt(tmp.Canvas.Handle, 0, 0, tmp.Width, tmp.Height, DC, 0, 0, SRCCOPY);

  if i <> -1 then
  begin
    M := TMonitor(FMonitors.Items[i]);
	if _prop_WorkArea then
	begin
      bmp := NewBitmap(M.GetWorkWidth, M.GetWorkHeight);
      bmp.Canvas.CopyRect(bmp.Canvas.ClipRect, tmp.Canvas, M.GetWorkRect);
    end  
	else
	begin
      bmp := NewBitmap(M.GetWidth, M.GetHeight);
      bmp.Canvas.CopyRect(bmp.Canvas.ClipRect, tmp.Canvas, M.GetRect);
    end;  
    _hi_onEvent(_event_onScreenShort, bmp);
    bmp.free;
  end
  else  
    _hi_onEvent(_event_onScreenShort, tmp);
    
  ReleaseDC(0, DC);
  tmp.free;
end;

procedure THiMonitors._var_Count;
begin
  dtInteger(_Data, FMonitors.Count);
end;

procedure THiMonitors._work_doWorkArea;
begin
    _prop_WorkArea := Readbool(_Data);  
end;

end.