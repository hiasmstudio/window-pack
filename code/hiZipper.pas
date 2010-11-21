unit hiZipper;

interface

uses Kol, Windows, Share, Debug; 

type
 ZIPResult = integer;
 THIZipper = class( TDebug )
   private
    List                    : PStrList;
    ArrList                 : PArray;
    function _GetList(
                   var Item : TData;
                    var Val : TData
                      )     : boolean;
    function _CountList     : integer;
   public
    _prop_ZipFileName       : string;
    _prop_BasePath          : string;
    _prop_FileMask          : string;
    _prop_Password          : string;
    _prop_Comment           : string;
    _prop_SpanSize          : integer;
    _prop_UpdateMode        : byte;
    _prop_Method            : byte;
    _prop_SkipOlder         : byte;
    _prop_TestOnly          : byte;
    _prop_ResetAttr         : byte;
    _prop_CheckAttr         : byte;
    _prop_UseFolders        : byte;
    _prop_IncludeSubfolders : byte;
    _prop_OverwriteExisting : byte;
    _prop_Progress          : byte;
    _event_onProgress       : THI_Event;
    _event_onError          : THI_Event;
    _data_Data              : THI_Event;
    _data_ZipFileName       : THI_Event;
    _data_BasePath          : THI_Event;
    _data_FileMask          : THI_Event;
    _data_Index             : THI_Event;
    sysDateTime             : TFileTime;
    strZIP                  : string;
    strPath                 : string;
    strName                 : string;
    strMask                 : string;
    strStoredName           : string;
    intCount                : integer;
    intMethod               : integer;
    intMode                 : integer;
    intFiles                : integer;
    intBytes                : integer;
    fResetAttr              : boolean;
    fCheckAttr              : boolean;
    fOverwriteExisting      : boolean;
    fSkipOlder              : boolean;
    fIncludeSubfolders      : boolean;
    fUseFolders             : boolean;
    fTestOnly               : boolean;
    constructor Create;
    destructor Destroy; override;
    procedure _work_doCreate( var _Data:TData; Index:word );
    procedure _work_doOpen( var _Data:TData; Index:word );
    procedure _work_doOrder( var _Data:TData; Index:word );
    procedure _work_doOrderMulti( var _Data:TData; Index:word );
    procedure _work_doCompress( var _Data:TData; Index:word );
    procedure _work_doClose( var _Data:TData; Index:word );
    procedure _work_doExtractAll( var _Data:TData; Index:word );
    procedure _work_doExtractOne( var _Data:TData; Index:word );
    procedure _work_doList( var _Data:TData; Index:word );
    procedure _work_doDelete( var _Data:TData; Index:word );
    procedure _work_doCancel( var _Data:TData; Index:word );
    procedure _work_doPassword( var _Data:TData; Index:word );
    procedure _var_Count( var _Data:TData; Index:word );
    procedure _var_List(var _Data:TData; Index:word);
    function Check( intResult: integer ) : boolean;
    procedure onProgress;
    property _intFiles: Integer read intFiles;
    property _intBytes: Integer read intBytes;
  end;

 const
  BSZIP        = 'BSZIP.dll';
  OLE32        = 'OLE32.dll';

 var
   pSelf: THIZipper;

implementation

uses HiTime;

function zCancelOperation(
  ): Boolean;  stdcall; 
  external BSZIP name 'zCancelOperation';

function zGetRunTimeInfo( var
  ProcessedFiles,
  ProcessedBytes    : integer
  ): Boolean; stdcall;
  external BSZIP name 'zGetRunTimeInfo';

function CoDosDateTimeToFileTime(
  nDosDate              : Word;
  nDosTime              : Word;
  var filetime          : TFileTime
  ) : BOOLEAN; stdcall;       
  external OLE32 name 'CoDosDateTimeToFileTime';

function zSelectFile(
  index                 : integer;
  how                   : boolean
  ) : Boolean;  stdcall;
  external BSZIP name 'zSelectFile';

function zDeleteFiles(
  ) : Integer;  stdcall;
  external BSZIP name 'zDeleteFiles';

function zGetFileTime(
  index                 : integer
  ) : Integer;  stdcall;
  external BSZIP name 'zGetFileTime';

function zGetFileDate(
  index                 : integer
  ) : Integer;  stdcall;
  external BSZIP name 'zGetFileDate';

function zGetFilePath(
  index                 : integer
  ) : PChar;  stdcall;
  external BSZIP name 'zGetFilePath';

function zGetFileName(
  index                 : integer
  ) : PChar;  stdcall;
  external BSZIP name 'zGetFileName';

function zGetFileSize(
  index                 : integer
  ) : Integer;  stdcall;
  external BSZIP name 'zGetFileSize';

function zGetTotalFiles(
  ) : Integer;  stdcall;
  external BSZIP name 'zGetTotalFiles';

function zGetCompressedFileSize(
  index                 : integer
  ): Integer; stdcall;
  external BSZIP name 'zGetCompressedFileSize';
  
function zCreateNewZip(
  zipfilename           : PChar
  ): ZIPResult; stdcall;
  external BSZIP name 'zCreateNewZip';

