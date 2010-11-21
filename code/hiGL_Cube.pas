unit hiGL_Cube;

interface

uses Kol,Share,Debug,OpenGL,DGlut;

type
  THIGL_Cube = class(TDebug)
   private
   public
    _prop_Size:real;

    _data_Size:THI_Event;
    _data_Point2:THI_Event;
    _data_Point1:THI_Event;
    _event_onDraw:THI_Event;

    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_Cube._work_doDraw;
begin
  glutSolidCube(ReadReal(_data,_data_size,_prop_Size));
  _hi_CreateEvent(_Data,@_event_onDraw);
end;

end.
