unit hiSQLite_QueryScalar;

interface

uses Kol,Share,Debug,SqLite3Api;

type
  THISQLite_QueryScalar = class(TDebug)
   private
    FResult:string; 
   public
    _prop_SQL:string;

    _data_SQL:THI_Event;
    _data_dbHandle:THI_Event;
    _event_onError:THI_Event;
    _event_onQuery:THI_Event;

    procedure _work_doQuery(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

uses hiSQLite_DB;

type arr = array[0..0] of PChar; parr = ^arr;

function callback(user:pointer; ncols:integer; values:ppchar; names:ppchar):integer; cdecl;
begin
   THISQLite_QueryScalar(user).FResult := string(parr(values)[0]); 
   Result := 0;
end;
       
procedure THISQLite_QueryScalar._work_doQuery;
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
      FResult := '';
      sqlite3_exec(id,PChar(s), callback, self, @mes);
      if mes <> '' then
        _hi_onEvent(_event_onError, string(mes))
      else
        _hi_onEvent(_event_onQuery, FResult);
    end;
end;

procedure THISQLite_QueryScalar._var_Result;
begin
   dtString(_Data, FResult);
end;

end.
