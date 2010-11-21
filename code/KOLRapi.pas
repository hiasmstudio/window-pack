unit KOLRapi;

interface

uses Windows, Kol;
// --------------------------------------------------------------------------
//
//       Unit KolRapi v 1.0
//       Author: Wolfik
//       wolfik@doctor.com
//
//       Relized 17/08/08
//       22/08/08: Some fixes
//
// --------------------------------------------------------------------------

const

VER_PLATFORM_WIN32_CE = 3;

CERAPI_E_ALREADYINITIALIZED = $80041001;

{FindAllFiles FAF}
{The filter flags}
FAF_ATTRIB_CHILDREN          = $00001000;
FAF_ATTRIB_NO_HIDDEN         = $00002000;
FAF_FOLDERS_ONLY             = $00004000;
FAF_NO_HIDDEN_SYS_ROMMODULES = $00008000;
FAF_GETTARGET                = $00010000;
{The retrieval flags}
FAF_ATTRIBUTES               = $00000001;
FAF_CREATION_TIME            = $00000002;
FAF_LASTACCESS_TIME          = $00000004;
FAF_LASTWRITE_TIME           = $00000008;
FAF_SIZE_HIGH                = $00000010;
FAF_SIZE_LOW                 = $00000020;
FAF_OID                      = $00000040;
FAF_NAME                     = $00000080;
FAF_FLAG_COUNT               = 8;

{File Attributes}
FILE_ATTRIBUTE_INROM         = $00000040;
FILE_ATTRIBUTE_SPARSE_FILE   = $00000200;
FILE_ATTRIBUTE_REPARSE_POINT = $00000400;
FILE_ATTRIBUTE_ROMSTATICREF  = $00001000;
//FILE_ATTRIBUTE_NOT_CONTENT_INDEXED = $00002000;
FILE_ATTRIBUTE_ROMMODULE     = $00002000;
FILE_ATTRIBUTE_ENCRYPTED     = $00004000;
FILE_ATTRIBUTE_HAS_CHILDREN  = $00010000;
FILE_ATTRIBUTE_SHORTCUT		   = $00020000;

{FindAllDatabases FAD}
FAD_OID            = $1;
FAD_FLAGS          = $2;
FAD_NAME           = $4;
FAD_TYPE           = $8;
FAD_NUM_RECORDS    = $10;
FAD_NUM_SORT_ORDER = $20;
FAD_SIZE           = $40;
FAD_LAST_MODIFIED  = $80;
FAD_SORT_SPECS     = $100;
FAD_FLAG_COUNT     = $9;

OBJTYPE_INVALID   = 0;
OBJTYPE_FILE      = 1;
OBJTYPE_DIRECTORY = 2;
OBJTYPE_DATABASE  = 3;
OBJTYPE_RECORD    = 4;

CeVT_I2       = 2;
CeVT_I4       = 3;
CEVT_R8       = 5;
CEVT_BOOL     = 11;
CeVT_UI2      = 18;
CeVT_UI4      = 19;
CeVT_LPWSTR   = 31;
CeVT_FILETIME = 64;
CeVT_BLOB     = 65;

CeVT_FLAG_EMPTY = $0400;

CeDB_SORT_DESCENDING      = $00000001;
CeDB_SORT_CASEINSENSITIVE = $00000002;
CeDB_SORT_UNKNOWNFIRST    = $00000004;
CeDB_SORT_GENERICORDER    = $00000008;

CeDB_MAXDBASENAMELEN = 32;
CeDB_MAXSORTORDER    = 4;

CeDB_VALIDNAME     = $0001;
CeDB_VALIDTYPE     = $0002;
CeDB_VALIDSORTSPEC = $0004;
CeDB_VALIDMODTIME  = $0008;

CeDB_AUTOINCREMENT = $00000001;

CeDB_SEEK_CeOID           = $00000001;
CeDB_SEEK_BEGINNING       = $00000002;
CeDB_SEEK_END             = $00000004;
CeDB_SEEK_CURRENT         = $00000008;
CeDB_SEEK_VALUESMALLER    = $00000010;
CeDB_SEEK_VALUEFIRSTEQUAL = $00000020;
CeDB_SEEK_VALUEGREATER    = $00000040;
CeDB_SEEK_VALUENEXTEQUAL  = $00000080;

CeDB_PROPNOTFOUND     = $0100;
CeDB_PROPDELETE       = $0200;
CeDB_MAXDATABLOCKSIZE = 4092;
CeDB_MAXPROPDATASIZE  = (CeDB_MAXDATABLOCKSIZE*16);
CeDB_MAXRECORDSIZE    = (128*1024);

CeDB_ALLOWREALLOC   =$00000001;

{SYSTEM_POWER_STATUS}
AC_LINE_OFFLINE      = $00;
AC_LINE_ONLINE       = $01;
AC_LINE_BACKUP_POWER = $02;
AC_LINE_UNKNOWN      = $FF;

