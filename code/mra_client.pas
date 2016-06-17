// author - BOBAH13
// sendSMS, search and some other - yXo
// http://yxu.org.ru
// Для того, чтобы не каждый ламер сунул компанент тупо на форму и
// сделал спамилку, вам придется почитать протокол :) 

unit mra_client;

interface

uses
 Share, Windows, Messages, WinSock, mra_proto, mra_pworks, kol;

const
 TIMER_MASK = $000000FF;
 TIMER_ID_MASK = $0000FF00;
 
 TIMER_PING = $00000001;
 TIMER_PRINT = $00000002;
 
type
 TErrorClient = (NotError, NotCreateSocket, NotConnect, NULLData,
  NotRequestData);
 TStatusClient = (OffLine, OnLine, Away, Invisible);
 TInvisStateClient = (clNormal, clInvisible, clVisible, clIgnore);
 
const
 DWORD_InvisList: array[TInvisStateClient] of DWORD = (
  0, CONTACT_FLAG_INVISIBLE, CONTACT_FLAG_VISIBLE, CONTACT_FLAG_IGNORE
  );
 DWORD_Status: array[TStatusClient] of DWORD = (
  STATUS_OFFLINE, STATUS_ONLINE, STATUS_AWAY,
  STATUS_UNDETERMINATED or STATUS_FLAG_INVISIBLE
  );
 
