unit hiGL_TexEnvMode;

interface

uses Kol,Share,Debug,OpenGL;

const
  glReplace = GL_REPLACE;
  glBlend = GL_BLEND;
  glDecal = GL_DECAL;
  glModulate = GL_MODULATE; 

type
  THIGL_TexEnvMode = class(TDebug)
   private
   public
    _prop_Mode:cardinal;

    _event_onTexEnv:THI_Event;

    procedure _work_doTexEnv(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_TexEnvMode._work_doTexEnv;
begin
  glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, _prop_Mode);
  _hi_CreateEvent(_Data,@_event_onTexEnv);
end;

end.
