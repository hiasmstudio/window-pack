unit hiMRA_ContactAdd;

interface

uses Windows,Kol,Share,Debug,mra_client;

type
  THIMRA_ContactAdd = class(TDebug)
   private
    mra:TMailClient;
    procedure SetMailAgent(agent:TMailClient);
    procedure OnAddContact(Sender: TObject; GroupID, UserID: DWORD; EMail, Nick:string);
    procedure OnAddContactError(Sender: TObject; GroupID, UserID: DWORD; EMail, Nick: string; Reason: DWORD);
   public
    _data_GroupID:THI_Event;
    _data_Nick:THI_Event;
    _data_Mail:THI_Event;
    _event_onError:THI_Event;
    _event_onAdd:THI_Event;

    procedure _work_doAdd(var _Data:TData; Index:word);
    property _prop_MailAgent:TMailClient read mra write SetMailAgent;
  end;

implementation

procedure THIMRA_ContactAdd.SetMailAgent(agent:TMailClient);
begin
  mra := agent;
  mra.OnAddContact := OnAddContact;
  mra.OnAddContactError := OnAddContactError;
end;

procedure THIMRA_ContactAdd.OnAddContact(Sender: TObject; GroupID, UserID: DWORD; EMail, Nick:string);
var
  dt,d:TData;
  f:PData;
begin
   dtString(dt, EMail);
   dtString(d, Nick);
   AddMTData(@dt, @d, f);
   dtInteger(d, integer(GroupID));
   AddMTData(@dt, @d, f);
   dtInteger(d, integer(UserID));
   AddMTData(@dt, @d, f);
   _hi_onEvent(_event_onAdd, dt);
   FreeData(f);
end;

procedure THIMRA_ContactAdd.OnAddContactError(Sender: TObject; GroupID, UserID: DWORD; EMail, Nick: string; Reason: DWORD);
var
  dt,d:TData;
  f:PData;
begin
   dtString(dt, EMail);
   dtString(d, Nick);
   AddMTData(@dt, @d, f);
   dtInteger(d, integer(GroupID));
   AddMTData(@dt, @d, f);
   dtInteger(d, integer(UserID));
   AddMTData(@dt, @d, f);
   dtInteger(d, integer(Reason));
   AddMTData(@dt, @d, f);
   _hi_onEvent(_event_onError, dt);
   FreeData(f);
end;

procedure THIMRA_ContactAdd._work_doAdd;
var m,n:string;
    g:integer;
begin
  m := ReadString(_Data, _data_Mail, '');
  n := ReadString(_Data, _data_Nick, '');
  g := ReadInteger(_Data, _data_GroupID, 0);
  mra.AddContact(m, n, g);
end;

end.
