unit hiTCPStat;

interface

uses Kol,Share,Debug,Win, Windows, winsock;

const
  // Константы состояний порта
  MIB_TCP_STATE_CLOSED     = 1;
  MIB_TCP_STATE_LISTEN     = 2;
  MIB_TCP_STATE_SYN_SENT   = 3;
  MIB_TCP_STATE_SYN_RCVD   = 4;
  MIB_TCP_STATE_ESTAB      = 5;
  MIB_TCP_STATE_FIN_WAIT1  = 6;
  MIB_TCP_STATE_FIN_WAIT2  = 7;
  MIB_TCP_STATE_CLOSE_WAIT = 8;
  MIB_TCP_STATE_CLOSING    = 9;
  MIB_TCP_STATE_LAST_ACK   = 10;
  MIB_TCP_STATE_TIME_WAIT  = 11;
  MIB_TCP_STATE_DELETE_TCB = 12;

type
  // Стандартная структура для получения ТСР статистики
  PTMibTCPRow = ^TMibTCPRow;
  TMibTCPRow = packed record
    dwState: DWORD;
    dwLocalAddr: DWORD;
    dwLocalPort: DWORD;
    dwRemoteAddr: DWORD;
    dwRemotePort: DWORD;
  end;

  // В данную структуру будет передаваться результат GetTcpTable
  PTMibTCPTable = ^TMibTCPTable;
  TMibTCPTable = packed record
    dwNumEntries: DWORD;
    Table: array[0..0] of TMibTCPRow;
  end;

  // Стандартная структура для получения UDP статистики
  PTMibUdpRow = ^TMibUdpRow;
  TMibUdpRow = packed record
    dwLocalAddr: DWORD;
    dwLocalPort: DWORD;
  end;

  // В данную структуру будет передаваться результат GetUDPTable
  PTMibUdpTable = ^TMibUdpTable;
  TMibUdpTable = packed record
    dwNumEntries: DWORD;
    table: array [0..0] of TMibUdpRow;
  end;

type
  THITCPStat = class(TDebug)
   private
   public
     _event_onEnumTCP: THI_Event;
     _event_onEnumUDP: THI_Event;
     _event_onPortIsOpen: THI_Event;
     _data_IP: THI_Event;
     _data_Port : THI_Event;
    
     procedure _work_doEnumTCP(var _Data:TData; Index:word);
     procedure _work_doEnumUDP(var _Data:TData; Index:word);
     procedure _work_doPortIsOpen(var _Data:TData; Index:word);
  end;

 function GetTcpTable(pTCPTable: PTMibTCPTable; var pDWSize: DWORD;
                      bOrder: BOOL): DWORD; stdcall; external 'IPHLPAPI.DLL';
 function GetUdpTable(pUDPTable: PTMibUDPTable; var pDWSize: DWORD;
                      bOrder: BOOL): DWORD; stdcall; external 'IPHLPAPI.DLL';

implementation

procedure THITCPStat._work_doEnumTCP;
var
  Size, i: DWORD;
  dtla, dtlp, dtra, dtrp, dtst: TData;
  fTCPTable: PTMibTCPTable;
  
  // Функция преобразует состояние порта в строковый эквивалент
  function PortStateToStr(const State: DWORD): String;
  begin
    case State of
      MIB_TCP_STATE_CLOSED: Result := 'CLOSED';
      MIB_TCP_STATE_LISTEN: Result := 'LISTEN';
      MIB_TCP_STATE_SYN_SENT: Result := 'SYN SENT';
      MIB_TCP_STATE_SYN_RCVD: Result := 'SYN RECEIVED';
      MIB_TCP_STATE_ESTAB: Result := 'ESTABLISHED';
      MIB_TCP_STATE_FIN_WAIT1: Result := 'FIN WAIT 1';
      MIB_TCP_STATE_FIN_WAIT2: Result := 'FIN WAIT 2';
      MIB_TCP_STATE_CLOSE_WAIT: Result := 'CLOSE WAIT';
      MIB_TCP_STATE_CLOSING: Result := 'CLOSING';
      MIB_TCP_STATE_LAST_ACK: Result := 'LAST ACK';
      MIB_TCP_STATE_TIME_WAIT: Result := 'TIME WAIT';
      MIB_TCP_STATE_DELETE_TCB: Result := 'DELETE TCB';
    else
      Result := 'UNKNOWN';
    end;
  end;
  
