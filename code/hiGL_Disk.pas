unit hiGL_Disk;

interface

uses Kol,Share,Debug,OpenGL,DGlut;

type
  THIGL_Disk = class(TDebug)
   private
   public
    _prop_InRadius:real;
    _prop_OutRadius:real;
    _prop_Slices:integer;
    _prop_Stacks:integer;

    _data_Stacks:THI_Event;
    _data_Slices:THI_Event;
    _data_OutRadius:THI_Event;
    _data_InRadius:THI_Event;
    _event_onDraw:THI_Event;

    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_Disk._work_doDraw;
var ri,ro:real;
    sl,st:integer;
begin
  ri := ReadReal(_Data,_data_InRadius,_prop_InRadius);
  ro := ReadReal(_Data,_data_OutRadius,_prop_OutRadius);
  sl := ReadInteger(_Data,_data_Slices,_prop_Slices);
  st := ReadInteger(_Data,_data_Stacks,_prop_Stacks);
  gluDisk(quadObj,ri,ro,sl,st);
  _hi_CreateEvent(_Data,@_event_onDraw);
end;

end.
