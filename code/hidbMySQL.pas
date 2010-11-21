unit hidbMySQL;

interface

uses Windows,Kol,Share,Debug,MySQL;

type
  THIdbMySQL = class(TDebug)
   private
    MySQL:TMySQL;
    procedure _OnError(Sender:TObject; Index:word);
   public
    _prop_Host:string;
    _prop_Login:string;
    _prop_Password:string;
    _prop_DBName:string;
    _prop_Charset:byte;

    _event_onError:THI_Event;
    _data_DBName:THI_Event;
    _data_Password:THI_Event;
    _data_Login:THI_Event;
    _data_Host:THI_Event;

    destructor Destroy; override;
    procedure _work_doOpen(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _work_doSelectDB(var _Data:TData; Index:word);
    procedure _work_doCharset(var _Data:TData; Index:word);
    procedure _var_dbHandle(var _Data:TData; Index:word);
    procedure _var_Charset(var _Data:TData; Index:word);
  end;

var MySQL_GUID:integer;

implementation

destructor THIdbMySQL.Destroy;
var dt:TData;
begin
   _work_doClose(dt,0);
   inherited;
end;

procedure THIdbMySQL._work_doOpen;
var Host,Login,Pass,Charset:string;
begin
   if not Assigned(MySQL) then
    begin
      MySQL := TMySQL.Create;
      MySQL.OnError := _OnError;
      MySQL.Init;
    end;

   Host := ReadString(_Data,_data_Host,_prop_Host);
   Login := ReadString(_Data,_data_Login,_prop_Login);
   Pass := ReadString(_Data,_data_Password,_prop_Password);
   MySQL.Connect(Host,Login,Pass);

   case _prop_Charset of
    0: ;
    1: Charset := 'ascii';
    2: Charset := 'cp1251';
    3: Charset := 'latin1';
    4: Charset := 'ucs2';
    5: Charset := 'utf8';
   end;
   if _prop_Charset <> 0 then MySQL.SetCharset(Charset);
end;

procedure THIdbMySQL._OnError;
begin
   _hi_OnEvent(_event_onError,integer(Index));
end;

procedure THIdbMySQL._work_doClose;
begin
   if Assigned(MySql) then
    begin
     MySQL.Close;
     MySQL.Destroy;
     MySQL := nil;
    end;
end;

procedure THIdbMySQL._work_doSelectDB;
begin
   mysql.SelectDB(readstring(_Data,_data_DBName,_prop_DBName));
end;

procedure THIdbMySQL._work_doCharset;
begin
   MySQL.SetCharset(ToString(_Data));
end;

procedure THIdbMySQL._var_dbHandle;
begin
   if MySQL <> nil then
    begin
     GenGUID(MySQL_GUID);
     dtObject(_Data,MySQL_GUID,MySQL);
    end
   else dtNull(_Data);
end;

procedure THIdbMySQL._var_Charset;
begin
   if MySQL <> nil then
     dtString(_Data,MySQL.CharsetName)
   else dtNull(_Data);
end;

end.
