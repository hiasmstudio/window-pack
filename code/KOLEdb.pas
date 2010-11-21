unit KOLEdb;
{* This unit is created for KOL to allow to communicate with DB using OLE DB.
|<br> ========================================================================
|<br> Copyright (C) 2001 by Vladimir Kladov.
|<p>
  This unit conains three objects TDataSource, TSession and TQuery to implement
  the most important things: to connect to database, to control transactions,
  to perform commands (queries) and obtain results or update tables.
|</p>
}

interface

{$I share.inc}

{define _db_debug_}

uses Windows, ActiveX, KOL;

type
  tagVariant = packed Record
    vt: WORD;
    reserved1,
    reserved2,
    reserved3: WORD;
    case Integer of
    0: ( bVal       : Byte );
    1: ( iVal       : ShortInt );
    2: ( lVal       : Integer );
    3: ( fltVal     : Extended );
    4: ( dblVal     : Double );
    5: ( boolVal    : Bool );
    6: ( scode      : SCODE );
    //7: ( cyVal      : CY );
    //8: ( date       : Date );
    9: ( bstrVal    : Pointer ); // BSTR => [ Len: Integer; array[ 1..Len ] of WideChar ]
    10:( pdecVal    : ^Decimal );
    end;

(*
typedef struct tagVARIANT  {
   VARTYPE vt;
   unsigned short wReserved1;
   unsigned short wReserved2;
   unsigned short wReserved3;
   union {
      Byte                    bVal;                 // VT_UI1.
      Short                   iVal;                 // VT_I2.
      long                    lVal;                 // VT_I4.
      float                   fltVal;               // VT_R4.
      double                  dblVal;               // VT_R8.
      VARIANT_BOOL            boolVal;              // VT_BOOL.
      SCODE                   scode;                // VT_ERROR.
      CY                      cyVal;                // VT_CY.
      DATE                    date;                 // VT_DATE.
      BSTR                    bstrVal;              // VT_BSTR.
      DECIMAL                 FAR* pdecVal          // VT_BYREF|VT_DECIMAL.
      IUnknown                FAR* punkVal;         // VT_UNKNOWN.
      IDispatch               FAR* pdispVal;        // VT_DISPATCH.
      SAFEARRAY               FAR* parray;          // VT_ARRAY|*.
      Byte                    FAR* pbVal;           // VT_BYREF|VT_UI1.
      short                   FAR* piVal;           // VT_BYREF|VT_I2.
      long                    FAR* plVal;           // VT_BYREF|VT_I4.
      float                   FAR* pfltVal;         // VT_BYREF|VT_R4.
      double                  FAR* pdblVal;         // VT_BYREF|VT_R8.
      VARIANT_BOOL            FAR* pboolVal;        // VT_BYREF|VT_BOOL.
      SCODE                   FAR* pscode;          // VT_BYREF|VT_ERROR.
      CY                      FAR* pcyVal;          // VT_BYREF|VT_CY.
      DATE                    FAR* pdate;           // VT_BYREF|VT_DATE.
      BSTR                    FAR* pbstrVal;        // VT_BYREF|VT_BSTR.
      IUnknown                FAR* FAR* ppunkVal;   // VT_BYREF|VT_UNKNOWN.
      IDispatch               FAR* FAR* ppdispVal;  // VT_BYREF|VT_DISPATCH.
      SAFEARRAY               FAR* FAR* pparray;    // VT_ARRAY|*.
      VARIANT                 FAR* pvarVal;         // VT_BYREF|VT_VARIANT.
      void                    FAR* byref;           // Generic ByRef.
      char                    cVal;                 // VT_I1.
      unsigned short          uiVal;                // VT_UI2.
      unsigned long           ulVal;                // VT_UI4.
      int                     intVal;               // VT_INT.
      unsigned int            uintVal;              // VT_UINT.
      char FAR *              pcVal;                // VT_BYREF|VT_I1.
      unsigned short FAR *    puiVal;               // VT_BYREF|VT_UI2.
      unsigned long FAR *     pulVal;               // VT_BYREF|VT_UI4.
      int FAR *               pintVal;              // VT_BYREF|VT_INT.
      unsigned int FAR *      puintVal;             //VT_BYREF|VT_UINT.
   };
};
*)

{============= This part of code is grabbed from OLEDB.pas ================}
const
  MAXBOUND = 65535; { High bound for arrays }

type
  PIUnknown = ^IUnknown;
  PUintArray = ^TUintArray;
  TUintArray = array[0..MAXBOUND] of UINT;
  HROW = UINT;
  HACCESSOR = UINT;
  HCHAPTER = UINT;
  DBCOLUMNFLAGS = UINT;
  DBTYPE = Word;
  DBKIND = UINT;
  DBPART = UINT;
  DBMEMOWNER = UINT;
  DBPARAMIO = UINT;
  DBBINDSTATUS = UINT;

const
  IID_NULL            : TGUID = '{00000000-0000-0000-0000-000000000000}';
  IID_IDataInitialize : TGUID = '{2206CCB1-19C1-11D1-89E0-00C04FD7A829}';
  CLSID_MSDAINITIALIZE: TGUID = '{2206CDB0-19C1-11D1-89E0-00C04FD7A829}';

  IID_IDBInitialize   : TGUID = '{0C733A8B-2A1C-11CE-ADE5-00AA0044773D}';
  //IID_IDBProperties : TGUID = '{0C733A8A-2A1C-11CE-ADE5-00AA0044773D}';
  IID_IDBCreateSession: TGUID = '{0C733A5D-2A1C-11CE-ADE5-00AA0044773D}';
  IID_IDBCreateCommand: TGUID = '{0C733A1D-2A1C-11CE-ADE5-00AA0044773D}';
  IID_ICommand        : TGUID = '{0C733A63-2A1C-11CE-ADE5-00AA0044773D}';
  IID_ICommandText    : TGUID = '{0C733A27-2A1C-11CE-ADE5-00AA0044773D}';
  IID_IRowset         : TGUID = '{0C733A7C-2A1C-11CE-ADE5-00AA0044773D}';
  IID_IColumnsInfo    : TGUID = '{0C733A11-2A1C-11CE-ADE5-00AA0044773D}';
  IID_IAccessor       : TGUID = '{0C733A8C-2A1C-11CE-ADE5-00AA0044773D}';

  // for version 1.5 of OLE DB:
  //DBGUID_DBSQL      : TGUID = '{c8b522df-5cf3-11ce-ade5-00aa0044773d}';

  // otherwise:
  DBGUID_DBSQL        : TGUID = '{C8B521FB-5CF3-11CE-ADE5-00AA0044773D}';
  DBGUID_DEFAULT      : TGUID = '{C8B521FB-5CF3-11CE-ADE5-00AA0044773D}';
  DBGUID_SQL          : TGUID = '{C8B522D7-5CF3-11CE-ADE5-00AA0044773D}';

  DB_S_ENDOFROWSET    = $00040EC6;

