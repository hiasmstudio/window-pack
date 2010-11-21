unit hiModemDial;

interface

uses Kol,Share,Windows,Messages,Debug;

const
  raslib = 'rasapi32.dll';
  RAS_MaxEntryName = 256;
  RAS_MaxPhoneNumber = 128;
  RAS_MaxCallbackNumber = 128;
  RAS_MaxAreaCode = 10;
  RAS_MaxDeviceType = 16;
  RAS_MaxDeviceName = 128;
  RAS_MaxPadType = 32;
  RAS_MaxX25Address = 200;
  RAS_MaxFacilities = 200;
  RAS_MaxUserData = 200;
  UNLEN = 256;
  PWLEN = 256;
  DNLEN = 15;

  RASBASE = 600;
  ERROR_BUFFER_TOO_SMALL = RASBASE+3;

  RASDIALEVENT    = 'RasDialEvent';
  WM_RASDIALEVENT = $CCCD;

type
  tagRASENTRYNAMEA = record
    dwSize: DWORD;
    szEntryName: packed array[0..RAS_MaxEntryName] of AnsiChar;
{$IFDEF WINVER_0x500_OR_GREATER}
    dwFlags: DWORD;
    szPhonebookPath: packed array[0..MAX_PATH] of AnsiChar;
{$ENDIF}
  end;
  TRasIPAddr = record
    a, b, c, d: Byte;
  end;
  RASIPADDR = TRasIPAddr;
  PRasEntryName = ^tagRASENTRYNAMEA;
  PRasEntry = ^tagRASENTRYA;
  tagRASENTRYA = record
    dwSize: DWORD;
    dwfOptions: DWORD;
    // Location/phone number.
    dwCountryID: DWORD;
    dwCountryCode: DWORD;
    szAreaCode: packed array[0..RAS_MaxAreaCode] of AnsiChar;
    szLocalPhoneNumber: packed array[0..RAS_MaxPhoneNumber] of AnsiChar;
    dwAlternateOffset: DWORD;
    // PPP/Ip
    ipaddr: RASIPADDR;
    ipaddrDns: RASIPADDR;
    ipaddrDnsAlt: RASIPADDR;
    ipaddrWins: RASIPADDR;
    ipaddrWinsAlt: RASIPADDR;
    // Framing
    dwFrameSize: DWORD;
    dwfNetProtocols: DWORD;
    dwFramingProtocol: DWORD;
    // Scripting
    szScript: packed array[0..MAX_PATH-1] of AnsiChar;
    // AutoDial
    szAutodialDll: packed array[0..MAX_PATH-1] of AnsiChar;
    szAutodialFunc: packed array[0..MAX_PATH-1] of AnsiChar;
    // Device
    szDeviceType: packed array[0..RAS_MaxDeviceType] of AnsiChar;
    szDeviceName: packed array[0..RAS_MaxDeviceName] of AnsiChar;
    // X.25
    szX25PadType: packed array[0..RAS_MaxPadType] of AnsiChar;
    szX25Address: packed array[0..RAS_MaxX25Address] of AnsiChar;
    szX25Facilities: packed array[0..RAS_MaxFacilities] of AnsiChar;
    szX25UserData: packed array[0..RAS_MaxUserData] of AnsiChar;
    dwChannels: DWORD;
    // Reserved
    dwReserved1: DWORD;
    dwReserved2: DWORD;
{$IFDEF WINVER_0x401_OR_GREATER}
    // Multilink
    dwSubEntries: DWORD;
    dwDialMode: DWORD;
    dwDialExtraPercent: DWORD;
    dwDialExtraSampleSeconds: DWORD;
    dwHangUpExtraPercent: DWORD;
    dwHangUpExtraSampleSeconds: DWORD;
    // Idle timeout
    dwIdleDisconnectSeconds: DWORD;
{$ENDIF}
{$IFDEF WINVER_0x500_OR_GREATER}
    dwType: DWORD;
    dwEncryptionType: DWORD;
    dwCustomAuthKey: DWORD;
    guidId: TGUID;
    szCustomDialDll: packed array[0..MAX_PATH-1] of AnsiChar;
    dwVpnStrategy: DWORD;
{$ENDIF}
  end;
  THIModemDial = class(TDebug)
   private
    FConnHandle:cardinal;
    OldMes:TOnMessage;
    FHWND:HWND;
    FNotifyMessage: DWORD;
    Entries:PRasEntryName;
    FPBK:Pchar;
    Arr:PArray;
    FParent:PControl;

    function Read(Var Item:TData; var Val:TData):boolean;
    function Count:integer;

    function GetProperties(var Value: PRasEntry): DWORD;

    function OnMes( var Msg: TMsg; var Rslt: Integer ): Boolean;
    function ReadStat(p1,p2:word):string;
   public
    _prop_AutoClose:boolean; 
     
    _data_Phone:THI_Event;
    _data_Password:THI_Event;
    _data_Name:THI_Event;
    _data_EntryName:THI_Event;
    _event_onStatus:THI_Event;
    _event_onEnum:THI_Event;

    constructor Create(Parent:PControl);
    destructor Destroy; override;
    procedure _work_doEnum(var _Data:TData; Index:word);
    procedure _work_doDial(var _Data:TData; Index:word);
    procedure _work_doHandUp(var _Data:TData; Index:word);
    procedure _var_Params(var _Data:TData; Index:word);
  end;

