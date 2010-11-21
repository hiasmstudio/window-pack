unit hiMRA_Authorize;

interface

uses Kol,Share,Debug,mra_client;

type
  THIMRA_Authorize = class(TDebug)
   private
     procedure OnSuccesAuthorize(sender:TObject); 
     procedure OnErrorAuthorize(Sender: TObject; Reason: string);
   public
    _prop_MailAgent:TMailClient;
    _prop_Mail:string;
    _prop_Password:string;
    _prop_status:string;

    _data_Password:THI_Event;
    _data_Mail:THI_Event;
    _data_status:THI_Event;
    _event_onFailed:THI_Event;
    _event_onAuthorize:THI_Event;

    destructor Destroy; override;
    procedure _work_doAuthorize(var _Data:TData; Index:word);
  end;

implementation

destructor THIMRA_Authorize.Destroy;
begin
  _prop_MailAgent.OnSuccesAuthorize := nil;
  inherited;
end;

procedure THIMRA_Authorize.OnSuccesAuthorize(sender:TObject); 
begin
  _hi_onEvent(_event_onAuthorize);
end;

procedure THIMRA_Authorize.OnErrorAuthorize(Sender: TObject; Reason: string);
begin
  _hi_onEvent(_event_onFailed, Reason);
end;

procedure THIMRA_Authorize._work_doAuthorize;
begin
  _prop_MailAgent.Mail := ReadString(_Data, _data_mail, _prop_Mail);
  _prop_MailAgent.PassWord := ReadString(_Data, _data_Password, _prop_Password);
  _prop_MailAgent.OnSuccesAuthorize := OnSuccesAuthorize;
  _prop_MailAgent.OnErrorAuthorize := OnErrorAuthorize;
  _prop_MailAgent.Authorize(ReadString(_Data, _data_status, _prop_status));  
end;

end.
