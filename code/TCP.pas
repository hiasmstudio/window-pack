unit TCP;

interface

uses kol,Windows,WinSock,Messages;

type
  TSocket = class;
  TSocketRead = procedure(Socket:TSocket; buf:pointer; len:cardinal) of object;
  TSocketNotify = procedure(Socket:TSocket) of object;

  TSocket = class
    private
     FParent:TSocket;
     FList:PList;

     function GetConnections(Index:integer):TSocket;
     function GetCount:cardinal;
     function GetConnected:boolean;

    protected
     FSocket:THandle;

    public
     SendBlocked:boolean;
     Tag:integer;
     IP:string;

     OnRead:TSocketRead;
     OnConnect:TSocketNotify;
     OnDisconnect:TSocketNotify;
     OnClientConnect:TSocketNotify;
     OnClientDisconnect:TSocketNotify;

     constructor Create; overload;
     constructor Create(par:TSocket); overload;
     destructor Destroy; override;

     procedure StartServer(Port:word; const Host:String);
     procedure StartClient(Port:word; const Host:String);
     procedure Listen(Max:word);
     procedure Close;
     procedure DisconnectClients;
     procedure Send(Buf:pointer; Size:cardinal);

     property Connections[Index:integer]:TSocket read GetConnections;
     property Count:cardinal read GetCount;
     property Connected:boolean read GetConnected;
     property Handle:THandle read FSocket;
     property Parent:TSocket read FParent;
  end;

implementation

var ToolWnd:THandle; AllSockets:PList;

function MWnd(window:hwnd; message:dword; wparam:WPARAM; lparam:LPARAM):LRESULT; stdcall;
var i:integer; sc,sc1:TSocket; buf:string; sz,szMax:integer;
begin
   Result := 0;
   case message of
    WM_USER: begin
      for i:=0 to AllSockets.Count-1 do begin
        sc := TSocket(AllSockets.Items[i]);
        if sc.Handle=THandle(wparam) then begin
          case lparam and $FFFF of
           FD_ACCEPT: begin
               sc1 := TSocket.Create(sc);
               if Assigned(sc.onClientConnect) then
                 sc.onClientConnect(sc1);
             end;
           FD_READ: begin
               ioctlsocket(sc.Handle, FIONREAD, szMax);
               SetLength(buf, szMax);
               while szMax>0 do begin
                 sz := Winsock.recv(sc.Handle, buf[1], szMax, 0);
                 if sz<=0 then break;
                 if Assigned(sc.onRead) then
                   sc.onRead(sc,@buf[1],sz);
                 dec(szMax,sz);
               end;
             end;
           FD_WRITE: sc.SendBlocked := False;
           FD_CLOSE: begin
               sc.Close;
               if Assigned(sc.Parent) then sc.Destroy;
             end;
          end;
          break;
        end;
      end;
    end;
    else Result := DefWindowProc(window,message,wparam,lparam);
   end;
end;

procedure CreateWindow;
var
  utilclass:TWndClass;
  wsaData:TWSAData;  
begin
   if ToolWnd > 0 then exit;

   WSAStartup($101,wsaData);
   ZeroMemory(@utilclass,sizeof(utilclass));
   utilclass.lpfnWndProc := @MWnd;
   utilclass.lpszClassName := 'TSocket';
   utilclass.hInstance := HInstance;
   RegisterClassA(utilclass);
   ToolWnd := CreateWindowEx(WS_EX_TOOLWINDOW,utilclass.lpszclassname,nil,
    WS_POPUP,0,0,0,0,0,0,hinstance,nil);
   AllSockets := NewList;
end;

procedure DestroyWindow;
begin
   AllSockets.Free;
   Windows.DestroyWindow(ToolWnd);
   ToolWnd := 0;
   WSACleanup;
end;

constructor TSocket.Create;
begin
   CreateWindow;
   FParent := nil;
   FSocket := 0;
   AllSockets.Add(Self);
end;