type
 TNotifyEvent = procedure(Sender: TObject) of object; 
 TOnReasonLPSEvent = procedure(Sender: TObject; Reason: string) of object;
 TOnReasonULEvent = procedure(Sender: TObject; Reason: DWORD) of object;
 TOnReasonULIDEvent = procedure(Sender: TObject; Reason, MsgID: DWORD; EMail:
  string) of object;
 TOnMessageEvent = procedure(Sender: TObject; MsgID: DWORD; From, Text: string)
  of object;
 TOnRTFMessageEvent = procedure(Sender: TObject; MsgID: DWORD; From, Text:
  string;
  IsRTF: Boolean) of object;
 TOnContactGroup = procedure(Sender: TObject; GroupID: DWORD; Text: string) of
  object;
 TOnContact = procedure(Sender: TObject; GroupID: DWORD; EMail, Nick: string;
  Status: TStatusClient; InvisState: TInvisStateClient) of object;
 TOnAddContact = procedure(Sender: TObject; GroupID, UserID: DWORD; EMail, Nick:
  string) of object;
 TOnAddContactError = procedure(Sender: TObject; GroupID, UserID: DWORD;
  EMail, Nick: string; Reason: DWORD) of object;
 TOnAddContactGroup = procedure(Sender: TObject; GroupID: DWORD; Text: string) of
  object;
 TOnAddContactGroupError = procedure(Sender: TObject; GroupID: DWORD; Text:
  string;
  Reason: DWORD) of object;
 TOnStatusChange = procedure(Sender: TObject; EMail: string; Status:
  TStatusClient) of object;
 TOnKeyRead = procedure(Sender: TObject; Key, Value: string) of object;
 //yxo
 TOnMailBoxStatusNew = procedure(Sender: TObject; MsgNum: DWORD; MailSender,
  Subject: string; TimeStamp: DWORD) of object;
 TOnUserFound = procedure(Sender: TObject; Status, FieldNum, MaxRows,
  ServerTime: DWORD; User, Domain, Nickname, FistName, LastName,
  Sex, Birth_Day, IDCity, Location, Zodiac, BirthMonth, BirthDay, IDCountry,
   Phone, mrim_Status: string) of object;
 
 TItemID = packed record
  MsgID: DWORD;
  EMail: string;
 end;
 
 TIDManager = class
 private
  FItems: array of TItemID;
 public
  destructor Destroy; override;
  function GetID(MsgID: DWORD): Integer;
  function Push(EMail: string; MsgID: Integer): Integer;
  function Pop(ID: Integer): TItemID;
  function Check: Boolean;
 end;
 
 TItemContact = packed record
  Flag: DWORD;
  GroupID: DWORD;
  EMail: string;
  Nick: string;
 end;
 
 TContactManager = class
 private
  FItems: array of TItemContact;
 public
  destructor Destroy; override;
  procedure Push(EMail, Nick: string; GroupID: Integer; Flag: DWORD);
  function Pop: TItemContact;
  function Check: Boolean;
 end;
 
 TPrintItem = packed record
  Free: Boolean;
  MsgID: DWORD;
  EMail: string;
 end;
 
 TPrintManager = class
 private
  FItems: array of TPrintItem;
 public
  destructor Destroy; override;
  function GetID(EMail: string): Integer;
  function Push(EMail: string; MsgID: Integer): Integer;
  function Pop(ID: Integer): TPrintItem;
  function Check: Boolean;
 end;
 
 TClientSocket = class
 private
  FThread:PThread;
  FSocket: TSocket;
  FHost: string;
  FPort: WORD;
  FIP: string;
  FStop:boolean;
  FLastError: TErrorClient;
  FOnDisconnect: TNotifyEvent;
  FOnConnect: TNotifyEvent;
  FOnRead: TNotifyEvent;
  FOnError: TNotifyEvent;
 protected
  procedure DoConnect;
  procedure DoDisconnect;
  procedure DoRead;
  procedure DoError;
 public
  constructor Create;
  destructor Destroy; override;
  function Execute(Sender:PThread): Integer;

  procedure Terminate;
  procedure Resume;           

  function Connected: Boolean;
  property LastError: TErrorClient read FLastError;
  property Host: string read FHost write FHost;
  property Port: WORD read FPort write FPort;
  property Socket: TSocket read FSocket;
  property IP: string read FIP;
  property OnError: TNotifyEvent read FOnError write FOnError;
  property OnConnect: TNotifyEvent read FOnConnect write FOnConnect;
  property OnDisconnect: TNotifyEvent read FOnDisconnect write FOnDisconnect;
  property OnRead: TNotifyEvent read FOnRead write FOnRead;
 end;
 
 TMailClient = class
 private
  FCList:PStrList;
  FWND: HWND;
  FHost: string;
  FPort: WORD;
  FHostInit: Boolean;
  FMRIMHost: string;
  FMRIMPort: WORD;
  FMail: string;
  FPrintInterval: Integer;
  FPassWord: string;
  FCaption: string;
  FSendMessageRecvOk: Boolean;
  FLastError: TErrorClient;
  FSeq: DWORD;
  FContactManager: TContactManager;
  FCheckContactManager: TContactManager;
  FPrintManager: TPrintManager;
  FMessageManager: TIDManager;
  FStatus: TStatusClient;
  FPingPeriod: DWORD;
  FSocket: TClientSocket;
  FOnError: TNotifyEvent;
  FOnConnect: TNotifyEvent;
  FOnDisconnect: TNotifyEvent;
  FOnHello: TNotifyEvent;
  FOnRequestHost: TNotifyEvent;
  FOnErrorRequestHost: TNotifyEvent;
  FOnRecievedHost: TNotifyEvent;
  FOnSuccesAuthorize: TNotifyEvent;
  FOnErrorAuthorize: TOnReasonLPSEvent;
  FOnMessageSended: TOnReasonULIDEvent;
  FOnLogOut: TOnReasonULEvent;
  FOnPing: TNotifyEvent;
  FOnMailBoxStatus: TOnReasonULEvent;
  FOnMessage: TOnRTFMessageEvent;
  FOnContactBeginPrint: TOnMessageEvent;
  FOnContactEndPrint: TOnMessageEvent;
  FOnContactAuthorize: TOnMessageEvent;
  FOnSystemMessage: TOnMessageEvent;
  FOnOfflineMessage: TOnMessageEvent;
  FOnConnection: TNotifyEvent;
  FOnContactGroup: TOnContactGroup;
  FOnContact: TOnContact;
  FOnAddContact: TOnAddContact;
  FOnAddContactError: TOnAddContactError;
  FOnAddContactGroup: TOnAddContactGroup;
  FOnAddContactGroupError: TOnAddContactGroupError;
  FOnModifyContact: TOnAddContact;
  FOnModifyContactError: TOnAddContactError;
  FOnModifyContactGroup: TOnAddContactGroup;
  FOnModifyContactGroupError: TOnAddContactGroupError;
  FOnStatusChange: TOnStatusChange;
  FOnStartRequestContactList: TNotifyEvent;
  FOnEndRequestContactList: TNotifyEvent;
  FOnKeyRead: TOnKeyRead;

  //yxo
  FOnMailBoxStatusNew: TOnMailBoxStatusNew;
  FOnUserFound: TOnUserFound;
  procedure SetStatus(Value: TStatusClient);
  function GetSocket: TSocket;
 protected
  procedure DoRequestHost(Sender: TObject);
  procedure DoRequestError(Sender: TObject);
  procedure DoRead(Sender: TObject);
  procedure DoError(Sender: TObject);
  procedure DoDisconnect(Sender: TObject);
  procedure WndProc(var Message: TMessage);
  function DStatusTo(Status: DWORD): TStatusClient;
  function DInvisStateTo(State: DWORD): TInvisStateClient;
 public
  constructor Create;
  destructor Destroy; override;

  procedure Connect;
  procedure Disconnect;
  function Connected: Boolean;

  procedure RequestHost;
  procedure Hello;
  procedure Authorize(const status:string);
  procedure Ping;
  procedure SendMessageRecv(From: string; MsgID: DWORD);
  procedure SendMessage(EMail, Text: string);
  procedure SendPrintMe(EMail: string);
  procedure SendSMS(Phone, Text: string);
  procedure ContactAuthorize(EMail: string);
  procedure AuthorizeMe(EMail, Text: string);
  procedure AddGroup(GroupName: string; GroupCount: Integer);
  procedure DeleteGroup(GroupName: string; GroupID, GroupCount: Integer);
  procedure AddContact(EMail, Nick: string; GroupID: Integer);
  procedure DeleteContact(EMail, Nick: string; ID, GroupID: Integer);
  procedure ChangeContact(EMail, Nick: string; ID, GroupID: Integer);
  procedure MoveContact(EMail, Nick: string; ID, GroupID: Integer);
  procedure FindContact(EMail: string; AlwaysOnLine: Boolean = False); overload;
  procedure FindContact(Nick, Name, LastName: string; Sex, MinAge, MaxAge,
   IDCity, Zodiac, Month, Day, IDCountry: Integer;
   AlwaysOnLine: Boolean = False); overload;

  property Sequence: DWORD read FSeq;
  property HostInit: Boolean read FHostInit;
  property PingPeriod: DWORD read FPingPeriod;
  property Socket: TSocket read GetSocket;
  property WNDHandel: HWND read FWND;
  property LastError: TErrorClient read FLastError;
  property Status: TStatusClient read FStatus write SetStatus;
 published
  property Host: string read FHost write FHost;
  property Port: WORD read FPort write FPort;
  property MRIMHost: string read FMRIMHost write FMRIMHost;
  property MRIMPort: WORD read FMRIMPort write FMRIMPort;
  property Caption: string read FCaption write FCaption;
  property Mail: string read FMail write FMail;
  property PassWord: string read FPassWord write FPassWord;
  property PrintInterval: Integer read FPrintInterval write FPrintInterval;
  property SendMessageRecvOk: Boolean read FSendMessageRecvOk write
   FSendMessageRecvOk;

  property OnError: TNotifyEvent read FOnError write FOnError;
  property OnConnection: TNotifyEvent read FOnConnection write FOnConnection;
  property OnConnect: TNotifyEvent read FOnConnect write FOnConnect;
  property OnDisconnect: TNotifyEvent read FOnDisconnect write FOnDisconnect;
  property OnHello: TNotifyEvent read FOnHello write FOnHello;
  property OnErrorAuthorize: TOnReasonLPSEvent read FOnErrorAuthorize write
   FOnErrorAuthorize;
  property OnSuccesAuthorize: TNotifyEvent read FOnSuccesAuthorize write
   FOnSuccesAuthorize;
  property OnPing: TNotifyEvent read FOnPing write FOnPing;
  property OnLogOut: TOnReasonULEvent read FOnLogOut write FOnLogOut;
  property OnRequestHost: TNotifyEvent read FOnRequestHost write FOnRequestHost;
  property OnErrorRequestHost: TNotifyEvent read FOnErrorRequestHost write
   FOnErrorRequestHost;
  property OnRecievedHost: TNotifyEvent read FOnRecievedHost write
   FOnRecievedHost;
  property OnMailBoxStatus: TOnReasonULEvent read FOnMailBoxStatus write
   FOnMailBoxStatus;
  property OnMailBoxStatusNew: TOnMailBoxStatusNew read FOnMailBoxStatusNew write
   FOnMailBoxStatusNew;
  property OnUserFound: TOnUserFound read FOnUserFound write FOnUserFound;
  property OnMessage: TOnRTFMessageEvent read FOnMessage write FOnMessage;
  property OnContactAuthorize: TOnMessageEvent read FOnContactAuthorize write
   FOnContactAuthorize;
  property OnSystemMessage: TOnMessageEvent read FOnSystemMessage write
   FOnSystemMessage;
  property OnOfflineMessage: TOnMessageEvent read FOnOfflineMessage write
   FOnOfflineMessage;
  property OnContactBeginPrint: TOnMessageEvent read FOnContactBeginPrint write
   FOnContactBeginPrint;
  property OnContactEndPrint: TOnMessageEvent read FOnContactEndPrint write
   FOnContactEndPrint;
  property OnMessageSended: TOnReasonULIDEvent read FOnMessageSended write
   FOnMessageSended;
  property OnContactGroup: TOnContactGroup read FOnContactGroup write
   FOnContactGroup;
  property OnContact: TOnContact read FOnContact write FOnContact;
  property OnAddContact: TOnAddContact read FOnAddContact write FOnAddContact;
  property OnAddContactError: TOnAddContactError read FOnAddContactError write
   FOnAddContactError;
  property OnAddContactGroup: TOnAddContactGroup read FOnAddContactGroup write
   FOnAddContactGroup;
  property OnAddContactGroupError: TOnAddContactGroupError read
   FOnAddContactGroupError write FOnAddContactGroupError;
  property OnModifyContact: TOnAddContact read FOnModifyContact write
   FOnModifyContact;
  property OnModifyContactError: TOnAddContactError read FOnModifyContactError
   write FOnModifyContactError;
  property OnModifyContactGroup: TOnAddContactGroup read FOnModifyContactGroup
   write FOnModifyContactGroup;
  property OnModifyContactGroupError: TOnAddContactGroupError read
   FOnModifyContactGroupError write FOnModifyContactGroupError;
  property OnStatusChange: TOnStatusChange read FOnStatusChange write
   FOnStatusChange;
  property OnStartRequestContactList: TNotifyEvent read
   FOnStartRequestContactList write FOnStartRequestContactList;
  property OnEndRequestContactList: TNotifyEvent read FOnEndRequestContactList
   write FOnEndRequestContactList;
  property OnKeyRead: TOnKeyRead read FOnKeyRead write FOnKeyRead;
 end;
 