BATTERY_FLAG_HIGH       = $01 ;
BATTERY_FLAG_LOW        = $02 ;
BATTERY_FLAG_CRITICAL   = $04 ;
BATTERY_FLAG_CHARGING   = $08 ;
BATTERY_FLAG_NO_BATTERY = $80 ;
BATTERY_FLAG_UNKNOWN    = $FF ;

BATTERY_PERCENTAGE_UNKNOWN = $FF;

BATTERY_LIFE_UNKNOWN = $FFFFFFFF;

PROCESSOR_INTEL_386       = 386;
PROCESSOR_INTEL_486       = 486;
PROCESSOR_INTEL_PENTIUM   = 586;
PROCESSOR_INTEL_PENTIUMII = 686;
PROCESSOR_MIPS_R4000      = 4000;
PROCESSOR_ALPHA_21064     = 21064;
PROCESSOR_PPC_403         = 403;
PROCESSOR_PPC_601         = 601;
PROCESSOR_PPC_603         = 603;
PROCESSOR_PPC_604         = 604;
PROCESSOR_PPC_620         = 620;
PROCESSOR_HITACHI_SH3     = 10003;
PROCESSOR_HITACHI_SH3E    = 10004;
PROCESSOR_HITACHI_SH4     = 10005;
PROCESSOR_MOTOROLA_821    = 821;
PROCESSOR_SHx_SH3         = 103;
PROCESSOR_SHx_SH4         = 104;
PROCESSOR_SHx_SH3DSP      = 105;
PROCESSOR_STRONGARM       = 2577;
PROCESSOR_ARM720          = 1824;
PROCESSOR_ARM820          = 2080;
PROCESSOR_ARM920          = 23360;
PROCESSOR_ARM_7TDMI       = 70001;

PROCESSOR_ARCHITECTURE_INTEL   = 0;
PROCESSOR_ARCHITECTURE_MIPS    = 1;
PROCESSOR_ARCHITECTURE_ALPHA   = 2;
PROCESSOR_ARCHITECTURE_PPC     = 3;
PROCESSOR_ARCHITECTURE_SHX     = 4;
PROCESSOR_ARCHITECTURE_ARM     = 5;
PROCESSOR_ARCHITECTURE_IA64    = 6;
PROCESSOR_ARCHITECTURE_ALPHA64 = 7;
PROCESSOR_ARCHITECTURE_UNKNOWN = $FFFF;

{CeGetSpecialFolderPath attribs}
CSIDL_APPDATA          = $001A; // \Application Data
CSIDL_BITBUCKET        = $000A; // \???
CSIDL_DESKTOP          = $0000; // \My Documents
CSIDL_DESKTOPDIRECTORY = $0010; // \???
CSIDL_DRIVES           = $0011; // \???
CSIDL_FAVORITES        = $0006; // \Windows\Favorites
CSIDL_FONTS            = $0014; // \Windows\Fonts
CSIDL_PERSONAL         = $0005; // \My Documents
CSIDL_PROFILE          = $0028; // \???
CSIDL_PROGRAM_FILES    = $0026; // \Program Files
CSIDL_PROGRAMS         = $0002; // \???
CSIDL_RECENT           = $0008; // \???
CSIDL_STARTMENU        = $000B; // \Windows\Start Menu
CSIDL_STARTUP          = $0007; // \Windows\StartUp
CSIDL_WINDOWS          = $0024; // \Windows

type

CE_FIND_DATA = record
  dwFileAttributes: DWORD;
  ftCreationTime: TFileTime;
  ftLastAccessTime: TFileTime;
  ftLastWriteTime: TFileTime;
  nFileSizeHigh: DWORD;
  nFileSizeLow: DWORD;
  dwOID: DWORD;
  cFileName: array[0..MAX_PATH - 1] of WideChar;
end;
TCeFindData = CE_FIND_DATA;
PCeFindData = ^TCeFindData;
TCeFindDataArray = array[0..MaxInt div sizeof(TCeFindData) - 1] of TCeFindData;
PCeFindDataArray = ^TCeFindDataArray;

STORE_INFORMATION = record
  dwStoreSize: DWORD;
  dwFreeSize: DWORD;
end;
TStoreInformation = STORE_INFORMATION;
PStoreInformation = ^TStoreInformation;

CEGUID = record
  Data1: DWORD;
  Data2: DWORD;
  Data3: DWORD;
  Data4: DWORD;
end;
TCeGUID = CEGUID;
PCeGUID = ^TCeGUID;

CEPROPID = DWORD;
TCePROPID = CEPROPID;
PCePROPID = ^TCePROPID;
TCePropIDArray = array[0..MaxInt div sizeof(TCePROPID) - 1] of TCePROPID;
PCePropIDArray = ^TCePropIDArray;

CEOID = DWORD;
TCeOID = CEOID;
PCeOID = ^TCeOID;

CEFILEINFO = record
  dwAttributes: DWORD;
  oidParent: TCeOID;
  szFileName: array [0..MAX_PATH - 1] of WCHAR;
  ftLastChanged: TFileTime;
  dwLength: DWORD;
