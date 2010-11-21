unit hiMT_ChanelToIndex;

interface

uses Kol,Share,Debug;

type
  THIMT_ChanelToIndex = class(TDebug)
   private
   public
    _prop_Count:integer;
    _event_onIndex:THI_Event;

    procedure doWork(var _Data:TData; Index:word);
  end;

implementation

procedure THIMT_ChanelToIndex.doWork(var _Data:TData; Index:word);
var s:PData;
    dt:TData;
begin
  dtInteger(dt,Index);
  AddMTData(@dt,@_Data,s);
  _hi_OnEvent_(_event_onIndex,dt);
  FreeData(@dt);
end;

end.
