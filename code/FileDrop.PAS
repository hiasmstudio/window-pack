// FILEDROP.PAS -- реализация простейшего приемника OLE. 
// Автор: Джим Мишель 
// Дата последней редакции: 28/05/97 
// Adapted for HiAsm by Nic. June 2011

unit FileDrop;

interface

uses Windows, ActiveX, kol;
type
  TDragDropInfo = class(TObject)
  private
    FInClientArea: Boolean;
    FDropPoint: TPoint;
    FFileList: PStrList;
  public
    constructor Create (ADropPoint: TPoint; AInClient: Boolean);
    destructor Destroy; override;
    procedure Add(const s: String);
    property InClientArea: Boolean read FInClientArea;
    property DropPoint: TPoint read FDropPoint;
    property Files: PStrList read FFileList;
  end;

  TFileDropEvent = procedure(DDI: TDragDropInfo) of object;
  TDragEvent = procedure(grfKeyState: Longint; pt: TPoint) of object;
  TDragLeaveEvent = procedure() of object;
  TDragType = (dtNone, dtCopy, dtMove, dtLink, dtScroll);
  TDragTypes = set of TDragType;

  { TFileDropTarget знает, как принимать сброшенные файлы }
  TFileDropTarget = class(TInterfacedObject, IDropTarget)
  private
    FHandle: HWND;
    FOnFilesDropped: TFileDropEvent;
    FOnDragEnter: TDragEvent;
    FOnDragOver: TDragEvent;
    FOnDragLeave: TDragLeaveEvent;
    FDragTypes : TDragTypes;
    function DragType(): Longint;
  public
    constructor Create(Handle: HWND);
    destructor Destroy; override;
    { из IDropTarget }
    function DragEnter(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint; var dwEffect: Longint) : HResult; stdcall;
    function DragOver(grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
    function DragLeave: HResult; stdcall;
    function Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
    property OnFilesDropped: TFileDropEvent read FOnFilesDropped write FOnFilesDropped;
    property OnDragEnter: TDragEvent read FOnDragEnter write FOnDragEnter;
    property OnDragOver: TDragEvent read FOnDragOver write FOnDragOver;
    property OnDragLeave: TDragLeaveEvent read FOnDragLeave write FOnDragLeave;
    property Dragtypes: TDragTypes read FDragTypes write FDragTypes;
  end;

implementation

uses ShellAPI;

{ TDragDropInfo }

constructor TDragDropInfo.Create(ADropPoint : TPoint; AInClient : Boolean);
begin
  inherited Create;
  FFileList := NewStrList;
  FDropPoint := ADropPoint;
  FInClientArea := AInClient;
end;

destructor TDragDropInfo.Destroy;
begin
  FFileList.Free;
  inherited Destroy;
end;

procedure TDragDropInfo.Add(const s : String);
begin
  Files.Add(s);
end;

{ TFileDropTarget }

constructor TFileDropTarget.Create(Handle: HWND);
begin
  inherited Create;
  _AddRef;
  FHandle := Handle;
  ActiveX.CoLockObjectExternal(Self, true, false);
  ActiveX.RegisterDragDrop(FHandle, Self);
end;

{ Destroy снимает блокировку с объекта и разрывает связь с ним }
destructor TFileDropTarget.Destroy;
var
  WorkHandle: HWND;
begin
  { Если значение FHandle не равно 0, значит, связь с окном все еще существует. 
    Обратите внимание на то, что FHandle необходимо прежде всего присвоить 0, 
    потому что CoLockObjectExternal и RevokeDragDrop вызывают Release,
    что, в свою очередь, может привести к вызову Free и зацикливанию программы.
    Подозреваю, что этот фрагмент не совсем надежен. Если объект будет
    освобожден до того, как счетчик ссылок упадет до 0, может возникнуть исключение. }
  if (FHandle <> 0) then begin
    WorkHandle := FHandle;
    FHandle := 0;
    ActiveX.CoLockObjectExternal(Self, false, true);
    ActiveX.RevokeDragDrop(WorkHandle);
  end;
  inherited Destroy;
end;

function TFileDropTarget.DragType: Longint;
begin
  result := DROPEFFECT_NONE;
  if (dtCopy in FDragTypes) then result := DROPEFFECT_COPY;
  if (dtMove in FDragTypes) then result := DROPEFFECT_MOVE;
  if (dtLink in FDragTypes) then result := DROPEFFECT_LINK;
  if (dtScroll in FDragTypes) then result := DROPEFFECT_SCROLL;
end;

function TFileDropTarget.DragEnter(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
begin
  { Если указан обработчик, вызываем его }
  if (Assigned(FOnDragEnter)) then FOnDragEnter(grfKeyState, pt);
  dwEffect := DragType;
  Result := S_OK;
end;

function TFileDropTarget.DragOver(grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
begin
  { Если указан обработчик, вызываем его }
  if (Assigned(FOnDragOver)) then FOnDragOver(grfKeyState, pt);
  dwEffect := DragType;
  Result := S_OK;
end;

function TFileDropTarget.DragLeave: HResult; stdcall;
begin
  { Если указан обработчик, вызываем его }
  if (Assigned(FOnDragLeave)) then FOnDragLeave;
  Result := S_OK;
end;

{ Обработка сброшенных данных }
function TFileDropTarget.Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
var
  Medium: TSTGMedium;
  Format: TFormatETC;
  NumFiles: Integer;
  i: Integer;
  rslt: Integer;
  DropInfo: TDragDropInfo;
  szFilename: array[0..MAX_PATH] of char;
  InClient: Boolean;
  DropPoint: TPoint;
begin
  dataObj._AddRef;
  { Получаем данные. Структура TFormatETC сообщает dataObj.GetData, 
    как получить данные и в каком формате они должны храниться 
    (эта информация содержится в структуре TSTGMedium) }
  Format.cfFormat := CF_HDROP;
  Format.ptd := nil;
  Format.dwAspect := DVASPECT_CONTENT;
  Format.lindex := -1;
  Format.tymed := TYMED_HGLOBAL;
  { Заносим данные в структуру Medium }
  rslt := dataObj.GetData(Format, Medium);
  { Если все прошло успешно, далее действуем, как при операции файлового перетаскивания FMDD }
  if (rslt = S_OK) then begin
    { Получаем количество файлов и прочие сведения }
    NumFiles := DragQueryFile(Medium.hGlobal, $FFFFFFFF, nil, 0);
    InClient := DragQueryPoint(Medium.hGlobal, DropPoint);
    { Создаем объект TDragDropInfo }
    DropInfo := TDragDropInfo.Create(DropPoint, InClient);
    { Заносим все файлы в список }
    for i := 0 to NumFiles - 1 do begin
      DragQueryFile(Medium.hGlobal, i, szFilename, sizeof(szFilename));
      DropInfo.Add(szFilename);
    end;
    { Если указан обработчик, вызываем его }
    if (Assigned(FOnFilesDropped)) then FOnFilesDropped(DropInfo);
    DropInfo.Free;
  end;
  if (Medium.unkForRelease = nil) then ReleaseStgMedium(Medium);
  dataObj._Release;
  dwEffect := DragType;
  result := S_OK;
end;

initialization
  OleInitialize(nil);

finalization
  OleUninitialize;

end.
