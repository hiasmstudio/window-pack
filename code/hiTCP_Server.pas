unit hiTCP_Server;

interface

uses Kol,Share,Windows,TCP, Debug;

const
  dtInteger = 0;
  dtString = 1;
  dtReal = 2;
  dtStream = 3;

type
  THITCP_Server = class(TDebug)
   private
    Sock:TSocket;
    Arr:PArray;
    Mem:PStream;
    FSize:cardinal;
    FSizeCount:byte;

    function Read(Var Item:TData; var Val:TData):boolean;
    function Count:integer;

    procedure _OnConnect(Sender: TSocket);
    procedure _OnDisConnect(Sender: TSocket);

    procedure _OnClientConnect(Sender: TSocket);
    procedure _OnClientDisConnect(Sender: TSocket);
    procedure _OnRes(Sender: TSocket; Buf: pointer; Count: cardinal);
//    procedure _OnError(Sender: PObj; const Error:integer);
   public
    _prop_IP:string;
    _prop_Port:integer;
    _prop_DataType:byte;
    _data_Data:THI_Event;
    _data_Port:THI_Event;
    _event_onConnect:THI_Event;
    _event_onDisconnect:THI_Event;
    _event_onServerConnect:THI_Event;
    _event_onServerDisconnect:THI_Event;
    _event_onRead:THI_Event;
    _event_onError:THI_Event;
    _event_onProgress:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doOpen(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _work_doSend(var _Data:TData; Index:word);
    procedure _work_doSendByIp(var _Data:TData; Index:word);
    procedure _work_doCloseAll(var _Data:TData; Index:word);
    procedure _work_doCloseByIP(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_IP(var _Data:TData; Index:word);
  end;

implementation

constructor THITCP_Server.Create;
begin
   inherited;
   Sock := TSocket.Create;
   Sock.OnConnect := _OnConnect;
   Sock.OnDisconnect := _OnDisConnect;
   Sock.OnRead := _OnRes;
   Sock.OnClientConnect := _OnClientConnect;
   Sock.OnClientDisconnect := _OnClientDisConnect;
//   Sock.OnError := _OnError;
end;

destructor THITCP_Server.Destroy;
begin
  Sock.OnConnect := nil;
  Sock.OnDisconnect := nil;
  Sock.OnRead := nil;
  Sock.OnClientConnect := nil;
  Sock.OnClientDisconnect := nil;
  Sock.Destroy;
  if Arr <> nil then dispose(Arr);
  inherited;
end;

procedure THITCP_Server._work_doOpen;
begin
   if Sock.Connected then Exit;
   Sock.StartServer(ReadInteger(_Data,_data_Port,_prop_Port),'');
   if Sock.Connected then Sock.Listen(10);
end;

procedure THITCP_Server._work_doClose;
begin
   if Sock.Connected then Sock.DisconnectClients;
   Sock.Close;
end;

procedure THITCP_Server._OnClientConnect;
begin
   _hi_OnEvent( _event_onConnect,Sender.IP );
end;

procedure THITCP_Server._OnClientDisConnect;
begin
   _hi_OnEvent( _event_onDisConnect,Sender.IP );
end;

procedure THITCP_Server._OnConnect;
begin
   _hi_OnEvent( _event_onServerConnect );
end;

procedure THITCP_Server._OnDisConnect;
begin
   _hi_OnEvent( _event_onServerDisconnect );
end;

//procedure THITCP_Server._OnError;
//begin
//  _hi_OnEvent( _event_onError,Error );
//end;

procedure THITCP_Server._OnRes;
var
    dt,d:TData;
    f:PData;
    c:integer;
    s: string;
    
    procedure event;
    begin
      Share.dtString(d, Sender.IP);
      AddMTData(@dt, @d, f);
      _hi_OnEvent(_event_onRead, dt);
      FreeData(f);    
    end;
begin
    case _prop_DataType of
     0: begin Share.dtInteger(dt, integer(buf^)); event(); end;
     1: begin
          SetLength(s, Count); 
          CopyMemory(@s[1], buf, Count);
          Share.dtString(dt, s);
          event();
         end;
     2: begin Share.dtReal(dt, real(buf^)); event(); end;
     3:
      while count > 0 do
       begin
         if Mem = nil then
          begin
           c := min(count, 4 - FSizeCount);
           CopyMemory(pointer(integer(@FSize) + FSizeCount), buf, c);
           inc(FSizeCount, c);
           if FSizeCount = 4 then
             begin
               Mem := NewMemoryStream;
               FSize := cardinal(buf^);
               if (count < 4) then
                  _debug('THITCP_Server: incorrect value count ' + int2str(count));
               inc(integer(buf), 4);
             end;
           dec(Count, c);
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
             Share.dtStream(dt, Mem);
             event();
//             _hi_OnEvent(_event_onRead,mem);
             Free_and_nil(Mem);
             FSizeCount := 0;
          end;
       end;
    end;
end;

procedure THITCP_Server._work_doSend;
var i,j:integer;
  r:real;
  s:string;
  st:PStream;
begin
    st := nil;
    case _prop_DataType of
       0: j := ReadInteger(_data,_data_Data,0);
       1: s := ReadString(_data,_data_Data,'');
       2: r := ReadInteger(_data,_data_Data,0);
       3: begin
             st := ReadStream(_data,_data_Data,nil);
             if st <> nil then
               j := st.Size;
          end;
    end;

   if Sock.Connected then
    for i := 0 to Sock.Count-1 do
     case _prop_DataType of
       0: Sock.Connections[i].Send(@j,sizeof(j));
       1: Sock.Connections[i].Send(@s[1],length(s));
       2: Sock.Connections[i].Send(@r,sizeof(r));
       3: begin
              if st <> nil then 
               begin
                 Sock.Connections[i].Send(@j,sizeof(j));
                 st.Position := 0;
                 Sock.Connections[i].Send(st.Memory,j);
               end;
          end;
    end;
end;

procedure THITCP_Server._work_doSendByIp;
var i,j:integer;
  r:real;
  s,ip:string;
  st:PStream;
  con:TSocket;
begin
    st := nil;
    case _prop_DataType of
       0: j := ReadInteger(_data,_data_Data,0);
       1: s := ReadString(_data,_data_Data,'');
       2: r := ReadInteger(_data,_data_Data,0);
       3: begin
             st := ReadStream(_data,_data_Data,nil);
             if st <> nil then
               j := st.Size;
          end;
    end;

   ip := ToString(_Data);
   con := nil;
   for i := 0 to Sock.Count-1 do
    if ip = Sock.Connections[i].ip then
     begin
      con := Sock.Connections[i];
      break;
     end;    
   
   if Sock.Connected and (con <> nil) then
     case _prop_DataType of
       0: con.Send(@j,sizeof(j));
       1: con.Send(@s[1],length(s));
       2: con.Send(@r,sizeof(r));
       3: begin
              if st <> nil then 
               begin
                 con.Send(@j,sizeof(j));
                 st.Position := 0;
                 con.Send(st.Memory,j);
               end;
          end;
    end;
end;

procedure THITCP_Server._work_doCloseAll;
begin
  Sock.DisconnectClients;
end;

procedure THITCP_Server._work_doCloseByIP;
begin
  Sock.DisconnectByIP(ToString(_Data));
end;

procedure THITCP_Server._var_Count;
begin
  if Assigned(Sock) then
     Share.dtInteger(_Data,Sock.Count);
end;

procedure THITCP_Server._var_IP;
begin
  if Arr = nil then
    Arr := CreateArray(nil,read,count,nil);
  dtArray(_Data,Arr);
end;

function THITCP_Server.Read;
type
   TChAddr = record c1,c2,c3,c4:byte; end;
var
  ind:integer;
begin
  ind := ToIntIndex(Item);
  if(ind >= 0 )and(ind < integer(Sock.Count))then
    Share.dtString(Val,Sock.Connections[ind].IP)
  else dtNull(Val);
  Result := not _IsNull(Val);
end;

function THITCP_Server.Count;
begin
   if Assigned(Sock) then Result := Sock.Count else Result := 0;
end;

end.