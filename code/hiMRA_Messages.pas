unit hiMRA_Messages;

interface

uses Windows,Kol,Share,Debug,mra_client;

type
  THIMRA_Messages = class(TDebug)
   private
    mra:TMailClient;
    procedure SetMailAgent(agent:TMailClient);
    procedure OnMessageSended(Sender: TObject; Reason, MsgID: DWORD; EMail: string);
   public
    _data_Text:THI_Event;
    _data_Mail:THI_Event;
    _event_onSendMessage:THI_Event;

    procedure _work_doSendMessage(var _Data:TData; Index:word);
    property _prop_MailAgent:TMailClient read mra write SetMailAgent;
  end;

implementation

procedure THIMRA_Messages.SetMailAgent(agent:TMailClient);
begin
  mra := agent;
  mra.OnMessageSended := OnMessageSended;
end;

procedure THIMRA_Messages.OnMessageSended;
var
  dt,d:TData;
  f:PData;
begin
   dtString(dt, EMail);
   dtInteger(d, Reason);
   AddMTData(@dt, @d, f);
   dtInteger(d, integer(MsgID));
   AddMTData(@dt, @d, f);
   _hi_onEvent(_event_onSendMessage, dt);
   FreeData(f);
end;

procedure THIMRA_Messages._work_doSendMessage;
var e,t:string;
begin
   e := ReadString(_Data, _data_Mail, '');
   t := ReadString(_Data, _data_text, '');
   _prop_MailAgent.SendMessage(e, t);
end;

end.
