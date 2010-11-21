unit hiCableData;

interface

uses Share,Debug,ShareCable;

type
  THICableData = class(TCable)
   private
     procedure SetCount(value:Word); override;
   public
     Wire: array of THI_Event;
     procedure _var_Cable(var Data:TData; Index:word);
  end;

implementation

procedure THICableData.SetCount;
begin
  SetLength(Wire, Value);
end;

procedure THICableData._var_Cable;
begin
  if _isCable(data) and ((data.idata-_prop_from) in [0..High(Wire)]) then
    _ReadData(data.ldata^, Wire[data.idata-_prop_From]);
end;

end.
