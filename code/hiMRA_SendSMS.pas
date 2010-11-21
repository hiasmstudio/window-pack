unit hiMRA_SendSMS;

interface

uses Windows,Kol,Share,Debug,mra_client;

type
  THIMRA_SendSMS = class(TDebug)
   private
   public
    _prop_MailAgent:TMailClient;
    _prop_Phone:string;
    _prop_Text:string;

    _data_Text:THI_Event;
    _data_Phone:THI_Event;
    _event_onSendSMS:THI_Event;

    procedure _work_doSendSMS(var _Data:TData; Index:word);
  end;

implementation

procedure THIMRA_SendSMS._work_doSendSMS;
var p,t:string;
begin
  p := ReadString(_Data, _data_Phone, _prop_Phone);
  t := ReadString(_Data, _data_Text, _prop_Text);
  _prop_MailAgent.SendSMS(p, t);
  _hi_onEvent(_event_onSendSMS);
end;

end.
