unit hiGL_ClipPlane;

interface

uses Kol,Share,Debug,OpenGL;
var
 eqr: array [0..3] of Double;
  
const
 Plane0 = GL_CLIP_PLANE0;
 Plane1 = GL_CLIP_PLANE1;
 Plane2 = GL_CLIP_PLANE2;
 Plane3 = GL_CLIP_PLANE3;
 Plane4 = GL_CLIP_PLANE4;
 Plane5 = GL_CLIP_PLANE5;  

type
  THIGL_ClipPlane = class(TDebug)
   private   
   public
   _prop_ClipPlane:cardinal;
   _prop_X:Integer;
   _prop_Y:Integer;
   _prop_Z:Integer;
   _prop_D:real;
   _event_onClipPlane:THI_Event;
   
    procedure _work_doClipPlane(var _Data:TData; Index:word);
    procedure _work_doX(var _Data:TData; Index:word);
    procedure _work_doY(var _Data:TData; Index:word);
    procedure _work_doZ(var _Data:TData; Index:word);
    procedure _work_doD(var _Data:TData; Index:word);
         
  end;

implementation

procedure THIGL_ClipPlane._work_doX(var _Data:TData; Index:word);
begin
   _prop_X := ToInteger(_Data);
end;

procedure THIGL_ClipPlane._work_doY(var _Data:TData; Index:word);
begin
   _prop_Y := ToInteger(_Data);
end;

procedure THIGL_ClipPlane._work_doZ(var _Data:TData; Index:word);
begin
   _prop_Z := ToInteger(_Data);
end;

procedure THIGL_ClipPlane._work_doD(var _Data:TData; Index:word);
begin
   _prop_D := ToReal(_Data);
end;

procedure THIGL_ClipPlane._work_doClipPlane;
begin
    eqr[0] := _prop_X;
    eqr[1] := _prop_Y;
    eqr[2] := _prop_Z;
    eqr[3] := _prop_D;
    glClipPlane(_prop_ClipPlane,@eqr);
   _hi_CreateEvent(_Data,@_event_onClipPlane);
end;

end.
