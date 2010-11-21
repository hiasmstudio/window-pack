unit hiDS_ODBC;

interface

uses Windows, kol, Share, Debug, DS_client;

const
  ODBCCP32              = 'ODBCCP32.dll';
  ODBC32                = 'ODBC32.dll';
  ODBC_ADD_DSN          = 1;    // Добавляем источник данных
  ODBC_CONFIG_DSN       = 2;    // Конфигурируем (редактируем) источник данных
  ODBC_REMOVE_DSN       = 3;    // Удаляем источник данных
  ODBC_ADD_SYS_DSN      = 4;    // Добавляем системный DSN
  ODBC_CONFIG_SYS_DSN   = 5;    // Конфигурируем системный DSN
  ODBC_REMOVE_SYS_DSN   = 6;    // удаляем системный DSN
  SQL_ATTR_ODBC_VERSION = 200;
  SQL_DRIVER_NOPROMPT   = 0;    // For SQLDriverConnect
  SQL_OV_ODBC3          = 3;
  SQL_HANDLE_ENV        = 1;
  SQL_HANDLE_DBC        = 2;
  SQL_HANDLE_STMT       = 3;
  SQL_HANDLE_DESC       = 4;
  SQL_FETCH_NEXT        = 1;
  SQL_FETCH_FIRST       = 2;
  SQL_FETCH_LAST        = 3;
  SQL_FETCH_PRIOR       = 4;
  SQL_FETCH_ABSOLUTE    = 5;
  SQL_FETCH_RELATIVE    = 6;
  SQL_CP_ONE_PER_DRIVER = 1;
  SQL_CP_ONE_PER_HENV   = 2;
  SQL_ATTR_ASYNC_ENABLE = 4;
  SQL_ASYNC_ENABLE_OFF  = 0;
  SQL_NULL_DATA         = $FFFFFFFF;
  SQL_NTS               = -3;
  SQL_IS_INTEGER        = -6;
  SQL_SUCCESS           = 0;  // Функция выполнена успешно
  SQL_SUCCESS_WITH_INFO = 1;  // Функция выполнена успешно, но с уведомительным сообщением

  // if (ODBCVER >= 0x0300)
  SQL_NEED_DATA         =  99;// Для успешного выполнения данной функции следует
                              // предварительно определить необходимые данные
  SQL_NO_DATA           = 100;// Больше нет строк для извлечения их из результирующего набора.
                              // В предыдущей версии ODBC API этот код возврата обозначался как
                              // SQL_NO_DATA_FOUND.
                              // В версии 3.x код возврата SQL_NO_DATA_FOUND содержатся
                              // в заголовочном файле sqlext.h
  SQL_ERROR             = -1; // При выполнении функции произошла ошибка
  SQL_INVALID_HANDLE    = -2; // Указан неверный дескриптор
  SQL_STILL_EXECUTING   =  2; // Функция, выполняемая асинхронно, пока не завершена

  //  SQLBindParameter - fParamType
  //  SQLProcedureColumns - COLUMN_TYPE
  SQL_PARAM_TYPE_UNKNOWN=  0;
  SQL_PARAM_INPUT       =  1;
  SQL_PARAM_INPUT_OUTPUT=  2;
  SQL_RESULT_COL        =  3;
  SQL_PARAM_OUTPUT      =  4;
  SQL_RETURN_VALUE      =  5;
  SQL_DEFAULT_PARAM     = -5;
  SQL_IGNORE            = -6;

  // SQL Types
  // SQL type VALUE Maps to
  SQL_UNKNOWN_TYPE      =  0;
  SQL_LONGVARCHAR       =  -1; // text
  SQL_BINARY            =  -2; // binary
  SQL_VARBINARY         =  -3; // varbinary
  SQL_LONGVARBINARY     =  -4; // image
  SQL_BIGINT            =  -5; // bigint
  SQL_TINYINT           =  -6; // tinyint
  SQL_BIT               =  -7; // bit
  SQL_NCHAR             =  -8; // nchar
  SQL_NVARCHAR          =  -9; // nvarchar
  SQL_WLONGVARCHAR      = -10; // ntext
  SQL_UID               = -11; // uniqueidentifier
  SQL_CHAR              =   1; // char
  SQL_NUMERIC           =   2; // numeric
  SQL_DECIMAL           =   3; // decimal
  SQL_INTEGER           =   4; // integer
  SQL_SMALLINT          =   5; // smallint
  SQL_FLOAT             =   6; // float
  SQL_REAL              =   7; // real
  SQL_DOUBLE            =   8; // real
  SQL_DATE              =   9; // datetime
  SQL_TIME              =  10; // datetime
  SQL_TIMESTAMP         =  11; // datetime
  SQL_VARCHAR           =  12; // varchar
  SQL_TYPE_TIMESTAMP    =  93; // datetime
  SQL_WVARCHAR          = -96; // ?
  SQL_VARIANT           = -150;// sql_variant

  // API Types
  // API type VALUE Maps to (T-SQL)
  // Note:  For SQL_C_BINARY use an array of unsigned characters.
  // C++ programmers must use VT-UI1.
  SQL_C_BINARY          = -2; // Binary or varbinary
  SQL_C_TINYINT         = -6; // tinyint
  SQL_C_BIT             = -7; // bit
  SQL_C_CHAR            =  1; // char or varchar
  SQL_C_LONG            =  4; // int
  SQL_C_SHORT           =  5; // int
  SQL_C_FLOAT           =  7; // real
  SQL_C_DOUBLE          =  8; // float
  SQL_C_DATE            =  9; // datetime
  SQL_C_TIME            = 10; // datetime
  SQL_C_TIMESTAMP       = 11; // datetime
  SQL_C_DEFAULT         = 99; // autodefine type of field
  // The following table identifies API types
  // that are not supported by repository Automation.
  // You can only store and retrieve unsigned
  // integers. It is recommended that you not use these API types.
  // API Types - Not Supported
  // API type VALUE
  SQL_C_UTINYINT        = -28;
  SQL_C_STINYINT        = -26;
  SQL_C_ULONG           = -18;
  SQL_C_USHORT          = -17;
  SQL_C_SLONG           = -16;
  SQL_C_SSHORT          = -15;

