unit HiSStorage_DS;

interface

uses
  Windows, Messages, ActiveX, KolComObj, Kol, Share, Debug;

const
  TMPFILEFORMAT = 'ddMMyyyyhhmmss';
  
const
  STG_ERR_SUCCESS                           = 0;
  STG_ERROR_INCORRECTFILENAME               = 1;
  STG_ERROR_FILENOTSTORAGE                  = 2;
  STG_ERROR_IMPOSSIBLEOPENSTORAGE           = 3;
  STG_ERROR_INACCESSIBLESTORAGE             = 4;   
  STG_ERROR_FOLDERISEXISTS                  = 5;
  STG_ERROR_IMPOSSIBLECREATEFOLDER          = 6;    
  STG_ERROR_INACCESSIBLESRCSTREAM           = 7;
  STG_ERROR_IMPOSSIBLEDELETEELEMENT         = 8;
  STG_ERROR_IMPOSSIBLEREANAMEFILEMOSTITSELF = 9;
  STG_ERROR_IMPOSSIBLERENAMEELEMENT         = 10; 
  STG_ERROR_IMPOSSIBLECOPYFILEMOSTITSELF    = 11;
  STG_ERROR_IMPOSSIBLECOPYELEMENT           = 12;
  STG_ERROR_IMPOSSIBLEMOVEFILEMOSTITSELF    = 13;
  STG_ERROR_IMPOSSIBLEMOVEELEMENT           = 14;
  STG_ERROR_IMPOSSIBLEPACKOPENSTG           = 15;
  STG_ERROR_IMPOSSIBLEPACKSTORAGE           = 16;  
  STG_ERROR_INACCESSIBLEROOTFOLDER          = 17;
  STG_ERROR_IMPOSSIBLEENUMELEMENTS          = 18;
  STG_ERROR_IMPOSSIBLEADDFILE               = 19;
  STG_ERROR_IMPOSSIBLEMERGEOPENSTG          = 20;
  STG_ERROR_IMPOSSIBLEMERGESTORAGES         = 21;        

const
  STGM_DIRECT_SWMR = $400000;
  
  stCreate         = STGM_CREATE or STGM_READWRITE or STGM_SHARE_EXCLUSIVE or STGM_DIRECT_SWMR;
  stTmpCreate      = STGM_CREATE or STGM_READWRITE or STGM_SHARE_EXCLUSIVE or STGM_DELETEONRELEASE or STGM_DIRECT_SWMR;
  stOpen           = STGM_READWRITE or STGM_SHARE_EXCLUSIVE or STGM_DIRECT_SWMR;
  stRead           = STGM_READ;
  stWrite          = STGM_WRITE;
  stReadWrite      = STGM_READWRITE;
  stCreateFolder   = stCreate{stOpen}; 
  stCreateFile     = stCreate;
  
  stShareDenyNone  = STGM_SHARE_DENY_NONE;
  stShareDenyRead  = STGM_SHARE_DENY_READ;
  stShareDenyWrite = STGM_SHARE_DENY_WRITE;
  stShareExclusive = STGM_SHARE_EXCLUSIVE;

  {Создается временный файл, который автоматически удаляется при закрытии.
   Т.е. если при создании хранилища вы используете эту константу, то при
   закрытии хранилища файл автоматически будет удален}
  stDeleteOnRelease = STGM_DELETEONRELEASE;

  STGC_DEFAULT                              = 0;
  STGC_OVERWRITE                            = 1;
  STGC_ONLYIFCURRENT                        = 2;
  STGC_DANGEROUSLYCOMMITMERELYTODISKCACHE   = 4;
  STGC_CONSOLIDATE                          = 8; 

const
  GWF_PARENT  = 0;
  GWF_CURRENT = 1;

//==============================================================================
//
//                  Оболочка для Структуированного Хранилища
//
//==============================================================================

{ TOleStream }

