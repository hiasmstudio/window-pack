unit hiGL_ShaParse;

interface

uses Kol,Share,Debug,OpenGL,DGlut;

type
  THIGL_ShaParse = class(TDebug)
   private

   public
    _prop_FileName:string;

    _data_FileName:THI_Event;
    _event_onDraw:THI_Event;
    _event_onParse:THI_Event;

    procedure _work_doParse(var _Data:TData; Index:word);
    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

procedure DrawCube(x1,y1,x2,y2:real);
type TPoint3D = array[0..2]of Single;
var p1,p2:TPoint3D;
begin
  p1[0] := x1;
  p1[1] := y1;
  p1[2] := 0;

  p2[0] := x2;
  p2[1] := y2;
  p2[2] := 0.04;

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
end;

procedure THIGL_ShaParse._work_doParse;
const Scale = 200;
var lst:PStrList;
    i:integer;
    a,b,c,d:real;
    s:string;
begin
    glNewList(1020,GL_COMPILE);
    glPushMatrix;
    glTranslatef(-1,-1,0);
    lst := NewStrList;
    lst.LoadFromFile(ReadString(_Data,_data_FileName,_prop_FileName));
    for i := 0 to lst.Count-1 do
     begin
       s := lst.Items[i];
       case s[1] of
        'c':
          begin
           glColor3f(0.5,0.5,0.5);
           GetTok(s,'(');
           a := str2int(GetTok(s,',')) / scale;
           b := str2int(GetTok(s,',')) / scale;
           c := str2int(GetTok(s,',')) / scale;
           d := str2int(GetTok(s,')')) / scale;
           DrawCube(a,b,c,d);
          end;
        's':
          begin
           GetTok(s,'(');
           a := str2int(GetTok(s,',')) / scale;
           b := str2int(GetTok(s,')')) / scale;
           glColor3f(1.0,1.0,0.0);
           glPushMatrix;
           glTranslated(a,b,0.02);
           gluSphere(quadObj,0.02,5,5);
           glPopMatrix;
          end;
         'p':
          begin
           GetTok(s,'(');
           glDisable(GL_LIGHTING);
           glBegin(GL_LINE_STRIP);
           glColor3f(0.0,0.0,1.0);
           while s[1] = '(' do
            begin
             delete(s,1,1);
             a := str2int(GetTok(s,',')) / scale;
             b := str2int(GetTok(s,')')) / scale;
             glVertex3f(a,b,0.02);
            end;             
           glEnd;
           glEnable(GL_LIGHTING);
          end;
       end;
     end;
    lst.Free;
    glPopMatrix;
    glEndList;
end;

procedure THIGL_ShaParse._work_doDraw;
begin

end;

end.
