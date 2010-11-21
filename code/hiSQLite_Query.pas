unit hiSQLite_Query;

interface

uses Kol,Share,Debug,SqLite3Api;

type
  THISQLite_Query = class(TDebug)
   private
    cok:boolean;
   public
    _prop_SQL:string;
    _data_dbHandle:THI_Event;
    _data_SQL:THI_Event;
    _event_onQuery:THI_Event;
    _event_onColumns:THI_Event;
    _event_onError:THI_Event;

    procedure _work_doQuery(var _Data:TData; Index:word);
    procedure _var_LastRowID(var _Data:TData; Index:word);
  end;

implementation

uses hiSQLite_DB;

type arr = array[0..0] of PChar; parr = ^arr;

function callback(user:pointer; ncols:integer; values:ppchar; names:ppchar):integer; cdecl;
var dt,ndt:TData;
    s:PData;
    i:integer; 
begin
   if not THISQLite_Query(user).cok then
    begin
     dtNull(dt);
     for i := 0 to ncols-1 do
      begin
       dtString(ndt,string(parr(names)[i])); 
       AddMTData(@dt,@ndt,s);
      end;
     ndt := dt;
     _hi_onEvent_(THISQLite_Query(user)._event_onColumns, dt);
     FreeData(@ndt);
     THISQLite_Query(user).cok := true;
    end;
   dtNull(dt);
   for i := 0 to ncols-1 do
    begin
     dtString(ndt,string(parr(values)[i])); 
     AddMTData(@dt,@ndt,s);
    end;
   ndt := dt; 
   _hi_onEvent_(THISQLite_Query(user)._event_onQuery, dt);
   FreeData(@ndt);
   Result := 0;
end;

procedure THISQLite_Query._work_doQuery;
var dt:TData;
    id:pointer;
    mes:PChar;
    s:string;
begin
   dt := ReadData(_Data,_data_dbHandle,nil);
   s := ReadString(_Data,_data_SQL,_prop_SQL); 
   id := ToObject(dt);
   if _IsObject(dt,SQLite_GUID) then
    begin
      cok := false;
      sqlite3_exec(id,PChar(s), callback, self, @mes);
      if mes <> '' then
        _hi_onEvent(_event_onError, string(mes));
    end;
end;

procedure THISQLite_Query._var_LastRowID;
var dt:TData;
    id:pointer;
begin
   dt := ReadData(_Data,_data_dbHandle,nil);
   id := ToObject(dt);
   if _IsObject(dt,SQLite_GUID) then
    begin
       dtInteger(_Data,integer(sqlite3_last_insert_rowid(id)));
    end;
end;

end.
