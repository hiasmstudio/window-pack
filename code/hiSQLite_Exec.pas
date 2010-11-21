unit hiSQLite_Exec;

interface

uses Kol,Share,Debug,SqLite3Api;

type
  THISQLite_Exec = class(TDebug)
   private
   public
    _prop_SQL:string;
    _data_dbHandle:THI_Event;
    _data_SQL:THI_Event;
    _event_onError:THI_Event;

    procedure _work_doExec(var _Data:TData; Index:word);
  end;

implementation

uses hiSQLite_DB;

function callback(user:pointer; ncols:integer; values:ppchar; names:ppchar):integer; cdecl;
begin
   Result := 0;
end;

procedure THISQLite_Exec._work_doExec;
var dt:TData;
    mes:PChar;
    s:string;
begin
  dt := ReadData(_Data,_data_dbHandle,nil);
  if _IsObject(dt,SQLite_GUID) then begin
    s := ReadString(_Data,_data_SQL,_prop_SQL);
    sqlite3_exec(ToObject(dt),PChar(s), callback, nil, @mes);
    if mes <> '' then
      _hi_CreateEvent(_Data,@_event_onError, string(mes));
  end;
end;

end.
