unit hiHost;

interface

uses Kol,Share,Debug,Win,{Windows,}winsock,{err,}ShellApi;

type
  THIHost = class(TDebug)
   private

   public

     _event_onHostByIP : THI_Event;
     _event_onIPByHost : THI_Event;
     _data_IP : THI_Event;
     _data_HostName : THI_Event;
    
     procedure _work_doHostByIP(var _Data:TData; Index:word);
     procedure _work_doIPByHost(var _Data:TData; Index:word);
     procedure _var_LoacalHostName(var _Data:TData; Index:word);
     procedure _var_LoacalIP(var _Data:TData; Index:word);
     function uGetLoacalHostName:string ; 
     function uHost2IP(HostName:string): String; 
     function uIP2Host(IPAddr : String): String; 
  end;

implementation

procedure THIHost._work_doHostByIP;
var   ip: string;   
begin
   ip := ReadString(_Data,_data_IP);
  _hi_OnEvent(_event_onHostByIP,uIP2Host(uHost2IP(ip)));
end;

procedure THIHost._work_doIPByHost;
var   Host: string;   
begin
  Host := ReadString(_Data,_data_HostName,uGetLoacalHostName);
  _hi_OnEvent(_event_onIPByHost,uHost2IP(Host));
end;

procedure THIHost._var_LoacalHostName;
begin
  dtString(_Data,uGetLoacalHostName);
end;

procedure THIHost._var_LoacalIP;
begin
  dtString(_Data,uHost2IP(uGetLoacalHostName));
end;

//////////////////////////////////////////////////////////////////////////////////////////////////
function THIHost.uGetLoacalHostName:string ;
var   Buffer: Array[0..63] of Char;
      GInitData: TWSAData;
begin
   WSAStartup($101, GInitData);
   Result := '';
   winsock.GetHostName(Buffer, SizeOf(Buffer));
   Result := Buffer;
   WSACleanup;
end;
////////////////////////////////////////////////////////////////////////////////
function THIHost.uHost2IP(HostName:string): String;
type
   TaPInAddr = Array[0..10] of PInAddr;
   PaPInAddr = ^TaPInAddr;
var   phe: PHostEnt;
      pptr: PaPInAddr;
      I: Integer;
      GInitData: TWSAData;
begin
   Result := '';
   WSAStartup($101, GInitData);
   phe := GetHostByName(@HostName[1]);
   if phe = nil then exit;
   pPtr := PaPInAddr(phe^.h_addr_list);
   I := 0;
   while pPtr^[I] <> nil do begin
      Result := inet_ntoa(pPtr^[I]^);
      Inc(I);
   end;
   WSACleanup;
end;
////////////////////////////////////////////////////////////////////////////////
function THIHost.uIP2Host(IPAddr : String): String;
var   SockAddrIn: TSockAddrIn;
      HostEnt: PHostEnt;
      WSAData: TWSAData;
begin
   Result:='';
   WSAStartup($101, WSAData);
   SockAddrIn.sin_addr.s_addr:= inet_addr(PChar(IPAddr));
   HostEnt:= GetHostByAddr(@SockAddrIn.sin_addr.S_addr, sizeof(in_addr), AF_INET);
   if HostEnt = nil then exit;
   Result := Hostent^.h_name;
   WSACleanup;
end;
////////////////////////////////////////////////////////////////////////////////

end.