unit hiJB_Subscribe;

interface

uses Kol,Share,Debug,JabberClient;

type
  THIJB_Subscribe = class(TDebug)
   private
     client:TJabberClient;
     
     procedure SetClient(value:TJabberClient);
     procedure _OnSubscribe(client:TJabberClient; const from, stype:string);
   public
    _prop_State:integer;
    
    _data_JID:THI_Event;
    _data_State:THI_Event;
    _event_onSubscribe:THI_Event;

    procedure _work_doSubscribe(var _Data:TData; Index:word);
    procedure _work_doRemove(var _Data:TData; Index:word);

    property _prop_Jabber:TJabberClient read client write SetClient;
  end;

implementation

procedure THIJB_Subscribe.SetClient(value:TJabberClient);
begin
  client := value;
  client.OnSubscribe := _OnSubscribe;
end;

procedure THIJB_Subscribe._OnSubscribe(client:TJabberClient; const from, stype:string);
var 
    dt:TData;
    mt:PMT;
begin
   mt := mt_make(dt);
   dtString(dt, from);
   mt_string(mt, stype); 
   _hi_onEvent(_event_onSubscribe, dt);
   mt_free(mt);
end;

procedure THIJB_Subscribe._work_doSubscribe;
var jid:string;
    state:integer;
begin
   jid := ReadString(_Data, _data_JID);
   state := ReadInteger(_Data, _data_State, _prop_State);
   case state of
     0: client.subscribe(jid);
     1: client.subscribed(jid);
     2: client.unsubscribe(jid);
     3: client.unsubscribed(jid);
   end;
end;

procedure THIJB_Subscribe._work_doRemove(var _Data:TData; Index:word);
begin
    client.remove(ReadString(_Data, _data_JID));
end;

end.
