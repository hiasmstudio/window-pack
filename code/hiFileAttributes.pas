unit hiFileAttributes; {чтение атрибутов файла ver 2.50}

interface

uses Windows,Shellapi,Kol,Share,Debug;

type
  THIFileAttributes = class(TDebug)
   private
    fn:string;
    fSmallIcon:boolean;
    fOpenIcon:boolean;    
    sys:WIN32_FILE_ATTRIBUTE_DATA;
    procedure GetTimeV(var _Data:TData; t:PFileTime; RealDate:boolean);
   public
    _prop_FileName:string;
    _prop_Attr:integer;
    _prop_Format:string;
    _prop_TimeType:byte;

    _data_Attr:THI_Event;
    _data_FileName:THI_Event;
    _data_CreateDate:THI_Event;
    _data_ModifyDate:THI_Event;
    _data_AccessDate:THI_Event;
    _event_onRead:THI_Event;
    _event_onError:THI_Event;
    _event_onGetFileIcon:THI_Event;

    property _prop_SmallIcon:boolean write fSmallIcon; 
    property _prop_OpenIcon:boolean write fOpenIcon;
    procedure _work_doRead(var _Data:TData; Index:word);
    procedure _work_doSet(var _Data:TData; Index:word);
    procedure _work_doSetDate(var _Data:TData; Index:word);
    procedure _work_doGetFileIcon(var _Data:TData; Index:word);    
    procedure _work_doSmallIcon(var _Data:TData; Index:word);
    procedure _work_doOpenIcon(var _Data:TData; Index:word);
    procedure _var_DateCreate(var _Data:TData; Index:word);
    procedure _var_DateAccess(var _Data:TData; Index:word);
    procedure _var_DateModify(var _Data:TData; Index:word);
    procedure _var_DateCreateReal(var _Data:TData; Index:word);
    procedure _var_DateAccessReal(var _Data:TData; Index:word);
    procedure _var_DateModifyReal(var _Data:TData; Index:word);
    procedure _var_FileSize(var _Data:TData; Index:word);
  end;

implementation

uses HiTime;

function GetFileAttributesEx(lpFileName: PChar; fInfoLevelId: TGetFileExInfoLevels;
         lpFileInformation: Pointer): BOOL; stdcall; external kernel32 name 'GetFileAttributesExA';

const At:array[0..8] of DWORD = (
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
  FILE_ATTRIBUTE_NOT_CONTENT_INDEXED});

procedure THIFileAttributes._work_doRead;
var i,j:integer;
begin
  fn := readString(_Data,_data_FileName,_prop_FileName);
  if not GetFileAttributesEx(PChar(fn),GetFileExInfoStandard,@sys) then begin
    fn := '';
    _hi_CreateEvent(_Data,@_event_onError,integer(getlasterror));
    exit;
  end;
  i := 0;
  for j := 0 to high(At) do
    i := i or ((integer((sys.dwFileAttributes and At[j])<>0)) shl j);
  _hi_CreateEvent(_Data,@_event_onRead,i);
end;

procedure THIFileAttributes._work_doSet;
var i,j,Attr:dword;
    fn:string;
begin
  fn := readString(_Data,_data_FileName,_prop_FileName);
  i := ReadInteger(_Data,_data_Attr,_prop_Attr);
  Attr := 0;
  for j := 0 to high(At) do
   Attr := Attr or ((i shr j) and 1)*At[j];

  if not SetFileAttributes(PChar(fn),Attr )then
    _hi_CreateEvent(_Data,@_event_onError);
end;

procedure THIFileAttributes._work_doSetDate;
var   hInfo:TByHandleFileInformation; 
      sys:TSystemTime;
      CreateDate:TDateTime;
      ModifyDate:TDateTime;
      AccessDate:TDateTime;
      hFile: THandle;
