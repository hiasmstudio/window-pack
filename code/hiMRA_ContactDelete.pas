unit hiMRA_ContactDelete;

interface

uses Windows,Kol,Share,Debug,mra_client;

type
  THIMRA_ContactDelete = class(TDebug)
   private
    mra:TMailClient;
    procedure SetMailAgent(agent:TMailClient);
    procedure OnModifyContact(Sender: TObject; GroupID, UserID: DWORD; EMail, Nick:string);
    procedure OnModifyContactError(Sender: TObject; GroupID, UserID: DWORD;
                                                        EMail, Nick: string; Reason: DWORD);
   public
    _data_GroupID:THI_Event;
    _data_Nick:THI_Event;
    _data_Mail:THI_Event;
    _event_onError:THI_Event;
    _event_onDelete:THI_Event;

    procedure _work_doDelete(var _Data:TData; Index:word);
    property _prop_MailAgent:TMailClient read mra write SetMailAgent;
  end;

implementation

procedure THIMRA_ContactDelete.SetMailAgent(agent:TMailClient);
begin
  mra := agent;
  mra.OnModifyContact := OnModifyContact;
  mra.OnModifyContactError := OnModifyContactError;
end;

procedure THIMRA_ContactDelete.OnModifyContact;
begin
  _hi_onEvent(_event_onDelete, EMail);
end;

procedure THIMRA_ContactDelete.OnModifyContactError;
begin
  _hi_onEvent(_event_onError); 
end;

procedure THIMRA_ContactDelete._work_doDelete;
var e,n:string;
    g,i:integer;
begin
  e := ReadString(_Data, _data_Mail);
  n := ReadString(_Data, _data_Nick);
  g := ReadInteger(_Data, _data_GroupID);
  mra.DeleteContact(e,n,33,g);
end;

end.
