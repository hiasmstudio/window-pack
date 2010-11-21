unit hiMT_Get;

interface

uses Kol,Share,Debug;

type
  THIMT_Get = class(TDebug)
   private
   public
    _event_onGet:THI_Event;
    _event_onData:THI_Event;

    procedure _work_doGet(var _Data:TData; Index:word);
  end;

implementation

procedure THIMT_Get._work_doGet;
var dt:TData;
begin
  dt := ReadData(_Data,Null);
  _hi_onEvent(_event_onGet,dt);
  _hi_CreateEvent_(_Data,@_event_onData);
end;

end.
