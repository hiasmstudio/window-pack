unit hiFTPC_DeleteFile;

interface

uses Kol, Share, Debug, WinInet, Windows, hiFTP_Client;

type
  THIFTPC_DeleteFile = class(TDebug)
   private
   public
    _prop_RemoteName: string;
    _prop_FTP_Client: IFTP_Client;
    _prop_ErrorEvent: byte;     

    _data_RemoteName: THI_Event;

    _event_onError,
    _event_onDeleteFile: THI_Event;

    procedure _work_doDeleteFile(var _Data: TData; Index: word);
  end;

implementation

procedure THIFTPC_DeleteFile._work_doDeleteFile;
var
  hFTP: HINTERNET;
  name: string;
begin
  if not Assigned(_prop_FTP_Client) then exit;
  hFTP := _prop_FTP_Client.getftphandle;
  name := ReadString(_Data,_data_RemoteName,_prop_RemoteName); 
  if not FtpDeleteFile(hFTP, PChar(name)) then
  begin
    if (_prop_ErrorEvent = 0) or (_prop_ErrorEvent = 2) then _prop_FTP_Client.onerror(12);
    if (_prop_ErrorEvent = 1) or (_prop_ErrorEvent = 2) then _hi_CreateEvent(_Data, @_event_onError, 12);
  end  
  else
    _hi_CreateEvent(_Data, @_event_onDeleteFile, name);      
end;

end.