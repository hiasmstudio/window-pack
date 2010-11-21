unit hiJB_XMLConsole;

interface

uses Kol,Share,Debug,JabberClient;

type
  THIJB_XMLConsole = class(TDebug)
   private
    client:TJabberClient;
    
    procedure SetClient(value:TJabberClient);
    procedure _OnXMLTrace(client:TJabberClient; const xml:string; direction:boolean);
   public
    _event_onReceive:THI_Event;
    _event_onSend:THI_Event;
    
    property _prop_Jabber:TJabberClient read client write SetClient;
  end;

implementation

procedure THIJB_XMLConsole.SetClient(value:TJabberClient);
begin
  client := value;
  client.OnXMLTrace := _OnXMLTrace;
end;

procedure THIJB_XMLConsole._OnXMLTrace(client:TJabberClient; const xml:string; direction:boolean);
begin
   if direction then
     _hi_onEvent(_event_onSend, xml)
   else
     _hi_onEvent(_event_onReceive, xml)
end;

end.