const
  MAXBUFLEN = 1024;
  NOT_ERROR = -1; 

// Оисание кодов ошибок ErrorArr
// 1000 -- 'Не удалось создать среду ODBC'
// 1001 -- 'Не удалось указать версию ODBC 3.0'
// 1002 -- 'Не удалось создать соединение'
// 1003 -- 'Не удалось соединиться с БД'
// 1004 -- 'Не удалось создать запрос'
// 1005 -- 'Не удалось выполнить запрос'
// 1006 -- 'Не удалось получить поле'
// 1007 -- 'Ошибка получения следующего набора данных';
// 1008 -- 'Не удалось подготовить запрос'
// 1009 -- 'Не удалось выполнить связывание'
// 1010 -- 'Не удалось получить RowCount'
// 1011 -- 'Не удалось получить список'
// 1012 -- 'Не задано имя источника данных'
// 1013 -- 'Не задано имя файла Базы Данных'
// 1014 -- 'Не удалось загрузить ODBCCP32.DLL'
// 1015 -- 'Не удалось получить адрес функции SQLConfigDataSource';
// 1016 -- 'Ошибка при создании DSN'
// 1017 -- 'Не удалось загрузить набор данных'
// 1018 -- 'Запрос не вернул данных'

const
  ErrorArray: array[0..18] of integer = (1000, 1001, 1002, 1003, 1004,
                                         1005, 1006, 1007, 1008, 1009,
                                         1010, 1011, 1012, 1013, 1014,
                                         1015, 1016, 1017, 1018);