type
  TOleStream = class; 
  POleStream = TOleStream;
  TOleStream = class(TDebug)
  private
    FStream: IStream;
  protected
    function GetIStream: IStream;
  public
    constructor Create(const Stream: IStream);
    function Read(var Buffer; Count: Longint): Longint;
    function Write(const Buffer; Count: Longint): Longint;
    function Seek(Offset: Longint; Origin: Word): Longint;
    procedure Stat(AStatStg: PStatStg);
    function GetSize: DWORD;
    procedure SetSize(NewSize: DWORD);          
    property Size: DWORD read GetSize write SetSize;
  end;

  TSPath = array of WideString;

{ TSCustomStg }

  TSCustomStg = class; 
  PSCustomStg = TSCustomStg; 
  TSCustomStg = class(TDebug)
  private
    FName: WideString;
    FStorage: IStorage;
  protected
  public
    constructor Create(const AName: WideString; AStorage: IStorage);
    destructor Destroy; override;
    property Name: WideString read FName;
  end;

{ TSStgFolder }

  TSStgFolder = class;
  PSStgFolder = TSStgFolder; 
  TSStgFolder = class(TSCustomStg)
  private
    FParent: TSCustomStg;
  protected
    property Parent: TSCustomStg read FParent write FParent;
  public
    destructor Destroy; override;
  end;

{ TSStgFile }

  TSStgFile = class; 
  PSStgFile = TSStgFile; 
  TSStgFile = class(TOleStream)
  private
    FParent: TSCustomStg;
  protected
    property Parent: TSCustomStg read FParent write FParent;
  public
    destructor Destroy; override;
  end;

{ TSStorage }

  TSStorage = class; 
  PSStorage = TSStorage; 
  TSStorage = class(TSCustomStg)
  private
  protected
  public
    {создает или открывает файл-хранилище - аналогично TFileStream.Create}
    constructor Create(const FileName: WideString; Mode: Longint);
    {создает новую "подпапку" в хранилище}
    function StgCreateFolder(const AName: WideString): Boolean;
    {создает новый "файл" в хранилище}
    function StgCreateFile(const AName: WideString): TOleStream;
    {открывает существующий "файл" в хранилище}
    function StgOpenFile(const AName: WideString): TOleStream;
    {проверяет существует ли такой путь}
    function StgPathExists(const AName: WideString): Boolean;
    {получает имя "хранилища"}  
    function GetStgName: WideString;
    {получает "папку" верхнего уровня}
    function GetWorkFolder(const APath: TSPath; var Folder: TSStgFolder; WorkFolder: integer = GWF_PARENT): Boolean;
    {удаляет элемент}
    function InternalDeleteElement(const AName: WideString): Boolean; 
    {переименовывает элемент}
    function InternalRenameElement(const OldName, NewName: WideString): Boolean;
    {пересылает/копирует элемент}
    function InternalMoveElementTo(const OldName, NewName: WideString; Mode: Dword): Boolean;
  end;

{освобождает занимаемое удаленными файлами место}
function StoragePack(const FileName: WideString): Boolean;
{объединение хранилищ}
function StorageMerge(const SrcFileName, DstFileName: WideString): Boolean;
{получает массив имен пути}
procedure GetSPath(const APath: WideString; var ASPath: TSPath);
function WideStringToString(const ws: WideString): String;
function StringToWideString(const s: String): WideString;
function AnsiCompareTextW(const S1, S2: WideString): Integer;
function _CreateFolder(const AName: WideString; AStorage: IStorage; var AStg: IStorage): Boolean;
function _OpenFolder(const AName: WideString; AStorage: IStorage; var AStg: IStorage): Boolean;
function _DestroyElement(const AName: WideString; AStorage: IStorage): Boolean;
function _RenameElement(const OldName, NewName: WideString; AStorage: IStorage): Boolean;
function _MoveElementTo(const SrcName, DestName: WideString; SrcStorage, DestStorage: IStorage; Mode: DWORD): Boolean;
function _CopyElementTo(const SrcName, DestName: WideString; SrcStorage, DestStorage: IStorage): Boolean;
function _ElementExists(AStorage: IStorage; const AName: WideString; AStatStg: PStatStg): Boolean;

//******************************************************************************
//==============================================================================
//
//                    Объявление главного класса компонента
//
//==============================================================================
//******************************************************************************

