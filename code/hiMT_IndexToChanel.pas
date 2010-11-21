unit hiMT_IndexToChanel;

interface

uses Kol,Share,Debug;

type
  THIMT_IndexToChanel = class(TDebug)
   private
    FCount:integer;
    procedure SetCount(Value:integer);
   public
    _data_index:THI_Event;
    _data_Data:THI_Event;
    onEvent:array of THI_Event;

    procedure _work_doEvent(var _Data:TData; Index:word);
    property _prop_Count:integer write SetCount;
  end;

implementation

procedure THIMT_IndexToChanel.SetCount;
begin
  SetLength(onEvent,Value);
  FCount := Value;
end;

procedure THIMT_IndexToChanel._work_doEvent;
var ind:integer;
begin
  ind := ReadInteger(_Data,_data_Index);
  _Data := ReadMTData(_Data,_data_Data);
  if(ind >= 0)and(ind < FCount) then
    _hi_CreateEvent_(_Data,@onEvent[ind]);
end;

end.
