unit hiTCP_Client;

interface

uses Kol,Share,Windows,TCP,Debug;

const
  dtInteger = 0;
  dtString = 1;
  dtReal = 2;
  dtStream = 3;

type
  THITCP_Client = class(TDebug)
   private
    Sock:TSocket;
    Mem:PStream;
    FSize:cardinal;
    FDeleteSocket:boolean;

    procedure _OnConnect(Sender: TSocket);
    procedure _OnDisConnect(Sender: TSocket);
    procedure _OnRes(Sender: TSocket; Buf: pointer; Count: cardinal);
    //procedure _OnError(Sender: PObj; const Error:integer);
   public
    _prop_IP:string;
    _prop_Port:integer;
    _prop_DataType:byte;
    _data_IP:THI_Event;
    _data_Data:THI_Event;
    _data_Port:THI_Event;
    _event_onConnect:THI_Event;
    _event_onDisconnect:THI_Event;
    _event_onRead:THI_Event;
    _event_onError:THI_Event;
    _event_onProgress:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure Attach(sck:TSocket);
    function Detach:TSocket;
    procedure _work_doOpen(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _work_doSend(var _Data:TData; Index:word);
    procedure _var_Active(var _Data:TData; Index:word);
    procedure _var_IP(var _Data:TData; Index:word);
  end;

implementation

constructor THITCP_Client.Create;
begin
  inherited;
  Sock := nil;
  FDeleteSocket := false;
end;

destructor THITCP_Client.Destroy;
begin
  if Assigned(Sock) then
    if FDeleteSocket then Detach.Destroy else Detach;
  inherited;
end;

procedure THITCP_Client.Attach;
begin
  if Assigned(Sock) then
    if FDeleteSocket then Detach.Destroy else Detach;
  Sock := sck;
  Sock.OnConnect := _OnConnect;
  Sock.OnDisconnect := _OnDisConnect;
  Sock.OnRead := _OnRes;
  //Sock.OnError := _onError;
end;

function THITCP_Client.Detach;
begin
  Result := Sock;
  if Assigned(Sock) then begin
    Sock.OnConnect := nil;
    Sock.OnDisconnect := nil;
    Sock.OnRead := nil;
    //Sock.OnError := nil;
    Sock := nil;
    FDeleteSocket := false;
  end;
end;

procedure THITCP_Client._OnConnect;
begin
   _hi_OnEvent( _event_onConnect );
end;

procedure THITCP_Client._OnDisConnect;
begin
   _hi_OnEvent( _event_onDisConnect );
end;

{procedure THITCP_Client._OnError;
begin
  _hi_OnEvent( _event_onError,Error );
end;}

procedure THITCP_Client._OnRes;
var s:string;
    c:integer;
begin
    case _prop_DataType of
     0: _hi_OnEvent(_event_onRead,integer(buf^));
     1:
      begin
       SetLength(s,Count);
       CopyMemory(@s[1], buf, Count);
       _hi_OnEvent(_event_onRead,s);
      end;
     2: _hi_OnEvent(_event_onRead,real(buf^));
     3:
      while count > 0 do
       begin
         if Mem = nil then
          begin
           Mem := NewMemoryStream;
           FSize := cardinal(buf^);
           inc(integer(buf), 4);
           dec(Count, 4);
          end;
          
         if Count > 0 then 
          begin
            c := Mem.Write(buf^,min(count,FSize - Mem.Size)); 
            dec(count, c);            
            inc(integer(buf), c);
          end;

         _hi_OnEvent(_event_onProgress, integer(Mem.Position));

         if FSize = Mem.Size then
          begin
             Mem.Position := 0;
             _hi_OnEvent(_event_onRead,mem);
             Free_and_nil(Mem);
          end;
       end;
    end;
end;

procedure THITCP_Client._work_doOpen;
var p:word;
   h:string;
begin
  if not Assigned(Sock) then begin
    Attach(TSocket.Create);
    FDeleteSocket := true;
  end;
  P := ReadInteger(_Data,_data_Port,_prop_Port);
  H := ReadString(_Data,_data_IP,_prop_IP);
  Sock.StartClient(p,h);
end;

procedure THITCP_Client._work_doClose;
begin
   if Assigned(Sock) then Sock.Close;
end;

procedure THITCP_Client._work_doSend;
var st:PStream;
    i:integer;
    r:real;
    s:string;
begin
  if not Assigned(Sock) then Exit;
  if Sock.Connected then
    case _prop_DataType of
     0:
       begin
        i := ReadInteger(_data,_data_Data,0);
        Sock.Send(@i,sizeof(i));
       end;
     1:
      begin
        s := ReadString(_data,_data_Data,'');
        Sock.Send(@s[1],length(s));
      end;
     2:
       begin
        r := ReadReal(_data,_data_Data,0);
        Sock.Send(@r,sizeof(r));
       end;
     3:
      begin
        st := ReadStream(_data,_data_Data,nil);
        if st <> nil then
         begin
         //_debug(int2str(st.size));
          st.Position := 0;
          i := st.Size;
          Sock.Send(@i,sizeof(i));
          Sock.Send(st.Memory,St.Size);
         end;
      end;
    end;
end;

procedure THITCP_Client._var_Active;
var a:integer;
begin
  if Assigned(Sock) then a := byte(Sock.Connected) else a := 0;
  Share.dtInteger(_Data, a);
end;

procedure THITCP_Client._var_IP;
begin
  if Assigned(Sock) then Share.dtString(_Data, Sock.IP);
end;

end.
