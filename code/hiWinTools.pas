unit hiWinTools;

interface

uses Kol,Share,Windows,Messages,Debug;

{$I share.inc}

type
  THIWinTools = class(TDebug)
   private
    procedure SetAttr(h:THandle; CValue:TColor; AValue:byte; Flag:DWORD);
   public
    _data_Text:THI_Event;
    _data_Handle:THI_Event;

    procedure _work_doVisible(var _Data:TData; Index:word);
    procedure _work_doPopup(var _Data:TData; Index:word);
    procedure _work_doBottom(var _Data:TData; Index:word);    
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _work_doQuit(var _Data:TData; Index:word);
    procedure _work_doCaption(var _Data:TData; Index:word);
    procedure _work_doSendMessage(var _Data:TData; Index:word);
    procedure _work_doActive(var _Data:TData; Index:word);
    procedure _work_doForeground(var _Data:TData; Index:word);
    procedure _work_doEnable(var _Data:TData; Index:word);

    procedure _work_doMinimize(var _Data:TData; Index:word);
    procedure _work_doNormal(var _Data:TData; Index:word);
    procedure _work_domaximize(var _Data:TData; Index:word);

    procedure _work_doTransparentColor(var _Data:TData; Index:word);
    procedure _work_doAlphaBlendValue(var _Data:TData; Index:word);
    procedure _work_doRedraw(var _Data:TData; Index:word);

    procedure _var_CaptionText(var _Data:TData; Index:word);
    procedure _var_FileName(var _Data:TData; Index:word);
    procedure _var_isVisible(var _Data:TData; Index:word);
    procedure _var_isEnabled(var _Data:TData; Index:word);
  end;

implementation

//function GetWindowModuleFileName(hwnd: HWND; pszFileName: PAnsiChar; cchFileNameMax: UINT): UINT; stdcall;
//         external user32 name 'GetWindowModuleFileNameA';

procedure THIWinTools._work_doVisible;
var f:Cardinal;
begin
   if ReadBool(_Data) then
     f := SW_SHOW
   else f := SW_HIDE;
   ShowWindow(ReadInteger(_Data,_data_Handle,0),f);
end;

