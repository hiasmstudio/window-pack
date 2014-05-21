unit hiFTP_Client;

interface

uses Kol, Share, Debug, WinInet, Windows;

type
  TIFTP_Client = record
    getftphandle:  function: HINTERNET of object;
    onerror:       procedure(error: integer) of object;           
  end;
  IFTP_Client = ^TIFTP_Client;

type
  THIFTP_Client = class(TDebug)
   private
    ftpc: TIFTP_Client;
    hNet, hFTP: HINTERNET;
    function getftphandle: HINTERNET;
    procedure onerror(error: integer);
    procedure CloseHandle;  
   public
    _prop_Name,
    _prop_Host,
    _prop_Username,
    _prop_Password: string;
    _prop_Port: integer;
    _prop_ErrorEvent: byte;

    _data_Host,
    _data_Port,
    _data_Username,
    _data_Password: THI_Event;

    _event_onGlobalError,
    _event_onError,
    _event_onConnect,
    _event_onDisconnect: THI_Event;
    
    destructor Destroy; override;
    procedure _work_doOpen(var _Data: TData; Index: word);
    procedure _work_doClose(var _Data: TData; Index: word);

    function getinterfaceFTP_Client: IFTP_Client ;    
  end;

implementation

function THIFTP_Client.getinterfaceFTP_Client: IFTP_Client; 
begin
  ftpc.getftphandle  := getftphandle;
  ftpc.onerror       := onerror;
  Result := @ftpc; 
end;

function THIFTP_Client.getftphandle: HINTERNET;
begin
  Result := hFTP;
end;

procedure THIFTP_Client.onerror;  
begin
  _hi_onEvent(_event_onGlobalError, error);
end;

procedure THIFTP_Client.CloseHandle;
begin
  if hFTP <> nil then InternetCloseHandle(hFTP);
  if hNet <> nil then InternetCloseHandle(hNet);
end;

destructor THIFTP_Client.Destroy;
begin
  CloseHandle;
  inherited;
end;

procedure THIFTP_Client._work_doOpen;
begin
  CloseHandle;
  hNet := InternetOpen('HiAsm FTP_Client', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if hNet = nil then
  begin
    if (_prop_ErrorEvent = 0) or (_prop_ErrorEvent = 2) then onerror(1);
    if (_prop_ErrorEvent = 1) or (_prop_ErrorEvent = 2) then _hi_onEvent(_event_onError, 1); 
    exit;
  end;
  hFTP := InternetConnect(hNet,
          PChar(ReadString(_Data, _data_Host, _prop_Host)),
          ReadInteger(_Data, _data_Port, _prop_Port),
          PChar(ReadString(_Data, _data_UserName, _prop_UserName)),
          PChar(ReadString(_Data, _data_Password, _prop_Password)),
          INTERNET_SERVICE_FTP,
          INTERNET_FLAG_PASSIVE,
          0);
  if hFTP = nil then
  begin
    InternetCloseHandle(hNet);
    if (_prop_ErrorEvent = 0) or (_prop_ErrorEvent = 2) then onerror(2);
    if (_prop_ErrorEvent = 1) or (_prop_ErrorEvent = 2) then _hi_onEvent(_event_onError, 2);     
  end
  else
    _hi_onEvent(_event_onConnect);
end;

procedure THIFTP_Client._work_doClose;
begin
  CloseHandle;
  _hi_onEvent(_event_onDisconnect);
end;

end.