type
  SQLResult = Word;

  TFieldDescription = packed record
    DataType           : SmallInt;
    ColumnSize         : DWORD;
    DecimalDigits      : SmallInt;
    Nullable           : SmallInt;
    BindPtr            : Pointer;
    StrLenInd          : PInteger;
  end;
  PFieldDescription = ^TFieldDescription;

  TSqlDateTimeStamp = packed record
    Year, month, day, hour, minute, second: Word;
    fraction: DWORD; // 1/1000 000 000 sec
  end;
  PSqlDateTimeStamp = ^TSqlDateTimeStamp;

  TSQLConfigDataSource = function(hwndParent: THandle;
                                  fRequest: WORD;
                                  lpszDriver: PChar;
                                  lpszAttributes: PChar ) : BOOLEAN; stdcall;

  THIDS_ODBC = class( TDebug )
  protected
    fConnHandle: THandle;
    fEnvHandle: THandle;
  private
    dss: TIDataSource;
    booConnect: Boolean;

    procedure ODBC_Disconnect;
    function ODBC_Connect(strDBConnect: string): boolean;

    function  procexec(const SQL: string): TData;
    function  procquery(const SQL: string; callBackFields: TCallBackFields; callBackData: TCallBackData): TData;
    function  procqueryscalar(const SQL: string; var Data: TData): TData;
  public
    _prop_Name: string;
    _prop_Driver: string;
    _prop_Error: byte;
 
    _event_onError: THI_Event;
    _event_onCreate: THI_Event;

    _data_Data: THI_Event;
    _data_DSN_Name: THI_Event;
    _data_ConnectionDrv: THI_Event;
    _data_UserID: THI_Event;
    _data_Password: THI_Event;
    _data_Driver: THI_Event;
    _data_BinaryStream: THI_Event;
    _data_BrowseType: THI_Event;
    _data_FileDB: THI_Event;

    function getInterfaceDataSource: IDataSource;
    
    constructor Create;
    destructor Destroy; override;
    procedure _work_doOpen( var _Data:TData; Index:word );
    procedure _work_doClose( var _Data:TData; Index:word );
  end;

implementation

function SQLCloseCursor        (StatementHandle: THandle): SQLResult;
                                stdcall; external ODBC32 name 'SQLCloseCursor';
function SQLFetch              (StatementHandle: THandle): SQLResult;
                                stdcall; external ODBC32 name 'SQLFetch';
function SQLFetchScroll        (StatementHandle: THandle; FetchOrientation: SmallInt;FetchOffset: Integer): SQLResult;
                                stdcall; external ODBC32 name 'SQLFetchScroll';
function SQLDescribeCol        (StatementHandle: THandle;ColumnNumber: SmallInt;ColumnName: PChar;BufferLength: SmallInt;
                                NameLengthPtr: PSmallInt; DataTypePtr: PSmallInt; ColumnSizePtr: PDWORD;
                                DecimalDigitsPtr: PSmallInt; NullablePtr: PSmallInt): SQLResult;
                                stdcall; external ODBC32 name 'SQLDescribeCol';
function SQLNumResultCols      (StatementHandle: THandle; ColumnCountPtr: PSmallInt): SQLResult;
                                stdcall; external ODBC32 name 'SQLNumResultCols';
function SQLDriverConnect      (ConnectionHandle: THandle; WindowHandle: HWnd; InConnectionString: PChar;
                                StringLength1: SmallInt; OutConnectionString: PChar; BufferLength: SmallInt;
                                StringLength2Ptr: PSmallInt; DriverCompletion: Word): SQLResult;
                                stdcall; external ODBC32 name 'SQLDriverConnect';
function SQLGetData            (StatementHandle: THandle; ColumnNumber: SmallInt; TargetType: SmallInt; TargetValuePtr: Pointer;
                                BufferLength: Integer; StrLen_or_IndPtr: PInteger): SQLResult;
                                stdcall; external ODBC32 name 'SQLGetData';
function SQLFreeHandle         (HandleType: SmallInt; Handle: THandle): SQLResult;
                                stdcall; external ODBC32 name 'SQLFreeHandle';
function SQLExecDirect         (StatementHandle: THandle; StatementText: PChar;TextLength: Integer): SQLResult;
                                stdcall; external ODBC32 name 'SQLExecDirect';
