unit crtsock;

interface

uses windows,kol;

{-$define debug}

// Server side :
//  - start a server
//  - wait for a client
function StartServer(Port:word):integer;
function WaitClient(Server:integer):integer;
function WaitClientEx(Server:integer; var ip:string):integer;

// Client side :
//  - call a server
function CallServer(Server:string;Port:word):integer;

// Both side :
//  - Assign CRT Sockets
//  - Disconnect server
procedure AssignCrtSock(Socket:integer;var Input,Output:TextFile);
procedure Disconnect(Socket:integer);

// BroadCasting (UDP)
function StartBroadCast(Port:word):integer;
function SendBroadCast(Server:integer; Port:word; s:string):integer;
function SendBroadCastTo(Server:integer; Port:word; ip,s:string):integer;
function ReadBroadCast(Server:integer; Port:word;var Addr:integer):string;
function ReadBroadCastEx(Server:integer; Port:word; var ip:string):string;

// BlockRead
function SockAvail(Socket:integer):integer;
function DataAvail(Var F:TextFile):integer;
Function BlockReadsock(Var F:TextFile; var s:string):boolean;

Function send(socket:integer; data:pointer; datalen,flags:integer):integer; stdcall; far;
Function recv(socket:integer; data:pchar; datalen,flags:integer):integer; stdcall; far;

// some usefull SOCKET apis
type
  PHost = ^THost;
  THost = packed record
    name     : PChar;
    aliases  : ^PChar;
    addrtype : Smallint;
    length   : Smallint;
    addr     : ^pointer;
  end;

  TSockAddr=packed record
   Family:word;
   Port:word;
   Addr:LongInt;
   Zeros:array[0..7] of byte;
  end;

  TTimeOut=packed record
   sec:integer;
   usec:integer;
  end;

Const
 fIoNbRead = $4004667F;
  fmClosed = $D7B0;
  fmInput  = $D7B1;
  fmOutput = $D7B2;
  fmInOut  = $D7B3;

Function socket(Family,Kind,Protocol:integer):integer; stdcall;
Function closesocket(socket:Integer):integer; stdcall;
Function gethostbyname(HostName:PChar):PHost; stdcall;
Function gethostname(name:pchar; size:integer):integer; stdcall;
Function bind(Socket:Integer; Var SockAddr:TSockAddr; AddrLen:integer):integer; stdcall;
Function WSAGetLastError:integer; stdcall;
Function ioctlsocket(socket:integer; cmd: integer; var arg: integer): Integer; stdcall;

// Convert an IP Value to xxx.xxx.xxx.xxx string
Function LongToIp(Long:LongInt):string;
Function IpToLong(ip:string):longint;
Function HostToLong(AHost:string):LongInt;

Var
 EofSock:boolean;

implementation

//------ winsock -------------------------------------------------------
Const
 WinSock='wsock32.dll'; { 32bits socket DLL }
 Internet=2; { Internat familly }
 Stream=1;   { Streamed socket }
 Datagrams=2;
// fIoNbRead = $4004667F;
 sol_socket=$FFFF;
 SO_BROADCAST    = $0020;          { permit sending of broadcast msgs }

Type
  TWSAData = packed record
    wVersion: Word;
    wHighVersion: Word;
    szDescription: array[0..256] of Char;
    szSystemStatus: array[0..128] of Char;
    iMaxSockets: Word;
    iMaxUdpDg: Word;
    lpVendorInfo: PChar;
  end;
  u_short = Word;
  TTextBuf = array[0..127] of Char;
  TTextRec = packed record (* must match the size the compiler generates: 460 bytes *)
    Handle: Integer;       (* must overlay with TFileRec *)
    Mode: Word;
    Flags: Word;
    BufSize: Cardinal;
    BufPos: Cardinal;
    BufEnd: Cardinal;
    BufPtr: PChar;
    OpenFunc: Pointer;
    InOutFunc: Pointer;
    FlushFunc: Pointer;
    CloseFunc: Pointer;
    UserData: array[1..32] of Byte;
    Name: array[0..259] of Char;
    Buffer: TTextBuf;
  end;

