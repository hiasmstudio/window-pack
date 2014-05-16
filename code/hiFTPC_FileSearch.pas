unit hiFTPC_FileSearch;

interface

uses Kol, Share, Debug, WinInet, Windows, Shellapi, hiFTP_Client;

type
  THIFTPC_FileSearch = class(TDebug)
   private
    Icon: PIcon;
    FStop: boolean;
    FindData: TWin32FindData;    
   public
    _prop_Mask: string;
    _prop_TimeType: byte;
    _prop_Include: byte;    
    _prop_TimeFormat: string;
    _prop_SmallIcon: boolean;    
    _prop_FTP_Client: IFTP_Client;

    _data_Mask: THI_Event;

    _event_onSearch,
    _event_onNotFound,
    _event_onEndSearch: THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doSearch(var _Data: TData; Index: word);
    procedure _work_doStop(var _Data: TData; Index: word);
    procedure _work_doTimeType(var _Data: TData; Index: word);    
    procedure _work_doInclude(var _Data: TData; Index: word);
    procedure _work_doTimeFormat(var _Data: TData; Index: word);    
    procedure _work_doSmallIcon(var _Data: TData; Index: word);
    
    procedure _var_IsDirectory(var _Data: TData; Index: word);
    procedure _var_FileName(var _Data: TData; Index: word);
    procedure _var_FileSize(var _Data: TData; Index: word);
    procedure _var_DateCreate(var _Data: TData; Index: word);
    procedure _var_DateModify(var _Data: TData; Index: word);
    procedure _var_FileIcon(var _Data: TData; Index: word);    
  end;

implementation

uses HiTime;

constructor THIFTPC_FileSearch.Create;
begin
  inherited;
  Icon := NewIcon;
end;

destructor THIFTPC_FileSearch.Destroy;
begin
  Icon.free;
  inherited;
end;

procedure THIFTPC_FileSearch._work_doSearch;
var
  hFTP, hFind: HINTERNET;
begin
  if not Assigned(_prop_FTP_Client) then exit;
  hFTP := _prop_FTP_Client.getftphandle;
  FStop := false;
  hFind := FtpFindFirstFile(hFTP, PChar(ReadString(_Data, _data_Mask, _prop_Mask)), FindData, INTERNET_FLAG_RELOAD, 0);
  if (hFind <> nil) and not FStop then
  begin
    repeat
      if (_prop_Include = 0) and ((FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0) then
        _hi_onEvent(_event_onSearch, FindData.cFileName)
      else if (_prop_Include = 1) and ((FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0) then
        _hi_onEvent(_event_onSearch, FindData.cFileName)
      else if (_prop_Include = 2) then             
        _hi_onEvent(_event_onSearch, FindData.cFileName);  
    until FStop or not InternetFindNextFile(hFind, @FindData); 
    InternetCloseHandle(hFind);
  end
  else if (hFind = nil) and not FStop then
    _hi_onEvent(_event_onNotFound);  
  _hi_onEvent(_event_onEndSearch);
end;

procedure THIFTPC_FileSearch._work_doStop;
begin
  FStop := true;
end;

procedure THIFTPC_FileSearch._work_doTimeType;    
begin
  _prop_TimeType := ToInteger(_Data);
end;

procedure THIFTPC_FileSearch._work_doInclude;
begin
  _prop_Include := ToInteger(_Data);
end;

procedure THIFTPC_FileSearch._work_doTimeFormat;  
begin
  _prop_TimeFormat := ToString(_Data);
end;

procedure THIFTPC_FileSearch._work_doSmallIcon;
begin
  _prop_SmallIcon := ReadBool(_Data);
end;

procedure THIFTPC_FileSearch._var_IsDirectory;
begin
  dtInteger(_Data, integer((FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0));
end;

procedure THIFTPC_FileSearch._var_FileName;
begin
  dtString(_Data, FindData.cFileName);
end;

procedure THIFTPC_FileSearch._var_DateCreate;
var
  m: TFileTime;
  sys: TSystemTime;
begin
  if _prop_TimeType = 1 then
     FileTimeToLocalFileTime(FindData.ftCreationTime, m)
  else
     m := FindData.ftCreationTime;
  FileTimeToSystemTime(m, sys);
  dtString(_Data, TimeToStr(_prop_TimeFormat, sys));
end;

procedure THIFTPC_FileSearch._var_DateModify;
var
  m: TFileTime;
  sys: TSystemTime;
begin
  if _prop_TimeType = 1 then
     FileTimeToLocalFileTime(FindData.ftLastWriteTime, m)
  else
     m := FindData.ftLastWriteTime;
  FileTimeToSystemTime(m, sys);
  dtString(_Data, TimeToStr(_prop_TimeFormat, sys));
end;

procedure THIFTPC_FileSearch._var_FileSize;
type
  T = record
    L, H: integer
  end;
var
  FSize: int64;
begin
  T(FSize).L := FindData.nFileSizeLow;
  T(FSize).H := FindData.nFileSizeHigh;
  if (T(FSize).H = 0) and (T(FSize).L >= 0) then
    dtInteger(_Data, T(FSize).L)
  else
    dtReal(_Data, FSize);
end;

procedure THIFTPC_FileSearch._var_FileIcon;
var
  SFI: TShFileInfo;
  _fileattribute, _flags: dword;
begin
   Icon.Clear;
   _flags := SHGFI_ICON or SHGFI_USEFILEATTRIBUTES;
   if _prop_SmallIcon then _flags := _flags or SHGFI_SMALLICON; 
   if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
     _fileattribute := FILE_ATTRIBUTE_DIRECTORY
   else
     _fileattribute := FILE_ATTRIBUTE_NORMAL;     
   ShGetFileInfo(FindData.cFileName, _fileattribute, SFI, SizeOf(SFI), _flags);
   Icon.handle:= SFI.hIcon; 
   if Icon.Handle <> 0 then
     dtIcon(_Data, Icon)
   else
     dtNull(_Data); 
end; 

end.