unit hiKE_LineState;

interface

uses Kol,Share,Debug,hiKE_Connect;

type
  THIKE_LineState = class(TDebug)
   private
    fKEU:IKE_USB;
    
    procedure SetKE_Device(value:IKE_USB);
    procedure _OnLineState(const value:string); 
   public
    _prop_Line:integer;
    _prop_Location:byte;

    _data_Line:THI_Event;
    _event_onLineState:THI_Event;

    procedure _work_doGetLineDirection(var _Data:TData; Index:word);
    property _prop_KE_Device:IKE_USB write SetKE_Device;
  end;

implementation

procedure THIKE_LineState._OnLineState;
var s,n:string;
    dt,d:TData;
    f:PData;
begin
  s := value; 
  if pos(',', value) > 0 then
    begin
      n := GetTok(s, ',');
      dtInteger(dt, str2int(n));
      dtInteger(d, ord(s[1]) - ord('0'));
      AddMTData(@dt, @d, f);
      _hi_onEvent(_event_onLineState, dt);
      FreeData(f);
    end
  else
    _hi_onEvent(_event_onLineState, value);
end;

procedure THIKE_LineState.SetKE_Device(value:IKE_USB);
begin
  if value <> nil then
    value.OnLineState := _OnLineState;     
  fKEU := value; 
end;

procedure THIKE_LineState._work_doGetLineDirection;
begin
   if fKEU <> nil then
     fKEU.GetLineDirection(ReadInteger(_Data, _data_Line, _prop_Line), _prop_Location = 1);
end;

end.
