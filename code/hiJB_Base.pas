unit hiJB_Base;

interface

uses Kol,Share,Debug,JabberClient;

type
  THIJB_Base = class(TDebug)
   private
     client:TJabberClient;
     FUser,FHost,FPlace,FPass:string;

     procedure _OnWelcome(client:TJabberClient);
     procedure _OnAuth(client:TJabberClient; success:boolean);
     procedure _OnConnect(client:TJabberClient);
   public
     _prop_Name:string;
     _prop_IP:string;
     _prop_port:integer;
     _prop_JID:string;
     _prop_Password:string;
     
     _data_IP:THI_Event;
     _data_port:THI_Event;
     _data_JID:THI_Event;
     _data_Password:THI_Event;
          
     _event_onConnect:THI_Event;
     _event_onError:THI_Event;
     
     constructor Create;
     destructor Destroy; override;
     procedure _work_doConnect(var _Data:TData; index:word);
     property getInterfaceJabber:TJabberClient read client;  
  end;

implementation

constructor THIJB_Base.Create;
begin
   inherited;
 
   client := TJabberClient.Create;
   client.OnWelcome := _OnWelcome;
   client.OnAuth := _OnAuth;
   client.OnConnect := _OnConnect;
end;

destructor THIJB_Base.Destroy;
begin
  client.Destroy;
  inherited;
end;

procedure THIJB_Base._work_doConnect(var _Data:TData; index:word);
var ip:string;
    port:integer;
begin
   client.disconnect;
   ip := ReadString(_Data, _data_IP, _prop_IP);
   port := ReadInteger(_Data, _data_Port, _prop_Port);

   FPlace := ReadString(_Data, _data_JID, _prop_JID);
   FUser := GetTok(FPlace, '@');
   FHost := GetTok(FPlace, '/');
   FPass := ReadString(_Data, _data_Password, _prop_Password);

   client.connect(ip, port);
end;

procedure THIJB_Base._OnWelcome(client:TJabberClient);
begin
  client.auth(FUser, FPass, FPlace);
end;

procedure THIJB_Base._OnAuth(client:TJabberClient; success:boolean);
begin
  if success then
    begin
      client.roster;
      client.status('', '');
    end
end;

procedure THIJB_Base._OnConnect(client:TJabberClient);
begin
  client.welcome(FHost);
end;

end.
