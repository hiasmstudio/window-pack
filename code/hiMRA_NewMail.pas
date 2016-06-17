unit hiMRA_NewMail;

interface

uses windows,Kol,Share,Debug,mra_client;

type
  THIMRA_NewMail = class(TDebug)
   private
    mra:TMailClient;
    procedure SetMailAgent(agent:TMailClient);
    procedure OnMailBoxStatusNew(Sender: TObject; MsgNum: DWORD; MailSender, Subject: string; TimeStamp: DWORD);
    procedure OnMailBoxStatus(Sender: TObject; Reason: DWORD);
   public
    _event_onNewMailReceive:THI_Event;
    _event_onChangeMailCount:THI_Event;
    
    property _prop_MailAgent:TMailClient read mra write SetMailAgent;
  end;

implementation

procedure THIMRA_NewMail.SetMailAgent(agent:TMailClient);
begin
  mra := agent;
  mra.OnMailBoxStatusNew := OnMailBoxStatusNew;
  mra.OnMailBoxStatus := OnMailBoxStatus;
end;

procedure THIMRA_NewMail.OnMailBoxStatusNew;
var
  dt,d:TData;
  f:PData;
begin
   dtString(dt, MailSender);
   dtString(d, Subject);
   AddMTData(@dt, @d, f);
   dtInteger(d, integer(TimeStamp));
   AddMTData(@dt, @d, f);
   dtInteger(d, integer(MsgNum));
   AddMTData(@dt, @d, f);
   _hi_onEvent(_event_onNewMailReceive, dt);
   FreeData(f);
end;

procedure THIMRA_NewMail.OnMailBoxStatus;
begin
   _hi_onEvent(_event_onChangeMailCount, integer(Reason));
end;

end.