procedure THIWinTools._work_doMinimize;
begin
   //ShowWindow(ReadInteger(_Data,_data_Handle,0),SW_MINIMIZE);
   PostMessage( ReadInteger(_Data,_data_Handle,0), WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

procedure THIWinTools._work_doNormal;
begin
   ShowWindow(ReadInteger(_Data,_data_Handle,0),SW_NORMAL);
end;

procedure THIWinTools._work_domaximize;
begin
   ShowWindow(ReadInteger(_Data,_data_Handle,0),SW_MAXIMIZE);
end;

procedure THIWinTools._work_doTransparentColor;
const LWA_COLORKEY = $00000001;
var h:cardinal;
begin
   h := ReadInteger(_Data,_data_Handle,0);
   SetAttr(h,ToInteger(_Data),0,LWA_COLORKEY);
end;

procedure THIWinTools._work_doAlphaBlendValue;
const LWA_ALPHA=$00000002;
var h:cardinal;
begin
   h := ReadInteger(_Data,_data_Handle,0);
   SetAttr(h,0,ToInteger(_Data),LWA_ALPHA);
end;

procedure THIWinTools.SetAttr;
const
  LWA_ALPHA=$00000002;
  ULW_COLORKEY=$00000001;
  ULW_ALPHA=$00000002;
  ULW_OPAQUE=$00000004;
  WS_EX_LAYERED=$00080000;
type
  TSetLayeredWindowAttributes=
    function( hwnd: Integer; crKey: TColor; bAlpha: Byte; dwFlags: DWORD )
    : Boolean; stdcall;
var
  SetLayeredWindowAttributes: TSetLayeredWindowAttributes;
  User32: THandle;
  dw: DWORD;
begin
  User32 := GetModuleHandle( 'User32' );
  SetLayeredWindowAttributes := GetProcAddress( User32, 'SetLayeredWindowAttributes' );
  if Assigned( SetLayeredWindowAttributes ) then
   begin
    dw := GetWindowLong( h, GWL_EXSTYLE );
    SetWindowLong( h, GWL_EXSTYLE, dw or WS_EX_LAYERED );
    //if Control.AlphaBlend < 255 then
    // inc(dw,LWA_ALPHA);
    SetLayeredWindowAttributes( h, CValue, AValue and $FF, Flag);
   end;
end;

procedure THIWinTools._work_doPopup;
var h:HWND;
begin
   if ReadBool(_Data) then
     h := HWND_TOPMOST
   else h := HWND_NOTOPMOST;
   SetWindowPos(ReadInteger(_Data,_data_Handle,0),h,0,0,0,0,SWP_NOSIZE or SWP_NOMOVE);
end;

procedure THIWinTools._work_doClose;
begin
   PostMessage(ReadInteger(_Data,_data_Handle,0), WM_CLOSE, 0, 0);
end;

procedure THIWinTools._work_doQuit;
begin
   PostMessage(ReadInteger(_Data,_data_Handle,0), WM_QUIT, 0, 0);
end;

procedure THIWinTools._work_doCaption;
begin
   SetWindowText(ReadInteger(_Data,_data_Handle,0),
           PChar(ReadString(_Data,_data_Text,'')));
end;

procedure THIWinTools._work_doSendMessage;
begin
   SendMessage(ReadInteger(_Data,_data_Handle,0), _Data.idata, 0, 0);
end;

procedure THIWinTools._work_doActive;
var aid,mid:cardinal;
begin
  aid := GetWindowThreadProcessId(GetForegroundWindow(),nil);
  mid := GetCurrentThreadId();
  AttachThreadInput(mid, aid, True);
  SetForegroundWindow(ReadInteger(_Data,_data_Handle,0));
  AttachThreadInput(mid, aid, False);
end;

procedure THIWinTools._work_doForeground;
begin
  SetForegroundWindow(ReadInteger(_Data,_data_Handle,0));
end;

procedure THIWinTools._work_doEnable;
var en:boolean;
begin
  en := ReadBool(_Data);
  EnableWindow(ReadInteger(_Data,_data_Handle,0), En);
end;

procedure THIWinTools._var_CaptionText;
var l,h:integer; s:string;
begin
  h := ReadInteger(_Data,_data_Handle,0);
  l := GetWindowTextLength(h);
  SetLength(s,l);
  GetWindowText(h,PChar(s),l+1);
  dtString(_Data,s);
end;

procedure THIWinTools._var_isVisible;
var h:cardinal;
begin
   h := ReadInteger(_Data,_data_Handle,0);
   dtInteger(_Data, integer(isWindowVisible(h)));
end;

procedure THIWinTools._var_isEnabled;
var h:cardinal;
begin
   h := ReadInteger(_Data,_data_Handle,0);
   dtInteger(_Data, integer(isWindowEnabled(h)));
end;

procedure THIWinTools._var_FileName;
type
  TGetModuleFileNameEx = function (hProcess: THandle; hModule: HMODULE;
                         lpFilename: PAnsiChar; nSize: DWORD): DWORD stdcall;
var  s:string;
     hPSAPI:THandle;
     hProc:THandle;
     _GetModuleFileNameEx: TGetModuleFileNameEx;
     lpdwProcessId:DWord;
begin
  hPSAPI := LoadLibrary('PSAPI.dll');
TRY
  if hPSAPI < 32 then exit;
  @_GetModuleFileNameEx := GetProcAddress(hPSAPI, 'GetModuleFileNameExA');
  GetWindowThreadProcessId(ReadInteger(_Data,_data_Handle,0), @lpdwProcessId);
  hProc := OpenProcess( PROCESS_ALL_ACCESS OR PROCESS_QUERY_INFORMATION, false, lpdwProcessId );
  SetLength(s,MAX_PATH);
  SetLength(s,_GetModuleFileNameEx(hProc,0,PChar(s),MAX_PATH));
  dtString(_Data,s);
FINALLY
  FreeLibrary(hPSAPI);
END;
end;

procedure THIWinTools._work_doRedraw;
begin
 InvalidateRect(ReadInteger(_Data,_data_Handle,0),nil,true);
end;

procedure THIWinTools._work_doBottom;
begin
  SetWindowPos(ReadInteger(_Data,_data_Handle,0),HWND_NOTOPMOST,0,0,0,0,SWP_NOSIZE or SWP_NOMOVE);
  SetWindowPos(ReadInteger(_Data,_data_Handle,0),HWND_BOTTOM,0,0,0,0,SWP_NOSIZE or SWP_NOMOVE or SWP_NOOWNERZORDER);
end;

end.