implementation

type
  tagRASDIALPARAMSA = record
    dwSize: DWORD;
    szEntryName: packed array[0..RAS_MaxEntryName] of AnsiChar;
    szPhoneNumber: packed array[0..RAS_MaxPhoneNumber] of AnsiChar;
    szCallbackNumber: packed array[0..RAS_MaxCallbackNumber] of AnsiChar;
    szUserName: packed array[0..UNLEN] of AnsiChar;
    szPassword: packed array[0..PWLEN] of AnsiChar;
    szDomain: packed array[0..DNLEN] of AnsiChar;
{$IFDEF WINVER_0x401_OR_GREATER}
    dwSubEntry: DWORD;
    dwCallbackId: DWORD;
{$ENDIF}
  end;
  TRasDialParams = tagRASDIALPARAMSA;
  PRasDialParams = ^tagRASDIALPARAMSA;

  tagRASDIALEXTENSIONS = record
    dwSize: DWORD;
    dwfOptions: DWORD;
    hwndParent: HWND;
    reserved: DWORD;
{$IFDEF WINVER_0x500_OR_GREATER}
    reserved1: DWORD;
    RasEapInfo: TRasEapInfo;
{$ENDIF}
  end;
  PRasDialExtensions = ^tagRASDIALEXTENSIONS;
  THRasConn = THandle;

function RasEnumEntries(reserved: PChar; lpszPhonebook: PChar;
  lprasentryname: PRasEntryName; var lpcb: DWORD;
  var lpcEntries: DWORD): DWORD; stdcall; external raslib name 'RasEnumEntriesA';

function RasDial(lpRasDialExtensions: PRasDialExtensions; lpszPhonebook: PChar;
  lpRasDialParams: PRasDialParams; dwNotifierType: DWORD; lpvNotifier: Pointer;
  var lphRasConn: THRasConn): DWORD; stdcall; external raslib name 'RasDialA';

function RasGetEntryDialParams(lpszPhonebook: PChar;
  var lprasdialparams: TRasDialParams; var lpfPassword: BOOL): DWORD; stdcall; external raslib name 'RasGetEntryDialParamsA';

function RasHangUp(hrasconn: THRasConn): DWORD; stdcall; external raslib name 'RasHangUpA';

function RasGetEntryProperties(lpszPhonebook: PAnsiChar; lpszEntry: PAnsiChar;
  lpRasEntry: PRasEntry; var lpdwEntryInfoSize: DWORD;
  lpbDeviceInfo: Pointer; lpdwDeviceInfoSize: PDWORD): DWORD; stdcall; external raslib name 'RasGetEntryPropertiesA';

