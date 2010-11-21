unit hiSMTP;

interface

uses Kol,Share,Windows,Debug;

type
  THISMTP = class(TDebug)
   private
    FHandle:integer;
    FLast:string;

    JoinPart:string;
    Arr:PArray;

    Function SmtpHead(From,Rcpt,Subject:string):boolean;
    procedure SmtpJoin(FileName:string);
    procedure OnStatus(const Text:string);

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
    _prop_From:string;
    _prop_To:string;
    _prop_Subject:string;
    _prop_Port:word;
    _prop_Login:string;
    _prop_Password:string;

    _data_Subject:THI_Event;
    _data_To:THI_Event;
    _data_From:THI_Event;
    _data_Server:THI_Event;
    _data_Body:THI_Event;
    _data_Attach:THI_Event;
    _data_Login:THI_Event;
    _data_Password:THI_Event;
    _event_onSend:THI_Event;
    _event_onStatus:THI_Event;

    procedure _work_doSend(var _Data:TData; Index:word);
    procedure _work_doPort(var _Data:TData; Index:word);
  end;

implementation

uses hiCharset,WinSock;

procedure THISMTP.OnStatus;
begin
   _hi_OnEvent(_event_onStatus,Text);
end;

procedure THISMTP._work_doPort;
begin
  _prop_Port := ToInteger(_Data);
end;

Function THISMTP.SmtpHead(From,Rcpt,Subject:string):boolean;
begin
  Result:=False;

  if _Exec('DATA') <> '3' then exit;
  _WriteLn('From: ' + From);
  _WriteLn('To: ' + Rcpt);
  _WriteLn('Subject: ' + Subject);

  if (Arr <> nil)and(Arr._Count > 0) then
   begin
     JoinPart := 'HIASM_' + Int2Str( Random(65536) );
     _WriteLn('Content-Type: multipart/mixed; boundary="' +  JoinPart + '"');
   end
  else
   begin
     JoinPart := '';
     _WriteLn('Content-Type: text/plain; charset="Windows-1251"');
   end;

  //_WriteLn('Content-Transfer-Encoding: 8bit'#13#10);
  _WriteLn('');

  Result := True;
end;

function FType(const Ext:string):string;
begin
   if pos(Ext,'.zip|.rar|.cab') > 0 then
    Result := 'application/x-zip-compressed'
   else if pos(Ext,'.ico|') > 0 then
    Result := 'image/icon'
   else if pos(Ext,'.jpg|.jpeg|') > 0 then
    Result := 'image/jpeg'
   else if pos(Ext,'.png|') > 0 then
    Result := 'image/png'
   else Result := 'application/octet-stream';
end;

procedure THISMTP.SmtpJoin(FileName:string);
 var
  St:PStream;
  Size:word;
  Buf:string;
begin
  St := NewReadFileStream(FileName);

  _WriteLn('--' + JoinPart);
  _WriteLn('Content-Type: '+FType(LowerCase( ExtractFileExt(FileName) ))+'; name="'+ ExtractFileName(FileName) +'"');
  _WriteLn('Content-Transfer-Encoding: base64');
  _WriteLn('Content-Disposition: attachment; filename="'+ ExtractFileName(FileName) +'"');
  _WriteLn('');

  repeat
    SetLength(buf,90);
    Size := St.read(Buf[1],90);
    SetLength(buf,Size);
    _WriteLn(Base64_Code(buf));
    OnStatus(ExtractFileName(FileName) + '...' + Int2Str(Round(100*(St.Position/St.Size))) + '%');
  until Size < 90;
  st.free;
end;

procedure THISMTP._Connect;
var SockAddr:TSockAddr;
    ip:string;
    p:PHostEnt;
 
    Size:cardinal;
    s:array[0..MAX_COMPUTERNAME_LENGTH] of char;
begin
  UPD_Init;

  FHandle := socket(AF_INET,SOCK_STREAM,IPPROTO_IP);
  ZeroMemory(@SockAddr,SizeOf(SockAddr));

  SockAddr.sin_family := AF_INET;
  p := gethostbyname(PChar(Host));
  if p = nil then
   begin
    closesocket(FHandle);
    FHandle := 0;
    Err(1);
    exit
   end
  else SockAddr.sin_addr.S_addr := integer(pointer(p.h_addr^)^);
  if SockAddr.sin_addr.S_addr = 0 then
    SockAddr.sin_addr.S_addr := inet_addr(PChar(Host));
  SockAddr.sin_port := htons(_prop_Port);
  if Connect(FHandle, SockAddr, sizeof(SockAddr)) <> 0 then
    begin
      Err(2);
    end
  else
   begin
     if _Read = '2' then
      begin
        Size := length(s);
        GetComputerName(s, Size);
        if _Exec('HELO ' + string(s)) = '2' then exit;
        _Disconnect;
        FHandle := 0;
      end
     else
      begin
       _Disconnect;
       FHandle := 0;
     end;
   end;
