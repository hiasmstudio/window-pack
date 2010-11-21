unit hiDirTools;

interface

uses windows,Kol,Share,Debug,ShellAPI;

type
  THIDirTools = class(TDebug)
   private
   public
    _prop_AllowUnDo:byte;
    _prop_FilesOnly:byte;
    _prop_MultiDestFiles:byte;
    _prop_NoConfirmation:byte;
    _prop_NoConfirmMKDir:byte;
    _prop_NoErrorUI:byte;
    _prop_RenameOnCollision:byte;
    _prop_Silent:byte;
    _prop_SimpleProgress:byte;

    _data_Dest:THI_Event;
    _data_Source:THI_Event;
    _event_onOK:THI_Event;

    function Op(func:cardinal; const FromFolder,ToFolder: string; flags:word):boolean;
    function creatflg():word;
    procedure _work_doCopy(var _Data:TData; Index:word);
    procedure _work_doMove(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);
    procedure _work_doRename(var _Data:TData; Index:word);
    procedure _work_doExists(var _Data:TData; Index:word);
    procedure _work_doGetSize(var _Data:TData; Index:word);
  end;

implementation

function THIDirTools.Op;
var
  Fo      : TSHFileOpStruct;
  buffer  : array[0..4096] of char;
  p       : pchar;
begin
  FillChar(Buffer, sizeof(Buffer), #0);
  p := @buffer;
  StrPCopy(p, PChar(FromFolder)); //директория, которую мы хотим скопировать
  FillChar(Fo, sizeof(Fo), 0);
  Fo.Wnd    := ReadHandle;
  Fo.wFunc  := func;
  Fo.pFrom  := @Buffer;
  Fo.pTo    := PChar(ToFolder); //куда будет скопирована директория
  Fo.fFlags := flags;
  Result := not (((SHFileOperation(Fo) <> 0) or (Fo.fAnyOperationsAborted <> false)));
end;

function THIDirTools.creatflg():word;
begin
  Result := _prop_AllowUnDo*FOF_ALLOWUNDO +
            _prop_FilesOnly*FOF_FILESONLY +
            _prop_MultiDestFiles*FOF_MULTIDESTFILES +
            _prop_NoConfirmation*FOF_NOCONFIRMATION +
            _prop_NoConfirmMKDir*FOF_NOCONFIRMMKDIR +
            _prop_NoErrorUI*FOF_NOERRORUI +
            _prop_RenameOnCollision*FOF_RENAMEONCOLLISION +
            _prop_Silent*FOF_SILENT +
            _prop_SimpleProgress*FOF_SIMPLEPROGRESS;
end;

procedure THIDirTools._work_doCopy;
var s:string;
begin
  s := ReadString(_Data,_data_Source,'');
  if Op(FO_COPY,s,ReadString(_Data,_data_Dest,''),creatflg()) then
    _hi_CreateEvent(_Data,@_event_onOK);
end;

procedure THIDirTools._work_doMove;
var s:string;
begin
  s := ReadString(_Data,_data_Source,'');
  if Op(FO_MOVE,s,ReadString(_Data,_data_Dest,''),creatflg()) then
    _hi_CreateEvent(_Data,@_event_onOK);
end;

procedure THIDirTools._work_doDelete;
begin
  if Op(FO_DELETE,ReadString(_Data,_data_Source,''),'',creatflg()) then
    _hi_CreateEvent(_Data,@_event_onOK);
end;

procedure THIDirTools._work_doRename;
begin
  if Op(FO_RENAME,ReadString(_Data,_data_Source,''),ReadString(_Data,_data_Dest,''),creatflg()) then
    _hi_CreateEvent(_Data,@_event_onOK);
end;

procedure THIDirTools._work_doExists;
var s:string;
begin
   s := ReadString(_Data,_data_Source,'');
   _hi_CreateEvent(_Data,@_event_onOK,integer(DirectoryExists(s))+2*integer(FileExists(s)));
end;

type T=record L,H:integer end;
// Отсутствует в KOL-FPC
function DirectorySize( const Path: String ): Int64;
var DirList: PDirList;
    I: Integer;
    Sz:Int64;
begin
  Result := 0;
  DirList := NewDirList(Path,'*.*',0);
  for I := 0 to DirList.Count-1 do begin
    if (DirList.Items[I].dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY)<>0 then
      Sz := DirectorySize(DirList.Path + DirList.Names[I])
    else begin
      T(Sz).L := DirList.Items[I].nFileSizeLow;
      T(Sz).H := DirList.Items[I].nFileSizeHigh;
    end;
    Result := Result + Sz;
  end;
  DirList.Free;
end;

procedure THIDirTools._work_doGetSize;
var Sz:Int64;
begin
  Sz := DirectorySize(ReadString(_Data,_data_Source,''));
  if (T(Sz).H=0)and(T(Sz).L>=0) then dtInteger(_Data,T(Sz).L)
  else dtReal(_Data,Sz);
  _hi_CreateEvent_(_Data,@_event_onOK);
end;

end.
