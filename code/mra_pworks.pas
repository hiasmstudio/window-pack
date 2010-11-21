unit mra_pworks;

interface

uses
  kol, Windows, WinSock, mra_proto, Share;

  function GetIP: String;
  function HostToIP(Host: String): String;
  function ExtractIPAndPort(Str: String; var Host: String; var Port: WORD): Boolean;
  function ExtractLoginAndHost(Str: String; var Login: String; var Host: String): Boolean;

  function SendBuffer(Socket: TSocket; Buffer: Pointer; Len: Integer): Integer;
  function RecvBuffer(Socket: TSocket; Buffer: Pointer; Len: Integer): Integer; 

  procedure MMP_Pack(lpPack: PMRIMPacket; CmdNum, Cmd, Port: DWORD; IP: String);
  procedure MMP_AddUL(lpPack: PMRIMPacket; var Data: Pointer; Value: DWORD);
  procedure MMP_AddLPS(lpPack: PMRIMPacket; var Data: Pointer; Value: String);
  procedure MMP_AddBuf(lpPacK: PMRIMPacket; var Data: Pointer; Value: Pointer; Len: DWORD);
  function MMP_GetUL(lpPack: PMRIMPacket; Data: Pointer; var Offset: DWORD): DWORD;
  function MMP_GetLPS(lpPack: PMRIMPacket; Data: Pointer; var Offset: DWORD): String;
  
  function MMP_SendPack(Socket: TSocket; lpPack: PMRIMPacket; Data: Pointer = NIL): Integer;
  function MMP_RecvPack(Socket: TSocket; lpPack: PMRIMPacket): Integer;
  function MMP_RecvData(Socket: TSocket; lpPack: PMRIMPacket; var Data: Pointer): Integer;
  
implementation

function ExtractIPAndPort;
var
  Code: Integer;
begin
  Host := Copy(Str, 1, Pos(':', Str) - 1);
  val(Copy(Str, Pos(':', Str) + 1, Length(Str)), Port, Code);
  Result := (Length(Host) > 0) and (Code <> 0);
end;

function ExtractLoginAndHost;
begin
  Login := Copy(Str, 1, Pos('@', Str) - 1);
  Host := Copy(Str, Pos('@', Str) + 1, Length(Str));
  Result := (Length(Login) > 0) and (Length(Host) > 0);
end;

function GetIP;
var
  p: PHostEnt;
  name: array[0..MAX_PATH-1] of CHAR;
begin
  ZeroMemory(@name, MAX_PATH);
  gethostname(name, MAX_PATH);
  P := gethostbyname(name);
  if p <> NIL then
    Result := inet_ntoa(pinaddr(p.h_addr_list^)^)
  else
    Result := '127.0.0.1';
end;

function HostToIP;
var
  hostName : array [0..255] of char;
  hostEnt : PHostEnt;
  addr : PChar;
begin
  Result := '0.0.0.0';
  gethostname (hostName, sizeof (hostName));
  StrPCopy(hostName, Host);
  hostEnt := gethostbyname (hostName);
  if Assigned (hostEnt) and Assigned (hostEnt^.h_addr_list) then
  begin
    addr := hostEnt^.h_addr_list^;
    if Assigned (addr) then
    begin
      Result := int2str(byte(addr[0])) + '.' + int2str(byte(addr[1])) + '.' + int2str(byte(addr[2])) + '.' + int2str(byte(addr[3]));  
    end;
  end;
end;

function SendBuffer;
var
  i: Integer;
  n: Integer;
begin
  i := 0;
  if Socket <> INVALID_SOCKET then
  repeat
    n := send(Socket, Pointer(Integer(Buffer) + i)^, (Len - i), 0);
    if (n = SOCKET_ERROR) or (n = 0) then
      Break;
    i := i + n;   
  until
    (i = Len);
  Result := i;
end;

function RecvBuffer;
var
  i: Integer;
  n: Integer;
begin
  i := 0;
  if Socket <> INVALID_SOCKET then
  repeat   
    n := recv(Socket, Pointer(Integer(Buffer) + i)^, (Len - i), 0);
    if (n = SOCKET_ERROR) or (n = 0) then
      Break;
    i := i + n;
  until
    (i = Len);
  Result := i;
end;

procedure MMP_Pack;
begin
  ZeroMemory(lpPack, SizeOf(TMRIMPacket));
  lpPack.magic := CS_MAGIC;
  lpPack.proto := PROTO_VERSION;
  lpPack.seq := CmdNum;
  lpPack.msg := Cmd;
  lpPack.from := inet_addr(PCHAR(IP));
  lpPack.fromport := Port;
end;

procedure MMP_AddUL;
begin
  if lpPack.dlen = 0 then
    GetMem(Data, SizeOf(Value))
  else
    ReAllocMem(Data, lpPack.dlen + SizeOf(Value));
  MoveMemory(Pointer(DWORD(Data) + lpPack.dlen), @Value, SizeOf(Value));
  lpPack.dlen := lpPack.dlen + SizeOf(Value);
end;

procedure MMP_AddLPS;
var
  LenLPS: DWORD;
  LPS: String;
begin
  LPS := Value;
  LenLPS := Length(LPS);
  if lpPack.dlen = 0 then
    GetMem(Data, SizeOf(LenLPS) + LenLPS)
  else
    ReAllocMem(Data, lpPack.dlen + SizeOf(LenLPS) + LenLPS);
  MoveMemory(Pointer(DWORD(Data) + lpPack.dlen), @LenLPS, SizeOf(LenLPS));
  if LenLPS > 0 then
  MoveMemory(Pointer(DWORD(Data) + lpPack.dlen + SizeOf(LenLPS)), PCHAR(LPS), LenLPS);
  lpPack.dlen := lpPack.dlen + SizeOf(LenLPS) + LenLPS;
end;

procedure MMP_AddBuf;
begin
  if lpPack.dlen = 0 then
    GetMem(Data, Len)
  else
    ReAllocMem(Data, lpPack.dlen + Len);
  MoveMemory(Pointer(DWORD(Data) + lpPack.dlen), Value, Len);
  lpPack.dlen := lpPack.dlen + Len;
end;

function MMP_GetUL;
begin
  Result := 0;
  if Offset + SizeOf(DWORD) <= lpPack.dlen then
  begin
    Result := DWORD(Pointer(DWORD(Data) + Offset)^);
    Offset := Offset + SizeOf(DWORD);
  end;
end;

function MMP_GetLPS;
var
  LenLPS: DWORD;
begin
  LenLPS := MMP_GetUL(lpPack, Data, Offset);
  if (LenLPS > 0) and (Offset + LenLPS <= lpPack.dlen) then
  begin
    SetLength(Result, LenLPS);
    MoveMemory(PCHAR(Result), Pointer(DWORD(Data) + Offset), LenLPS);
    Offset := Offset + LenLPS;
  end;
end; 

function MMP_SendPack;
begin
  Result := SendBuffer(Socket, lpPack, SizeOf(TMRIMPacket));
  if (lpPack.dlen > 0) and (Data <> NIL) then
  Result := Result + SendBuffer(Socket, Data, lpPack.dlen);
end;

function MMP_RecvPack;
begin
  Result := RecvBuffer(Socket, lpPack, SizeOf(TMRIMPacket));
end;

function MMP_RecvData;
begin
  if lpPack.dlen > 0 then
  begin
    GetMem(Data, lpPack.dlen);
    Result := RecvBuffer(Socket, Data, lpPack.dlen);
  end else
    Result := -1;
end;

end.