unit EasyProxy;

interface

uses
  kol,
  Windows,
  Winsock;

type
  TCompletionPort = class
  public
    FHandle:THandle;
    constructor Create(dwNumberOfConcurentThreads:DWORD);
    destructor Destroy;override;
    function AssociateDevice(hDevice:THandle;dwCompKey:DWORD):boolean;
  end;


  TThread = class
  private
    Thread:PThread;
    function _Execute(Sender:PThread): Integer;
  protected
    procedure Execute(Sender:PThread);virtual;abstract;
    constructor Create;
    destructor Destroy;override;
  end;

  TProxy = class;

  TAcceptThread = class(TThread)
  private
    FListenSocket:TSocket;
    FListenPort:Word;
    FClientList:PList;
    FParent:TProxy;

    procedure GarbageCollect;
  protected
    procedure Execute(Sender:PThread);override;
  public
    constructor Create(AListenPort:Word; Proxy:TProxy);reintroduce;
    destructor Destroy;override;
    function Count:integer;
  end;


  TClientThread=class(TThread)
  private
    FParent:TProxy;
  public
    constructor Create(Proxy:TProxy);
    procedure Execute(Sender:PThread);override;
  end;


  TClient = class
  private
    FParent:TProxy;
    FSocket:TSocket;
    FEvent:THandle;
    ov:POVERLAPPED;
    Buffer:Pointer;
    BufSize:Cardinal;
    procedure Write(Buf:Pointer;Size:Cardinal);
  public
    FOppositeClient:TClient;
    FLastActivity:double;
    constructor Create(Proxy:TProxy);
    destructor Destroy;override;
    procedure Connect(ARequest:string);
    procedure Disconnect;
    procedure Complete(dwNumBytes:Cardinal);virtual;abstract;
  end;


  TInternalClient = class(TClient)
  public
    procedure Complete(dwNumBytes:Cardinal);override;
  end;


  TExternalClient = class(TClient)
  public
    procedure Complete(dwNumBytes:Cardinal);override;
  end;

  TOnHost = procedure(Sender:TProxy; const Host:string) of object;
  TOnIsAuth = function(Sender:TProxy; const LoginPass:string):boolean of object; 

  TProxy = class
  private
    AF:TAcceptThread;
    FClients:PList;
  public
    FCompPort:TCompletionPort;
    OnHost:TOnHost;
    OnIsAuth:TOnIsAuth;

    constructor Create;
    destructor Destroy; override;

    procedure Init(Port:integer; Count:integer);
    procedure Stop;

    function Count:integer;
  end;

implementation

uses hiCharset,Share;

{ TCompletionPort }

constructor TCompletionPort.Create(dwNumberOfConcurentThreads: DWORD);
begin
  FHandle:=CreateIoCompletionPort(INVALID_HANDLE_VALUE,0,0,dwNumberOfConcurentThreads);
end;

function TCompletionPort.AssociateDevice(hDevice: THandle;
  dwCompKey: DWORD): boolean;
begin
  result:=CreateIoCompletionPort(hDevice,FHandle,dwCompKey,0)=FHandle;
end;

destructor TCompletionPort.Destroy;
begin
  CloseHandle(FHandle);
  inherited;
end;

{ TThread }

constructor TThread.Create;
begin
   inherited;
   Thread := {$ifdef F_P}NewThreadforFPC{$else}NewThread{$endif};
   Thread.OnExecute := _Execute;
   Thread.Resume;
end;

destructor TThread.Destroy;
begin
   Thread.Free;
   inherited;
end;

function TThread._Execute;
begin
   Execute(Sender);
   Result := 0;
end;

{ TAcceptThread }

constructor TAcceptThread.Create;
begin
  inherited Create;
  FListenPort := AListenPort;
  FClientList := NewList;
  FParent := Proxy;
end;

destructor TAcceptThread.Destroy;
begin
  closesocket(FListenSocket);
  FClientList.Free;
  inherited;
end;

function TAcceptThread.Count;
begin
  Result := FClientList.Count;
end;

procedure TAcceptThread.GarbageCollect;
var
  AClient:TClient;
  i:integer;
