unit hiMRA_MessageReciever;

interface

uses Windows,Kol,Share,Debug,mra_client;

type
  THIMRA_MessageReciever = class(TDebug)
   private
    mra:TMailClient;
    procedure SetMailAgent(agent:TMailClient);
    procedure onMessage(Sender: TObject; MsgID: DWORD; From, Text:string; IsRTF: Boolean);
    procedure onOfflineMessage(Sender: TObject; MsgID: DWORD; From, Text: string);
    procedure onSystemMessage(Sender: TObject; MsgID: DWORD; From, Text: string);
    procedure onContactAuthorize(Sender: TObject; MsgID: DWORD; From, Text: string);
   public
    _event_onSystemMessage:THI_Event;
    _event_onOfflineMessage:THI_Event;
    _event_onMessage:THI_Event;
    _event_onContactAuthorize:THI_Event;
    property _prop_MailAgent:TMailClient read mra write SetMailAgent;
  end;

implementation

procedure THIMRA_MessageReciever.SetMailAgent(agent:TMailClient);
begin
  mra := agent;
  mra.onMessage := onMessage;
  mra.onOfflineMessage := onOfflineMessage;
  mra.onSystemMessage := onSystemMessage;
  mra.onContactAuthorize := onContactAuthorize;
end;

procedure THIMRA_MessageReciever.onMessage(Sender: TObject; MsgID: DWORD; From, Text:string; IsRTF: Boolean);
var
  dt,d:TData;
  f:PData;
begin
   dtString(dt, From);
   dtString(d, Text);
   AddMTData(@dt, @d, f);
   dtInteger(d, integer(MsgID));
   AddMTData(@dt, @d, f);
   _hi_onEvent(_event_onMessage, dt);
   FreeData(f);
   mra.SendMessageRecv(From, MsgID);
end;

procedure THIMRA_MessageReciever.onOfflineMessage(Sender: TObject; MsgID: DWORD; From, Text: string);
var
  dt,d:TData;
  f:PData;
begin
   dtString(dt, From);
   dtString(d, Text);
   AddMTData(@dt, @d, f);
   dtInteger(d, integer(MsgID));
   AddMTData(@dt, @d, f);
   _hi_onEvent(_event_onOfflineMessage, dt);
   FreeData(f);
end;

procedure THIMRA_MessageReciever.onSystemMessage(Sender: TObject; MsgID: DWORD; From, Text: string);
var
  dt,d:TData;
  f:PData;
begin
   dtString(dt, From);
   dtString(d, Text);
   AddMTData(@dt, @d, f);
   dtInteger(d, integer(MsgID));
   AddMTData(@dt, @d, f);
   _hi_onEvent(_event_onSystemMessage, dt);
   FreeData(f);
end;

procedure THIMRA_MessageReciever.onContactAuthorize(Sender: TObject; MsgID: DWORD; From, Text: string);
var
  dt,d:TData;
  f:PData;
begin
   dtString(dt, From);
   dtString(d, Text);
   AddMTData(@dt, @d, f);
   dtInteger(d, integer(MsgID));
   AddMTData(@dt, @d, f);
   _hi_onEvent(_event_onContactAuthorize, dt);
   FreeData(f);
end;

end.
