unit hiGL_CallList;

interface

uses Kol,Share,Debug,OpenGL;

type
  THIGL_CallList = class(TDebug)
   private
   public
    _prop_Index:integer;

    _data_Index:THI_Event;
    _event_onCallList:THI_Event;

    procedure _work_doCallList(var _Data:TData; Index:word);
  end;

implementation

procedure THIGL_CallList._work_doCallList;
begin
   glCallList(ReadInteger(_Data,_data_Index,_prop_Index));
   _hi_CreateEvent(_Data,@_event_onCallList);
end;

end.
