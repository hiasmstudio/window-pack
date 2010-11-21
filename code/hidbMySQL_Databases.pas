unit hidbMySQL_Databases;

interface

uses Kol,Share,Debug,MySQL;

type
  THIdbMySQL_Databases = class(TDebug)
   private
   public
    _data_DBName:THI_Event;
    _data_dbHandle:THI_Event;
    _event_onError:THI_Event;
    _event_onEnum:THI_Event;

    procedure _work_doEnum(var _Data:TData; Index:word);
    procedure _work_doEmpty(var _Data:TData; Index:word);
    procedure _work_doDrop(var _Data:TData; Index:word);
  end;

implementation

uses hidbMySql;

procedure THIdbMySQL_Databases._work_doEnum;
var
   My:TMySQL;
   dt:TData;
   i:smallint;
begin
   dt := ReadData(_Data,_data_dbHandle,nil);
   if _IsObject(dt,MySQL_GUID) then
    begin
     My := TMySQL(ToObject(dt));
     My.Query('show databases');
     for i := 0 to my.RecordCount - 1 do
      begin
        _hi_OnEvent(_event_onEnum,my.Values[0]);
        my.FindNext;
      end;
    end
   else _hi_OnEvent(_event_onError,0);
end;

procedure THIdbMySQL_Databases._work_doEmpty;
begin

end;

procedure THIdbMySQL_Databases._work_doDrop;
begin

end;

end.
