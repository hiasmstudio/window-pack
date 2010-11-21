unit hiGL_CullFace;

interface

uses Kol,Share,Debug,OpenGL;

const
   gsFront = GL_FRONT;
   gsBack  = GL_BACK;
   gsFrontAndBack = GL_FRONT_AND_BACK;

type
  THIGL_CullFace = class(TDebug)
   private
   public
    _prop_Side:cardinal;
    _event_onCullFace:THI_Event;

    procedure _work_doCullFace(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_CullFace._work_doCullFace;
begin
   glCullFace(_prop_Side);
   _hi_CreateEvent(_data,@_event_onCullFace);
end;

end.
