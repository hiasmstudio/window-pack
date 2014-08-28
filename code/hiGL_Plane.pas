unit hiGL_Plane;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGL_Plane = class(TDebug)
   private
    FNormal:PGLfloat;
    procedure SetNormal(Value:byte);
   public
    _event_onDraw:THI_Event;
    _data_Point1:THI_Event;
    _data_Point2:THI_Event;
    _data_Point3:THI_Event;
    _data_Point4:THI_Event;

    procedure _work_doDraw(var _Data:TData; Index:word);
    property _prop_Normal:byte write SetNormal;
  end;

implementation

procedure THIGL_Plane._work_doDraw;
const p0: array [0..2] of GLfloat = (0, 0, 0);  //fix
var   p1,p2,p3,p4: PGLfloat;
begin
  with ReadData(_Data,_data_Point1,nil) do
   if data_type = data_gl_point3d
    then p1 := PGLfloat(idata)
    else p1 := PGLfloat(integer(@p0[0]));  //fix
  with ReadData(_Data,_data_Point2,nil) do
   if data_type = data_gl_point3d
    then p2 := PGLfloat(idata)
    else p2 := PGLfloat(integer(@p0[0]));  //fix
  with ReadData(_Data,_data_Point3,nil) do
   if data_type = data_gl_point3d
    then p3 := PGLfloat(idata)
    else p3 := PGLfloat(integer(@p0[0]));  //fix
  with ReadData(_Data,_data_Point4,nil) do
   if data_type = data_gl_point3d
    then p4 := PGLfloat(idata)
    else p4 := PGLfloat(integer(@p0[0]));  //fix

  glBegin (GL_QUADS);
   glNormal3fv(FNormal);
   glVertex3fv(p1);
   glVertex3fv(p2);
   glVertex3fv(p3);
   glVertex3fv(p4);
  glEnd;
  _hi_CreateEvent(_Data,@_event_onDraw);
end;

procedure THIGL_Plane.SetNormal;
type
  TNorm = array[0..2] of Single;
  PNorm = ^TNorm;
begin
   getmem(FNormal,sizeof(Single)*3);
   FillChar(FNormal^,sizeof(Single)*3,0);
   case Value of
    0: PNorm(FNormal)^[0] := 1.0;
    1: PNorm(FNormal)^[0] := -1.0;
    2: PNorm(FNormal)^[1] := 1.0;
    3: PNorm(FNormal)^[1] := -1.0;
    4: PNorm(FNormal)^[2] := 1.0;
    5: PNorm(FNormal)^[2] := -1.0;
   end;
end;

end.