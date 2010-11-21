unit hiKE_WriteLine;

interface

uses Kol,Share,Debug,hiKE_Connect;

type
  THIKE_WriteLine = class(TDebug)
   private
    fKEU:IKE_USB;
    
    procedure SetKE_Device(value:IKE_USB);
    procedure _OnWriteLine(const answer:string); 
   public
    _prop_Line:integer;

    _data_Value:THI_Event;
    _data_Line:THI_Event;
    _event_onError:THI_Event;
    _event_onWriteLine:THI_Event;

    procedure _work_doWriteLine(var _Data:TData; Index:word);
    property _prop_KE_Device:IKE_USB write SetKE_Device;
  end;

implementation

procedure THIKE_WriteLine._work_doWriteLine;
var l,v:integer;
begin
   l := ReadInteger(_Data, _data_Line, _prop_Line);
   v := ReadInteger(_Data, _data_Value);
   if v <> 0 then v := 1;
   if fKEU <> nil then
     fKEU.WriteLine(l, v);
end;

procedure THIKE_WriteLine.SetKE_Device(value:IKE_USB);
begin
  if value <> nil then
    value.OnWriteLine := _OnWriteLine;     
  fKEU := value; 
end;

procedure THIKE_WriteLine._OnWriteLine(const answer:string);
begin
   if answer = 'OK' then
     _hi_onEvent(_event_onWriteLine)
   else
     _hi_onEvent(_event_onError); 
end;

end.
