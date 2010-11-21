unit hiGl_End;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGl_End = class(TDebug)
   private
   public
    _event_onEnd:THI_Event;

    procedure _work_doEnd(var _Data:TData; Index:word);
  end;

implementation


procedure THIGl_End._work_doEnd;
begin
  glEnd;
  _hi_CreateEvent(_Data,@_event_onEnd);
end;

end.
