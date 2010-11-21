unit hiUDP;

interface

{$I share.inc}

uses Windows,Kol,Share,Debug,WinSock;

type
  THIUDP = class(TDebug)
   private
    Handle:cardinal;
    th:PTHread;
    FIP:string;
    resData:string;

    function Execute(Sender:PThread): Integer;
    procedure SyncExec(Sender: PThread; Param: Pointer);
    procedure Err(Index:integer);
    procedure Close;
   public
    _prop_LocalPort:integer;
    _prop_RemotePort:integer;
    _prop_LocalIP:string;
    _prop_RemoteIP:string;
    _prop_AutoConnect:boolean;
    _prop_ReceiveMode:byte;
    _prop_BroadCast:boolean;

    _data_Count:THI_Event;
    _data_LocalIP:THI_Event;
    _data_RemoteIP:THI_Event;
    _data_RemotePort:THI_Event;
    _data_LocalPort:THI_Event;
    _data_Data:THI_Event;
    _event_onReceive:THI_Event;
    _event_onError:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doOpen(var _Data:TData; Index:word);
    procedure _work_doSend(var _Data:TData; Index:word);
    procedure _work_doReceive(var _Data:TData; Index:word);
    procedure _work_doSendTo(var _Data:TData; Index:word);
    procedure _work_doReceiveFrom(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _var_ReceiveIP(var _Data:TData; Index:word);
    procedure _var_Activate(var _Data:TData; Index:word);
  end;

implementation

constructor THIUDP.Create;
begin
  inherited;
  UPD_Init;
end;

destructor THIUDP.Destroy;
var dt:TData;
begin
  _work_doClose(dt,0);
  UPD_Clear;
  inherited;
end;

procedure THIUDP._work_doOpen;
var SockAddr:TSockAddr;
//    ip:string;
    bc:integer;
begin
  Handle := socket(AF_INET,SOCK_DGRAM,17);
  ZeroMemory(@SockAddr,SizeOf(SockAddr));

  SockAddr.sin_family := AF_INET;
  SockAddr.sin_addr.S_addr := inet_addr(PChar(ReadString(_Data,_data_LocalIP,_prop_LocalIP)));
  SockAddr.sin_port := htons(ReadInteger(_Data,_data_LocalPort,_prop_LocalPort));
  if Bind(Handle,SockAddr,SizeOf(SockAddr)) <> 0 then
    begin
     Close;
     Err(1);
     Exit;
    end;

  if _prop_BroadCast then
   begin
    bc := SO_BROADCAST;
    if setsockopt(Handle,SOL_SOCKET,SO_BROADCAST,pchar(@bc),SizeOf(bc)) <> 0 then
     ;
   end;

  if _prop_AutoConnect then
     begin
      SockAddr.sin_addr.S_addr := inet_addr(PChar(ReadString(_Data,_data_RemoteIP,_prop_RemoteIP)));
      SockAddr.sin_port := htons(ReadInteger(_Data,_data_RemotePort,_prop_RemotePort));
      if Connect(Handle, SockAddr, sizeof(SockAddr)) <> 0 then
        begin
          Close;
          Err(2);
          Exit;
        end;
     end;
  if _prop_ReceiveMode = 0 then
   begin
    {$ifdef F_P}
     th := NewThreadforFPC;
    {$else}
     th := NewThread;
    {$endif}
     th.OnExecute := Execute;
     th.Resume;
   end;
end;

function THIUDP.Execute(Sender:PThread): Integer;
type TIP = record b1,b2,b3,b4:byte; end;
var
    sc:sockaddr_in;
    FDSet:TFDSet;
    len,ln:integer;
    dt:^string;
begin
   while not Sender.Terminated do
    begin
     FD_ZERO(FDSet);
     FD_SET(Handle, FDSet);
     if (select(0,@FDSet,nil,nil,nil) > 0) {and FD_ISSET(Handle, FDSet)} then
      begin
       ioctlsocket(Handle, FIONREAD, len);
       SetLength(ResData,len);
       ln := sizeof(sockaddr_in);
       len := recvfrom(Handle,ResData[1],len,0,sc,ln);
       if len = 0 then continue;
       setlength(ResData,len);
       with TIP(sc.sin_addr.S_addr) do
         FIP := int2str(b1) + '.' + int2str(b2)  + '.' +
              int2str(b3) + '.' + int2str(b4) + ':' + int2str(ntohs(sc.sin_port));
       //_hi_OnEvent(_event_onReceive,resdata);
       new(dt);
       cardinal(dt^) := 0;
       dt^ := ResData;
       Sender.SynchronizeEx(SyncExec, dt);
      end;
    end;
   Result := 0;
end;

procedure THIUDP.SyncExec;
type PString = ^string;
begin
  _hi_OnEvent(_event_onReceive,PString(Param)^);
  PString(param)^ := '';
  dispose(Param);
end;

procedure THIUDP.Err;
begin
   _hi_OnEvent(_event_onError,Index);
end;

procedure THIUDP.Close;
begin
   closesocket(handle);
   Handle := 0;
end;

procedure THIUDP._work_doSend;
var s:string;
begin
   s := ReadString(_Data,_data_Data,'');
   send(Handle,s[1],length(s),0);
end;

procedure THIUDP._work_doReceive;
var s:string;
    FDSet:TFDSet;
    len:integer;
begin
   FD_ZERO(FDSet);
   FD_SET(Handle, FDSet);
   if select(0,@FDSet,nil,nil,nil) > 0 then
    begin
     ioctlsocket(Handle, FIONREAD, len);
     setlength(s,len);
     //if recv(Handle,s[1],len,0) <> SOCKET_ERROR then
     recv(Handle,s[1],len,0);
     _hi_OnEvent(_event_onReceive,s);
    end; //_debug('res');
end;

procedure THIUDP._work_doSendTo;
var SockAddr:TSockAddr;
    s:string;
begin
   SockAddr.sin_family := AF_INET;
   SockAddr.sin_port := htons(ReadInteger(_Data,_data_RemotePort,_prop_RemotePort));
   s := ReadString(_Data,_data_RemoteIP,_prop_RemoteIP);
   if s = '' then
     SockAddr.sin_addr.S_addr := longint(INADDR_BROADCAST) 
   else SockAddr.sin_addr.S_addr := inet_addr(PChar(s));

   s := ReadString(_Data,_data_Data,'');
   sendto(Handle,s[1],length(s),0,SockAddr,sizeof(TSockAddr));
end;

procedure THIUDP._work_doReceiveFrom;
type TIP = record b1,b2,b3,b4:byte; end;
var s:string;
    sc:sockaddr_in;
    FDSet:TFDSet;
    len,ln:integer;
begin
   FD_ZERO(FDSet);
   FD_SET(Handle, FDSet);
   if select(0,@FDSet,nil,nil,nil) > 0 then
    begin
     ioctlsocket(Handle, FIONREAD, len);
     SetLength(s,len);
     //if recvfrom(Handle,s[1],Len,0,sc,len) <> SOCKET_ERROR then
     ln := sizeof(sockaddr_in);
     recvfrom(Handle,s[1],len,0,sc,ln);
      begin
        with TIP(sc.sin_addr.S_addr) do
         FIP := int2str(b1) + '.' + int2str(b2)  + '.' +
              int2str(b3) + '.' + int2str(b4);
        _hi_OnEvent(_event_onReceive,s);
      end;
    end;
end;

procedure THIUDP._work_doClose;
begin
   if (_prop_ReceiveMode = 0) and Assigned(th) then
    Free_and_nil(th);
   close;
end;

procedure THIUDP._var_ReceiveIP;
begin
  dtString(_data,FIP);
end;

procedure THIUDP._var_Activate;
begin
  dtInteger(_data,byte(Handle > 0));
end;

end.