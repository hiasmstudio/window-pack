unit hiDoData;

interface

uses Kol,Share,Debug;

type
  THIDoData = class(TDebug)
   private
   public
    _prop_Data:TData;
   _data_Data:THI_Event;
   _event_onEventData:THI_Event;

   procedure _work_doData(var _Data:TData; Index:word);
  end;

implementation

procedure THIDoData._work_doData;
begin
    dtNull(_Data);
    _hi_CreateEvent(_Data,@_event_onEventData,ReadData(_Data,_data_Data,@_prop_Data));
end;

end.