type

// *********************************************************************//
// Interface: IDBInitialize
// GUID:      {0C733A8B-2A1C-11CE-ADE5-00AA0044773D}
// *********************************************************************//
  IDBInitialize = interface(IUnknown)
    ['{0C733A8B-2A1C-11CE-ADE5-00AA0044773D}']
    function Initialize: HResult; stdcall;
    function Uninitialize: HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IDBCreateCommand
// GUID:      {0C733A1D-2A1C-11CE-ADE5-00AA0044773D}
// *********************************************************************//
  IDBCreateCommand = interface(IUnknown)
    ['{0C733A1D-2A1C-11CE-ADE5-00AA0044773D}']
    function CreateCommand(const punkOuter: IUnknown; const riid: TGUID;
      out ppCommand: IUnknown): HResult; stdcall;
  end;

  (*---
  { Safecall Version }
  IDBCreateCommandSC = interface(IUnknown)
    ['{0C733A1D-2A1C-11CE-ADE5-00AA0044773D}']
    procedure CreateCommand(const punkOuter: IUnknown; const riid: TGUID;
      out ppCommand: IUnknown); safecall;
  end;
  ---*)

// *********************************************************************//
// Interface: IDBCreateSession
// GUID:      {0C733A5D-2A1C-11CE-ADE5-00AA0044773D}
// *********************************************************************//
  IDBCreateSession = interface(IUnknown)
    ['{0C733A5D-2A1C-11CE-ADE5-00AA0044773D}']
    function CreateSession(const punkOuter: IUnknown; const riid: TGUID;
      out ppDBSession: IUnknown): HResult; stdcall;
  end;

  (*---
  { Safecall Version }
  IDBCreateSessionSC = interface(IUnknown)
    ['{0C733A5D-2A1C-11CE-ADE5-00AA0044773D}']
    procedure CreateSession(const punkOuter: IUnknown; const riid: TGUID;
      out ppDBSession: IUnknown); safecall;
  end;
  ---*)

// *********************************************************************//
// Interface: IDataInitialize
// GUID:      {2206CCB1-19C1-11D1-89E0-00C04FD7A829}
// *********************************************************************//
  IDataInitialize = interface(IUnknown)
    ['{2206CCB1-19C1-11D1-89E0-00C04FD7A829}']
    function GetDataSource(const pUnkOuter: IUnknown; dwClsCtx: DWORD;
      pwszInitializationString: POleStr; const riid: TIID;
      var DataSource: IUnknown): HResult; stdcall;
    function GetInitializationString(const DataSource: IUnknown;
      fIncludePassword: Boolean; out pwszInitString: POleStr): HResult; stdcall;
    function CreateDBInstance(const clsidProvider: TGUID;
      const pUnkOuter: IUnknown; dwClsCtx: DWORD; pwszReserved: POleStr;
      riid: TIID; var DataSource: IUnknown): HResult; stdcall;
    function CreateDBInstanceEx(const clsidProvider: TGUID;
      const pUnkOuter: IUnknown; dwClsCtx: DWORD; pwszReserved: POleStr;
      pServerInfo: PCoServerInfo; cmq: ULONG; rgmqResults: PMultiQI): HResult; stdcall;
    function LoadStringFromStorage(pwszFileName: POleStr;
      out pwszInitializationString: POleStr): HResult; stdcall;
    function WriteStringToStorage(pwszFileName, pwszInitializationString: POleStr;
      dwCreationDisposition: DWORD): HResult; stdcall;
  end;

  (*---
  { Safecall Version }
  IDataInitializeSC = interface(IUnknown)
    ['{2206CCB1-19C1-11D1-89E0-00C04FD7A829}']
    procedure GetDataSource(const pUnkOuter: IUnknown; dwClsCtx: DWORD;
      pwszInitializationString: POleStr; const riid: TIID;
      var DataSource: IUnknown); safecall;
    procedure GetInitializationString(const DataSource: IUnknown;
      fIncludePassword: Boolean; out pwszInitString: POleStr); safecall;
    procedure CreateDBInstance(const clsidProvider: TGUID;
      const pUnkOuter: IUnknown; dwClsCtx: DWORD; pwszReserved: POleStr;
      riid: TIID; var DataSource: IUnknown); safecall;
    procedure CreateDBInstanceEx(const clsidProvider: TGUID;
      const pUnkOuter: IUnknown; dwClsCtx: DWORD; pwszReserved: POleStr;
      pServerInfo: PCoServerInfo; cmq: ULONG; rgmqResults: PMultiQI); safecall;
    procedure LoadStringFromStorage(pwszFileName: POleStr;
      out pwszInitializationString: POleStr); safecall;
    procedure WriteStringToStorage(pwszFileName, pwszInitializationString: POleStr;
      dwCreationDisposition: DWORD); safecall;
  end;
  ---*)

// *********************************************************************//
// Interface: ICommand
// GUID:      {0C733A63-2A1C-11CE-ADE5-00AA0044773D}
// *********************************************************************//
  ICommand = interface(IUnknown)
    ['{0C733A63-2A1C-11CE-ADE5-00AA0044773D}']
    function Cancel: HResult; stdcall;
    function Execute(const punkOuter: IUnknown; const riid: TGUID;
      pParams: Pointer; // var pParams: DBPARAMS;
      pcRowsAffected: PInteger; ppRowset: PIUnknown): HResult; stdcall;
    function GetDBSession(const riid: TGUID; out ppSession: IUnknown): HResult; stdcall;
  end;

  (*
  { Safecall Version }
  ICommandSC = interface(IUnknown)
    ['{0C733A63-2A1C-11CE-ADE5-00AA0044773D}']
    procedure Cancel; safecall;
    procedure Execute(const punkOuter: IUnknown; const riid: TGUID; var pParams: DBPARAMS;
      pcRowsAffected: PInteger; ppRowset: PIUnknown); safecall;
    procedure GetDBSession(const riid: TGUID; out ppSession: IUnknown); safecall;
  end;
  *)

