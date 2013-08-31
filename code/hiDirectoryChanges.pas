unit hiDirectoryChanges;

interface

uses Windows,kol,Share,Debug;

const
  FILE_LIST_DIRECTORY   = $0001;
const
  MAX_THREAD_COUNT = 10;

function ReadDirectoryChanges(hDirectory: THandle; lpBuffer: Pointer;
                              nBufferLength: DWORD; bWatchSubtree: Bool; dwNotifyFilter: DWORD;
                              lpBytesReturned: LPDWORD; lpOverlapped: POverlapped;
                              lpCompletionRoutine: FARPROC): BOOL; stdcall;
                              external kernel32 name 'ReadDirectoryChangesW';

type
  PFileNotifyInformation = ^TFileNotifyInformation;
  TFileNotifyInformation = record
    NextEntryOffset : DWORD;
    Action          : DWORD;
    FileNameLength  : DWORD;
    FileName        : array[0..0] of WideChar;
  end;

 // Структура с информацией об изменении в структуре наблюдаемых папок (передается в callback процедуру)

  PInfoCallBack = ^TInfoCallBack;
  TInfoCallBack = record
    FAction      : Integer; // тип изменения (константы FILE_ACTION_XXX)
    FDrive       : string;  // диск, на котором было изменение
    FOldFileName : string;  // имя файла до переименования
    FNewFileName : string;  // имя файла после переименования
  end;

// callback процедура, вызываемая при изменении в структуре наблюдаемых папок
//
TWatchFileSystemCallBack = procedure (pInfo: TInfoCallBack; Tag: DWord);

type
// Собственно, наш HiAsm класс
//
 THiDirectoryChanges = class(TDebug)
   private
    sSubTree        : boolean;
    WFS             : PThread;
    FName           : string;
    FFilter         : Cardinal;
    FSubTree        : boolean;
    FInfoCallBack   : TWatchFileSystemCallBack;
    FWatchHandle    : THandle;
    FWatchBuf       : array[0..4096] of Byte;
    FOverLapp       : TOverlapped;
    FPOverLapp      : POverlapped;
    FBytesWritte    : DWORD;
    FCompletionPort : THandle;
    IOCP            : THandle;
    FNumBytes       : Cardinal;
    FOldFileName    : string;
    sTag            : DWord;
    sOldFileName    : string;
    sNewFileName    : string;
    procedure StartWatch(pName: string; pFilter: cardinal; pSubTree: boolean; pInfoCallBack: TWatchFileSystemCallBack);
    procedure StopWatch;
    function CreateDirHandle(aDir: string): THandle;
    procedure HandleEvent;
    function Execute(Sender:PThread): Integer;
   public
    _prop_Flags     : integer;
    _prop_DirName   : string;    
    _event_onError  : THI_Event;
    _event_onChange : THI_Event;
    _data_DirName   : THI_Event;
    _data_Flags     : THI_Event;

    property _prop_SubTree:boolean write sSubTree;

    destructor Destroy; override;
    procedure _work_doStartWatch(var _Data:TData; Index:word);
    procedure _work_doStopWatch(var _Data:TData; Index:word);
    procedure _work_doSubTree(var _Data:TData; Index:word);    
    procedure _var_OldFileName(var _Data:TData; Index:word);
    procedure _var_NewFileName(var _Data:TData; Index:word);
 end;

implementation

