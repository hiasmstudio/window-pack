unit hiMRA_Authorize;

interface

uses Kol,Share,Debug,mra_client;

type
  THIMRA_Authorize = class(TDebug)
   private
	 NickName: string;
	 MailTotal: integer;
	 MailUnread: integer;
	 EndPoint: string;
     mra:TMailClient;
     procedure SetMailAgent(agent:TMailClient);
     procedure OnSuccesAuthorize(sender:TObject); 
     procedure OnErrorAuthorize(Sender: TObject; Reason: string);
     procedure OnKeyRead(Sender: TObject; Key, Value: string);     
   public
//    _prop_MailAgent:TMailClient;
    _prop_Mail:string;
    _prop_Password:string;
    _prop_status:string;

    _data_Password:THI_Event;
    _data_Mail:THI_Event;
    _data_status:THI_Event;
    _event_onFailed:THI_Event;
    _event_onAuthorize:THI_Event;
    _event_onUserInfo:THI_Event;    

    property _prop_MailAgent:TMailClient read mra write SetMailAgent;
	  
    destructor Destroy; override;
    procedure _work_doAuthorize(var _Data:TData; Index:word);
  end;

implementation

destructor THIMRA_Authorize.Destroy;
begin
  _prop_MailAgent.OnSuccesAuthorize := nil;
  inherited;
end;

procedure THIMRA_Authorize.SetMailAgent(agent:TMailClient);
begin
  mra := agent;
  mra.OnKeyRead := OnKeyRead;  
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

procedure THIMRA_Authorize.OnKeyRead;
var
  dt,d:TData;
  f:PData;
begin
  if Uppercase(Key) = 'MRIM.NICKNAME' then
    NickName := Value
  else if Uppercase(Key) = 'CLIENT.ENDPOINT' then
    EndPoint := Value
  else if Uppercase(Key) = 'MESSAGES.TOTAL' then
    MailTotal := Str2Int(Value)
  else if Uppercase(Key) = 'MESSAGES.UNREAD' then
	begin
      MailUnread := Str2Int(Value);
      dtString(dt, NickName);
      dtString(d, EndPoint);
      AddMTData(@dt, @d, f);
      dtInteger(d, MailTotal);
      AddMTData(@dt, @d, f);
      dtInteger(d, MailUnread);
      AddMTData(@dt, @d, f);
      _hi_onEvent(_event_onUserInfo, dt);
      FreeData(f);      
    end;  
end;

end.
