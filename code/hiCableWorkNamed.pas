unit hiCableWorkNamed;

interface

uses Share, ShareCable;

type
  THICableWorkNamed = class(TCableNamed)
   public
   
    Cable: THI_Event;
    procedure _work_Wire(var Data:TData; Index:word);
  end;

implementation

procedure THICableWorkNamed._work_Wire;
  var dt: PData;
begin
  dtCable(dt, @Data, Wire.Items[index]);
  _hi_onEvent(Cable, Dt^);
  if dt<>@Data then Dispose(dt); 
end;

end.
