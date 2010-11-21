unit hiGL_Dodecahedron;

interface

uses Kol,Share,Debug,OpenGL,dglut;

type
  THIGL_Dodecahedron = class(TDebug)
   private
   public
    _event_onDraw:THI_Event;

    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_Dodecahedron._work_doDraw;
begin
  glutSolidDodecahedron();
  _hi_CreateEvent(_Data,@_event_onDraw);
end;

end.