function SQLDisconnect         (ConnectionHandle: THandle): SQLResult;
                                stdcall; external ODBC32 name 'SQLDisconnect';
function SQLSetEnvAttr         (EnvironmentHandle: THandle; Attribute: Integer; ValuePtr: Pointer;
                                StringLength: Integer): SQLResult;
                                stdcall; external ODBC32 name 'SQLSetEnvAttr';
function SQLAllocHandle        (HandleType: SmallInt; InputHandle: THandle; OutputHandlePtr: PHandle): SQLResult;
                                stdcall; external ODBC32 name 'SQLAllocHandle';

function SqlDateTimeStampToDateTime( TS: PSqlDateTimeStamp ): TDateTime;
var
  ST: TSystemTime;
begin
  ST.wYear := TS.Year;
  ST.wMonth := TS.month;
  ST.wDay := TS.day;
  ST.wHour := TS.hour;
  ST.wMinute := TS.minute;
  ST.wSecond := TS.second;
  ST.wMilliseconds := TS.fraction div 1000000;
  SystemTime2DateTime(ST, Result);
end;

function THIDS_ODBC.getInterfaceDataSource;
begin
  Result := @dss;
end;

constructor THIDS_ODBC.Create;
begin
  inherited Create;
  booConnect := false;
  dss.procexec := procexec;
  dss.procqueryscalar := procqueryscalar;
  dss.procquery := procquery;    
end;

destructor THIDS_ODBC.Destroy;
begin
  if booConnect then ODBC_Disconnect;
  inherited;
end;

function THIDS_ODBC.ODBC_Connect(strDBConnect: string): boolean;
var
  R: SQLResult;
  StrLenInd: SmallInt;
  BufferConnect: PChar;  
begin
  Result := false;
  R := SQLAllocHandle(SQL_HANDLE_ENV, 0, @fEnvHandle );
  if R > SQL_SUCCESS_WITH_INFO then
    _hi_onEvent(_event_onError, ErrorArray[0]) // 'Не удалось создать среду ODBC' 
  else
  begin
    R := SQLSetEnvAttr(fEnvHandle, SQL_ATTR_ODBC_VERSION,
                       Pointer(SQL_OV_ODBC3), SQL_IS_INTEGER);
    if R > SQL_SUCCESS_WITH_INFO then
      _hi_onEvent(_event_onError, ErrorArray[1]) // 'Не удалось указать версию ODBC 3.0'
    else
    begin
      R := SQLAllocHandle(SQL_HANDLE_DBC, fEnvHandle, @fConnHandle);
      if (R > SQL_SUCCESS_WITH_INFO) or (StrDBConnect = '') then
        _hi_onEvent(_event_onError, ErrorArray[2]) // 'Не удалось создать соединение'
      else
      begin
        BufferConnect := AllocMem(MAXBUFLEN);
        R := SQLDriverConnect(fConnHandle,              // Connection handle
                              0,                        // Window handle
                              PChar(StrDBConnect),      // Input connect string
                              Length(StrDBConnect),     // Null-terminated string
                              BufferConnect,            // Address of output buffer
                              MAXBUFLEN,                // Size of output buffer
                              @StrLenInd,               // Address of output length
                              SQL_DRIVER_NOPROMPT);
        FreeMem(BufferConnect);
        if R > SQL_SUCCESS_WITH_INFO then
          _hi_onEvent(_event_onError, ErrorArray[3]) // 'Не удалось соединиться с БД' )
        else
          Result := true;
      end; { If }
    end; { If }
  end; { If }
end;

procedure THIDS_ODBC._work_doOpen(var _Data:TData; Index:word);
begin
  if booConnect then ODBC_Disconnect;
  if not ODBC_Connect(ReadString(_Data, _data_Driver, _prop_Driver)) then exit;
  booConnect := true;
  _hi_onEvent(_event_onCreate);
end;

procedure THIDS_ODBC._work_doClose(var _Data:TData; Index:word);
begin
  if booConnect then ODBC_Disconnect;
