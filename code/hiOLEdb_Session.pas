unit hiOLEdb_Session;

interface

uses Kol,Share,Debug,KOLEdb;

type
  THIOLEdb_Session = class(TDebug)
   private
    ss:PSession;
    _err:boolean;
    procedure _onError(Result: HResult);
    procedure _onDestroy(Sender:PObj);virtual;
   public
    _data_dbHandle:THI_Event;
    _event_onCreate:THI_Event;
    _event_onError:THI_Event;

    destructor Destroy; override;
    procedure _work_doCreate(var _Data:TData; Index:word);
    procedure _var_dbSession(var _Data:TData; Index:word);
  end;

var OleSessionGUID:integer;

implementation

uses hiOLEdb;

destructor THIOLEdb_Session.Destroy;
begin
   ss.free;
   inherited;
end;

procedure THIOLEdb_Session._onDestroy;
begin
   ss := nil;
end;

procedure THIOLEdb_Session._onError;
begin
   _err := true;
   _hi_onEvent(_event_onError, integer(Result));
end;

procedure THIOLEdb_Session._work_doCreate;
var
    dt:TData;
    ds:PDataSource;
begin
   dt := Readdata(_Data,_data_dbHandle,nil);
   if not _isObject(dt, OleDbGUID) then exit;
   ds := PDataSource(ToObject(dt));
   ss.free;
   ss := NewSession(ds,_onError);
   ss.onDestroy := _onDestroy;
   genGuid(OleSessionGUID);
   dtObject(Dt, OleSessionGUID, ss);
   if not _err then _hi_CreateEvent(_Data, @_event_onCreate, Dt);
end;

procedure THIOLEdb_Session._var_dbSession;
begin
  if ss = nil then dtInteger(_Data,0)
  else dtObject(_Data, OleSessionGUID, ss);
end;

end.
