unit hiDynDNS;

interface

uses TCP,Share,Windows,Kol,Debug;

type
  THIDynDNS = class(TDebug)
   private
    Sock:TSocket;
    res:string;
    procedure onDis(Socket:TSocket);
    procedure onRead(Socket:TSocket; buf:pointer; len:cardinal);
   public
    _prop_Login:string;
    _prop_Password:string;
    _prop_Host:string;
    _data_IP:THI_Event;
    _data_Login:THI_Event;
    _data_Password:THI_Event;
    _data_Host:THI_Event;
    _event_onUpdate:THI_Event;

    destructor Destroy; override;
    procedure _work_doUpdate(var _Data:TData; Index:word);
  end;

implementation

uses hiCharset;

destructor THIDynDNS.Destroy;
begin
   if Sock <> nil then
     Sock.Destroy;
   inherited;
end;

procedure THIDynDNS.onDis(Socket:TSocket);
var list:PStrList;
    i:integer;
begin
   list := NewStrList;
   list.Text := res;
   for i := 0 to list.count-1 do
    if list.items[i] = '' then
     begin
       _hi_OnEvent(_event_onUpdate, list.items[i+1]);
       break;
     end;
end;

procedure THIDynDNS.onRead;
begin
    res := res + copy(PChar(buf), 1, len);
end;

procedure THIDynDNS._work_doUpdate;
var
   req,code:string;
begin
   if Sock = nil then
    begin
     Sock := TSocket.Create;
     Sock.OnDisconnect := OnDis;
     Sock.OnRead := OnRead;
    end;
   Sock.StartClient(80, '63.208.196.94'); //'members.dyndns.org');
   req := 'GET /nic/update?system=dyndns&hostname=%host%&myip=%ip%&wildcard=OFF&mx=mail.exchanger.ext&backmx=NO&offline=NO HTTP/1.0'#13#10 +
          'Host: members.dyndns.org'#13#10 +
          'Authorization: Basic %code%'#13#10 +
          'User-Agent: coordinator/1.0'#13#10#13#10;
   replace(req,'%ip%',ReadString(_Data,_data_IP,''));
   code := ReadString(_Data,_data_Login,_prop_Login) + ':' + ReadString(_Data,_data_Password,_prop_Password);
   replace(req,'%code%',Base64_Code(code));
   replace(req,'%host%',ReadString(_Data,_data_Host,_prop_Host));
   res := '';
   Sock.Send(@req[1],Length(req));
end;

end.