begin
  for i := 0 to FClientList.Count-1 do
   begin
    AClient := TClient(FClientList.Items[i]);
    if Assigned(AClient) then
      if (AClient.FSocket = INVALID_SOCKET) and ((now-AClient.FLastActivity)>2E-4) then
        begin
          FClientList.Items[i] := nil;
          if Assigned(AClient.FOppositeClient) then AClient.FOppositeClient.Destroy;
          AClient.Destroy;
        end;
   end;
  //FClientList.Pack;
  i := 0;
  while i < FClientList.Count do
    if FClientList.Items[i] = nil then
      FClientList.Delete(i)
    else inc(i);
  FClientList.Capacity := FClientList.Count;
end;


procedure TAcceptThread.Execute;
var
  FAddr: TSockAddrIn;
  Len: Integer;
  ClientSocket:TSocket;
  InternalClient:TClient;
begin
  FListenSocket := socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
  FAddr.sin_family := PF_INET;
  FAddr.sin_addr.s_addr := INADDR_ANY;
  FAddr.sin_port := htons(FListenPort);
  bind(FListenSocket, FAddr, SizeOf(FAddr));
  listen(FListenSocket, SOMAXCONN);
  try
    while not Sender.Terminated do begin
      Len:=sizeof(FAddr);
      ClientSocket:=accept(FListenSocket, @FAddr, @Len);
      try
        GarbageCollect;
        if ClientSocket<>INVALID_SOCKET then begin
          InternalClient:=TInternalClient.Create(FParent);
          InternalClient.FSocket:=ClientSocket;
          FClientList.Add(InternalClient);
          FParent.FCompPort.AssociateDevice(InternalClient.FSocket,Cardinal(InternalClient));
          InternalClient.Complete(0);
        end;
      except end;
    end;
  finally
    shutdown(FListenSocket,2);
    closesocket(FListenSocket);
  end;
end;


{ TClientThread }

constructor TClientThread.Create;
begin
   inherited Create;
   FParent := Proxy;
end;

procedure TClientThread.Execute;
var
  CompKey,dwNumBytes:Cardinal;
  ov:POVERLAPPED;
begin
  try
    while not Sender.Terminated do begin
      if GetQueuedCompletionStatus(FParent.FCompPort.FHandle,dwNumBytes,CompKey,ov,INFINITE) and (dwNumBytes>0) then
      begin
        if TClient(CompKey).FSocket<>INVALID_SOCKET then begin
          TClient(CompKey).Complete(dwNumBytes);
          TClient(CompKey).FLastActivity:=now;
        end;
      end else
        TClient(CompKey).Disconnect;
    end;
  except
    //TClientThread.Create(FParent);
  end;
end;

{ TClient }

constructor TClient.Create;
begin
  FSocket:=INVALID_SOCKET;
  BufSize:=8192;
  GetMem(Buffer,BufSize);
  new(ov);
  ov.Internal:=0;
  ov.InternalHigh:=0;
  ov.Offset:=0;
  ov.OffsetHigh:=0;
  ov.hEvent:=0;
  FEvent:=CreateEvent(nil,true,false,nil);
  FLastActivity := Now;
  FParent := Proxy;
end;


destructor TClient.Destroy;
begin
  Disconnect;
  CloseHandle(FEvent);
  FreeMem(Buffer);
  Dispose(ov);
  inherited;
end;


////////////////////////////////////////////////////////////////////////////////
//
//  ????? ??????? ?? ??????????? ? ?????????? ?????

procedure TClient.Connect(ARequest: string);
var
  f,t:integer;
  ARemoteAddress:string;
  ARemotePort,s:string;
  he:PHostEnt;
  FAddr:TSockAddrIn;
  auth:boolean;
