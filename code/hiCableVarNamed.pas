unit hiCableVarNamed;

interface

uses Share, ShareCable;

type
  THICableVarNamed = class(TCableNamed)
   public
   
    Cable: THI_Event;
    procedure _var_Wire(var Data:TData; Index:word);
  end;

implementation

procedure THICableVarNamed._var_Wire;
  var dt: PData;
begin
  dtCable(dt, @Data, Wire.Items[index]);
  _ReadData(dt^, Cable);
  if dt<>@Data then Dispose(dt); 
end;

end.
