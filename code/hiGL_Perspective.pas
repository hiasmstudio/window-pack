unit hiGL_Perspective;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGL_Perspective = class(TDebug)
   private
   public
    _prop_Aspect:real;
    _prop_Fovy:real;
    _prop_zNear:real;
    _prop_zFar:real;

    _data_zFar:THI_Event;
    _data_zNear:THI_Event;
    _data_Fovy:THI_Event;
    _data_Aspect:THI_Event;
    _event_onPerspective:THI_Event;

    procedure _work_doPerspective(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_Perspective._work_doPerspective;
var
    a,f,zn,zf:real;
begin
     //glFrustum (-1, 1, -1, 1, 3, 10);
     a := readreal(_data,_data_Aspect,_prop_Aspect);
     f := readreal(_data,_data_fovy,_prop_fovy);
     zn := readreal(_data,_data_znear,_prop_znear);
     zf := readreal(_data,_data_zfar,_prop_zfar);
     glMatrixMode(GL_PROJECTION);
     glLoadIdentity;
     gluPerspective(f, a, zn, zf);

     glMatrixMode(GL_MODELVIEW);
     glLoadIdentity;

     glTranslatef(0.0, 0.0, -8.0);

     _hi_CreateEvent(_data,@_event_onPerspective);
end;

end.