// *********************************************************************//
// Interface: ICommandText
// GUID:      {0C733A27-2A1C-11CE-ADE5-00AA0044773D}
// *********************************************************************//
  ICommandText = interface(ICommand)
    ['{0C733A27-2A1C-11CE-ADE5-00AA0044773D}']
    function GetCommandText(var pguidDialect: TGUID;
      out ppwszCommand: PWideChar): HResult; stdcall;
    function SetCommandText(rguidDialect: PGUID;
      pwszCommand: PWideChar): HResult; stdcall;
  end;

  (*
  { Safecall Version }
  ICommandTextSC = interface(ICommand)
    ['{0C733A27-2A1C-11CE-ADE5-00AA0044773D}']
    procedure GetCommandText(var pguidDialect: TGUID;
      out ppwszCommand: PWideChar); safecall;
    procedure SetCommandText(rguidDialect: PGUID;
      pwszCommand: PWideChar); safecall;
  end;
  *)

// *********************************************************************//
// Interface: IRowset
// GUID:      {0C733A7C-2A1C-11CE-ADE5-00AA0044773D}
// *********************************************************************//
  IRowset = interface(IUnknown)
    ['{0C733A7C-2A1C-11CE-ADE5-00AA0044773D}']
    function AddRefRows(cRows: UINT; rghRows: PUintArray; rgRefCounts: PUintArray;
      rgRowStatus: PUintArray): HResult; stdcall;
    function GetData(HROW: HROW; HACCESSOR: HACCESSOR; pData: Pointer): HResult; stdcall;
    function GetNextRows(hReserved: HCHAPTER; lRowsOffset: Integer; cRows: Integer;
      out pcRowsObtained: UINT; {var prghRows: PUintArray} prghRows: Pointer ): HResult; stdcall;
    function ReleaseRows(cRows: UINT; rghRows: PUintArray; rgRowOptions,
      rgRefCounts, rgRowStatus: PUintArray): HResult; stdcall;
    function RestartPosition(hReserved: HCHAPTER): HResult; stdcall;
  end;

  (*
  { Safecall Version }
  IRowsetSC = interface(IUnknown)
    ['{0C733A7C-2A1C-11CE-ADE5-00AA0044773D}']
    procedure AddRefRows(cRows: UINT; rghRows: PUintArray; rgRefCounts: PUintArray;
      rgRowStatus: PUintArray); safecall;
    procedure GetData(HROW: HROW; HACCESSOR: HACCESSOR; pData: Pointer); safecall;
    procedure GetNextRows(hReserved: HCHAPTER; lRowsOffset: Integer; cRows: Integer;
      out pcRowsObtained: UINT; var prghRows: PUintArray); safecall;
    procedure ReleaseRows(cRows: UINT; rghRows: PUintArray; rgRowOptions,
      rgRefCounts, rgRowStatus: PUintArray); safecall;
    procedure RestartPosition(hReserved: HCHAPTER); safecall;
  end;
  *)

  PDBIDName = ^TDBIDName;
  DBIDNAME = record
    case Integer of
      0: (pwszName: PWideChar);
      1: (ulPropid: UINT);
  end;
  TDBIDName = DBIDNAME;

  PDBIDGuid = ^TDBIDGuid;
  DBIDGUID = record
    case Integer of
      0: (guid: TGUID);
      1: (pguid: ^TGUID);
  end;
  TDBIDGuid = DBIDGUID;

  PPDBID = ^PDBID;
  PDBID = ^DBID;
  DBID = packed record
    uGuid: DBIDGUID;
    eKind: DBKIND;
    uName: DBIDNAME;
  end;
  TDBID = DBID;

  PDBIDArray = ^TDBIDArray;
  TDBIDArray = array[0..MAXBOUND] of TDBID;

  PDBColumnInfo = ^TDBColumnInfo;
  DBCOLUMNINFO = packed record
    pwszName: PWideChar;
    pTypeInfo: ITypeInfo;
    iOrdinal: UINT;
    dwFlags: DBCOLUMNFLAGS;
    ulColumnSize: UINT;
    wType: DBTYPE;
    bPrecision: Byte;
    bScale: Byte;
    columnid: DBID;
  end;
  TDBColumnInfo = DBCOLUMNINFO;

  PColumnInfo = ^TColumnInfoArray;
  TColumnInfoArray = array[ 0..MAXBOUND ] of TDBColumnInfo;

// *********************************************************************//
// Interface: IColumnsInfo
// GUID:      {0C733A11-2A1C-11CE-ADE5-00AA0044773D}
// *********************************************************************//
  IColumnsInfo = interface(IUnknown)
    ['{0C733A11-2A1C-11CE-ADE5-00AA0044773D}']
    function GetColumnInfo(var pcColumns: UINT; out prgInfo: PDBColumnInfo;
      out ppStringsBuffer: PWideChar): HResult; stdcall;
    function MapColumnIDs(cColumnIDs: UINT; rgColumnIDs: PDBIDArray;
      rgColumns: PUintArray): HResult; stdcall;
  end;

  (*
  { Safecall Version }
  IColumnsInfoSC = interface(IUnknown)
    ['{0C733A11-2A1C-11CE-ADE5-00AA0044773D}']
    procedure GetColumnInfo(var pcColumns: UINT; out prgInfo: PDBColumnInfo;
      out ppStringsBuffer: PWideChar); safecall;
    procedure MapColumnIDs(cColumnIDs: UINT; rgColumnIDs: PDBIDArray;
      rgColumns: PUINTArray); safecall;
  end;
  *)

  PDBBindExt = ^TDBBindExt;
  DBBINDEXT = packed record
    pExtension: PByte;
    ulExtension: UINT;
  end;
  TDBBindExt = DBBINDEXT;

  PDBObject = ^TDBObject;
  DBOBJECT = packed record
    dwFlags: UINT;
    iid: TGUID;
  end;
  TDBObject = DBOBJECT;

  PDBBinding = ^TDBBinding;
  DBBINDING = packed record
    iOrdinal: UINT;
    obValue: UINT;
    obLength: UINT;
    obStatus: UINT;
    pTypeInfo: Pointer; //ITypeInfo; (reserved, should be nil)
    pObject: PDBObject;
    pBindExt: PDBBindExt;
    dwPart: DBPART;
    dwMemOwner: DBMEMOWNER;
    eParamIO: DBPARAMIO;
    cbMaxLen: UINT;
    dwFlags: UINT;
    wType: DBTYPE;
    bPrecision: Byte;
    bScale: Byte;
  end;
  TDBBinding = DBBINDING;

  PDBBindingArray = ^TDBBindingArray;
  TDBBindingArray = array[0..MAXBOUND] of TDBBinding;

