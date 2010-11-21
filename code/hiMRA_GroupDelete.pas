unit hiMRA_GroupDelete;

interface

uses Windows,Kol,Share,Debug,mra_client;

type
  THIMRA_GroupDelete = class(TDebug)
   private
    mra:TMailClient;
    
    procedure SetMailAgent(agent:TMailClient);
    procedure OnModifyContactGroup(Sender: TObject; GroupID: DWORD; Text: string);
    procedure OnModifyContactGroupError(Sender: TObject; GroupID: DWORD; Text: string; Reason: DWORD);
   public
    _data_ID:THI_Event;
    _data_Name:THI_Event;
    _event_onError:THI_Event;
    _event_onDelete:THI_Event;

    procedure _work_doDelete(var _Data:TData; Index:word);
    property _prop_MailAgent:TMailClient read mra write SetMailAgent;
  end;

implementation

procedure THIMRA_GroupDelete.SetMailAgent(agent:TMailClient);
begin
  mra := agent;
  mra.OnModifyContactGroup := OnModifyContactGroup;
  mra.OnModifyContactGroupError := OnModifyContactGroupError;
end;

procedure THIMRA_GroupDelete.OnModifyContactGroup(Sender: TObject; GroupID: DWORD; Text: string);
var
  dt,d:TData;
  f:PData;
begin
   dtString(dt, Text);
   dtInteger(d, GroupID);
   AddMTData(@dt, @d, f);
   _hi_onEvent(_event_onDelete, dt);
   FreeData(f);
end;

procedure THIMRA_GroupDelete.OnModifyContactGroupError;
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

procedure THIMRA_GroupDelete._work_doDelete;
var n:string;
    id:integer;
begin
   n := ReadString(_Data, _data_Name);
   id := ReadInteger(_Data, _data_ID); 
   mra.DeleteGroup(n, id, 20);
end;

end.