end;
TCeFileInfo = CEFILEINFO;

CEDIRINFO = record
  dwAttributes: DWORD;
  oidParent: TCeOID;
  szDirName: array [0..MAX_PATH - 1] of WCHAR;
end;
TCeDirInfo = CEDIRINFO;

CERECORDINFO = record
  oidParent: TCeOID;
end;
TCeRecordInfo = CERECORDINFO;

SORTORDERSPEC = record
  propid: TCePROPID;
  dwFlags: DWORD;
end;
TSortOrderSpec = SORTORDERSPEC;

CEDBASEINFO = record
  dwFlags: DWORD;
  szDbaseName: array [0..CeDB_MAXDBASENAMELEN - 1] of WCHAR;
  dwDbaseType: DWORD;
  wNumRecords: WORD;
  wNumSortOrder: WORD;
  dwSize: DWORD;
  ftLastModified: TFileTime;
  rgSortSpecs: array [0..CeDB_MAXSORTORDER - 1] of TSortOrderSpec;
end;
TCeDBaseInfo = CEDBASEINFO;
PCeDBaseInfo = ^TCeDBaseInfo;

CEDB_FIND_DATA = record
  OidDb: TCeOID;
  DbInfo: TCeDBaseInfo;
end;
TCeDBFindData = CEDB_FIND_DATA;
PCeDBFindData = ^TCeDBFindData;
TCeDBFindDataArray = array [0..MaxInt div sizeof(TCeDBFindData) - 1] of TCeDBFindData;
PCeDBFindDataArray = ^TCeDBFindDataArray;

CEOIDINFO = record
  wObjType: WORD;
  wPad: WORD;
  case Integer of
   0: ( infFile       : TCeFileInfo );
   1: ( infDirectory  : TCeDirInfo );
   2: ( infDatabase   : TCeDBaseInfo );
   3: ( infRecord     : TCeRecordInfo );
end;
TCeOIdInfo = CEOIDINFO;
PCeOIDInfo = ^TCeOIDInfo;

CEBLOB = record
  dwCount: DWORD;
  lpb: DWORD;
end;
TCeBlob = CEBLOB;

CEVALUNION = record
  case Integer of
   0: ( iVal    : SHORT );
   1: ( uiVal   : WORD );
   2: ( lVal    : LONGINT );
   3: ( ulVal   : ULONG );
   4: ( filetime: TFILETIME );
   5: ( lpwstr  : LPWSTR );
   6: ( blob    : TCeBlob );
   7: ( boolVal : BOOL );
   8: ( dblVal  : DOUBLE );
end;
TCeValUnion = CEVALUNION;

CEPROPVAL = record
  propid: TCePROPID ;
  wLenData: WORD;
  wFlags: WORD;
  val: TCeValUnion;
end;
TCePROPVAL = CEPROPVAL;
PCePROPVAL = ^TCePROPVAL;

CEOSVERSIONINFO = record
  dwOSVersionInfoSize: DWORD;
  dwMajorVersion: DWORD;
  dwMinorVersion: DWORD;
  dwBuildNumber: DWORD;
  dwPlatformId: DWORD;
  szCSDVersion: array[0..128 - 1] of WCHAR;
end;
TCeOSVersionInfo = CEOSVERSIONINFO;
PCeOSVersionInfo = ^TCeOSVersionInfo;

SYSTEM_POWER_STATUS_EX = record
  ACLineStatus: BYTE;
  BatteryFlag: BYTE;
  BatteryLifePercent: BYTE;
  Reserved1: BYTE;
  BatteryLifeTime: DWORD;
  BatteryFullLifeTime: DWORD;
  Reserved2: BYTE;
  BackupBatteryFlag: BYTE;
  BackupBatteryLifePercent: BYTE;
  Reserved3: BYTE;
  BackupBatteryLifeTime: DWORD;
  BackupBatteryFullLifeTime: DWORD;
end;
TSystemPowerStatusEx = SYSTEM_POWER_STATUS_EX;
PSystemPowerStatusEx = ^TSystemPowerStatusEx;
TSystemPowerStatusExArray = array [0..MaxInt div Sizeof(TSystemPowerStatusEx) - 1] of TSystemPowerStatusEx;
PSystemPowerStatusExArray = ^TSystemPowerStatusExArray;

RAPIINIT = record
  cbSize: DWORD;
  heRapiInit: THandle;
  hrRapiInit: HResult;
end;
TRapiInit = RAPIINIT;

IRAPIStream = record
  f1: DWORD;
  f2: DWORD;
end;
pIRAPIStream = ^IRAPIStream;
ppIRAPIStream = ^pIRAPIStream;

PBYTE = ^BYTE;
PPBYTE = ^PBYTE;

function CeCheckPassword(lpszPassword: LPWSTR): BOOL; stdcall;
function CeCloseHandle(hObject: THandle): BOOL; stdcall;
function CeCopyFile(lpExistingFileName: LPCWSTR; lpNewFileName: LPCWSTR; bFailIfExists: BOOL): BOOL; stdcall;
function CeCreateDatabase(lpszName: LPWSTR; dwDbaseType: DWORD; wNumSortOrder: WORD;
  var rgSortSpecs: TSortOrderSpec): TCeOID; stdcall;
