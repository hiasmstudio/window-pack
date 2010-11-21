unit hiDS_MySQL;

interface

uses Kol,Share,Debug,DS_client,mysqllib;

type
  THIDS_MySQL = class(TDebug)
   private
    id: PMYSQL;
    ds: TIDataSource;

    procedure MakeData(var Data:TData; row, lengths:pointer; index:integer);
    procedure Close;
    procedure Error(index:integer);
    function  procexec(const SQL: string): TData;
    function  procquery(const SQL: string; callBackFields: TCallBackFields; callBackData: TCallBackData): TData;
    function  procqueryscalar(const SQL: string; var Data: TData): TData;
   public
    _prop_Name:string;
    _prop_Server:string;
    _prop_Username:string;
    _prop_Password:string;
    _prop_DBName:string;

    _data_Password:THI_Event;
    _data_Username:THI_Event;
    _data_Server:THI_Event;
    _event_onError:THI_Event;
    _event_onOpen:THI_Event;

    constructor Create;
    destructor Destroy; override;
    function getInterfaceDataSource: IDataSource;
    procedure _work_doOpen(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _work_doSelectDB(var _Data:TData; Index:word);
  end;

implementation

const
  err_init = 1;
  err_connect = 2;
  err_query = 3;
  err_store = 4;
  err_execute = 5;

function THIDS_MySQL.getInterfaceDataSource;
begin
  Result := @ds;
end;

constructor THIDS_MySQL.Create;
begin
   inherited;
   
   ds.procexec := procexec;
   ds.procqueryscalar := procqueryscalar;
   ds.procquery := procquery;
end; 

destructor THIDS_MySQL.Destroy;
begin
   Close;
   
   inherited;
end;

procedure THIDS_MySQL.Close;
begin
   if id <> nil then
    begin
      mysql_close(id);
      id := nil;
    end;
end;

procedure THIDS_MySQL.Error;
begin
  _hi_onEvent(_event_onError, index);
end;

function  THIDS_MySQL.procexec(const SQL: string): TData;
begin
   if mysql_real_query(id,PChar(SQL),length(SQL)) = -1 then
     begin
       Error(err_execute);
       dtInteger(Result, err_execute); 
     end
   else
     begin
       mysql_affected_rows(id);
       dtNull(Result);
     end;
end;

procedure THIDS_MySQL.MakeData;
type TLen = array[0..0] of LongInt;
     TRow = array[0..0] of PChar;
var
    Length: LongInt;
begin
   if Lengths <> nil then
     Length  := TLen(Lengths^)[Index]
   else Length := 0;
   if Row = nil then
     dtString(Data, '')
   else dtString(Data, copy(TRow(Row^)[Index],1,Length));
end;

function  THIDS_MySQL.procquery(const SQL: string; callBackFields: TCallBackFields; callBackData: TCallBackData): TData;
var list:PStrList;
    fld:PMYSQL_FIELD;
    Lengths: PLongInt;
    rw:TInt64;
    row:PMYSQL_ROW;
    ms:PMYSQL_RES;
    i:integer;
    dt,ndt: TData;
    s: PData;
begin
   dtNull(Result);
   if mysql_query(id,PChar(SQL)) = -1 then
     Error(err_Query)
   else
    begin
      ms := mysql_store_result(id);
      if ms <> nil then
        begin
          if Assigned(callBackFields) then
            begin
              list := NewStrList;
              for i := 0 to mysql_num_fields(ms)-1 do
                begin
                  mysql_field_seek(ms,i);
                  fld := mysql_fetch_field(ms);
                  list.add(fld.name);
                end;
              callBackFields(list);
              list.free;            
            end;
            
          if Assigned(callBackData) then
            begin
              row := mysql_fetch_row(ms);
              while row <> nil do
                begin 
                  Lengths := mysql_fetch_lengths(ms);
                  dtNull(dt);
                  for i := 0 to mysql_num_fields(ms)-1 do
                    begin
                      MakeData(ndt, row, Lengths, i);
                      AddMTData(@dt, @ndt, s);
                    end;
                  ndt := dt; 
                  callBackData(dt);
                  FreeData(@ndt);
                  row := mysql_fetch_row(ms);
                end;
              dtNull(Result);
            end;
            
          mysql_free_result(ms);    
        end
      else Error(err_store);
    end;
end;

function  THIDS_MySQL.procqueryscalar(const SQL: string; var Data: TData): TData;
var
    ms:PMYSQL_RES;
begin
   dtNull(Result);
   if mysql_query(id,PChar(SQL)) = -1 then
     Error(err_Query)
   else
    begin
      ms := mysql_store_result(id);
      if ms <> nil then
        begin
          if mysql_num_rows(ms) > 0 then
            MakeData(Data, mysql_fetch_row(ms), mysql_fetch_lengths(ms), 0)
          else dtNull(Data);
          mysql_free_result(ms);    
        end
      else Error(err_store);
    end;
end;

procedure THIDS_MySQL._work_doOpen;
var Host,Login,Passwd:string;
    err:integer;
begin
   Host := ReadString(_Data,_data_Server,_prop_Server);
   Login := ReadString(_Data,_data_Username,_prop_Username);
   Passwd := ReadString(_Data,_data_Password,_prop_Password);
   
   mysql_load_dll();
    
   id := mysql_init(nil);
   err := 0;
   if id = nil then
      err := err_init
   else if Assigned(mysql_connect) then 
     begin
       if mysql_connect(id,PChar(Host),PChar(Login),PChar(Passwd)) = nil then
         err := err_connect
     end
   else if Assigned(mysql_real_connect) then
     begin
       if mysql_real_connect(id,PChar(Host),PChar(Login),PChar(Passwd),nil,0,nil,0) = nil then
         err := err_connect
     end
   else
     err := err_connect;
  
   if err > 0 then
     Error(err)
   else
     begin
       if _prop_DBName <> '' then mysql_select_db(id, PChar(_prop_DBName));   
       _hi_onEvent(_event_onOpen);
     end;
end;

procedure THIDS_MySQL._work_doClose;
begin
  Close;
end;

procedure THIDS_MySQL._work_doSelectDB;
begin
   mysql_select_db(id, PChar(ToString(_Data))); 
end;

end.