constructor TSocket.Create(par:TSocket);
type TChAddr = record c1,c2,c3,c4:byte; end;
var ad:TSockAddr; sz:integer;
begin
   FParent := par;
   sz := sizeof(TSockAddr);
   FSocket := accept(par.FSocket,@ad,@sz);
   SendBlocked := False;
   with TChAddr(Ad.sin_addr) do
     IP := int2str(c1) + '.' + int2str(c2) + '.' + int2str(c3) + '.' + int2str(c4);
   OnRead := par.OnRead;
   AllSockets.Add(Self);
   FParent.FList.Add(Self);
   WSAAsyncSelect(FSocket,ToolWnd,WM_USER,FD_READ or FD_WRITE or FD_CLOSE);
end;

destructor TSocket.Destroy;
begin
   Close;
   if FList<>nil then DisconnectClients;
   if FParent<>nil then FParent.FList.Remove(Self);
   AllSockets.Remove(Self);
   if AllSockets.Count=0 then DestroyWindow;
end;

procedure TSocket.StartServer;
var addr:sockaddr_in;
begin
   if FSocket<>0 then Exit;
   FSocket := socket(PF_INET, SOCK_STREAM, IPPROTO_IP);
   addr.sin_family := AF_INET;
   addr.sin_port := htons(Port);
   if Host = '' then
     addr.sin_addr.S_addr := INADDR_ANY
   else addr.sin_addr.S_addr := inet_addr(PChar(Host));
   if bind(FSocket,addr,sizeof(addr)) = -1 then
     begin
       closesocket(FSocket);
       FSocket := 0;
     end
   else
    begin
     FList := NewList;
     WSAAsyncSelect(FSocket,ToolWnd,WM_USER,FD_ACCEPT or FD_CLOSE);
     if Assigned(onConnect) then
       onConnect(Self);
    end;
end;

procedure TSocket.StartClient;
var addr:sockaddr_in;
begin
   if FSocket<>0 then Exit;
   FSocket := socket(PF_INET, SOCK_STREAM, IPPROTO_IP);
   SendBlocked := False;
   addr.sin_family := AF_INET;
   addr.sin_port := htons(Port);
   addr.sin_addr.S_addr := inet_addr(PChar(Host));
   if connect(FSocket,addr,sizeof(addr)) <> 0 then
     begin
       closesocket(FSocket);
       FSocket := 0;
     end
   else
    begin
     WSAAsyncSelect(FSocket,ToolWnd,WM_USER,FD_READ or FD_WRITE or FD_CLOSE);
     if Assigned(onConnect) then
       onConnect(Self);
    end;
end;

function TSocket.GetConnections;
begin
  Result := TSocket(FList.Items[Index]);
end;

function TSocket.GetCount;
begin
  if FList <> nil then
    Result := FList.Count
  else Result := 0;
end;

function TSocket.GetConnected;
begin
  Result := FSocket > 0;
end;

procedure TSocket.Listen;
begin
  if FSocket=0 then Exit;
  Winsock.Listen(FSocket,Max);
end;

procedure TSocket.DisconnectClients;
var i:smallint;
begin
  for i := FList.Count-1 downto 0 do with Connections[i] do
   begin
    Close;
    Destroy;
   end;
  FList.Clear;
end;

procedure TSocket.Send;
var sent:integer;
begin
  while (FSocket<>0) and (Size>0) do begin
    sent := Winsock.send(FSocket,buf^,Size,0);
    if sent=SOCKET_ERROR then begin
      if WSAGetLastError()=WSAEWOULDBLOCK then begin
        SendBlocked := True;
        //while SendBlocked and not AppletTerminated do begin
	  //if Assigned(Applet) then Applet.ProcessMessages;
//	  Sleep(1);  // ????
	//end;
      end else Exit;
    end else begin
      dec(Size, sent);
      buf := pointer(integer(buf)+sent);
    end;
  end;
end;

procedure TSocket.Close;
begin
  if FSocket=0 then Exit;
  WSAAsyncSelect(FSocket,ToolWnd,0,0);
  closesocket(FSocket); FSocket := 0; SendBlocked := False;
  if Assigned(onDisconnect) then
    onDisconnect(Self);
  if Assigned(FParent) then
    if Assigned(FParent.onClientDisconnect) then
      FParent.onClientDisconnect(Self);
end;

end.