constructor THIModemDial.Create;
begin
   inherited Create;
   if Parent <> nil then
    begin
     FHWND := Parent.GetWindowHandle;
     OldMes := Parent.OnMessage;
     Parent.OnMessage := OnMes;
    end;
   FParent := Parent; 

   FNotifyMessage := RegisterWindowMessage(RASDIALEVENT);
   if FNotifyMessage = 0 then FNotifyMessage := WM_RASDIALEVENT;
end;

destructor THIModemDial.Destroy;
begin
   if FParent <> nil then FParent.OnMessage := OldMes;
   
   if _prop_AutoClose then
     RasHangUp(FConnHandle);
   inherited;
end; 

function THIModemDial.OnMes;
begin
   case Msg.message of
     WM_CLOSE: if _prop_AutoClose then RasHangUp(FConnHandle);
   end;
   if Msg.message = FNotifyMessage then
     _hi_OnEvent(_event_onStatus,ReadStat(Msg.wParam,Msg.lParam));
   Result := OldMes(Msg,Rslt);
end;

resourcestring
  sRasError = 'RAS Error code: %d.'#10'"%s"';
  sRASCS_OpenPort = 'Port is about to be opened';
  sRASCS_PortOpened = 'Port has been opened';
  sRASCS_ConnectDevice = 'A device is about to be connected';
  sRASCS_DeviceConnected = 'A device has connected successfully';
  sRASCS_AllDevicesConnected = 'All devices in the device chain have successfully connected';
  sRASCS_Authenticate = 'The authentication process is starting';
  sRASCS_AuthNotify = 'An authentication event has occurred';
  sRASCS_AuthRetry = 'The client has requested another validation attempt with a new user name/password/domain';
  sRASCS_AuthCallback = 'The remote access server has requested a callback number';
  sRASCS_AuthChangePassword = 'The client has requested to change the password on the account';
  sRASCS_AuthProject = 'The projection phase is starting';
  sRASCS_AuthLinkSpeed = 'The link-speed calculation phase is starting';
  sRASCS_AuthAck = 'An authentication request is being acknowledged';
  sRASCS_ReAuthenticate = 'Reauthentication (after callback) is starting';
  sRASCS_Authenticated = 'The client has successfully completed authentication';
  sRASCS_PrepareForCallback = 'The line is about to disconnect in preparation for callback';
  sRASCS_WaitForModemReset = 'The client is delaying in order to give the modem time to reset itself in preparation for callback';
  sRASCS_WaitForCallback = 'The client is waiting for an incoming call from the remote access server';
  sRASCS_Projected = 'Projection result information is available';
  sRASCS_StartAuthentication = 'User authentication is being initiated or retried';
  sRASCS_CallbackComplete = 'Client has been called back and is about to resume authentication';
  sRASCS_LogonNetwork = 'Client is logging on to the network';
  sRASCS_SubEntryConnected = 'Subentry has been connected during the dialing process';
  sRASCS_SubEntryDisconnected = 'Subentry has been disconnected during the dialing process';
  sRASCS_Interactive = 'Terminal state supported by RASPHONE.EXE';
  sRASCS_RetryAuthentication = 'Retry authentication state supported by RASPHONE.EXE';
  sRASCS_CallbackSetByCaller = 'Callback state supported by RASPHONE.EXE';
  sRASCS_PasswordExpired = 'Change password state supported by RASPHONE.EXE';
  sRASCS_Connected = 'Connected';
  sRASCS_Disconnected = 'Disconnected';

