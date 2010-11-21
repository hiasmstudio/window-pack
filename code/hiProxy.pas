unit hiProxy;

interface

uses Kol,Share,Windows,Debug,hiCharset,EasyProxy;

type
  THIProxy = class(TDebug)
   private
    Proxy:TProxy;

    procedure _OnHost(Sender: TProxy; const Host:string);
    function _OnIsAuth(Sender:TProxy; const LoginPass:string):boolean;
    procedure SetAuthorization(value:boolean);
   public
    _prop_Port:integer;
    _prop_ServicePort:integer;
    _prop_IP:string;

    _data_IP:THI_Event;
    _data_Port:THI_Event;
    _data_ServicePort:THI_Event;
    _data_UserArray:THI_Event;

    _event_onURL:THI_Event;
    _event_onError:THI_Event;

    constructor Create;
    destructor Destroy; override;

    procedure _work_doOpen(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    property _prop_Authorization:boolean write SetAuthorization;
  end;

implementation

constructor THIProxy.Create;
begin
   inherited Create;
   UPD_Init;
   Proxy := TProxy.Create;
   Proxy.OnHost := _OnHost;
end;

destructor THIProxy.Destroy;
begin
   Proxy.Destroy;
   inherited;
end;

procedure THIProxy.SetAuthorization;
begin
   if value then
     Proxy.OnIsAuth := _OnIsAuth;
end;

procedure THIProxy._OnHost;
begin
   _hi_onEvent(_event_onURL, host);
end;

function THIProxy._OnIsAuth;
var i:integer;
    ua:PArray; ind,dt:TData;
begin
    Result := false;
    ua := ReadArray(_data_UserArray);
    if ua <> nil then
        for i := 0 to ua._Count-1 do
          begin
            dtInteger(ind, i);
            if ua._Get(ind,dt) and(ToString(dt) = LoginPass) then
              begin
                Result := True;
                break;
              end;
          end;
end;

procedure THIProxy._work_doOpen;
begin
   Proxy.Init(ReadInteger(_data, _data_Port, _prop_Port), 8);
end;

procedure THIProxy._work_doClose;
begin
   Proxy.Stop;
end;

procedure THIProxy._var_Count;
begin
   dtInteger(_Data, Proxy.Count);
end;

end.
