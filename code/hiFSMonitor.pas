unit hiFSMonitor;

interface

uses Windows,Messages,Kol,Share,Debug;

type
  THIFSMonitor = class(TDebug)
   private
    utilclass:TWndClass;
    ToolWnd:HWND;
   public
    _event_onDeviceRemoveComplete:THI_Event;
    _event_onDeviceArrival:THI_Event;
    _event_onError: THI_Event;
    _prop_Drive: String;
    _data_Drive: THI_Event;
        
    constructor Create;
    destructor Destroy; override;
    procedure DevChange(wparam:WPARAM;lparam:LPARAM);
    procedure _work_doDeviceRemove(var _Data:TData; Index:word);
  end;

implementation

const

 IOCTL_STORAGE_MEDIA_REMOVAL = 2967556;
 IOCTL_STORAGE_EJECT_MEDIA = 2967560;

 FSCTL_LOCK_VOLUME = 589848; 
 FSCTL_DISMOUNT_VOLUME = 589856;
  
type
 PDevBroadcastHdr = ^DEV_BROADCAST_HDR;
 DEV_BROADCAST_HDR  = record
  dbch_size:DWORD;
  dbch_devicetype:DWORD;
  dbch_reserved:DWORD;
 end;
 DEV_BROADCAST_VOLUME  = record
  dbcv_size:DWORD;
  dbcv_devicetype:DWORD;
  dbcv_reserved:DWORD;
  dbcv_unitmask:DWORD;
  dbcv_flags:DWORD;
 end;
 PREVENT_MEDIA_REMOVAL = record
   PreventMediaRemoval: Boolean;
 end;
 
 function OpenVolume(DriveLetter: Char): THandle;
var
  szRoot:   PChar;
  szVolume: PChar;
  dwAccess: DWORD;
begin

  szRoot := PChar(DriveLetter+':\'); 

  case GetDriveType(szRoot) of
    DRIVE_REMOVABLE: dwAccess := GENERIC_READ or GENERIC_WRITE;
    DRIVE_CDROM:     dwAccess := GENERIC_READ;
    DRIVE_FIXED:     dwAccess := GENERIC_READ or GENERIC_WRITE;
    else begin Result := INVALID_HANDLE_VALUE; Exit; end;
  end;

  szVolume := PChar('\\.\'+DriveLetter+':'); 
  Result := CreateFile(szVolume, dwAccess, FILE_SHARE_READ or FILE_SHARE_WRITE,
                       nil, OPEN_EXISTING, 0, 0);
end;

function LockVolume(hVolume: THandle): LongBool;
var
  dwRet:   DWORD;
  dwSleep: DWORD;
  I:       Integer;
begin
  Result  := False;
  dwSleep := 100; //LOCK_TIMEOUT div LOCK_RETRY;

  for i := 0 to 10 {LOCK_RETRY } do
  begin
    if DeviceIoControl(hVolume, FSCTL_LOCK_VOLUME, nil, 0, nil, 0, dwRet, nil) then
    begin
      Result := True;
      Exit;
    end;

    Sleep(dwSleep);
  end;
end;        

function DismountVolume(hVolume: THandle): LongBool;
var
  dwRet: DWORD;
begin
  Result := DeviceIoControl(hVolume, FSCTL_DISMOUNT_VOLUME, nil, 0, 
                            nil, 0, dwRet, nil);
end;    

function AutoEjectMedia(hVolume: THandle): LongBool;
var
  dwRet: DWORD;
begin
  Result := DeviceIoControl(hVolume, IOCTL_STORAGE_EJECT_MEDIA, nil, 0, 
                            nil, 0, dwRet, nil);
end;

function PreventVolumeRemoval(hVolume: THandle; Prevent: Boolean): LongBool;
var
  dwRet: DWORD;
  PRM:   PREVENT_MEDIA_REMOVAL;
begin
  PRM.PreventMediaRemoval := Prevent;
  Result := DeviceIoControl(hVolume, IOCTL_STORAGE_MEDIA_REMOVAL, @PRM,
                            SizeOf(PREVENT_MEDIA_REMOVAL), nil, 0, dwRet, nil);
end;

function MWnd(window:hwnd;message:dword;wparam:WPARAM;lparam:LPARAM):LRESULT;stdcall;
var s:^string;
begin
   case message of
    WM_DEVICECHANGE: THIFSMonitor(pointer(GetWindowLong(Window,GWL_USERDATA))).DevChange(wparam,lparam);
    else Result := DefWindowProc(window,message,wparam,lparam);
   end;
end;

constructor THIFSMonitor.Create;
begin
   inherited;

   ZeroMemory(@utilclass,sizeof(utilclass));
   utilclass.lpfnWndProc := @MWnd;
   utilclass.lpszClassName := 'FSMonitor';
   utilclass.hInstance := HInstance;
   RegisterClassA(utilclass);
   ToolWnd := CreateWindowEx(WS_EX_TOOLWINDOW,utilclass.lpszclassname,nil,
    WS_POPUP,0,0,0,0,0,0,hinstance,nil);
   SetWindowLong(ToolWnd,GWL_USERDATA,longint(Self));
end;

destructor THIFSMonitor.Destroy;
begin
  DestroyWindow(ToolWnd);
  inherited;
end;

function Drive(mask:cardinal):string;
var i:byte;
begin
   i := 0;
   while DEV_BROADCAST_VOLUME(pointer(mask)^).dbcv_unitmask shr i <> 1 do
      inc(i);
   Result := string(chr(ord('A') + i));
end;

procedure THIFSMonitor.DevChange;

begin
    if WParam = $8000 then
      case DEV_BROADCAST_HDR(pointer(LParam)^).dbch_devicetype of
        2: _hi_OnEvent(_event_onDeviceArrival,Drive(LParam));
      end
    else if WParam = $8004 then
      case DEV_BROADCAST_HDR(pointer(LParam)^).dbch_devicetype of
        2: _hi_OnEvent(_event_onDeviceRemoveComplete,Drive(LParam));
      end;
    //else ListBox1.Items.Add( inttohex( Mes.WParam ,4) );

end;

procedure THIFSMonitor._work_doDeviceRemove;
var
  DriveLetter: String;
  hVol: THandle;
  err: Byte;
begin
  err:=0;
  DriveLetter := ReadString(_Data, _data_Drive, _prop_Drive);
  if (Length(DriveLetter)>0) and (DriveLetter[1] in ['A'..'z']) then // Синтаксис 
   begin
    hVol := OpenVolume(DriveLetter[1]);
    if hVol = INVALID_HANDLE_VALUE then err:=2 else 
     begin 
       if not LockVolume(hVol) then err:=3 
        else if not DismountVolume(hVol) then err:=4
        else if not PreventVolumeRemoval(hVol, false) then err:=5
        else if not AutoEjectMedia(hVol) then err:=6;
       if not CloseHandle(hVol) then err:=7;
     end;
   end 
    else err:=1;
    
  if err=0 then _Hi_OnEvent(_event_onDeviceRemoveComplete, DriveLetter)
           else _Hi_OnEvent(_event_onError, err); 
   
end;


end.
