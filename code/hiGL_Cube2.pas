unit hiGL_Cube2;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGL_Cube2 = class(TDebug)
   private
   public

    _data_Point2:THI_Event;
    _data_Point1:THI_Event;
    _event_onDraw:THI_Event;

    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_Cube2._work_doDraw;
type TPoint3D = array[0..2]of GlFloat;
     PPoint3D = ^TPoint3D;
var p1,p2:PPoint3D;
begin
  with ReadData(_Data,_data_Point1,nil) do
   if data_type = data_gl_point3d then
    p1 := PPoint3D(idata);
  with ReadData(_Data,_data_Point2,nil) do
   if data_type = data_gl_point3d then
    p2 := PPoint3D(idata);

  glBegin (GL_QUADS);
   glNormal3f(0.0,0.0,-1.0);
   glVertex3f(p1[0], p1[1], p1[2]);
   glVertex3f(p2[0], p1[1], p1[2]);
   glVertex3f(p2[0], p2[1], p1[2]);
   glVertex3f(p1[0], p2[1], p1[2]);
  glEnd;

  glBegin (GL_QUADS);
   glNormal3f(0.0,0.0,1.0);
   glVertex3f(p1[0], p1[1], p2[2]);
   glVertex3f(p2[0], p1[1], p2[2]);
   glVertex3f(p2[0], p2[1], p2[2]);
   glVertex3f(p1[0], p2[1], p2[2]);
  glEnd;
   
  glBegin (GL_QUADS);
   glNormal3f(-1.0,0.0,0.0);
   glVertex3f(p1[0], p1[1], p1[2]);
   glVertex3f(p1[0], p2[1], p1[2]);
   glVertex3f(p1[0], p2[1], p2[2]);
   glVertex3f(p1[0], p1[1], p2[2]);
  glEnd;

  glBegin (GL_QUADS);
   glNormal3f(1.0,0.0,0.0);
   glVertex3f(p2[0], p1[1], p1[2]);
   glVertex3f(p2[0], p2[1], p1[2]);
   glVertex3f(p2[0], p2[1], p2[2]);
   glVertex3f(p2[0], p1[1], p2[2]);
  glEnd;

  glBegin (GL_QUADS);
   glNormal3f(0.0,-1.0,0.0);
   glVertex3f(p1[0], p1[1], p1[2]);
   glVertex3f(p2[0], p1[1], p1[2]);
   glVertex3f(p2[0], p1[1], p2[2]);
   glVertex3f(p1[0], p1[1], p2[2]);
  glEnd;

  glBegin (GL_QUADS);
   glNormal3f(0.0,1.0,0.0);
   glVertex3f(p1[0], p2[1], p1[2]);
   glVertex3f(p2[0], p2[1], p1[2]);
   glVertex3f(p2[0], p2[1], p2[2]);
   glVertex3f(p1[0], p2[1], p2[2]);
  glEnd;

  _hi_CreateEvent(_Data,@_event_onDraw);
end;

end.