function zOpenZipFile(
  zipfilename           : PChar
  ): ZIPResult; stdcall;
  external BSZIP name 'zOpenZipFile';

function zCloseZipFile(
  ): ZIPResult; stdcall;
  external BSZIP name 'zCloseZipFile';

function zExtractAll(
  ExtractDirectory      : pchar;
  Password              : pchar;
  OverwriteExisting     : boolean;
  SkipOlder             : boolean;
  UseFolders            : boolean;
  TestOnly              : boolean;
  RTInfoFunc            : pointer
  ): ZIPResult; stdcall;
  external BSZIP name 'zExtractAll';

function zExtractOne(
  index                 : integer;
  ExtractDirectory      : pchar;
  Password              : pchar;
  OverwriteExisting     : boolean;
  SkipOlder             : boolean;
  UseFolders            : boolean;
  TestOnly              : boolean;
  RTInfoFunc            : pointer
  ): ZIPResult; stdcall;
  external BSZIP name 'zExtractOne';

function zOrderFile(
  FileName              : pchar;
  StoredName            : pchar;
  UpdateMode            : integer
  ): ZIPResult; stdcall;
  external BSZIP name 'zOrderFile';

function zOrderByWildcards(
  FileMask              : pchar;
  BasePath              : pchar;
  IncludeSubfolders     : boolean;
  CheckArchiveAttribute : boolean;
  UpdateMode            : integer
  ): ZIPResult; stdcall;
  external BSZIP name 'zOrderByWildcards';
  
function zCompressFiles(
  TempDir               : pchar;
  Password              : pchar;
  CompressionMethod     : integer;
  ResetArchiveAttribute : boolean;
  SpanSize              : integer;
  Comment               : string;
  RTInfoFunc            : pointer
  ): ZIPResult; stdcall;
  external BSZIP name 'zCompressFiles';


constructor THIZipper.Create;
  begin
    inherited Create;
    List := NewStrList;
    ArrList := CreateArray( nil, _GetList, _CountList, nil );
    strZIP := '';
  end;

destructor THIZipper.Destroy;
  begin
    List.Free;
    if ArrList <> nil then dispose(ArrList);
    inherited;
  end;

function THIZipper.Check( intResult: integer ) : boolean;
  begin
    Result := False;
    _hi_OnEvent( _event_onError, intResult );
    if intResult = 0 then Result := True;
  end;

procedure THIZipper._work_doCreate( var _Data:TData; Index:word );
  begin
    if strZIP <> '' then
      if Check( zCloseZipFile ) then
        strZIP := '';
    strZIP := ReadString( _Data, _data_ZipFileName, _prop_ZipFileName );
    if Check( zCreateNewZip( PChar( strZIP ) ) ) then
      List.Clear
    else
      strZIP := '';
  end;

procedure THIZipper._work_doOpen( var _Data:TData; Index:word );
  begin
    if strZIP <> '' then
      if Check( zCloseZipFile ) then
        strZIP := '';
    strZIP := ReadString( _Data, _data_ZipFileName, _prop_ZipFileName );
    if Check( zOpenZipFile( PChar( strZIP ) ) ) then
      List.Clear
    else
      strZIP := '';
  end;

procedure THIZipper._work_doList;
  const
    tab : string = Chr($09);
  var
    i : Word;
    strTemp : string;
    date : word;
    time : word;
    sys : TSystemTime;
    Ratio : integer;
    fs : integer;
    cfs : integer;
  begin
    if strZIP = '' then Exit;
    intCount := zGetTotalFiles;
    List.Clear;
    for i := 0 to intCount - 1 do begin
      strTemp := zGetFileName( i ) + tab;
      date := zGetFileDate( i );
      time := zGetFileTime( i );
      CoDosDateTimeToFileTime( date, time, sysDateTime );
      FileTimeToSystemTime( sysDateTime, sys );
      strTemp := strTemp + TimeToStr( 'D.M.Y h:m:s', sys ) + tab;
      fs := zGetFileSize( i );
      cfs := zGetCompressedFileSize( i );
      if fs <> 0 then
        Ratio := 100 - Trunc( ( cfs / fs ) * 100 )
      else
        Ratio := 0;
      strTemp := strTemp + Int2Str( fs ) + tab;
      strTemp := strTemp + Int2Str( Ratio ) + '%' + tab;
      strTemp := strTemp + Int2Str( cfs ) + tab;
      strTemp := strTemp + zGetFilePath( i );
      List.Add( strTemp );
    end; { For }
  end;

procedure THIZipper._work_doOrder( var _Data:TData; Index:word );
  var
    strTemp : string;
  begin
    if strZIP = '' then Exit;
    strName := ReadString( _Data, _data_Data, '' );
    strTemp := kol.ExtractFilePath( strZIP );
    strStoredName:= Copy( strName, Length( strTemp ) + 1, Length( strName ) - Length( strTemp ) );
    intMode := _prop_UpdateMode;
    if Check( zOrderFile(
                     PChar( strName ),
                     PChar( strStoredName ),
                     intMode 
                     ) ) then begin
      List.Add( kol.ExtractFileName( strName ) );
      intCount := List.Count;
    end; { If }
  end;

