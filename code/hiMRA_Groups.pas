unit hiMRA_Groups;

interface

uses Windows,Kol,Share,Debug,mra_client;

type
  THIMRA_Groups = class(TDebug)
   private
    mra:TMailClient;
    procedure SetMailAgent(agent:TMailClient);
    procedure onContactGroup(Sender: TObject; GroupID: DWORD; Text: string);
   public
    _event_onEnum:THI_Event;
    
    property _prop_MailAgent:TMailClient read mra write SetMailAgent;
  end;

implementation

procedure THIMRA_Groups.SetMailAgent(agent:TMailClient);
begin
  mra := agent;
  mra.OnContactGroup := OnContactGroup;
end;

procedure THIMRA_Groups.OnContactGroup;
var
  dt,d:TData;
  f:PData;
begin
   dtString(dt, Text);
   dtInteger(d, GroupID);
   AddMTData(@dt, @d, f);
   _hi_onEvent(_event_onEnum, dt);
   FreeData(f);
end;

end.
