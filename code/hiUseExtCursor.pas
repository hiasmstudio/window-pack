unit hiUseExtCursor;

interface

uses Windows, Kol, Share, Debug, Win;

type
  THIUseExtCursor = class(TDebug)
  private
    sControl: PControl;
    oldCursor: HCursor;
    hCursor:  HCursor; 
    FControlManager: IControlManager;
    procedure SetControlManager(Value: IControlManager);  
  public

   _prop_FileCurName: string;
   _prop_ResetOnDestroy: boolean;

   _data_FileCurName: THI_Event;
   _event_onSetCursor: THI_Event;

    destructor Destroy; override;
    property _prop_ControlManager: IControlManager write SetControlManager; 
    procedure _work_doSetCursor(var _Data: TData; Index: word);
    procedure _work_doResetCursor(var _Data: TData; Index: word);
  end;

implementation

destructor THIUseExtCursor.Destroy;
begin
// Возвращаем старый курсор
  if Assigned(sControl) and _prop_ResetOnDestroy then
    sControl.Cursor := oldCursor;
  DestroyCursor(hCursor);
  inherited;
end;

procedure THIUseExtCursor._work_doSetCursor;
begin
  if not Assigned(FControlManager) then exit;
  DestroyCursor(hCursor);
  hCursor := LoadCursorFromFile(PChar(ReadString(_Data, _data_FileCurName, _prop_FileCurName)));
  sControl.Cursor := hCursor;
  _hi_CreateEvent(_Data, @_event_onSetCursor); 
end;

procedure THIUseExtCursor._work_doResetCursor;
begin
  if not Assigned(FControlManager) then exit;
  sControl.Cursor := oldCursor;
  DestroyCursor(hCursor);
end;

procedure THIUseExtCursor.SetControlManager; 
begin
  if Value = nil then exit; 
  FControlManager := Value;
  sControl := FControlManager.ctrlpoint;
  oldCursor := sControl.Cursor;
end;

end.