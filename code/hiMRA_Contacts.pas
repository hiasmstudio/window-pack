unit hiMRA_Contacts;

interface

uses Windows,Kol,Share,Debug,mra_client;

type
  THIMRA_Contacts = class(TDebug)
   private
    mra:TMailClient;
    procedure SetMailAgent(agent:TMailClient);
    procedure onContact(Sender: TObject; GroupID: DWORD; EMail, Nick: string; 
                        Status: TStatusClient; InvisState: TInvisStateClient);
    procedure onStatusChange(Sender: TObject; EMail: string; Status:TStatusClient);                    
   public
    _prop_AuthText:string;
   
    _data_Mail:THI_Event;
    _data_AuthText:THI_Event;
    
    _event_onEnum:THI_Event;
    _event_onStatusChange:THI_Event;
    
    procedure _work_doContactAuthorize(var _Data:TData; index:word);
    procedure _work_doAuthorizeMe(var _Data:TData; index:word);
    property _prop_MailAgent:TMailClient read mra write SetMailAgent;
  end;

implementation

procedure THIMRA_Contacts._work_doContactAuthorize(var _Data:TData; index:word);
begin
   mra.ContactAuthorize(ReadString(_Data, _data_Mail, ''));
end;

procedure THIMRA_Contacts._work_doAuthorizeMe(var _Data:TData; index:word);
var m,t:string;
begin
   m := ReadString(_Data, _data_Mail, '');
   t := ReadString(_Data, _data_AuthText, _prop_AuthText);
   mra.AuthorizeMe(m, t);
end;

procedure THIMRA_Contacts.SetMailAgent(agent:TMailClient);
begin
  mra := agent;
  mra.onContact := onContact;
  mra.onStatusChange := onStatusChange;
end;

procedure THIMRA_Contacts.onContact;
var
  dt,d:TData;
  f:PData;
begin
   dtString(dt, EMail);
   dtString(d, Nick);
   AddMTData(@dt, @d, f);
   dtInteger(d, integer(GroupID));
   AddMTData(@dt, @d, f);
   dtInteger(d, integer(Status));
   AddMTData(@dt, @d, f);
   dtInteger(d, integer(InvisState));
   AddMTData(@dt, @d, f);
   _hi_onEvent(_event_onEnum, dt);
   FreeData(f);
end;

procedure THIMRA_Contacts.onStatusChange(Sender: TObject; EMail: string; Status:TStatusClient);
var
  dt,d:TData;
  f:PData;
begin
   dtString(dt, EMail);
   dtInteger(d, integer(Status));
   AddMTData(@dt, @d, f);
   _hi_onEvent(_event_onStatusChange, dt);
   FreeData(f);
end;

end.
