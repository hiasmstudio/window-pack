unit hiFTPC_Rename;

interface

uses Kol, Share, Debug, WinInet, Windows, hiFTP_Client;

type
  THIFTPC_Rename = class(TDebug)
   private
   public
    _prop_RemoteName,
    _prop_NewRemoteName: string;
    _prop_FTP_Client: IFTP_Client;
    _prop_ErrorEvent: byte;    

    _data_RemoteName,
    _data_NewRemoteName: THI_Event;

    _event_onError,
    _event_onRename: THI_Event;

    procedure _work_doRename(var _Data: TData; Index: word);
  end;

implementation

procedure THIFTPC_Rename._work_doRename;
var
  hFTP: HINTERNET;
  name, newname: string;
begin
  if not Assigned(_prop_FTP_Client) then exit;
  hFTP := _prop_FTP_Client.getftphandle;
  name := ReadString(_data,_data_RemoteName,_prop_RemoteName);
  newname := ReadString(_data,_data_NewRemoteName,name); 
  if not FtpRenameFile(hFTP, PChar(name), PChar(newname)) then
  begin
    if (_prop_ErrorEvent = 0) or (_prop_ErrorEvent = 2) then _prop_FTP_Client.onerror(11);
    if (_prop_ErrorEvent = 1) or (_prop_ErrorEvent = 2) then _hi_CreateEvent(_Data, @_event_onError, 11);
  end  
  else
    _hi_CreateEvent(_Data, @_event_onRename, newname);  
end;

end.