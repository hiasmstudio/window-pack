unit hiDropTextManager;

interface

uses Windows, Kol, Share, Debug, Win, TextDrop;

type
  THIDropTextManager = class(TDebug)
  private
    sControl: PControl;
    FControlManager: IControlManager;
    Wnd: HWnd;
    FDragtype: TDragTypes;
    FDropTarget: TTextDropTarget;
    procedure SetControlManager(Value: IControlManager);  
    procedure SetDropType;  
    procedure OnTextDropped_(Text: PChar);
    procedure OnDragEnter_(grfKeyState: Longint; pt: TPoint);
    procedure OnDragOver_(grfKeyState: Longint; pt: TPoint);
    procedure OnDragLeave_;
    function StrPas(const Str: PChar): string; 
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

destructor THIDropTextManager.Destroy;
begin
  if Assigned(FDropTarget) then Free_and_nil(FDropTarget);
  inherited Destroy;
end;

procedure THIDropTextManager._work_doStop;
begin
  if Assigned(FDropTarget) then Free_and_nil(FDropTarget);
end;

procedure THIDropTextManager.SetControlManager; 
begin
  if Value = nil then exit; 
  FControlManager := Value;
  sControl := FControlManager.ctrlpoint;
  Wnd := sControl.Handle;
end;

procedure THIDropTextManager._work_doListen;
begin
  if not Assigned(sControl) then exit;
  if not IsWindow(Wnd) then exit;
  { Создаем приемник }
  FDropTarget := TTextDropTarget.Create(Wnd);
  { Определяем обработчики событий }
  FDropTarget.OnTextDropped := OnTextDropped_;
  FDropTarget.OnDragEnter := OnDragEnter_;
  FDropTarget.OnDragOver := OnDragOver_;
  FDropTarget.OnDragLeave := OnDragLeave_;
  SetDropType;
end;

procedure THIDropTextManager._work_doDropType;
begin
  if not Assigned(FControlManager) then exit;
  _prop_DropType := ToInteger(_data);
  SetDropType;
 end;

procedure THIDropTextManager.SetDropType;
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

procedure THIDropTextManager.OnTextDropped_;
begin
  _hi_onEvent(_event_onDrop, StrPas(Text));
end;

procedure THIDropTextManager.OnDragEnter_;
begin
  _hi_onEvent(_event_onDragEnter, integer(grfKeyState));
end;

procedure THIDropTextManager.OnDragOver_;
begin
  _hi_onEvent(_event_onDragOver, integer(grfKeyState));
end;

procedure THIDropTextManager.OnDragLeave_;
begin
  _hi_onEvent(_event_onDragLeave);
end;

function THIDropTextManager.StrPas(const Str: PChar): string; 
begin 
   Result := Str; 
end;

end.