implementation

var
 WSData: WSAData;
 
{ TContactManager }

destructor TContactManager.Destroy;
begin
 SetLength(FItems, 0);
 inherited;
end;

function TContactManager.Check;
begin
 Result:= Length(FItems) > 0;
end;

procedure TContactManager.Push;
var
 i: Integer;
begin
 i:= Length(FItems);
 SetLength(FItems, i + 1);
 FItems[i].GroupID:= GroupID;
 FItems[i].EMail:= EMail;
 FItems[i].Nick:= Nick;
 FItems[i].Flag:= Flag;
end;

function TContactManager.Pop;
var
 i: Integer;
begin
 if not Check then
  Exit;
 Result:= FItems[0];
 for i:= 0 to Length(FItems) - 2 do
  FItems[i]:= FItems[i + 1];
 SetLength(FItems, Length(FItems) - 1);
end;

{ TIDManager }

destructor TIDManager.Destroy;
begin
 SetLength(FItems, 0);
 inherited;
end;

function TIDManager.Check;
begin
 Result:= Length(FItems) > 0;
end;

function TIDManager.GetID;
var
 i: Integer;
begin
 Result:= -1;
 for i:= 0 to Length(FItems) - 1 do
  if FItems[i].MsgID = MsgID then
  begin
   Result:= i;
   Break;
  end;
end;

function TIDManager.Push;
var
 n: Integer;
begin
 n:= Length(FItems);
 SetLength(FItems, n + 1);
 FItems[n].MsgID:= MsgID;
 FItems[n].EMail:= EMail;
 Result:= n;
end;

function TIDManager.Pop;
var
 i: Integer;
begin
 if (ID >= 0) and (ID < Length(FItems)) then
 begin
  Result:= FItems[ID];
  for i:= ID to Length(FItems) - 2 do
   FItems[i]:= FItems[i + 1];
  SetLength(FItems, Length(FItems) - 1);
 end;
end;

{ TPrintContactManager }

destructor TPrintManager.Destroy;
begin
 SetLength(FItems, 0);
 inherited;
end;

function TPrintManager.Check;
begin
 Result:= Length(FItems) > 0;
end;

function TPrintManager.GetID;
var
 i: Integer;
begin
 Result:= -1;
 for i:= 0 to Length(FItems) - 1 do
  if StrIComp(PChar(FItems[i].EMail), PChar(EMail)) = 0 then
  begin
   Result:= i;
   Break;
  end;
end;

function TPrintManager.Push;
var
 i, n: Integer;
begin
 Result:= -1;
 if GetID(EMail) >= 0 then
  Exit;
 n:= -1;
 for i:= 0 to Length(FItems) - 1 do
  if FItems[i].Free then
  begin
   n:= i;
   Break;
  end;
 if n = -1 then
 begin
  n:= Length(FItems);
  SetLength(FItems, n + 1);
 end;
 FItems[n].MsgID:= MsgID;
 FItems[n].EMail:= EMail;
 FItems[n].Free:= False;
 Result:= n;
end;

function TPrintManager.Pop;
begin
 if (ID >= 0) and (ID < Length(FItems)) then
 begin
  Result:= FItems[ID];
  FItems[ID].Free:= True;
  FItems[ID].EMail:= '';
  FItems[ID].MsgID:= 0;
 end;
end;

{ TMailClientSocket }

constructor TClientSocket.Create;
begin
 inherited Create;
 FIP := GetIP;
 FSocket := INVALID_SOCKET;
 FThread := {$ifdef F_P}NewThreadforFPC{$else}NewThread{$endif};
 FThread.OnExecute := Execute;
end;

destructor TClientSocket.Destroy;
begin
 FStop := true;
// FThread.WaitFor;
// FThread.Free;
 inherited Destroy;
end;

procedure TClientSocket.Terminate;
begin
   FStop := true;
   closesocket(FSocket);
   FSocket:= INVALID_SOCKET;
   FThread.Terminate;
end;

procedure TClientSocket.Resume;
begin
   FThread.Resume;
end;

function TClientSocket.Execute;
var
 addr: sockaddr_in;
 FDSet: TFDSet;
 TimeVal: TTimeVal;
 Len: Integer;
begin
 FLastError:= NotError;
 
 FStop := false;
 FSocket:= winsock.socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
 if FSocket = INVALID_SOCKET then
 begin
  FLastError:= NotCreateSocket;
  Sender.Synchronize(DoError);
  Free;
  Exit;
 end;
 
 ZeroMemory(@addr, SizeOf(sockaddr_in));
 addr.sin_family:= AF_INET;
 addr.sin_port:= htons(FPort);
 addr.sin_addr.S_addr:= inet_addr(PCHAR(FHost));
 if winsock.connect(FSocket, addr, SIZEOF(sockaddr_in)) = SOCKET_ERROR then
 begin
  closesocket(FSocket);
  FLastError:= NotConnect;
  Sender.Synchronize(DoError);
  Exit;
 end;
 
 Sender.Synchronize(DoConnect);
 
 while not FStop and (FSocket <> INVALID_SOCKET) do
 begin
  FD_ZERO(FDSet);
  FD_SET(FSocket, FDSet);
  TimeVal.tv_sec:= 0;
  TimeVal.tv_usec:= 500;
  if (select(0, @FDSet, nil, nil, @TimeVal) > 0) and not FStop then
  begin
   ioctlsocket(FSocket, FIONREAD, Len);
   if Len = 0 then
    Break
   else
    Sender.Synchronize(DoRead);
  end;
 end;
 closesocket(FSocket);
 FSocket := INVALID_SOCKET;

 Sender.Synchronize(DoDisconnect);
 Result := 0;
end;

procedure TClientSocket.DoConnect;
begin
 if Assigned(FOnConnect) then FOnConnect(Self);
end;

procedure TClientSocket.DoDisconnect;
begin
 if Assigned(FOnDisconnect) then FOnDisconnect(Self);
end;

procedure TClientSocket.DoRead;
begin
 if Assigned(FOnRead) then FOnRead(Self);
end;

procedure TClientSocket.DoError;
begin
 if (FLastError <> NotError) and Assigned(FOnError) then FOnError(Self);
end;

function TClientSocket.Connected;
begin
 Result:= (FSocket <> INVALID_SOCKET);
end;

{ TMailClient }

function MWnd(window:hwnd;message:dword;wparam:WPARAM;lparam:LPARAM):LRESULT;stdcall;
var msg:TMessage;
begin
   msg.msg := message;
   msg.wparam := wparam;
   msg.lparam := lparam;
   if message = WM_TIMER then
    begin 
      TMailClient(GetWindowLong(window, GWL_USERDATA)).WndProc(msg);
      Result := msg.Result;
    end
   else
     Result := DefWindowProc(window, message, wParam, lParam);
end;

function AllocateHWnd(obj:TMailClient):HWND;
var
  utilclass:TWndClass;