{ Winsock }
Function WSAStartup(Version:word; Var Data:TwsaData):integer; stdcall; far; external winsock;
Function socket(Family,Kind,Protocol:integer):integer; stdcall; far; external winsock;
Function shutdown(Socket,How:Integer):integer; stdcall; far; external winsock;
Function closesocket(socket:Integer):integer; stdcall; far; external winsock;
Function WSACleanup:integer; stdcall; far; external winsock;
//Function WSAAsyncSelect(Socket:Integer; Handle:Hwnd; Msg:word; Level:Longint):longint; stdcall; far; external winsock;
Function bind(Socket:Integer; Var SockAddr:TSockAddr; AddrLen:integer):integer; stdcall; far; external winsock;
Function listen(socket,flags:Integer):integer; stdcall; far; external winsock;
Function connect(socket:Integer; Var SockAddr:TSockAddr; AddrLen:integer):integer; stdcall; far; external winsock;
Function accept(socket:Integer; Var SockAddr:TSockAddr; Var AddrLen:Integer):integer; stdcall; far; external winsock;
Function WSAGetLastError:integer; stdcall; far; external winsock;
Function recv(socket:integer; data:pchar; datalen,flags:integer):integer; stdcall; far; external winsock;
Function send(socket:integer; data:pointer; datalen,flags:integer):integer; stdcall; far; external winsock;
//Function getpeername(socket:integer; var SockAddr:TSockAddr; Var AddrLen:Integer):Integer; stdcall; far; external winsock;
Function gethostbyname(HostName:PChar):PHost; stdcall; far; external winsock;
//Function getsockname(socket:integer; var SockAddr:TSockAddr; Var AddrLen:Integer):integer; stdcall; far; external winsock;
//Function inet_ntoa(addr:longint):PChar; stdcall; far; external winsock;
Function WSAIsBlocking:boolean; stdcall; far; external winsock;
Function WSACancelBlockingCall:integer; stdcall; far; external winsock;
Function ioctlsocket(socket:integer; cmd: integer; var arg: integer): Integer; stdcall; far; external winsock;
//Function gethostbyaddr(var addr:longint; size,atype:integer):PHost; stdcall; far; external winsock;
Function gethostname(name:pchar; size:integer):integer; stdcall; far; external winsock;
function select(nfds:integer; readfds, writefds, exceptfds:pointer; var timeout:TTimeOut):integer; stdcall; far; external winsock;
function setsockopt(socket,level,optname:integer;var optval; optlen:integer):integer; stdcall; far; external winsock;
Function sendto(socket:integer; data:pointer; datalen,flags:integer; var SockAddr:TSockAddr; AddrLen:Integer):integer; stdcall; far; external winsock;
Function recvfrom(socket:integer; data:pointer; datalen,flags:integer; var SockAddr:TSockAddr; var AddrLen:Integer):integer; stdcall; far; external winsock;
function htons(hostshort: u_short): u_short;   stdcall; far; external  winsock;

Function IpToLong(ip:string):LongInt;
 var
  x,i:byte;
  ipx:array[0..3] of byte;
  v:integer;
 begin
  Result:=0;
  longint(ipx):=0; i:=0;
  for x:=1 to length(ip) do
   if ip[x]='.' then begin
    inc(i);
    if i=4 then exit;
   end else begin
    if not (ip[x] in ['0'..'9']) then exit;
    v:=ipx[i]*10+ord(ip[x])-ord('0');
    if v>255 then exit;
    ipx[i]:=v;
   end;
  result:=longint(ipx);
 end;

Function HostToLong(AHost:string):LongInt;
 Var
  Host:PHost;
 begin
  Result:=IpToLong(AHost);
  if Result=0 then begin
   Host:=GetHostByName(PChar(AHost));
   if Host<>nil then Result:=longint(Host^.Addr^^);
  end;
 end;

Function LongToIp(Long:LongInt):string;
 var
  ipx:array[0..3] of byte;
  i:byte;
 begin
  longint(ipx):=long;
  Result:='';
  for i:=0 to 3 do result:=result + Int2Str(ipx[i])+'.';
  SetLength(Result,Length(Result)-1);
 end;

//--- Server Side ------------------------------------------------------------------------
function StartServer(Port:word):integer;
 Var
  SockAddr:TSockAddr;
 begin
  Result:=socket(Internet,Stream,0);
  if Result=-1 then exit;
  FillChar(SockAddr,SizeOf(SockAddr),0);
  SockAddr.Family:=Internet;
  SockAddr.Port := htons(Port);
  if (Bind(Result,SockAddr,SizeOf(SockAddr))<>0)
  or (Listen(Result,0)<>0) then begin
   CloseSocket(Result);
   Result:=-1;
  end;
 end;

