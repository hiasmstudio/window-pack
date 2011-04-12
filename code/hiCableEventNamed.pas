unit hiCableEventNamed;

interface

uses Share,ShareCable;

type

  THICableEventNamed = class(TCableNamed)
   private
    procedure SetWire(const value:string); override;
   public

    _event_Wire: array of THI_Event;
    procedure Cable(var Data:TData; Index:word);
  end;
 
implementation

procedure THICableEventNamed.Cable;
 var i: integer;
begin
  if not _isCable(data) then exit;
  i:=Wire.IndexOf(cparse(data.sdata)); 
  if i>=0 then
    if data.sdata='' then
      _hi_onEvent_(_event_Wire[i],data.ldata^)
     else 
      _hi_onEvent_(_event_Wire[i],data);
end;

procedure THICableEventNamed.SetWire;
begin
   inherited;
   SetLength(_event_Wire,Wire.Count);
end;

end.
