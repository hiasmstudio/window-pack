unit hiKE_LineDirection;

interface

uses Kol,Share,Debug,hiKE_Connect;

type
  THIKE_LineDirection = class(TDebug)
   private
    fKEU:IKE_USB;
    
    procedure SetKE_Device(value:IKE_USB);
    procedure _onLineDirection(const value:string); 
   public
    _prop_Line:integer;
    _prop_Direction:byte;
    _prop_SaveToMEM:boolean;

    _data_Direction:THI_Event;
    _data_Line:THI_Event;
    _event_onSetDirection:THI_Event;

    procedure _work_doSetDirection(var _Data:TData; Index:word);
    property _prop_KE_Device:IKE_USB write SetKE_Device;
  end;

implementation

procedure THIKE_LineDirection.SetKE_Device(value:IKE_USB);
begin
  if value <> nil then
    value.onLineDirection := _onLineDirection;     
  fKEU := value; 
end;

procedure THIKE_LineDirection._work_doSetDirection;
var l,d:integer;
begin
   l := ReadInteger(_Data, _data_Line, _prop_Line); 
   d := ReadInteger(_Data, _data_Direction, _prop_Direction);
   if fKEU <> nil then
     fKEU.SetLineDirection(l, d, _prop_SaveToMEM);
end;

procedure THIKE_LineDirection._onLineDirection(const value:string);
begin
   _hi_onEvent(_event_onSetDirection)
end;

end.
