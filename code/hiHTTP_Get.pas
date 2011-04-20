unit hiHTTP_Get;

interface

{$I share.inc}

uses Kol,Share,WinInet,Windows,Debug,hiCharset;

type
  THIHTTP_Get = class(TDebug)
   private
    th:PThread;
    FStop:boolean;
    GData:TData;
    FSize:cardinal;
    FBusy:boolean;

    fs:PStream;

    procedure ShowInfo;
    procedure EndDownload;
    procedure OnDownload;
    function Execute(Sender:PThread): Integer;
   public
    _prop_URL:string;
    _prop_FileName:string;
    _prop_Wait:boolean;
    _prop_Proxy:string;
    _prop_ProxyUsername:string;
    _prop_ProxyPassword:string;
    _prop_Length:cardinal;
    _prop_UserAgent:PChar;
    _prop_Method:integer;

    _data_FileName:THI_Event;
    _data_URL:THI_Event;
    _data_Position:THI_Event;
    _data_Length:THI_Event;
    _data_Proxy:THI_Event;
    _data_ProxyUsername:THI_Event;
    _data_ProxyPassword:THI_Event;
    _data_PostData:THI_Event;
    _event_onURLSize:THI_Event;
    _event_onDownload:THI_Event;
    _event_onStatus:THI_Event;
    _event_onStop:THI_Event;

   procedure _work_doDownload(var _Data:TData; Index:word);
   procedure _work_doStop(var _Data:TData; Index:word);
   procedure _work_GetURLSize(var _Data:TData; Index:word);
   procedure _var_Busy(var _Data:TData; Index:word);
  end;

implementation

function GetUrlInfo(const FileURL, agent: string):cardinal;
var
  hSession, hFile: hInternet;
  dwBuffer:array[0..20] of char;
  dwBufferLen, dwIndex: DWORD;
