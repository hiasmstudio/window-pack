unit hiGL_BlendFunc;

interface

uses Kol,Share,Debug,OpenGL;

const
   GlSrcAlpha = GL_SRC_ALPHA;
   GlOneMinusSrcAlpha = GL_ONE_MINUS_SRC_ALPHA;
   GlDstAlpha = GL_DST_ALPHA;
   GlOneMinusDstAlpha = GL_ONE_MINUS_DST_ALPHA;
   GlSrcColor = GL_SRC_COLOR;
   GlOneMinusSrcColor = GL_ONE_MINUS_SRC_COLOR;
   GlDstColor = GL_DST_COLOR;
   GlOneMinusDstColor = GL_ONE_MINUS_DST_COLOR;
   GlSrcAlphaSaturate = GL_SRC_ALPHA_SATURATE;
   GlOne = GL_ONE;
   GlZero = GL_ZERO;

type
  THIGL_BlendFunc = class(TDebug)
   private
   public
    _prop_sfactor:cardinal;
    _prop_dfactor:cardinal;

    _event_onBlendFunc:THI_Event;

    procedure _work_doBlendFunc(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_BlendFunc._work_doBlendFunc;
begin
   glBlendFunc(_prop_sfactor, _prop_dfactor);
   _hi_CreateEvent(_Data,@_event_onBlendFunc);
end;

end.
