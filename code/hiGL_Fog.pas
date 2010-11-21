unit hiGL_Fog;

interface

uses Kol,Share,Debug,OpenGL;

const
  fmExp = GL_EXP;
  fmLinear = GL_LINEAR;

type
  THIGL_Fog = class(TDebug)
   private
   public
    _prop_Color:TColor;
    _prop_Mode:cardinal;
    _prop_Density:real;
    _prop_LinearStart:integer;
    _prop_LinearEnd:integer;

    _event_onEnabled:THI_Event;

    procedure _work_doEnabled(var _Data:TData; Index:word);
  end;

implementation

//uses hiGL_Main;

procedure THIGL_Fog._work_doEnabled;
var cl:array[0..3] of GLfloat;
begin
   if ReadBool(_Data) then
    begin
      with TRGB(_prop_Color) do
       begin
         cl[0] := r/255;
         cl[1] := g/255;
         cl[2] := b/255;
         cl[3] := 1.0;
       end;
      glFogfv(GL_FOG_COLOR, @cl);
      glFogf(GL_FOG_DENSITY, _prop_Density);
      glFogf(GL_FOG_START, _prop_LinearStart);
      glFogf(GL_FOG_END, _prop_LinearEnd);
      glFogi(GL_FOG_MODE, _prop_Mode);
      glEnable(GL_FOG);
    end
   else glDisable(GL_FOG);
   _hi_CreateEvent(_Data,@_event_onEnabled);
end;

end.