begin
   ZeroMemory(@utilclass,sizeof(utilclass));
   utilclass.lpfnWndProc := @MWnd;
   utilclass.lpszClassName := 'TSocket';
   utilclass.hInstance := HInstance;
   RegisterClassA(utilclass);
   Result := CreateWindowEx(WS_EX_TOOLWINDOW,utilclass.lpszclassname,nil,
    WS_POPUP,0,0,0,0,0,0,hinstance,nil);
   SetWindowLong(Result, GWL_USERDATA, cardinal(obj)); 
end;

procedure DeallocateHWnd(handle:HWND);
begin
   Windows.DestroyWindow(handle);
end;

constructor TMailClient.Create;
begin
 inherited;
 FSocket:= nil;
 FPrintInterval:= 10 * 1000;
 FWND:= AllocateHWnd(self);
 FContactManager:= TContactManager.Create;
 FCheckContactManager:= TContactManager.Create;
 FPrintManager:= TPrintManager.Create;
 FMessageManager:= TIDManager.Create;
 FCList := NewStrList;
end;

destructor TMailClient.Destroy;
begin
 Disconnect;
 DeallocateHWnd(FWND);
 FContactManager.Free;
 FCheckContactManager.Free;
 FPrintManager.Free;
 FMessageManager.Free;
 FCList.Free;
 inherited;
end;

function TMailClient.GetSocket;
begin
 if Connected then
  Result:= FSocket.Socket
 else
  Result:= INVALID_SOCKET;
end;

procedure TMailClient.SetStatus;
var
 Pack: TMRIMPacket;
 Data: Pointer;
begin
 if FStatus <> Value then
 begin
  FStatus:= Value;
  case Value of
   OffLine:
    Disconnect;
   OnLine, Away, Invisible:
    if Connected then
     begin
      MMP_Pack(@Pack, FSeq, MRIM_CS_CHANGE_STATUS, FSocket.Port, FSocket.IP);
      MMP_AddUL(@Pack, Data, DWORD_Status[FStatus]);
      MMP_SendPack(FSocket.Socket, @Pack, Data);
      FreeMem(Data);
      FSeq:= FSeq + 1;
     end;
  end;
 end;
end;

function TMailClient.Connected;
begin
 Result:= Assigned(FSocket) and (FSocket.Socket <> INVALID_SOCKET);
end;

procedure TMailClient.WndProc;
var
 PrintContact: TPrintItem;
begin
 with Message do
  case Msg of
   WM_TIMER:
    begin
     case (wParam and TIMER_MASK) of
      TIMER_PING:
       Ping;
      TIMER_PRINT:
       if FPrintManager.Check then
       begin
        PrintContact:= FPrintManager.Pop(wParam and TIMER_ID_MASK);
        KillTimer(FWND, TIMER_PRINT or (wParam and TIMER_ID_MASK));
        if Assigned(FOnContactEndPrint) then
         FOnContactEndPrint(Self, PrintContact.MsgID, PrintContact.EMail, '');
       end;
     end;
     Result:= 0;
    end;
  else
   Result:= DefWindowProc(FWND, Msg, wParam, lParam);
  end;
end;

procedure TMailClient.DoRequestHost(Sender: TObject);
var
 Sock: TClientSocket;
 Data: PCHAR;
 Len: Integer;
begin
 if Sender is TClientSocket then
 begin
  Sock:= TClientSocket(Sender);

  ioctlsocket(Sock.Socket, FIONREAD, Len);
  if Len > 0 then
  begin
   GetMem(Data, Len);
   if (recv(Sock.Socket, Data^, Len, 0) = Len) then
   begin
    FHostInit:= ExtractIPAndPort(Data, FHost, FPort);
    if FHostInit and Assigned(FOnRecievedHost) then
     FOnRecievedHost(Self);
   end
   else
   begin
    FLastError:= NotRequestData;
    if Assigned(FOnError) then
     FOnError(Self);
   end;
   FreeMem(Data);
  end
  else
  begin
   FLastError:= NULLData;
   if Assigned(FOnError) then
    FOnError(Self);
  end;

  Sock.Terminate;
 end;
end;

procedure TMailClient.DoRequestError(Sender: TObject);
var
 Sock: TClientSocket;
begin
 if Sender is TClientSocket then
 begin
  Sock:= TClientSocket(Sender);
  FLastError:= Sock.LastError;
  if Assigned(FOnErrorRequestHost) then
   FOnErrorRequestHost(Self);
 end;
end;

procedure TMailClient.RequestHost;
var
 Sock: TClientSocket;
begin
 Sock:= TClientSocket.Create;
 Sock.FHost:= HostToIP(FMRIMHost);
 Sock.FPort:= FMRIMPort;
 Sock.OnRead:= DoRequestHost;
 Sock.OnError:= DoRequestError;
 Sock.OnDisconnect:= nil;
 if Assigned(FOnRequestHost) then
  FOnRequestHost(Self);
 Sock.Resume;
end;

procedure TMailClient.Connect;
begin
 if not Connected then
 begin
  if Assigned(FOnConnection) then
   FOnConnection(Self);
  FSocket:= TClientSocket.Create;
  FSocket.Host:= FHost;
  FSocket.Port:= FPort;
  FSocket.OnRead:= DoRead;
  FSocket.OnDisconnect:= DoDisconnect;
  FSocket.OnConnect:= OnConnect;
  FSocket.OnError:= DoError;
  FSocket.Resume;
 end;
end;

function TMailClient.DStatusTo;
begin
 if (Status and STATUS_FLAG_INVISIBLE = STATUS_FLAG_INVISIBLE) then
  Result:= Invisible
 else if (Status and STATUS_AWAY = STATUS_AWAY) then
  Result:= Away
 else if (Status and STATUS_ONLINE = STATUS_ONLINE) then
  Result:= OnLine
 else
  Result:= OffLine;
end;

function TMailClient.DInvisStateTo;
begin
 if (State and CONTACT_FLAG_IGNORE = CONTACT_FLAG_IGNORE) then
  Result:= clIgnore
 else if (State and CONTACT_FLAG_VISIBLE = CONTACT_FLAG_VISIBLE) then
  Result:= clVisible
 else if (State and CONTACT_FLAG_INVISIBLE = CONTACT_FLAG_INVISIBLE) then
  Result:= clInvisible
 else
  Result:= clNormal;
end;

procedure TMailClient.DoDisconnect;
begin
 KillTimer(FWND, TIMER_PING);
 FStatus:= Offline;
 if Assigned(FOnDisconnect) then
  FOnDisconnect(Self);
end;

procedure TMailClient.Disconnect;
begin
 if Assigned(FSocket) then
  begin
//    FSocket.Terminate;
    FSocket.Destroy;
    FSocket := nil;
  end;
end;

procedure TMailClient.DoError;
begin
 FStatus:= Offline;
 FLastError:= FSocket.LastError;
 if Assigned(FOnError) then
  FOnError(Self);
end;

