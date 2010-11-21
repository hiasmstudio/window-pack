unit hiKE_Reset;

interface

uses Kol,Share,Debug,hiKE_Connect;

type
  THIKE_Reset = class(TDebug)
   private
    fKEU:IKE_USB;
    
    procedure SetKE_Device(value:IKE_USB);
    procedure _OnResetDevice(const value:string); 
   public
    _event_onReset:THI_Event;

    procedure _work_doReset(var _Data:TData; Index:word);
    property _prop_KE_Device:IKE_USB write SetKE_Device;
  end;

implementation

procedure THIKE_Reset.SetKE_Device(value:IKE_USB);
begin
  if value <> nil then
    value.OnResetDevice := _OnResetDevice;     
  fKEU := value; 
end;

procedure THIKE_Reset._OnResetDevice(const value:string);
begin
   _hi_onEvent(_event_onReset); 
end;

procedure THIKE_Reset._work_doReset;
begin
   if fKEU <> nil then
     fKEU.ResetDevice();
end;

end.
