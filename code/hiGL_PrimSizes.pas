unit hiGL_PrimSizes;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGL_PrimSizes = class(TDebug)
   private
   public
    _prop_Size:real;

    _data_Size:THI_Event;
    _event_onSize:THI_Event;

    procedure _work_doLineSize(var _Data:TData; Index:word);
    procedure _work_doPointSize(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_PrimSizes._work_doLineSize;
begin
   glLineWidth(ReadReal(_Data,_data_Size,_prop_Size));
   _hi_CreateEvent(_Data,@_event_onSize);
end;

procedure THIGL_PrimSizes._work_doPointSize;
begin
   glPointSize(ReadReal(_Data,_data_Size,_prop_Size));
   _hi_CreateEvent(_Data,@_event_onSize);
end;

end.
