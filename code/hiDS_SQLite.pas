unit hiDS_SQLite;

interface

uses Windows, Kol, Share, Debug, SqLite3Api, DS_client;

const
  NO_OPEN_DB = 'No open database';

type

  THIDS_SQLite = class(TDebug)
  private
    id: pointer;
    ds: TIDataSource;
    procedure Close;
    procedure MakeData(var Data:TData; r:pointer; col:integer);
    function  procexec(const SQL: string): TData;
    function  procquery(const SQL: string; callBackFields: TCallBackFields; callBackData: TCallBackData): TData;
    function  procqueryscalar(const SQL: string; var Data: TData): TData;
  public
    _prop_Name:string;
    _prop_FileName:string;
    _prop_WaitClose:boolean;    

    _data_FileName:THI_Event;
    _event_onOpen:THI_Event;
    _event_onClose:THI_Event;    
    _event_onError:THI_Event;

    constructor Create;
    function getInterfaceDataSource: IDataSource;
    procedure _work_doOpen(var _Data: TData; Index: word);
    procedure _work_doClose(var _Data: TData; Index: word);
  end;
  
implementation

uses hiCharset;

//------------------------- Функции обратного вызова ---------------------------

function execproccallback(user:pointer; ncols:integer; values:ppchar; names:ppchar):integer; cdecl;
begin
  Result := 0;
end;

//------------------------------------------------------------------------------

function THIDS_SQLite.getInterfaceDataSource;
begin
  Result := @ds;
end;

constructor THIDS_SQLite.Create;
begin
  inherited;
  ds.procexec := procexec;
  ds.procqueryscalar := procqueryscalar;
  ds.procquery := procquery;
end; 

procedure THIDS_SQLite._work_doOpen;
begin
  if checkSqliteLoaded then
  begin
    Close;
    sqlite3_open(PChar(CodePage1ToCodePage2(ReadString(_Data,_data_FileName, _prop_FileName), CP_ACP, CP_UTF8)), id);
    if id <> nil then
      _hi_CreateEvent(_Data, @_event_onOpen)
    else  
      _hi_CreateEvent(_Data, @_event_onError);
  end;
end;

procedure THIDS_SQLite._work_doClose;
begin
  Close;
  _hi_CreateEvent(_Data, @_event_onClose); 
end;

procedure THIDS_SQLite.Close;
begin
  if id = nil then exit;
  while (sqlite3_close(id) <> SQLITE_OK) and _prop_WaitClose do
    sleep(10);
  id := nil;
end;

procedure THIDS_SQLite.MakeData(var Data:TData; r:pointer; col:integer);
begin
    case sqlite3_column_type(r, col) of
      SQLITE_INTEGER: dtInteger(Data, sqlite3_column_int(r, col));
      SQLITE_FLOAT: dtReal(Data, sqlite3_column_double(r, col));
      else
         dtString(Data, sqlite3_column_text(r, col)); 
    end;
end;

function THIDS_SQLite.procexec;
var
  mes: PChar;
begin
  if id = nil then
    begin
      dtString(Result, NO_OPEN_DB);
      exit;
    end; 
  dtNull(Result);
  sqlite3_exec(id, PChar(SQL), execproccallback, nil, @mes);
  if mes <> '' then
    dtString(Result, string(mes));
end;

function THIDS_SQLite.procqueryscalar;
var
  mes: PChar;
  r:pointer;
begin
  if id = nil then
    begin
      dtString(Result, NO_OPEN_DB);
      exit;
    end;
  mes := '';
  r := nil;
  sqlite3_prepare(id, PChar(SQL), -1, r, mes);
  if r = nil then
    begin
      dtString(Result, sqlite3_errmsg(id));
      exit;
    end; 
  sqlite3_step(r);
  if sqlite3_data_count(r) = 0 then
    dtNull(Data)
  else
    MakeData(Data, r, 0);
  sqlite3_finalize(r);
  dtNull(Result);
end;

function THIDS_SQLite.procquery;
label error;
var
  mes: PChar;
  r:pointer;
  i,c:integer;
  list: PStrList;
  dt,ndt: TData;
  s: PData;
begin
  if id = nil then
    begin
      dtString(Result, NO_OPEN_DB);
      exit;
    end;
  mes := '';
  r := nil;
  sqlite3_prepare(id, PChar(SQL), -1, r, mes);
  if r = nil then
    begin
      dtString(Result, sqlite3_errmsg(id));
      exit;
    end; 

  c := sqlite3_column_count(r); 
  if assigned(callBackFields) then
    begin
      list := NewStrList;
      for i := 0 to c-1 do
         list.add(sqlite3_column_name(r, i));
      callBackFields(list);
      list.free;
    end;
 
  sqlite3_step(r);
  while sqlite3_data_count(r) > 0 do
    begin 
      dtNull(dt);
      for i := 0 to c-1 do
        begin
          MakeData(ndt, r, i);
          AddMTData(@dt, @ndt, s);
        end;
      ndt := dt; 
      callBackData(dt);
      FreeData(@ndt);
      sqlite3_step(r);
    end;
  sqlite3_finalize(r);
  dtNull(Result);
end;

end.