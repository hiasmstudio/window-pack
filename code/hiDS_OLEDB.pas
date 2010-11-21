unit hiDS_OLEDB;

interface

uses Windows, Kol, Share, Debug, KOLEdb, DS_client;

type
  THIDS_OLEDB = class(TDebug)
   private
    ss: PSession;
    dss: TIDataSource;
    ds: PDataSource;
    _err: boolean;
    procedure Close;
    procedure _onErrorSession(Result: HResult);
    procedure _onErrorQuery(Result: HResult);    
    procedure _onDestroySession(Sender: PObj); virtual;    
    function  procexec(const SQL: string): TData;
    function  procquery(const SQL: string; callBackFields: TCallBackFields; callBackData: TCallBackData): TData;
    function  procqueryscalar(const SQL: string; var Data: TData): TData;
   public
    _prop_Name: string;
    _prop_Driver: string;

    _data_Driver:THI_Event;
    _event_onCreate:THI_Event;
    _event_onError:THI_Event;

    constructor Create;
    destructor Destroy; override;
    function getInterfaceDataSource: IDataSource;
    procedure _work_doOpen(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
  end;

implementation

function SqlDateTimeStampToDateTime( TS: PSqlDateTimeStamp ):TDateTime;
var
  ST: TSystemTime;
begin
  ST.wYear := TS.Year;
  ST.wMonth := TS.month;
  ST.wDay := TS.day;
  ST.wHour := TS.hour;
  ST.wMinute := TS.minute;
  ST.wSecond := TS.second;
  ST.wMilliseconds := TS.fraction div 1000000;
  SystemTime2DateTime( ST, Result );
end;

function THIDS_OLEDB.getInterfaceDataSource;
begin
  Result := @dss;
end;

constructor THIDS_OLEDB.Create;
begin
  inherited;
  dss.procexec := procexec;
  dss.procqueryscalar := procqueryscalar;
  dss.procquery := procquery;
end; 

destructor THIDS_OLEDB.Destroy;
begin
  Close;
  inherited;
end;

procedure THIDS_OLEDB._onDestroySession;
begin
  ss := nil;
end;

procedure THIDS_OLEDB._onErrorQuery;
begin
end;

procedure THIDS_OLEDB._onErrorSession;
begin
  _err := true;
  _hi_onEvent(_event_onError, integer(Result));
end;

procedure THIDS_OLEDB.Close;
begin
  free_and_nil(ss);
  free_and_nil(ds);
end;

procedure THIDS_OLEDB._work_doClose;
begin
  Close;
end;

procedure THIDS_OLEDB._work_doOpen;
begin
  Close;
  _err := false;
  ds := NewDataSource(ReadString(_Data, _data_Driver, _prop_Driver), _onErrorSession);
  if _err then
  begin
   free_and_nil(ds);
   exit;
  end; 
  ss := NewSession(ds, _onErrorSession);
  ss.onDestroy := _onDestroySession;
  if not _err then
    _hi_CreateEvent(_Data, @_event_onCreate)
  else
    Close;
end;

procedure GetData(qr: PQuery; i: integer; var ndt: TData);
var
  st: PStream;
  _date: PSqlDateTimeStamp; 
begin
  case qr.Bindings[i].wType of
    DBTYPE_STR,DBTYPE_WSTR:
      dtString(ndt, QR.SField[i]);
    DBTYPE_I4,DBTYPE_UI1:
      dtInteger(ndt, QR.IField[i]);
    DBTYPE_I2:  
      dtInteger(ndt, QR.I2Field[i]);
    DBTYPE_R4,DBTYPE_R8:
      dtReal(ndt, QR.RField[i]);
    DBTYPE_NULL:
      dtString(ndt, 'NULL');
    DBTYPE_EMPTY:    
      dtString(ndt, 'EMPTY');
    DBTYPE_DATE:
      dtString(ndt, '-dt-');
    DBTYPE_BOOL:
      dtInteger(ndt, QR.IField[i]); 
    DBTYPE_BYTES: 
    begin
      st := QR.BlobField[i];
      if st = nil then
        dtInteger(ndt, 0)
      else
        dtStream(ndt, st);
    end;
    DBTYPE_DBTIMESTAMP: 
    begin
      _date := QR.TSField[i];
      if _date = nil then 
        dtString(ndt, 'null') 
      else
        dtString(ndt, DateTime2StrShort(SqlDateTimeStampToDateTime(_date)));
    end
    else
      dtString(ndt, 'None: ' + int2str(qr.Bindings[i].wType));
  end; // case 
end;

procedure _procquery(const qr: PQuery; const user: pointer);
var
  dt,
  ndt: TData;
  i: integer;
  s: PData;
  list: PStrList;
begin
  if (assigned(PCallBackRec(user).callBackFields)) and (qr.ColCount > 0) then
  begin
    list := NewStrList;
    for i := 0 to qr.ColCount - 1 do 
      list.add(qr.ColNames[i]); 
    PCallBackRec(user).callBackFields(list);
    list.free;
  end;
  while not qr.EOF do 
  begin
    dtNull(dt);
    for i := 0 to qr.ColCount - 1 do 
    begin
      GetData(qr, i, ndt);
      AddMTData(@dt, @ndt, s);
    end; // for
    ndt := dt;
    PCallBackRec(user).callBackData(dt);
    FreeData(@ndt);
    qr.Next;
  end;   // while
end;

procedure _procqueryscalar(const qr: PQuery; const user: pointer);
begin
  GetData(qr, 0, PData(user)^);
end;

function THIDS_OLEDB.procquery;
var
  rec: TCallBackRec;
  qr: PQuery;
begin
  if ss = nil then
  begin
    dtInteger(Result, 1);
    exit;
  end;
  qr := NewQuery(ss, _onErrorQuery);
TRY
  if qr.Error <> 0 then exit;       
  qr.Text := SQL;
  qr.Open;
  if qr.Error <> 0 then exit;  
  rec.callBackFields := callBackFields;
  rec.callBackData := callBackData;
  _procquery(qr, @rec);
FINALLY
  if qr.Error <> 0 then
    dtInteger(Result, qr.Error)
  else
    dtNull(Result);
  free_and_nil(qr);
END;
end;

function THIDS_OLEDB.procqueryscalar;
var
  qr: PQuery;
begin
  if ss = nil then
  begin
    dtInteger(Result, 1);
    exit;
  end;
  qr := NewQuery(ss, _onErrorQuery);
TRY
  if qr.Error <> 0 then exit;       
  qr.Text := SQL;
  qr.Open;
  if qr.Error <> 0 then exit;  
  _procqueryscalar(qr, @Data);
FINALLY
  if qr.Error <> 0 then
    dtInteger(Result, qr.Error)
  else
    dtNull(Result);
  free_and_nil(qr);
END;
end;

function THIDS_OLEDB.procexec;
var
  qr: PQuery;
begin
  if ss = nil then
  begin
    dtInteger(Result, 1);
    exit;
  end;
  qr := NewQuery(ss, _onErrorQuery);
TRY
  if qr.Error <> 0 then exit;
  qr.Text := SQL;
  qr.Execute;
FINALLY
  if qr.Error <> 0 then
    dtInteger(Result, qr.Error)
  else
    dtNull(Result);
  free_and_nil(qr);
END;  
end;

end.

