unit hiTCP_ServerEx;

interface

uses KOL,Share,Debug,TCP,hiMultiBase,hiMultiElementEx,hiEditMultiEx,hiTCP_Client;

type
  THITCP_ServerEx = class(THIMultiElementEx)
  private
    FSock: TSocket;

    procedure _OnClientConnect(Sender: TSocket);
    procedure _OnClientDisconnect(Sender: TSocket);
  public
    ServerPort: THI_Event;
    _prop_ServerPort: integer;

    constructor Create(Control:PControl);
    destructor Destroy; override;

    procedure Add(var Data:TData; Index:word);
    procedure Open(var Data:TData; Index:word);
    procedure Close(var Data:TData; Index:word);
  end;

implementation

constructor THITCP_ServerEx.Create;
begin
  FSock := nil;
  inherited Create(Control);
  _prop_Mode := 1;
end;

destructor THITCP_ServerEx.Destroy;
var dt:TData;
begin
  Close(dt,0);
  inherited;
end;

type
  TMainClass = class(TClassMultiBase)
    emx:THIEditMultiEx;
    cli:THITCP_Client;
  end;

procedure THITCP_ServerEx._OnClientConnect;
var emx:THIEditMultiEx; mc:TMainClass; sv:TSocketNotify;
begin
  emx := AddInstance;
  mc := TMainClass(emx.MainClass);
  sv := Sender.OnDisconnect; 
  mc.cli.Attach(Sender);
  Sender.OnDisconnect := sv;
  Sender.Tag := integer(mc);
  _hi_OnEvent(mc.cli._event_onConnect, Sender.IP);
end;

procedure THITCP_ServerEx._OnClientDisconnect;
var mc:TMainClass;
begin
  mc := TMainClass(Sender.Tag);
  _hi_OnEvent(mc.cli._event_onDisConnect);
  RemoveInstance(mc.emx);
end;

procedure THITCP_ServerEx.Add;
begin
end;

procedure THITCP_ServerEx.Open;
begin
  if not Assigned(FSock) then begin
    FSock := TSocket.Create;
    FSock.OnClientConnect := _OnClientConnect;
    FSock.OnClientDisconnect := _OnClientDisconnect;
    FSock.StartServer(ReadInteger(Data,ServerPort,_prop_ServerPort),'');
    if FSock.Connected then FSock.Listen(10);
  end;
end;

procedure THITCP_ServerEx.Close;
var i:integer;
begin
  if Assigned(FSock) then begin
    for i:=0 to FSock.Count-1 do
      FSock.Connections[i].Close;
    FSock.Destroy;
    FSock := nil;
  end;
end;

end.
