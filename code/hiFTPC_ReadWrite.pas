unit hiFTPC_ReadWrite;

interface

uses Kol, Share, Debug, WinInet, Windows, hiFTP_Client;

type
  THIFTPC_ReadWrite = class(TDebug)
   private
     FInProgress, FAbort: Boolean;
     procedure RaiseError(var _Data: TData; Code: Integer);
   public
    _prop_Mode: byte;
    _prop_RemoteName: string;
    _prop_FTP_Client: IFTP_Client;
    _prop_ErrorEvent: byte;     

    _data_RemoteName,
    _data_LocalName: THI_Event;

    _event_onError,
    _event_onFileOperation,
    _event_onProgress: THI_Event;

    procedure _work_doFileOperation0(var _Data: TData; Index: word);
    procedure _work_doFileOperation1(var _Data: TData; Index: word);
    procedure _work_doAbort(var _Data: TData; Index: word);
   
  end;

implementation

const
  READ_BUFFERSIZE = 4096;
  
procedure THIFTPC_ReadWrite.RaiseError;
begin
  if (_prop_ErrorEvent = 0) or (_prop_ErrorEvent = 2) then _prop_FTP_Client.onerror(Code);
  if (_prop_ErrorEvent = 1) or (_prop_ErrorEvent = 2) then _hi_CreateEvent(_Data, @_event_onError, Code);
end;

procedure THIFTPC_ReadWrite._work_doFileOperation0;
var
  hFTP, hFile: HINTERNET;
  fn: string;
  st: PStream;
  buffer: array[0..READ_BUFFERSIZE - 1] of Char;
  bufsize: DWORD;
  dt: TData;
  wbufsize: DWORD;  
begin
  if (not Assigned(_prop_FTP_Client)) or (FInProgress) then exit;
  FInProgress := True;
  FAbort := False;
  hFTP := _prop_FTP_Client.getftphandle;
  
  dt := ReadData(_Data, _data_LocalName, nil);
  fn := ReadString(_Data, _data_RemoteName, _prop_RemoteName);

  hFile := FtpOpenFile(hFTP, PChar(fn), GENERIC_READ, FTP_TRANSFER_TYPE_BINARY, 0);
  if hFile = nil then
  begin
    FInProgress := False;
    RaiseError(_Data, 5);
    exit;
  end;

  if _IsStream(dt) then
    st := ToStream(dt)
  else
  begin
    st := NewWriteFileStream(ToString(dt));
    if st.Handle = INVALID_HANDLE_VALUE then
    begin
      FInProgress := False;
      InternetCloseHandle(hFile);
      st.Free;
      RaiseError(_Data, 4);
      exit;
    end;  
  end;

  bufsize := READ_BUFFERSIZE;

  while (bufsize > 0) and (not FAbort) do
  begin
    if not InternetReadFile(hFile, @buffer, READ_BUFFERSIZE, bufsize) then
    begin
      FInProgress := False;
      InternetCloseHandle(hFile);
      if not _IsStream(dt) then st.Free;
      RaiseError(_Data, 6);
      exit;    
    end
    else
    begin
      if (bufsize > 0) and (bufsize <= READ_BUFFERSIZE) then
      begin
        wbufsize := st.Write(buffer, bufsize);
        if wbufsize <> bufsize then
        begin
          FInProgress := False;
          InternetCloseHandle(hFile);
          if not _IsStream(dt) then st.Free;
          RaiseError(_Data, 6);
          exit;    
        end
        else
          _hi_OnEvent(_event_onProgress, integer(st.position));
      end;  
    end;
  end;
  FInProgress := False;
  InternetCloseHandle(hFile);
  if not _IsStream(dt) then st.Free;
  _hi_CreateEvent(_Data, @_event_onFileOperation, fn);
end;

procedure THIFTPC_ReadWrite._work_doFileOperation1;
var
  hFTP, hFile: HINTERNET;
  st: PStream;
  fn: string;
  buffer: array[0..READ_BUFFERSIZE - 1] of Char;
  bufsize: DWORD;
  dt: TData;
begin
  if (not Assigned(_prop_FTP_Client)) or (FInProgress) then exit;
  FInProgress := True;
  FAbort := False;
  hFTP := _prop_FTP_Client.getftphandle;
  
  dt := ReadData(_Data, _data_LocalName, nil);
  fn := ReadString(_data, _data_RemoteName, _prop_RemoteName);

  hFile := FtpOpenFile(hFTP, PChar(fn), GENERIC_WRITE, FTP_TRANSFER_TYPE_BINARY, 0);
  if hFile = nil then
  begin
    FInProgress := False;
    RaiseError(_Data, 5);    
    exit;
  end;

  if _IsStream(dt) then
    st := ToStream(dt)
  else
  begin
    st := NewReadFileStream(ToString(dt));
    if st.Handle = INVALID_HANDLE_VALUE then
    begin
      FInProgress := False;
      InternetCloseHandle(hFile);
      st.Free;
      RaiseError(_Data, 4);
      exit;
    end;  
  end;

  while (st.Position < st.Size) and (not FAbort) do
  begin
    bufsize := READ_BUFFERSIZE;
    bufsize := st.Read(buffer, bufsize);
    if not InternetWriteFile(hFile, @buffer, bufsize, bufsize) then
    begin
      FInProgress := False;
      InternetCloseHandle(hFile);
      if not _IsStream(dt) then st.Free;
      RaiseError(_Data, 7);
      exit;     
    end
    else
      _hi_OnEvent(_event_onProgress, integer(st.position));
  end;
  InternetCloseHandle(hFile);
  if not _IsStream(dt) then st.Free;
  FInProgress := False;
  _hi_CreateEvent(_Data, @_event_onFileOperation, fn);
end;

procedure THIFTPC_ReadWrite._work_doAbort;
begin
  FAbort := True;
end;

end.