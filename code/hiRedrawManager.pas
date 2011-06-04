unit hiRedrawManager;

interface
     
uses Messages,Windows,Kol,Share,Debug,Win;

type
  THIRedrawManager = class(TDebug)
   private
   public
     _prop_EraseMode: boolean;
     _prop_ControlManager:IControlManager;
     procedure _work_doRedraw(var _Data:TData; Index:word);
     procedure _work_doBeginUpdate(var _Data: TData; Index: word);
     procedure _work_doEndUpdate(var _Data: TData; Index: word);
  end;

implementation

procedure THIRedrawManager._work_doRedraw;
var
  sControl: PControl;
begin
  if not Assigned(_prop_ControlManager) then exit;
  sControl := _prop_ControlManager.ctrlpoint;
  InvalidateRect(sControl.Handle, nil, _prop_EraseMode);
end;

procedure THIRedrawManager._work_doBeginUpdate;
var
  sControl: PControl;
begin
  if not Assigned(_prop_ControlManager) then exit;
  sControl := _prop_ControlManager.ctrlpoint;
  sControl.BeginUpdate;
end;

procedure THIRedrawManager._work_doEndUpdate;
var
  sControl: PControl;
begin
  if not Assigned(_prop_ControlManager) then exit;
  sControl := _prop_ControlManager.ctrlpoint;
  sControl.EndUpdate;
end;

end.