const
  DBTYPE_EMPTY     = $00000000;
  DBTYPE_NULL      = $00000001;
  DBTYPE_I2        = $00000002;
  DBTYPE_I4        = $00000003;
  DBTYPE_R4        = $00000004;
  DBTYPE_R8        = $00000005;
  DBTYPE_CY        = $00000006;
  DBTYPE_DATE      = $00000007;
  DBTYPE_BSTR      = $00000008;
  DBTYPE_IDISPATCH = $00000009;
  DBTYPE_ERROR     = $0000000A;
  DBTYPE_BOOL      = $0000000B;
  DBTYPE_VARIANT   = $0000000C;
  DBTYPE_IUNKNOWN  = $0000000D;
  DBTYPE_DECIMAL   = $0000000E;
  DBTYPE_UI1       = $00000011;
  DBTYPE_ARRAY     = $00002000;
  DBTYPE_BYREF     = $00004000;
  DBTYPE_I1        = $00000010;
  DBTYPE_UI2       = $00000012;
  DBTYPE_UI4       = $00000013;
  DBTYPE_I8        = $00000014;
  DBTYPE_UI8       = $00000015;
  DBTYPE_GUID      = $00000048;
  DBTYPE_VECTOR    = $00001000;
  DBTYPE_RESERVED  = $00008000;
  DBTYPE_BYTES     = $00000080;
  DBTYPE_STR       = $00000081;
  DBTYPE_WSTR      = $00000082;
  DBTYPE_NUMERIC   = $00000083;
  DBTYPE_UDT       = $00000084;
  DBTYPE_DBDATE    = $00000085;
  DBTYPE_DBTIME    = $00000086;
  DBTYPE_DBTIMESTAMP = $00000087;

type
// *********************************************************************//
// Interface: IAccessor
// GUID:      {0C733A8C-2A1C-11CE-ADE5-00AA0044773D}
// *********************************************************************//
  IAccessor = interface(IUnknown)
    ['{0C733A8C-2A1C-11CE-ADE5-00AA0044773D}']
    function AddRefAccessor(HACCESSOR: HACCESSOR; pcRefCount: PUINT): HResult; stdcall;
    function CreateAccessor(dwAccessorFlags: UINT; cBindings: UINT; rgBindings: PDBBindingArray;
      cbRowSize: UINT; var phAccessor: HACCESSOR; rgStatus: PUintArray): HResult; stdcall;
    function GetBindings(HACCESSOR: HACCESSOR; pdwAccessorFlags: PUINT; var pcBindings: UINT;
      out prgBindings: PDBBinding): HResult; stdcall;
    function ReleaseAccessor(HACCESSOR: HACCESSOR; pcRefCount: PUINT): HResult; stdcall;
  end;

  (*
  { Safecall Version }
  IAccessorSC = interface(IUnknown)
    ['{0C733A8C-2A1C-11CE-ADE5-00AA0044773D}']
    procedure AddRefAccessor(HACCESSOR: HACCESSOR; pcRefCount: PUINT); safecall;
    procedure CreateAccessor(dwAccessorFlags: UINT; cBindings: UINT; rgBindings: PDBBindingArray;
      cbRowSize: UINT; var phAccessor: HACCESSOR; rgStatus: PUintArray); safecall;
    procedure GetBindings(HACCESSOR: HACCESSOR; pdwAccessorFlags: PUINT; var pcBindings: UINT;
      out prgBindings: PDBBinding); safecall;
    procedure ReleaseAccessor(HACCESSOR: HACCESSOR; pcRefCount: PUINT); safecall;
  end;
  *)

{============= This part of code is designed by me ================}
type
  PDBBINDSTATUSARRAY = ^TDBBINDSTATUSARRAY;
  TDBBINDSTATUSARRAY = array[ 0..MAXBOUND ] of DBBINDSTATUS;

//''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
//  TDataSource - a connection to data base
//,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
type
  TOnOleError = procedure ( Result: HResult ) of object;
  {$ifdef F_P}
  TDataSource = class;
  PDataSource = TDataSource;
  TDataSource = class( TObj )
  {$else}
  PDataSource = ^TDataSource;
  TDataSource = object( TObj )
  {$endif}
  {* This object provides a connection with data base. You create it using
     NewDataSource function and passing a connection string to it. The object
     is initializing immediately after creating. You can get know if the
     connection established successfully reading Intitialized property. }
  private
    fSessions: PList;
    fIDBInitialize: IDBInitialize;
    FInitialized: Boolean;
  protected
    function Initialize( const Params: String ): Boolean;
    procedure CheckOLE( Result: HResult );
  public
    OnError:TOnOleError;
    constructor Create(event:TOnOleError);
    {* Do not call this constructor. Use function NewDataSource instead. }
    destructor Destroy; {$ifndef F_P}virtual{$else}override{$endif};
    {* Do not call this destructor. Use Free method instead. When TDataSource
       object is destroyed, all its sessions (and consequensly, all queries)
       are freed automatically. }
    property Initialized: Boolean read FInitialized;
    {* Returns True, if the connection with database is established. Mainly,
       it is not necessary to analizy this flag. If any error occure during
       initialization, CheckOle halts further execution. (But You can use
       another error handler, which does not stop the application). }
  end;

function NewDataSource( const Params: String; event:TOnOleError ): PDataSource;
{* Creates data source objects and initializes it. Pass a connection
   string as a parameter, which determines used provider, database
   location, user identification and other parameters. See demo provided
   or/and read spicifications from database software vendors, which
   parameters to pass. }

//''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
//  TSession - transaction session in a connection
//,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
type
  {$ifdef F_P}
  TSession = class;
  PSession = TSession;
  TSession = class( TObj )
  {$else}
  PSession = ^TSession;
  TSession = object( TObj )
  {$endif}
  {* This object is intended to provide session transactions. It always
     must be created as a "child" of TDataSource object, and it owns by
     query objects (of type TQuery). For each TDataSource object, it is
     possible to create several TSession objects, and for each session,
     several TQuery objects can exist. }
  private
    fQueryList: PList;
    fDataSource: PDataSource;
    fCreateCommand: IDBCreateCommand;
    procedure CheckOLE( Result: HResult );
  protected
  public
    OnError:TOnOleError;
    constructor Create;
    {* }
    destructor Destroy; {$ifndef F_P}virtual{$else}override{$endif};
    {* Do not call directly, call Free method instead. When TSession object is
       destroyed, all it child queries are freed automatically. }
    property DataSource: PDataSource read fDataSource;
    {* Returns a pointer to owner TDataSource object. }
  end;

