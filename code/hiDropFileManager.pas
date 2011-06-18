unit hiDropFileManager;

interface

uses Windows, Kol, Share, Debug, Win, FileDrop;

type
  THIDropFileManager = class(TDebug)
  private
    sControl: PControl;
    FControlManager: IControlManager;
    Wnd: HWnd;
    FDragtype: TDragTypes;
    FDropTarget: TFileDropTarget;
    procedure SetControlManager(Value: IControlManager);  
    procedure SetDropType;  
    procedure OnFilesDropped_(DropInfo: TDragDropInfo);
    procedure OnDragEnter_(grfKeyState: Longint; pt: TPoint);
    procedure OnDragOver_(grfKeyState: Longint; pt: TPoint);
    procedure OnDragLeave_;
  public
    _prop_DropType: byte;
    _event_onDrop: THI_Event;
    _event_onDropEnd: THI_Event;
    _event_onDragEnter: THI_Event;
    _event_onDragOver: THI_Event;
    _event_onDragLeave: THI_Event;
    destructor Destroy; override;
    procedure _work_doListen(var _Data: TData; Index: word);
    procedure _work_doStop(var _Data: TData; Index: word);
    procedure _work_doDropType(var _Data: TData; Index: word);
    property _prop_ControlManager: IControlManager write SetControlManager; 
  end;

implementation

destructor THIDropFileManager.Destroy;
begin
  if Assigned(FDropTarget) then Free_and_nil(FDropTarget);
  inherited Destroy;
end;

procedure THIDropFileManager._work_doStop;
begin
  if Assigned(FDropTarget) then Free_and_nil(FDropTarget);
end;

procedure THIDropFileManager.SetControlManager; 
begin
  if Value = nil then exit; 
  FControlManager := Value;
  sControl := FControlManager.ctrlpoint;
  Wnd := sControl.Handle;
end;

procedure THIDropFileManager._work_doListen;
begin
  if not Assigned(sControl) then exit;
  if not IsWindow(Wnd) then exit;
  { Создаем приемник }
  FDropTarget := TFileDropTarget.Create(Wnd);
  { Определяем обработчики событий }
  FDropTarget.OnFilesDropped := OnFilesDropped_;
  FDropTarget.OnDragEnter := OnDragEnter_;
  FDropTarget.OnDragOver := OnDragOver_;
  FDropTarget.OnDragLeave := OnDragLeave_;
  SetDropType;
end;

procedure THIDropFileManager._work_doDropType;
begin
  if not Assigned(FControlManager) then exit;
  _prop_DropType := ToInteger(_data);
  SetDropType;
 end;

procedure THIDropFileManager.SetDropType;
begin
  if not Assigned(FControlManager) then exit;
    case _prop_DropType of
    0: FDragtype := [dtNone];
    1: FDragtype := [dtCopy];
    2: FDragtype := [dtMove];
    3: FDragtype := [dtLink];
    4: FDragtype := [dtScroll];
    end;
    FDropTarget.Dragtypes := FDragtype;
 end;

procedure THIDropFileManager.OnFilesDropped_;
var i: Integer;
begin
  for i := 0 to DropInfo.Files.Count-1 do
    _hi_onEvent(_event_onDrop, DropInfo.Files.Items[i]);
  _hi_onEvent(_event_onDropEnd, DropInfo.Files.Count);
end;

procedure THIDropFileManager.OnDragEnter_;
begin
  _hi_onEvent(_event_onDragEnter, integer(grfKeyState));
end;

procedure THIDropFileManager.OnDragOver_;
begin
  _hi_onEvent(_event_onDragOver, integer(grfKeyState));
end;

procedure THIDropFileManager.OnDragLeave_;
begin
  _hi_onEvent(_event_onDragLeave);
end;

end.