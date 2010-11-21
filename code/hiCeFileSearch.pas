unit hiCeFileSearch;

interface

uses Windows,Kol,KOLRapi,Share,Debug;

type
  THICeFileSearch = class(TDebug)
   private
    FCount:integer;
    FStop:boolean;
    FWorkExt,fsDr:String;
    FindData:TCeFindData;

    procedure Search(const Dir:string);
    procedure OutFiles(const Dir,Name:string);

    function  _arr_count:integer;
   public
    _prop_Ext:string;
    _prop_Dir:string;
    _prop_SubDir:byte;
    _prop_FullName:boolean;
    _prop_Include:byte;

    _data_Dir:THI_Event;
    _data_Ext:THI_Event;
    _event_onEndSearch:THI_Event;
    _event_onSearch:THI_Event;
    _event_onOtherFiles:THI_Event;

    destructor Destroy; override;
    procedure _work_doSearch(var _Data:TData; Index:word);
    procedure _work_doFastSearch(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_Size(var _Data:TData; Index:word);
  end;

implementation

uses hiStrMask;

destructor THICeFileSearch.Destroy;
begin
   inherited Destroy;
end;

procedure THICeFileSearch.OutFiles;
var fn:string;
begin
  fn := Name;
  if _prop_FullName then fn := Dir + fn;
  _hi_OnEvent(_event_onSearch,fn);
end;

procedure THICeFileSearch._work_doSearch;
var Dr:String;
begin
  Dr := ReadString(_Data,_data_Dir,_prop_Dir);
  FWorkExt := LowerCase(ReadString(_Data,_data_Ext,_prop_Ext));
  if Dr = '' then exit;
  if Dr[Length(Dr)] <> '\' then Dr := Dr + '\';
  if FWorkExt = '' then FWorkExt := '*';
  FCount := 0;
  FStop := false;
  Search(Dr);
  _hi_CreateEvent(_Data,@_event_onEndSearch,FCount);
end;

procedure THICeFileSearch._work_doFastSearch;
type T = record L,H:integer end;
var
    FastFindData:PCeFindDataArray;
    i:integer;
    FSize: int64;
    nms:string;
begin
  fsDr := ReadString(_Data,_data_Dir,_prop_Dir);
  FWorkExt := LowerCase(ReadString(_Data,_data_Ext,_prop_Ext));
  if fsDr = '' then exit;
  FCount := 0;
  if fsDr[Length(fsDr)] <> '\' then fsDr := fsDr + '\';
  if FWorkExt = '' then FWorkExt := '*';
  CeRapiFreeBuffer(FastFindData);
  CeFindAllFiles(StringToOleStr(fsDr + FWorkExt),FAF_ATTRIBUTES or FAF_NAME or FAF_SIZE_HIGH or FAF_SIZE_LOW,DWORD(FCount),FastFindData);
  for i := 0 to FCount-1 do
   begin
     nms := LStrFromPWCharLen(FastFindData[i].cFileName,sizeof(FindData.cFileName));
     if (FastFindData[i].dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
       nms := nms + '\';
     
     FindData.nFileSizeLow := FastFindData[i].nFileSizeLow;
     FindData.nFileSizeHigh := FastFindData[i].nFileSizeHigh;

     OutFiles(fsDr, nms);
   end;
      
  _hi_CreateEvent(_Data,@_event_onEndSearch,FCount);
  CeRapiFreeBuffer(FastFindData);
end;

procedure THICeFileSearch.Search;
var FindHandle: THandle;
    stFName: String;
begin
  FindHandle := CeFindFirstFile(StringToOleStr(Dir + '*.*'), @FindData);
  if FindHandle = INVALID_HANDLE_VALUE then exit;
  repeat
   stFName := LStrFromPWCharLen(@FindData.cFileName,sizeof(FindData.cFileName));
   if pos('.',stFName) <> 1 then
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
     begin
      if _prop_Include > 0 then OutFiles(Dir,stFName + '\');
      if _prop_SubDir = 0 then Search(Dir + stFName + '\');
     end else if StrCmp(LowerCase(stFName),FWorkExt) then 
     begin
      inc(FCount);
      if _prop_Include <> 1 then OutFiles(Dir,stFName);
     end else _hi_OnEvent(_event_onOtherFiles,Dir + '\' + stFName);
  until FStop or not CeFindNextFile(FindHandle, @FindData);
  CeFindClose(FindHandle);
end;

procedure THICeFileSearch._work_doStop;
begin
  FStop := true;
end;

procedure THICeFileSearch._var_Count;
begin
  dtInteger(_Data,FCount);
end;

procedure THICeFileSearch._var_Size;
type T=record L,H:integer end;
var FSize:int64;
begin
  T(FSize).L := FindData.nFileSizeLow;
  T(FSize).H := FindData.nFileSizeHigh;
  if (T(FSize).H=0)and(T(FSize).L>=0) then dtInteger(_Data,T(FSize).L)
  else dtReal(_Data,FSize);
end;

function THICeFileSearch._arr_count;
begin
  Result := FCount;
end;

end.
