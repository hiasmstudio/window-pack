unit hiGl_Axis;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGl_Axis = class(TDebug)
   private
   public
    _prop_XColor:TColor;
    _prop_YColor:TColor;
    _prop_ZColor:TColor;
    _prop_Length:real;
    _prop_Title:boolean;
    _prop_TitleScale:real;
    _prop_TitleSpace:real;

    _event_onDraw:THI_Event;

    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

uses hiGL_Main;

procedure THIGl_Axis._work_doDraw;
var old:boolean;
begin
   old := glIsEnabled(GL_LIGHTING);

   glDisable(GL_LIGHTING);
   glBegin(GL_LINES);
    glColor(_prop_XColor);
    glVertex3f(0.0,0.0,0.0);
    glVertex3f(_prop_Length,0.0,0.0);

    glColor(_prop_YColor);
    glVertex3f(0.0,0.0,0.0);
    glVertex3f(0.0,_prop_Length,0.0);

    glColor(_prop_ZColor);
    glVertex3f(0.0,0.0,0.0);
    glVertex3f(0.0,0.0,_prop_Length);
    if _prop_Title then
     begin
      glColor(_prop_XColor);
      glVertex3f(_prop_Length + _prop_TitleSpace,-0.2*_prop_TitleScale,-0.1*_prop_TitleScale);
      glVertex3f(_prop_Length + _prop_TitleSpace,0.2*_prop_TitleScale,0.1*_prop_TitleScale);
      glVertex3f(_prop_Length + _prop_TitleSpace,0.2*_prop_TitleScale,-0.1*_prop_TitleScale);
      glVertex3f(_prop_Length + _prop_TitleSpace,-0.2*_prop_TitleScale,0.1*_prop_TitleScale);

      glColor(_prop_YColor);
      glVertex3f(0.0,_prop_Length+_prop_TitleSpace,-0.2*_prop_TitleScale);
      glVertex3f(0.0,_prop_Length+_prop_TitleSpace,0.0);
      glVertex3f(0.0,_prop_Length+_prop_TitleSpace,0.0);
      glVertex3f(0.1*_prop_TitleScale,_prop_Length+_prop_TitleSpace,0.2*_prop_TitleScale);
      glVertex3f(0.0,_prop_Length+_prop_TitleSpace,0.0);
      glVertex3f(-0.1*_prop_TitleScale,_prop_Length+_prop_TitleSpace,0.2*_prop_TitleScale);

      glColor(_prop_ZColor);
      glVertex3f(0.1*_prop_TitleScale,-0.2*_prop_TitleScale,_prop_Length+_prop_TitleSpace);
      glVertex3f(-0.1*_prop_TitleScale,-0.2*_prop_TitleScale,_prop_Length+_prop_TitleSpace);
      glVertex3f(-0.1*_prop_TitleScale,-0.2*_prop_TitleScale,_prop_Length+_prop_TitleSpace);
      glVertex3f(0.1*_prop_TitleScale,0.2*_prop_TitleScale,_prop_Length+_prop_TitleSpace);
      glVertex3f(0.1*_prop_TitleScale,0.2*_prop_TitleScale,_prop_Length+_prop_TitleSpace);
      glVertex3f(-0.1*_prop_TitleScale,0.2*_prop_TitleScale,_prop_Length+_prop_TitleSpace);
     end;
   glEnd;
   if old then
     glEnable(GL_LIGHTING);
   _hi_CreateEvent(_Data,@_event_onDraw);
end;

end.
