unit hiCableDataNamed;

interface

uses Kol,Share,ShareCable;

type

  THICableDataNamed = class(TCableNamed)
   private
    procedure SetWire(const value:string); override;
   public

    _data_Wire: array of THI_Event;
    procedure Cable(var Data:TData; Index:word);
  end;
 
implementation

procedure THICableDataNamed.Cable;
 var i: integer;
begin
  if not _isCable(data) then exit;
  i:=Wire.IndexOf(parse(data.sdata, CableNameDelimiter)); 
  if i>=0 then
    if data.sdata='' then
      _ReadData(data.ldata^, _data_Wire[i])
     else
      _ReadData(data, _data_Wire[i]);
end;

procedure THICableDataNamed.SetWire;
begin
   inherited;
   SetLength(_data_Wire,Wire.Count);
end;

end.
