unit hiWinFTP;

interface

uses Kol,Share,Debug,WinInet,Windows;

type
  THIWinFTP = class(TDebug)
   private
    hNet, hFTP: HINTERNET;
    FindData: TWin32FindData;
    CurrentDirectory: string;    
   public
    _prop_Host:string;
    _prop_Username:string;
    _prop_Password:string;
    _prop_Port:integer;
    _prop_Directory:string;
    _prop_RemoteName:string;
    _prop_TimeFormat:string;

    _data_LocalName:THI_Event;
    _data_RemoteName:THI_Event;
    _data_NewRemoteName:THI_Event;
    _data_Host:THI_Event;
    _data_Username:THI_Event;
    _data_Password:THI_Event;
    _data_Mask:THI_Event;

    _event_onWriteProgress:THI_Event;
    _event_onReadProgress:THI_Event;
    _event_onError:THI_Event;
    _event_onConnect:THI_Event;
    _event_onRead:THI_Event;
    _event_onWrite:THI_Event;
    _event_onFindFile:THI_Event;
    _event_onEndFind:THI_Event;
    _event_onGetCurrentDirectory:THI_Event;

    procedure _work_doOpen(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _work_doReadFile(var _Data:TData; Index:word);
    procedure _work_doWriteFile(var _Data:TData; Index:word);
    procedure _work_doDirectory(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);
    procedure _work_doFindFile(var _Data:TData; Index:word);
    procedure _work_doCreateDirectory(var _Data:TData; Index:word);
    procedure _work_doRemoveDirectory(var _Data:TData; Index:word);
    procedure _work_doRename(var _Data:TData; Index:word);    
    procedure _work_doGetCurrentDirectory(var _Data:TData; Index:word);    

    procedure _var_FoundIsDirectory(var _Data:TData; Index:word);
    procedure _var_FoundFileName(var _Data:TData; Index:word);
    procedure _var_FoundFileSize(var _Data:TData; Index:word);
    procedure _var_FoundDateCreate(var _Data:TData; Index:word);
    procedure _var_FoundDateLastWrite(var _Data:TData; Index:word);
    procedure _var_CurrentDirectory(var _Data:TData; Index:word);
  end;

implementation

uses HiTime;

procedure THIWinFTP._work_doOpen;
begin
   hNet := InternetOpen('HiAsm WinFTP',INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
   if hNet = nil then
    begin
     _hi_CreateEvent(_Data,@_event_onError,1);
     Exit;
    end;
   hFTP := InternetConnect(hNet,
      PChar(ReadString(_Data,_data_Host,_prop_Host)),_prop_Port,
      PChar(ReadString(_Data,_data_UserName,_prop_UserName)),
      PChar(ReadString(_Data,_data_Password,_prop_Password)),INTERNET_SERVICE_FTP,INTERNET_FLAG_PASSIVE,0);
   if hFTP = nil then
    begin
     InternetCloseHandle(hNet);
     _hi_CreateEvent(_Data,@_event_onError,2);
     Exit;
    end;
   if not FtpSetCurrentDirectory(hFTP, PChar(_prop_Directory)) then
     _hi_onEvent(_event_onError,3)
   else _hi_CreateEvent(_Data,@_event_onConnect);
end;

procedure THIWinFTP._work_doClose;
begin
   InternetCloseHandle(hFTP);
   InternetCloseHandle(hNet);
end;

const
  READ_BUFFERSIZE = 4096;

procedure THIWinFTP._work_doReadFile;
var
//  sRec: TWin32FindData;
  hFile: HINTERNET;
  fn: string;
  st: PStream;
  buffer: array[0..READ_BUFFERSIZE - 1] of Char;
//  fileSize,
  bufsize: DWORD;
begin
  _Data := ReadData(_Data,_data_LocalName,nil);
  fn := ReadString(_data,_data_RemoteName,_prop_RemoteName);
{
  hFile := FtpFindFirstFile(hFTP, PChar(fn), sRec, 0, 0);
  if  hFile <> nil then
  begin
    fileSize := sRec.nFileSizeLow;
    InternetCloseHandle(hFile);
  end
  else
  begin
    _hi_CreateEvent(_Data,@_event_onError,4);
    Exit;
  end;
}
  hFile := FtpOpenFile(hFTP,PChar(fn),GENERIC_READ,FTP_TRANSFER_TYPE_BINARY, 0);
  if hFile = nil then
  begin
    _hi_CreateEvent(_Data,@_event_onError,5);
    Exit;
  end;

  if _IsStream(_data) then
    st := ToStream(_Data)
  else
    st := NewWriteFileStream(ToString(_Data));

  bufsize := READ_BUFFERSIZE;

  while (bufsize > 0) do
  begin
    if not InternetReadFile(hFile, @buffer,READ_BUFFERSIZE,bufsize) then Break;
    if (bufsize > 0) and (bufsize <= READ_BUFFERSIZE) then
      st.Write(buffer, bufsize);
    _hi_OnEvent(_event_onReadProgress,integer(st.position));
  end;
  InternetCloseHandle(hFile);
  if not _IsStream(_data) then
    st.Free;
  _hi_CreateEvent(_Data,@_event_onRead);
end;

procedure THIWinFTP._work_doWriteFile;
var
  hFile:HINTERNET;
  st:PStream;
  fn:string;
  buffer:array[0..READ_BUFFERSIZE - 1] of Char;
  bufsize:DWORD;
  dt:TData;
begin
  dt := ReadData(_Data,_data_LocalName,nil);
  fn := ReadString(_data,_data_RemoteName,_prop_RemoteName);

  hFile := FtpOpenFile(hFTP,PChar(fn),GENERIC_WRITE,FTP_TRANSFER_TYPE_BINARY, 0);
  if hFile = nil then
   begin
    _hi_CreateEvent(_Data,@_event_onError,5);
    Exit;
   end;

  if _IsStream(dt) then
    st := ToStream(dt)
  else st := NewReadFileStream(ToString(dt));

  while st.Position < st.Size do
   begin
    bufsize := READ_BUFFERSIZE;
    bufsize := st.Read(buffer, bufsize);
    if not InternetWriteFile(hFile, @buffer,bufsize,bufsize) then Break;
    _hi_OnEvent(_event_onWriteProgress,integer(st.position));
   end;
  InternetCloseHandle(hFile);
  if not _IsStream(dt) then
    st.Free;
  _hi_CreateEvent(_Data,@_event_onWrite);
end;

procedure THIWinFTP._work_doDirectory;
begin
  _prop_Directory := ToString(_Data);
  if not FtpSetCurrentDirectory(hFTP, PChar(_prop_Directory)) then
    _hi_onEvent(_event_onError,3);
end;

procedure THIWinFTP._work_doDelete;
begin
  if not FtpDeleteFile(hFTP, PChar(ReadString(_data,_data_RemoteName,_prop_RemoteName))) then
    _hi_onEvent(_event_onError,4);
end;

procedure THIWinFTP._work_doRename;
var
  name, newname: string;
begin
  name := ReadString(_data,_data_RemoteName,_prop_RemoteName);
  newname := ReadString(_data,_data_NewRemoteName,name); 
  if not FtpRenameFile(hFTP, PChar(name), PChar(newname)) then
    _hi_onEvent(_event_onError,9);
end;

procedure THIWinFTP._work_doFindFile;
var hFind:HINTERNET;
begin
  hFind := FtpFindFirstFile(hFTP,PChar(ReadString(_Data,_data_Mask,'*.*')),FindData,INTERNET_FLAG_RELOAD,0);
  if hFind<>nil then begin
    _hi_onEvent(_event_onFindFile,FindData.cFileName);
    while InternetFindNextFile(hFind,@FindData) do
      _hi_onEvent(_event_onFindFile,FindData.cFileName);
    InternetCloseHandle(hFind);
  end;
  _hi_CreateEvent(_Data,@_event_onEndFind);
end;

procedure THIWinFTP._work_doCreateDirectory;
begin
  if not FtpCreateDirectory(hFTP, PChar(ToString(_Data))) then
    _hi_onEvent(_event_onError,6);
end;

procedure THIWinFTP._work_doRemoveDirectory;
begin
  if not FtpRemoveDirectory(hFTP, PChar(ToString(_Data))) then
    _hi_onEvent(_event_onError,7);
end;

procedure THIWinFTP._work_doGetCurrentDirectory;
var
  len: Cardinal;
begin
  len := MAX_PATH; 
  CurrentDirectory := '';
  SetLength(CurrentDirectory, len);
  if not FtpGetCurrentDirectory(hFTP, @CurrentDirectory[1], len) then
  begin
    _hi_onEvent(_event_onError,8);
    exit;
  end;  
  SetLength(CurrentDirectory, len);
  _hi_onEvent(_event_onGetCurrentDirectory,CurrentDirectory);
end;

procedure THIWinFTP._var_FoundIsDirectory;
begin
  dtInteger(_Data, integer((FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY)<>0));
end;

procedure THIWinFTP._var_FoundFileName;
begin
  dtString(_Data, FindData.cFileName);
end;

procedure THIWinFTP._var_FoundDateCreate(var _Data:TData; Index:word);
var
  m: TFileTime;
  sys:TSystemTime;
begin
  FileTimeToLocalFileTime(FindData.ftCreationTime, m);
  FileTimeToSystemTime(m,sys);
  dtString(_Data,TimeToStr(_prop_TimeFormat, sys));
end;

procedure THIWinFTP._var_FoundDateLastWrite(var _Data:TData; Index:word);
var
  m: TFileTime;
  sys:TSystemTime;
begin
  FileTimeToLocalFileTime(FindData.ftLastWriteTime, m);
  FileTimeToSystemTime(m,sys);
  dtString(_Data,TimeToStr(_prop_TimeFormat, sys));
end;

procedure THIWinFTP._var_FoundFileSize;
type T=record L,H:integer end;
var FSize:int64;
begin
  T(FSize).L := FindData.nFileSizeLow;
  T(FSize).H := FindData.nFileSizeHigh;
  if (T(FSize).H=0)and(T(FSize).L>=0) then dtInteger(_Data,T(FSize).L)
  else dtReal(_Data,FSize);
end;

procedure THIWinFTP._var_CurrentDirectory;
begin
  dtString(_Data, CurrentDirectory);
end;

end.
