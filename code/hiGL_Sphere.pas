unit hiGL_Sphere;

interface

uses Kol,Share,Debug,OpenGL,DGlut;

type
  THIGL_Sphere = class(TDebug)
   private
   public
    _prop_Radius:real;
    _prop_Slices:integer;
    _prop_Stacks:integer;

    _data_Stacks:THI_Event;
    _data_Slices:THI_Event;
    _data_Radius:THI_Event;
    _event_onDraw:THI_Event;

    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_Sphere._work_doDraw;
var r:double;
    sl,st:integer;
    c:TColor;
begin
  r := ReadReal(_Data,_data_Radius,_prop_Radius);
  sl := ReadInteger(_Data,_data_Slices,_prop_Slices);
  st := ReadInteger(_Data,_data_Stacks,_prop_Stacks);
  gluSphere(quadObj,r,sl,st);
  _hi_CreateEvent(_Data,@_event_onDraw);
end;

end.
