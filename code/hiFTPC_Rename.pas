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

    _data_RemoteName,
    _data_NewRemoteName: THI_Event;

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
    _prop_FTP_Client.onerror(9)
  else
    _hi_onEvent(_event_onRename, newname);      
end;

end.