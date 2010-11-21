unit hiODBC;

interface

uses Windows, kol, Share, Debug;

type
  SQLResult = Word;
  ErrorODBC = packed record
    ErrorNumber        : SmallInt;
    ErrorMessage       : PChar;
  end;
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
  TSQLConfigDataSource = function( hwndParent: THandle;
                                   fRequest: WORD;
                                   lpszDriver: PChar;
                                   lpszAttributes: PChar ) : BOOLEAN; stdcall;
  THIODBC = class( TDebug )

   protected
     fHandle: Integer;
     fConnHandle: THandle;
     fEnvHandle: THandle;
   private
     ErrorArr: Array of ErrorODBC;
   public
     _prop_DSN_Name: string;
     _prop_User_ID: string;
     _prop_Password: string;
     _prop_ConnectionDrv: string;
     _prop_Driver: string;
     _prop_FileDB: string;
     _prop_BrowseType: byte;
     _prop_Exclusive: byte;
     _prop_ReadOnly: byte;
     _prop_Error: byte;
     _event_onStreamString: THI_Event;
     _event_onStreamBinary: THI_Event;
     _event_onRowCount: THI_Event;
     _event_onColumnsInfo: THI_Event;
     _event_onError: THI_Event;
     _data_Data: THI_Event;
     _data_DSN_Name: THI_Event;
     _data_ConnectionDrv: THI_Event;
     _data_UserID: THI_Event;
     _data_Password: THI_Event;
     _data_Driver: THI_Event;
     _data_BinaryStream: THI_Event;
     _data_BrowseType: THI_Event;
     _data_FileDB: THI_Event;
     BufferConnect: PChar;
     Buffer: PChar;
     BufferSize : Integer;
     BufferText: array[0..4095] of char;
     BufferChar: ^Char;
     BufferDouble: ^Double;
     BufferFloat: ^Double;
     BufferReal: ^Real;
     BufferInteger: ^Integer;
     BufferSmallInt: ^SmallInt;
     BufferTinyInt: ^Byte;
     BufferNChar: ^Char;
     BufferByte: ^Byte;
     BufferDateTime: ^TDateTime;
     BufferDecimal: ^Char;
     StrLenInd: SmallInt;
     RowCount: SmallInt;
     FD: PFieldDescription;
     FieldName: String;
     FieldType: Integer;
     FieldSize: Integer;
     fColCount: SmallInt;
     ColName: array[ 0..4095 ] of Char;
     ColLen: SmallInt;
     booConnect: Boolean;
     fdata: Boolean;
     StrDBConnect: String;
     DSN: String;
     User: String;
     Pwd: String;
     Txt: String;
     StreamString: PStream;
     StreamBinary: PStream;

   constructor Create;
   destructor Destroy; override;
   procedure _work_doConnectDSN( var _Data:TData; Index:word );
   procedure _work_doConnectDrv( var _Data:TData; Index:word );
   procedure _work_doDisconnect( var _Data:TData; Index:word );
   procedure _work_doQuery( var _Data:TData; Index:word );
   procedure _work_doExec( var _Data:TData; Index:word );
   procedure _work_doBinary( var _Data:TData; Index:word );
   procedure _work_doList( var _Data:TData; Index:word );
   procedure _work_doSetup( var _Data:TData; Index:word );
   procedure _var_FieldName( var _Data:TData; Index:word );
   procedure _var_FieldType( var _Data:TData; Index:word );
   procedure _var_FieldSize( var _Data:TData; Index:word );
   procedure _var_ColumnsCount( var _Data:TData; Index:word );
   procedure ColumnsInfo;
   procedure ErrorEvent( R:SQLResult; Err:smallint );
   procedure ODBC_Disconnect;
   function ODBC_Connect( strDBConnect:string ): boolean;
   function FormatString( strField: string ): string;
 end;

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
  SQL_NEED_DATA         = 99; // Для успешного выполнения данной функции следует
                              // предварительно определить необходимые данные
  SQL_NO_DATA           = 100;// Больше нет строк для извлечения их из результирующего набора.
                              // В предыдущей версии ODBC API этот код возврата обозначался как
                              // SQL_NO_DATA_FOUND.
                              // В версии 3.x код возврата SQL_NO_DATA_FOUND содержатся
                              // в заголовочном файле sqlext.h
  SQL_ERROR             = -1; // При выполнении функции произошла ошибка
  SQL_INVALID_HANDLE    = -2; // Указан неверный дескриптор
  SQL_STILL_EXECUTING   = 2;  // Функция, выполняемая асинхронно, пока не завершена

  //  SQLBindParameter - fParamType
  //  SQLProcedureColumns - COLUMN_TYPE
  SQL_PARAM_TYPE_UNKNOWN= 0;
  SQL_PARAM_INPUT       = 1;
  SQL_PARAM_INPUT_OUTPUT= 2;
  SQL_RESULT_COL        = 3;
  SQL_PARAM_OUTPUT      = 4;
  SQL_RETURN_VALUE      = 5;
  SQL_DEFAULT_PARAM     =-5;
  SQL_IGNORE            =-6;

  // SQL Types
  // SQL type VALUE Maps to
  SQL_UNKNOWN_TYPE      =  0;
  SQL_LONGVARCHAR       = -1; // text
  SQL_BINARY            = -2; // binary
  SQL_VARBINARY         = -3; // varbinary
  SQL_LONGVARBINARY     = -4; // image
  SQL_BIGINT            = -5; // bigint
  SQL_TINYINT           = -6; // tinyint
  SQL_BIT               = -7; // bit
  SQL_NCHAR             = -8; // nchar
  SQL_NVARCHAR          = -9; // nvarchar
  SQL_WLONGVARCHAR      =-10; // ntext
  SQL_UID               =-11; // uniqueidentifier
  SQL_CHAR              =  1; // char
  SQL_NUMERIC           =  2; // numeric
  SQL_DECIMAL           =  3; // decimal
  SQL_INTEGER           =  4; // integer
  SQL_SMALLINT          =  5; // smallint
  SQL_FLOAT             =  6; // float
  SQL_REAL              =  7; // real
  SQL_DOUBLE            =  8; // real
  SQL_DATE              =  9; // datetime
  SQL_TIME              = 10; // datetime
  SQL_TIMESTAMP         = 11; // datetime
  SQL_VARCHAR           = 12; // varchar
  SQL_TYPE_TIMESTAMP    = 93; // datetime
  SQL_WVARCHAR          =-96; // ?
  SQL_VARIANT           =-150;// sql_variant

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
  SQL_C_UTINYINT        =-28;
  SQL_C_STINYINT        =-26;
  SQL_C_ULONG           =-18;
  SQL_C_USHORT          =-17;
  SQL_C_SLONG           =-16;
  SQL_C_SSHORT          =-15;

