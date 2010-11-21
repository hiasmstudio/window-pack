unit hiGl_Begin;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGl_Begin = class(TDebug)
   private
   public
    _prop_BlockType:byte;
    _event_onBegin:THI_Event;

    procedure _work_doBegin(var _Data:TData; Index:word);
  end;

implementation

procedure THIGl_Begin._work_doBegin;
begin
   glBegin(_prop_BlockType);
   _hi_CreateEvent(_Data,@_event_onBegin);
end;

end.