const
  RASCS_PAUSED = $1000;
  RASCS_DONE   = $2000;

  RASCS_OpenPort = 0;
  RASCS_PortOpened = 1;
  RASCS_ConnectDevice = 2;
  RASCS_DeviceConnected = 3;
  RASCS_AllDevicesConnected = 4;
  RASCS_Authenticate = 5;
  RASCS_AuthNotify = 6;
  RASCS_AuthRetry = 7;
  RASCS_AuthCallback = 8;
  RASCS_AuthChangePassword = 9;
  RASCS_AuthProject = 10;
  RASCS_AuthLinkSpeed = 11;
  RASCS_AuthAck = 12;
  RASCS_ReAuthenticate = 13;
  RASCS_Authenticated = 14;
  RASCS_PrepareForCallback = 15;
  RASCS_WaitForModemReset = 16;
  RASCS_WaitForCallback = 17;
  RASCS_Projected = 18;
  RASCS_StartAuthentication = 19;
  RASCS_CallbackComplete = 20;
  RASCS_LogonNetwork = 21;
  RASCS_SubEntryConnected = 22;
  RASCS_SubEntryDisconnected = 23;
  RASCS_Interactive = RASCS_PAUSED;
  RASCS_RetryAuthentication = RASCS_PAUSED + 1;
  RASCS_CallbackSetByCaller = RASCS_PAUSED + 2;
  RASCS_PasswordExpired = RASCS_PAUSED + 3;
  RASCS_InvokeEapUI = RASCS_PAUSED + 4;
  RASCS_Connected = RASCS_DONE;
  RASCS_Disconnected = RASCS_DONE + 1;

function THIModemDial.ReadStat;
begin
    case p1 of
      RASCS_OpenPort: Result := sRASCS_OpenPort;
      RASCS_PortOpened: Result := sRASCS_PortOpened;
      RASCS_ConnectDevice: Result := sRASCS_ConnectDevice;
      RASCS_DeviceConnected: Result := sRASCS_DeviceConnected;
      RASCS_AllDevicesConnected: Result := sRASCS_AllDevicesConnected;
      RASCS_Authenticate: Result := sRASCS_Authenticate;
      RASCS_AuthNotify: Result := sRASCS_AuthNotify;
      RASCS_AuthRetry: Result := sRASCS_AuthRetry;
      RASCS_AuthCallback: Result := sRASCS_AuthCallback;
      RASCS_AuthChangePassword: Result := sRASCS_AuthChangePassword;
      RASCS_AuthProject: Result := sRASCS_AuthProject;
      RASCS_AuthLinkSpeed: Result := sRASCS_AuthLinkSpeed;
      RASCS_AuthAck: Result := sRASCS_AuthAck;
      RASCS_ReAuthenticate: Result := sRASCS_ReAuthenticate;
      RASCS_Authenticated: Result := sRASCS_Authenticated;
      RASCS_PrepareForCallback: Result := sRASCS_PrepareForCallback;
      RASCS_WaitForModemReset: Result := sRASCS_WaitForModemReset;
      RASCS_WaitForCallback: Result := sRASCS_WaitForCallback;
      RASCS_Projected: Result := sRASCS_Projected;
      RASCS_StartAuthentication: Result := sRASCS_StartAuthentication;
      RASCS_CallbackComplete: Result := sRASCS_CallbackComplete;
      RASCS_LogonNetwork: Result := sRASCS_LogonNetwork;
      RASCS_SubEntryConnected: Result := sRASCS_SubEntryConnected;
      RASCS_SubEntryDisconnected: Result := sRASCS_SubEntryDisconnected;
      RASCS_Interactive: Result := sRASCS_Interactive;
      RASCS_RetryAuthentication: Result := sRASCS_RetryAuthentication;
      RASCS_CallbackSetByCaller: Result := sRASCS_CallbackSetByCaller;
      RASCS_PasswordExpired: Result := sRASCS_PasswordExpired;
      RASCS_Connected: Result := sRASCS_Connected;
      RASCS_Disconnected: Result := sRASCS_Disconnected;
    else
      Result := '';
    end;
end;

procedure THIModemDial._work_doEnum;
var
    BufSize,NumberOfEntries,Res:DWORD;
    i:byte;
    p:pointer;
   procedure InitFirstEntry;
   begin
     ZeroMemory(Entries, BufSize);
     Entries.dwSize := Sizeof(tagRASENTRYNAMEA);
     NumberOfEntries := 0;
   end;