end;

function FormatString(strField: string): string;
var
  i: Cardinal;
begin
  Result := '';
  i := Pos(Chr(0), strField);
  if i > 0 then
    Result := Copy(strField, 1, i - 1)
  else
    Result := strField;
end;

function GetData(fSession: THandle; FD: PFieldDescription; i: integer; var ndt: TData; scalar: boolean): Integer;
var
  BufferText: array[0..4095] of Char;
  ColName:    array[0..4095] of Char;
  R: SQLResult;
  s: string;
  ColLen: SmallInt;
  Buffer: PChar;
  BufferDouble: ^Double;
  BufferReal: ^Real;
  BufferInteger: ^Integer;
  BufferSmallInt: ^SmallInt;
  BufferTinyInt: ^Byte;
  BufferByte: ^Byte;
  BufferDateTime: ^TDateTime;
  BufferChar: ^Char;
  st: PStream;
begin
  dtString(ndt, 'NULL');
  Result := NOT_ERROR;

  SQLDescribeCol(fSession, i + 1, ColName, Sizeof(ColName), @ColLen,
                 @FD.DataType, @FD.ColumnSize, @FD.DecimalDigits, @FD.Nullable);
  
  CASE FD.DataType OF
    SQL_TINYINT:
    begin
      BufferTinyInt := Addr(BufferText);
      R := SQLGetData(fSession, i + 1, SQL_C_DEFAULT, BufferTinyInt, FD.ColumnSize, @FD.ColumnSize);
      if ((R = SQL_SUCCESS) or (R = SQL_SUCCESS_WITH_INFO)) and (FD.ColumnSize <> SQL_NULL_DATA) then
        dtInteger(ndt, PByte(BufferTinyInt)^);
    end; { SQL_TINYINT: }
  
    SQL_SMALLINT:
    begin
      BufferSmallInt := Addr(BufferText); 
      R := SQLGetData(fSession, i + 1, SQL_C_DEFAULT, BufferSmallInt, FD.ColumnSize, @FD.ColumnSize);
      if ((R = SQL_SUCCESS) or (R = SQL_SUCCESS_WITH_INFO)) and (FD.ColumnSize <> SQL_NULL_DATA) then
        dtInteger(ndt, PSmallInt(BufferSmallInt)^);
    end; { SQL_SMALLINT: }
  
    SQL_REAL:
    begin
      BufferReal := Addr(BufferText);
      R := SQLGetData(fSession, i + 1, SQL_C_DEFAULT, BufferReal, FD.ColumnSize, @FD.ColumnSize);
      if ((R = SQL_SUCCESS) or (R = SQL_SUCCESS_WITH_INFO)) and (FD.ColumnSize <> SQL_NULL_DATA) then
        dtReal(ndt, PSingle(BufferReal)^);
    end; { REAL: }

    SQL_INTEGER:
    begin
      BufferInteger := Addr(BufferText);
      R := SQLGetData(fSession, i + 1, SQL_C_BINARY, BufferInteger, FD.ColumnSize, @FD.ColumnSize);
      if ((R = SQL_SUCCESS) or (R = SQL_SUCCESS_WITH_INFO)) and (FD.ColumnSize <> SQL_NULL_DATA) then
        dtInteger(ndt, PInteger(BufferInteger)^);
    end; { SQL_INTEGER: }

    SQL_UID, SQL_LONGVARCHAR, SQL_WLONGVARCHAR, SQL_NVARCHAR, SQL_NUMERIC, SQL_DECIMAL:
    begin
      BufferChar := Addr(BufferText);
      R := SQLGetData(fSession, i + 1, SQL_C_DEFAULT, BufferChar, Sizeof( BufferText ), @FD.ColumnSize);
      if ((R = SQL_SUCCESS) or (R = SQL_SUCCESS_WITH_INFO)) and (FD.ColumnSize <> SQL_NULL_DATA) then
      begin
        SetString(s, PChar(BufferChar), FD.ColumnSize);
        s := FormatString(s);
        dtString(ndt, s);
      end; { If }
    end; { SQL_UID, SQL_LONGVARCHAR, SQL_WLONGVARCHAR, SQL_NVARCHAR, SQL_NUMERIC, SQL_DECIMAL: }

    SQL_VARCHAR:
    begin
      BufferChar := Addr(BufferText);
      R := SQLGetData(fSession, i + 1, SQL_C_BINARY, BufferChar, FD.ColumnSize, @FD.ColumnSize);
      if ((R = SQL_SUCCESS) or (R = SQL_SUCCESS_WITH_INFO)) and (FD.ColumnSize <> SQL_NULL_DATA) then
      begin
        SetString(s, PChar(BufferChar), FD.ColumnSize);
        s := FormatString(s);
        dtString(ndt, s);
      end; { If }
    end; { SQL_VARCHAR: }

    SQL_TYPE_TIMESTAMP:
    begin
      BufferDateTime := Addr(BufferText);
      R := SQLGetData(fSession, i + 1, SQL_C_DEFAULT, BufferDateTime, FD.ColumnSize, @FD.ColumnSize);
      if ((R = SQL_SUCCESS) or (R = SQL_SUCCESS_WITH_INFO)) and (FD.ColumnSize <> SQL_NULL_DATA) then
        dtString(ndt, DateTime2StrShort(SqlDateTimeStampToDateTime(@BufferDateTime^)));
    end; { SQL_TYPE_TIMESTAMP: }

    SQL_BIT:
    begin
      BufferByte := Addr(BufferText);
      R := SQLGetData(fSession, i + 1, SQL_C_DEFAULT, BufferByte, FD.ColumnSize, @FD.ColumnSize);
      if ((R = SQL_SUCCESS) or (R = SQL_SUCCESS_WITH_INFO)) and (FD.ColumnSize <> SQL_NULL_DATA) then
        dtInteger(ndt, PByte(BufferByte)^);
    end; { SQL_BIT: }

    SQL_DOUBLE, SQL_FLOAT, SQL_BIGINT:
    begin
      BufferDouble := Addr(BufferText);
      R := SQLGetData(fSession, i + 1, SQL_C_DEFAULT, BufferDouble, FD.ColumnSize, @FD.ColumnSize);
      if ((R = SQL_SUCCESS) or (R = SQL_SUCCESS_WITH_INFO)) and (FD.ColumnSize <> SQL_NULL_DATA) then
        dtReal(ndt, PDouble( BufferDouble)^);
    end; { SQL_DOUBLE, SQL_FLOAT, SQL_BIGINT: }

    SQL_VARIANT, SQL_VARBINARY, SQL_BINARY:
    begin
      R := SQLGetData( fSession, i+1, SQL_C_BINARY, @Buffer, 0, @FD.ColumnSize );
      if R <> SQL_SUCCESS_WITH_INFO then
        dtString(ndt, 'NULL')
      else
      begin
        Buffer := AllocMem( FD.ColumnSize + 4 );
        TRY
          R := SQLGetData( fSession, i + 1, SQL_C_DEFAULT, Buffer, FD.ColumnSize, @FD.ColumnSize );
          if ((R = SQL_SUCCESS) or (R = SQL_SUCCESS_WITH_INFO)) and (FD.ColumnSize <> SQL_NULL_DATA) then
          begin
            St := NewMemoryStream;
            St.Write( Buffer^, FD.ColumnSize );
            St.Position := 0;
            if scalar then 
              dtStream(ndt, St)
            else
              dtString(ndt, 'Binary');
            free_and_nil(St);
          end; { If }
        FINALLY
          FreeMem(Buffer);
        END;  
      end; { If }
    end; { SQL_VARIANT, SQL_VARBINARY, SQL_BINARY: }

    SQL_LONGVARBINARY:
    begin
      R := SQLGetData( fSession, i+1, SQL_C_BINARY, @Buffer, 0, @FD.ColumnSize );
      if R <> SQL_SUCCESS_WITH_INFO then
        dtString(ndt, 'NULL')
      else
      begin
        Buffer := AllocMem(FD.ColumnSize);
        TRY
          R := SQLGetData( fSession, i + 1, SQL_C_DEFAULT, Buffer, FD.ColumnSize, @FD.ColumnSize );
          if ((R = SQL_SUCCESS) or (R = SQL_SUCCESS_WITH_INFO)) and (FD.ColumnSize <> SQL_NULL_DATA) then
          begin
            St := NewMemoryStream;
            St.Write(Buffer^, FD.ColumnSize);
            St.Position := 0;
            if scalar then 
              dtStream(ndt, St)
            else
              dtString(ndt, 'Binary');
            free_and_nil(St);
          end;
        FINALLY
          FreeMem(Buffer);
        END;  
      end; { If }
    end { SQL_LONGVARBINARY: }

    ELSE { ELSE CASE }
    begin
      BufferChar := Addr(BufferText);
      R := SQLGetData( fSession, i + 1, SQL_C_DEFAULT, BufferChar, FD.ColumnSize, @FD.ColumnSize );
      if ((R <= SQL_SUCCESS_WITH_INFO) and (FD.ColumnSize <> SQL_NULL_DATA)) then
      begin
        St := NewMemoryStream;
        St.Write( BufferChar^, FD.ColumnSize );
        St.Position := 0;
        if scalar then 
          dtStream(ndt, St)
        else
          dtString(ndt, 'Binary');
        free_and_nil(St);
      end
      else
        dtString(ndt, 'NULL');
    end; { ELSE CASE }

  end; { CASE }

  if R > SQL_SUCCESS_WITH_INFO then
    Result := ErrorArray[6]; // 'Не удалось получить поле'    
