unit TCP_Client;

interface

uses Windows,WinSock;

type
    TTCP_Client = class;
    TSocketRead = procedure(Socket:TTCP_Client; buf:pointer; len:cardinal) of object;
    TSocketNotify = procedure(Socket:TTCP_Client) of object;
    
    TTCP_Client = class
        private
            FThread:THandle;
        protected
            FSocket:TSocket;

            procedure read(buf:PChar; len:integer);
        public
            OnRead:TSocketRead;
            OnConnect:TSocketNotify;
            OnDisconnect:TSocketNotify;
            OnClientConnect:TSocketNotify;
            OnClientDisconnect:TSocketNotify;

            constructor Create;
            destructor Destroy; override;

            function open(const host:string; port:integer):integer;
            procedure close;
            procedure send(buf:pointer; len:integer); overload;
            procedure send(const buf:string); overload;
    end;

implementation

function read_proc(sock:pointer):Integer; stdcall;
var readset:TFDSet;
    timeout:TTimeVal;
    szMax:integer;
    //buf:string;
    buf:array[0..10000] of char;
begin
    repeat
        szMax := 10000;
        szMax := recv(TTCP_Client(sock).FSocket, buf[0], szMax, 0);
        if szMax > 0 then
            TTCP_Client(sock).read(buf, szMax);
        {
        FD_ZERO(readset);
        FD_SET(TTCP_Client(sock).FSocket, readset);

        timeout.tv_sec := 10;
        timeout.tv_usec := 0;

        if select(2, @readset, nil, nil, @timeout) < 0 then
            Exit;
        if FD_ISSET(TTCP_Client(sock).FSocket, readset) then
          begin
            ioctlsocket(TTCP_Client(sock).FSocket, FIONREAD, szMax);
            SetLength(buf, szMax);
            recv(TTCP_Client(sock).FSocket, buf[1], szMax, 0);
            TTCP_Client(sock).read(buf, szMax);
          end;
        }
    until szMax < 1;
    TTCP_Client(sock).close;
    Result := 0;
end;

constructor TTCP_Client.Create;
begin
    inherited;
end;

destructor TTCP_Client.Destroy;
begin
    close;
    inherited;
end;

function TTCP_Client.open(const host:string; port:integer):integer;
var addr:sockaddr_in;
    id:LongWord;
begin
   Result := 0;
   if FSocket <> 0 then Exit;

   FSocket := socket(PF_INET, SOCK_STREAM, IPPROTO_IP);
   addr.sin_family := AF_INET;
   addr.sin_port := htons(Port);
   addr.sin_addr.S_addr := inet_addr(PChar(Host));
   if connect(FSocket,addr,sizeof(addr)) <> 0 then
     begin
       closesocket(FSocket);
       FSocket := 0;
       Result := 1;
       Exit;
     end;

   FThread := CreateThread(nil, 0, @read_proc, self, 0, id);

   if Assigned(onConnect) then
      onConnect(Self);
end;

procedure TTCP_Client.close;
begin
    if FSocket = 0 then Exit;

    closesocket(FSocket);
    WaitForSingleObject(FThread, 1);
    CloseHandle(FThread);
    FSocket := 0;
    if Assigned(onDisconnect) then
        onDisconnect(Self);
end;

procedure TTCP_Client.read(buf:PChar; len:integer);
begin
    if Assigned(OnRead) then
        OnRead(Self, buf, len);
end;

procedure TTCP_Client.send(buf:pointer; len:integer);
begin
    WinSock.send(FSocket, buf^, len, 0);
end;

procedure TTCP_Client.send(const buf:string);
begin
   send(PChar(buf), length(buf));
end;

var wsaData:TWSAData;

initialization
   WSAStartup($101,wsaData);

end.