begin
   new(Entries);
   BufSize := sizeof(tagRASENTRYNAMEA);
   InitFirstEntry;
   Res := RasEnumEntries(nil, FPBK, Entries, BufSize, NumberOfEntries);
   if Res = ERROR_BUFFER_TOO_SMALL then
    begin
     ReallocMem(Entries, BufSize);
     InitFirstEntry;
     RasEnumEntries(nil, FPBK, Entries, BufSize, NumberOfEntries);
    end;
   p := Entries;
   for i := 1 to NumberOfEntries do
    begin
       _hi_OnEvent(_event_onEnum,Entries.szEntryName);
       inc(Entries);
    end;
   FreeMem(p);
   Entries := nil;
end;

procedure THIModemDial._work_doDial;
var FParams:TRasDialParams;
    pr:TRasDialParams;
    pass:bool;
    s:string;
begin
   ZeroMemory(@FParams,sizeof(TRasDialParams));
   FParams.dwSize := sizeof(TRasDialParams);
   StrPCopy(FParams.szEntryName,ReadString(_Data,_Data_EntryName,''));

   ZeroMemory(@pr,sizeof(pr));
   pr.dwSize := sizeof(pr);
   StrCopy( pr.szEntryName, FParams.szEntryName );
   RasGetEntryDialParams(FPBK,pr,pass);

   s := ReadString(_Data,_data_Phone,'');
   if s = '' then
     FParams.szPhoneNumber := pr.szPhoneNumber
   else StrPCopy( FParams.szPhoneNumber,s);

   s := ReadString(_Data,_data_Name,'');
   if s = '' then
     FParams.szUserName := pr.szUserName
   else StrPCopy(FParams.szUserName,s);

   s := ReadString(_Data,_data_Password,'');
   if s = '' then
     FParams.szPassword := pr.szPassword
   else StrPCopy(FParams.szPassword,s);
   FConnHandle := 0;
   RasDial(nil, nil, @FParams, $FFFFFFFF, Pointer(FHWND), FConnHandle);
end;

procedure THIModemDial._work_doHandUp;
begin
   RasHangUp(FConnHandle);
end;

function THIModemDial.GetProperties;
var
  Res: DWORD;
begin
  Result := 0;
  Res := RasGetEntryProperties(FPBK, Entries.szEntryName, nil, Result, nil, nil);
  //if Res <> ERROR_BUFFER_TOO_SMALL then RasCheck(Res);
  Value := AllocMem(Result);
  Value^.dwSize := Sizeof(tagRASENTRYA);
  Res := RasGetEntryProperties(FPBK, Entries.szEntryName, Value, Result, nil, nil);
  //if Res <> SUCCESS then
  //  FreeMem(Value);
end;

function THIModemDial.Read;
var pr:TRasDialParams;
    pass:bool;
    ind:integer;
    Prop: PRasEntry;
    s:string;
begin
   if Entries = nil then begin Result := false; exit; end;
   ZeroMemory(@pr,sizeof(pr));
   pr.dwSize := sizeof(pr);
   StrCopy( pr.szEntryName, Entries.szEntryName );
   RasGetEntryDialParams(FPBK,pr,pass);
   ind := ToInteger(Item);

   GetProperties(Prop);
   case ind of
    0: s := pr.szUserName;
    1: s := pr.szPassword;
    2: s := Prop.szLocalPhoneNumber;
    3: s := prop.szAreaCode;
    4: s := prop.szDeviceName;
   end;
   FreeMem(Prop);
   dtString(val,s);
   Result := (ind >= 0)and(ind < 5);
end;

function THIModemDial.Count;
begin
   Result := 3;
end;

procedure THIModemDial._var_Params;
begin
  if Arr = nil then
     Arr := CreateArray(nil,read,count,nil);
  dtArray(_Data,Arr);
end;

end.
