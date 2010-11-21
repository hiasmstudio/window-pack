unit hiCeFileAttributes; {чтение атрибутов файла ver 2.50}

interface

uses Windows,KolRapi,Kol,Share,Debug;

type
  THICeFileAttributes = class(TDebug)
   private
    procedure GetTimeV(var _Data:TData; idx:integer; RealDate:boolean);
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

    procedure _work_doRead(var _Data:TData; Index:word);
    procedure _work_doSet(var _Data:TData; Index:word);
    procedure _work_doSetDate(var _Data:TData; Index:word);
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

const At:array[0..12] of DWORD = (
  FILE_ATTRIBUTE_ARCHIVE,
  FILE_ATTRIBUTE_COMPRESSED,
  FILE_ATTRIBUTE_DIRECTORY,
  FILE_ATTRIBUTE_ENCRYPTED,
  FILE_ATTRIBUTE_HIDDEN,
  FILE_ATTRIBUTE_INROM,
  FILE_ATTRIBUTE_NORMAL,
  FILE_ATTRIBUTE_READONLY,
  FILE_ATTRIBUTE_REPARSE_POINT,
  FILE_ATTRIBUTE_ROMMODULE,
  FILE_ATTRIBUTE_SPARSE_FILE,
  FILE_ATTRIBUTE_SYSTEM,
  FILE_ATTRIBUTE_TEMPORARY);

procedure THICeFileAttributes._work_doRead;
var Attr,i,j:integer;
    fn:string;
begin
  fn := readString(_Data,_data_FileName,_prop_FileName);
  Attr := CeGetFileAttributes(StringToOleStr(fn));
  i := 0;
  for j := 0 to high(At) do
    i := i or ((integer((Attr and At[j]) <> 0)) shl j);
  _hi_CreateEvent(_Data,@_event_onRead,i);
end;

procedure THICeFileAttributes._work_doSet;
var i,j,Attr:dword;
    fn:string;
begin
  fn := readString(_Data,_data_FileName,_prop_FileName);
  i := ReadInteger(_Data,_data_Attr,_prop_Attr);
  Attr := 0;
  for j := 0 to high(At) do
   Attr := Attr or ((i shr j) and 1) * At[j];

  if not CeSetFileAttributes(StringToOleStr(fn),Attr )then
    _hi_CreateEvent(_Data,@_event_onError);
end;

procedure THICeFileAttributes._work_doSetDate;
var   hInfo:TByHandleFileInformation; 
      sys:TSystemTime;
      CreateDate:TDateTime;
      ModifyDate:TDateTime;
      AccessDate:TDateTime;
      hFile: THandle;
      fn:string;
begin
  fn := ReadString(_Data,_data_FileName,_prop_FileName);
  hFile := CeCreateFile(StringToOleStr(fn), GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
  CreateDate := ReadReal(_Data, _data_CreateDate);
  ModifyDate := ReadReal(_Data, _data_ModifyDate);
  AccessDate := ReadReal(_Data, _data_AccessDate);
  if hFile <> INVALID_HANDLE_VALUE then begin
     if  CreateDate <> 0 then begin
        DateTime2SystemTime(CreateDate, sys);
        SystemTimeToFileTime(sys, hInfo.ftCreationTime); 
        if _prop_TimeType = 1 then
           LocalFileTimeToFileTime(hInfo.ftCreationTime, hInfo.ftCreationTime);
        CeSetFileTime(hFile,@hInfo.ftCreationTime,nil,nil);
     end;   
     if  ModifyDate <> 0 then begin
        DateTime2SystemTime(ModifyDate, sys);
        SystemTimeToFileTime(sys, hInfo.ftLastWriteTime);
        if _prop_TimeType = 1 then
           LocalFileTimeToFileTime(hInfo.ftLastWriteTime,  hInfo.ftLastWriteTime);     
        CeSetFileTime(hFile,nil,nil,@hInfo.ftLastWriteTime);
     end;
     if  AccessDate <> 0 then begin
        DateTime2SystemTime(AccessDate, sys);
        SystemTimeToFileTime(sys, hInfo.ftLastAccessTime);
        if _prop_TimeType = 1 then
           LocalFileTimeToFileTime(hInfo.ftLastAccessTime,  hInfo.ftLastAccessTime);     
        CeSetFileTime(hFile,nil,@hInfo.ftLastAccessTime,nil);
     end;
  end else
        _hi_CreateEvent(_Data,@_event_onError);
  CeCloseHandle(hFile);
end;

procedure THICeFileAttributes.GetTimeV(var _Data:TData; idx:integer; RealDate:boolean);
var tmp,m,x,y,z:TFileTime;
    sys:TSystemTime;
    DateTime:TDateTime;
    fn:string;
    hFile: THandle;
begin
  fn := readString(_Data,_data_FileName,_prop_FileName);
  hFile := CeCreateFile(StringToOleStr(fn), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if (hFile <> INVALID_HANDLE_VALUE) and CeGetFileTime(hFile,@x,@y,@z) then begin
   case idx of
    1: tmp := x;
    2: tmp := y;
    3: tmp := z;
   end;
    if _prop_TimeType = 1 then
       FileTimeToLocalFileTime(tmp,m)
    else
       m := tmp;
    FileTimeToSystemTime(m,sys);
    if RealDate then begin
       SystemTime2DateTime(sys, DateTime);
       dtReal(_Data,DateTime);
    end else
       dtString(_Data,TimeToStr(_prop_Format,sys));
  end else dtNull(_data);
  CeCloseHandle(hFile);
end;

procedure THICeFileAttributes._var_FileSize;
type T=record L,H:dword end;
var Sz:int64;
    fn:string;
    hFile: THandle;
begin
  fn := readString(_Data,_data_FileName,_prop_FileName);
  hFile := CeCreateFile(StringToOleStr(fn), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if hFile <> INVALID_HANDLE_VALUE then
   begin
   T(Sz).L := CeGetFileSize(hFile,@T(Sz).H);
    if (Integer(T(Sz).H) = 0) and (integer(T(Sz).L) >= 0) then
      dtInteger(_Data,T(Sz).L)
    else
      dtReal(_Data,Sz);
   end
  else dtNull(_data);
  CeCloseHandle(hFile);
end;

procedure THICeFileAttributes._var_DateCreate;
begin
  GetTimeV(_Data,1,false);
end;

procedure THICeFileAttributes._var_DateAccess;
begin
  GetTimeV(_Data,2,false);
end;

procedure THICeFileAttributes._var_DateModify;
begin
  GetTimeV(_Data,3,false);
end;

procedure THICeFileAttributes._var_DateCreateReal;
begin
  GetTimeV(_Data,1,true);
end;

procedure THICeFileAttributes._var_DateAccessReal;
begin
  GetTimeV(_Data,2,true);
end;

procedure THICeFileAttributes._var_DateModifyReal;
begin
  GetTimeV(_Data,3,true);
end;

end.