function WaitClient(Server:integer):integer;
 var
  Client:TSockAddr;
  Size:integer;
 begin
  Size:=SizeOf(Client);
  Result:=Accept(Server,Client,Size);
 end;

function WaitClientEx(Server:integer; var ip:string):integer;
 var
  Client:TSockAddr;
  Size:integer;
 begin
  Size:=SizeOf(Client);
  Result:=Accept(Server,Client,Size);
  ip:=LongToIp(Client.Addr);
 end;

function SockReady(Socket:integer):boolean;
 var
  sockset:packed record
   count:integer;
   socks:{array[0..63] of} integer;
  end;
  timeval:TTimeOut;
 begin
  sockSet.count:=1;
  sockSet.socks:=Socket;
  timeval.sec  :=0;
  timeval.usec :=0;
  result:=Select(0,@sockSet,nil,nil,timeval)>0;
 end;

function SockAvail(Socket:integer):integer;
 var
  rdy:boolean;
 begin
  rdy:=SockReady(Socket); // before IoCtlSocket to be sure (?) that we don't get some data between the 2 calls
  if IoctlSocket(Socket, fIoNbRead,Result)<0 then
   Result:=-1
  else begin
   if (Result=0) and RDY then result:=-1; // SockReady is TRUE when Data ara Avaible AND when Socket is closed
  end;
 end;

function DataAvail(Var F:TextFile):integer;
 var
  s:integer;
 begin
 // cause of TexTFile Buffer, we need to check both Buffer & Socket !
  With TTextRec(F) do begin
   Result:=BufEnd-BufPos;
   s:=SockAvail(Handle);
  end;
  if Result=0 then Result:=s else if s>0 then Inc(Result,s);
 end;

Function BlockReadSock(Var F:TextFile; var s:string):boolean;
 Var
  Handle:THandle;
  Size:integer;
 begin
  Result:=False;
  Handle:=TTextRec(pointer(@F)^).Handle;
  Repeat
   if (IoctlSocket(Handle, fIoNbRead, Size)<0) then exit;
   if Size=0 then exit
  until (Size>0);
  SetLength(s,Size);
  Recv(Handle,pchar(s),Size,0);
  Result:=True;
 end;

// Client Side--------------------------------------------------------------------------
function CallServer(Server:string; Port:word):integer;
 var
  SockAddr:TSockAddr;
 begin
  Result:=socket(Internet,Stream,0);
  if Result=-1 then exit;
  FillChar(SockAddr,SizeOf(SockAddr),0);
  SockAddr.Family:=Internet;
  SockAddr.Port := htons(Port);
  SockAddr.Addr:=HostToLong(Server);
  if Connect(Result,SockAddr,SizeOf(SockAddr))<>0 then begin
   Disconnect(Result);
   Result:=-1;
  end;
 end;

// BroadCasting-------------------------------------
function StartBroadCast(Port:word):integer;
 Var
  SockAddr:TSockAddr;
  bc:integer;
 begin
  Result:=socket(Internet,Datagrams,17); // 17 for UDP ... work also with 0 ?!
  if Result=-1 then exit;
  FillChar(SockAddr,SizeOf(SockAddr),0);
  SockAddr.Family:=Internet;
  SockAddr.Port := htons(Port);
//  SockAddr.Addr:=0; ?
  bc:=SO_BROADCAST;
  if (Bind(Result,SockAddr,SizeOf(SockAddr))<>0)
  or (setsockopt(Result,SOL_SOCKET,SO_BROADCAST,bc,SizeOf(bc))<>0) then begin
   CloseSocket(Result);
   Result:=-1;
  end;
 end;

function SendBroadCast(Server:integer; Port:word; s:string):integer;
 Var
  SockAddr:TSockAddr;
 begin
  SockAddr.Family:=Internet;
  SockAddr.Port:=htons(Port);
  SockAddr.Addr:=-1;
  Result:=SendTo(Server,@s[1],length(s),0,SockAddr,SizeOf(SockAddr));
 end;

function SendBroadCastTo(Server:integer; Port:word; ip,s:string):integer;
 Var
  SockAddr:TSockAddr;
 begin
  SockAddr.Family:=Internet;
  SockAddr.Port:=htons(Port);
  SockAddr.Addr:=IpToLong(ip);
  Result:=SendTo(Server,@s[1],length(s),0,SockAddr,SizeOf(SockAddr));
 end;

