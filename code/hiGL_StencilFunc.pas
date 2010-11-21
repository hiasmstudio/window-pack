unit hiGL_StencilFunc;

interface

uses Kol,Share,Debug,OpenGL;

const
  glNever = GL_NEVER;
  glLess = GL_LESS;
  glLequal = GL_LEQUAL;
  glGreater = GL_GREATER;
  glGequal = GL_GEQUAL;
  glEgual = GL_EQUAL;
  glNotequal = GL_NOTEQUAL;
  glAlways = GL_ALWAYS;

type
  THIGL_StencilFunc = class(TDebug)
   private
   public
    _prop_Func:cardinal;
    _prop_Ref:integer;
    _prop_Mask:integer;

    _event_onStencilFunc:THI_Event;

    procedure _work_doStencilFunc(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_StencilFunc._work_doStencilFunc;
begin
  glStencilFunc(_prop_Func,_prop_Ref,_prop_Mask);
  _hi_CreateEvent(_Data,@_event_onStencilFunc);
end;

end.
