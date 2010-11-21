unit hiMRA_GroupAdd;

interface

uses Windows,Kol,Share,Debug,mra_client;

type
  THIMRA_GroupAdd = class(TDebug)
   private
    mra:TMailClient;
    
    procedure SetMailAgent(agent:TMailClient);
    procedure OnAddContactGroup(Sender: TObject; GroupID: DWORD; Text: string);
    procedure OnAddContactGroupError(Sender: TObject; GroupID: DWORD; Text: string; Reason: DWORD);
   public
    _data_Name:THI_Event;
    _event_onError:THI_Event;
    _event_onAdd:THI_Event;

    procedure _work_doAdd(var _Data:TData; Index:word);
    property _prop_MailAgent:TMailClient read mra write SetMailAgent;
  end;

implementation

procedure THIMRA_GroupAdd.SetMailAgent(agent:TMailClient);
begin
  mra := agent;
  mra.OnAddContactGroup := OnAddContactGroup;
  mra.OnAddContactGroupError := OnAddContactGroupError;
end;

procedure THIMRA_GroupAdd.OnAddContactGroup(Sender: TObject; GroupID: DWORD; Text: string);
var
  dt,d:TData;
  f:PData;
begin
   dtString(dt, Text);
   dtInteger(d, GroupID);
   AddMTData(@dt, @d, f);
   _hi_onEvent(_event_onAdd, dt);
   FreeData(f);
end;

procedure THIMRA_GroupAdd.OnAddContactGroupError;
var
  dt,d:TData;
  f:PData;
begin
   dtString(dt, Text);
   dtInteger(d, GroupID);
   AddMTData(@dt, @d, f);
   dtInteger(d, Reason);
   AddMTData(@dt, @d, f);
   _hi_onEvent(_event_onError, dt);
   FreeData(f);
end;

procedure THIMRA_GroupAdd._work_doAdd;
begin
   mra.AddGroup(ReadString(_Data, _data_Name), 20);
end;

end.
