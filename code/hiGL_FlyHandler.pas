// Основа кода
// eXgine v0.80
// Author : XProger
unit hiGL_FlyHandler;

interface

uses windows,kol,Share,Debug,OpenGL;

type
   TVector3f = record
   X, Y, Z: Single;
end;

TVector2f = record
X, Y: Single;
end;

TVector   = TVector3f;
TVector2D = TVector2f;
TVec2f = TVector2f;
TVec3f = TVector3f;

const
   deg2rad = pi / 180;
   rad2deg = 180 / pi;

var
   Pos   : TVector;
   Angle : TVector;
   m_delta  : TVector2f;

type
   THIGL_FlyHandler = class(TDebug)
   private
   forwardkey, backkey, leftkey, rightkey: integer;
   h:integer;

   public

   _prop_KeySensitive:real;
   _prop_MouseSensitive:real;
   _prop_AngleLimiter:integer;
   _prop_LimiterTopAngle:real;
   _prop_LimiterBottomAngle:real;
   _prop_Enabled:boolean;
   _prop_RelocationMode:boolean;
   _prop_glLoadIdentity:boolean;
   _prop_SetPosCamX:real;
   _prop_SetPosCamY:real;
   _prop_SetPosCamZ:real;
   _prop_SetAngleCamX:real;
   _prop_SetAngleCamY:real;
   _prop_SetAngleCamZ:real;
   _prop_KeyForward:integer;
   _prop_KeyBack:integer;
   _prop_KeyLeft:integer;
   _prop_KeyRight:integer;

   _data_Handle:THI_Event;
   _data_KeySensitive:THI_Event;
   _data_MouseSensitive:THI_Event;
   _data_SetPosCamX:THI_Event;
   _data_SetPosCamY:THI_Event;
   _data_SetPosCamZ:THI_Event;
   _data_SetAngleCamX:THI_Event;
   _data_SetAngleCamY:THI_Event;
   _data_SetAngleCamZ:THI_Event;
   _data_KeyForward:THI_Event;
   _data_KeyBack:THI_Event;
   _data_KeyLeft:THI_Event;
   _data_KeyRight:THI_Event;
   
   _event_onFly:THI_Event;
   _event_onSetPosition:THI_Event;
   _event_onUpdate:THI_Event;

procedure _work_doSetPosition(var _Data:TData; Index:word);
procedure _work_doUpdate(var _Data:TData; Index:word);
procedure _work_doFly(var _Data:TData; Index:word);
procedure _work_doEnabled(var _Data:TData; Index:word);
procedure _work_doRelocationMode(var _Data:TData; Index:word);
procedure _var_CameraX(var _Data:TData; Index:word);
procedure _var_CameraY(var _Data:TData; Index:word);
procedure _var_CameraZ(var _Data:TData; Index:word);
procedure _var_AngleX(var _Data:TData; Index:word);
procedure _var_AngleY(var _Data:TData; Index:word);
end;

implementation

//function--------------------------------------------
function MDelta: TVector2f;
begin
   Result := m_delta;
end;

function Create_(X, Y, Z: Single): TVector3f; overload;
begin
   Result.X := X;
   Result.Y := Y;
   Result.Z := Z;
end;

function Add(v1, v2: TVector3f): TVector3f;
begin
   Result.X := v1.X + v2.X;
   Result.Y := v1.Y + v2.Y;
   Result.Z := v1.Z + v2.Z;
end;

function Length(v: TVector3f): Single;
begin
   Result := sqrt(sqr(v.X) + sqr(v.Y) + sqr(v.Z));
end;

function Mult(v: TVector3f; x: Single): TVector3f;
begin
   Result.X := v.X * x;
   Result.Y := v.Y * x;
   Result.Z := v.Z * x;
end;

function Normalize(v: TVector3f): TVector3f;
var
   len : Single;
begin
   len := Length(v);
   if len <> 0 then
   Result := Mult(v, 1/len)
   else
   Result := v;
end;

function Cross(v1, v2: TVector3f): TVector3f;
begin
   Result.X := v1.Y * v2.Z - v1.Z * v2.Y;
   Result.Y := v1.Z * v2.X - v1.X * v2.Z;
   Result.Z := v1.X * v2.Y - v1.Y * v2.X;
end;

function Sub(v1, v2: TVector3f): TVector3f;
begin
   Result.X := v1.X - v2.X;
   Result.Y := v1.Y - v2.Y;
   Result.Z := v1.Z - v2.Z;
end;
//end function----------------------------------------

procedure THIGL_FlyHandler._work_doSetPosition;

var
   SetPosCamX,SetPosCamY,SetPosCamZ : Real;
   SetAngleCamX,SetAngleCamY,SetAngleCamZ : Real;
begin
   // установка позиции и угла поворота камеры
   SetPosCamX := ReadReal(_Data,_data_SetPosCamX,_prop_SetPosCamX);
   SetPosCamY := ReadReal(_Data,_data_SetPosCamY,_prop_SetPosCamY);
   SetPosCamZ := ReadReal(_Data,_data_SetPosCamZ,_prop_SetPosCamZ);
   SetAngleCamX := ReadReal(_Data,_data_SetAngleCamX,_prop_SetAngleCamX);
   SetAngleCamY := ReadReal(_Data,_data_SetAngleCamY,_prop_SetAngleCamY);
   SetAngleCamZ := ReadReal(_Data,_data_SetAngleCamZ,_prop_SetAngleCamZ);
   m_delta.X := 0;
   m_delta.Y := 0;
   Pos   := Create_(SetPosCamX,SetPosCamY,SetPosCamZ);
   Angle := Create_(SetAngleCamX,SetAngleCamY,SetAngleCamZ);
   _hi_onEvent(_event_onSetPosition,SetPosCamX);
