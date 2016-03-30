unit hiFileSearch;

interface

uses Windows,Kol,Share,Debug;

type
  THIFileSearch = class(TDebug)
   private
    FCount:integer;
    FStop:boolean;
    FWorkExt:PStrList;
    FindData:PWin32FindData;

    function multiCmp(const Name:string):boolean;
    procedure Search(const Dir:string);
    procedure OutFiles(const Dir,Name:string);
   public
    _prop_Ext:string;
    _prop_Dir:string;
    _prop_SubDir:byte;
    _prop_FullName:boolean;
    _prop_FullOtherName:boolean;
    _prop_Include:byte;
    _prop_Format:string;
    _prop_TimeType:byte;

    _data_Dir:THI_Event;
    _data_Ext:THI_Event;
    _event_onEndSearch:THI_Event;
    _event_onSearch:THI_Event;
    _event_onOtherFiles:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doSearch(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_Size(var _Data:TData; Index:word);
    procedure _var_ShortName(var _Data:TData; Index:word);
    procedure _var_DateCreate(var _Data:TData; Index:word);
    procedure _var_DateAccess(var _Data:TData; Index:word);
    procedure _var_DateModify(var _Data:TData; Index:word);
    procedure _var_DateCreateReal(var _Data:TData; Index:word);
    procedure _var_DateAccessReal(var _Data:TData; Index:word);
    procedure _var_DateModifyReal(var _Data:TData; Index:word);
    procedure _var_Attr(var _Data:TData; Index:word);
  end;

implementation

uses hiStrMask, HiTime;

var Dummy:TWin32FindData;

constructor THIFileSearch.Create;
begin
  inherited Create;
  FindData := @Dummy; //инициализируем пустышкой для дуракоустойчивости
  FWorkExt  := NewStrList;
end;

destructor THIFileSearch.Destroy;
begin
  FWorkExt.Free;
  inherited Destroy;
end;

procedure THIFileSearch.OutFiles;
var fn:string;
begin
  fn := Name;
  if _prop_FullName then fn := Dir + fn;
  _hi_OnEvent(_event_onSearch,fn);
end;

function THIFileSearch.multiCmp;
var i:integer;
begin
  Result := true;
  for i := 0 to FWorkExt.Count-1 do
    if (FWorkExt.Items[i]<>'')and StrCmp(Name, FWorkExt.Items[i]) then exit;
  Result := false;
end;

procedure THIFileSearch._work_doSearch;
var Dr:String;
begin
  Dr := ReadString(_Data,_data_Dir,_prop_Dir);
  FWorkExt.SetText(LowerCase(ReadString(_Data,_data_Ext,_prop_Ext)), false);
  if Dr = '' then exit;
  if Dr[Length(Dr)] <> '\' then Dr := Dr + '\';
  if FWorkExt.Count = 0 then FWorkExt.Add('*');
  FCount := 0;
  FStop := false;
  Search(Dr);         //там FindData принимает боевые значения
  FindData := @Dummy; //восстанавливаем указатель на пустышку
  _hi_CreateEvent(_Data,@_event_onEndSearch,FCount);
end;

procedure THIFileSearch.Search;
var FindHandle:THandle;
    FindData:TWin32FindData;
begin
  FindHandle := FindFirstFile(PChar(Dir + '*.*'), FindData);
  if FindHandle=INVALID_HANDLE_VALUE then exit;
  Self.FindData := @FindData;
  repeat if (PChar(@FindData.cFileName[0]) <> '.')and(PChar(@FindData.cFileName[0]) <> '..') then
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY)<>0 then  begin
      if _prop_Include > 0 then OutFiles(Dir,FindData.cFileName);
      if _prop_SubDir = 0 then
      begin
         Search(Dir + FindData.cFileName + '\');
         Self.FindData := @FindData;
      end
    end else if multiCmp(LowerCase(FindData.cFileName)) then begin
      inc(FCount);
      if _prop_Include <> 1 then OutFiles(Dir,FindData.cFileName);
    end else if _prop_FullOtherName then _hi_OnEvent(_event_onOtherFiles,Dir + FindData.cFileName)
    else _hi_OnEvent(_event_onOtherFiles,FindData.cFileName);
  until FStop or not FindNextFile(FindHandle, FindData);
  FindClose(FindHandle);
end;

procedure THIFileSearch._work_doStop;
begin
  FStop := true;
end;

procedure THIFileSearch._var_Count;
begin
  dtInteger(_Data,FCount);
end;

procedure THIFileSearch._var_Size;
type T=record L,H:integer end;
var FSize:int64;
begin
  T(FSize).L := FindData.nFileSizeLow;
  T(FSize).H := FindData.nFileSizeHigh;
  if (T(FSize).H=0)and(T(FSize).L>=0) then dtInteger(_Data,T(FSize).L)
  else dtReal(_Data,FSize);
end;

procedure THIFileSearch._var_ShortName;
begin
  dtString(_Data,FindData.cAlternateFileName);
end;

procedure THIFileSearch._var_DateCreate;
var
  m: TFileTime;
  sys: TSystemTime;
begin
  if _prop_TimeType = 1 then
     FileTimeToLocalFileTime(FindData.ftCreationTime, m)
  else
     m := FindData.ftCreationTime;
  FileTimeToSystemTime(m,sys);
  dtString(_Data,TimeToStr(_prop_Format, sys));
end;

procedure THIFileSearch._var_DateAccess;
var
  m: TFileTime;
  sys: TSystemTime;
begin
  if _prop_TimeType = 1 then
     FileTimeToLocalFileTime(FindData.ftLastAccessTime, m)
  else
     m := FindData.ftLastAccessTime;
  FileTimeToSystemTime(m,sys);
  dtString(_Data,TimeToStr(_prop_Format, sys));
end;

procedure THIFileSearch._var_DateModify;
var
  m: TFileTime;
  sys: TSystemTime;
begin
  if _prop_TimeType = 1 then
     FileTimeToLocalFileTime(FindData.ftLastWriteTime, m)
  else
     m := FindData.ftLastWriteTime;
  FileTimeToSystemTime(m,sys);
  dtString(_Data,TimeToStr(_prop_Format, sys));
end;

procedure THIFileSearch._var_DateCreateReal;
var
  m: TFileTime;
  sys: TSystemTime;
  DateTime: TDateTime;
begin
  if _prop_TimeType = 1 then
     FileTimeToLocalFileTime(FindData.ftCreationTime, m)
  else
     m := FindData.ftCreationTime;
  FileTimeToSystemTime(m, sys);
  SystemTime2DateTime(sys, DateTime);
  dtReal(_Data, DateTime);
end;

procedure THIFileSearch._var_DateAccessReal;
var
  m: TFileTime;
  sys: TSystemTime;
  DateTime: TDateTime;
begin
  if _prop_TimeType = 1 then
     FileTimeToLocalFileTime(FindData.ftLastAccessTime, m)
  else
     m := FindData.ftLastAccessTime;
  FileTimeToSystemTime(m, sys);
  SystemTime2DateTime(sys, DateTime);
  dtReal(_Data, DateTime);
end;

procedure THIFileSearch._var_DateModifyReal;
var
  m: TFileTime;
  sys: TSystemTime;
  DateTime: TDateTime;
begin
  if _prop_TimeType = 1 then
     FileTimeToLocalFileTime(FindData.ftLastWriteTime, m)
  else
     m := FindData.ftLastWriteTime;
  FileTimeToSystemTime(m, sys);
  SystemTime2DateTime(sys, DateTime);
  dtReal(_Data, DateTime);
end;

procedure THIFileSearch._var_Attr;
const
  At: array[0..8] of DWORD = (FILE_ATTRIBUTE_NORMAL,
                              FILE_ATTRIBUTE_ARCHIVE,
                              FILE_ATTRIBUTE_READONLY,
                              FILE_ATTRIBUTE_HIDDEN,
                              FILE_ATTRIBUTE_SYSTEM,
                              FILE_ATTRIBUTE_DIRECTORY,
                              FILE_ATTRIBUTE_TEMPORARY,
                              FILE_ATTRIBUTE_COMPRESSED,
                              FILE_ATTRIBUTE_OFFLINE);
var
  i, j: integer;
begin
  i := 0;
  for j := 0 to high(At) do
    i := i or ((integer((FindData.dwFileAttributes and At[j]) <> 0)) shl j);
  dtInteger(_Data, i);
end;

initialization
  FillChar(Dummy, sizeof(Dummy), #0);
end.