function CeCreateDatabaseEx(mpceguid: PCeGUID; lpCEDBInfo: PCeDBaseInfo): TCeOID; stdcall;

function CeCreateDirectory(lpPathName: LPCWSTR; lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;
function CeCreateFile(lpFileName: LPCWSTR; dwDesiredAccess: DWORD; dwShareMode: DWORD;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDistribution: DWORD;
  dwFlagsAndAttributes: DWORD; hTemplateFile: THandle): THandle; stdcall;
function CeCreateProcess(lpApplicationName: LPCWSTR; lpCommandLine: LPCWSTR; lpProcessAttributes: PSecurityAttributes;
  lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL; dwCreateFlags: DWORD; lpEnvironment: Pointer;
  lpCurrentDirectory: LPWSTR; lpStartupInfo: PSTARTUPINFO; lpProcessInformation: PProcessInformation): BOOL; stdcall;
function CeDeleteDatabase(oidDBase: TCeOID): BOOL; stdcall;
function CeDeleteDatabaseEx(mpceguid: PCeGUID; oid: TCeOID): BOOL; stdcall;

function CeDeleteFile(lpFileName: LPCWSTR): BOOL; stdcall;
function CeDeleteRecord(hDatabase: THandle; oidRecord: TCeOID): BOOL; stdcall;
function CeEnumDBVolumes(var mpceguid: TCeGUID; lpBuf: LPWSTR; dwNumChars: DWORD): BOOL; stdcall;
function CeFindAllDatabases(dwDbaseType: DWORD; wFlags: WORD; var cFindData: DWORD;
  var ppFindData: PCeDBFindDataArray): BOOL; stdcall;
function CeFindAllFiles(Path: PWideChar; Attr: DWORD;
  var Count: DWord; var FindData: PCeFindDataArray): BOOL; stdcall;
function CeFindClose(hFindFile: THandle): BOOL; stdcall;
function CeFindFirstDatabase(dwDbaseType: DWORD): THandle; stdcall;
function CeFindFirstDatabaseEx(mpceguid: PCeGUID; dwDbaseType: DWORD): THandle; stdcall;

function CeFindFirstFile(lpFileName: LPCWSTR; lpFindFileData: PCeFindData): THandle; stdcall;
function CeFindNextDatabase(hEnum: THandle): TCeOID; stdcall;
function CeFindNextDatabaseEx(hEnum: THandle; mpceguid: PCeGUID): TCeOID; stdcall;

function CeFindNextFile(hFindFile: THandle; lpFindFileData: PCeFindData): BOOL; stdcall;
function CeFlushDBVol(mpceguid: PCeGUID): BOOL; stdcall;

function CeGetClassName(hWnd: HWND; lpClassName: LPWSTR; nMaxCount: integer): Integer; stdcall;
function CeGetDesktopDeviceCaps(nIndedx: Integer): LongInt; stdcall;
function CeGetDiskFreeSpaceEx(lpDirectoryName: LPCWSTR; lpFreeBytesAvailable,lpTotalNumberOfBytes,
  lpTotalNumberOfFreeBytes: PLargeInteger): Integer; stdcall;
function CeGetFileAttributes(lpFileName: LPCWSTR): DWORD; stdcall;
function CeGetFileSize(hFile: THandle; lpFileSizeHigh: PDWORD): DWORD; stdcall;
function CeGetFileTime(hFile: THandle; lpCreationTime: PFileTime;
  lpLastAccessTime: PFileTime; lpLastWriteTime: PFileTime): BOOL; stdcall;
function CeGetLastError: DWORD; stdcall;
function CeGetSpecialFolderPath(nFolder: Integer; nBufferLength: DWORD; lpBuffer: LPWSTR): DWORD; stdcall;
function CeGetStoreInformation(lpsi: PStoreInformation): BOOL; stdcall;
procedure CeGetSystemInfo(lpSystemInfo: PSystemInfo); stdcall;
function CeGetSystemMetrics(nIndex: Integer): Integer; stdcall;
function CeGetSystemPowerStatusEx(pStatus: PSystemPowerStatusEx; fUpdate: BOOL): BOOL; stdcall;
function CeGetTempPath(nBufferLength: DWORD; lpBuffer: LPWSTR): DWORD; stdcall;
function CeGetVersionEx(lpVersionInfo: PCeOSVersionInfo): BOOL; stdcall;
function CeGetWindow(hWnd: HWND; uCmd: UINT): HWND; stdcall;
function CeGetWindowLong(hWnd: HWND; nIndex: integer): LongInt; stdcall;
function CeGetWindowText(hWnd: HWND; lpString: LPWSTR; nMaxCount: integer): Integer; stdcall;
procedure CeGlobalMemoryStatus(lpmst: PMemoryStatus); stdcall;
function CeMountDBVol(mpceguid: PCeGUID; lpszDBVol: LPWSTR; dwFlags: DWORD): BOOL; stdcall;

function CeMoveFile(lpExistingFileName: LPCWSTR; lpNewFileName: LPCWSTR): BOOL; stdcall;
function CeOidGetInfo(oid: TCeOID; var poidInfo: TCeOIDINFO): BOOL; stdcall;
function CeOidGetInfoEx(mpceguid: PCeGUID; oid: TCeOID; var poidInfo: TCeOIDINFO): BOOL; stdcall;

function CeOpenDatabase(var poid: TCeOID; lpszName: LPWSTR; propid: TCePROPID;
  dwFlags: DWORD; hwndNotify: HWND): THandle; stdcall;
function CeOpenDatabaseEx(mpceguid: PCeGUID; var poid: TCeOID; lpszName: LPWSTR;
  propid: TCePROPID; dwFlags: DWORD; pRequest: Pointer): THandle; stdcall;

function CeQueryInstructionSet(dwInstructionSet: DWORD; lpdwCurrentInstructionSet: PDWORD): BOOL; stdcall;
procedure CeRapiFreeBuffer(p: Pointer); stdcall;
function CeRapiGetError: HResult; stdcall;
function CeRapiInit: LongInt; stdcall;
function CeRapiInitEx(var RInit: TRapiInit): LongInt; stdcall;
function CeRapiInvoke(pDllPath: LPCWSTR; pFunctionName: LPWSTR; cbInput: DWORD; pInput: Pointer; var pcbOutput: DWORD;
  var ppOutput: Pointer; mppIRAPIStream: ppIRAPIStream; dwReserved: DWORD ): LongInt; stdcall;
//function CeRapiInvoke(pDllPath: LPCWSTR; pFunctionName: LPWSTR; cbInput: DWORD; pInput: Pointer; var pcbOutput: DWORD;
//  var ppOutput: PBYTE; mppIRAPIStream: ppIRAPIStream; dwReserved: DWORD ): LongInt; stdcall;
function CeRapiUninit: LongInt; stdcall;
function CeReadFile(hFile: THandle; lpBuffer: Pointer; nNumberOfBytesToRead: DWORD;
  var NumberOfBytesRead: DWORD; Overlapped: POVERLAPPED): BOOL; stdcall;
function CeReadRecordProps(hDbase: THandle; dwFlags: DWORD; var cPropID: WORD;
  rgPropID: Pointer; var Buffer: Pointer; var cbBuffer: DWORD): TCeOID; stdcall;
function CeReadRecordPropsEx(hDbase: THandle; dwFlags: DWORD; var cPropID: WORD;
  rgPropID: PCePROPID; var Buffer: Pointer; var cbBuffer: DWORD; hHeap: THandle): TCeOID; stdcall;

function CeRegCloseKey(hKey: HKEY): LongInt; stdcall;
function CeRegCreateKeyEx(hKey: HKEY; lpSzSubKey: LPCWSTR; dwReserved: DWORD;
  lpszClass: LPWSTR; dwOption: DWORD; samDesired: REGSAM; lpSecurityAttributes: PSecurityAttributes;
  var phkResult: HKEY; lpdwDisposition: PDWORD): LongInt; stdcall;
function CeRegDeleteKey(hKey: HKEY; lpszSubKey: LPCWSTR): LongInt; stdcall;
function CeRegDeleteValue(hKey: HKEY; lpszValueName: LPCWSTR): LongInt; stdcall;
function CeRegEnumKeyEx(hKey: HKEY; dwIndex: DWORD; KeyName: LPWSTR; var chName: DWORD;
  reserved: Pointer; szClass: LPWSTR; cchClass: PDWORD; ftLastWrite: PFileTime): LongInt; stdcall;
function CeRegEnumValue(hKey: HKEY; dwIndex: DWORD; lpszName:LPWSTR; var lpcchName:DWORD;
  lpReserved: PDWORD; lpszClass: PDWORD; lpcchClass: PBYTE; lpftLastWrite: PDWORD): LongInt; stdcall;
function CeRegOpenKeyEx(hKey: HKEY; SubKey: LPCWSTR; Reserved: DWORD; samDesired: REGSAM;  var phkResult: HKEY): LongInt; stdcall;
function CeRegQueryInfoKey(hKey: HKEY; ClassName: LPWSTR; cchClass: PDWORD; Reserved: PDWORD; cSubKeys: PDWORD;
  cchMaxSubKeyLen: PDWORD; cchMaxClassLen: PDWORD; cValues: PDWORD; cchMaxValueNameLen: PDWORD; 
  cbMaxValueData: PDWORD; cbSecurityDescriptor: PDWORD; LastWriteTime: PFileTime): LongInt; stdcall;
function CeRegQueryValueEx(hKey: HKEY; ValueName: LPCWSTR; Reserved: Pointer; pType: PDWORD;
  pData: PBYTE; cbData: PDWORD): LongInt; stdcall;
function CeRegSetValueEx(hKey: HKEY; ValueName: LPCWSTR; reserved: DWORD; dwType: DWORD;
  pData: Pointer; cbData: DWORD): LongInt; stdcall; //pData: PBYTE;
function CeRemoveDirectory(PathName: LPCWSTR): BOOL; stdcall;
function CeSeekDatabase(hDatabase: THandle; dwSeekType: DWORD; dwValue: LongInt;
  dwIndex: PDWORD): TCeOID; stdcall;
function CeSetDatabaseInfo(oidDbase: TCeOID; var NewInfo: TCeDBaseInfo): BOOL; stdcall;
function CeSetDatabaseInfoEx(mpceguid: PCeGUID; oidDbase: TCeOID; var NewInfo: TCeDBaseInfo): BOOL; stdcall;

function CeSetEndOfFile(hFile: THandle): BOOL; stdcall;
function CeSetFileAttributes(FileName: LPCWSTR; dwFileAttributes: DWORD): BOOL; stdcall;
function CeSetFilePointer(hFile: THandle; DistanceToMove: LongInt; DistanceToMoveHigh: PULONG;
  dwMoveMethod: DWORD): DWORD; stdcall;
function CeSetFileTime(hFile: THandle; CreationTime: PFileTime;
  LastAccessTime: PFileTime; lastWriteTime: PFileTime): BOOL; stdcall;
function CeSHCreateShortcut(ShortCut: LPWSTR; Target: LPWSTR): DWORD; stdcall;
function CeSHGetShortcutTarget(ShortCut: LPWSTR; Target: LPWSTR; cbMax: integer): BOOL; stdcall;
function CeSyncStart(szCommand: LPCWSTR): HResult; stdcall;
function CeSyncStop: HResult; stdcall;
function CeUnmountDBVol(mpceguid: PCeGUID): BOOL; stdcall;

function CeWriteFile(hFile: THandle; Buffer: Pointer; NumberOfBytesToWrite: DWORD;
  var NumberOfBytesWritten: DWORD; OverLapped: POVERLAPPED): BOOL; stdcall;
function CeWriteRecordProps(hDbase: THandle; oidRecord: TCeOID; cPropID: WORD; var PropVal: TCePROPVAL): TCeOID; stdcall;

procedure CREATE_INVALIDGUID( var mceguid: TCeGUID );
procedure CREATE_SYSTEMGUID( var mceguid: TCeGUID );

{File acess as PStream realisation}
function CeSeekFileStream( Strm: PStream; MoveTo: Integer; MoveFrom: TMoveMethod ): DWORD;
function CeGetSizeFileStream( Strm: PStream ): DWORD;
procedure CeSetSizeFileStream( Strm: PStream; NewSize: DWORD );
function CeReadFileStream( Strm: PStream; var Buffer; Count: DWORD ): DWORD;
function CeWriteFileStream( Strm: PStream; var Buffer; Count: DWORD ): DWORD;
procedure CeCloseFileStream( Strm: PStream );

function NewCeReadFileStream(const FileName: PWideChar): PStream;
function NewCeWriteFileStream(const FileName: PWideChar): PStream;
function NewCeReadWriteFileStream(const FileName: PWideChar): PStream;

{own Kol-like procs}
function CeFileExists(const FileName : PWideChar) : Boolean;
function CeDirectoryExists(const Name: PWideChar): Boolean;
function CeDirSize(const Path: PWideChar): Int64;

const
  RapiLib  = 'rapi.dll';

  CeBaseFileMethods: TStreamMethods = (
    fSeek: CeSeekFileStream;
    fGetSiz: CeGetSizeFileStream;
    fSetSiz: DummySetSize;
    fRead: DummyReadWrite;
    fWrite: DummyReadWrite;
    fClose: CeCloseFileStream;
    fCustom: nil; //???
  );

implementation

function CeCheckPassword; external RapiLib name 'CeCheckPassword';
function CeCloseHandle; external RapiLib name 'CeCloseHandle';
function CeCopyFile; external RapiLib name 'CeCopyFile';
function CeCreateDatabase; external RapiLib name 'CeCreateDatabase';
function CeCreateDatabaseEx; external RapiLib name 'CeCreateDatabaseEx';
function CeCreateDirectory; external RapiLib name 'CeCreateDirectory';
function CeCreateFile; external RapiLib name 'CeCreateFile';
function CeCreateProcess; external RapiLib name 'CeCreateProcess';
function CeDeleteDatabase; external RapiLib name 'CeDeleteDatabase';
function CeDeleteDatabaseEx; external RapiLib name 'CeDeleteDatabaseEx';
function CeDeleteFile; external RapiLib name 'CeDeleteFile';
function CeDeleteRecord; external RapiLib name 'CeDeleteRecord';
function CeEnumDBVolumes; external RapiLib name 'CeEnumDBVolumes';
function CeFindAllDatabases; external RapiLib name 'CeFindAllDatabases';
function CeFindAllFiles; external RapiLib name 'CeFindAllFiles';
function CeFindClose; external RapiLib name 'CeFindClose';
function CeFindFirstDatabase; external RapiLib name 'CeFindFirstDatabase';
function CeFindFirstDatabaseEx; external RapiLib name 'CeFindFirstDatabaseEx';
function CeFindFirstFile; external RapiLib name 'CeFindFirstFile';
function CeFindNextDatabase; external RapiLib name 'CeFindNextDatabase';
function CeFindNextDatabaseEx; external RapiLib name 'CeFindNextDatabaseEx';
function CeFindNextFile; external RapiLib name 'CeFindNextFile';
function CeFlushDBVol; external RapiLib name 'CeFlushDBVol';
function CeGetClassName; external RapiLib name 'CeGetClassName';
function CeGetDesktopDeviceCaps; external RapiLib name 'CeGetDesktopDeviceCaps';
function CeGetDiskFreeSpaceEx; external RapiLib name 'CeGetDiskFreeSpaceEx';
function CeGetFileAttributes; external RapiLib name 'CeGetFileAttributes';
function CeGetFileSize; external RapiLib name 'CeGetFileSize';
function CeGetFileTime; external RapiLib name 'CeGetFileTime';
function CeGetLastError; external RapiLib name 'CeGetLastError';
function CeGetSpecialFolderPath; external RapiLib name 'CeGetSpecialFolderPath';
function CeGetStoreInformation; external RapiLib name 'CeGetStoreInformation';
procedure CeGetSystemInfo; external RapiLib name 'CeGetSystemInfo';
function CeGetSystemMetrics; external RapiLib name 'CeGetSystemMetrics';
function CeGetSystemPowerStatusEx; external RapiLib name 'CeGetSystemPowerStatusEx';
function CeGetTempPath; external RapiLib name 'CeGetTempPath';
function CeGetVersionEx; external RapiLib name 'CeGetVersionEx';
function CeGetWindow; external RapiLib name 'CeGetWindow';
function CeGetWindowLong; external RapiLib name 'CeGetWindowLong';
function CeGetWindowText; external RapiLib name 'CeGetWindowText';
procedure CeGlobalMemoryStatus; external RapiLib name 'CeGlobalMemoryStatus';
function CeMountDBVol; external RapiLib name 'CeMountDBVol';
function CeMoveFile; external RapiLib name 'CeMoveFile';
function CeOidGetInfo; external RapiLib name 'CeOidGetInfo';
function CeOidGetInfoEx; external RapiLib name 'CeOidGetInfoEx';
function CeOpenDatabase; external RapiLib name 'CeOpenDatabase';
function CeOpenDatabaseEx; external RapiLib name 'CeOpenDatabaseEx';
function CeQueryInstructionSet; external RapiLib name 'CeQueryInstructionSet';
procedure CeRapiFreeBuffer; external RapiLib name 'CeRapiFreeBuffer';
function CeRapiGetError; external RapiLib name 'CeRapiGetError';
function CeRapiInit; external RapiLib name 'CeRapiInit';
function CeRapiInitEx; external RapiLib name 'CeRapiInitEx';
function CeRapiInvoke; external RapiLib name 'CeRapiInvoke';
function CeRapiUninit; external RapiLib name 'CeRapiUninit';
function CeReadFile; external RapiLib name 'CeReadFile';
function CeReadRecordProps; external RapiLib name 'CeReadRecordProps';
function CeReadRecordPropsEx; external RapiLib name 'CeReadRecordPropsEx';
function CeRegCloseKey; external RapiLib name 'CeRegCloseKey';
function CeRegCreateKeyEx; external RapiLib name 'CeRegCreateKeyEx';
function CeRegDeleteKey; external RapiLib name 'CeRegDeleteKey';
function CeRegDeleteValue; external RapiLib name 'CeRegDeleteValue';
function CeRegEnumKeyEx; external RapiLib name 'CeRegEnumKeyEx';
function CeRegEnumValue; external RapiLib name 'CeRegEnumValue';
function CeRegOpenKeyEx; external RapiLib name 'CeRegOpenKeyEx';
function CeRegQueryInfoKey; external RapiLib name 'CeRegQueryInfoKey';
function CeRegQueryValueEx; external RapiLib name 'CeRegQueryValueEx';
function CeRegSetValueEx; external RapiLib name 'CeRegSetValueEx';
function CeRemoveDirectory; external RapiLib name 'CeRemoveDirectory';
function CeSeekDatabase; external RapiLib name 'CeSeekDatabase';
function CeSetDatabaseInfo; external RapiLib name 'CeSetDatabaseInfo';
function CeSetDatabaseInfoEx; external RapiLib name 'CeSetDatabaseInfoEx';
function CeSetEndOfFile; external RapiLib name 'CeSetEndOfFile';
function CeSetFileAttributes; external RapiLib name 'CeSetFileAttributes';
function CeSetFilePointer; external RapiLib name 'CeSetFilePointer';
function CeSetFileTime; external RapiLib name 'CeSetFileTime';
function CeSHCreateShortcut; external RapiLib name 'CeSHCreateShortcut';
function CeSHGetShortcutTarget; external RapiLib name 'CeSHGetShortcutTarget';
function CeSyncStart; external RapiLib name 'CeSyncStart';
function CeSyncStop; external RapiLib name 'CeSyncStop';
function CeUnmountDBVol; external RapiLib name 'CeUnmountDBVol';
function CeWriteFile; external RapiLib name 'CeWriteFile';
function CeWriteRecordProps; external RapiLib name 'CeWriteRecordProps';


procedure CREATE_INVALIDGUID( var mceguid: TCeGUID );
begin
   fillchar( mceguid, sizeof( TCeGUID ) , -1 );
end;

procedure CREATE_SYSTEMGUID( var mceguid: TCeGUID );
begin
   fillchar( mceguid, sizeof( TCeGUID ) , 0 );
end;

function NewCeReadFileStream(const FileName: PWideChar): PStream;
begin
  Result := _NewStream(CeBaseFileMethods);
  Result.Methods.fRead := CeReadFileStream;
  with Result.Data do fHandle := CeCreateFile(FileName,GENERIC_READ,
                                        FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
end;

function NewCeWriteFileStream(const FileName: PWideChar): PStream;
begin
  Result := _NewStream(CeBaseFileMethods);
  Result.Methods.fWrite := CeWriteFileStream;
  Result.Methods.fSetSiz := CeSetSizeFileStream;
  with Result.Data do fHandle := CeCreateFile(FileName,GENERIC_WRITE,
                                        FILE_SHARE_READ,nil,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0);
end;

function NewCeReadWriteFileStream(const FileName: PWideChar): PStream;
begin
  Result := _NewStream(CeBaseFileMethods);
  Result.Methods.fRead := CeReadFileStream;
  Result.Methods.fWrite := CeWriteFileStream;
  Result.Methods.fSetSiz := CeSetSizeFileStream;
  with Result.Data do fHandle := CeCreateFile(FileName,GENERIC_READ or GENERIC_WRITE,
                                        FILE_SHARE_READ,nil,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0);
end;

function CeReadFileStream( Strm: PStream; var Buffer; Count: DWORD ): DWORD;
begin
  if not CeReadFile(Strm.Data.fHandle, @Buffer, Count, Result, nil) then
    Result := 0;
end;

function CeWriteFileStream( Strm: PStream; var Buffer; Count: DWORD ): DWORD;
begin
  if not CeWriteFile(Strm.Data.fHandle, @Buffer, Count, Result, nil) then
    Result := 0;  
end;

function CeGetSizeFileStream( Strm: PStream ): DWORD;
begin
  Result := CeGetFileSize(Strm.Data.fHandle, nil);
  if Result = DWORD( -1 ) then Result := 0;
end;

procedure CeSetSizeFileStream( Strm: PStream; NewSize: DWORD );
var P: DWORD;
begin
  P := Strm.Position;
  Strm.Position := NewSize;
  CeSetEndOfFile(Strm.Handle);
  if P < NewSize then
    Strm.Position := P;
end;

function CeSeekFileStream( Strm: PStream; MoveTo: Integer; MoveFrom: TMoveMethod ): DWORD;
begin
  Result := CeSetFilePointer(Strm.Data.fHandle, MoveTo, nil, Ord(MoveFrom));
end;

procedure CeCloseFileStream( Strm: PStream );
begin
  CeCloseHandle(Strm.Data.fHandle);
end;

function CeFileExists(const FileName : PWideChar) : Boolean;
var Code: DWORD;
begin
  Code := CeGetFileAttributes(FileName);
  Result := (Code <> $FFFFFFFF) and (FILE_ATTRIBUTE_DIRECTORY and Code = 0);
end;

function CeDirectoryExists(const Name: PWideChar): Boolean;
var Code: DWORD;
begin
  Code := CeGetFileAttributes(Name);
  Result := (Code <> $FFFFFFFF) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;

function CeDirSize( const Path: PWideChar ): Int64;
type MakeLowHigh = record
       L,H:integer
     end;
var I,DirCount: Integer;
    Sz:Int64;
    _FAFData:PCeFindDataArray;
begin
  Result := 0;
//Path must be without '\'
  CeFindAllFiles(PWideChar(WideString(Path) + WideString('\*')),FAF_ATTRIBUTES or FAF_NAME or FAF_SIZE_HIGH or FAF_SIZE_LOW,
                   DWORD(DirCount),_FAFData);
  for I := 0 to DirCount - 1 do begin
    if (_FAFData[i].dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
      Sz := CeDirSize(PWideChar(WideString(Path) + WideString('\') + WideString(PWideChar(@_FAFData[i].cFileName))))
    else begin
      MakeLowHigh(Sz).L := _FAFData[i].nFileSizeLow;
      MakeLowHigh(Sz).H := _FAFData[i].nFileSizeHigh;
    end;
    Result := Result + Sz;
  end;
  CeRapiFreeBuffer(_FAFData);
end;

end.