type
  PCardinal = ^cardinal;
  TISStorage_DS = record
    GetFRootStorage: function: TSStorage of object;
    GetFRootFolder: function: IStorage of object;
    GetFStorage: function(Storage: TSStgFolder): IStorage of object;
    CloseRootStorage: procedure of object;
    EventError: procedure(Err: Word) of object;
  end;
  PISStorage_DS = ^TISStorage_DS;

type
 THiSStorage_DS = class(TDebug)
   private
     sstg: TISStorage_DS;
     FRootStorage: TSStorage;
     procedure CloseRootStorage;
     function GetFRootStorage: TSStorage;
     function GetFRootFolder: IStorage;
     function GetFStorage(Storage: TSStgFolder): IStorage;          
     procedure EventError(Err: Word);
   public
     _prop_Name,
     _prop_StgFilePath: string; 

     onGetSizeElement,
     _event_onOpenStorage,
     onEndPackStorage,
     onLoadFileFromStg,
     onError,
     IsCurrentStgPack,
     SrcStream,
     InFilePath,
     InNewFilePath,
     NewFileName,
     PackStgFilePath,
     _data_StgFilePath,
     _event_onError: THI_Event;
     destructor Destroy; override;
     procedure _work_doOpenStorage(var _Data: TData; Index: Word);
     procedure _work_doCloseStorage(var _Data: TData; Index: Word);     
     function getinterfaceSStorage_DS: PISStorage_DS ;                 
 end;

//==============================================================================

implementation

//==============================================================================
//
//    Конвертирует Unicode в AnsiString, используя текущую кодовую страницу
//
//==============================================================================

function WideStringToString(const ws: WideString): String;
var
  l: integer;
begin
  if ws = '' then
    Result := ''
  else
  begin
    l := WideCharToMultiByte(CP_ACP, WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR, PWChar(ws), -1, nil, 0, nil, nil);
    SetLength(Result, l - 1);
    if l > 1 then
      WideCharToMultiByte(CP_ACP, WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR, PWChar(ws), -1, PChar(Result), l - 1, nil, nil);
  end;
end;

//==============================================================================
//
//    Конвертирует AnsiString в Unicode, используя текущую кодовую страницу
//
//==============================================================================

function StringToWideString(const s: String): WideString;
var
  l: integer;
begin
  if s = '' then
    Result := ''
  else
  begin
    l := MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, PChar(s), -1, nil, 0);
    SetLength(Result, l - 1);
    if l > 1 then
      MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, PChar(s), -1, PWChar(Result), l - 1);
  end;
end;

//==============================================================================
//
//                        Сравнивает две строки в Unicode
//
//==============================================================================

function AnsiCompareTextW(const S1, S2: WideString): Integer;
begin
  Result := CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PWChar(S1), -1, PWChar(S2), -1 ) - 2;
end;

//==============================================================================

{ TOleStream }

function TOleStream.Read(var Buffer{: Pointer}; Count: Longint): Longint;
begin
  OleCheck(FStream.Read(Pointer(Buffer), Count, @Result));
end;

function TOleStream.Seek(Offset: Longint; Origin: Word): Longint;
//  For Origin
//  STREAM_SEEK_SET = 0;
//  STREAM_SEEK_CUR = 1;
//  STREAM_SEEK_END = 2;
var
  Pos: Largeint;
begin
  OleCheck(FStream.Seek(Offset, Origin, Pos));
  Result := Longint(Pos);
end;

function TOleStream.Write(const Buffer{: Pointer}; Count: Longint): Longint;
begin
  OleCheck(FStream.Write(Pointer(Buffer), Count, @Result));
end;

function TOleStream.GetIStream: IStream;
begin
  Result := FStream;
end;

procedure TOleStream.Stat(AStatStg: PStatStg);
var
  StatStg: TStatStg; 
begin
  OleCheck(FStream.Stat(StatStg, STATFLAG_DEFAULT));
  if AStatStg <> nil then Move(StatStg, AStatStg^, SizeOf(TStatStg));  
end;  

procedure TOleStream.SetSize(NewSize: DWORD);
var
  sSize: int64; 