procedure TMailClient.DoRead;
var
 Pack: TMRIMPacket;
 Data: Pointer;
 Offset: DWORD;
 ID: DWORD;
 IDContact: Integer;
 i: Integer;
 MsgNum: DWORD;
 
 MMP_Message: packed record
  MsgID: DWORD;
  Flags: DWORD;
  From: string;
  Text: string;
  RTFText: string;
 end;
 MMP_Contacts: packed record
  Status: DWORD;
  GroupCount: DWORD;
  GroupMask: string;
  ContactMask: string;
 end;
 MMP_Group: packed record
  Flag: DWORD;
  Name: string;
 end;
 MMP_Contact: packed record
  Flag: DWORD;
  GroupID: DWORD;
  EMail: string;
  Nick: string;
  ServerFlag: DWORD;
  Status: DWORD;
 end;
 MMP_ContactOK: packed record
  Status: DWORD;
  ID: DWORD;
 end;
 MMP_ContactInfo: packed record
  Key: string;
  Value: string;
 end;
 
 MMP_FindContactInfo: packed record
  Status: DWORD;
  FieldNum: DWORD;
  MaxRows: DWORD;
  ServerTime: DWORD;
  User, Domain, Nickname, FistName, LastName,
   Sex, Birth_Day, IDCity, Location, Zodiac, BirthMonth, BirthDay, IDCountry,
   Phone, mrim_Status: string;
 end;
 
