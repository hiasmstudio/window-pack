unit JabberClient;

interface

uses Windows, TCP_Client, BNFXMLParser, MD5, CryptoAPI;

type
    TChallengeRec = record
      nonce:string;
      qop:string;
      charset:string;
      algorithm:string;
    end;

    TRosterSub = (RS_NONE, RS_TO, RS_FROM, RS_BOTH, RS_REMOVE);
    TRosterItem = record
      Name:string;
      jid:string;
      subscription:TRosterSub;
    end;
    TRosterList = array of TRosterItem;

    TJabberClient = class;
    TOnXMLTrace = procedure (client:TJabberClient; const xml:string; direction:boolean) of object;
    TOnJabberNotify = procedure (client:TJabberClient) of object;
    TOnJabberAuth = procedure (client:TJabberClient; success:boolean) of object;
    TOnJabberRosterList = procedure (client:TJabberClient; const from:string; const list:TRosterList) of object;
    TOnJabberMessage = procedure (client:TJabberClient; const from, me, text:string) of object;
    TOnJabberSubscribe = procedure (client:TJabberClient; const from, stype:string) of object;
    TOnJabberStatus = procedure (client:TJabberClient; const from, status:string) of object;

    TJabberClient = class
      private
        sock:TTCP_Client;
        ConID:string;
        FHost:string;
        FUser:string;
        FPass:string;
        FResource:string;
        ReadBuffer:string;
        FThread:THandle;

        FDigest:boolean;
        FDigestMD5:boolean;
        FPlain:boolean;
        FFeatures:boolean;
        Fcnonce:string;

        procedure request_auth_methods;
        procedure begin_wait;
        procedure end_wait;
        procedure auth_digest;
        procedure auth_digest_md5(step:byte; const response:string = '');
        procedure auth_plain;
        procedure bind_resource;
        procedure begin_session;
        procedure _welcome;
        procedure stream_features(node:TXMLNode);
        procedure parse_roster(node:TXMLNode);

        procedure decode_challenge(const ch:string; var clrec:TChallengeRec);
        function gen_adm_response(const nonce, cnonce:string):string;

        procedure _OnRead(Socket:TTCP_Client; buf:pointer; len:cardinal);
        procedure _OnDisconnect(Socket:TTCP_Client);
        procedure _OnConnect(Socket:TTCP_Client);

        procedure send_trace(const xml:string);
        procedure Trace(const xml:string; direction:boolean);
      public
        RosterList:TRosterList;

        OnXMLTrace:TOnXMLTrace;
        OnWelcome:TOnJabberNotify;
        OnAuth:TOnJabberAuth;
        OnRosterList:TOnJabberRosterList;
        OnMessage:TOnJabberMessage;
        OnSubscribe:TOnJabberSubscribe;
        OnConnect:TOnJabberNotify;
        OnStatus:TOnJabberStatus;

        constructor Create;
        destructor Destroy; override;

        function connect(const host:string; port:integer):integer;
        procedure disconnect;
        procedure welcome(const host:string);
        procedure auth(const user, password, resource:string);
        procedure roster;
        procedure send_msg(const user, text:string);
        procedure status(const value, info:string);

        procedure subscribe(const jid:string);
        procedure subscribed(const jid:string);
        procedure unsubscribe(const jid:string);
        procedure unsubscribed(const jid:string);
        
        procedure remove(const jid:string);
    end;

implementation

uses hiCharset;

function StrLCopy(Dest: PChar; const Source: PChar; MaxLen: Cardinal): PChar; assembler;
asm
        PUSH    EDI
        PUSH    ESI
        PUSH    EBX
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EBX,ECX
        XOR     AL,AL
        TEST    ECX,ECX
        JZ      @@1
        REPNE   SCASB
        JNE     @@1
        INC     ECX
@@1:    SUB     EBX,ECX
        MOV     EDI,ESI
        MOV     ESI,EDX
        MOV     EDX,EDI
        MOV     ECX,EBX
        SHR     ECX,2
        REP     MOVSD
        MOV     ECX,EBX
        AND     ECX,3
        REP     MOVSB
        STOSB
        MOV     EAX,EDX
        POP     EBX
        POP     ESI
        POP     EDI
end;

function toLower(const text:string):string;
var i:integer;
begin
  result := text;
  for i := 1 to Length(text) do
    if text[i] in ['A'..'Z'] then
      Result[i] := chr(ord(Result[i]) - ord('A') + ord('a'));
end;

constructor TJabberClient.Create;
begin
  inherited;
  sock := TTCP_Client.Create;
  sock.OnRead := _OnRead;
  sock.OnDisconnect := _OnDisconnect;
  sock.OnConnect := _OnConnect;
end;

