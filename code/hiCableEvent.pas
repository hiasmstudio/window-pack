unit hiCableEvent;

interface

uses Share,Debug,ShareCable;

type
 THICableEvent = class(TCable)
   private
     procedure SetCount(value:Word); override;
   public
     Wire: array of THI_Event;
     procedure _work_Cable(var Data:TData; Index:word);
 end;

implementation

procedure THICableEvent.SetCount;
begin
  SetLength(Wire,Value);
end;

procedure THICableEvent._work_Cable;
begin
  if _isCable(data) and ((data.idata-_prop_from) in [0..High(Wire)]) then
    _hi_onEvent_(Wire[data.idata-_prop_From],data.ldata^);
end;

end.
