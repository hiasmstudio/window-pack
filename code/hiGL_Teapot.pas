unit hiGL_Teapot;

interface

uses Kol,Share,Debug,OpenGL,DGlut;

type
  THIGL_Teapot = class(TDebug)
   private
   public
    _prop_Size:real;

    _data_Size:THI_Event;
    _event_onDraw:THI_Event;

    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_Teapot._work_doDraw;
var s:double;
begin
  s := ReadReal(_Data,_data_Size,_prop_Size);
  glutSolidTeapot(s);
  _hi_CreateEvent(_Data,@_event_onDraw);
end;

end.
