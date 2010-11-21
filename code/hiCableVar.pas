unit hiCableVar;

interface
                                 
uses Share,Debug,ShareCable;

type
 THICableVar = class(TCable)
   public
    _data_Cable: THI_Event;
    procedure Wire(var Data:TData; Index:word);
 end;

implementation

procedure THICableVar.Wire;
 var dt: TData;
begin
  dtCable(dt, @Data, index+_prop_From);
  _ReadData(dt, _data_Cable);
end;

end.
