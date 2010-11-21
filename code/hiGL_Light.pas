unit hiGL_Light;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGL_Light = class(TDebug)
   private
    procedure SetLColor(Prop:cardinal; Color:TColor);
   public
    _prop_Index:byte;
    _prop_Ambient:TColor;
    _prop_Diffuse:TColor;
    _prop_Specular:TColor;
    _prop_TypeSource:real;
    _prop_Exponent:real; 
    _prop_CutOff:real;
    _prop_Constant:real;  
    _prop_Linear:real; 
    _prop_Quadratic:real;

    _data_Point:THI_Event;
    _data_PointDirection:THI_Event;
    _data_Exponent:THI_Event;
    _data_CutOff:THI_Event;    
    _data_Constant:THI_Event;
    _data_Linear:THI_Event;
    _data_Quadratic:THI_Event;
    
    _event_onMove:THI_Event;
    _event_onEnabled:THI_Event;
    

    procedure _work_doMove(var _Data:TData; Index:word);
    procedure _work_doEnabled(var _Data:TData; Index:word);
    procedure _work_doAmbient(var _Data:TData; Index:word);
    procedure _work_doDiffuse(var _Data:TData; Index:word);
    procedure _work_doSpecular(var _Data:TData; Index:word);
    procedure _work_doExponent(var _Data:TData; Index:word);
    procedure _work_doCutOff(var _Data:TData; Index:word);
    procedure _work_doConstant(var _Data:TData; Index:word); 
    procedure _work_doLinear(var _Data:TData; Index:word); 
    procedure _work_doQuadratic(var _Data:TData; Index:word); 
    procedure _var_Max(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_Light._work_doMove;
type TPoint3D = array[0..2]of Single;
     PPoint3D = ^TPoint3D;    
var v: Array [0..3] of single;
    vd:Array [0..2] of single;
    p:PPoint3D;
    pd:PPoint3D;
begin
  with ReadData(_Data,_data_Point,nil) do
   if data_type = data_gl_point3d then
   p := PPoint3D(idata);
   v[0] := p^[0];
   v[1] := p^[1];
   v[2] := p^[2];
   v[3] := _prop_TypeSource;
   glLightfv(GL_LIGHT0 + _prop_Index,GL_POSITION, @v);
   if _prop_TypeSource <> 0 then begin
  with ReadData(_Data,_data_PointDirection,nil) do
   if data_type = data_gl_point3d then begin
   pd := PPoint3D(idata);
   vd[0] := pd^[0];
   vd[1] := pd^[1];
   vd[2] := pd^[2];   
   glLightfv(GL_LIGHT0 + _prop_Index,GL_SPOT_DIRECTION, @vd);
   end;
  end;
   _hi_CreateEvent(_Data,@_event_onMove); 
end;

procedure THIGL_Light.SetLColor;
var v:Array [0..3] of single;
begin
   with TRGB(Color) do
    begin
      v[0] := r/255;
      v[1] := g/255;
      v[2] := b/255;
      v[3] := 1.0;
    end;
   glLightfv(GL_LIGHT0 + _prop_Index, Prop, @v);
end;

procedure THIGL_Light._work_doAmbient(var _Data:TData; Index:word);
begin
   SetLColor(GL_AMBIENT,ToInteger(_Data));
end;

procedure THIGL_Light._work_doDiffuse(var _Data:TData; Index:word);
begin
   SetLColor(GL_DIFFUSE,ToInteger(_Data));
end;

procedure THIGL_Light._work_doSpecular(var _Data:TData; Index:word);
begin
   SetLColor(GL_SPECULAR,ToInteger(_Data));
end;

procedure THIGL_Light._work_doExponent(var _Data:TData; Index:word);
begin
  if _prop_TypeSource <> 0 then
  glLightf(GL_LIGHT0 + _prop_Index,GL_SPOT_EXPONENT,(ReadReal(_Data,_data_Exponent)));
end;

procedure THIGL_Light._work_doCutOff(var _Data:TData; Index:word);
begin
  if _prop_TypeSource <> 0 then
  glLightf(GL_LIGHT0 + _prop_Index,GL_SPOT_CUTOFF,(ReadReal(_Data,_data_CutOff)));
end;

procedure THIGL_Light._work_doConstant(var _Data:TData; Index:word);
begin
  if _prop_TypeSource <> 0 then
  glLightf(GL_LIGHT0 + _prop_Index,GL_CONSTANT_ATTENUATION,(ReadReal(_Data,_data_Constant)));
end;

procedure THIGL_Light._work_doLinear(var _Data:TData; Index:word);
begin
  if _prop_TypeSource <> 0 then
  glLightf(GL_LIGHT0 + _prop_Index,GL_LINEAR_ATTENUATION,(ReadReal(_Data,_data_Linear)));
end;

procedure THIGL_Light._work_doQuadratic(var _Data:TData; Index:word);
begin
  if _prop_TypeSource <> 0 then
  glLightf(GL_LIGHT0 + _prop_Index,GL_QUADRATIC_ATTENUATION,(ReadReal(_Data,_data_Quadratic)));
end;

procedure THIGL_Light._work_doEnabled;
begin
   if ReadBool(_Data) then
     begin
      glEnable($4000 + _prop_Index);
      SetLColor(GL_AMBIENT,_prop_Ambient);
      SetLColor(GL_DIFFUSE,_prop_Diffuse);
      SetLColor(GL_SPECULAR,_prop_Specular);
      if _prop_TypeSource <> 0 then begin 
      glLightf(GL_LIGHT0 + _prop_Index,GL_SPOT_EXPONENT,(ReadReal(_Data,_data_Exponent,_prop_Exponent)));
      glLightf(GL_LIGHT0 + _prop_Index,GL_SPOT_CUTOFF,(ReadReal(_Data,_data_CutOff,_prop_CutOff)));
      glLightf(GL_LIGHT0 + _prop_Index,GL_CONSTANT_ATTENUATION,(ReadReal(_Data,_data_Constant,_prop_Constant)));
      glLightf(GL_LIGHT0 + _prop_Index,GL_LINEAR_ATTENUATION,(ReadReal(_Data,_data_Linear,_prop_Linear)));
      glLightf(GL_LIGHT0 + _prop_Index,GL_QUADRATIC_ATTENUATION,(ReadReal(_Data,_data_Quadratic,_prop_Quadratic)));
      end      
     end
   else glDisable($4000 + _prop_Index);
   _hi_CreateEvent(_Data,@_event_onEnabled);
end;

procedure THIGL_Light._var_Max(var _Data:TData; Index:word);
var wrk:glint;
begin
  glGetintegerv (GL_MAX_LIGHTS, @wrk);
  _Data := _DoData(wrk);
end;

end.
