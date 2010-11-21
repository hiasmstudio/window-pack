unit hiMRA_Base;

interface

uses windows,Kol,Share,Debug,mra_client;

type
  THIMRA_Base = class(TDebug)
   private
    mra:TMailClient;
    procedure OnRecievedHost(sender:TObject);
    procedure onError(sender:TObject); 
    procedure onConnect(sender:TObject);
    procedure OnHello(sender:TObject);
    procedure OnDisconnect(sender:TObject); 
   public
    _prop_Host:string;
    _prop_Port:integer;
    _prop_Name:string;

    _data_Port:THI_Event;
    _data_Host:THI_Event;
    _event_onError:THI_Event;
    _event_onConnect:THI_Event;
    _event_onDisconnect:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doConnect(var _Data:TData; Index:word);
    procedure _work_doDisconnect(var _Data:TData; Index:word);
    procedure _var_Connection(var _Data:TData; Index:word);
    procedure _var_MRA_Handle(var _Data:TData; Index:word);
    property GetInterfaceMRA:TMailClient read mra;
  end;

var MRA_GUID:integer;

implementation

constructor THIMRA_Base.Create;
begin
  inherited;
  mra := TMailClient.Create;
  mra.onError := onError;
  mra.onConnect := onConnect;
  mra.OnRecievedHost := OnRecievedHost;
  mra.OnHello := OnHello;
  mra.OnDisconnect := OnDisconnect;
  
  GenGUID(MRA_GUID);
end;

destructor THIMRA_Base.Destroy;
begin
  mra.Destroy;
  inherited;
end;

procedure THIMRA_Base.OnRecievedHost(sender:TObject); 
begin
   mra.Connect;
end;

procedure THIMRA_Base.onConnect(sender:TObject);
begin
   mra.Hello;
end;

procedure THIMRA_Base.OnHello(sender:TObject); 
begin
   _hi_onEvent(_event_onConnect);
end;

procedure THIMRA_Base.OnDisconnect(sender:TObject); 
begin
   _hi_onEvent(_event_onDisConnect);
end;

procedure THIMRA_Base.onError(sender:TObject);
begin
  _hi_onEvent(_event_onError, integer(mra.LastError));
end;

procedure THIMRA_Base._work_doConnect;
begin
  mra.MRIMHost := ReadString(_Data, _data_Host, _prop_Host);
  mra.MRIMPort := ReadInteger(_Data, _data_Port, _prop_Port);
  mra.RequestHost;
end;

procedure THIMRA_Base._work_doDisconnect;
begin
  mra.Status := OffLine;
end;

procedure THIMRA_Base._var_MRA_Handle;
begin
  dtObject(_Data,MRA_GUID,mra);
end;

procedure THIMRA_Base._var_Connection;
begin
  dtInteger(_Data, integer(mra.Connected));
end;

end.