destructor TJabberClient.Destroy;
begin
  sock.Destroy;
  inherited;
end;

procedure TJabberClient.Trace(const xml:string; direction:boolean);
begin
    if Assigned(OnXMLTrace) then
        OnXMLTrace(self, xml, direction);
end;

procedure TJabberClient.send_trace(const xml:string);
begin
  Trace(xml, true);
  sock.send(xml);
end;

function TJabberClient.connect(const host:string; port:integer):integer;
begin
  ConID := '';
  Result := sock.open(host, port);
end;

procedure TJabberClient.disconnect;
begin
  sock.close;
end;

procedure TJabberClient.welcome(const host:string);
begin
  FDigest := false;
  FDigestMD5 := false;
  FPlain := false;
  FFeatures := false;
  Fcnonce := '';
  FHost := host;
  ConID := '';

  _welcome;
end;

procedure TJabberClient.request_auth_methods;
var xml:string;
begin
  xml := '<iq type="get" to="' + FHost + '" id="authm">' +
         '<query xmlns="jabber:iq:auth">' +
         '<username>' + FUser + '</username>' +
         '</query>' +
         '</iq>';

  Trace(xml, true);
  sock.send(xml);
end;

procedure TJabberClient.auth(const user, password, resource:string);
begin
  FUser := user;
  FPass := password;
  FResource := resource;

  if FFeatures then
    begin
      if FDigestMD5 then
         auth_digest_md5(0)
      else
         auth_plain
    end
  else
    request_auth_methods;
end;

procedure TJabberClient.auth_digest;
var xml,pass:string;
begin
  HashStr(HASH_SHA1, ConID + FPass, pass);
  xml := '<iq type="set" to="' + FHost + '" id="auth">'+
         '<query xmlns="jabber:iq:auth">'+
         '<username>' + FUser + '</username>'+
         '<digest>' + pass + '</digest>'+
         '<resource>' + FResource + '</resource>'+
         '</query>'+
         '</iq>';
  Trace(xml, true);
  sock.send(xml);
end;

procedure TJabberClient.auth_digest_md5(step:byte; const response:string = '');
var
    clrec:TChallengeRec;
    answer:string;
begin
   case step of
     0: send_trace('<auth xmlns="urn:ietf:params:xml:ns:xmpp-sasl" mechanism="DIGEST-MD5"/>');
     1:
        if Fcnonce = '' then
          begin
             Fcnonce := toLower(MD5DigestToStr(MD5String('todo')));
             decode_challenge(response, clrec);
             answer := 'username="' + FUser + '",realm="' + FHost + '",nonce="' + clrec.nonce + '",' +
                       'cnonce="' + Fcnonce + '",' +
                       'nc=00000001,qop=auth,digest-uri="xmpp/' + FHost + '",charset=utf-8,' +
                       'response=' + gen_adm_response(clrec.nonce, Fcnonce);
             send_trace('<response xmlns="urn:ietf:params:xml:ns:xmpp-sasl">' + Base64_Code(answer) + '</response>');
          end
        else
          begin
             send_trace('<response xmlns="urn:ietf:params:xml:ns:xmpp-sasl"/>');

          end;
     2:
        begin
          _welcome;
        end;
   end;
end;

procedure TJabberClient.auth_plain;
var xml:string;
begin
  xml := '<iq type="set">' +
         '<query xmlns="jabber:iq:auth">' +
         '<username>' + FUser + '</username><password>' + FPass + '</password><resource>' + FResource + '</resource>' +
         '</query>' +
         '</iq>';
  send_trace(xml);
end;

procedure TJabberClient.bind_resource;
var xml:string;
begin
  xml := '<iq type="set" id="bind"><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind">' +
         '<resource>' + FResource + '</resource>' +
         '</bind></iq>';
  send_trace(xml);
end;

procedure TJabberClient.begin_session;
begin
  send_trace('<iq type="set" id="ssid"><session xmlns="urn:ietf:params:xml:ns:xmpp-session"/></iq>');
end;

procedure TJabberClient._welcome;
var xml:string;
begin
  xml := '<?xml version="1.0" encoding="UTF-8"?>' +
         '<stream:stream to="' + FHost + '" xmlns="jabber:client"' +
         ' xmlns:stream="http://etherx.jabber.org/streams" xml:lang="en" version="1.0">';

  send_trace(xml);
end;

procedure TJabberClient.stream_features(node:TXMLNode);
var i,j:integer;
    fn:TXMLNode;
