unit hiGL_Torus;

interface

uses Kol,Share,Debug,OpenGL,Dglut;

type
  THIGL_Torus = class(TDebug)
   private
   public
    _prop_inRadius:real;
    _prop_outRadius:real;
    _prop_Sides:integer;
    _prop_Rings:integer;

    _data_Rings:THI_Event;
    _data_Sides:THI_Event;
    _data_outRadius:THI_Event;
    _data_inRadius:THI_Event;
    _event_onDraw:THI_Event;

    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation


procedure THIGL_Torus._work_doDraw;
var rb,rt,h:real;
    sl,st:integer;
begin
  rb := ReadReal(_Data,_data_inRadius,_prop_inRadius);
  rt := ReadReal(_Data,_data_outRadius,_prop_outRadius);

  sl := ReadInteger(_Data,_data_Sides,_prop_Sides);
  st := ReadInteger(_Data,_data_Rings,_prop_Rings);
  glutSolidTorus(rb,rt,sl,st);
  _hi_CreateEvent(_Data,@_event_onDraw);
end;

end.
