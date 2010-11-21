unit hiGL_Material;

interface

uses Kol,Share,Debug,OpenGL;

const
  gsFront = GL_FRONT;
  gsBack  = GL_BACK;
  gsFrontAndBack = GL_FRONT_AND_BACK;

type
  THIGL_Material = class(TDebug)
   private
    procedure SetLColor(Prop:cardinal; Color:TColor);
   public
    _prop_Side:cardinal;
    _prop_Ambient:TColor;
    _prop_Diffuse:TColor;
    _prop_Specular:TColor;
    _prop_Emission:TColor;
    _prop_Shininess:integer;

    _event_onSet:THI_Event;

    procedure _work_doSet(var _Data:TData; Index:word);
    procedure _work_doAmbient(var _Data:TData; Index:word);
    procedure _work_doDiffuse(var _Data:TData; Index:word);
    procedure _work_doSpecular(var _Data:TData; Index:word);
    procedure _work_doEmission(var _Data:TData; Index:word);
    procedure _work_doShininess(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_Material._work_doAmbient(var _Data:TData; Index:word);
begin
   _prop_Ambient := ToInteger(_Data);
end;

procedure THIGL_Material._work_doDiffuse(var _Data:TData; Index:word);
begin
   _prop_Diffuse := ToInteger(_Data);
end;

procedure THIGL_Material._work_doSpecular(var _Data:TData; Index:word);
begin
   _prop_Specular := ToInteger(_Data);
end;

procedure THIGL_Material._work_doEmission(var _Data:TData; Index:word);
begin
   _prop_Emission := ToInteger(_Data);
end;

procedure THIGL_Material._work_doShininess(var _Data:TData; Index:word);
begin
   _prop_Shininess := ToInteger(_Data);
end;

procedure THIGL_Material.SetLColor;
var v:Array [0..3] of single;
begin
   with TRGB(Color) do
    begin
      v[0] := r/255;
      v[1] := g/255;
      v[2] := b/255;
      v[3] := 1.0;
    end;
   glMaterialfv(_prop_Side, Prop, @v);
end;

procedure THIGL_Material._work_doSet;
begin
   SetLColor(GL_AMBIENT,_prop_Ambient);
   SetLColor(GL_DIFFUSE,_prop_Diffuse);
   SetLColor(GL_SPECULAR,_prop_Specular);
   SetLColor(GL_EMISSION,_prop_Emission);
   glMaterialf(_prop_Side, GL_SHININESS, _prop_Shininess);
   _hi_CreateEvent(_Data,@_event_onSet);
end;

end.