begin
  Result := 0;
  hSession := InternetOpen(PChar(agent),INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if Assigned(hSession) then
   begin
    hFile := InternetOpenURL(hSession, PChar(FileURL),nil,0,INTERNET_FLAG_RELOAD, 0);
    dwIndex := 0;
    dwBufferLen := 20;
    if HttpQueryInfo(hFile, HTTP_QUERY_CONTENT_LENGTH, @dwBuffer[0], dwBufferLen, dwIndex)
      then Result := str2int(dwBuffer);
    if Assigned(hFile) then InternetCloseHandle(hFile);
    InternetCloseHandle(hsession);
   end;
end;

function THIHTTP_Get.Execute;
var
  NetHandle: HINTERNET;
  UrlHandle: HINTERNET;
  ConHandle: HINTERNET;

  Buffer: array[0..1024] of char;
  BytesRead, len: cardinal;
  Url,Fname,Head:string;
  PI:TInternetProxyInfo;
  dwStatus,dwStatusSize:cardinal;
  dwNil:DWORD;
  dt:TData; s,s1:string;
  i:integer;
begin
   FBusy := true; dtNull(dt);
   NetHandle := InternetOpen(_prop_UserAgent, INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
   s := ReadString(dt, _data_Proxy, _prop_Proxy);
   if s<>'' then begin
     PI.dwAccessType := INTERNET_OPEN_TYPE_PROXY;
     PI.lpszProxy := PChar(s);
     PI.lpszProxyByPass := nil;
     InternetSetOption(NetHandle,INTERNET_OPTION_PROXY,@PI,sizeof(PI));
   end;
   FStop := false;
   if Assigned(NetHandle) then
    begin
     Url := ReadString(GData,_data_URL,_prop_URL);

     BytesRead := ReadInteger(GData,_data_Position,0);
     len := ReadInteger(GData,_data_Length,_prop_Length);
     if BytesRead > 0 then
       Head := 'Range: bytes=' + Int2Str(BytesRead) + '-' + Int2Str(BytesRead + Len) 
     else Head := '';

     if _prop_Method = 1 then
       begin
         if pos('https', Url) > 0 then
           begin
             dwStatus := INTERNET_DEFAULT_HTTPS_PORT;
             dwStatusSize := INTERNET_FLAG_SECURE;
           end 
         else
           begin
             dwStatus := INTERNET_DEFAULT_HTTP_PORT;
             dwStatusSize := 0;
           end;
         i := pos('//', Url);
         if i <> -1 then
           delete(url, 1, i + 1);
         i := pos('/', Url);
         if i = -1 then
           begin
             s := url;
             s1 := '';
           end
         else
           begin
             s := copy(url, 1, i-1);
             s1 := copy(url, i+1, length(url));
           end;
         ConHandle := InternetConnect(NetHandle,PChar(s),dwStatus,nil,nil,INTERNET_SERVICE_HTTP, 0, 0);
         UrlHandle := HttpOpenRequest(ConHandle,'POST',PChar(s1),nil,nil,0,INTERNET_FLAG_KEEP_CONNECTION or dwStatusSize,0);
         s := 'Content-Type: application/x-www-form-urlencoded';  
         s1 := ReadString(GData, _data_PostData);
         HttpSendRequest(UrlHandle, PChar(s), length(s), PAnsiChar(s1), Length(s1));
       end
     else
        UrlHandle := InternetOpenUrl(NetHandle, PChar(Url), PChar(Head), cardinal(-1), INTERNET_FLAG_RELOAD+INTERNET_FLAG_NO_AUTH, 0);

     if Assigned(UrlHandle) then
      begin
       dwStatusSize := sizeof(dwStatus);
       dwNil := 0;
       HttpQueryInfo(UrlHandle, HTTP_QUERY_FLAG_NUMBER or
         HTTP_QUERY_STATUS_CODE, @dwStatus, dwStatusSize, dwNil);
       if dwStatus=HTTP_STATUS_PROXY_AUTH_REQ then begin
         s := ReadString(dt, _data_ProxyUsername, _prop_ProxyUsername);
         s1 := ReadString(dt, _data_ProxyPassword, _prop_ProxyPassword);
         if (s<>'') and (s1<>'') then begin
           repeat InternetReadFile(UrlHandle, @Buffer, SizeOf(Buffer), BytesRead); until BytesRead=0;
           HttpSendRequest(UrlHandle,PAnsiChar('Proxy-Authorization: Basic '+Base64_Code(s+':'+s1)+#13#10),DWORD(-1),nil,0);
         end;
       end;
       
       FillChar(Buffer, SizeOf(Buffer), 0);
       FSize := 0;
       Fname := ReadString(GData,_data_FileName,_prop_FileName);
       if Fname = '' then fs := NewMemoryStream
       else fs := NewWriteFileStream(Fname);
       repeat
        FillChar(Buffer, SizeOf(Buffer), 0);
        InternetReadFile(UrlHandle, @Buffer, SizeOf(Buffer), BytesRead);
        fs.Write(Buffer,BytesRead);
        inc(FSize,BytesRead);
        if _prop_Wait then
         ShowInfo
        else th.Synchronize( ShowInfo );
        //ProcessMessages;
       until (BytesRead = 0)or FStop;
       InternetCloseHandle(UrlHandle);
       InternetCloseHandle(NetHandle);
       
       if Fname = '' then
         fs.Position := 0
       else
        begin
          fs.Free;
          fs := nil;
        end;
       if _prop_Wait then
        OnDownload
       else th.Synchronize( OnDownload );
      end
     else ;//MessageBox(0,'Can''t open URL!','Error',MB_OK);
     InternetCloseHandle(NetHandle);
    end
   else ;//MessageBox(0,'I can not connect to Internet!','Error',MB_OK);
   Result := 0;
   //th.Free;
   FBusy := false;
   if _prop_Wait then
     EndDownload
   else th.Synchronize( EndDownload );
end;

procedure THIHTTP_Get.ShowInfo;
begin
   _hi_OnEvent(_event_onStatus,integer(fsize));
end;

procedure THIHTTP_Get.EndDownload;
begin
   _hi_OnEvent(_event_onStop);
end;

procedure THIHTTP_Get.OnDownload;
begin
  if fs = nil then
     _hi_OnEvent(_event_onDownload)
  else
   begin
     _hi_OnEvent(_event_onDownload,fs);
     fs.Free;
   end;
end;

procedure THIHTTP_Get._work_doDownload;
begin
   GData := _Data;
   //if th <> nil then
   //  th.Free;
   if _prop_Wait then
    Execute(nil)
   else
    begin
     {$ifdef F_P}
     th := NewThreadForFPC;
     {$else}
     th := NewThread;
     {$endif}
     th.OnExecute := Execute;
     th.AutoFree := true;
     th.Resume;
    end;
end;

procedure THIHTTP_Get._work_doStop;
begin
   FStop := true;
   //_debug('1');
   //th.WaitFor;
   //_debug('2');
   //th.Free;
   //th := nil;
end;

procedure THIHTTP_Get._var_Busy;
begin
   dtInteger(_data,byte(FBusy));
end;

procedure THIHTTP_Get._work_GetURLSize;
var
   Url:string;
begin
   Url := ReadString(_Data,_data_URL,_prop_URL);
   _hi_OnEvent(_event_onURLSize,integer(GetUrlInfo(URL, _prop_UserAgent)));
end;

end.