end;

procedure THIDS_ODBC.ODBC_Disconnect;
begin
  SQLDisconnect(fConnHandle );
  SQLFreeHandle(SQL_HANDLE_DBC, fConnHandle);
  SQLFreeHandle(SQL_HANDLE_ENV, fEnvHandle);
  booConnect := false;
end;

function _procquery(const fSession: THandle; const user: pointer): integer;
var
  dt,
  ndt: TData;
  i: integer;
  s: PData;
  list: PStrList;
  R: SQLResult;
  fData: Boolean;
  ColCount: SmallInt; 
  ColName: array[ 0..4095 ] of Char;
  ColLen: SmallInt;  
  FD: PFieldDescription;
begin
  ColCount := 0;
  SQLNumResultCols(fSession, @ColCount);
  FD := AllocMem(Sizeof(FD^));
TRY
  Result := NOT_ERROR;
  fData := false;

  if ColCount > 0 then
  begin
    R := SQLFetch(fSession);
    if R <> SQL_NO_DATA then
    begin
      if R > SQL_SUCCESS_WITH_INFO then
        Result := ErrorArray[17] // 'Не удалось загрузить набор данных'
      else
      begin
        fData := true;
        if Assigned(PCallBackRec(user).callBackFields) then
        begin
          list := NewStrList;
        TRY  
          for i := 0 to ColCount - 1 do
          begin
            SQLDescribeCol(fSession, i + 1, ColName, Sizeof(ColName), @ColLen, @FD.DataType,
                           @FD.ColumnSize, @FD.DecimalDigits, @FD.Nullable);
            list.add(ColName);
          end; { For }
          PCallBackRec(user).callBackFields(list);
        FINALLY  
          list.free;
        END;  
        end; { If }
      end; { If }
    end; { If }
  end; { If }  

  if fdata then
  begin
    dtNull(dt);
    repeat
      for i := 0 to ColCount - 1 do
      begin
        Result := GetData(fSession, FD, i, ndt, false);
        AddMTData(@dt, @ndt, s);
      end;  
      ndt := dt;
      PCallBackRec(user).callBackData(dt);
      FreeData(@ndt);
    until SQLFetchScroll(fSession, SQL_FETCH_NEXT, 0) = SQL_NO_DATA; { Repeat }
  end
  else
  begin
    Result := ErrorArray[18]; // 'Запрос не вернул данных' 
  end; { If }
  SQLCloseCursor(fSession);