begin
 if MMP_RecvPack(FSocket.Socket, @Pack) <> SizeOf(TMRIMPacket) then
 begin
  FLastError:= NotRequestData;
  if Assigned(FOnError) then
   FOnError(Self);
  Exit;
 end;
 Data:= nil;
 Offset:= 0;
 MMP_RecvData(FSocket.Socket, @Pack, Data);
 case Pack.msg of
  MRIM_CS_HELLO_ACK:
   begin
    FPingPeriod:= MMP_GetUL(@Pack, Data, Offset) * 1000;
    SetTimer(FWND, TIMER_PING, FPingPeriod, nil);
    FStatus := Online;
    if Assigned(FOnHello) then
     FOnHello(Self);
   end;
  MRIM_CS_CONNECTION_PARAMS:
   begin
    KillTimer(FWND, TIMER_PING);
    FPingPeriod:= MMP_GetUL(@Pack, Data, Offset) * 1000;
    SetTimer(FWND, TIMER_PING, FPingPeriod, nil);
   end;
  MRIM_CS_LOGIN_ACK:
   begin
    if Assigned(FOnSuccesAuthorize) then
     FOnSuccesAuthorize(Self);
   end;
  MRIM_CS_LOGIN_REJ:
   begin
    FStatus:= Offline;
    if Assigned(FOnErrorAuthorize) then
     FOnErrorAuthorize(Self, MMP_GetLPS(@Pack, Data, Offset));
   end;
  MRIM_CS_LOGOUT:
   begin
    FStatus:= Offline;
    if Assigned(FOnLogOut) then
     FOnLogOut(Self, MMP_GetUL(@Pack, Data, Offset));
   end;
  MRIM_CS_MAILBOX_STATUS:
   begin
    if Assigned(FOnMailBoxStatus) then
     FOnMailBoxStatus(Self, MMP_GetUL(@Pack, Data, Offset));
   end;
  MRIM_CS_MAILBOX_STATUS_NEW:
   begin
    if Assigned(FOnMailBoxStatusNew) then
    begin
     MsgNum := MMP_GetUL(@Pack, Data, Offset);
     FOnMailBoxStatusNew(Self, MsgNum,
      MMP_GetLPS(@Pack, Data, Offset), MMP_GetLPS(@Pack, Data, Offset),
      MMP_GetUL(@Pack, Data, Offset));
    end;
   end;
  MRIM_CS_USER_INFO:
   begin
    Offset:= 0;
    while Offset < Pack.dlen do
     with MMP_ContactInfo do
     begin
      Key:= MMP_GetLPS(@Pack, Data, Offset);
      Value:= MMP_GetLPS(@Pack, Data, Offset);
      if Assigned(FOnKeyRead) then
       FOnKeyRead(Self, Key, Value);
     end;
   end;
  MRIM_CS_MESSAGE_ACK:
   begin
    with MMP_Message do
    begin
     MsgID:= MMP_GetUL(@Pack, Data, Offset);
     Flags:= MMP_GetUL(@Pack, Data, Offset);
     From:= MMP_GetLPS(@Pack, Data, Offset);
     Text:= MMP_GetLPS(@Pack, Data, Offset);
     RTFText:= MMP_GetLPS(@Pack, Data, Offset);

     if (Flags and MESSAGE_FLAG_NORECV <> MESSAGE_FLAG_NORECV) and
      FSendMessageRecvOk then SendMessageRecv(From, MsgID);

     if (Flags and MESSAGE_FLAG_NOTIFY = MESSAGE_FLAG_NOTIFY) then
     begin
      IDContact:= FPrintManager.Push(From, MsgID);
      if IDContact = -1 then
      begin
       IDContact:= FPrintManager.GetID(From);
       KillTimer(FWND, TIMER_PRINT or (IDContact shl 8));
       SetTimer(FWND, TIMER_PRINT or (IDContact shl 8), FPrintInterval, nil);
      end
      else
      begin
       SetTimer(FWND, TIMER_PRINT or (IDContact shl 8), FPrintInterval, nil);
       if Assigned(FOnContactBeginPrint) then
        FOnContactBeginPrint(Self, MsgID, From, Text);
      end;
     end
     else if (Flags and MESSAGE_FLAG_AUTHORIZE = MESSAGE_FLAG_AUTHORIZE) then
     begin
      if Assigned(FOnContactAuthorize) then
       FOnContactAuthorize(Self, MsgID, From, Text);
     end
     else if (Flags and MESSAGE_FLAG_SYSTEM = MESSAGE_FLAG_SYSTEM) then
     begin
      if Assigned(FOnSystemMessage) then
       FOnSystemMessage(Self, MsgID, From, Text);
     end
     else if (Flags and MESSAGE_FLAG_OFFLINE = MESSAGE_FLAG_OFFLINE) then
     begin
      if Assigned(FOnOfflineMessage) then
       FOnOfflineMessage(Self, MsgID, From, Text);
     end
     else if Assigned(FOnMessage) then
     begin
      //    if Flags and MESSAGE_FLAG_RTF = MESSAGE_FLAG_RTF then // RTF
      FOnMessage(Self, MsgID, From, Text, False);
     end;
    end;
   end;
  MRIM_CS_ADD_CONTACT_ACK:
   begin
    with MMP_ContactOK do
    begin
     Status:= MMP_GetUL(@Pack, Data, Offset);
     ID:= MMP_GetUL(@Pack, Data, Offset);

     if FContactManager.Check then
      case Status of
       CONTACT_OPER_SUCCESS:
        begin
         with FContactManager.Pop do
         begin
          if Flag and CONTACT_FLAG_GROUP = CONTACT_FLAG_GROUP then
          begin
           if Assigned(FOnAddContactGroup) then
            FOnAddContactGroup(Self, ID, EMail);
          end
          else
          begin
           FCList.Add(EMail);
           if Assigned(FOnAddContact) then
             FOnAddContact(Self, GroupID, ID, EMail, Nick);
          end;
         end;
        end;
      else
       with FContactManager.Pop do
       begin
        if Flag and CONTACT_FLAG_GROUP = CONTACT_FLAG_GROUP then
        begin
         if Assigned(FOnAddContactGroupError) then
          FOnAddContactGroupError(Self, ID, EMail, Status);
        end
        else if Assigned(FOnAddContactError) then
         FOnAddContactError(Self, GroupID, ID, EMail, Nick, Status);
       end;
      end;
    end;
   end;
  MRIM_CS_MODIFY_CONTACT_ACK:
   begin
    with MMP_ContactOK do
    begin
     Status:= MMP_GetUL(@Pack, Data, Offset);

     if FCheckContactManager.Check then
      case Status of
       CONTACT_OPER_SUCCESS:
        begin
         with FCheckContactManager.Pop do
         begin
          if Flag and CONTACT_FLAG_GROUP = CONTACT_FLAG_GROUP then
          begin
           if Assigned(FOnModifyContactGroup) then
            FOnModifyContactGroup(Self, ID, EMail);
          end
          else
          begin
           if Assigned(FOnModifyContact) then
            FOnModifyContact(Self, GroupID, ID, EMail, Nick);
          end;
         end;
        end;
      else
       with FCheckContactManager.Pop do
       begin
        if Flag and CONTACT_FLAG_GROUP = CONTACT_FLAG_GROUP then
        begin
         if Assigned(FOnModifyContactGroupError) then
          FOnModifyContactGroupError(Self, ID, EMail, Status);
        end
        else if Assigned(FOnModifyContactError) then
         FOnModifyContactError(Self, GroupID, ID, EMail, Nick, Status);
       end;
      end;

    end;
   end;
  MRIM_CS_CONTACT_LIST2:
   begin
    with MMP_Contacts do
    begin
     Status:= MMP_GetUL(@Pack, Data, Offset);
     case Status of
      GET_CONTACTS_OK:
       begin
        if Assigned(FOnStartRequestContactList) then
         FOnStartRequestContactList(Self);

        GroupCount:= MMP_GetUL(@Pack, Data, Offset);
        GroupMask:= MMP_GetLPS(@Pack, Data, Offset);
        ContactMask:= MMP_GetLPS(@Pack, Data, Offset);
        
        ID:= 0;
        while ID < GroupCount do
         with MMP_Group do
         begin
          Flag:= MMP_GetUL(@Pack, Data, Offset);
          Name:= MMP_GetLPS(@Pack, Data, Offset);
          //_debug(name + ':' + int2hex(Flag,6));
          for i:= 3 to Length(GroupMask) do
           case GroupMask[i] of
            'u':
             MMP_GetUL(@Pack, Data, Offset);
            's':
             MMP_GetLPS(@Pack, Data, Offset);
           end;
          if(Flag and 1 = 0)and Assigned(FOnContactGroup) then
           FOnContactGroup(Self, ID, Name);
          ID:= ID + 1;
         end;
        FCList.Clear;
        while Offset < Pack.dlen do
         with MMP_Contact do
         begin
          Flag:= MMP_GetUL(@Pack, Data, Offset);
          GroupID:= MMP_GetUL(@Pack, Data, Offset);
          EMail:= MMP_GetLPS(@Pack, Data, Offset);
          Nick:= MMP_GetLPS(@Pack, Data, Offset);
          ServerFlag:= MMP_GetUL(@Pack, Data, Offset);
          Status:= MMP_GetUL(@Pack, Data, Offset);
          for i:= 7 to Length(ContactMask) do
           case ContactMask[i] of
            'u':
             MMP_GetUL(@Pack, Data, Offset);
            's':
             MMP_GetLPS(@Pack, Data, Offset);
           end;
          FCList.Add(EMail);
          if Assigned(FOnContact) then
            FOnContact(Self, GroupID, EMail, Nick, DStatusTo(Status), DInvisStateTo(Flag));
         end;
        if Assigned(FOnEndRequestContactList) then
         FOnEndRequestContactList(Self);
       end;
      GET_CONTACTS_ERROR:
       begin
       end;
      GET_CONTACTS_INTERR:
       begin
       end;
     end;
    end;
   end;
  MRIM_CS_MESSAGE_STATUS:
   begin
    IDContact:= FMessageManager.GetID(Pack.seq);
    if (IDContact >= 0) and Assigned(FOnMessageSended) then
    begin
     FOnMessageSended(Self, MMP_GetUL(@Pack, Data, Offset), Pack.seq,
      FMessageManager.Pop(IDContact).EMail);
    end;
   end;
  MRIM_CS_USER_STATUS:
   begin
    with MMP_Group do
    begin
     Flag:= MMP_GetUL(@Pack, Data, Offset);
     Name:= MMP_GetLPS(@Pack, Data, Offset);
     if Assigned(FOnStatusChange) then
      FOnStatusChange(Self, Name, DStatusTo(Flag));
    end;
   end;
  MRIM_CS_SMS_ACK: //yxo
   begin
       //_debug('SMS status: ' + int2str(MMP_GetUL(@Pack, Data, Offset)));
   end;

  MRIM_CS_ANKETA_INFO:
   begin
    with MMP_FindContactInfo do
    begin
     ZeroMemory(@MMP_FindContactInfo, SizeOf(MMP_FindContactInfo));

     Status:= MMP_GetUL(@Pack, Data, Offset);
     FieldNum:= MMP_GetUL(@Pack, Data, Offset);
     MaxRows:= MMP_GetUL(@Pack, Data, Offset);
     ServerTime:= MMP_GetUL(@Pack, Data, Offset);

     case Status of
      MRIM_ANKETA_INFO_STATUS_OK:
       begin
        for i:= 0 to FieldNum - 1 do
        begin
         MMP_GetLPS(@Pack, Data, Offset);
         // messagebox(FWND, PCHAR( MMP_GetLPS(@Pack, Data, Offset) ), '', 0);
        end;

        while Offset < Pack.dlen do
         for i:= 0 to FieldNum - 1 do
         begin
          User:= MMP_GetLPS(@Pack, Data, Offset);
          Domain:= MMP_GetLPS(@Pack, Data, Offset);
          Nickname:= MMP_GetLPS(@Pack, Data, Offset);
          FistName:= MMP_GetLPS(@Pack, Data, Offset);
          LastName:= MMP_GetLPS(@Pack, Data, Offset);
          Sex:= MMP_GetLPS(@Pack, Data, Offset);
          Birth_Day:= MMP_GetLPS(@Pack, Data, Offset);
          IDCity:= MMP_GetLPS(@Pack, Data, Offset);
          Location:= MMP_GetLPS(@Pack, Data, Offset);
          Zodiac:= MMP_GetLPS(@Pack, Data, Offset);
          BirthMonth:= MMP_GetLPS(@Pack, Data, Offset);
          BirthDay:= MMP_GetLPS(@Pack, Data, Offset);
          IDCountry:= MMP_GetLPS(@Pack, Data, Offset);
          Phone:= MMP_GetLPS(@Pack, Data, Offset);
          mrim_Status:= MMP_GetLPS(@Pack, Data, Offset);
          if Assigned(FOnUserFound) then
           FOnUserFound(Self, status, FieldNum, MaxRows, ServerTime,
            User, Domain, Nickname, FistName, LastName,
            Sex, Birth_Day, IDCity, Location, Zodiac, BirthMonth,
            BirthDay, IDCountry, Phone, mrim_Status);
          //               messagebox(FWND, PCHAR( MMP_GetLPS(@Pack, Data, Offset) ), '', 0);
         end;
       end;
     end;
    end;
   end;
 end;
 if (Data <> nil) then FreeMem(Data);
end;

procedure TMailClient.Hello;
var
 Pack: TMRIMPacket;
begin
 if Connected then
 begin
  MMP_Pack(@Pack, FSeq, MRIM_CS_HELLO, FSocket.Port, FSocket.IP);
  MMP_SendPack(FSocket.Socket, @Pack);
  FSeq:= FSeq + 1;
 end;
end;

procedure TMailClient.Authorize;
var
 Pack: TMRIMPacket;
 Data: Pointer;
