unit hiPOP3;

interface

uses Kol,Share,Debug;

type
  THIPOP3 = class(TDebug)
   private
    FCount:integer;
    FHandle:cardinal;
    last:string;

    procedure OpenMailBox(Server,User,Password:string; Port:word);
    Procedure CloseMailBox;
    Function MailCount:integer;
    Function GetMail(Index:integer):string;
    Function DelMail(Index:integer):string;
    Function TopMail(Index:integer):string;

    //_______________________________
    procedure _Connect(const Host:string);
    procedure _Write(text:string);
    procedure _WriteLn(text:string);
    function _Read:string;
    procedure _DisConnect;
    procedure Err(Index:integer);
    function _Exec(text:string):string;
    //_______________________________
   public
    _prop_Server:string;
    _prop_Login:string;
    _prop_Password:string;
    _prop_Port:word;
    _prop_Count:word;

    _data_Password:THI_Event;
    _data_Login:THI_Event;
    _data_Server:THI_Event;
    _event_onRead:THI_Event;
    _event_onConnect:THI_Event;
    _event_onError:THI_Event;

    procedure _work_doConnect(var _Data:TData; Index:word);
    procedure _work_doRead(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);
    procedure _work_doTop(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _work_doPort(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
  end;

implementation

uses WinSock,Windows;

procedure THIPOP3._Connect;
var SockAddr:TSockAddr;
    Z:PHostEnt;
begin
  UPD_Init;
  FHandle := 0;
  z := gethostbyname(PChar(Host));
  if Z = nil then
   begin
    Err(1);
    exit;
   end;

  FHandle := socket(AF_INET,SOCK_STREAM,IPPROTO_IP);
  ZeroMemory(@SockAddr,SizeOf(SockAddr));

  SockAddr.sin_family := AF_INET;
  SockAddr.sin_addr.S_addr := integer(pointer(Z.h_Addr^)^);
  if SockAddr.sin_addr.S_addr = 0 then
    SockAddr.sin_addr.S_addr := inet_addr(PChar(Host));
  SockAddr.sin_port := htons(_prop_Port);
  if Connect(FHandle, SockAddr, sizeof(SockAddr)) <> 0 then
    begin
      Err(2);
    end;
end;

procedure THIPOP3._DisConnect;
begin
   closesocket(FHandle);
   FHandle := 0;
end;

procedure THIPOP3._Write;
begin
   send(FHandle,text[1],length(text),0);
end;

procedure THIPOP3._WriteLn;
begin
   _Write(text + #13#10);
end;

function THIPOP3._Read;
var
    FDSet:TFDSet;
    len:integer;
begin
  repeat
   //repeat
    FD_ZERO(FDSet);
    FD_SET(FHandle, FDSet);
   //until
   select(0,@FDSet,nil,nil,nil);

   ioctlsocket(FHandle, FIONREAD, len);
   setlength(Result,len);
   //if recv(Handle,s[1],len,0) <> SOCKET_ERROR then
   recv(FHandle,Result[1],len,0);
  until (Length(Result) < 4)or(Result[4] <> '-');
  last := Result;
  if Result = '' then Result := '?' else Result := Result[1];
end;

procedure THIPOP3.Err;
begin
   _hi_OnEvent(_event_onError,index);
end;

function THIPOP3._Exec;
begin
   _WriteLn(text);
   Result := _Read;
end;

procedure THIPOP3.OpenMailBox;
begin
  _Connect(Server);
  if FHandle > 0 then
   if _Read = '+' then
    begin
     if (_Exec('USER ' + User)='+') and (_Exec('PASS ' + Password)='+') then exit;
     _Disconnect;
     Err(3);
    end
   else
    begin
     _Disconnect;
     Err(4);
    end;
end;

Procedure THIPOP3.CloseMailBox;
begin
  _Exec('QUIT');
  _DisConnect;
end;

Function THIPOP3.MailCount:integer;
 var
  i:integer;
begin
  Result := -1;
  if _Exec('STAT') <> '+' then exit;
  i := pos(' ',Last);
  if i = 0 then exit;

  while Last[i] = ' ' do inc(i);
  Result:=0;
  while (i < length(Last))and(Last[i] in ['0'..'9']) do begin
   Result:=10*Result+ord(Last[i])-ord('0');
   inc(i);
  end;
end;

Function THIPOP3.GetMail(Index:integer):string;
{
var
  s:string;
  lst:PStrList;
}
begin
  _Writeln('RETR ' + int2str(Index));
  result := '';
  if _Read = '+' then
   begin
    Result := last;
    while pos(#13#10'.'#13#10,Result) = 0 do
     begin
      _Read;
      Result := Result + last;
     end;
    {
    lst := NewStrList;
    Repeat
     _Read;
     Result := Result + last;
     lst.Text := last;
    until pos(#13#10'.'#13#10,Result) > 0; //lst.Items[Lst.Count-1] = '.';
    lst.Free;
    }
   end;
end;

Function THIPOP3.DelMail(Index:integer):string;
{
var
  s:string;
  lst:PStrList;
}
begin
  _Writeln('DELE ' + int2str(Index));
  if _Read = '+' then
    result := 'ok'
   else result := 'err';
  {
  if _Read = '+' then
   begin
    lst := NewStrList;
    Repeat
     _Read;
     Result := Result + last;
     lst.Text := last;
    until lst.Items[Lst.Count-1] = '.';
    lst.Free;
   end;
  }
end;

Function THIPOP3.TopMail(Index:integer):string;
begin
  _Writeln('TOP ' + int2str(Index) + ' ' + int2str(_prop_Count));
  //if _Read = '+' then Result := last;

  result := '';
  if _Read = '+' then
   begin
    Result := last;
    while pos(#13#10'.'#13#10,Result) = 0 do
     begin
      _Read;
      Result := Result + last;
     end;
  end; { If }

end;

procedure THIPOP3._work_doConnect;
begin
  if FHandle > 0 then exit;

  FCount := 0;
  OpenMailBox(ReadString(_Data,_data_Server,_prop_Server),
              ReadString(_Data,_data_Login,_prop_Login),
              ReadString(_Data,_data_Password,_prop_Password),_prop_Port);
  if FHandle = 0 then   Exit;
  FCount := MailCount;
  _hi_OnEvent(_event_onConnect,FCount);
end;

procedure THIPOP3._work_doRead;
var i:smallint;
begin
   i := ToInteger(_Data);
   if (i > 0)and(i <= FCount)then
     _hi_OnEvent(_event_onRead,GetMail(i));
end;

procedure THIPOP3._work_doDelete;
var i:smallint;
begin
   i := ToInteger(_Data);
   if (i > 0)and(i <= FCount)then
     _hi_OnEvent(_event_onRead,DelMail(i));
end;

procedure THIPOP3._work_doTop;
var i:smallint;
begin
   i := ToInteger(_Data);
   if (i > 0)and(i <= FCount)then
     _hi_OnEvent(_event_onRead,TopMail(i));
end;

procedure THIPOP3._work_doClose;
begin
   if FHandle > 0 then
    CloseMailBox;
   FHandle := 0;
end;

procedure THIPOP3._work_doPort;
begin
   _prop_Port := ToInteger(_Data);
end;

procedure THIPOP3._var_Count;
begin
   dtInteger(_Data,FCount);
end;

end.
