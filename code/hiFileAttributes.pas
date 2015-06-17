
unit hiFileAttributes; {чтение атрибутов файла ver 2.50}

interface

uses
  Windows, Shellapi, Kol, Share, Debug;

type 
  TVerInfo = packed record 
    vMajor, vMinor, vRelease, vBuild: Word;
  end;
  
type
  THIFileAttributes = class(TDebug)
    private
      fFileName: string;
      fSmallIcon: Boolean;
      fOpenIcon: Boolean;    
      fAttrData: WIN32_FILE_ATTRIBUTE_DATA;
      sVersion: TVerInfo;
      
      procedure GetTimeV(var _Data: TData; t: PFileTime; RealDate: Boolean);
      
    public
      _prop_FileName: string;
      _prop_Attr: Integer;
      _prop_Format: string;
      _prop_TimeType: Byte;

      _data_Attr: THI_Event;
      _data_FileName: THI_Event;
      _data_CreateDate: THI_Event;
      _data_ModifyDate: THI_Event;
      _data_AccessDate: THI_Event;
      
      _event_onRead: THI_Event;
      _event_onError: THI_Event;
      _event_onGetFileIcon: THI_Event;
      _event_onGetFileVersion: THI_Event;    

      property _prop_SmallIcon: Boolean write fSmallIcon; 
      property _prop_OpenIcon: Boolean write fOpenIcon;
      
      procedure _work_doRead(var _Data: TData; Index: Word);
      procedure _work_doSet(var _Data: TData; Index: Word);
      procedure _work_doSetDate(var _Data: TData; Index: Word);
      procedure _work_doGetFileIcon(var _Data: TData; Index: Word);
      procedure _work_doGetFileVersion(var _Data: TData; Index: Word);        
      procedure _work_doSmallIcon(var _Data: TData; Index: Word);
      procedure _work_doOpenIcon(var _Data: TData; Index: Word);
      
      procedure _var_DateCreate(var _Data: TData; Index: Word);
      procedure _var_DateAccess(var _Data: TData; Index: Word);
      procedure _var_DateModify(var _Data: TData; Index: Word);
      procedure _var_DateCreateReal(var _Data: TData; Index: Word);
      procedure _var_DateAccessReal(var _Data: TData; Index: Word);
      procedure _var_DateModifyReal(var _Data: TData; Index: Word);
      procedure _var_FileSize(var _Data: TData; Index: Word);
      procedure _var_Major(var _Data: TData; Index: Word);
      procedure _var_Minor(var _Data: TData; Index: Word);
      procedure _var_Release(var _Data: TData; Index: Word);
      procedure _var_Build(var _Data: TData; Index: Word);
  end;

implementation

uses
  HiTime;

function GetFileAttributesEx(lpFileName: PChar; fInfoLevelId: TGetFileExInfoLevels;
         lpFileInformation: Pointer): BOOL; stdcall; external kernel32 name 'GetFileAttributesExA';

const
  At: array[0..8] of DWORD = (
    FILE_ATTRIBUTE_NORMAL,
    FILE_ATTRIBUTE_ARCHIVE,
    FILE_ATTRIBUTE_READONLY,
    FILE_ATTRIBUTE_HIDDEN,
    FILE_ATTRIBUTE_SYSTEM,
    FILE_ATTRIBUTE_DIRECTORY,
    FILE_ATTRIBUTE_TEMPORARY,
    FILE_ATTRIBUTE_COMPRESSED,
    FILE_ATTRIBUTE_OFFLINE{,
    FILE_ATTRIBUTE_ENCRYPTED,
    FILE_ATTRIBUTE_REPARSE_POINT,
    FILE_ATTRIBUTE_SPARSE_FILE,
    FILE_ATTRIBUTE_NOT_CONTENT_INDEXED}
  );

procedure THIFileAttributes._work_doRead;
var 
  i, j: Integer;
begin
  fFileName := ReadString(_Data, _data_FileName, _prop_FileName);
  if not GetFileAttributesEx(PChar(fFileName), GetFileExInfoStandard, @fAttrData) then
  begin
    _hi_CreateEvent(_Data, @_event_onError, Integer(GetLastError));
    fFileName := '';
    Exit;
  end;
  i := 0;
  for j := 0 to high(At) do
    i := i or ((Integer((fAttrData.dwFileAttributes and At[j]) <> 0)) shl j);
  _hi_CreateEvent(_Data, @_event_onRead, i);
end;

procedure THIFileAttributes._work_doSet;
var
  i, j, Attr: DWord;
  fn: string;
