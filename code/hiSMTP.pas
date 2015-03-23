unit hiSMTP;

interface

uses Kol,Share,Windows,Debug,WinSock;

type
  THISMTP = class(TDebug)
    private
      FHandle: TSocket;
      FLast:string;

      JoinPart:string;
      Arr:PArray;

      function SmtpHead(From, Rcpt, Subject: string): boolean;
      function SmtpJoin(FileName: string): boolean;
      procedure OnStatus(const Text: string);

      //_______________________________
      function _Connect(const Host: string): boolean;
      function _Write(text: string): boolean;
      function _WriteLn(text: string): boolean;
      function _Read: string;
      procedure _DisConnect;
      procedure Err(Index: integer);
      function _Exec(text: string): string;
      //_______________________________
    public
      _prop_Server: string;
      _prop_From: string;
      _prop_To: string;
      _prop_Subject: string;
      _prop_Port: word;
      _prop_Login: string;
      _prop_Password: string;
      _prop_IntroduceAs: string;
      _prop_Greeting: Integer;
      _prop_AuthType: Integer;

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
      procedure _work_doIntroduceAs(var _Data:TData; Index:word);
      procedure _work_doAuthType(var _Data:TData; Index:word);
  end;

implementation

uses hiCharset;

procedure THISMTP.OnStatus;
begin
  _hi_OnEvent(_event_onStatus,Text);
end;

procedure THISMTP._work_doPort;
begin
  _prop_Port := ToInteger(_Data);
end;

procedure THISMTP._work_doIntroduceAs;
begin
  _prop_IntroduceAs := Share.ToString(_Data);
end;

procedure THISMTP._work_doAuthType;
begin
  _prop_AuthType := ToInteger(_Data);
end;

function THISMTP.SmtpHead(From,Rcpt,Subject:string):boolean;
begin
  Result := False;

  if _Exec('DATA') <> '3' then Exit;
  _WriteLn('From: ' + From);
  _WriteLn('To: ' + Rcpt);
  Result := _WriteLn('Subject: ' + Subject);
  
  if not Result then Exit;
  
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
  Result := _WriteLn('');

  //Result := True;
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
  else
    Result := 'application/octet-stream';
end;

function THISMTP.SmtpJoin(FileName:string): boolean;
const
  BUF_SIZE = 1023; // Подбирать нужно так, чтобы Base64_Code не добавляла лишних "="
var
  St:PStream;
  Size:word;
  Buf, S:string;
  Fn: string;
  C: Integer;
begin
  St := NewReadFileStream(FileName);
  if St.Handle = INVALID_HANDLE_VALUE then // Если не удалось открыть файл - возвращаем успех, но файл не шлем
  begin
    Result := True;
    St.Free;
    Exit;
  end;
  Fn := ExtractFileName(FileName);
  _WriteLn('--' + JoinPart);
  _WriteLn('Content-Type: '+FType(LowerCase( ExtractFileExt(FileName) ))+'; name="'+ Fn +'"');
  _WriteLn('Content-Transfer-Encoding: base64');
  _WriteLn('Content-Disposition: attachment; filename="'+ Fn +'"');
  Result := _WriteLn('');
  if Result then
  begin
    SetLength(buf,BUF_SIZE);
    repeat
      Size := St.read(Buf[1],BUF_SIZE);
      if Size > 0 then
      begin
        Result := _WriteLn(Base64_Code(Copy(buf, 1, Size)));
        OnStatus(Fn + '...' + Int2Str(Round(100*(St.Position/St.Size))) + '%');
      end;
    until (Size < BUF_SIZE) or (Result = False);
  end;
  
  St.Free;
end;

function THISMTP._Connect;
var 
  Addr: TSockAddr;
  IP: string;
  Sock: TSocket;
  
  G: string;
  //CompName: string;
  //Sz: cardinal;