begin
 if Connected then
 begin
  MMP_Pack(@Pack, FSeq, MRIM_CS_LOGIN2, FSocket.Port, FSocket.IP);
  MMP_AddLPS(@Pack, Data, Mail);
  MMP_AddLPS(@Pack, Data, PassWord);
  MMP_AddUL(@Pack, Data, DWORD_Status[FStatus]);
  MMP_AddLPS(@Pack, Data, status);
  MMP_AddLPS(@Pack, Data, Caption);
  MMP_SendPack(FSocket.Socket, @Pack, Data);
  FreeMem(Data);
  FSeq:= FSeq + 1;
 end;
end;

procedure TMailClient.Ping;
var
 Pack: TMRIMPacket;
begin
 if Connected then
 begin
  MMP_Pack(@Pack, FSeq, MRIM_CS_PING, FSocket.Port, FSocket.IP);
  MMP_SendPack(FSocket.Socket, @Pack);
  FSeq:= FSeq + 1;
  if Assigned(FOnPing) then
   FOnPing(Self);
 end;
end;

procedure TMailClient.SendMessage;
var
 Pack: TMRIMPacket;
 Data: Pointer;
begin
 if Connected then
 begin
  FMessageManager.Push(EMail, FSeq);
  MMP_Pack(@Pack, FSeq, MRIM_CS_MESSAGE, FSocket.Port, FSocket.IP);
  MMP_AddUL(@Pack, Data, 0);
  MMP_AddLPS(@Pack, Data, EMail);
  MMP_AddLPS(@Pack, Data, Text);
  MMP_AddLPS(@Pack, Data, ' ');
  MMP_SendPack(FSocket.Socket, @Pack, Data);
  FSeq:= FSeq + 1;
  FreeMem(Data);
 end;
end;

procedure TMailClient.SendMessageRecv;
var
 Pack: TMRIMPacket;
 Data: Pointer;
begin
 if Connected then
 begin
  MMP_Pack(@Pack, MsgID, MRIM_CS_MESSAGE_RECV, FSocket.Port, FSocket.IP);
  MMP_AddLPS(@Pack, Data, From);
  MMP_AddUL(@Pack, Data, MsgID);
  MMP_SendPack(FSocket.Socket, @Pack, Data);
  FreeMem(Data);
 end;
end;

procedure TMailClient.SendPrintMe;
var
 Pack: TMRIMPacket;
 Data: Pointer;
begin
 if Connected then
 begin
  MMP_Pack(@Pack, FSeq, MRIM_CS_MESSAGE, FSocket.Port, FSocket.IP);
  MMP_AddUL(@Pack, Data, MESSAGE_FLAG_NOTIFY);
  MMP_AddLPS(@Pack, Data, EMail);
  MMP_AddLPS(@Pack, Data, ' ');
  MMP_AddLPS(@Pack, Data, ' ');
  MMP_SendPack(FSocket.Socket, @Pack, Data);
  FSeq:= FSeq + 1;
  FreeMem(Data);
 end;
end;

procedure TMailClient.AuthorizeMe;
var
 Pack: TMRIMPacket;
 Data: Pointer;
begin
 if Connected then
 begin
  MMP_Pack(@Pack, FSeq, MRIM_CS_MESSAGE, FSocket.Port, FSocket.IP);
  MMP_AddUL(@Pack, Data, MESSAGE_FLAG_AUTHORIZE);
  MMP_AddLPS(@Pack, Data, EMail);
  MMP_AddLPS(@Pack, Data, Text);
  MMP_AddLPS(@Pack, Data, ' ');
  MMP_SendPack(FSocket.Socket, @Pack, Data);
  FSeq:= FSeq + 1;
  FreeMem(Data);
 end;
end;

procedure TMailClient.ContactAuthorize;
var
 Pack: TMRIMPacket;
 Data: Pointer;
begin
 if Connected then
 begin
  MMP_Pack(@Pack, FSeq, MRIM_CS_AUTHORIZE, FSocket.Port, FSocket.IP);
  MMP_AddLPS(@Pack, Data, EMail);
  MMP_SendPack(FSocket.Socket, @Pack, Data);
  FSeq:= FSeq + 1;
  FreeMem(Data);
 end;
end;

procedure TMailClient.AddGroup;
var
 Pack: TMRIMPacket;
 Data: Pointer;
begin
 if Connected then
 begin
  FContactManager.Push(GroupName, '', GroupCount, CONTACT_FLAG_GROUP);
  MMP_Pack(@Pack, FSeq, MRIM_CS_ADD_CONTACT, FSocket.Port, FSocket.IP);
  MMP_AddUL(@Pack, Data, CONTACT_FLAG_GROUP or ((GroupCount and $FF) shl 24));
  MMP_AddUL(@Pack, Data, 0);
  MMP_AddLPS(@Pack, Data, GroupName);
  MMP_AddLPS(@Pack, Data, '');
  MMP_SendPack(FSocket.Socket, @Pack, Data);
  FSeq:= FSeq + 1;
  FreeMem(Data);
 end;
end;

procedure TMailClient.DeleteGroup;
var
 Pack: TMRIMPacket;
 Data: Pointer;
begin
 if Connected then
 begin
  FCheckContactManager.Push(GroupName, GroupName, GroupID, CONTACT_FLAG_GROUP or
   CONTACT_FLAG_REMOVED or ((GroupCount and $FF) shl 24));
  MMP_Pack(@Pack, FSeq, MRIM_CS_MODIFY_CONTACT, FSocket.Port, FSocket.IP);
  MMP_AddUL(@Pack, Data, GroupID);
  MMP_AddUL(@Pack, Data, (CONTACT_FLAG_GROUP or CONTACT_FLAG_REMOVED) or
   ((GroupCount and $FF) shl 24));
  MMP_AddUL(@Pack, Data, 0);
  MMP_AddLPS(@Pack, Data, GroupName);
  MMP_AddLPS(@Pack, Data, GroupName);
  MMP_SendPack(FSocket.Socket, @Pack, Data);
  FSeq:= FSeq + 1;
  FreeMem(Data);
 end;
end;

procedure TMailClient.AddContact;
var
 Pack: TMRIMPacket;
 Data: Pointer;
begin
 if Connected then
 begin
  FContactManager.Push(EMail, Nick, GroupID, 0);
  MMP_Pack(@Pack, FSeq, MRIM_CS_ADD_CONTACT, FSocket.Port, FSocket.IP);
  MMP_AddUL(@Pack, Data, CONTACT_FLAG_VISIBLE);
  MMP_AddUL(@Pack, Data, GroupID);
  MMP_AddLPS(@Pack, Data, EMail);
  MMP_AddLPS(@Pack, Data, Nick);
  MMP_SendPack(FSocket.Socket, @Pack, Data);
  FSeq:= FSeq + 1;
  FreeMem(Data);
 end;
end;

procedure TMailClient.DeleteContact;
var
 Pack: TMRIMPacket;
 Data: Pointer;
 i:integer;
begin
 if Connected then
 begin
  FCheckContactManager.Push(EMail, Nick, GroupID, CONTACT_FLAG_REMOVED);
  MMP_Pack(@Pack, FSeq, MRIM_CS_MODIFY_CONTACT, FSocket.Port, FSocket.IP);
  i := FCList.IndexOf(EMail);
  FCList.Items[i] := ''; 
  MMP_AddUL(@Pack, Data, i + 20);
  MMP_AddUL(@Pack, Data, CONTACT_FLAG_REMOVED);
  MMP_AddUL(@Pack, Data, GroupID);
  MMP_AddLPS(@Pack, Data, EMail);
  MMP_AddLPS(@Pack, Data, Nick);
  MMP_AddLPS(@Pack, Data, '');
  MMP_SendPack(FSocket.Socket, @Pack, Data);
  FSeq:= FSeq + 1;
  FreeMem(Data);
 end;
