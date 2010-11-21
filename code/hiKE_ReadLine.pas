unit hiKE_ReadLine;

interface

uses Kol,Share,Debug,hiKE_Connect;

type
  THIKE_ReadLine = class(TDebug)
   private
    fKEU:IKE_USB;
    
    procedure SetKE_Device(value:IKE_USB);
    procedure _OnReadLine(const answer:string); 
   public
    _prop_Line:integer;

    _data_Line:THI_Event;
    _event_onError:THI_Event;
    _event_onReadLine:THI_Event;

    procedure _work_doReadLine(var _Data:TData; Index:word);
    property _prop_KE_Device:IKE_USB write SetKE_Device;
  end;

implementation

procedure THIKE_ReadLine.SetKE_Device(value:IKE_USB);
begin
  if value <> nil then
    value.OnReadLine := _OnReadLine;     
  fKEU := value; 
end;

procedure THIKE_ReadLine._OnReadLine(const answer:string);
var s,l:string;
    dt,d:TData;
    f:PData;
begin
   if answer = 'WRONGLINE' then
     _hi_onEvent(_event_onError)
   else
     if pos(',', answer) > 0 then
      begin
        s := answer;
        l := GetTok(s, ',');
        dtInteger(dt, str2int(l));
        dtInteger(d, ord(s[1]) - ord('0'));
        AddMTData(@dt, @d, f);
        _hi_onEvent(_event_onReadLine, dt);
        FreeData(f);
      end
     else _hi_onEvent(_event_onReadLine, answer);  
end;

procedure THIKE_ReadLine._work_doReadLine;
begin
   if fKEU <> nil then
     fKEU.ReadLine(ReadInteger(_Data, _data_Line, _prop_Line));
end;

end.
