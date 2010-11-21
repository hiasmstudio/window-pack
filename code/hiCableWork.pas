unit hiCableWork;

interface
                                 
uses Share,Debug,ShareCable;         

type
 THICableWork = class(TCable)
   public
    _event_Cable: THI_Event;
    procedure Wire(var Data:TData; Index:word);
 end;

implementation

procedure THICableWork.Wire;
 var dt: TData;
begin
  dtCable(dt, @Data, index+_prop_From);
  _hi_onEvent(_event_Cable, Dt);
end;

end.