function NewSession( ADataSource: PDataSource; event:TOnOleError ): PSession;
{* Creates session object owned by ADataSource (this last must exist). }

//''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
//  TQuery - a command and resulting rowset(s)
//,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
type
  TSqlDateTimeStamp = packed record
    Year, month, day, hour, minute, second: Word;
    fraction: DWORD; // 1/1000 000 000 sec
  end;
  PSqlDateTimeStamp = ^TSqlDateTimeStamp;

  {$ifdef F_P}
  TQuery = class;
  PQuery = TQuery;
  TQuery = class( TObj )
  {$else}
  PQuery = ^TQuery;
  TQuery = object( TObj )
  {$endif}
  {* This is the most important object to work with database. It is always
     must be created as a "child" of TSession object, and allows to perform
     commands, open rowsets, scroll it, update and so on. }
  private
    fSession: PSession;
    fText: String;
    fCommand: ICommandText;
    fRowsAffected: Integer;
    fRowSet: IRowset;
    fColCount: UINT;
    fColInfo: PColumnInfo;
    fColNames: PWideChar;
    fBindings: PDBBindingArray;
    fBindStatus: PDBBINDSTATUSARRAY;
    fRowSize: Integer;
    fAccessor: HACCESSOR;
    fRowHandle: THandle;
    fRowBuffers: PList;
    fEOF: Boolean;
    fCurIndex: Integer;
    
    {$ifdef _db_debug_}
    mlist:PStrList;
    {$endif}
    
    procedure SetText(const Value: String);
    function GetRowCount: Integer;
    function GetColNames(Idx: Integer): String;
    procedure SetCurIndex(const Value: Integer);
    function GetRowsKnown: Integer;
    function GetStrField(Idx: Integer): String;
    function GetIntField(Idx: Integer): Integer;
    function GetInt2Field(Idx: Integer): Integer;
    function GetFltField(Idx: Integer): Double;
    function GetTimeStampField(Idx: Integer): PSqlDateTimeStamp;
    function GetBlobField(Idx: Integer): PStream;
    function CheckOLE( Res: HResult ):boolean;
  protected
    procedure ClearRowset;
    procedure ReleaseHandle;
    procedure FetchData;
    procedure NextWOFetch( Skip: Integer );
  public
    OnError:TOnOleError;
    Error:HResult;
    destructor Destroy; {$ifndef F_P}virtual{$else}override{$endif};
    {* Do not call the destructor directly, call method Free instead. When
       "parent" TSession object is destroyed, all queries owned by the session
       are destroyed automatically. }
    property Session: PSession read fSession;
    {* Returns owner session object. }
    property Text: String read FText write SetText;
    {* Query command text. When You change it, currently opened rowset (if any)
       is closed, so there are no needs to call Close method before preparing
       for new command. Current version does not support passing "parameters",
       so include all values into Text as a part of string. }
    procedure Close;
    {* Closes opened rowset if any. It is not necessary to call clase after
       Execute. Also, rowset is closed automatically when another value is
       assigned to Text property. }
    procedure Execute;
    {* Call this method to execute command (stored in Text), which does not
       open a rowset (thus is, "insert", "delete", and "update" SQL statements
       do so). }
    procedure Open;
    {* Call this method for executing command, which opens a rowset (table of
       data). This can be "select" SQL statement, or call to stored procedure,
       which returns result in a table. }
    property RowCount: Integer read GetRowCount;
    {* For commands, such as "insert", "delete" or "update" SQL statements,
       this property returns number of rows affected by a command. For "select"
       statement performed using Open method, this property should return
       a number of rows selected. By for (the most) providers, this value is
       unknown for first time (-1 is returned). To get know how much rows are
       in returned rowset, method Last should be called first. But for large
       data returned this is not efficient way, because actually a loop
       "while not EOF do Next" is performed to do so.
       |<br>
       Tip: to get count of rows, You can call another query, which executes
       "select count(*) where..." SQL statement with the same conditions. }
    property RowsKnown: Integer read GetRowsKnown;
    {* Returns actual number or selected rows, if this "know" value, or number
       of rows already fetched. }
    property ColCount: UINT read fColCount;
    {* Returns number of columns in opened rowset. }
    property ColNames[ Idx: Integer ]: String read GetColNames;
    {* Return names of columns. }
    property EOF: Boolean read fEOF;
    {* Returns True, if end of data is achived (usually after calling Next
       method, or immediately after Open, if there are no rows in opened
       dataset). }
    procedure First;
    {* Resets a position to the start of rowset. This method is called
       automatically when Open is called successfully. }
    procedure Next;
    {* Moves position to the next row if possible. If EOF achived, a position
       is not changed. }
    procedure Prev;
    {* Moves position to a previous row (but if CurIndex > 0). }
    procedure Last;
    {* Moves position to the last row. This method can be unefficient for
       large datasets, because implemented as a loop where method Next is
       called repeteadly, while EOF is not achieved. }
    property CurIndex: Integer read fCurIndex write SetCurIndex;
    {* Index of current row. It is possible to change it directly even if
       specified row is not yet fetched. But check at least what new value is
       stored in CurIndex after such assignment. }
    property SField[ Idx: Integer ]: String read GetStrField;
    {* Access to a string field by index. You should be sure, that a field
       has string type. }
    property IField[ Idx: Integer ]: Integer read GetIntField;
    property I2Field[ Idx: Integer ]: Integer read GetInt2Field;
    property RField[ Idx: Integer ]: Double read GetFltField;
    property TSField[ Idx: Integer ]: PSqlDateTimeStamp read GetTimeStampField;
    property BlobField[ Idx: Integer ]: PStream read GetBlobField;

    property Bindings:PDBBindingArray read fBindings;
  end;

function NewQuery( Session: PSession; event:TOnOleError ): PQuery;
//procedure addlog(const text:string);
{* Creates query object. }

implementation

var fIMalloc: IMalloc = nil;

type
  PDataStruct = ^TDataStruct;
  TDataStruct = record
    status:DWORD;
    length:integer;
    value:pointer;
  end;
{
procedure addlog(const text:string);
var lst:PStrList;
begin
  lst := NewStrList;
  lst.LoadFromFile('c:\text.txt');
  lst.add(text);
  lst.SaveToFile('c:\text.txt');
  lst.free;
end;
}
procedure TDataSource.CheckOLE( Result: HResult );
begin
  if Result <> 0 then
   if Assigned(onError) then
    OnError(Result)
   else
    MsgOK( 'OLE DB error ' + Int2Hex( Result, 8 ) );
