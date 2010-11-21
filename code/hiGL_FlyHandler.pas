unit hiGL_FlyHandler;

interface

uses windows,Kol,Share,Debug,OpenGL,win;

type
  THIGL_FlyHandler = class(TDebug)
   private
    a1,a2,px,py,pz,mx,my,x,y:real;
   public
    _prop_KeySensitive:real;
    _prop_MouseSensitive:real;
    _prop_AngleLimiter:integer;
    _prop_VerticalAngleUp:real;
    _prop_VerticalAngleDown:real;
    _prop_ControlManager:IControlManager;
    _prop_Enabled:boolean;
    
    _data_X:THI_Event;
    _data_Y:THI_Event;

    _event_onFly:THI_Event;

    procedure _work_doFly(var _Data:TData; Index:word);
    procedure _work_doMouseMove(var _Data:TData; Index:word);
    procedure _work_doKeyPress(var _Data:TData; Index:word);
    procedure _work_doKeyRelease(var _Data:TData; Index:word);
    procedure _work_doEnabled(var _Data:TData; Index:word);
    procedure _var_CameraX(var _Data:TData; Index:word);
    procedure _var_CameraY(var _Data:TData; Index:word);
    procedure _var_CameraZ(var _Data:TData; Index:word);
    procedure _var_HorizontalAngel(var _Data:TData; Index:word);
    procedure _var_VerticalAngel(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_FlyHandler._work_doFly;
begin
  glRotated(a1, 0.0, cos(-a2/180*pi), 0.0);
  glRotated(a2*cos(-a1/180*pi), 1.0, 0.0, 0.0);
  glRotated(a2*sin(a1/180*pi), 0.0, 0.0, 1.0);
  glTranslatef(px, py, pz);
  _hi_onEvent(_event_onFly, cos(-a1/180*pi))
end;

procedure THIGL_FlyHandler._work_doMouseMove;
var dy:real;
    pos:TPoint;
    sControl:PControl;
begin
  if not _prop_Enabled then exit;
  
  sControl := _prop_ControlManager.ctrlpoint;
  x := ReadInteger(_data,_data_X);  
  y := ReadInteger(_data,_data_Y);
  if(x = mx)and(y = my)then exit;
  mx := sControl.clientwidth / 2;
  my := sControl.clientheight / 2;
  a1 := a1 + _prop_MouseSensitive*(x - mx);
  
  dy := _prop_MouseSensitive*(y - my); 
  if(_prop_AngleLimiter = 1) or (a2 + dy > _prop_VerticalAngleDown)and(a2 + dy < _prop_VerticalAngleUp) then
     a2 := a2 + dy;
  
  pos := sControl.client2screen(makepoint(Round(mx), round(my)));
  mx := x;
  my := y;
  SetCursorPos(pos.x, pos.y); 
end;

procedure THIGL_FlyHandler._work_doKeyPress;
begin
  case ToInteger(_data) of
    87:
     if _prop_Enabled then
      begin
        pz := pz + _prop_KeySensitive*cos(-a1/180*pi);
        py := py - _prop_KeySensitive*sin(-a2/180*pi);
        px := px + _prop_KeySensitive*sin(-a1/180*pi);
      end;
    83:
     if _prop_Enabled then
      begin
        pz := pz - _prop_KeySensitive*cos(-a1/180*pi);
        py := py + _prop_KeySensitive*sin(-a2/180*pi);
        px := px - _prop_KeySensitive*sin(-a1/180*pi);
      end; 
    65:
     if _prop_Enabled then
      begin
        px := px + _prop_KeySensitive*cos(a1/180*pi);
        pz := pz + _prop_KeySensitive*sin(a1/180*pi);
      end;
    68:
     if _prop_Enabled then
      begin
        px := px - _prop_KeySensitive*cos(a1/180*pi);
        pz := pz - _prop_KeySensitive*sin(a1/180*pi);
      end;
    27: _prop_Enabled := not _prop_Enabled;
  end;
end;

procedure THIGL_FlyHandler._work_doKeyRelease;
begin

end;

procedure THIGL_FlyHandler._var_CameraX;
begin
   dtReal(_Data, px);
end;

procedure THIGL_FlyHandler._var_CameraY;
begin
   dtReal(_Data, py);
end;

procedure THIGL_FlyHandler._var_CameraZ;
begin
   dtReal(_Data, pz);
end;

procedure THIGL_FlyHandler._var_HorizontalAngel;
begin
   dtReal(_Data, a1);
end;

procedure THIGL_FlyHandler._var_VerticalAngel;
begin
   dtReal(_Data, a2);
end;

procedure THIGL_FlyHandler._work_doEnabled(var _Data:TData; Index:word);
begin
  _prop_Enabled := ToInteger(_Data) <> 0;
end;

end.
