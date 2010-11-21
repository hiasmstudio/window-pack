unit mysqllib;

interface

const
  MYSQL_PORT = 3306;
  LOCAL_HOST = 'localhost';

type
  PLongInt = ^integer;
  TBool = Byte;
  TInt64 = packed record
    Data: LongInt;
    Pad: LongInt;
  end;
  mysql_status = (
    MYSQL_STATUS_READY,
    MYSQL_STATUS_GET_RESULT,
    MYSQL_STATUS_USE_RESULT
  );
  MYSQL_FIELD = record
    name:       PChar;
    table:      PChar;
    def:        PChar;
    _type:      Byte;
    length:     Integer;
    max_length: Integer;
    flags:      Integer;
    decimals:   Integer;
  end;
  PMYSQL_FIELD = ^MYSQL_FIELD;

  PMYSQL = pointer;
  PMYSQL_ROW = pointer;
  PMYSQL_ROWS = pointer;
  PMYSQL_DATA = pointer;
  PMYSQL_RES = pointer;
  MYSQL_FIELD_OFFSET = cardinal;
  MYSQL_ROW_OFFSET = PMYSQL_ROWS;

 Tmysql_close = procedure(Handle: PMYSQL); stdcall;
 Tmysql_query = function(Handle: PMYSQL; const Query: PChar):Integer; stdcall;
 Tmysql_connect = function(Handle: PMYSQL; const Host, User, Passwd: PChar):PMYSQL; stdcall;
 Tmysql_real_connect = function(Handle: PMYSQL; const Host, User, Passwd, DBName: PChar; Port:integer; unix_socket:PChar; client_flag:cardinal):PMYSQL; stdcall;
 Tmysql_init = function(Handle: PMYSQL):PMYSQL; stdcall;
 Tmysql_select_db = function(Handle: PMYSQL; const Db: PChar):Integer; stdcall;
 Tmysql_store_result = function(Handle: PMYSQL):PMYSQL_RES; stdcall;
 Tmysql_fetch_row = function(Result: PMYSQL_RES):PMYSQL_ROW; stdcall;
 Tmysql_fetch_lengths = function(Result: PMYSQL_RES):PLongInt; stdcall;
 Tmysql_fetch_field = function(Result: PMYSQL_RES):PMYSQL_FIELD; stdcall;
 Tmysql_field_seek = function(Result: PMYSQL_RES; Offset: MYSQL_FIELD_OFFSET):MYSQL_FIELD_OFFSET; stdcall;
 Tmysql_row_seek = function(Result: PMYSQL_RES; Row: MYSQL_ROW_OFFSET):MYSQL_ROW_OFFSET; stdcall;
 Tmysql_data_seek = procedure(Result: PMYSQL_RES; Offset: TInt64);stdcall;
 Tmysql_num_fields = function(Result: PMYSQL_RES): Integer; stdcall;
 Tmysql_num_rows = function(Result: PMYSQL_RES): Integer; stdcall;
 Tmysql_real_query = function(Handle: PMYSQL; const Query: PChar; length: Integer): Integer; stdcall;
 Tmysql_affected_rows = function(Handle: PMYSQL): Integer; stdcall;
 Tmysql_free_result = procedure(Result: PMYSQL_RES); stdcall;
 Tmysql_real_escape_string = function(Handle: PMYSQL; ato: PChar; from: PChar; from_length: Integer): Integer; stdcall;
 Tmysql_set_character_set = function(Handle: PMYSQL;csname: PChar): Integer; stdcall;
 Tmysql_character_set_name = function(Handle: PMYSQL): PChar; stdcall;

var
  mysql_close:          Tmysql_close;
  mysql_query:          Tmysql_query;
  mysql_connect:        Tmysql_connect;
  mysql_real_connect:   Tmysql_real_connect;
  mysql_init:           Tmysql_init;
  mysql_select_db:      Tmysql_select_db;
  mysql_store_result:   Tmysql_store_result;
  mysql_fetch_row:      Tmysql_fetch_row;
  mysql_fetch_lengths:  Tmysql_fetch_lengths;
  mysql_fetch_field:    Tmysql_fetch_field;
  mysql_field_seek:     Tmysql_field_seek;
  mysql_row_seek:       Tmysql_row_seek;
  mysql_data_seek:      Tmysql_data_seek;
  mysql_num_fields:     Tmysql_num_fields;
  mysql_num_rows:       Tmysql_num_rows;
  mysql_real_query:     Tmysql_real_query;
  mysql_affected_rows:  Tmysql_affected_rows;
  mysql_free_result:    Tmysql_free_result;
  mysql_real_escape_string: Tmysql_real_escape_string;
  mysql_set_character_set:  Tmysql_set_character_set;
  mysql_character_set_name: Tmysql_character_set_name;
  
procedure mysql_load_dll;

implementation

uses Windows;

var
  hDLL:cardinal;

procedure mysql_load_dll;
begin
   if hDLL <> 0 then exit;
   
   hDLL := LoadLibrary('libmysql.dll');
   mysql_close         := GetProcAddress(hDLL,'mysql_close');
   mysql_query         := GetProcAddress(hDLL,'mysql_query');
   mysql_connect       := GetProcAddress(hDLL,'mysql_connect');
   mysql_real_connect  := GetProcAddress(hDLL,'mysql_real_connect');
   mysql_init          := GetProcAddress(hDLL,'mysql_init');
   mysql_select_db     := GetProcAddress(hDLL,'mysql_select_db');
   mysql_store_result  := GetProcAddress(hDLL,'mysql_store_result');
   mysql_fetch_row     := GetProcAddress(hDLL,'mysql_fetch_row');
   mysql_fetch_lengths := GetProcAddress(hDLL,'mysql_fetch_lengths');
   mysql_fetch_field   := GetProcAddress(hDLL,'mysql_fetch_field');
   mysql_field_seek    := GetProcAddress(hDLL,'mysql_field_seek');
   mysql_row_seek      := GetProcAddress(hDLL,'mysql_row_seek');
   mysql_data_seek     := GetProcAddress(hDLL,'mysql_data_seek');
   mysql_num_fields    := GetProcAddress(hDLL,'mysql_num_fields');
   mysql_num_rows      := GetProcAddress(hDLL,'mysql_num_rows');
   mysql_real_query    := GetProcAddress(hDLL,'mysql_real_query');
   mysql_affected_rows := GetProcAddress(hDLL,'mysql_affected_rows');
   mysql_free_result   := GetProcAddress(hDLL,'mysql_free_result');
   mysql_real_escape_string := GetProcAddress(hDLL,'mysql_real_escape_string');
   mysql_set_character_set  := GetProcAddress(hDLL,'mysql_set_character_set');
   mysql_character_set_name := GetProcAddress(hDLL,'mysql_character_set_name');
end;

end.