end;

function TQuery.CheckOLE( Res: HResult ):boolean;
begin
  Result := Res <> 0;
  if Res <> 0 then
   begin
     Error := Res;
     if Assigned(onError) then
        OnError(Res)
     else
        MsgOK( 'OLE DB error ' + Int2Hex( Res, 8 ) );
   end;
end;

procedure TSession.CheckOLE( Result: HResult );
begin
  if Result <> 0 then
   if Assigned(onError) then
    OnError(Result)
   else
    MsgOK( 'OLE DB error ' + Int2Hex( Result, 8 ) );
end;

{ TDataSource }

function NewDataSource;
begin
  {$ifdef F_P}
  Result := PDataSource.Create(event);
  {$Else}
  new( Result, Create(event) );
  {$endif}
  Result.Initialize( Params );
end;

constructor TDataSource.Create;
var clsid: TCLSID;
begin
  inherited Create;
  onError := event;
  fSessions := NewList;
  CoInitialize( nil );
  CheckOLE( CoGetMalloc( MEMCTX_TASK, fIMalloc ) );
  CheckOLE( CLSIDFromProgID( 'SQLOLEDB', clsid ) );

  CheckOLE( CoCreateInstance( clsid, nil, CLSCTX_INPROC_SERVER, IID_IDBInitialize, fIDBInitialize ) );
end;

destructor TDataSource.Destroy;
var I: Integer;
begin
  for I := fSessions.Count - 1 downto 0 do
    PObj( fSessions.Items[ I ] ).Free;
  fSessions.Free;
  if Initialized then
    CheckOLE( fIDBInitialize.UnInitialize );
  CoUnInitialize;
  inherited;
end;

function StringToOleStr(const S: string): WideString;
var   len: integer;
begin
   Result := '';
   if s = '' then exit;
   len := MultiByteToWideChar(3, MB_PRECOMPOSED, PChar(@s[1]), -1, nil, 0);
   SetLength(Result, len - 1);
   if len <= 1 then exit;
   MultiByteToWideChar(3, MB_PRECOMPOSED, PChar(@s[1]), -1, PWideChar(@Result[1]), len);
end;

function TDataSource.Initialize( const Params: String ): Boolean;
var DI: IDataInitialize;
    Unk: IUnknown;
begin
  if Initialized then
  begin
    Result := TRUE;
    Exit;
  end;
  CheckOLE( CoCreateInstance( CLSID_MSDAINITIALIZE, nil,
          CLSCTX_ALL, IID_IDataInitialize, DI ) );
  CheckOLE( DI.GetDataSource( nil, CLSCTX_ALL, PWchar(StringToOleStr(Params)),
            IID_IDBInitialize, Unk ) );
  CheckOLE( Unk.QueryInterface( IID_IDBInitialize, fIDBInitialize ) );
  CheckOLE( fIDBInitialize.Initialize );
  Result := TRUE;
  FInitialized := Result;
end;

{ TSession }

function NewSession( ADataSource: PDataSource; event:TOnOleError ): PSession;
var CreateSession: IDBCreateSession;
begin
  {$ifdef F_P}
  Result := PSession.Create;
  {$else}
  new( Result, Create );
  {$endif}
  Result.onError := event;
  Result.fDataSource := ADataSource;
  ADataSource.fSessions.Add( Result );
  Result.CheckOLE( ADataSource.fIDBInitialize.QueryInterface( IID_IDBCreateSession, CreateSession ) );
  Result.CheckOLE( CreateSession.CreateSession( nil, IID_IDBCreateCommand,
            IUnknown( Result.fCreateCommand ) ) );
end;

constructor TSession.Create;
begin
  inherited;
  fQueryList := NewList;
end;

destructor TSession.Destroy;
var I: Integer;
begin
  for I := fQueryList.Count - 1 downto 0 do
    PObj( fQueryList.Items[ I ] ).Free;
  fQueryList.Free;
  I := fDataSource.fSessions.IndexOf( {$ifndef F_P}@{$endif}Self );
  fDataSource.fSessions.Delete( I );
  fCreateCommand := nil;
  inherited;
end;

{ TQuery }

function NewQuery( Session: PSession; event:TOnOleError ): PQuery;
begin
  {$ifdef F_P}
  Result := PQuery.Create;
  {$else}
  new( Result, Create );
  {$endif}
  Result.onError := event;
  Result.fSession := Session;
  {$ifdef _db_debug_}
  Result.mlist := NewStrList;
  {$endif}

  Session.fQueryList.Add( Result );
  Result.CheckOLE( Session.fCreateCommand.CreateCommand( nil, IID_ICommandText,
            IUnknown( Result.fCommand ) ) );
end;

procedure TQuery.ClearRowset;
var I: Integer;
    AccessorIntf: IAccessor;
begin
  ReleaseHandle;

  if fAccessor <> 0 then
  begin
    CheckOLE( fRowSet.QueryInterface( IID_IAccessor, AccessorIntf ) );
    AccessorIntf.ReleaseAccessor( fAccessor, nil );
    fAccessor := 0;
  end;

  if fRowBuffers <> nil then
  begin
    for I := fRowBuffers.Count - 1 downto 0 do
      FreeMem( fRowBuffers.Items[ I ] );
    fRowBuffers.Free;
    fRowBuffers := nil;
  end;
  fRowSize := 0;

  if fBindings <> nil then
  begin
    //for I := 0 to fColCount - 1 do
    //  fBindings[ I ].pTypeInfo := nil;
    FreeMem( fBindings );
    fBindings := nil;
    FreeMem( fBindStatus );
    fBindStatus := nil;
  end;

  if fColInfo <> nil then
    fIMalloc.Free( fColInfo );
  fColInfo := nil;

  if fColNames <> nil then
    fIMalloc.Free( fColNames );
  fColNames := nil;

  fColCount := 0;
  fRowSet := nil;
  fRowsAffected := 0;

  fEOF := TRUE;
end;

procedure TQuery.Close;
begin
  ClearRowset;
end;

