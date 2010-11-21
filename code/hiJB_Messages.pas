unit hiJB_Messages;

interface

uses Kol,Share,Debug,JabberClient;

type
  THIJB_Messages = class(TDebug)
   private
     client:TJabberClient;
    
     procedure SetClient(value:TJabberClient);
     procedure _OnMessage(client:TJabberClient; const from, me, text:string);
   public
    _prop_JID:string;
    _prop_Text:string;

    _data_Text:THI_Event;
    _data_JID:THI_Event;
    _event_onReceive:THI_Event;
    _event_onSend:THI_Event;

    procedure _work_doSend(var _Data:TData; Index:word);
    property _prop_Jabber:TJabberClient read client write SetClient;
  end;

implementation

procedure THIJB_Messages._work_doSend;
var jid,msg:string;
begin
   jid := ReadString(_Data, _data_JID, _prop_JID);
   msg := ReadString(_Data, _data_Text, _prop_Text);  
   client.send_msg(jid, msg);
   _hi_onEvent(_event_onSend, msg);
end;

procedure THIJB_Messages.SetClient(value:TJabberClient);
begin
  client := value;
  client.OnMessage := _OnMessage;
end;

procedure THIJB_Messages._OnMessage(client:TJabberClient; const from, me, text:string);
var
    dt:TData;
    mt:PMT;
begin
   mt := mt_make(dt);
   dtString(dt, from);
   mt_string(mt, text); 
   _hi_onEvent(_event_onReceive, dt);
   mt_free(mt);
end;

end.
