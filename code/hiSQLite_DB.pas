unit hiSQLite_DB;

interface

uses Windows,Kol,Share,Debug,SqLite3Api;

type
  THISQLite_DB = class(TDebug)
   private
    id:pointer;
    procedure Close;
   public
    _prop_FileName:string;
    _prop_WaitClose:boolean;    

    _data_FileName:THI_Event;
    _event_onOpen:THI_Event;
    _event_onError:THI_Event;

    procedure _work_doOpen(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _var_dbHandle(var _Data:TData; Index:word);
  end;
  
var SQLite_GUID:integer;

implementation

uses hiCharset;

procedure THISQLite_DB._work_doOpen;
begin
  if checkSqliteLoaded then
  begin
    Close;
    sqlite3_open(PChar(CodePage1ToCodePage2(ReadString(_Data,_data_FileName, _prop_FileName), CP_ACP, CP_UTF8)), id);
    if id <> nil then
    begin
      GenGUID(SQLite_GUID);
      dtObject(_Data, SQLite_GUID, id);
      _hi_CreateEvent_(_Data, @_event_onOpen);
    end;
  end;
end;

procedure THISQLite_DB._work_doClose;
begin
  Close;
end;

procedure THISQLite_DB.Close;
begin
  if id = nil then exit;
  while (sqlite3_close(id) <> SQLITE_OK) and _prop_WaitClose do
    sleep(10);
  id := nil;   
end;

procedure THISQLite_DB._var_dbHandle;
begin
  if id <> nil then
    dtObject(_Data, SQLite_GUID, id)
  else
    dtNull(_Data);
end;

end.