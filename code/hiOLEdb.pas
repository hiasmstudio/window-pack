unit hiOLEdb;

interface

uses Kol,Share,Debug,KOLEdb;

type
  THIOLEdb = class(TDebug)
   private
    ds:PDataSource;
    _err:boolean;
    procedure _onError(Result: HResult);
   public
    _prop_Driver:string;

    _data_Driver:THI_Event;
    _event_onError:THI_Event;
    _event_onConnect:THI_Event;

    destructor Destroy; override;
    procedure _work_doOpen(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _var_dbHandle(var _Data:TData; Index:word);
  end;

var OleDbGUID:integer;

implementation

destructor THIOLEdb.Destroy;
begin
   ds.free;
   inherited;
end;

procedure THIOLEdb._onError;
begin
   _err := true;
   _hi_onEvent(_event_onError, integer(Result));
end;

procedure THIOLEdb._work_doOpen;
var dt:TData;
begin
   if ds <> nil then exit;
   _err := false;
   ds := NewDataSource(ReadString(_Data, _data_Driver, _prop_Driver), _onError);
   if _err then free_and_nil(ds)
   else if ds <> nil then begin 
      genGuid(OleDbGUID);
      dtObject(Dt, OleDbGUID, ds);
      _hi_CreateEvent(_Data, @_event_onConnect, Dt);
   end
end;

procedure THIOLEdb._work_doClose;
begin
  free_and_nil(ds);
end;

procedure THIOLEdb._var_dbHandle;
begin
  if ds = nil then dtInteger(_Data,0)
  else dtObject(_Data, OleDbGUID, ds);
end;

end.
