unit hiGL_PolygonMode;

interface

uses Kol,Share,Debug,OpenGL;

const
   glPoint = GL_POINT;
   glLine = GL_LINE;
   glFill = GL_FILL;

   gsFront = GL_FRONT;
   gsBack  = GL_BACK;
   gsFrontAndBack = GL_FRONT_AND_BACK;

type
  THIGL_PolygonMode = class(TDebug)
   private
   public
    _prop_Side:cardinal;
    _prop_Mode:cardinal;

    _event_onPolygonMode:THI_Event;

    procedure _work_doPolygonMode(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_PolygonMode._work_doPolygonMode;
begin
   glPolygonMode(_prop_Side, _prop_Mode);
   _hi_CreateEvent(_Data,@_event_onPolygonMode);
end;

end.