implementation

const
    MAXBUFLEN = 1024;

function SQLDataSources(
  StatementHandle       : THandle;
  Direction             : SmallInt;
  DriverDesc            : PChar;
  DriverDescMax         : SmallInt;
  StringLength1Ptr      : PSmallInt;
  DriverAttr            : PChar;
  DriverAttrMax         : SmallInt;
  StringLength2Ptr      : PSmallInt
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLDataSources';

function SQLDrivers(
  StatementHandle       : THandle;
  Direction             : SmallInt;
  DriverDesc            : PChar;
  DriverDescMax         : SmallInt;
  StringLength1Ptr      : PSmallInt;
  DriverAttr            : PChar;
  DriverAttrMax         : SmallInt;
  StringLength2Ptr      : PSmallInt
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLDrivers';

function SQLBrowseConnect(
  ConnectionHandle        : THandle;
  InConnectionString      : PChar;
  StringLength1           : SmallInt;
  OutConnectionString     : PChar;
  BufferLength            : SmallInt;
  StringLength2Ptr        : PSmallInt
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLBrowseConnect';

function SQLPutData(
  StatementHandle   : THandle;
  DataPtr           : Pointer;
  DataLength        : Integer
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLPutData';

function SQLParamData(
  StatementHandle      : THandle;
  ValuePtrPtr          : Pointer
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLParamData';

function SQLExecute(
  StatementHandle      : THandle
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLExecute';

function SQLPrepare(
  StatementHandle      : THandle;
  StatementText        : PChar;
  TextLength           : Integer
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLPrepare';

function SQLBindParameter(
  StatementHandle   : THandle;
  ColumnNumber      : Word;
  TargetType        : SmallInt;
  TargetValuePtr    : SmallInt;
  ParameterType     : SmallInt;
  ColumnSize        : DWORD;
  DecimalDigits     : SmallInt;
  ParameterValuePtr : Pointer;
  BufferLength      : Integer;
  StrLen_or_Ind     : PInteger
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLBindParameter';

function SQLGetInstalledDrivers(
  DriversBuffer      : PChar;
  BufferMaxLength    : SmallInt;
  OutDataPtr         : PInteger
  ): SQLResult; stdcall;
  external ODBCCP32 name 'SQLGetInstalledDrivers';

function SQLCloseCursor(
  StatementHandle       : THandle
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLCloseCursor';

function SQLFetch(
  StatementHandle : THandle
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLFetch';

function SQLFetchScroll(
  StatementHandle       : THandle;
  FetchOrientation      : SmallInt;
  FetchOffset           : Integer
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLFetchScroll';

function SQLMoreResults(
  StatementHandle      : THandle
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLMoreResults';

function SQLDescribeCol(
  StatementHandle       : THandle;
  ColumnNumber          : SmallInt;
  ColumnName            : PChar;
  BufferLength          : SmallInt;
  NameLengthPtr         : PSmallInt;
  DataTypePtr           : PSmallInt;
  ColumnSizePtr         : PDWORD;
  DecimalDigitsPtr      : PSmallInt;
  NullablePtr           : PSmallInt
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLDescribeCol';

function SQLRowCount(
  StatementHandle         : THandle;
  RowCountPtr             : PSmallInt
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLRowCount';

function SQLNumResultCols(
  StatementHandle         : THandle;
  ColumnCountPtr          : PSmallInt
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLNumResultCols';

function SQLDriverConnect(
  ConnectionHandle        : THandle;
  WindowHandle            : HWnd;
  InConnectionString      : PChar;
  StringLength1           : SmallInt;
  OutConnectionString     : PChar;
  BufferLength            : SmallInt;
  StringLength2Ptr        : PSmallInt;
  DriverCompletion        : Word
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLDriverConnect';

function SQLGetData(
  StatementHandle   : THandle;
  ColumnNumber      : SmallInt;
  TargetType        : SmallInt;
  TargetValuePtr    : Pointer;
  BufferLength      : Integer;
  StrLen_or_IndPtr  : PInteger
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLGetData';

function SQLFreeHandle(
  HandleType           : SmallInt;
  Handle               : THandle
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLFreeHandle';

function SQLBindCol(
  StatementHandle   : THandle;
  ColumnNumber      : Word;
  TargetType        : SmallInt;
  TargetValuePtr    : Pointer;
  BufferLength      : Integer;
  StrLen_or_Ind     : PInteger
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLBindCol';

function SQLExecDirect(
  StatementHandle      : THandle;
  StatementText        : PChar;
  TextLength           : Integer
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLExecDirect';

function SQLDisconnect(
  ConnectionHandle     : THandle
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLDisconnect';

function SQLConnect(
  ConnectionHandle  : THandle;
  ServerName        : PChar;
  NameLength1       : SmallInt;
  UserName          : PChar;
  NameLength2       : SmallInt;
  Authentication    : PChar;
  NameLength3       : SmallInt
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLConnect';

function SQLSetEnvAttr(
  EnvironmentHandle    : THandle;
  Attribute            : Integer;
  ValuePtr             : Pointer;
  StringLength         : Integer
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLSetEnvAttr';

function SQLAllocHandle(
  HandleType            : SmallInt;
  InputHandle           : THandle;
  OutputHandlePtr       : PHandle
  ): SQLResult; stdcall;
  external ODBC32 name 'SQLAllocHandle';

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
    SystemTime2DateTime( ST, Result );
  end;

constructor THIODBC.Create;
  begin
    inherited Create;
    booConnect := false;
    fdata := false;
    SetLength( ErrorArr, 19 );
    ErrorArr[0].ErrorNumber := 1000;
    ErrorArr[0].ErrorMessage := 'Не удалось создать среду ODBC';
    ErrorArr[1].ErrorNumber := 1001;
    ErrorArr[1].ErrorMessage := 'Не удалось указать версию ODBC 3.0';
    ErrorArr[2].ErrorNumber := 1002;
    ErrorArr[2].ErrorMessage := 'Не удалось создать соединение';
    ErrorArr[3].ErrorNumber := 1003;
    ErrorArr[3].ErrorMessage := 'Не удалось соединиться с БД';
    ErrorArr[4].ErrorNumber := 1004;
    ErrorArr[4].ErrorMessage := 'Не удалось создать запрос';
    ErrorArr[5].ErrorNumber := 1005;
    ErrorArr[5].ErrorMessage := 'Не удалось выполнить запрос';
    ErrorArr[6].ErrorNumber := 1006;
    ErrorArr[6].ErrorMessage := 'Не удалось получить поле';
    ErrorArr[7].ErrorNumber := 1007;
    ErrorArr[7].ErrorMessage := 'Ошибка получения следующего набора данных';
    ErrorArr[8].ErrorNumber := 1008;
    ErrorArr[8].ErrorMessage := 'Не удалось подготовить запрос';
    ErrorArr[9].ErrorNumber := 1009;
    ErrorArr[9].ErrorMessage := 'Не удалось выполнить связывание';
    ErrorArr[10].ErrorNumber := 1010;
    ErrorArr[10].ErrorMessage := 'Не удалось получить RowCount';
    ErrorArr[11].ErrorNumber := 1011;
    ErrorArr[11].ErrorMessage := 'Не удалось получить список';
    ErrorArr[12].ErrorNumber := 1012;
    ErrorArr[12].ErrorMessage := 'Не задано имя источника данных';
    ErrorArr[13].ErrorNumber := 1013;
    ErrorArr[13].ErrorMessage := 'Не задано имя файла Базы Данных';
    ErrorArr[14].ErrorNumber := 1014;
    ErrorArr[14].ErrorMessage := 'Не удалось загрузить ODBCCP32.DLL';
    ErrorArr[15].ErrorNumber := 1015;
    ErrorArr[15].ErrorMessage := 'Не удалось получить адрес функции SQLConfigDataSource';
    ErrorArr[16].ErrorNumber := 1016;
    ErrorArr[16].ErrorMessage := 'Ошибка при создании DSN';
    ErrorArr[17].ErrorNumber := 1017;
    ErrorArr[17].ErrorMessage := 'Не удалось загрузить набор данных';
    ErrorArr[18].ErrorNumber := 1018;
    ErrorArr[18].ErrorMessage := 'Запрос не вернул данных';
  end;

destructor THIODBC.Destroy;
  begin
    if booConnect Then ODBC_Disconnect;
    inherited;
  end;

function THIODBC.ODBC_Connect( strDBConnect: string ): boolean;
  var
    R: SQLResult;
  begin
    Result := FALSE;
    R := SQLAllocHandle( SQL_HANDLE_ENV, 0, @ fEnvHandle );
    if R > SQL_SUCCESS_WITH_INFO then
       //MsgOk( 'Не удалось создать среду ODBC' )
       ErrorEvent( R, 0 )
    else begin
     R := SQLSetEnvAttr( fEnvHandle, SQL_ATTR_ODBC_VERSION,
     Pointer( SQL_OV_ODBC3 ), SQL_IS_INTEGER );
     if R > SQL_SUCCESS_WITH_INFO then
        //MsgOk( 'Не удалось указать версию ODBC 3.0' )
        ErrorEvent( R, 1 )
     else begin
      R := SQLAllocHandle( SQL_HANDLE_DBC, fEnvHandle, @ fConnHandle );
      if R > SQL_SUCCESS_WITH_INFO then
         //MsgOk( 'Не удалось создать соединение' )
         ErrorEvent( R, 2 )
      else begin
       If StrDBConnect = '' Then
        R := SQLConnect( fConnHandle,
                        PChar( DSN ),
                        Length( DSN ),
                        PChar( User ),
                        Length( User ),
                        PChar( Pwd ),
                        Length( Pwd ) )
       else begin
        BufferConnect := AllocMem( MAXBUFLEN );
        R := SQLDriverConnect(fConnHandle,              // Connection handle
                              0,                        // Window handle
                              PChar( StrDBConnect ),    // Input connect string
                              Length( StrDBConnect ),   // Null-terminated string
                              BufferConnect,            // Address of output buffer
                              MAXBUFLEN,                // Size of output buffer
                              @ StrLenInd,              // Address of output length
                              SQL_DRIVER_NOPROMPT
                             );
        FreeMem( BufferConnect );
       end; { If }
       if R > SQL_SUCCESS_WITH_INFO then
          //MsgOk( 'Не удалось соединиться с БД' )
          ErrorEvent( R, 3 )
       else begin
        R := SQLAllocHandle( SQL_HANDLE_STMT,
                            fConnHandle,
                            @ fHandle
                           );
        if R > SQL_SUCCESS_WITH_INFO then
           //MsgOk( 'Не удалось создать запрос' )
           ErrorEvent( R, 4 )
        else
         Result := TRUE;
       end; { If }
      end; { If }
     end; { If }
    end; { If }
  end;

function THIODBC.FormatString( strField: string ): string;
  var
    i: Cardinal;
  begin
    Result := '';
    i := Pos( Chr(0), strField );
    If i > 0 Then Result := Copy( strField, 1, i - 1 )
    else Result := strField;
  end;

procedure THIODBC._work_doQuery( var _Data:TData; Index:word );
  var
    s: String;
    l: Cardinal;
    R: SQLResult;
    i: Word;
    j: Integer;
  begin

    if booConnect then begin
     Txt := ReadString( _data, _data_Data, '' );
     R := SQLExecDirect( fHandle, PChar( Txt ), Length( Txt ) );
     if (R > SQL_SUCCESS_WITH_INFO) and (R <> SQL_NO_DATA) then
        //MsgOk( 'Не удалось выполнить запрос')
        ErrorEvent( R, 5 )
     else begin
      // This is works only if provider support returning multiple record sets from execution
      //REPEAT
       fColCount := 0;
       SQLNumResultCols( fHandle, @ fColCount );
       FD := AllocMem( Sizeof( FD^ ) );
       ColumnsInfo;
       // Проверка: вернул ли запрос данные?
       if fdata then begin
        StreamString := NewMemoryStream;
        StreamBinary := NewMemoryStream;
        repeat
         for i := 0 to fColCount-1 do begin
          SQLDescribeCol( fHandle, i+1, ColName, Sizeof( ColName ), @ ColLen,
          @ FD.DataType, @ FD.ColumnSize, @ FD.DecimalDigits, @ FD.Nullable );
          SetString( FieldName, ColName, ColLen );
          FieldType := FD.DataType;
          s := FormatString( '<NULL>' );
          l := Length( s );
          StreamString.Size := 0;
          StreamBinary.Size := 0;
          CASE FD.DataType OF
           SQL_VARIANT,
           SQL_VARBINARY,
           SQL_BINARY: begin
            R := SQLGetData( fHandle, i+1, SQL_C_BINARY, @ Buffer, 0, @ FD.ColumnSize );
            if R <> SQL_SUCCESS_WITH_INFO Then
             StreamString.Write( s[1], l )
            else begin
             Buffer := AllocMem( FD.ColumnSize + 4 );
             R := SQLGetData( fHandle,
                             i+1,
                             SQL_C_DEFAULT,
                             Buffer,
                             FD.ColumnSize,
                             @ FD.ColumnSize
                            );
             if R > SQL_SUCCESS_WITH_INFO then
                //MsgOk( 'Не удалось получить поле' )
                ErrorEvent( R, 6 )
             else begin
              If FD.ColumnSize <> SQL_NULL_DATA then begin
               s := '<Binary>';
               StreamString.Write( s[1], Length( s ) );
               StreamBinary.Write( Buffer, FD.ColumnSize );
              end else StreamString.Write( s[1], l );
             end; { If }
             FreeMem( Buffer );
            end; { If }
           end; { SQL_VARIANT, SQL_VARBINARY, SQL_BINARY: }
           SQL_TINYINT: begin
            BufferTinyInt := Addr(BufferText);
            R := SQLGetData( fHandle,
                            i+1,
                            SQL_C_DEFAULT,
                            BufferTinyInt,
                            FD.ColumnSize,
                            @ FD.ColumnSize
                           );
            if R > SQL_SUCCESS_WITH_INFO then
               //MsgOk( 'Не удалось получить поле' )
               ErrorEvent( R, 6 )
            else begin
             If FD.ColumnSize <> SQL_NULL_DATA Then begin
              s := Int2Str( PByte( BufferTinyInt )^ );
              s := FormatString( s );
              l := Length( s );
             end; { If }
             StreamString.Write( s[1], l);
             StreamBinary.Write( BufferTinyInt^, FD.ColumnSize );
            end; { If }
           end; { SQL_TINYINT: }
           SQL_SMALLINT: begin
            BufferSmallInt := Addr(BufferText); 
            R := SQLGetData( fHandle, 
                            i+1,
                            SQL_C_DEFAULT,
                            BufferSmallInt,
                            FD.ColumnSize,
                            @ FD.ColumnSize
                           );
            if R > SQL_SUCCESS_WITH_INFO then
               //MsgOk( 'Не удалось получить поле' )
               ErrorEvent( R, 6 )
            else begin
             If FD.ColumnSize <> SQL_NULL_DATA Then begin
              s := Int2Str( PSmallInt( BufferSmallInt )^ );
              s := FormatString( s );
              l := Length( s );
             end; { If }
             StreamString.Write( s[1], l );
             StreamBinary.Write( BufferSmallInt^, FD.ColumnSize );
            end; { If }
           end; { SQL_SMALLINT: }
           SQL_REAL: begin
            BufferReal := Addr(BufferText);
            R := SQLGetData( fHandle,
                            i+1,
                            SQL_C_DEFAULT,
                            BufferReal,
                            FD.ColumnSize,
                            @ FD.ColumnSize
                           );
            if (R > SQL_SUCCESS_WITH_INFO) then
               //MsgOk( 'Не удалось получить поле' )
               ErrorEvent( R, 6 )
            else begin
             If FD.ColumnSize <> SQL_NULL_DATA Then begin
              s := Double2Str( PSingle( BufferReal )^ );
              s := FormatString( s );
              l := Length( s );
             end; { If }
             StreamString.Write( s[1], l );
             StreamBinary.Write( BufferReal^, FD.ColumnSize );
            end; { If }
           end; { REAL: }
           SQL_INTEGER: begin
            BufferInteger := Addr(BufferText);
            R := SQLGetData( fHandle,
                            i+1,
                            SQL_C_DEFAULT,
                            BufferInteger,
                            FD.ColumnSize,
                            @ FD.ColumnSize
                           );
            if R > SQL_SUCCESS_WITH_INFO then
               //MsgOk( 'Не удалось получить поле' )
               ErrorEvent( R, 6 )
            else begin
             If FD.ColumnSize <> SQL_NULL_DATA Then begin
              s := Int2Str( PInteger( BufferInteger )^ );
              s := FormatString( s );
              l := Length( s );
             end; { If }
             StreamString.Write( s[1], l );
             StreamBinary.Write( BufferInteger^, FD.ColumnSize );
            end; { If }
           end; { SQL_INTEGER: }
           SQL_VARCHAR,
           SQL_NVARCHAR,
           SQL_NUMERIC,
           SQL_DECIMAL: begin
            BufferDecimal := Addr(BufferText);
            R := SQLGetData( fHandle,
                            i+1,
                            SQL_C_DEFAULT,
                            BufferDecimal,
                            FD.ColumnSize,
                            @ FD.ColumnSize
                           );
            if R > SQL_SUCCESS_WITH_INFO then
               //MsgOk( 'Не удалось получить поле' )
               ErrorEvent( R, 6 )
            else begin
             If FD.ColumnSize <> SQL_NULL_DATA Then begin
              SetString( s, PChar( BufferDecimal ), FD.ColumnSize );
              s := FormatString( s );
              l := Length( s );
             end; { If }
             StreamString.Write( s[1], l );
             StreamBinary.Write( BufferDecimal^, FD.ColumnSize );
            end; { If }
           end; { SQL_VARCHAR, SQL_NVARCHAR, SQL_NUMERIC, SQL_DECIMAL: }
           SQL_TYPE_TIMESTAMP: begin
            BufferDateTime := Addr(BufferText);
            R := SQLGetData( fHandle,
                            i+1,
                            SQL_C_DEFAULT,
                            BufferDateTime,
                            FD.ColumnSize,
                            @ FD.ColumnSize
                           );
            if R > SQL_SUCCESS_WITH_INFO then
               //MsgOk( 'Не удалось получить поле' )
               ErrorEvent( R, 6 )
            else begin
             If FD.ColumnSize <> SQL_NULL_DATA Then begin
              s := DateTime2StrShort( SqlDateTimeStampToDateTime( @ BufferDateTime^ ) );
             l := Length( s );
             end; { If }
             StreamString.Write( s[1], l );
             StreamBinary.Write( BufferDateTime^, FD.ColumnSize );
            end; { If }
           end; { SQL_TYPE_TIMESTAMP: }
           SQL_BIT: begin
            BufferByte := Addr(BufferText);
            R := SQLGetData( fHandle,
                            i+1,
                            SQL_C_DEFAULT,
                            BufferByte,
                            FD.ColumnSize,
                            @ FD.ColumnSize
                           );
            if R > SQL_SUCCESS_WITH_INFO then
               //MsgOk( 'Не удалось получить поле' )
               ErrorEvent( R, 6 )
            else begin
             If FD.ColumnSize <> SQL_NULL_DATA Then begin
              s := Int2Str( PByte( BufferByte )^ );
              s := FormatString( s );
              l := Length( s );
             end; { If }
             StreamString.Write( s[1], l );
             StreamBinary.Write( BufferByte^, FD.ColumnSize );
            end; { If }
           end; { SQL_BIT: }
           SQL_DOUBLE,
           SQL_FLOAT: begin
            BufferFloat := Addr(BufferText);
            R := SQLGetData( fHandle,
                            i+1,
                            SQL_C_DEFAULT,
                            BufferFloat,
                            FD.ColumnSize,
                            @ FD.ColumnSize
                           );
            if (R > SQL_SUCCESS_WITH_INFO) then
               //MsgOk( 'Не удалось получить поле' )
               ErrorEvent( R, 6 )
            else begin
             If FD.ColumnSize <> SQL_NULL_DATA Then begin
              s := Double2Str( PDouble( BufferFloat )^ );
              s := FormatString( s );
              l := Length( s );
             end; { If }
             StreamString.Write( s[1], l );
             StreamBinary.Write( BufferFloat^, FD.ColumnSize );
            end; { If }
           end; { SQL_DOUBLE, SQL_FLOAT: }
           SQL_BIGINT: begin
            BufferDouble := Addr(BufferText);
            R := SQLGetData( fHandle,
                            i+1,
                            SQL_C_DOUBLE,
                            BufferDouble,
                            FD.ColumnSize,
                            @ FD.ColumnSize
                           );
            if (R > SQL_SUCCESS_WITH_INFO) then
               //MsgOk( 'Не удалось получить поле' )
               ErrorEvent( R, 6 )
            else begin
             If FD.ColumnSize <> SQL_NULL_DATA Then begin
              s := Double2Str( PDouble( BufferDouble )^ );
              s := FormatString( s );
              l := Length( s );
             end; { If }
             StreamString.Write( s[1], l );
             StreamBinary.Write( BufferDouble^, FD.ColumnSize );
            end; { If }
           end; { SQL_BIGINT: }
           SQL_UID,
           SQL_LONGVARCHAR,
           SQL_WLONGVARCHAR: begin
            BufferNChar := Addr( BufferText );
            R := SQLGetData( fHandle,
                            i+1,
                            SQL_C_DEFAULT,
                            BufferNChar,
                            Sizeof( BufferText ),
                            @ FD.ColumnSize
                           );
            if (R > SQL_SUCCESS_WITH_INFO) and (R <> SQL_NO_DATA) then
               //MsgOk( 'Не удалось получить поле' )
               ErrorEvent( R, 6 )
            else begin
             If FD.ColumnSize <> SQL_NULL_DATA Then begin
              SetString( s, PChar( BufferNChar ), FD.ColumnSize );
              s := FormatString( s );
              l := Length( s );
             end; { If }
             StreamString.Write( s[1], l );
             StreamBinary.Write( BufferNChar^, FD.ColumnSize );
            end; { If }
           end; { SQL_UID, SQL_LONGVARCHAR, SQL_WLONGVARCHAR: }
           SQL_LONGVARBINARY: begin
            R := SQLGetData( fHandle,
                            i+1,
                            SQL_C_BINARY,
                            @ Buffer,
                            0,
                            @ FD.ColumnSize
                           );
            if R <> SQL_SUCCESS_WITH_INFO Then
             StreamString.Write( s[1], l )
            else begin
             Buffer := AllocMem( FD.ColumnSize );
             R := SQLGetData( fHandle,
                             i+1,
                             SQL_C_DEFAULT,
                             Buffer,
                             FD.ColumnSize,
                             @ FD.ColumnSize
                            );
             if R > SQL_SUCCESS_WITH_INFO then
                //MsgOk( 'Не удалось получить поле' )
                ErrorEvent( R, 6 )
             else begin
              If FD.ColumnSize <> SQL_NULL_DATA Then begin
               s := FormatString( '<Binary>' );
               StreamString.Write( s[1], Length( s ) );
               StreamBinary.Write( Buffer^, FD.ColumnSize );
              end else StreamString.Write( s[1], l );
             end; { If }
             FreeMem( Buffer );
            end; { If }
           end; { SQL_LONGVARBINARY: }
           ELSE begin
            BufferChar := Addr( BufferText );
            R := SQLGetData( fHandle,
                            i+1,
                            SQL_C_DEFAULT,
                            BufferChar,
                            FD.ColumnSize,
                            @ FD.ColumnSize
                           );
            if R > SQL_SUCCESS_WITH_INFO then
               //MsgOk( 'Не удалось получить поле' )
               ErrorEvent( R, 6 )
            else begin
             if FD.ColumnSize <> SQL_NULL_DATA Then begin
              StreamString.Write( BufferChar^, FD.ColumnSize );
              StreamBinary.Write( BufferChar^, FD.ColumnSize );
             end else StreamString.Write( s[1], l );
            end; { If }
           end; { ELSE CASE }
          END; { CASE }
          StreamString.Position := 0;
          If StreamString.Size <> 0 then
           _hi_OnEvent( _event_onStreamString, StreamString )
          else begin
           s := 'Error';
           StreamString.Write( s[1], Length( s ) );
           _hi_OnEvent( _event_onStreamString, StreamString );
          end; { If }
          StreamBinary.Position := 0;
          FieldSize := StreamBinary.Size;
          If StreamBinary.Size <> 0 then
           _hi_OnEvent( _event_onStreamBinary, StreamBinary );
         end; { For }
        until SQLFetchScroll( fHandle, SQL_FETCH_NEXT, 0 ) = SQL_NO_DATA; { Repeat }
        StreamString.Free;
        StreamBinary.Free;
       end else begin { запрос ничего не вернул }
        ErrorEvent( SQL_SUCCESS, 18 )
       end; { If }
       FreeMem( FD );
       // This is works only if provider support returning multiple record sets from execution
       //R := SQLMoreResults( fHandle );
       //if (R > SQL_SUCCESS_WITH_INFO) and (R <> SQL_NO_DATA) then
       //   //MsgOk( 'Ошибка получения следующего набора данных');
       //   ErrorEvent( R, 7 );
      //UNTIL (R = SQL_NO_DATA);
      SQLCloseCursor( fHandle );
     end; { If }
    end; { If }
  end;

procedure THIODBC.ODBC_Disconnect;
  begin
    SQLFreeHandle( SQL_HANDLE_STMT, fHandle );
    SQLDisconnect( fConnHandle );
    SQLFreeHandle( SQL_HANDLE_DBC, fConnHandle );
    SQLFreeHandle( SQL_HANDLE_ENV, fEnvHandle );
    booConnect := FALSE;
   end;

procedure THIODBC._work_doConnectDSN( var _Data:TData; Index:word );
  begin
    if booConnect then Exit;
    DSN := ReadString( _Data, _data_DSN_Name, _prop_DSN_Name );
    _Data.sdata := '';
    User := ReadString( _Data, _data_UserID, _prop_User_ID );
    Pwd := ReadString( _Data, _data_Password, _prop_Password );
    if ODBC_Connect( '' ) then
     booConnect := TRUE
    else
     //MsgOk( 'Не удалось установить соединение' );
     ErrorEvent( 0, 3 );
  end;

procedure THIODBC._work_doConnectDrv( var _Data:TData; Index:word );
  begin
    if booConnect then Exit;
    StrDBConnect := ReadString( _Data, _data_ConnectionDrv, _prop_ConnectionDrv );
    if ODBC_Connect( StrDBConnect ) then
     booConnect := TRUE
    else
     //MsgOk( 'Не удалось установить соединение' );
     ErrorEvent( 0, 3 );
  end;

procedure THIODBC._work_doDisconnect( var _Data:TData; Index:word );
  begin
    if booConnect Then ODBC_Disconnect;
  end;

procedure THIODBC._work_doExec( var _Data:TData; Index:word );
  var
    R: SQLResult;
  begin
    if booConnect then
    begin
     Txt := ReadString( _Data, _data_Data, '' );
     R := SQLExecDirect( fHandle, PChar( Txt ), Length( Txt ) );
     if (R > SQL_SUCCESS_WITH_INFO) and (R <> SQL_NO_DATA) then
        //MsgOk( 'Не удалось выполнить запрос' )
        ErrorEvent( R, 5 )
     else begin
      R := SQLRowCount( fHandle, @ RowCount );
      if (R > SQL_SUCCESS_WITH_INFO) and (R <> SQL_NO_DATA) then
         //MsgOk( 'Не удалось выполнить запрос' )
         ErrorEvent( R, 5 )
      else _hi_OnEvent( _event_onRowCount, RowCount );
     end; { If }
    end; { If }
  end;

procedure THIODBC._work_doBinary( var _Data:TData; Index:word );
  var
    R: SQLResult;
  begin
    if booConnect then
    begin
     Txt := ReadString( _Data, _data_Data, '' );
     StreamBinary := ReadStream( _data, _data_BinaryStream, nil );
     if StreamBinary <> nil then begin
      StreamBinary.Position := 0;
      BufferSize := StreamBinary.Size;
      if BufferSize > 0 then
      begin
       Buffer := AllocMem( BufferSize );
       StreamBinary.Read( Buffer^, BufferSize );
       R := SQLPrepare( fHandle, PChar( Txt ), Length( Txt ) );
       if R > SQL_SUCCESS_WITH_INFO then
          //MsgOk( 'Не удалось подготовить запрос' )
          ErrorEvent( R, 8 )
       else begin
        R := SQLBindParameter( fHandle,
                              1,
                              SQL_PARAM_INPUT,
                              SQL_C_BINARY,
                              SQL_LONGVARBINARY,
                              BufferSize + 4,
                              0,
                              Buffer,
                              BufferSize,
                              @ BufferSize
                             );
        if R > SQL_SUCCESS_WITH_INFO then
           //MsgOk( 'Не удалось выполнить связывание' )
           ErrorEvent( R, 9 )
        else begin
         R := SQLExecute( fHandle );
         if R > SQL_SUCCESS_WITH_INFO then
            //MsgOk( 'Не удалось выполнить запрос' )
            ErrorEvent( R, 5 )
         else begin
          R := SQLRowCount( fHandle, @ RowCount);
          if (R > SQL_SUCCESS_WITH_INFO) and (R <> SQL_NO_DATA) then
             //MsgOk( 'Не удалось получить RowCount' )
             ErrorEvent( R, 10 )
          else begin
           _hi_OnEvent( _event_onRowCount, RowCount );
          end; { If }
         end; { If }
        end; { If }
       end; { If }
       FreeMem( Buffer );
      end; { If }
     end; { If }
    end; { If }
  end;

procedure THIODBC._work_doList( var _Data:TData; Index:word );
 var
    R: SQLResult;
    BuffDrv: PChar;
    BuffDesc: PChar;
    rdriv, rdesc: Word;
    direct: Smallint;
    bBrowse: Byte;
    sBrowse: String;
    strBrowse: String;
  begin
    sBrowse := 'DRIVERS';
    bBrowse := 0;
    if _prop_BrowseType = 1 then sBrowse := 'DATASOURCES';
    strBrowse := ReadString( _Data, _data_BrowseType, sBrowse );
    if AnsiUpperCase( strBrowse ) = 'DATASOURCES' then bBrowse := 1;
    R := SQLAllocHandle( SQL_HANDLE_ENV,
                         0,
                         @ fEnvHandle
                       );
    if R > SQL_SUCCESS_WITH_INFO then
      //MsgOk( 'Не удалось создать среду ODBC' )
      ErrorEvent( R, 0 )
    else begin
     R := SQLSetEnvAttr( fEnvHandle,
                         SQL_ATTR_ODBC_VERSION,
                         Pointer( SQL_OV_ODBC3 ),
                         SQL_IS_INTEGER
                       );
     if R > SQL_SUCCESS_WITH_INFO then
       //MsgOk( 'Не удалось указать версию ODBC 3.0' )
       ErrorEvent( R, 1 )
     else begin
      BuffDrv := AllocMem( MAXBUFLEN );
      BuffDesc := AllocMem( MAXBUFLEN );
      StreamBinary := NewMemoryStream;
      StreamString := NewMemoryStream;
      direct := SQL_FETCH_FIRST;
      Repeat
       Case bBrowse of
       0:
        R := SQLDrivers( fEnvHandle,
                         direct,
                         BuffDrv,
                         MAXBUFLEN,
                         @ rdriv,
                         BuffDesc,
                         MAXBUFLEN,
                         @ rdesc
                       );
       1:
        R := SQLDataSources( fEnvHandle,
                             direct,
                             BuffDrv,
                             MAXBUFLEN,
                             @ rdriv,
                             BuffDesc,
                             MAXBUFLEN,
                             @ rdesc
                           );
       end; { Case }
       direct := SQL_FETCH_NEXT;
       if (R > SQL_SUCCESS_WITH_INFO) and (R <> SQL_NO_DATA) then
          //MsgOk( 'Не удалось получить список' )
          ErrorEvent( R, 11 )
       else begin
        StreamString.Write( BuffDrv^, rdriv );
        StreamBinary.Write( BuffDesc^, rdesc );
        StreamString.Position := 0;
        StreamBinary.Position := 0;
        _hi_OnEvent( _event_onStreamString, StreamString );
        _hi_OnEvent( _event_onStreamBinary, StreamBinary );
        StreamString.Size := 0;
        StreamBinary.Size := 0;
       end; { If }
      Until R = SQL_NO_DATA;
      StreamString.Free;
      StreamBinary.Free;
      FreeMem( BuffDrv );
      FreeMem( BuffDesc );
      SQLFreeHandle( SQL_HANDLE_ENV, fEnvHandle)
     end; { If }
    end; { If }
  end;

procedure THIODBC._work_doSetup( var _Data:TData; Index:word );
  var
    pFn: TSQLConfigDataSource;
    hLib: LongWord;
    strAttr: Array[0..255] of char;
    strName: string;
    strDriver: string;
    strFile: string;
    strTemp: string;
    i: Word;
  begin
    strDriver := PChar( ReadString( _Data, _data_Driver, _prop_Driver ) );
    strFile := ReadString( _Data, _data_FileDB, _prop_FileDB );
    DSN := ReadString( _Data, _data_DSN_Name, _prop_DSN_Name );
    _Data.sdata := '';
    User := ReadString( _Data, _data_UserID, _prop_User_ID );
    Pwd := ReadString( _Data, _data_Password, _prop_Password );
    if DSN = '' then
      //MsgOk( 'Не задано имя источника данных' )
      ErrorEvent( 0, 12 )
    else begin
     DSN := 'DSN=' + DSN + Chr(0);
     if User <> '' then User := 'UID=' + User + Chr(0);
     if Pwd <> '' then User := 'PWD=' + Pwd + Chr(0);
     if strFile = '' Then
        //MsgOk( 'Не задано имя файла Базы Данных' )
        ErrorEvent( 0, 13 )
     else begin
      hLib := LoadLibrary( 'ODBCCP32' );
      if hLib = 0 then
         //MsgOk( 'Не удалось загрузить ODBCCP32.DLL' )
         ErrorEvent( 0, 14 )
      else begin
       @pFn := GetProcAddress( hLib, 'SQLConfigDataSource' );
       if @pFn = nil then
          //MsgOk( 'Не удалось получить адрес функции SQLConfigDataSource' )
          ErrorEvent( 0, 15 )
       else begin
        strTemp := DSN + User + Pwd +
                   'DBQ=' + strFile + Chr(0)+
                   'Exclusive=' + Int2Str( _prop_Exclusive xor 1 ) + Chr(0) +
                   'ReadOnly=' + Int2Str( _prop_ReadOnly xor 1 ) + Chr(0) +
                   'Description=For HiAsm ODBC component' + Chr(0) + Chr(0);
        for i := 0 To Length( strTemp ) - 1 do strAttr[i] := strTemp[i+1];
        if Not pFn( 0, ODBC_ADD_DSN, @strDriver[1], @strAttr[0] ) then
           //MsgOk( 'Ошибка при создании DSN' );
           ErrorEvent( 0, 16 );
       end; { If }
      end; { If }
      FreeLibrary( hLib );
     end; { If }
    end; { If }
  end;

procedure THIODBC.ColumnsInfo;
  var
    R: SQLResult;
    i: word;
  begin
    R := SQLFetch( fHandle );
    if R = SQL_NO_DATA then
       fdata := false
    else
     if R > SQL_SUCCESS_WITH_INFO then
       ErrorEvent( R, 17 )
     else begin
      fdata := true;
      for i := 0 to fColCount - 1 do begin
       SQLDescribeCol( fHandle,
                      i+1,
                      ColName,
                      Sizeof( ColName ),
                      @ ColLen,
                      @ FD.DataType,
                      @ FD.ColumnSize,
                      @ FD.DecimalDigits,
                      @ FD.Nullable
                     );
       SetString( FieldName, ColName, ColLen );
       FieldType := FD.DataType;
       If ColName <> '' then _hi_OnEvent( _event_onColumnsInfo, ColName );
      end; { For }
     end; { If }
  end;

procedure THIODBC._var_FieldName(var _Data:TData; Index:word);
  begin
    dtString(_Data,FieldName);
  end;

procedure THIODBC._var_FieldType(var _Data:TData; Index:word);
  begin
    dtInteger(_Data,FieldType);
  end;

procedure THIODBC._var_FieldSize(var _Data:TData; Index:word);
  begin
    dtInteger(_Data,FieldSize);
  end;

procedure THIODBC._var_ColumnsCount(var _Data:TData; Index:word);
  begin
    dtInteger(_Data,fColCount);
  end;

procedure THIODBC.ErrorEvent( R:SQLResult; Err:smallint );
  var
    strR: string;
  begin
    if R <> SQL_SUCCESS then
      strR := Int2Str( R ) + ', '
    else
      strR := '';
    if _prop_Error = 0 then
      MsgOk( 'Error:' + strR + ErrorArr[Err].ErrorMessage )
    else
      _hi_OnEvent( _event_onError, ErrorArr[Err].ErrorNumber );
  end;

end.