begin
  Size := 0;
  GetMem(fTCPTable, SizeOf(TMibTCPTable));
try
  if GetTcpTable(fTCPTable, Size, true) <> ERROR_INSUFFICIENT_BUFFER then exit;
  FreeMem(fTCPTable);
  GetMem(fTCPTable, Size);
  if GetTcpTable(fTCPTable, Size, true) <> NO_ERROR then exit;
  for i := 0 to fTCPTable^.dwNumEntries - 1 do
  begin
    dtString(dtla, inet_ntoa(in_addr(fTCPTable^.Table[i].dwLocalAddr)));
    dtInteger(dtlp, htons(fTCPTable^.Table[i].dwLocalPort));
    dtString(dtra, inet_ntoa(in_addr(fTCPTable^.Table[i].dwRemoteAddr)));
    dtInteger(dtrp, htons(fTCPTable^.Table[i].dwRemotePort));
    dtString(dtst, PortStateToStr(fTCPTable^.Table[i].dwState));
    dtla.ldata := @dtlp;
    dtlp.ldata := @dtra;
    dtra.ldata := @dtrp;
    dtrp.ldata := @dtst;
    _hi_onEvent_(_event_onEnumTCP, dtla);
  end;
finally
  FreeMem(fTCPTable);
end;  
end;

procedure THITCPStat._work_doEnumUDP;
var
  Size, i: DWORD;
  dtla, dtlp: TData;  
  fUDPTable: PTMibUdpTable;  
begin
  Size := 0;
  GetMem(fUDPTable, SizeOf(TMibUDPTable));
try   
  if GetUDPTable(fUDPTable, Size, true) <> ERROR_INSUFFICIENT_BUFFER then exit;
  FreeMem(fUDPTable);
  GetMem(fUDPTable, Size);
  if GetUDPTable(fUDPTable, Size, true) <> NO_ERROR then exit;
  for i := 0 to fUDPTable^.dwNumEntries - 1 do
  begin
    dtString(dtla, inet_ntoa(in_addr(fUDPTable^.Table[i].dwLocalAddr)));
    dtInteger(dtlp, htons(fUDPTable^.Table[i].dwLocalPort));
    dtla.ldata := @dtlp;
    _hi_onEvent_(_event_onEnumUDP, dtla);
  end;  
finally
  FreeMem(fUDPTable);  
end;
end;

procedure THITCPStat._work_doPortIsOpen;

  function PortTCP_IsOpen(ipAddressStr: AnsiString; dwPort: Word): boolean;
  var
    client : sockaddr_in;
    sock, ret : integer;
    wsdata : WSAData;
  begin
    Result := false;
    ret := WSAStartup($101, wsdata);                              //initiates use of the Winsock DLL
  try
    if ret <> 0 then exit;
    client.sin_family      := AF_INET;                            //Set the protocol to use , in this case (IPv4)
    client.sin_port        := htons(dwPort);                      //convert to TCP/IP network byte order (big-endian)
    client.sin_addr.s_addr := inet_addr(PAnsiChar(ipAddressStr)); //convert to IN_ADDR structure
    sock                   := socket(AF_INET, SOCK_STREAM, 0);    //creates a socket
    Result := connect(sock, client, SizeOf(client)) = 0;          //establishes a connection to a specified socket
  finally
    WSACleanup;
  end;
  end;

begin
  _hi_onEvent(_event_onPortIsOpen, ord(PortTCP_IsOpen(ReadString(_Data, _data_IP), ReadInteger(_Data, _data_Port))));
end;

end.