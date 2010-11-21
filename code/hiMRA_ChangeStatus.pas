unit hiMRA_ChangeStatus;

interface

uses Windows,Kol,Share,Debug,mra_client;

type
  THIMRA_ChangeStatus = class(TDebug)
   private
   public
    _prop_MailAgent:TMailClient;

    _data_Status:THI_Event;
    _event_onChangeStatus:THI_Event;

    procedure _work_doChangeStatus(var _Data:TData; Index:word);
  end;

implementation

procedure THIMRA_ChangeStatus._work_doChangeStatus;
var dt:TData;
begin
   dt := _Data;
   _prop_MailAgent.Status := TStatusClient(ReadInteger(_Data, _data_Status, 0));
   _hi_onEvent(_event_onChangeStatus, dt);
end;

end.
