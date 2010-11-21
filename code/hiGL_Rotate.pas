unit hiGL_Rotate;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGL_Rotate = class(TDebug)
   private
   public
    _prop_X:real;
    _prop_Y:real;
    _prop_Z:real;
    _prop_Angle:real;

    _event_onRotate:THI_Event;
    _data_Angle:THI_Event;
    _data_Z:THI_Event;
    _data_Y:THI_Event;
    _data_X:THI_Event;

    procedure _work_doRotate(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_Rotate._work_doRotate;
var a,x,y,z:single;
begin
   a := ReadReal(_Data,_data_Angle,_prop_Angle);
   x := ReadReal(_Data,_data_X,_prop_X);
   y := ReadReal(_Data,_data_Y,_prop_Y);
   z := ReadReal(_Data,_data_Z,_prop_Z);
   glRotated(a,x,y,z);
   _hi_CreateEvent(_Data,@_event_onRotate);
end;

end.