end;

procedure THIGL_FlyHandler._work_doFly;
begin
   // применяем к матрице вида преобразования по параметрам камеры
   if _prop_glLoadIdentity then glLoadIdentity;
   glRotatef(Angle.Z, 0, 0, 1);
   glRotatef(Angle.X, 1, 0, 0);
   glRotatef(Angle.Y, 0, 1, 0);
   glTranslatef(-Pos.X, -Pos.Y, -Pos.Z);
   _hi_onEvent(_event_onFly);
end;

procedure THIGL_FlyHandler._work_doUpdate;
var
   Rect : TRect;
   PosCur  : Windows.TPoint;
   Speed : TVector;
   s, c  : Single;
   Dir   : TVector;
   MAX_SPEED : Real;
   MouseSensitive : Real;
   LimiterTopAngle : Real;
   LimiterBottomAngle : Real;
   
begin
   if not _prop_Enabled then exit;
   // устанавливаем курсор по центру окна, вычисляем смещение курсора
   //относительно центра (m_delta)
   h := ReadInteger(_Data,_data_handle,0);
   GetWindowRect(h, Rect);
   GetCursorPos(PosCur);
   m_delta.X := PosCur.X - Rect.Left - (Rect.Right - Rect.Left) div 2;
   m_delta.Y := PosCur.Y - Rect.Top  - (Rect.Bottom - Rect.Top) div 2;
   SetCursorPos(Rect.Left + (Rect.Right - Rect.Left) div 2, Rect.Top + (Rect.Bottom - Rect.Top) div 2);
   //-----------------------------------------------------------------
   MouseSensitive := ReadReal(_Data,_data_MouseSensitive,_prop_MouseSensitive);
   // осуществляем поворот головы мышью :)
   Angle.X := Angle.X + MDelta.Y * MouseSensitive;
   Angle.Y := Angle.Y + MDelta.X * MouseSensitive;
   // ограничение угла поворота (вниз/вверх)
   if Angle.X < (-(_prop_LimiterTopAngle)) then Angle.X := (-(_prop_LimiterTopAngle)); //вверх
   if Angle.X > (_prop_LimiterBottomAngle) then Angle.X := (_prop_LimiterBottomAngle); //вниз
   // проверяем нажатие клавиш управляющих движением
   forwardkey := byte(GetKeyState (Readinteger(_data,_data_keyforward,_prop_keyforward))<0);
   backkey    := byte(GetKeyState (Readinteger(_data,_data_keyback,_prop_keyback))<0);
   leftkey    := byte(GetKeyState (Readinteger(_data,_data_keyleft,_prop_keyleft))<0);
   rightkey   := byte(GetKeyState (Readinteger(_data,_data_keyright,_prop_keyright))<0);
   MAX_SPEED  := ReadReal(_Data,_data_KeySensitive,_prop_KeySensitive);
   // выбираем режим перемещения
   if _prop_RelocationMode then begin
      // летим куда хотим
      Dir.X := sin(pi - Angle.Y * deg2rad) * cos(Angle.X * deg2rad);
      Dir.Y := -sin(Angle.X * deg2rad);
      Dir.Z := cos(pi - Angle.Y * deg2rad) * cos(Angle.X * deg2rad);
      Speed := Create_(0, 0, 0);
      // проверяем нажатие клавиш управляющих движением
      if (forwardkey = 1) then Speed := Add(Speed, Dir);
      if (backkey = 1)    then Speed := Sub(Speed, Dir);
      if (rightkey = 1)   then Speed := Add(Speed, Normalize(Cross(Dir, Create_(0, 1, 0))));
      if (leftkey = 1)    then Speed := Sub(Speed, Normalize(Cross(Dir, Create_(0, 1, 0))));
      Pos := Add(Pos, Mult(Normalize(Speed), MAX_SPEED));
   end
   else
   begin
      // топаем куда хотим
      Speed := Create_(0, 0, 0);
      if (forwardkey = 1) then Speed := Add(Speed, Create_( 0, 0, -1));
      if (backkey = 1)    then Speed := Add(Speed, Create_( 0, 0,  1));
      if (leftkey = 1)    then Speed := Add(Speed, Create_(-1, 0,  0));
      if (rightkey = 1)   then Speed := Add(Speed, Create_( 1, 0,  0));
      // скорость перемещения
      Speed := Mult(Normalize(Speed), MAX_SPEED);
      // изменяем текущую позицию
      s := sin(Angle.Y * deg2rad);
      c := cos(Angle.Y * deg2rad);
      with Speed do
      Pos := Add(Pos, Create_(X * c - Z * s, 0, X * s + Z * c));
   end;
   _hi_onEvent(_event_onUpdate);
end;

procedure THIGL_FlyHandler._var_CameraX;
begin
   dtReal(_Data, Pos.X);
end;

procedure THIGL_FlyHandler._var_CameraY;
begin
   dtReal(_Data, Pos.Y);
end;

procedure THIGL_FlyHandler._var_CameraZ;
begin
   dtReal(_Data, Pos.Z);
end;

procedure THIGL_FlyHandler._var_AngleX;
begin
   dtReal(_Data, Angle.X);
end;

procedure THIGL_FlyHandler._var_AngleY;
begin
   dtReal(_Data, Angle.Y);
end;

procedure THIGL_FlyHandler._work_doEnabled;
begin
   _prop_Enabled := ReadBool(_Data);
end;

procedure THIGL_FlyHandler._work_doRelocationMode;
begin
   _prop_RelocationMode := ReadBool(_Data);
end;

end.