begin
  i64(sSize).Lo := NewSize;  
  OleCheck(FStream.SetSize(sSize));
end;

function TOleStream.GetSize: DWORD;
var
  StatStg: TStatStg;
begin
  OleCheck(FStream.Stat(StatStg, STATFLAG_DEFAULT));
  Result := i64(StatStg.cbSize).Lo;  
end;    

constructor TOleStream.Create(const Stream: IStream);
begin
  FStream := Stream;
end;

//==============================================================================

function StoragePack(const FileName: WideString): Boolean;
var
  Bool: Boolean;
  TmpFile: WideString;
  Stg, Temp: IStorage;

  procedure GetTmpFile(var FileName: WideString);
  var
    TmpFile: WideString;
    SystemTime: TSystemTime;
    DateTime:TDateTime;
  begin
    SetLength(TmpFile, MAX_PATH + 1);
    if GetTempFileNameW(PWChar(StringToWideString(ExtractFilePath(ParamStr(0)))), 'stg', 0, PWChar(TmpFile)) = 0 then
      begin
        GetLocalTime(SystemTime);
        SystemTime2DateTime(SystemTime, DateTime);
        FileName := StringToWideString('stg' + Time2StrFmt(Date2StrFmt('yyyyMMdd._ss', DateTime), DateTime));
      end
    else
      FileName := TmpFile;
  end;

begin
  GetTmpFile(TmpFile);
  StgOpenStorage(PWideChar(FileName), nil, stOpen, nil, 0, Stg);
  StgCreateDocFile(PWideChar(TmpFile), stCreate, 0, Temp);
  TRY
    Bool := Stg.CopyTo(0, nil, nil, Temp) = S_OK;
  FINALLY
    Temp := nil;
    Stg := nil;
  end;
  Result := Bool and DeleteFileW(PWChar(FileName)) and MoveFileW(PWChar(TmpFile), PWChar(FileName));
  if not Result then DeleteFileW(PWChar(TmpFile));
end;

//==============================================================================

function StorageMerge(const SrcFileName, DstFileName: WideString): Boolean;
var
  Src, Dst: IStorage;
begin
  StgOpenStorage(PWideChar(SrcFileName), nil, stOpen, nil, 0, Src);
  StgOpenStorage(PWideChar(DstFileName), nil, stOpen, nil, 0, Dst);
  TRY
    Result := Src.CopyTo(0, nil, nil, Dst) = S_OK;
  FINALLY
    Src := nil;
    Dst := nil;
  end;
end;

//==============================================================================

procedure GetSPath(const APath: WideString; var ASPath: TSPath);
var
  i, x, Len: integer;