begin
  fn := ReadString(_Data,_data_FileName,_prop_FileName);
  hFile := CreateFile(PChar(fn), GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
  CreateDate := ReadReal(_Data, _data_CreateDate);
  ModifyDate := ReadReal(_Data, _data_ModifyDate);
  AccessDate := ReadReal(_Data, _data_AccessDate);
  if hFile <> 0 then begin
     if  CreateDate <> 0 then begin
        DateTime2SystemTime(CreateDate, sys);
        SystemTimeToFileTime(sys, hInfo.ftCreationTime); 
        if _prop_TimeType = 1 then
           LocalFileTimeToFileTime(hInfo.ftCreationTime, hInfo.ftCreationTime);
        SetFileTime(hFile,@hInfo.ftCreationTime,nil,nil);
     end;   
     if  ModifyDate <> 0 then begin
        DateTime2SystemTime(ModifyDate, sys);
        SystemTimeToFileTime(sys, hInfo.ftLastWriteTime);
        if _prop_TimeType = 1 then
           LocalFileTimeToFileTime(hInfo.ftLastWriteTime,  hInfo.ftLastWriteTime);     
        SetFileTime(hFile,nil,nil,@hInfo.ftLastWriteTime);
     end;
     if  AccessDate <> 0 then begin
        DateTime2SystemTime(AccessDate, sys);
        SystemTimeToFileTime(sys, hInfo.ftLastAccessTime);
        if _prop_TimeType = 1 then
           LocalFileTimeToFileTime(hInfo.ftLastAccessTime,  hInfo.ftLastAccessTime);     
        SetFileTime(hFile,nil,@hInfo.ftLastAccessTime,nil);
     end;
  end else
        _hi_CreateEvent(_Data,@_event_onError);
  CloseHandle(hFile);
end;

procedure THIFileAttributes.GetTimeV;
var m:TFileTime;
    sys:TSystemTime;
    DateTime:TDateTime;
begin
  if fn = '' then begin
    fn := readString(_Data,_data_FileName,_prop_FileName);
    if not GetFileAttributesEx(PChar(fn),GetFileExInfoStandard,@sys) then
      fn := '';
  end;
  if fn <> '' then begin
    if _prop_TimeType = 1 then
       FileTimeToLocalFileTime(t^,m)
    else
       m := t^;
    FileTimeToSystemTime(m,sys);
    if RealDate then begin
       SystemTime2DateTime(sys, DateTime);
       dtReal(_Data,DateTime);
    end else
       dtString(_Data,TimeToStr(_prop_Format,sys));
  end else dtNull(_data);
end;

procedure THIFileAttributes._var_FileSize;
type T=record L,H:dword end;
var Sz:int64;
begin
  if fn = '' then begin
    fn := readString(_Data,_data_FileName,_prop_FileName);
    if not GetFileAttributesEx(PChar(fn),GetFileExInfoStandard,@sys) then
      fn := '';
  end;
  if fn <> '' then
    if (sys.nFileSizeHigh=0)and(integer(sys.nFileSizeLow)>=0) then
      dtInteger(_Data,sys.nFileSizeLow)
    else begin
      T(Sz).L := sys.nFileSizeLow;
      T(Sz).H := sys.nFileSizeHigh;
      dtReal(_Data,Sz);
    end
  else dtNull(_data);
end;

//doGetFileIcon - Извлекает иконку, ассоциированную с файлом
//
procedure THIFileAttributes._work_doGetFileIcon;
var   ico: PIcon;
      f:string;
      dt:TData;
      SFI: TShFileInfo;
      _flags:dword;      
begin
   f := ReadString(_Data,_data_FileName,_prop_FileName);
   ico:= NewIcon;
   _flags := SHGFI_ICON or SHGFI_ICONLOCATION or SHGFI_TYPENAME or SHGFI_SYSICONINDEX;
   if fOpenIcon then _flags := _flags or SHGFI_OPENICON;   
   if fSmallIcon then _flags := _flags or SHGFI_SMALLICON;
   ShGetFileInfo(PChar(f), 0, SFI, SizeOf(SFI), _flags);
   ico.handle:= SFI.hIcon; 
   if ico.Handle <> 0 then dtIcon(dt,ico) else dtNull(dt); 
   _hi_onEvent(_event_onGetFileIcon, dt);
   ico.free;
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
  GetTimeV(_Data,@sys.ftCreationTime,false);
end;

procedure THIFileAttributes._var_DateAccess;
begin
  GetTimeV(_Data,@sys.ftLastAccessTime,false);
end;

procedure THIFileAttributes._var_DateModify;
begin
  GetTimeV(_Data,@sys.ftLastWriteTime,false);
end;

procedure THIFileAttributes._var_DateCreateReal;
begin
  GetTimeV(_Data,@sys.ftCreationTime,true);
end;

procedure THIFileAttributes._var_DateAccessReal;
begin
  GetTimeV(_Data,@sys.ftLastAccessTime,true);
end;

procedure THIFileAttributes._var_DateModifyReal;
begin
  GetTimeV(_Data,@sys.ftLastWriteTime,true);
end;

end.