unit hiKE_SerialNumber;

interface

uses Kol,Share,Debug,hiKE_Connect;

type
  THIKE_SerialNumber = class(TDebug)
   private
    fKEU:IKE_USB;
    
    procedure SetKE_Device(value:IKE_USB);
    procedure _OnSerialNumber(const snum:string); 
   public
    _event_onGetSerial:THI_Event;

    procedure _work_doGetSerial(var _Data:TData; Index:word);
    property _prop_KE_Device:IKE_USB write SetKE_Device;
  end;

implementation

procedure THIKE_SerialNumber._work_doGetSerial;
begin
   if fKEU <> nil then
     fKEU.GetSerialNumber;
end;

procedure THIKE_SerialNumber.SetKE_Device(value:IKE_USB);
begin
  if value <> nil then
    value.OnSerialNumber := _OnSerialNumber;     
  fKEU := value; 
end;

procedure THIKE_SerialNumber._OnSerialNumber(const snum:string);
begin
   _hi_onEvent(_event_onGetSerial, snum);
end;

end.