begin
   for i := 0 to Length(node.Nodes) - 1 do
    if node.Nodes[i].Name = 'mechanisms' then
      begin
        fn := node.Nodes[i];
        for j := 0 to Length(fn.Nodes) - 1 do
          if fn.Nodes[j].Value = 'PLAIN' then
            FPlain := true
          else if fn.Nodes[j].Value = 'DIGEST-MD5' then
            FDigestMD5 := true;
        FFeatures := true;
      end
    else if node.Nodes[i].Name = 'bind' then
      bind_resource
    else if node.Nodes[i].Name = 'session' then
      begin_session;
end;

procedure TJabberClient.parse_roster(node:TXMLNode);
var i:integer;
begin
    SetLength(RosterList, Length(node.Nodes[0].Nodes));
    for i := 0 to Length(RosterList) - 1 do
     with node.Nodes[0].Nodes[i] do
      begin
        RosterList[i].Name := attr['name'];
        RosterList[i].jid := attr['jid'];
        if attr['subscription'] = 'none' then
          RosterList[i].subscription := RS_NONE
        else if attr['subscription'] = 'to' then
          RosterList[i].subscription := RS_TO
        else if attr['subscription'] = 'from' then
          RosterList[i].subscription := RS_FROM
        else if attr['subscription'] = 'both' then
          RosterList[i].subscription := RS_BOTH
        else if attr['subscription'] = 'remove' then
          RosterList[i].subscription := RS_REMOVE
      end;
    if Assigned(OnRosterList) then
        OnRosterList(self, node.attr['from'], RosterList);
end;

procedure TJabberClient.decode_challenge(const ch:string; var clrec:TChallengeRec);
var s,p,n:string;
    i:integer;
begin
   s := Base64_DeCode(ch) + ',';
   repeat
      i := pos(',', s);
      p := copy(s, 1, i - 1);
      delete(s, 1, i);
      i := pos('=', p);
      n := copy(p, 1, i - 1);
      if n = 'nonce' then
        clrec.nonce := copy(p, i + 2, Length(p) - i - 2)
      else if n = 'qop' then
        clrec.qop := copy(p, i + 2, Length(p) - i - 2)
      else if n = 'charset' then
        clrec.charset := copy(p, i + 1, Length(p) - i)
      else if n = 'algorithm' then
        clrec.algorithm := copy(p, i + 1, Length(p) - i);
   until s = '';
end;

function TJabberClient.gen_adm_response(const nonce, cnonce:string):string;
const
  nc         = '00000001';
  gop        = 'auth';
var
  HA1, HA2:string;
  buf:string;
  md:TMD5Digest;
begin
  // ????????? ?1 ?? ??????? RFC 2831
  //  A1 = { H( { username-value, ":", realm-value, ":", passwd } ),
  //           ":", nonce-value, ":", cnonce-value, ":", authzid-value }
  SetLength(buf, 16);
  md := MD5String(FUser + ':' + FHost + ':' + FPass);
  StrLCopy(PChar(@buf[1]), PChar(@md.v[0]), 16);
  HA1 := toLower(MD5DigestToStr(MD5String(buf + ':' + nonce + ':' + cnonce)));

  // ????????? ?2 ?? ??????? RFC 2831
  //  A2       = { "AUTHENTICATE:", digest-uri-value }
  HA2 := toLower(MD5DigestToStr(MD5String('AUTHENTICATE:xmpp/' + FHost)));

  // ????????? RESPONSE ?? ??????? RFC 2831
  //  HEX( KD ( HEX(H(A1)),
  //                 { nonce-value, ":" nc-value, ":",
  //                   cnonce-value, ":", qop-value, ":", HEX(H(A2)) }))
  Result := toLower(MD5DigestToStr(MD5String(HA1 + ':' + nonce + ':' + nc + ':' + cnonce + ':' + gop + ':' + HA2)));
 end;

procedure TJabberClient.roster();
var xml:string;
begin
  xml := '<iq type="get" id="roster">'+
         '<query xmlns="jabber:iq:roster"/>'+
         '</iq>';

  Trace(xml, true);
  sock.send(xml);
end;

procedure TJabberClient.send_msg(const user, text:string);
var xml:string;
begin
  xml := '<message type="chat" to="' + user + '" id="msg" from="' + FUser + '@' + FHost + '/' + FResource + '">' +
            '<body>' + text + '</body>' +
         '</message>';

  Trace(xml, true);
  sock.send(xml);
end;

procedure TJabberClient.status(const value, info:string);
var xml:string;
begin
  xml := '<presence>';
  xml  := xml + '<show>' + value + '</show>';
  if info <> '' then
    xml  := xml + '<status>' + info + '</status>';
    
  xml  := xml + '<priority>5</priority></presence>';

  send_trace(xml);
end;

procedure TJabberClient.subscribe(const jid:string);
var xml:string;
begin
  xml := '<presence to="' + jid + '" type="subscribe" from="' + FUser + '@' + FHost + '"/>';
  Trace(xml, true);
  sock.send(xml);
