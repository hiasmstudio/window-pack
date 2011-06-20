// OLE drop text target
// Adapted for HiAsm by Nic. June 2011
unit TextDrop;

interface

uses Windows, ActiveX, kol;

type
  TTextDropEvent = procedure(text: PChar) of object;
  TDragEvent = procedure(grfKeyState: Longint; pt: TPoint) of object;
  TDragLeaveEvent = procedure() of object;
  TDragType = (dtNone, dtCopy, dtMove, dtLink, dtScroll);
  TDragTypes = set of TDragType;

  TTextDropTarget = class(TInterfacedObject, IDropTarget)
  private
    FHandle: HWND;
    FOnTextDropped: TTextDropEvent;
    FOnDragEnter: TDragEvent;
    FOnDragOver: TDragEvent;
    FOnDragLeave: TDragLeaveEvent;
    FDragTypes : TDragTypes;
    function DragType(): Longint;
  public
    constructor Create(Handle: HWND);
    destructor Destroy; override;
    function DragEnter(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint; var dwEffect: Longint) : HResult; stdcall;
    function DragOver(grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
    function DragLeave: HResult; stdcall;
    function Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
    property OnTextDropped: TTextDropEvent read FOnTextDropped write FOnTextDropped;
    property OnDragEnter: TDragEvent read FOnDragEnter write FOnDragEnter;
    property OnDragOver: TDragEvent read FOnDragOver write FOnDragOver;
    property OnDragLeave: TDragLeaveEvent read FOnDragLeave write FOnDragLeave;
    property Dragtypes: TDragTypes read FDragTypes write FDragTypes;
  end;

implementation

uses ShellAPI;

constructor TTextDropTarget.Create(Handle: HWND);
begin
  inherited Create;
  _AddRef;
  FHandle := Handle;
  ActiveX.CoLockObjectExternal(Self, true, false);
  ActiveX.RegisterDragDrop(FHandle, Self);
end;

destructor TTextDropTarget.Destroy;
var
  WorkHandle: HWND;
begin
  if (FHandle <> 0) then begin
    WorkHandle := FHandle;
    FHandle := 0;
    ActiveX.CoLockObjectExternal(Self, false, true);
    ActiveX.RevokeDragDrop(WorkHandle);
  end;
  inherited Destroy;
end;

function TTextDropTarget.DragType: Longint;
begin
  result := DROPEFFECT_NONE;
  if (dtCopy in FDragTypes) then result := DROPEFFECT_COPY;
  if (dtMove in FDragTypes) then result := DROPEFFECT_MOVE;
  if (dtLink in FDragTypes) then result := DROPEFFECT_LINK;
  if (dtScroll in FDragTypes) then result := DROPEFFECT_SCROLL;
end;

function TTextDropTarget.DragEnter(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
begin
  if (Assigned(FOnDragEnter)) then FOnDragEnter(grfKeyState, pt);
  dwEffect := DragType;
  Result := S_OK;
end;

function TTextDropTarget.DragOver(grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
begin
  if (Assigned(FOnDragOver)) then FOnDragOver(grfKeyState, pt);
  dwEffect := DragType;
  Result := S_OK;
end;

function TTextDropTarget.DragLeave: HResult; stdcall;
begin
  if (Assigned(FOnDragLeave)) then FOnDragLeave;
  Result := S_OK;
end;

function TTextDropTarget.Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
var
  Medium: TSTGMedium;
  Format: TFormatETC;
begin
  dataObj._AddRef;
  Format.cfFormat := CF_TEXT;
  Format.ptd := nil;
  Format.dwAspect := DVASPECT_CONTENT;
  Format.lindex := -1;
  Format.tymed := TYMED_HGLOBAL;
  if dataObj.GetData(Format, Medium) = S_OK then begin
    Assert(Medium.tymed = Format.tymed);
    if (Assigned(FOnTextDropped)) then FOnTextDropped(GlobalLock(Medium.hGlobal));
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