FINALLY
  FreeMem(FD);
END;
end;

function _procqueryscalar(const fSession: THandle; const user: pointer): integer;
var
  FD: PFieldDescription;  
  R: SQLResult;
begin
  FD := AllocMem(Sizeof(FD^));
TRY
  R := SQLFetch(fSession);
  if R = SQL_NO_DATA then
    Result := ErrorArray[18] // 'Запрос не вернул данных'
  else
    Result := GetData(fSession, FD, 0, PData(user)^, true);
  SQLCloseCursor(fSession);  
FINALLY
  FreeMem(FD);
END;
end;

function THIDS_ODBC.procquery;
var
  rec: TCallBackRec;
  R: SQLResult;
  Error: integer;
  fSession: THandle;
begin
  if booConnect then
  begin
    R := SQLAllocHandle(SQL_HANDLE_STMT, fConnHandle, @fSession);
    TRY
      if R > SQL_SUCCESS_WITH_INFO then
      begin
        Error := ErrorArray[4]; // 'Не удалось создать запрос'
        exit;
      end;
      R := SQLExecDirect(fSession, PChar(SQL), Length(SQL));
      if (R > SQL_SUCCESS_WITH_INFO) and (R <> SQL_NO_DATA) then
        Error := ErrorArray[5] // 'Не удалось выполнить запрос'
      else
      begin
        rec.callBackFields := callBackFields;
        rec.callBackData := callBackData;
        Error := _procquery(fSession, @rec);
      end;
    FINALLY
      SQLFreeHandle(SQL_HANDLE_STMT, fSession);
    END;
  end
  else
    Error := ErrorArray[4]; // 'Не удалось создать запрос'
  if Error < 0  then
    dtNull(Result)
  else
    dtInteger(Result, Error);