function ReadBroadCast(Server:integer; Port:word; var Addr:integer):string;
 Var
  SockAddr:TSockAddr;
  SockLen:integer;
  len:integer;
 begin
  FillChar(SockAddr,SizeOf(SockAddr),0);
  SockAddr.Family:=Internet;
  SockAddr.Port:=htons(Port);
  SockLen:=SizeOf(SockAddr);
  setlength(result,1024);
  len:=recvfrom(Server,@result[1],1024,0,SockAddr,SockLen);
  Addr := SockAddr.Addr;
  if len>0 then SetLength(result,len) else result:='';
 end;

function ReadBroadCastEx(Server:integer; Port:word; var ip:string):string;
 Var
  SockAddr:TSockAddr;
  SockLen:integer;
  len:integer;
 begin
  FillChar(SockAddr,SizeOf(SockAddr),0);
  SockAddr.Family:=Internet;
  SockAddr.Port:=htons(Port);
  SockLen:=SizeOf(SockAddr);
  setlength(result,1024);
  len:=recvfrom(Server,@result[1],1024,0,SockAddr,SockLen);
  if len>0 then SetLength(result,len) else result:='';
  ip:=LongToIp(SockAddr.Addr);
 end;

//------------ CrtSock -----------------
Var
 InitOk:boolean;

function OutputSock(Var F:TTextRec):integer; far;
 begin
 {$ifdef debug}writeln('out ',F.BufPtr);{$endif}
  if F.BufPos<>0 then begin
   Send(F.Handle,F.BufPtr,F.BufPos,0);
   F.BufPos:=0;
  end;
  Result:=0;
 end;

function InputSock(var F: TTextRec): Integer; far;
 Var
  Size:integer;
 begin
  F.BufEnd:=0;
  F.BufPos:=0;
  Result:=0;
  Repeat
   if (IoctlSocket(F.Handle, fIoNbRead, Size)<0) then begin
    EofSock:=True;
    exit;
   end;
  until (Size>=0);
  //if Size>0 then
  F.BufEnd:=Recv(F.Handle,F.BufPtr,F.BufSize,0);
  EofSock:=(F.BufEnd=0);
 {$ifdef debug}writeln('in  ',F.BufPtr);{$endif}
 end;

procedure Disconnect(Socket:integer);
 var
  dummy:array[0..1024] of char;
 begin
  ShutDown(Socket,1);
  repeat until recv(Socket,dummy,1024,0)<=0;
  CloseSocket(Socket);
 end;

function CloseSock(var F:TTextRec):integer; far;
 begin
  Disconnect(F.Handle);
  F.Handle:=-1;
  Result:=0;
 end;

function OpenSock(var F: TTextRec): Integer; far;
begin
  F.BufPos:=0;
  F.BufEnd:=0;
  if F.Mode = fmInput then begin // ReadLn
    EofSock:=False;
    F.InOutFunc := @InputSock;
    F.FlushFunc := nil;
  end else begin                 // WriteLn
    F.Mode := fmOutput;
    F.InOutFunc := @OutputSock;
    F.FlushFunc := @OutputSock;
  end;
  F.CloseFunc := @CloseSock;
  Result:=0;
end;

Procedure AssignCrtSock;//(Socket:integer; Input,Output:PTextFile);
 begin
  with TTextRec(Input) do begin
    Handle := Socket;
    Mode := fmClosed;
    BufSize := SizeOf(Buffer);
    BufPtr := @Buffer;
    OpenFunc := @OpenSock;
  end;
  with TTextRec(Output) do begin
    Handle := Socket;
    Mode := fmClosed;
    BufSize := SizeOf(Buffer);
    BufPtr := @Buffer;
    OpenFunc := @OpenSock;
  end;
  Reset(Input);
  Rewrite(Output);
 end;

//----- Initialization/Finalization--------------------------------------------------

Procedure InitCrtSock;
 var
  wsaData:TWSAData;
 begin
  InitOk:=wsaStartup($101,wsaData)=0;
{$ifdef debug}allocconsole{$endif}
 end;

Procedure DoneCrtSock;
 begin
  if not InitOk then exit;
  if wsaIsBlocking then wsaCancelBlockingCall;
  wsaCleanup;
 end;

Initialization InitCrtSock;

Finalization DoneCrtSock;

end.
