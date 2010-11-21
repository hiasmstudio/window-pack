unit hiGL_Scissor;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGL_Scissor = class(TDebug)
   private
   public
    _prop_X:integer;
    _prop_Y:integer;
    _prop_Width:integer;
    _prop_Height:integer;

    _data_X:THI_Event;
    _data_Y:THI_Event;
    _data_Width:THI_Event;
    _data_Height:THI_Event;
    _event_onScissor:THI_Event;

    procedure _work_doScissor(var _Data:TData; Index:word);
  end;

implementation


procedure THIGL_Scissor._work_doScissor;
begin
  glScissor(ReadInteger(_Data,_data_X,_prop_X),ReadInteger(_Data,_data_Y,_prop_Y),ReadInteger(_Data,_data_Width,_prop_Width),ReadInteger(_Data,_data_Height,_prop_Height));
  _hi_CreateEvent(_Data,@_event_onScissor);
end;

end.