end;

function THIDS_ODBC.procqueryscalar;
var
  R: SQLResult;
  Error: integer;
  fSession: THandle;  
begin
  if booConnect then
  begin
    R := SQLAllocHandle(SQL_HANDLE_STMT, fConnHandle, @fSession);
    TRY
      if R > SQL_SUCCESS_WITH_INFO then
      begin
        Error := ErrorArray[4]; // 'Не удалось создать запрос'
        exit;
      end;
      R := SQLExecDirect(fSession, PChar(SQL), Length(SQL));
      if (R > SQL_SUCCESS_WITH_INFO) and (R <> SQL_NO_DATA) then
        Error := ErrorArray[5] // 'Не удалось выполнить запрос'
      else
        Error := _procqueryscalar(fSession, @Data);
    FINALLY
      SQLFreeHandle(SQL_HANDLE_STMT, fSession);
    END;
  end
  else
    Error := ErrorArray[4]; // 'Не удалось создать запрос'
  if Error < 0  then
    dtNull(Result)
  else
    dtInteger(Result, Error);
end;

function THIDS_ODBC.procexec;
var
  R: SQLResult;
  Error: integer;
  fSession: THandle;    
begin
  Error := NOT_ERROR;
  if booConnect then
  begin
    R := SQLAllocHandle(SQL_HANDLE_STMT, fConnHandle, @fSession);
    TRY
      if R > SQL_SUCCESS_WITH_INFO then
      begin
        Error := ErrorArray[4]; // 'Не удалось создать запрос'
        exit;
      end;
      R := SQLExecDirect(fSession, PChar(SQL), Length(SQL));
      if (R > SQL_SUCCESS_WITH_INFO) and (R <> SQL_NO_DATA) then
        Error := ErrorArray[5]; //'Не удалось выполнить запрос'
    FINALLY
      SQLFreeHandle(SQL_HANDLE_STMT, fSession);
    END;
  end
  else
    Error := ErrorArray[4]; // 'Не удалось создать запрос'
  if Error < 0  then
    dtNull(Result)
  else
    dtInteger(Result, Error);
end;

end.