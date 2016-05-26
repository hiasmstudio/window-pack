unit hiTrayIcon;

interface

uses Kol,Share,Windows,ShellAPI,Messages,Debug;

type
  THITrayIcon = class(TDebug)
   private
    ParentForm:PControl;
    FTrayData:TNotifyIconData;
    FInst:boolean;  
    OldMessage:TOnMessage;
    FHint:string;
    P:TPoint;
    Procedure AddTrayIcon(_hide:boolean = true);
    procedure RemoveTrayIcon(_hide:boolean = true);
    function OnMessage( var Msg: TMsg; var Rslt: Integer ): Boolean;
    procedure SetHint(const Value:string);
   public
    _prop_FormHook:boolean;
    _prop_MinimizeInTray:byte;    
    _prop_ShowWORemoveIcon:boolean;
    
    _prop_Text:string;
    _prop_Title:string;
    _prop_Icon:byte;

    _data_Text:THI_Event;
    _data_Title:THI_Event;
    _data_Icon:THI_Event;

    _event_onDblClick:THI_Event;
    _event_onHide:THI_Event;
    _event_onClick:THI_Event;
    _event_onMouseDown:THI_Event;
    _event_onMouseMove:THI_Event;
    _event_onMouseUp:THI_Event;
    _event_onBallonShow:THI_Event;
    _event_onBallonTimeOut:THI_Event;        
    _event_onBallonUserClick:THI_Event;
    _event_onAutoRecreate:THI_Event;
    
    constructor Create(Parent:PControl);
    destructor Destroy; override;
    procedure _work_doShow(var _Data:TData; Index:word);
    procedure _work_doHide(var _Data:TData; Index:word);
    procedure _work_doHint(var _Data:TData; Index:word);
    procedure _work_doIcon(var _Data:TData; Index:word);
    procedure _work_doAddTrayIcon(var _Data:TData; Index:word);
    procedure _work_doDeleteTrayIcon(var _Data:TData; Index:word);
    procedure _work_doShowBallonTip(var _Data:TData; Index:word);
    procedure _work_doFormHook(var _Data:TData; Index:word);    
    procedure _var_MouseX(var _Data:TData; Index:word);
    procedure _var_MouseY(var _Data:TData; Index:word);
    property _prop_Hint:string write SetHint;
  end;

implementation

const
  TrayID = 1;
  CM_TRAYICON = WM_USER + 1;
  NIN_BALLOONSHOW = WM_USER + 2;
  NIN_BALLOONHIDE = WM_USER + 3;
  NIN_BALLOONTIMEOUT = WM_USER + 4;
  NIN_BALLOONUSERCLICK = WM_USER + 5;
  
type 
  NotifyIconData_50 = record // определённая в shellapi.h 
    cbSize: DWORD; 
    Wnd: HWND; 
    uID: UINT; 
    uFlags: UINT; 
    uCallbackMessage: UINT; 
    hIcon: HICON; 
    szTip: array[0..MAXCHAR] of AnsiChar; 
    dwState: DWORD; 
    dwStateMask: DWORD; 
    szInfo: array[0..MAXBYTE] of AnsiChar; 
    uTimeout: UINT; // union with uVersion: UINT; 
    szInfoTitle: array[0..63] of AnsiChar; 
    dwInfoFlags: DWORD; 
  end{record}; 
  
  TBalloonTimeout = 10..30{seconds}; 
  TBalloonIconType = (bitNone,    // нет иконки 
                      bitInfo,    // информационная иконка (синяя) 
                      bitWarning, // иконка восклицания (жёлтая) 
                      bitError);  // иконка ошибки (краснаа)
                      
const 
  NIF_INFO      =        $00000010; 

  NIIF_NONE     =        $00000000; 
  NIIF_INFO     =        $00000001; 
  NIIF_WARNING  =        $00000002; 
  NIIF_ERROR    =        $00000003;
  
var
  fRecreateMsg: DWORD;
   
