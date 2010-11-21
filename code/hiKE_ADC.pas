unit hiKE_ADC;

interface

uses Kol,Share,Debug,hiKE_Connect;

type
  THIKE_ADC = class(TDebug)
   private
    fKEU:IKE_USB;
    
    procedure SetKE_Device(value:IKE_USB);
    procedure _OnADCValue(const value:string); 
   public
    _prop_Freq:integer;
    _prop_Type:byte;

    _data_Freq:THI_Event;
    _event_onGetADCValue:THI_Event;

    procedure _work_doGetADCValue(var _Data:TData; Index:word);
    procedure _work_doADCFreq(var _Data:TData; Index:word);
    property _prop_KE_Device:IKE_USB write SetKE_Device;
  end;

implementation

procedure THIKE_ADC._work_doGetADCValue;
begin
   if fKEU <> nil then
     fKEU.GetADCValue;
end;

procedure THIKE_ADC._work_doADCFreq;
begin
   if fKEU <> nil then
     fKEU.SetADCFreq(ReadInteger(_Data, _data_Freq, _prop_Freq));
end;

procedure THIKE_ADC.SetKE_Device(value:IKE_USB);
begin
  if value <> nil then
    value.OnADCValue := _OnADCValue;     
  fKEU := value; 
end;

procedure THIKE_ADC._OnADCValue(const value:string);
var v:integer;
begin
   v := str2int(value);
   if _prop_Type = 0 then
     _hi_onEvent(_event_onGetADCValue, v)
   else
     _hi_onEvent(_event_onGetADCValue, v/1023*5.0); 
end;

end.