end;

procedure TJabberClient.subscribed(const jid:string);
var xml:string;
begin
  xml := '<presence to="' + jid + '" type="subscribed"/>';
  Trace(xml, true);
  sock.send(xml);
end;

procedure TJabberClient.unsubscribe(const jid:string);
var xml:string;
begin
  xml := '<presence to="' + jid + '" type="unsubscribe"/>';
  Trace(xml, true);
  sock.send(xml);
end;

procedure TJabberClient.unsubscribed(const jid:string);
var xml:string;
begin
  xml := '<presence to="' + jid + '" type="unsubscribed"/>';
  Trace(xml, true);
  sock.send(xml);
end;

procedure TJabberClient.remove(const jid:string);
var xml:string;
begin
  xml := '<iq type="set" id="remove"><query xmlns="jabber:iq:roster">' +
         '<item subscription="remove" jid="' + jid + '"/>' +
         '</query></iq>';
  Trace(xml, true);
  sock.send(xml);
end;

function wait_proc(client:pointer):Integer; stdcall;
begin
  sleep(100);
  TJabberClient(client).end_wait;
  Result := 0;
end;

procedure TJabberClient.begin_wait;
var id:Cardinal;
begin
  if FThread > 0 then
    CloseHandle(FThread);
  FThread := CreateThread(nil, 0, @wait_proc, self, 0, id);
end;

procedure TJabberClient.end_wait;
begin
  if Assigned(OnWelcome) then
    OnWelcome(self);
end;

procedure TJabberClient._OnRead(Socket:TTCP_Client; buf:pointer; len:cardinal);
var xml,s:string;
    doc:TXMLDocument;
    node,fn:TXMLNode;
    n,i:integer;
begin
  SetLength(xml, len);
  StrLCopy(PChar(@xml[1]), buf, len);
  Trace(xml, false);

  doc := TXMLDocument.Create;
  ReadBuffer := ReadBuffer + xml;
  if not doc.parse(ReadBuffer) then exit;
  ReadBuffer := '';

  for n := 0 to Length(doc.root.Nodes) - 1 do
    begin
      node := doc.root.Nodes[n];

      if node.Name = 'stream:stream' then
        begin
          if ConID = '' then
            begin
              ConID := node.attr['id'];
              begin_wait;
            end;
          if Length(node.Nodes) > 0 then
             stream_features(node.Nodes[0]);
        end
      else if node.Name = 'stream:features' then
        begin
          stream_features(node);
        end
      else if node.Name = 'challenge' then
        begin
          auth_digest_md5(1, node.Value);
        end
      else if node.Name = 'success' then
        begin
          auth_digest_md5(2);
        end
      else if node.Name = 'iq' then
        begin
          if node.attr['id'] = 'auth' then
            begin
              if Assigned(OnAuth) then
                OnAuth(self, node.attr['type'] = 'result');
            end
          else if node.attr['id'] = 'authm' then
            begin
              auth_digest;
            end
          else if node.attr['id'] = 'bind' then
            begin
              if Assigned(OnAuth) then
                OnAuth(self, true);
            end
          else if node.attr['id'] = 'roster' then
            begin
              parse_roster(node);
            end
          else
            if node.attr['type'] = 'set' then
              begin
                if node.Nodes[0].attr['xmlns'] = 'jabber:iq:roster' then
                   parse_roster(node);
              end;
        end
      else if node.Name = 'message' then
       begin
         if node.attr['type'] = 'chat' then
           begin
              if Assigned(OnMessage) then
                OnMessage(self, node.attr['from'], node.attr['to'], node.node['body'].Value);
           end
       end
      else if node.Name = 'presence' then
       begin
         s := node.attr['type'];
         fn := node.getNodeByName('show');
         if s <> '' then
           begin
              if Assigned(OnSubscribe) then
                OnSubscribe(self, node.attr['from'], s);
           end
         else if fn <> nil then
           begin
             if Assigned(OnStatus) then
                 OnStatus(self, node.attr['from'], fn.value);
           end
         else
           begin
             if Assigned(OnStatus) then
                 OnStatus(self, node.attr['from'], '');
           end;
       end;
    end;
  //<message from='puux@jabber.ru/u-pc' to='dilma@hiasm.com/u-xp' xml:lang='en' type='chat' id='aacfa'>
  // <body>test</body>
  // <active xmlns='http://jabber.org/protocol/chatstates'/>
  //</message>
end;

procedure TJabberClient._OnDisconnect(Socket:TTCP_Client);
begin

end;

procedure TJabberClient._OnConnect(Socket:TTCP_Client);
begin
  if Assigned(OnConnect) then
    OnConnect(self);
end;

end.