end;

procedure THISMTP._DisConnect;
begin
   closesocket(FHandle);
end;

procedure THISMTP._Write;
begin
   send(FHandle,text[1],length(text),0);
end;

procedure THISMTP._WriteLn;
begin
   _Write(text + #13#10);
end;

function THISMTP._Read;
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
   FLast := Result;
   if Result = '' then Result := '?' else Result := Result[1];
  until (Length(Result) < 4)or(Result[4] <> '-'); 
end;

procedure THISMTP.Err;
begin
   _hi_OnEvent(_event_onStatus,index);
end;

function THISMTP._Exec;
begin
   _WriteLn(text);
   Result := _Read;
end;

procedure THISMTP._work_doSend;
label error;
var Body,EMailFrom,EMailTo:string;
   i:TData;
   s,to_orig:string;
   l,p:string;
begin
   Arr := ReadArray(_data_Attach);

   randomize;
   Body := ReadString(_Data,_data_Body,'');

   OnStatus('Connect to server...');
   _Connect(ReadString(_Data,_data_Server,_prop_Server));
   if FHandle = 0 then
    begin
      _hi_OnEvent(_event_onSend,'Break from CONNECT');
      goto error;
    end;

   l := ReadString(_data,_data_Login,_prop_Login);
   p := ReadString(_data,_data_Password,_prop_Password);
   if (l <> '')and(p <> '') then
    begin
     OnStatus('Login...');
     if _Exec('AUTH LOGIN') <> '3' then
      begin
       _hi_OnEvent(_event_onSend,'Break from AUTH LOGIN');
       goto error;
      end;

     if _Exec( Base64_Code(l) ) <> '3' then
      begin
       _hi_OnEvent(_event_onSend,'Break from LoginData-sending');
       goto error;
      end;

     if _Exec(Base64_Code(p)) <> '2' then
      begin
       _hi_OnEvent(_event_onSend,'Break from Password-sending');
       goto error;
      end;

    end;

   EMailFrom := ReadString(_data,_data_From,_prop_From);
   OnStatus('Check MAIL From: ' + EMailFrom);
   if _Exec('MAIL From: ' + EMailFrom) <> '2' then
     begin
       _hi_OnEvent(_event_onSend,'Break from FROM-sending');
       goto error;
     end;

   to_orig := ReadString(_data,_data_To,_prop_To);
   s := to_orig + ';';
   replace(s, ',', ';');
   repeat
    EMailTo := gettok(s,';');
    OnStatus('Check RCPT To: ' + EMailTo);
    if _Exec('RCPT To: ' + EMailTo) <> '2' then
     begin
       _hi_OnEvent(_event_onSend,'Break from TO-sending');
       goto error;
     end;
    until s = '';

   OnStatus('Send head');
   if not SmtpHead(EMailFrom,to_orig,ReadString(_data,_data_Subject,_prop_Subject)) then
     begin
       _hi_OnEvent(_event_onSend,'Break from HEAD-sending');
       goto error;
     end;

   OnStatus('Send body');
   if JoinPart <> '' then
    begin
      _Writeln('--' + JoinPart);
      _Writeln('Content-Type: text/plain; charset="Windows-1251"');
      _Writeln('Content-Transfer-Encoding: 8bit');
      _Writeln('');
    end;
   _Writeln(Body);

   i.Data_type := data_int;
   i.idata := 0;
   if Arr <> nil then
   while Arr._Get(i,_Data) do
    begin
     s := ToString(_Data);
     if FileExists(s) then
      SmtpJoin(s);
     inc(i.idata);
    end;

   if JoinPart <> '' then
    _Writeln('--' + JoinPart + '--');

   OnStatus('Close connection');
   if _Exec('.') = '2' then
     begin
      _DisConnect;
      _hi_OnEvent(_event_onSend); //Ok
     end
   else _hi_OnEvent(_event_onSend,'Break from BODY-sending');

  Exit;
error:
  OnStatus('Connect close:' + FLast);
end;


end.