begin
  fn := ReadString(_Data, _data_FileName, _prop_FileName);
  i := ReadInteger(_Data, _data_Attr, _prop_Attr);
  Attr := 0;
  
  for j := 0 to High(At) do
   Attr := Attr or ((i shr j) and 1) * At[j];

  if not SetFileAttributes(PChar(fn), Attr) then
    _hi_CreateEvent(_Data, @_event_onError, Integer(GetLastError));
end;

procedure THIFileAttributes._work_doSetDate;
var
  hInfo: TByHandleFileInformation; 
  ST: TSystemTime;
  CreateDate: TDateTime;
  ModifyDate: TDateTime;
  AccessDate: TDateTime;
  hFile: THandle;
  fn: string;
begin
  fn := ReadString(_Data, _data_FileName, _prop_FileName);
  
  hFile := CreateFile(PChar(fn), GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
  CreateDate := ReadReal(_Data, _data_CreateDate);
  ModifyDate := ReadReal(_Data, _data_ModifyDate);
  AccessDate := ReadReal(_Data, _data_AccessDate);
  
  if hFile <> 0 then
  begin
    if CreateDate <> 0 then
    begin
      DateTime2SystemTime(CreateDate, ST);
      SystemTimeToFileTime(ST, hInfo.ftCreationTime); 
      if _prop_TimeType = 1 then
        LocalFileTimeToFileTime(hInfo.ftCreationTime, hInfo.ftCreationTime);
      SetFileTime(hFile, @hInfo.ftCreationTime, nil, nil);
    end;
    
    if ModifyDate <> 0 then
    begin
      DateTime2SystemTime(ModifyDate, ST);
      SystemTimeToFileTime(ST, hInfo.ftLastWriteTime);
      if _prop_TimeType = 1 then
        LocalFileTimeToFileTime(hInfo.ftLastWriteTime,  hInfo.ftLastWriteTime);     
      SetFileTime(hFile, nil, nil, @hInfo.ftLastWriteTime);
    end;
    
    if AccessDate <> 0 then
    begin
      DateTime2SystemTime(AccessDate, ST);
      SystemTimeToFileTime(ST, hInfo.ftLastAccessTime);
      if _prop_TimeType = 1 then
        LocalFileTimeToFileTime(hInfo.ftLastAccessTime,  hInfo.ftLastAccessTime);     
      SetFileTime(hFile, nil, @hInfo.ftLastAccessTime, nil);
    end;
    
    CloseHandle(hFile);
  end
  else
    _hi_CreateEvent(_Data, @_event_onError, Integer(GetLastError));
end;

procedure THIFileAttributes.GetTimeV(var _Data: TData; t: PFileTime; RealDate: Boolean);
var
  FT: TFileTime;
  ST: TSystemTime;
  DateTime: TDateTime;
  fn: string;
begin
  if fFileName = '' then // Не было предварительного doRead
  begin
    fn := ReadString(_Data, _data_FileName, _prop_FileName);
    if not GetFileAttributesEx(PChar(fn), GetFileExInfoStandard, @fAttrData) then
    begin
      dtNull(_Data);
      Exit;
    end;
  end;

  if _prop_TimeType = 1 then
    FileTimeToLocalFileTime(t^, FT)
  else
    FT := t^;

  FileTimeToSystemTime(FT, ST);
  
  if RealDate then
  begin
    SystemTime2DateTime(ST, DateTime);
    dtReal(_Data, DateTime);
  end
  else
    dtString(_Data, TimeToStr(_prop_Format, ST));
end;

procedure THIFileAttributes._var_FileSize;
type
  T = record
    L, H: DWord
  end;
var
  Sz: Int64;
  fn: string;
begin
  if fFileName = '' then // Не было предварительного doRead
  begin
    fn := ReadString(_Data, _data_FileName, _prop_FileName);
    if not GetFileAttributesEx(PChar(fn), GetFileExInfoStandard, @fAttrData) then
    begin
      dtNull(_Data);
      Exit;
    end;
  end;
  
  if (fAttrData.nFileSizeHigh = 0) and (Integer(fAttrData.nFileSizeLow) >= 0) then
    dtInteger(_Data, fAttrData.nFileSizeLow)
  else
  begin
    T(Sz).L := fAttrData.nFileSizeLow;
    T(Sz).H := fAttrData.nFileSizeHigh;
    dtReal(_Data, Sz);
  end;
end;

//doGetFileIcon - Извлекает иконку, ассоциированную с файлом

procedure THIFileAttributes._work_doGetFileIcon;
var
  ico: PIcon;
  fn: string;
  dt: TData;
  SFI: TShFileInfo;
  Flags: DWord;      
begin
  fn := ReadString(_Data, _data_FileName, _prop_FileName);
  
  Flags := SHGFI_ICON or SHGFI_ICONLOCATION or SHGFI_TYPENAME or SHGFI_SYSICONINDEX;
  if fOpenIcon then Flags := Flags or SHGFI_OPENICON;   
  if fSmallIcon then Flags := Flags or SHGFI_SMALLICON;
  
  ShGetFileInfo(PChar(fn), 0, SFI, SizeOf(SFI), Flags);

  if SFI.hIcon <> 0 then
  begin
    ico := NewIcon;
    ico.Handle := SFI.hIcon; 
    dtIcon(dt, ico);
    _hi_onEvent(_event_onGetFileIcon, dt);
    ico.Free;
    DestroyIcon(SFI.hIcon);
  end
  else
  begin
    dtNull(dt); 
    _hi_onEvent(_event_onGetFileIcon, dt);
  end;
end;

procedure THIFileAttributes._work_doSmallIcon;
begin
  fSmallIcon := ReadBool(_Data);
end;

procedure THIFileAttributes._work_doOpenIcon;
begin
  fOpenIcon := ReadBool(_Data);
end;

procedure THIFileAttributes._var_DateCreate;
begin
  GetTimeV(_Data, @fAttrData.ftCreationTime, False);
end;

procedure THIFileAttributes._var_DateAccess;
begin
  GetTimeV(_Data, @fAttrData.ftLastAccessTime, False);
end;

procedure THIFileAttributes._var_DateModify;
begin
  GetTimeV(_Data, @fAttrData.ftLastWriteTime, False);
end;

procedure THIFileAttributes._var_DateCreateReal;
begin
  GetTimeV(_Data, @fAttrData.ftCreationTime, True);
end;

procedure THIFileAttributes._var_DateAccessReal;
begin
  GetTimeV(_Data, @fAttrData.ftLastAccessTime, True);
end;

procedure THIFileAttributes._var_DateModifyReal;
begin
  GetTimeV(_Data, @fAttrData.ftLastWriteTime, True);
end;

procedure THIFileAttributes._work_doGetFileVersion;
var
  len, dummy: Cardinal; 
  verdata: Pointer; 
  verstruct: Pointer;
  fn: string;
  dt: TData;
  mt: PMT;
  Err: Integer;
begin
  sVersion.vMajor := 0;
  sVersion.vMinor := 0;
  sVersion.vRelease := 0;
  sVersion.vRelease := 0;

  fn := ReadString(_Data, _data_FileName, _prop_FileName);
  len := GetFileVersionInfoSize(PChar(fn), dummy);
  Err := Integer(GetLastError);

  if Err <> NO_ERROR then
  begin
    _hi_CreateEvent(_Data, @_event_onError, Err);
    Exit;
  end;

  GetMem(verdata, len);
  try
    GetFileVersionInfo(PChar(fn), 0, len, verdata);
    VerQueryValue(verdata, '\', verstruct, dummy);
    sVersion.vMajor := HiWord(TVSFixedFileInfo(verstruct^).dwFileVersionMS);
    sVersion.vMinor := LoWord(TVSFixedFileInfo(verstruct^).dwFileVersionMS);
    sVersion.vRelease := HiWord(TVSFixedFileInfo(verstruct^).dwFileVersionLS);
    sVersion.vBuild := LoWord(TVSFixedFileInfo(verstruct^).dwFileVersionLS);
  finally
    FreeMem(verdata);
  end;
  dtInteger(dt, sVersion.vMajor);
  mt := mt_make(dt);
  mt_int(mt, sVersion.vMinor);
  mt_int(mt, sVersion.vRelease);
  mt_int(mt, sVersion.vBuild);
  _hi_onEvent(_event_onGetFileVersion, dt);
  mt_free(mt);
end;  

procedure THIFileAttributes._var_Major;
begin
  dtInteger(_Data, sVersion.vMajor);
end;

procedure THIFileAttributes._var_Minor;
begin
  dtInteger(_Data, sVersion.vMinor);
end;

procedure THIFileAttributes._var_Release;
begin
  dtInteger(_Data, sVersion.vRelease);
end;

procedure THIFileAttributes._var_Build;
begin
  dtInteger(_Data, sVersion.vBuild);
end;

end.