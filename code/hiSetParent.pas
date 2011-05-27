unit hiSetParent;

interface

uses Windows, Kol, Share, Debug;

type
  THISetParent = class(TDebug)
   private
     FOldParent: integer;
   public

    _data_Handle: THI_Event;
    _data_NewParent: THI_Event;
    _event_onSetParent: THI_Event;
    _event_onError: THI_Event;

    procedure _work_doSetParent(var _Data:TData; Index:word);
    procedure _var_OldParent(var _Data:TData; Index:word);
  end;

implementation

procedure THISetParent._work_doSetParent;
var
  p, h: HWND;
begin
 h := ReadInteger(_Data, _data_Handle);
 p := ReadInteger(_Data, _data_NewParent);
 FOldParent := 0;

 if (p <> 0) and (h <> 0) then
 begin
  FOldParent := SetParent(h, p);
  if FOldParent <> 0 then
    _hi_CreateEvent(_Data, @_event_onSetParent)
  else
    _hi_CreateEvent(_Data, @_event_onError);
 end;

end;

procedure THISetParent._var_OldParent;
begin
  dtInteger(_Data, FOldParent);
end;

end.