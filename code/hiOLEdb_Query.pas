unit hiOLEdb_Query;

interface

uses Kol,Share,Debug,KOLEdb;

type
  THIOLEdb_Query = class(TDebug)
   private
    qr:PQuery;
    _err:boolean;
    procedure _onError(Result: HResult);
    procedure _onDestroy(Sender:PObj); virtual;
   public
    _prop_Text:string;

    _data_dbSession:THI_Event;
    _data_Text:THI_Event;
    _event_onError:THI_Event;
    _event_onColumns:THI_Event;
    _event_onQuery:THI_Event;

    destructor Destroy; override;
    procedure _work_doQuery(var _Data:TData; Index:word);
    procedure _work_doExec(var _Data:TData; Index:word);
  end;

implementation

uses windows,hiOLEdb_Session;

function SqlDateTimeStampToDateTime( TS: PSqlDateTimeStamp ):TDateTime;
var ST: TSystemTime;
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

destructor THIOLEdb_Query.Destroy;
begin
   qr.free;
   inherited;
end;

procedure THIOLEdb_Query._onDestroy;
begin
   qr := nil;
end;

procedure THIOLEdb_Query._onError;
begin
   _err := true;
   _hi_onEvent(_event_onError, integer(Result));
end;

procedure THIOLEdb_Query._work_doQuery;
label ERROR;
var dt,ndt:TData;
    ss:PSession;
    i:integer;
    s:PData;
    _date:PSqlDateTimeStamp;    
    st:PStream;
begin
   _err := false;
   dt := ReadData(_Data,_data_dbSession);
   if not _isObject(dt, OleSessionGUID) then 
     begin
       _hi_onEvent(_event_onError, 1);
       exit;
     end;
   ss := PSession(ToObject(dt));
   qr := NewQuery(ss, _onError);
   qr.onDestroy := _onDestroy;
   if _err then goto ERROR;       
   qr.Text := ReadString(_Data,_data_Text,_prop_Text);
   qr.Open;
   if _err then goto ERROR;
   if qr.ColCount > 0 then 
    begin 
      dtNull(dt);
      for i := 0 to qr.ColCount-1 do 
       begin
         dtString(ndt,qr.ColNames[i]); 
         AddMTData(@dt,@ndt,s);
       end;
      ndt := dt; 
      _hi_onEvent(_event_onColumns, dt);
      FreeData(@ndt);
        
      while not qr.EOF do 
       begin
         dtNull(dt);
         for i := 0 to qr.ColCount-1 do 
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
                  if st = nil then dtInteger(ndt, 0)
                  else dtStream(ndt, st);
               end;
             DBTYPE_DBTIMESTAMP: 
               begin
                  _date := QR.TSField[i];
                  if _date = nil then 
                       dtString(ndt, 'null') 
                  else dtString(ndt, DateTime2StrShort(SqlDateTimeStampToDateTime(_date)));
               end;
             else dtString(ndt, 'None: ' + int2str(qr.Bindings[i].wType));
            end; // case 
            AddMTData(@dt,@ndt,s);
          end; // for
         ndt := dt; 
         _hi_onEvent(_event_onQuery, dt);
         FreeData(@ndt);
         qr.Next;
      end;
   end;
ERROR:
   free_and_nil(qr);
end;

procedure THIOLEdb_Query._work_doExec;
var dt:TData;
    ss:PSession;
begin
   dt := Readdata(_Data,_data_dbSession);
   if (qr<>nil) or not _isObject(dt, OleSessionGUID) then exit;
   ss := PSession(ToObject(dt));
   qr := NewQuery(ss, _onError);
   qr.onDestroy := _onDestroy;
   qr.Text := ReadString(_Data,_data_Text,_prop_Text);
   qr.Execute;
   free_and_nil(qr);
end;

end.
