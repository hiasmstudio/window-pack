unit hiGL_Vertex3D;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGL_Vertex3D = class(TDebug)
   private
   public
    _prop_X:real;
    _prop_Y:real;
    _prop_Z:real;

    _data_Z:THI_Event;
    _data_Y:THI_Event;
    _data_X:THI_Event;
    _event_onVertex:THI_Event;

    procedure _work_doVertex(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_Vertex3D._work_doVertex;
var v:array[0..2] of glfloat;
begin
   v[0] := ReadReal(_Data,_data_X,_prop_X);
   v[1] := ReadReal(_Data,_data_Y,_prop_Y);
   v[2] := ReadReal(_Data,_data_Z,_prop_Z);
   glVertex3fv(@v);
   _hi_CreateEvent(_Data,@_event_onVertex);
end;

end.
