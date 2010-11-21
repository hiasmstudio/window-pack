unit hiGl_EndList;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGl_EndList = class(TDebug)
   private
   public 
    _event_onEndList:THI_Event;

    procedure _work_doEndList(var _Data:TData; Index:word);
  end;

implementation

procedure THIGl_EndList._work_doEndList;
begin
   glEndList;
   _hi_CreateEvent(_Data,@_event_onEndList);
end;

end.
