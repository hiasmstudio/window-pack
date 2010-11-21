unit hiMRA_Wire;

interface

uses Kol,Share,Debug,mra_client;

type
  THIMRA_Wire = class(TDebug)
   private
   public
    _prop_Name:string;
    _data_MRA_Handle:THI_Event;
    
    function GetInterfaceMRA:TMailClient;
  end;

implementation

uses hiMRA_Base;

function THIMRA_Wire.GetInterfaceMRA;
var dt:Tdata;
begin
  EventOn;  // это вообще говоря не очень правильно...
  dtNull(dt);
  _ReadData(dt, _data_MRA_Handle);
//  EventOff; // ...
  
  Result := TMailClient(ToObject(dt));
  if not _IsObject(dt,MRA_GUID) then
    Result := nil;
end;

end.