// Запуск мониторинга изменений структуры папок
// Праметры:
//   pName    - имя папки для мониторинга
//   pFilter  - комбинация констант FILE_NOTIFY_XXX
//   pSubTree - мониторить ли все подпапки заданной папки
//   pInfoCallBack - адрес callback процедуры, вызываемой при изменении в структуре наблюдаемых папок
//
procedure THiDirectoryChanges.StartWatch(pName: string; pFilter: cardinal; pSubTree: boolean; pInfoCallBack: TWatchFileSystemCallBack);
begin
  StopWatch;
  sTag := LongInt(Self);
  FName := IncludeTrailingChar(pName, '\');
  FFilter := pFilter;
  FSubTree := pSubTree;
  FOldFileName := '';
  ZeroMemory(@FOverLapp, SizeOf(TOverLapped));
  FPOverLapp:=@FOverLapp;
  ZeroMemory(@FWatchBuf, SizeOf(FWatchBuf));
  FInfoCallBack := pInfoCallBack;
  IOCP := CreateIoCompletionPort(INVALID_HANDLE_VALUE, 0, 0, MAX_THREAD_COUNT);
  WFS := {$ifdef F_P}NewThreadforFPC{$else}NewThread{$endif};
  WFS.OnExecute := Execute;
  WFS.Resume;
end;

// Остановка мониторинга
//
procedure THiDirectoryChanges.StopWatch;
var Temp : PThread;
begin
  if Assigned(WFS) then
  begin
    PostQueuedCompletionStatus(FCompletionPort, 0, 0, nil);
    if Assigned(WFS) then
    begin
      Temp := WFS;
      WFS := nil;
      Temp.Terminate;
      Temp.WaitFor;
      free_and_nil(Temp);
    end;
    CloseHandle(FWatchHandle);
    FWatchHandle := 0;
    CloseHandle(FCompletionPort);
    FCompletionPort := 0;
    CloseHandle(IOCP);
    IOCP := 0;
  end;
end;

destructor THiDirectoryChanges.Destroy;
begin
  {$ifndef F_P}StopWatch;{$endif}
  inherited;
end;

function THiDirectoryChanges.CreateDirHandle(aDir: string): THandle;
begin
Result := CreateFile(PChar(aDir), FILE_LIST_DIRECTORY, FILE_SHARE_READ+FILE_SHARE_DELETE+FILE_SHARE_WRITE,
                     nil,OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS or FILE_FLAG_OVERLAPPED, 0);
end;

function THiDirectoryChanges.Execute;
var CompletionKey: Cardinal;
begin
  Result := 0;
  FWatchHandle := CreateDirHandle(FName);
  FCompletionPort := CreateIoCompletionPort(FWatchHandle, IOCP, Longint(pointer(Self)), 0);
  ZeroMemory(@FWatchBuf, SizeOf(FWatchBuf));
  if not ReadDirectoryChanges(FWatchHandle, @FWatchBuf, SizeOf(FWatchBuf), FSubTree,
                              FFilter, @FBytesWritte,  @FOverLapp, nil) then
  begin
    _hi_onEvent(_event_onError, SysErrorMessage(GetLastError));
    Sender.Terminate;
  end else
  begin
    while not Sender.Terminated do
    begin
      GetQueuedCompletionStatus(FCompletionPort, FNumBytes, CompletionKey, FPOverLapp, INFINITE);
      if CompletionKey <> 0 then
      begin
        Sender.Synchronize(HandleEvent);
        ZeroMemory(@FWatchBuf, SizeOf(FWatchBuf));
        FBytesWritte := 0;
        ReadDirectoryChanges(FWatchHandle, @FWatchBuf, SizeOf(FWatchBuf), FSubTree,
                             FFilter, @FBytesWritte, @FOverLapp, nil);
      end else Sender.Terminate;
    end;
  end;
end;

procedure THiDirectoryChanges.HandleEvent;
var FileNotifyInfo : PFileNotifyInformation;
    InfoCallBack   : TInfoCallBack;
    Offset         : Longint;
    Str            : string;
begin
  Pointer(FileNotifyInfo) := @FWatchBuf[0];
  repeat
    Offset:=FileNotifyInfo^.NextEntryOffset;
    InfoCallBack.FAction := FileNotifyInfo^.Action;
    InfoCallBack.FDrive := FName;
//    InfoCallBack.FNewFileName := WideCharToString(@(FileNotifyInfo^.FileName[0]));
//    InfoCallBack.FNewFileName := Trim(InfoCallBack.FNewFileName);
//    case FileNotifyInfo^.Action of
//      FILE_ACTION_RENAMED_OLD_NAME: FOldFileName := Trim(WideCharToString(@(FileNotifyInfo^.FileName[0])));
//      FILE_ACTION_RENAMED_NEW_NAME: InfoCallBack.FOldFileName := FOldFileName;
//    end;
    Str := Trim(WideCharLenToString(@(FileNotifyInfo^.FileName[0]), FileNotifyInfo.FileNameLength div 2));
    InfoCallBack.FNewFileName := Str;
    case FileNotifyInfo^.Action of
      FILE_ACTION_RENAMED_OLD_NAME: FOldFileName := Str;
      FILE_ACTION_RENAMED_NEW_NAME: InfoCallBack.FOldFileName := FOldFileName;
    end;
    FInfoCallBack(InfoCallBack, sTag);
    PChar(FileNotifyInfo) := PChar(FileNotifyInfo) + Offset;
  until (Offset=0) or WFS.Terminated or (WFS = nil);
end;

procedure MyInfoCallBack(pInfo: TInfoCallBack; Tag: DWord);
var Self: THiDirectoryChanges;
begin
  Self := THiDirectoryChanges(Tag);
  Self.sOldFileName := '';
  Self.sNewFileName := '';
  if pInfo.FAction = FILE_ACTION_RENAMED_OLD_NAME then exit;
  Self.sNewFileName := pInfo.FDrive + pInfo.FNewFileName;
  if pInfo.FAction = FILE_ACTION_RENAMED_NEW_NAME then
    Self.sOldFileName := pInfo.FDrive + pInfo.FOldFileName;
  _hi_onEvent(Self._event_onChange, pInfo.FAction);
end;

{
FILE_ACTION_ADDED                   = $00000001;//создание
FILE_ACTION_REMOVED                 = $00000002;//удаление
FILE_ACTION_MODIFIED                = $00000003;//изменение
FILE_ACTION_RENAMED_OLD_NAME        = $00000004;//старое имя файла
FILE_ACTION_RENAMED_NEW_NAME        = $00000005;//новое имя файла

FILE_NOTIFY_CHANGE_FILE_NAME        = $00000001; //изменение имени файла
FILE_NOTIFY_CHANGE_DIR_NAME         = $00000002; //изменение имени папки
FILE_NOTIFY_CHANGE_ATTRIBUTES       = $00000004; //изменение атрибутов файла
FILE_NOTIFY_CHANGE_SIZE             = $00000008; //изменение размера
FILE_NOTIFY_CHANGE_LAST_WRITE       = $00000010; //изменение времени последней записи
FILE_NOTIFY_CHANGE_LAST_ACCESS      = $00000020; //изменение времени последнего доступа
FILE_NOTIFY_CHANGE_CREATION         = $00000040; //изменение времени создания
FILE_NOTIFY_CHANGE_SECURITY         = $00000100; //изменение прав доступа
}

procedure THiDirectoryChanges._work_doStartWatch;
var _Flags: Cardinal;
    _DirName: string;
begin
  _DirName := ReadString(_Data, _data_DirName, _prop_DirName);
  _Flags := ReadInteger(_Data, _data_Flags, _prop_Flags);
  if _Flags = 0 then exit;
  StartWatch(_DirName, _Flags, sSubTree, @MyInfoCallBack);
end;

procedure THiDirectoryChanges._work_doStopWatch;
begin
  StopWatch;
end;

procedure THiDirectoryChanges._work_doSubTree;
begin
  sSubTree := ReadBool(_Data);
end;

procedure THiDirectoryChanges._var_OldFileName;
begin
  dtString(_Data, sOldFileName);
end;

procedure THiDirectoryChanges._var_NewFileName;
begin
  dtString(_Data, sNewFileName);
end;

end.