destructor TQuery.Destroy;
var I: Integer;
begin
  {$ifdef _db_debug_}
  mlist.savetofile('c:\db.txt');
  {$endif}
  ClearRowset;
  I := fSession.fQueryList.IndexOf( {$ifndef F_P}@{$endif}Self );
  if I >= 0 then
    fSession.fQueryList.Delete( I );
  fText := '';
  fCommand := nil;
  inherited;
end;

procedure TQuery.Execute;
begin
  ClearRowset;
  // first set txt to fCommand just before execute
  CheckOLE( fCommand.SetCommandText( @DBGUID_DBSQL, PWchar(StringToOleStr(fText)) ) );
  CheckOLE( fCommand.Execute( nil, IID_NULL, nil, @fRowsAffected, nil ) );
end;

procedure TQuery.FetchData;
var Buffer: Pointer;
begin
  if fRowHandle = 0 then
    Exit;
  {if fRowBuffers = nil then
    fRowBuffers := NewList;
  if fCurIndex >= fRowBuffers.Count then
    fRowBuffers.Add( nil );}
  if fRowBuffers.Items[ fCurIndex ] = nil then
  begin
//    MessageBox(0,'ok',pchar(int2str(fRowSize)),mb_ok);
    GetMem( Buffer, 256*1024 );
    fRowBuffers.Items[ fCurIndex ] := Buffer;
    CheckOLE( fRowSet.GetData( fRowHandle, fAccessor, fRowBuffers.Items[ fCurIndex ] ) );
  end;
end;

procedure TQuery.First;
begin
  ReleaseHandle;
  fCurIndex := -1;
  CheckOLE( fRowSet.RestartPosition( 0 ) );
  fEOF := FALSE;
  Next;
end;

function TQuery.GetColNames(Idx: Integer): String;
begin
  Result := fColInfo[ Idx ].pwszName;
end;

function TQuery.GetFltField(Idx: Integer): Double;
var P: Pointer;
begin
  Result := 0.0;
  if (fRowSet = nil) or (fCurIndex < 0) or (DWORD(Idx) >= ColCount) then
    Exit;
  P := Pointer( DWORD( fRowBuffers.Items[ fCurIndex ] ) +
                   fBindings[ Idx ].obValue );
  if fBindings[ Idx ].wType = DBTYPE_R4 then
    Result := PExtended( P )^
  else
    Result := PDouble( P )^;
end;

function TQuery.GetTimeStampField;
var P: Pointer;
    dt:PDataStruct;
begin
  Result := nil;
  if (fRowSet = nil) or (fCurIndex < 0) or (DWORD(Idx) >= ColCount) then
    Exit;
  dt := PDataStruct(dword(fRowBuffers.Items[fCurIndex]) + fBindings[Idx].obStatus);
  if dt.Status and $03 > 0 then
    exit;
  P := Pointer( DWORD( fRowBuffers.Items[ fCurIndex ] ) + fBindings[ Idx ].obValue );
  {$ifdef _db_debug_}
  mlist.add(Format('DATE - val: %d, stat: %d, len: %d',[dt.Value, dt.Status, dt.Length]));
  {$endif}

  Result := PSqlDateTimeStamp(P);
end;

function TQuery.GetBlobField;
var P: Pointer;
    dt:PDataStruct;
begin
  Result := nil;
  if (fRowSet = nil) or (fCurIndex < 0) or (DWORD(Idx) >= ColCount) then
    Exit;
  dt := PDataStruct(dword(fRowBuffers.Items[fCurIndex]) + fBindings[Idx].obStatus);
  if dt.Status and $03 > 0 then
    exit;
  P := Pointer( DWORD( fRowBuffers.Items[ fCurIndex ] ) + fBindings[ Idx ].obValue );
  {$ifdef _db_debug_}
  mlist.add(Format('BLOB - val: %d, stat: %d, len: %d',[dt.Value, dt.Status, dt.Length]));
  {$endif}

  Result := NewMemoryStream;
  Result.Write(p^, dt.Length);
  Result.position := 0;
end;


function TQuery.GetIntField(Idx: Integer): Integer;
var P: Pointer;
    dt:PDataStruct;
begin
  Result := 0;
  if (fRowSet = nil) or (fCurIndex < 0) or (DWORD(Idx) >= ColCount) then
    Exit;
  dt := PDataStruct(dword(fRowBuffers.Items[fCurIndex]) + fBindings[Idx].obStatus);
  if dt.Status and $03 > 0 then
    exit;
  P := Pointer( DWORD( fRowBuffers.Items[ fCurIndex ] ) + fBindings[ Idx ].obValue );
  {$ifdef _db_debug_}
  mlist.add(Format('INT - val: %d, stat: %d, len: %d, type: %d',[dt.Value, dt.Status, dt.Length, fBindings[Idx].wType]));
  {$endif}
  
  if fBindings[Idx].wType = DBTYPE_I2 then
    Result := PShortInt(P)^
  else if fBindings[Idx].wType = DBTYPE_BOOL then
    if byte(P^) = 0 then
      Result := 0
    else Result := 1
  else
    Result := PInteger(P)^;
end;

function TQuery.GetInt2Field(Idx: Integer): Integer;
var P: Pointer;
    dt:PDataStruct;
begin
  Result := 0;
  if (fRowSet = nil) or (fCurIndex < 0) or (DWORD(Idx) >= ColCount) then
    Exit;
  dt := PDataStruct(dword(fRowBuffers.Items[fCurIndex]) + fBindings[Idx].obStatus);
  if dt.Status and $03 > 0 then
    exit;
  P := Pointer( DWORD( fRowBuffers.Items[ fCurIndex ] ) + fBindings[ Idx ].obValue );
  {$ifdef _db_debug_}
  mlist.add(Format('INT - val: %d, stat: %d, len: %d, type: %d',[dt.Value, dt.Status, dt.Length, fBindings[Idx].wType]));
  {$endif}
  
  Result := smallint(P^);
end;

function TQuery.GetRowCount: Integer;
begin
  {if fRowsAffected = DB_S_ASYNCHRONOUS then
  begin
    // only for asynchronous connections - do not see now
  end;}
  Result := fRowsAffected;
end;

function TQuery.GetRowsKnown: Integer;
begin
  Result := fRowsAffected;
  if Result = 0 then
  if fRowBuffers <> nil then
    Result := fRowBuffers.Count;
end;

function TQuery.GetStrField(Idx: Integer): String;
var P: Pointer;
    dt:PDataStruct;
