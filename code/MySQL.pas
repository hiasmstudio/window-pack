unit MySQL;

interface

uses KOL,mysqllib;

const
 err_init = 1;
 err_connect = 2;
 err_query = 3;
 err_store = 4;
 err_execute = 5;

type
  TMySQL = class
    private
     FHandle:PMYSQL;
     ms:PMYSQL_RES;
     Lengths: PLongInt;
     rw:TInt64;
     row:PMYSQL_ROW;
	 FBlobSize:LongInt;

     procedure Error(Index:word);
     function GetRecordCount:integer;
     function GetFieldCount:integer;
     function GetValues(Index:integer):string;
     function GetFields(Index:integer):string;
     function GetBlob(Index:integer):PMYSQL_ROW;
     function GetCharset:string;
     function StrPas(const Str: PChar): string; 
    public
     OnError:procedure(Sender:TObject; Index:word) of object;

     constructor Create;
     procedure Init;
     procedure Connect(const Host,Login,Passwd:string);
     procedure SelectDB(const DBName:string);
     procedure SetCharset(const CSname:string);
     procedure Close;
     procedure Query(const text:string);
     procedure FindFirst;
     procedure FindNext;
     function Execute(const text:string):Integer;
	 function BlobToString(const p:Pointer;size:Integer):string;
     property CharsetName:string read GetCharset;
     property RecordCount:integer read GetRecordCount;
     property FieldCount:integer read GetFieldCount;
     property Values[index:integer]:string read GetValues;
     property Fields[index:integer]:string read GetFields;
     property Blob[index:integer]:PMYSQL_ROW read GetBlob;
     property BlobSize:LongInt read FBlobSize;
 
  end;

implementation

constructor TMySQL.Create;
begin
   inherited;
end;

procedure TMySQL.Error;
begin
   if AssigneD(onerror) then
    OnError(Self,Index);
end;

procedure TMySQL.Init;
begin
   mysql_load_dll;
end;

procedure TMySQL.Connect;
begin
   FHandle := mysql_init(nil);
   if FHandle = nil then
    Error(err_init)
   else if Assigned(mysql_connect) then begin
    if mysql_connect(FHandle,PChar(Host),PChar(Login),PChar(Passwd)) = nil then
      Error(err_connect);
   end else if Assigned(mysql_real_connect) then begin
    if mysql_real_connect(FHandle,PChar(Host),PChar(Login),PChar(Passwd),nil,0,nil,0) = nil then
      Error(err_connect);
   end else
    Error(err_connect);
end;

procedure TMySQL.SelectDB;
begin
   mysql_select_db(FHandle,PChar(DBName));
end;

procedure TMySQL.SetCharset;
begin
   if FHandle <> nil then mysql_set_character_set(FHandle,PChar(CSname));
end;

procedure TMySQL.Close;
begin
   if FHandle <> nil then
    begin
	 if ms <> nil then mysql_free_result(ms);
     mysql_close(FHandle);
     FHandle := nil;
    end;
end;

procedure TMySQL.Query;
begin
   if ms <> nil then
    begin
	 mysql_free_result(ms);
     ms := nil;
	end;
   if mysql_query(FHandle,PChar(text)) = -1 then
     Error(err_Query)
   else
    begin
     ms := mysql_store_result(FHandle);
     if ms <> nil then
       FindFirst
     else Error(err_store);
    end;
end;

function TMySQL.Execute;
begin
   if mysql_real_query(FHandle,PChar(text),length(text)) = -1 then
     Error(err_execute)
   else
     Result := mysql_affected_rows(FHandle);
end;

procedure TMySQL.FindFirst;
begin
   rw.Data := 0;
   rw.Pad := 0;
   row := nil;
   Lengths := nil;
   FindNext;
end;

procedure TMySQL.FindNext;
begin
   if ms <> nil then
    begin
     mysql_data_seek(ms,rw);
     row := mysql_fetch_row(ms);
     Lengths := mysql_fetch_lengths(ms);
     inc(rw.Data);
    end;
end;

function TMySQL.StrPas; 
begin 
   Result := Str; 
end;

function TMySQL.BlobToString;
var
  temp: String;
  newSize: Integer;
begin
  SetLength(temp, size*2+1);
  newSize := mysql_real_escape_string(FHandle, PChar(@temp[1]), PChar(p), size);
  SetLength(temp, newSize);
  Result := StrPas(PChar(temp));
end;

function TMySQL.GetValues;
type TLen = array[0..0] of LongInt;
     TRow = array[0..0] of PChar;
var
    Length: LongInt;
begin
   if Lengths <> nil then
     Length  := TLen(Lengths^)[Index]
   else Length := 0;
   if Row = nil then
     Result := ''
   else Result := copy(TRow(Row^)[Index],1,Length);
end;

function TMySQL.GetFields;
var fld:PMYSQL_FIELD;
begin
   if ms = nil then
    Result := ''
   else
    begin
     mysql_field_seek(ms,index);
     fld := mysql_fetch_field(ms);
     Result := fld.name;
    end;
end;

function TMySQL.GetBlob;
type TLen = array[0..0] of LongInt;
     TRow = array[0..0] of PChar;
begin
   if ms = nil then
    Result := nil
   else
    begin
     if row = nil then
      Result := nil
     else
      begin
	   if Lengths <> nil then
        FBlobSize  := TLen(Lengths^)[Index]
	   else FBlobSize := 0;
	   Result := TRow(Row^)[Index];
	  end;
	end;
end;

function TMySQL.GetCharset;
begin
   if FHandle = nil then
     Result := ''
   else Result := StrPas(mysql_character_set_name(FHandle));
end;

function TMySQL.GetRecordCount;
begin
   if ms = nil then
     Result := 0
   else Result := mysql_num_rows(ms);
end;

function TMySQL.GetFieldCount;
begin
   if ms = nil then
     Result := 0
   else Result := mysql_num_fields(ms);
end;

end.