const
  TaskbarCreatedMsg: array[ 0..14 ] of Char = ('T','a','s','k','b','a','r',
                     'C','r','e','a','t','e','d',#0);

constructor THITrayIcon.Create;
begin
   inherited Create;
   ParentForm := Parent;
   OldMessage := ParentForm.OnMessage;
   ParentForm.OnMessage := OnMessage;
   fRecreateMsg := RegisterWindowMessage( TaskbarCreatedMsg );
end;

destructor THITrayIcon.Destroy;
begin
    //RemoveTrayIcon;
	    inherited;
end;

procedure THITrayIcon.SetHint;
begin
  FHint := Value;
  // if FInst then
  //  begin
  //    RemoveTrayIcon;
  //    AddTrayIcon;
  //  end;
end;

function THITrayIcon.OnMessage;
begin
  Result := false;
  if Msg.message = fRecreateMsg then
    if FInst then
    begin
      FInst := false;
      AddTrayIcon(false);
      _hi_onEvent(_event_onAutoRecreate);
    end;
  Case Msg.message Of
    WM_SYSCOMMAND:
    begin
      Case Msg.wParam Of
        SC_RESTORE : RemoveTrayIcon;
        SC_MINIMIZE:
          if (_prop_FormHook and (Msg.lParam = -1)) or (_prop_MinimizeInTray = 0) then 
          begin
            AddTrayIcon;
            Result := true;
          end;
      end;
    end;  
    WM_DESTROY:
     Begin
      RemoveTrayIcon;
      ParentForm.OnMessage := OldMessage; //???
     End;
    WM_CLOSE:
     if _prop_FormHook and (Msg.lParam=0) then
      begin
        SendMessage(ParentForm.Handle,WM_SYSCOMMAND,SC_MINIMIZE, -1);
        Rslt := 0;
        Result := true;
      end;
    WM_SETICON:
     begin
		        FTrayData.hIcon := ParentForm.Icon;
        Shell_NotifyIcon(NIM_MODIFY,@FTrayData);
     end;  
    CM_TRAYICON: 
      Case Msg.lParam Of
        WM_LBUTTONDBLCLK: _hi_OnEvent(_event_onDblClick,0);   //SendMessage(ParentForm.Handle,WM_SYSCOMMAND,SC_RESTORE,0);
        WM_RBUTTONDBLCLK: _hi_OnEvent(_event_onDblClick,1);
        WM_MBUTTONDBLCLK: _hi_OnEvent(_event_onDblClick,2);
        WM_LBUTTONUP: begin
           _hi_OnEvent(_event_onMouseUp,0);
           _hi_OnEvent(_event_onClick,0);
        end;
        WM_RBUTTONUP: begin
           _hi_OnEvent(_event_onClick,1);
           _hi_OnEvent(_event_onMouseUp,1);
        end;
        WM_MBUTTONUP: begin
           _hi_OnEvent(_event_onClick,2);
           _hi_OnEvent(_event_onMouseUp,2);
        end;

        WM_LBUTTONDOWN:        _hi_OnEvent(_event_onMouseDown,0);
        WM_RBUTTONDOWN:        _hi_OnEvent(_event_onMouseDown,1);
        WM_MBUTTONDOWN:        _hi_OnEvent(_event_onMouseDown,2);
        WM_MOUSEMOVE:          _hi_OnEvent(_event_onMouseMove);
        NIN_BALLOONSHOW:       _hi_OnEvent(_event_onBallonShow);
        NIN_BALLOONTIMEOUT:    _hi_OnEvent(_event_onBallonTimeOut);
        NIN_BALLOONUSERCLICK:  _hi_OnEvent(_event_onBallonUserClick);
      End;
  End;
  Result := Result or _hi_OnMessage(OldMessage,Msg,Rslt);
end;

procedure THITrayIcon._work_doShow;
begin
   RemoveTrayIcon(not _prop_ShowWORemoveIcon);
end;

procedure THITrayIcon._work_doHide;
//var IconData:TNotifyIconData;
begin
   {
   IconData.cbSize := SIZEOF(IconData);
   IconData.Wnd := ParentForm.Handle;
   IconData.uFlags := NIF_INFO;

   StrLCopy(FTrayData.szTip,PChar(ToString(_Data)),SizeOf(FTrayData.szTip)-1);
   IconData.uTimeout := 15000; // in milliseconds
   Shell_NotifyIcon(NIM_MODIFY,IconData);
   }
   AddTrayIcon;
end;

procedure THITrayIcon._work_doAddTrayIcon;
begin
   AddTrayIcon(false);
end;

procedure THITrayIcon._work_doDeleteTrayIcon;
begin
   Shell_NotifyIcon(NIM_DELETE,@FTrayData);
   FInst := false;
end;

Procedure THITrayIcon.AddTrayIcon;
Begin
  if _hide then 
    begin
        ShowWindow(ParentForm.Handle,SW_HIDE);
        if ParentForm.Parent <> nil then
           ShowWindow(ParentForm.Parent.Handle,SW_HIDE);
        _hi_onEvent(_event_onHide);
    end;
  if FInst = false then 
    begin
        FTrayData.cbSize := SizeOf(FTrayData);
        FTrayData.Wnd := ParentForm.Handle;
        FTrayData.uID := TrayID;
        FTrayData.uFlags := NIF_ICON Or NIF_MESSAGE Or NIF_TIP;
        FTrayData.uCallBackMessage := CM_TRAYICON;
        FTrayData.hIcon := ParentForm.Icon;
        StrLCopy(FTrayData.szTip,PChar(FHint),SizeOf(FTrayData.szTip)-1);
        Shell_NotifyIcon(NIM_ADD,@FTrayData);
        FInst := true;
    end;
End;

procedure THITrayIcon.RemoveTrayIcon;
begin
   if FInst then
    begin
      if _hide then
        begin
            Shell_NotifyIcon(NIM_DELETE,@FTrayData);
            FInst := false;
        end;
      if ParentForm.Parent <> nil then
        ShowWindow(ParentForm.Parent.Handle,SW_SHOW);
      ShowWindow(ParentForm.Handle,SW_SHOW);
      SetForegroundWindow( ParentForm.Handle );
    end;
end;

procedure THITrayIcon._work_doHint;
begin
  FHint := ToString(_data);
  StrLCopy(FTrayData.szTip,PChar(FHint),SizeOf(FTrayData.szTip)-1);
  Shell_NotifyIcon(NIM_MODIFY,@FTrayData);
end;

procedure THITrayIcon._work_doIcon;
begin
  if _IsIcon(_data) then
    FTrayData.hIcon := ToIcon(_data).handle
  else FTrayData.hIcon := ParentForm.Icon;
  Shell_NotifyIcon(NIM_MODIFY,@FTrayData);
end;

procedure THITrayIcon._work_doShowBallonTip;
const 
  aBalloonIconTypes : array[0..3] of Byte = (NIIF_NONE, NIIF_INFO, NIIF_WARNING, NIIF_ERROR); 
var 
  NID_50 : NotifyIconData_50; 
begin 
  FillChar(NID_50, SizeOf(NotifyIconData_50), 0); 
  with NID_50 do 
   begin 
     cbSize := SizeOf(NotifyIconData_50); 
     Wnd := ParentForm.Handle; 
     uID := 1; 
     uFlags := NIF_INFO; 
     StrPCopy(szInfo, PChar(ReadString(_Data,_data_Text,_prop_Text)));
     uTimeout := 1000; 
     StrPCopy(szInfoTitle, PChar(ReadString(_Data,_data_Title,_prop_Title)));
     dwInfoFlags := aBalloonIconTypes[ReadInteger(_Data,_data_Icon,_prop_Icon)];
   end; 
  Shell_NotifyIcon(NIM_MODIFY, @NID_50); 
end;

procedure THITrayIcon._var_MouseX;
begin
   GetCursorPos(P);
   dtInteger(_Data, P.X);
end;

procedure THITrayIcon._var_MouseY;
begin
   GetCursorPos(P);
   dtInteger(_Data, P.Y);
end;

procedure THITrayIcon._work_doFormHook;
begin
  _prop_FormHook := ReadBool(_Data);
end;

end.