begin
  Result := '';
  if (fRowSet = nil) or (fCurIndex < 0) or (DWORD(Idx) >= ColCount) then
    Exit;
  P := Pointer(DWORD(fRowBuffers.Items[fCurIndex]) + fBindings[Idx].obValue);
  dt := PDataStruct(dword(fRowBuffers.Items[fCurIndex]) + fBindings[Idx].obStatus);
  if dt.Status and $03 > 0 then
    exit;
  {$ifdef _db_debug_}
//  dt := PDataStruct(dword(fRowBuffers.Items[fCurIndex]) + fBindings[Idx].obStatus);
  mlist.add(Format('STR - val: %d, stat: %d, len: %d',[dt.Value, dt.Status, dt.Length]));
  {$endif}

  if fBindings[ Idx ].wType = DBTYPE_STR then
    Result := PChar( P )
  else
    Result := PWideChar( P );
end;

procedure TQuery.Last;
begin
  while not EOF do
    Next; //WOFetch( 0 );
  if RowsKnown > 0 then
    fCurIndex := RowsKnown;
  Prev;
  FetchData;
  fEOF := FALSE;
end;

procedure TQuery.Next;
begin
  NextWOFetch( 0 );
  FetchData;
end;

procedure TQuery.NextWOFetch( Skip: Integer );
var Obtained: UINT;
    PHandle: Pointer;
    hr: HResult;
begin
  ReleaseHandle;
  PHandle := @fRowHandle;
  hr := fRowSet.GetNextRows( 0, Skip, 1, Obtained, @PHandle );
  if hr <> DB_S_ENDOFROWSET then
    CheckOLE( hr );
  if Obtained = 0 then
  begin
    fEOF := TRUE;
    if fRowBuffers <> nil then
      fRowsAffected := fRowBuffers.Count;
  end
    else
  begin
    Inc( fCurIndex );
    if fRowBuffers = nil then
      fRowBuffers := NewList;
    if fCurIndex >= fRowBuffers.Count then
      fRowBuffers.Add( nil );
  end;
end;

procedure TQuery.Open;
var ColInfo: IColumnsInfo;
    AccessorIntf: IAccessor;
    I: Integer;
begin
  Error := 0; 
  ClearRowset;
  if CheckOLE( fCommand.SetCommandText( @DBGUID_DBSQL, PWchar(StringToOleStr(fText)) ) ) then exit;
  if CheckOLE( fCommand.Execute( nil, IID_IROWSET, nil, @fRowsAffected, PIUnknown( @fRowSet ) ) ) then exit;
  if fRowsAffected = 0 then
    Dec( fRowsAffected ); // RowCount = -1 means that RowCount is an unknown value
  if CheckOLE( fRowSet.QueryInterface( IID_IColumnsInfo, ColInfo ) ) then exit;
  if CheckOLE( ColInfo.GetColumnInfo( fColCount, PDBColumnInfo( fColInfo ), fColNames ) ) then exit;
  GetMem( fBindings, Sizeof( TDBBinding ) * fColCount );
  FillChar( fBindings^, Sizeof( TDBBinding ) * fColCount, 0 );
  for I := 0 to fColCount - 1 do
  begin
        fBindings[ I ].iOrdinal   := I + 1;
        fBindings[ I ].obValue    := fRowSize + sizeof(DWORD) + sizeof(integer);
        fBindings[ I ].obLength   := fRowSize + sizeof(DWORD);
        fBindings[ I ].obStatus   := fRowSize + 0;
    //  fBindings[ I ].pTypeInfo  := nil;
    //  fBindings[ I ].pObject    := nil;
    //  fBindings[ I ].pBindExt   := nil;
        fBindings[ I ].dwPart     := $01 or $02 or $04;
    //  fBindings[ I ].dwMemOwner := 0; //DBMEMOWNER_CLIENTOWNED;
    //  fBindings[ I ].eParamIO   := 0; //DBPARAMIO_NOTPARAM;
        if fColInfo[I].wType = DBTYPE_BYTES then
        fBindings[ I ].cbMaxLen   := 256*1024
        else
        fBindings[ I ].cbMaxLen   := fColInfo[ I ].ulColumnSize + 1;
    //  fBindings[ I ].dwFlags    := 0;
        fBindings[ I ].wType      := fColInfo[ I ].wType;
        fBindings[ I ].bPrecision := fColInfo[ I ].bPrecision;
        fBindings[ I ].bScale     := fColInfo[ I ].bScale;
        Inc( fRowSize, fBindings[I].cbMaxLen + 4+4);
//        messagebox(0, pchar('row - ' + int2hex(fColInfo[I].wType, 8)), pchar(''), MB_OK);
  end;
  GetMem( fBindStatus, Sizeof( DBBINDSTATUS ) * fColCount );
  if CheckOLE( fRowSet.QueryInterface( IID_IAccessor, AccessorIntf ) ) then exit;
  AccessorIntf.CreateAccessor(
    2, //DBACCESSOR_ROWDATA, // Accessor will be used to retrieve row data
    fColCount,  // Number of columns being bound
    fBindings,  // Structure containing bind info
    0,          // Not used for row accessors
    fAccessor,  // Returned accessor handle
    PUIntArray( fBindStatus ) // Information about binding validity
    );
  fEOF := FALSE;
  fCurIndex := -1;
  First;
end;

procedure TQuery.Prev;
begin
  if CurIndex > 0 then
  begin
    //NextWOFetch( -2 );
    Dec( fCurIndex );
    fEOF := FALSE;
    //FetchData;
  end;
end;

procedure TQuery.ReleaseHandle;
begin
  if fRowHandle <> 0 then
    CheckOLE( fRowSet.ReleaseRows( 1, @fRowHandle, nil, nil, nil ) );
  fRowHandle := 0;
end;

procedure TQuery.SetCurIndex(const Value: Integer);
var OldCurIndex: Integer;
begin
  if fCurIndex = Value then
    Exit;
  OldCurIndex := fCurIndex;
  if Value = 0 then
    First
  else
  if Value = fRowsAffected - 1 then
    Last;
  fEOF := FALSE;
  while (fCurIndex < Value) and not EOF do
    Next;
  while (fCurIndex > Value) and not EOF do
    Prev;
  if fCurIndex = Value then
    FetchData
  else
    fCurIndex := OldCurIndex;
end;

procedure TQuery.SetText(const Value: String);
begin
  // clear here current rowset if any:
  ClearRowset;
  {// set txt to fCommand -- do this at the last moment just before execute
  CheckOLE( fCommand.SetCommandText( DBGUID_DBSQL, PWchar(StringToOleStr(Value)) ) );}
  FText := Value;
end;

end.
