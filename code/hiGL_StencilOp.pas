unit hiGL_StencilOp;

interface

uses Kol,Share,Debug,OpenGL;

const
 glKeep = GL_KEEP;
 glZero = GL_ZERO;
 glReplace = GL_REPLACE;
 glIncr = GL_INCR;
 glDecr = GL_DECR;
 glInvert = GL_INVERT;

type
  THIGL_StencilOp = class(TDebug)
   private
   public
    _prop_Fail:cardinal;
    _prop_zFail:cardinal;
    _prop_zPass:cardinal;

    _event_onStencilOp:THI_Event;

    procedure _work_doStencilOp(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_StencilOp._work_doStencilOp;
begin
  glStencilOp(_prop_Fail,_prop_zFail,_prop_zPass);
  _hi_CreateEvent(_Data,@_event_onStencilOp);
end;

end.
