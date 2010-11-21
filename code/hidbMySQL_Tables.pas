unit hidbMySQL_Tables;

interface

uses Kol,Share,Debug,MySQL;

type
  THIdbMySQL_Tables = class(TDebug)
   private
   public
    _prop_DBName:string;

    _data_TableName:THI_Event;
    _data_DBName:THI_Event;
    _data_dbHandle:THI_Event;
    _event_onError:THI_Event;
    _event_onEnum:THI_Event;

    procedure _work_doEnum(var _Data:TData; Index:word);
    procedure _work_doDrop(var _Data:TData; Index:word);
    procedure _work_doEmpty(var _Data:TData; Index:word);
  end;

implementation

uses hidbMySql;

procedure THIdbMySQL_Tables._work_doEnum;
var
   My:TMySQL;
   dt:TData;
   i:smallint;
   db:string;
begin
   dt := ReadData(_Data,_data_dbHandle,nil);
   db := ReadString(_Data,_data_DBName,_prop_DBName);
   if _IsObject(dt,MySQL_GUID) then
    begin
     My := TMySQL(ToObject(dt));
     if db = '' then
       My.Query('show tables')
     else My.Query('show tables from ' + db);
     for i := 0 to my.RecordCount - 1 do
      begin
        _hi_OnEvent(_event_onEnum,my.Values[0]);
        my.FindNext;
      end;
    end
   else _hi_OnEvent(_event_onError,0);
end;

procedure THIdbMySQL_Tables._work_doDrop;
var
   My:TMySQL;
   dt:TData;
begin
   dt := ReadData(_Data,_data_dbHandle,nil);
   if _IsObject(dt,MySQL_GUID) then
    begin
     My := TMySQL(ToObject(dt));
     My.Execute('drop table ' + ReadString(_data,_data_TableName,''));
    end
   else _hi_OnEvent(_event_onError,0);
end;

procedure THIdbMySQL_Tables._work_doEmpty;
var
   My:TMySQL;
   dt:TData;
begin
   dt := ReadData(_Data,_data_dbHandle,nil);
   if _IsObject(dt,MySQL_GUID) then
    begin
     My := TMySQL(ToObject(dt));
     My.Execute('delete from ' + ReadString(_data,_data_TableName,''));
    end
   else _hi_OnEvent(_event_onError,0);
end;

end.