begin
  Result := False;
  
  _Disconnect;

  IP := TCPGetHostByName(PChar(Host));
  if Length(IP) = 0 then
  begin
    Err(1);
    exit;
  end;
  
  Sock := Winsock.socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  if Sock = 0 then
  begin
    Err(1);
    exit;
  end;
  
  FillChar(Addr, SizeOf(TSockAddr), #0);
  Addr.sin_family := AF_INET;
  Addr.sin_port := htons(_prop_Port);
  Addr.sin_addr.S_addr := inet_addr(PChar(IP));


  if Winsock.connect(Sock, Addr, SizeOf(Addr)) <> 0 then
  begin
    //_debug(WSAGetLastError);
    closesocket(Sock);
    Err(2);
  end
  else
  begin 
    FHandle := Sock;
    if _Read = '2' then
    begin
      {
      SetLength(CompName, MAX_COMPUTERNAME_LENGTH);
      Sz := MAX_COMPUTERNAME_LENGTH;
      GetComputerName(PChar(CompName), Sz);
      SetLength(CompName, Sz); // Подгоняем длину строки
      }
      if _prop_Greeting = 0 then G := 'HELO' else G := 'EHLO';
      if _Exec(G + ' ' + _prop_IntroduceAs) = '2' then
      begin
        Result := True;
      end
      else
        _Disconnect;
   end
   else
     _Disconnect;
  end;
end;

procedure THISMTP._DisConnect;
begin
  if FHandle <> 0 then
  begin
    shutdown(FHandle, 2); // 2 - SD_BOTH
    closesocket(FHandle);
    FHandle := 0;
  end;
end;

function THISMTP._Write;
const
  SEND_SIZE = 4*1024;
var
  Total, Len, SendLen, Sended: Integer;
begin
  Result := False;
  if FHandle = 0 then Exit;
  
  Len := Length(text);
  Total := 0;
  
  repeat
    SendLen := Len - Total;
    if SendLen > SEND_SIZE  then SendLen := SEND_SIZE;
    
    Sended := send(FHandle,text[1 + Total], SendLen, 0);
    if Sended = SOCKET_ERROR then
    begin
      _DisConnect;
      Exit;
    end;
    Inc(Total, Sended);      
  until Total >= Len;
  Result := True;
end;

function THISMTP._WriteLn;
begin
  Result := _Write(text + #13#10);
end;

function THISMTP._Read;
type
  TSocketSet = record // Упрощенный аналог WinSock.TFDSet для одного сокета
    Count: Integer;
    Socket: TSocket;
  end;
const
  MAX_RESPONSE = 10*1024;
var
  Buf: string;
  ByteReceived, Available: Integer;

  FDRead, FDErr: TSocketSet;
  TimeVal: TTimeVal;
begin  
  Result := '?';
  
  if FHandle = 0 then Exit;
  
  ByteReceived := 0;
  Available := 0;
  FLast := '';
  
  // Каждый ответ сервера завершается символами #13#10
  while Length(FLast) < MAX_RESPONSE do
  begin
    
    FDRead.Count := 1;
    FDRead.Socket := FHandle;
    FDErr.Count := 1;
    FDErr.Socket := FHandle;

    
    TimeVal.tv_sec := 4; // Таймаут ожидания данных - 4 сек
    TimeVal.tv_usec := 0;

    // Ожидаем доступности данных по таймауту
    case select(0, PFDSet(@FDRead), nil, PFDSet(@FDErr), @TimeVal) of
      SOCKET_ERROR:
        begin
          _DisConnect;
          Break;
        end;
      0:  // Таймаут
        begin
          //_DisConnect;
          Break;
        end;
      else
        begin
          if FDErr.Count > 0 then // Получили ошибку
          begin
            _DisConnect;
            Break;
          end;
        end;
    end;
    
    ioctlsocket(FHandle, FIONREAD, Available);
    
    if Available < 1 then // Получили сообщение, что данные готовы, но размер 0 - соединение завершено
    begin
      _DisConnect;
      Break;
    end;
    
    // Готовим буфер нужного размера 
    if Length(Buf) < Available then SetLength(Buf, Available);
    
    // Считываем данные
    ByteReceived := recv(FHandle, Buf[1], Available, 0);
    if ByteReceived < 1 then // 0 - отключено от сервера, -1 - ошибка соединения
    begin 
      _DisConnect;
      Break;
    end;
    FLast := FLast + Copy(Buf, 1, ByteReceived); // Полный ответ
    
    // Ищем #13#10 (многострочные ответы могут быть получены не полностью, но нас пока не интересует)
    // Многострочный ответ начинается "XXX-текст1", заканчивается "YYY текст2", где X, Y - три цифры
    if Pos(#13#10, FLast) > 0 then // TODO: Использовать PosEx с индексом Length(FLast)-ByteReceived-2
    begin
      Result := Copy(FLast, 1, 1); // Получаем первый символ кода ответа
      Break;
    end;
  end;
end;


procedure THISMTP.Err;
begin
  _hi_OnEvent(_event_onStatus,index);
end;

function THISMTP._Exec;
begin
  if _WriteLn(text) then Result := _Read;
end;

procedure THISMTP._work_doSend;
label
  error;
var 
  Body,EMailFrom,EMailTo:string;
  i:TData;
  s,to_orig:string;
  l,p:string;
  Rslt: boolean;
begin
  Arr := ReadArray(_data_Attach);

  randomize;
  Body := ReadString(_Data,_data_Body,'');

  OnStatus('Connecting to the server...');
  if not _Connect(ReadString(_Data,_data_Server,_prop_Server)) then
  begin
   _hi_OnEvent(_event_onSend,'Break from CONNECT');
   goto error;
  end;
  
  // Авторизация
  l := ReadString(_data,_data_Login,_prop_Login);
  p := ReadString(_data,_data_Password,_prop_Password);
  if (l <> '') and (p <> '') then
  begin
    OnStatus('Authorization...');
    if _prop_AuthType = 0 then // LOGIN
    begin
      if _Exec('AUTH LOGIN') <> '3' then
      begin
        _hi_OnEvent(_event_onSend,'Break from AUTH LOGIN');
        goto error;
      end;

      if _Exec(Base64_Code(l)) <> '3' then
      begin
        _hi_OnEvent(_event_onSend,'Break from LoginData-sending');
        goto error;
      end;

      if _Exec(Base64_Code(p)) <> '2' then
      begin
        _hi_OnEvent(_event_onSend,'Break from Password-sending');
        goto error;
      end;
    end
    else // PLAIN
    begin
      if _Exec('AUTH PLAIN') <> '3' then
      begin
        _hi_OnEvent(_event_onSend,'Break from AUTH PLAIN');
        goto error;
      end;

      if _Exec(Base64_Code(#0 + l + #0 + p)) <> '2' then
      begin
        _hi_OnEvent(_event_onSend,'Break from LoginData-sending');
        goto error;
      end;
    end;
  end;

  EMailFrom := ReadString(_data,_data_From,_prop_From);
  OnStatus('Check MAIL FROM: ' + EMailFrom);
  if _Exec('MAIL FROM: ' + EMailFrom) <> '2' then
  begin
    _hi_OnEvent(_event_onSend,'Break from FROM-sending');
    goto error;
  end;

   to_orig := ReadString(_data,_data_To,_prop_To);
   s := to_orig + ';';
   replace(s, ',', ';');
  repeat
    EMailTo := gettok(s,';');
    OnStatus('Check RCPT TO: ' + EMailTo);
    if _Exec('RCPT TO: ' + EMailTo) <> '2' then
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
  Rslt := True;
  if JoinPart <> '' then
  begin
    _Writeln('--' + JoinPart);
    _Writeln('Content-Type: text/plain; charset="Windows-1251"');
    _Writeln('Content-Transfer-Encoding: 8bit');
    Rslt := _Writeln('');
  end;
  
  if (not Rslt) or (not _Writeln(Body)) then
  begin
    _hi_OnEvent(_event_onSend, 'Break from BODY-sending 1');
    goto error;
  end;  

  i.Data_type := data_int;
  i.idata := 0;
  if Arr <> nil then
    while Arr._Get(i,_Data) do
    begin
      s := ToString(_Data);
      if FileExists(s) then
      begin
        Rslt := SmtpJoin(s);
        if not Rslt then
        begin
          _hi_OnEvent(_event_onSend, 'Break from attach sending');
          goto error;
        end; 
      end;
      inc(i.idata);
    end;


  if JoinPart <> '' then
  begin
    Rslt := _Writeln('--' + JoinPart + '--');
    if not Rslt then
    begin
      _hi_OnEvent(_event_onSend, 'Break from BODY-sending 2');
      goto error;
    end; 
  end;

  OnStatus('Close connection');
  s := _Exec('.');
  _DisConnect;
  if s = '2' then
    _hi_OnEvent(_event_onSend) //Ok
  else
    _hi_OnEvent(_event_onSend,'Break from BODY-sending 3');


  Exit;
error:
  OnStatus('Connection closed: ' + FLast);
end;

initialization
  UPD_Init; // Инициализация WinSock
  
end.