begin
  ASPath := nil;
  x := 1;
  i := 1;
  Len := Length(APath);
  while i <= Len + 1 do
  begin
    if (Len = 1) and (APath[1] = '\') then
    begin
      SetLength(ASPath, Length(ASPath) + 1);
      ASPath[High(ASPath)] := '';
      break;     
    end; 
    if (i = Len + 1) or (APath[i] = '\') then
    begin
      if i - x > 0 then
      begin
        SetLength(ASPath, Length(ASPath) + 1);
        ASPath[High(ASPath)] := Copy(APath, x, i - x);
      end;
      x := i + 1;
    end;
    i := i + 1;
  end;
end;

function _CreateFolder(const AName: WideString; AStorage: IStorage; var AStg: IStorage): Boolean;
begin
  Result := AStorage.CreateStorage(PWideChar(AName), stCreateFolder, 0, 0, AStg) = S_OK;
end;

function _OpenFolder(const AName: WideString; AStorage: IStorage; var AStg: IStorage): Boolean;
begin
  Result := AStorage.OpenStorage(PWideChar(AName), nil, stOpen, nil, 0, AStg) = S_OK;
end;

function _RenameElement(const OldName, NewName: WideString; AStorage: IStorage): Boolean;
begin
  Result := AStorage.RenameElement(PWideChar(OldName), PWideChar(NewName)) = S_OK;
end;

function _DestroyElement(const AName: WideString; AStorage: IStorage): Boolean;
begin
  Result := AStorage.DestroyElement(PWideChar(AName)) = S_OK;
end;

function _MoveElementTo(const SrcName, DestName: WideString; SrcStorage, DestStorage: IStorage; Mode: DWORD): Boolean;
begin
  Result := SrcStorage.MoveElementTo(PWideChar(SrcName), DestStorage, PWideChar(DestName), Mode) = S_OK;
end;

function _CopyElementTo(const SrcName, DestName: WideString; SrcStorage, DestStorage: IStorage): Boolean;
begin
  Result := SrcStorage.MoveElementTo(PWideChar(SrcName), DestStorage, PWideChar(DestName), STGMOVE_COPY) = S_OK;
end;

function _ElementExists(AStorage: IStorage; const AName: WideString; AStatStg: PStatStg): Boolean;
var
  Enum: IEnumStatStg;
  Data: TStatStg;
begin
  Result := false;
  if AStorage.EnumElements(0, nil, 0, Enum) = S_OK then
  TRY
    while (not Result) and (Enum.Next(1, Data, nil) = S_Ok) do
      Result := AnsiCompareTextW(AName, Data.pwcsName) = 0;
  FINALLY
    Enum := nil;
  END;
  if Result and (AStatStg <> nil) then Move(Data, AStatStg^, SizeOf(TStatStg));
end;

{ TSCustomStg }

constructor TSCustomStg.Create(const AName: WideString; AStorage: IStorage);
begin
  FName := AName;
  FStorage := AStorage;
end;

destructor TSCustomStg.Destroy;
begin
  FStorage := nil;
  inherited;
end;

{ TSStgFile }

destructor TSStgFile.Destroy;
begin
  inherited;
  if (FParent <> nil) and not (FParent is TSStorage) then FParent.Free;
end;

{ TSStgFolder }

destructor TSStgFolder.Destroy;
begin
  inherited;
  FStorage := nil;
  if (FParent <> nil) and not (FParent is TSStorage) then FParent.Free;
end;

{ TSStorage }

constructor TSStorage.Create(const FileName: WideString; Mode: LongInt);
begin
  if Mode = stCreate then
    StgCreateDocfile(PWChar(FileName), Mode, 0, FStorage)
  else
    StgOpenStorage(PWChar(FileName), nil, Mode, nil, 0, FStorage);
  inherited Create(FileName, FStorage);
end;

function TSStorage.GetWorkFolder(const APath: TSPath; var Folder: TSStgFolder; WorkFolder: integer = GWF_PARENT): Boolean;
var
  i: Integer;
  TmpStg: IStorage;
  StatStg: TStatStg;
  ParentStg: TSCustomStg;
  TmpFolder: TSStgFolder;
  len: integer;
begin
  Result := True;

  TmpStg := FStorage;
  ParentStg := Self;
  TmpFolder := nil;

  len := High(APath);
  if WorkFolder = GWF_PARENT then
    len := len - 1;  
  for I := 0 to len do
  begin
    if _ElementExists(TmpStg, APath[I], @StatStg) and (StatStg.dwType = STGTY_STORAGE) and _OpenFolder(APath[I], TmpStg, TmpStg) then
    begin
      TmpFolder := TSStgFolder.Create(APath[I], TmpStg);
      TmpFolder.FParent := ParentStg;
      ParentStg := TmpFolder;
    end
    else
    begin
      Result := False;
      TmpFolder.free;
      break;
    end
  end;
  Folder := TmpFolder;
end;

function TSStorage.GetStgName: WideString;
var
  TmpStg: IStorage;
  StatStg: TStatStg;
  CustomStorage: TSCustomStg;
begin
  CustomStorage := Self;
  TmpStg := CustomStorage.FStorage;
  if TmpStg.Stat(StatStg, STATFLAG_DEFAULT) = S_OK then
    Result := StatStg.pwcsName
  else  
    Result := '';
end;

function TSStorage.InternalRenameElement(const OldName, NewName: WideString): Boolean;
var
  TmpStg: IStorage;
  vPath: TSPath;
  TmpFolder: TSStgFolder;
begin
  GetSPath(OldName, vPath);
  if GetWorkFolder(vPath, TmpFolder) then
  begin
    if TmpFolder <> nil then
      TmpStg := TmpFolder.FStorage
    else
      TmpStg := FStorage;
    Result := _RenameElement(vPath[High(vPath)], NewName, TmpStg);
    if TmpFolder <> nil then TmpFolder.Free;
  end
  else
    Result := False;
end;

function TSStorage.InternalDeleteElement(const AName: WideString): Boolean;
var
  TmpStg: IStorage;
  vPath: TSPath;
  TmpFolder: TSStgFolder;
begin
  GetSPath(AName, vPath);
  if GetWorkFolder(vPath, TmpFolder) then
  begin
    if TmpFolder <> nil then
      TmpStg := TmpFolder.FStorage
    else
      TmpStg := FStorage;
    Result := _DestroyElement(vPath[High(vPath)], TmpStg);
    if TmpFolder <> nil then TmpFolder.Free;
  end
  else
    Result := False
end;

function TSStorage.InternalMoveElementTo(const OldName, NewName: WideString; Mode: Dword): Boolean;
var
  TmpStg, NewStg: IStorage;
  vPath, nPath: TSPath;
  TmpFolder, NewFolder: TSStgFolder;
begin
  GetSPath(OldName, vPath);
  GetSPath(NewName, nPath);
  if GetWorkFolder(vPath, TmpFolder) and GetWorkFolder(nPath, {High(nPath), }NewFolder) then
  begin
    if TmpFolder <> nil then
      TmpStg := TmpFolder.FStorage
    else
      TmpStg := FStorage;
    if NewFolder <> nil then
      NewStg := NewFolder.FStorage
    else
      NewStg := FStorage;

    Result := _MoveElementTo(vPath[High(vPath)], nPath[High(nPath)], TmpStg, NewStg, Mode);
    if NewFolder <> nil then NewFolder.Free;
    if TmpFolder <> nil then TmpFolder.Free;
  end
  else
    Result := False;
end;

function TSStorage.StgPathExists(const AName: WideString): Boolean;
var
  I: Integer;
  vPath: TSPath;

  function DoFind(Stg: IStorage): Boolean;
  var
    TmpStg: IStorage;
    StatStg: TStatStg;
  begin
    if (I = High(vPath)) then
      Result := _ElementExists(Stg, vPath[I], @StatStg)
    else if _ElementExists(Stg, vPath[I], @StatStg) and (StatStg.dwType = STGTY_STORAGE) and _OpenFolder(vPath[I], Stg, TmpStg) then
    begin
      Inc(I);
      Result := DoFind(TmpStg);
    end
    else
      Result := False;
  end;

begin
  I := 0;
  GetSPath(AName, vPath);
  if (vPath <> nil) and (FStorage <> nil) then
    Result := DoFind(FStorage)
  else
    Result := False;
end;

function TSStorage.StgCreateFolder(const AName: WideString): Boolean;
var
  TmpStg: IStorage;
  vPath: TSPath;
  TmpFolder: TSStgFolder;
begin
  GetSPath(AName, vPath);
  if GetWorkFolder(vPath, TmpFolder) then
  begin
    if TmpFolder <> nil then
      TmpStg := TmpFolder.FStorage
    else
      TmpStg := FStorage;
    Result := _CreateFolder(vPath[High(vPath)], TmpStg, TmpStg);
    if TmpFolder <> nil then TmpFolder.Free;
  end
  else
    Result := False;
end;

function TSStorage.StgCreateFile(const AName: WideString): TOleStream;
var
  Strm: IStream;
  TmpStg: IStorage;
  vPath: TSPath;
  TmpFolder: TSStgFolder;
  vBool: Boolean;  
begin
  GetSPath(AName, vPath);
  Result := nil;
  if GetWorkFolder(vPath, TmpFolder) then
  begin
    vBool := TmpFolder <> nil;
    if vBool then
      TmpStg := TmpFolder.FStorage
    else
      TmpStg := FStorage;

      if TmpStg.CreateStream(PWideChar(vPath[High(vPath)]), stCreateFile, 0, 0, Strm) = S_OK then
      begin
        Result := TSStgFile.Create(Strm);
        TSStgFile(Result).Parent := TmpFolder;
      end
      else
        if vBool then TmpFolder.Free;
  end
end;

function TSStorage.StgOpenFile(const AName: WideString): TOleStream;
var
  Strm: IStream;
  TmpStg: IStorage;
  vPath: TSPath;
  TmpFolder: TSStgFolder;
  vBool: Boolean;
begin
  GetSPath(AName, vPath);
  Result := nil;
  if GetWorkFolder(vPath, TmpFolder) then
  begin
    vBool := TmpFolder <> nil;
    if vBool then
      TmpStg := TmpFolder.FStorage
    else
      TmpStg := FStorage;
      if TmpStg.OpenStream(PWideChar(vPath[High(vPath)]), nil, stReadWrite or stShareExclusive, 0, Strm) = S_OK then
      begin
        Result := TSStgFile.Create(Strm);
        TSStgFile(Result).Parent := TmpFolder;
      end
      else
        if vBool then TmpFolder.Free;
  end;
end;

//******************************************************************************
//==============================================================================
//
//                     Методы главного класса компонента
//
//==============================================================================
//******************************************************************************

function THiSStorage_DS.getinterfaceSStorage_DS: PISStorage_DS; 
begin
  sstg.GetFRootStorage := GetFRootStorage;
  sstg.GetFRootFolder := GetFRootFolder;
  sstg.GetFStorage := GetFStorage;
  sstg.CloseRootStorage := CloseRootStorage;
  sstg.EventError := EventError;
  Result := @sstg; 
end;

//==============================================================================

function THiSStorage_DS.GetFRootStorage: TSStorage;
begin
  Result := FRootStorage;
end;

function THiSStorage_DS.GetFRootFolder: IStorage;
begin
  if FRootStorage <> nil then 
    Result := FRootStorage.FStorage
  else  
    Result := nil; 
end;

function THiSStorage_DS.GetFStorage(Storage: TSStgFolder): IStorage;
begin
  Result := Storage.FStorage;
end;     

//==============================================================================
//
//          Закрытие текущего Хранилища и уничтожение экземпляра класса
//
//==============================================================================

procedure THiSStorage_DS.CloseRootStorage;
begin
  if FRootStorage = nil then exit;
  FRootStorage.FStorage._Release;
  free_and_nil(FRootStorage);
end; 

destructor THiSStorage_DS.Destroy;
begin
  CloseRootStorage;
  inherited;
end; 

//==============================================================================
//
//                             Открытие Хранилища
//          если файла хранилища не существует, то он будет создан
//
//==============================================================================

procedure THiSStorage_DS._work_doOpenStorage;
var
  FStgName: WideString;
  Res: HResult;
begin
  FStgName := StringToWideString(ReadString(_Data, _data_StgFilePath));
  if FStgName = '' then
  begin
    EventError(STG_ERROR_INCORRECTFILENAME);
    exit;
  end;  
  CloseRootStorage;
  Res := StgIsStorageFile(PWChar(FStgName));
  case Res of
    S_OK: FRootStorage := TSStorage.Create(PWChar(FStgName), stOpen);
    STG_E_FILENOTFOUND: FRootStorage := TSStorage.Create(PWChar(FStgName), stCreate);
    S_FALSE:
    begin
      EventError(STG_ERROR_FILENOTSTORAGE);
      exit;
    end  
  end;    
  if FRootStorage <> nil then
    _hi_onEvent(_event_onOpenStorage, WideStringToString(FRootStorage.GetStgName))
  else  
    EventError(STG_ERROR_IMPOSSIBLEOPENSTORAGE);
end;

//==============================================================================
//
//                             Закрытие Хранилища
//
//==============================================================================

procedure THiSStorage_DS._work_doCloseStorage;
begin
  CloseRootStorage; 
end;

//==============================================================================
//                         
//                             Выдача события ошибки
//
//==============================================================================

procedure THiSStorage_DS.EventError;
begin
  _hi_onEvent(_event_onError, Err);
end;

//******************************************************************************

end.