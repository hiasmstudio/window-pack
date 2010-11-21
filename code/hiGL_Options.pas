unit hiGL_Options;

interface

uses Kol,Share,Debug,OpenGL;
var
  glfClipPlane:cardinal;
 
const
 glfLighting = GL_LIGHTING;
 glfColorMaterial = GL_COLOR_MATERIAL;
 glfDepthTest = GL_DEPTH_TEST;
 glfNormalize = GL_NORMALIZE;
 glfFog = GL_FOG;
 glfLineStipple = GL_LINE_STIPPLE;
 glfLineSmooth = GL_LINE_SMOOTH;
 glfPointSmooth = GL_POINT_SMOOTH;
 glfBlend = GL_BLEND;
 glfCullFace = GL_CULL_FACE;
 glfTexture2D = GL_TEXTURE_2D;
 glfStencilTest = GL_STENCIL_TEST;
 glfScissor = GL_SCISSOR_TEST;
 glfClipPlane0 = GL_CLIP_PLANE0;
 glfClipPlane1 = GL_CLIP_PLANE1;
 glfClipPlane2 = GL_CLIP_PLANE2;
 glfClipPlane3 = GL_CLIP_PLANE3;
 glfClipPlane4 = GL_CLIP_PLANE4;
 glfClipPlane5 = GL_CLIP_PLANE5; 

type
  THIGL_Options = class(TDebug)
   private
   public
    _prop_Flag:cardinal;
    _event_onEvent:THI_Event;

    procedure _work_doEnabled(var _Data:TData; Index:word);
    procedure _work_doDisabled(var _Data:TData; Index:word);
    procedure _var_Enabled(var _Data:TData; Index:word);
  end;

implementation 


procedure THIGL_Options._work_doEnabled;
begin
    glEnable(_prop_Flag);
    _hi_CreateEvent(_Data,@_event_onEvent);
end;

procedure THIGL_Options._work_doDisabled;
begin
    glDisable(_prop_Flag);
    _hi_CreateEvent(_Data,@_event_onEvent);
end;

procedure THIGL_Options._var_Enabled;
begin
    dtInteger(_Data,integer(glIsEnabled(_prop_Flag)));
end;
end.
