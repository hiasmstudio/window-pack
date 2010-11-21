unit hiSampleDelta;

interface

uses Kol,Share,Debug;

type
  THISampleDelta = class(TDebug)
   private
    Store:TData;
   public
    _data_Data:THI_Event;
    _event_onCalcDelta:THI_Event;

    procedure _work_doCalcDelta(var _Data:TData; Index:word);
    property _prop_Store:TData write Store;
  end;

implementation

procedure THISampleDelta._work_doCalcDelta;
var dt:TData;
begin
   dt := ReadData(_Data,_data_Data);
   case _IsType(Store) of
    data_int: _hi_CreateEvent(_Data,@_event_onCalcDelta,-ToInteger(Store) + ToInteger(dt));
    data_real: _hi_CreateEvent(_Data,@_event_onCalcDelta,-ToReal(Store) + ToReal(dt));
   end;
   Store := dt;
end;

end.