begin
  f:=Pos('/',ARequest)+2;
  t:=Pos('HTTP',ARequest)-1;
  ARemoteAddress:=Copy(ARequest,f,t-f);
  t:=Pos('/',ARemoteAddress);
  if t<>0 then ARemoteAddress:=Copy(ARemoteAddress,0,t-1);
  t:=Pos(':',ARemoteAddress);
  if t<>0 then begin
    ARemotePort:=Copy(ARemoteAddress,t+1,Length(ARemoteAddress)-t);
    ARemoteAddress:=Copy(ARemoteAddress,0,t-1);
  end else
    ARemotePort:='80';
  if assigned(FParent.onHost) then
    FParent.OnHost(FParent, ARemoteAddress);
  
  if Assigned(FParent.OnIsAuth) then
    begin      
      auth := false;
      f := Pos('Proxy-Authorization: ', ARequest);
      if f > 0 then
        begin
          delete(ARequest, 1, f + 20);
          f := pos(#13, ARequest);
          s := copy(ARequest, 1, f-1);
          if copy(s,1,6) = 'Basic ' then 
            begin
              delete(s,1,6);
              s := Base64_Decode(s);
              auth := FParent.OnIsAuth(FParent, s);
            end;
        end;
      
      if not auth then
        begin 
          s := 'HTTP/1.0 407 Proxy authentication required'#13#10'Proxy-Authenticate: Basic realm="HiAsm proxy"'#13#10#13#10'Proxy authentication required';
          FOppositeClient.Write(@s[1], length(s));
          Disconnect;
          exit;
        end;
    end;
    
  he:=GetHostByName(PChar(ARemoteAddress));
  if not Assigned(he) then exit;
  ARemoteAddress:=inet_ntoa(PInAddr(he.h_addr_list^)^);

  FSocket:=socket(PF_INET, SOCK_STREAM, IPPROTO_IP);
  FAddr.sin_family:=PF_INET;
  FAddr.sin_addr.s_addr :=inet_addr(PChar(ARemoteAddress));
  try
    FAddr.sin_port := htons(Str2Int(ARemotePort));
    if WinSock.connect(FSocket, FAddr, SizeOf(FAddr))=SOCKET_ERROR then FSocket:=INVALID_SOCKET;
  except
    //WriteLn('Connection failed');
  end;
end;


procedure TClient.Disconnect;
begin
  if FSocket<>INVALID_SOCKET then begin
    shutdown(FSocket,2);
    closesocket(FSocket);
    FSocket:=INVALID_SOCKET;
    if Assigned(FOppositeClient) then FOppositeClient.Disconnect;
  end;
end;

procedure TClient.Write(Buf: Pointer; Size: Cardinal);
var
  BytesWrite:Cardinal;
begin
  ov.hEvent:=FEvent or 1;
  WriteFile(FSocket,Buf^,Size,BytesWrite,ov);
  ov.hEvent:=0;
end;


{ TInternalClient }

procedure TInternalClient.Complete(dwNumBytes: Cardinal);
var
  BytesRead:Cardinal;
begin
  if dwNumBytes>0 then begin
    if not Assigned(FOppositeClient) then begin
      FOppositeClient:=TExternalClient.Create(FParent);
      FOppositeClient.FOppositeClient:=self;
      FOppositeClient.Connect(PChar(Buffer));
      if FOppositeClient.FSocket=INVALID_SOCKET then begin
        Disconnect;
        exit;
      end;
      FParent.FCompPort.AssociateDevice(FOppositeClient.FSocket,Cardinal(FOppositeClient));
      FOppositeClient.Complete(0);
    end;
    FOppositeClient.Write(Buffer,dwNumBytes);
  end;
  ReadFile(FSocket,Buffer^,BufSize,BytesRead,ov);
end;

{ TExternalClient }

procedure TExternalClient.Complete(dwNumBytes: Cardinal);
var
  BytesRead:Cardinal;
begin
  if dwNumBytes>0 then FOppositeClient.Write(Buffer,dwNumBytes);
  ReadFile(FSocket,Buffer^,BufSize,BytesRead,ov);
end;

constructor TProxy.Create;
begin
   inherited Create;
end;

destructor TProxy.Destroy;
begin
   Stop;
   inherited;
end;

procedure TProxy.Init;
var i:integer;
begin
   FCompPort := TCompletionPort.Create(Count);
   FClients := NewList;
   for i := 0 to Count-1 do
     FClients.Add(TClientThread.Create(Self));
   AF := TAcceptThread.Create(Port, Self);
end;

procedure TProxy.Stop;
var i:integer;
begin
   if FCompPort = nil then exit;

   FCompPort.Destroy;
   FCompPort := nil;
   AF.Destroy;
   for i := 0 to FClients.Count-1 do
     TClientThread(FClients.Items[i]).Destroy;
   FClients.Free;
end;

function TProxy.Count;
begin
  if FCompPort = nil then
    Result := 0
  else Result := AF.Count;
end;

end.
