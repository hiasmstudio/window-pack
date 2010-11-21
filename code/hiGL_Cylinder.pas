unit hiGL_Cylinder;

interface

uses Kol,Share,Debug,OpenGL,DGlut;

type
  THIGL_Cylinder = class(TDebug)
   private
   public
    _prop_BaseRadius:real;
    _prop_TopRadius:real;
    _prop_Height:real;
    _prop_Slices:integer;
    _prop_Stacks:integer;

    _data_Stacks:THI_Event;
    _data_Slices:THI_Event;
    _data_Height:THI_Event;
    _data_TopRadius:THI_Event;
    _data_BaseRadius:THI_Event;
    _event_onDraw:THI_Event;

    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_Cylinder._work_doDraw;
var rb,rt,h:real;
    sl,st:integer;
begin
  rb := ReadReal(_Data,_data_BaseRadius,_prop_BaseRadius);
  rt := ReadReal(_Data,_data_TopRadius,_prop_TopRadius);
  h := ReadReal(_Data,_data_Height,_prop_Height);

  sl := ReadInteger(_Data,_data_Slices,_prop_Slices);
  st := ReadInteger(_Data,_data_Stacks,_prop_Stacks);
  gluCylinder(quadObj,rb,rt,h,sl,st);
  _hi_CreateEvent(_Data,@_event_onDraw);
end;

end.