procedure THIZipper._work_doOrderMulti( var _Data:TData; Index:word );
  begin
    if strZIP = '' then Exit;
    strMask := ReadString( _Data, _data_FileMask, _prop_FileMask );
    strPath := ReadString( _Data, _data_BasePath, _prop_BasePath );
    if Copy( strPath, Length( strPath ), 1) <> '\' then strPath := strPath + '\';
    intMode := _prop_UpdateMode;
    if _prop_IncludeSubfolders = 0 then fIncludeSubfolders := True
    else fIncludeSubfolders := False;
    if _prop_CheckAttr = 0 then fCheckAttr := True
    else fCheckAttr := False;
    Check( zOrderByWildcards(
                     PChar( strPath + strMask ),
                     PChar( strPath ),
                     fIncludeSubfolders,
                     fCheckAttr,
                     intMode
                     ) );
  end;

procedure THIZipper._work_doCompress;
  begin
    if strZIP = '' then Exit;
    intMethod := _prop_Method;
    if _prop_ResetAttr = 0 then fResetAttr := True
    else fResetAttr := False;
    pSelf := Self;
    Check( zCompressFiles(
                     nil,
                     PChar( _prop_Password ),
                     intMethod,
                     fResetAttr,
                     _prop_SpanSize,
                     _prop_Comment,
                     @THIZipper.onProgress
                     ) );
  end;

procedure THIZipper._work_doExtractAll( var _Data:TData; Index:word );
  begin
    if strZIP = '' then Exit;
    strPath := ReadString( _Data, _data_BasePath, _prop_BasePath );
    if _prop_OverwriteExisting = 0 then fOverwriteExisting := True
    else fOverwriteExisting := False;
    if _prop_SkipOlder = 0 then fSkipOlder := True
    else fSkipOlder := False;
    if _prop_UseFolders = 0 then fUseFolders := True
    else fUseFolders := False;
    if _prop_TestOnly = 0 then fTestOnly := True
    else fTestOnly := False;
    pSelf := Self;
    Check( zExtractAll(
                     PChar( strPath ),
                     PChar( _prop_Password ),
                     fOverwriteExisting,
                     fSkipOlder,
                     fUseFolders,
                     fTestOnly,
                     @THIZipper.onProgress
                     ) );
  end;

procedure THIZipper._work_doExtractOne( var _Data:TData; Index:word );
  var
    i : integer;
  begin
    if strZIP = '' then Exit;
    strPath := ReadString( _Data, _data_BasePath, _prop_BasePath );
    i := ReadInteger( _Data, _data_Index, 0 );
    if _prop_OverwriteExisting = 0 then fOverwriteExisting := True
    else fOverwriteExisting := False;
    if _prop_SkipOlder = 0 then fSkipOlder := True
    else fSkipOlder := False;
    if _prop_UseFolders = 0 then fUseFolders := True
    else fUseFolders := False;
    if _prop_TestOnly = 0 then fTestOnly := True
    else fTestOnly := False;
    pSelf := Self;
    Check( zExtractOne(
                     i,
                     PChar( strPath ),
                     PChar( _prop_Password ),
                     fOverwriteExisting,
                     fSkipOlder,
                     fUseFolders,
                     fTestOnly,
                     @THIZipper.onProgress
                     ) );
  end;

procedure THIZipper._work_doDelete( var _Data:TData; Index:word );
  var
    i : integer;
  begin
    if strZIP = '' then Exit;
    i := ToInteger( _Data );
    if zSelectFile( i, True) then begin
      Check( zDeleteFiles );
      zSelectFile( i, False )
    end; { If }
  end;

procedure THIZipper._work_doCancel;
  begin
    if strZIP = '' then Exit;
    if zCancelOperation then ;
  end;

procedure THIZipper._work_doClose;
  begin
    if strZIP = '' then Exit; 
    if Check( zCloseZipFile ) then begin
      List.Clear; 
      strZIP := '';
    end; { If }
  end;

procedure THIZipper._work_doPassword;
  begin
    _prop_Password := ToString( _Data );
  end;

procedure  THIZipper._var_Count(var _Data:TData; Index:word);
  begin
    dtInteger(_Data, intCount);
  end;

procedure THIZipper._var_List( var _Data:TData; Index:word );
  begin
    dtArray(_Data, ArrList );
  end;

function THIZipper._GetList;
  var
    ind: integer;
  begin
    ind := ToIntIndex( Item );
    if (ind >= 0) and (ind < List.Count) then
     begin
      Result := true;
      dtString(Val,List.Items[ind]);
     end
    else Result := false;
  end;

function THIZipper._CountList;
  begin
    Result := List.Count;
  end;

procedure THIZipper.onProgress; far;
  begin
    zGetRunTimeInfo( pSelf.intFiles, pSelf.intBytes );
    if pSelf._prop_Progress = 0 then
      _hi_OnEvent( pSelf._event_onProgress,  pSelf._intFiles )
    else
      _hi_OnEvent( pSelf._event_onProgress,  pSelf._intBytes );
  end;

end.