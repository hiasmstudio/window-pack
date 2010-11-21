unit hiWaitObject;

interface

uses Windows,Kol,Share,Debug;

type
  THIWaitObject = class(TDebug)
   private
   public
    _prop_Time:integer;

    _event_onWait:THI_Event;
    _data_ObjHandle:THI_Event;

    procedure _work_doWait(var _Data:TData; Index:word);
  end;

implementation

procedure THIWaitObject._work_doWait;
begin
   WaitForSingleObject(ReadInteger(_Data,_data_ObjHandle,0),_prop_Time);
   _hi_CreateEvent(_Data,@_event_onWait);
end;

end.