end;

procedure TMailClient.ChangeContact;
var
 Pack: TMRIMPacket;
 Data: Pointer;
begin
 if Connected then
 begin
  FCheckContactManager.Push(EMail, Nick, GroupID, CONTACT_FLAG_REMOVED);
  MMP_Pack(@Pack, FSeq, MRIM_CS_MODIFY_CONTACT, FSocket.Port, FSocket.IP);
  MMP_AddUL(@Pack, Data, ID);
  MMP_AddUL(@Pack, Data, CONTACT_FLAG_VISIBLE);
  MMP_AddUL(@Pack, Data, GroupID);
  MMP_AddLPS(@Pack, Data, EMail);
  MMP_AddLPS(@Pack, Data, Nick);
  MMP_AddLPS(@Pack, Data, '');
  MMP_SendPack(FSocket.Socket, @Pack, Data);
  FSeq:= FSeq + 1;
  FreeMem(Data);
 end;
end;

procedure TMailClient.MoveContact;
var
 Pack: TMRIMPacket;
 Data: Pointer;
begin
 if Connected then
 begin
  FCheckContactManager.Push(EMail, Nick, GroupID, 0);
  MMP_Pack(@Pack, FSeq, MRIM_CS_MODIFY_CONTACT, FSocket.Port, FSocket.IP);
  MMP_AddUL(@Pack, Data, ID);
  MMP_AddUL(@Pack, Data, 0);
  MMP_AddUL(@Pack, Data, GroupID);
  MMP_AddLPS(@Pack, Data, EMail);
  MMP_AddLPS(@Pack, Data, Nick);
  MMP_SendPack(FSocket.Socket, @Pack, Data);
  FSeq:= FSeq + 1;
  FreeMem(Data);
 end;
end;

procedure TMailClient.FindContact(EMail: string; AlwaysOnLine: Boolean = False);
var
 Pack: TMRIMPacket;
 Data: Pointer;
 Login, Host: string;
begin
 if Connected and ExtractLoginAndHost(EMail, Login, Host) then
 begin
  MMP_Pack(@Pack, FSeq, MRIM_CS_WP_REQUEST, FSocket.Port, FSocket.IP);
  MMP_AddUL(@Pack, Data, MRIM_CS_WP_REQUEST_PARAM_USER);
  MMP_AddLPS(@Pack, Data, Login);
  MMP_AddUL(@Pack, Data, MRIM_CS_WP_REQUEST_PARAM_DOMAIN);
  MMP_AddLPS(@Pack, Data, Host);
  if AlwaysOnLine then
   MMP_AddUL(@Pack, Data, MRIM_CS_WP_REQUEST_PARAM_ONLINE);
  MMP_SendPack(FSocket.Socket, @Pack, Data);
  FSeq:= FSeq + 1;
  FreeMem(Data);
 end;
end;

procedure TMailClient.FindContact(Nick, Name, LastName: string; Sex, MinAge,
 MaxAge, IDCity, Zodiac, Month, Day, IDCountry: Integer;
 AlwaysOnLine: Boolean = False);
var
 Pack: TMRIMPacket;
 Data: Pointer;
begin
 if Connected then
 begin
  MMP_Pack(@Pack, FSeq, MRIM_CS_WP_REQUEST, FSocket.Port, FSocket.IP);

  if (Length(Nick) > 0) then
  begin
   MMP_AddUL(@Pack, Data, MRIM_CS_WP_REQUEST_PARAM_NICKNAME);
   MMP_AddLPS(@Pack, Data, Nick + '*');
  end;
  if (Length(Name) > 0) then
  begin
   MMP_AddUL(@Pack, Data, MRIM_CS_WP_REQUEST_PARAM_FIRSTNAME);
   MMP_AddLPS(@Pack, Data, Name + '*' );
  end;
  if (Length(LastName) > 0) then
  begin
   MMP_AddUL(@Pack, Data, MRIM_CS_WP_REQUEST_PARAM_LASTNAME);
   MMP_AddLPS(@Pack, Data, LastName + '*' );
  end;
  if (Sex >= 0) then
  begin
   MMP_AddUL(@Pack, Data, MRIM_CS_WP_REQUEST_PARAM_SEX);
   MMP_AddLPS(@Pack, Data, int2str(Sex));
  end;
  if (MinAge >= 0) then
  begin
   MMP_AddUL(@Pack, Data, MRIM_CS_WP_REQUEST_PARAM_DATE1);
   MMP_AddLPS(@Pack, Data, int2str(MinAge));
  end;
  if (MaxAge >= 0) then
  begin
   MMP_AddUL(@Pack, Data, MRIM_CS_WP_REQUEST_PARAM_DATE2);
   MMP_AddLPS(@Pack, Data, int2str(MaxAge));
  end;
  if (IDCity >= 0) then
  begin
   MMP_AddUL(@Pack, Data, MRIM_CS_WP_REQUEST_PARAM_CITY_ID);
   MMP_AddLPS(@Pack, Data, int2str(IDCity));
  end;
  if (Zodiac >= 0) then
  begin
   MMP_AddUL(@Pack, Data, MRIM_CS_WP_REQUEST_PARAM_ZODIAC);
   MMP_AddLPS(@Pack, Data, int2str(Zodiac));
  end;
  if (Month >= 0) then
  begin
   MMP_AddUL(@Pack, Data, MRIM_CS_WP_REQUEST_PARAM_BIRTHDAY_MONTH);
   MMP_AddLPS(@Pack, Data, int2str(Month));
  end;
  if (Day >= 0) then
  begin
   MMP_AddUL(@Pack, Data, MRIM_CS_WP_REQUEST_PARAM_BIRTHDAY_DAY);
   MMP_AddLPS(@Pack, Data, int2str(Day));
  end;
  if (IDCountry >= 0) then
  begin
   MMP_AddUL(@Pack, Data, MRIM_CS_WP_REQUEST_PARAM_COUNTRY_ID);
   MMP_AddLPS(@Pack, Data, int2str(IDCountry));
  end;
  if AlwaysOnLine then
   MMP_AddUL(@Pack, Data, MRIM_CS_WP_REQUEST_PARAM_ONLINE);

  MMP_SendPack(FSocket.Socket, @Pack, Data);
  FSeq:= FSeq + 1;
  FreeMem(Data);
 end;
end;

procedure TMailClient.SendSMS(Phone, Text: string); //yxo
var
 Pack: TMRIMPacket;
 Data: Pointer;
begin
 if Connected then
 begin
  MMP_Pack(@Pack, FSeq, MRIM_CS_SMS, FSocket.Port, FSocket.IP);
  MMP_AddUL(@Pack, Data, 0);
  MMP_AddLPS(@Pack, Data, Phone);
  MMP_AddLPS(@Pack, Data, Text);
  MMP_SendPack(FSocket.Socket, @Pack, Data);
  FSeq:= FSeq + 1;
  FreeMem(Data);
 end;
end;

initialization
 WSAStartup(MAKEWORD(2, 2), WSData);
 
finalization
 WSACleanUp;
 
end.

