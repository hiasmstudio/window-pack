unit DropSourcek;

// -----------------------------------------------------------------------------
// Project:         Drag and Drop Component Suite
// Component Names: TDropTextSource, TDropFileSource,
// Module:          DropSource
// Description:     Implements Dragging & Dropping of text, files
//                  FROM your application to another.
// Version:         3.7
// Date:            22-JUL-1999
// Target:          Win32, Delphi 3 - Delphi 5, C++ Builder 3, C++ Builder 4
// Authors:         Angus Johnson,   ajohnson@rpi.net.au
//                  Anders Melander, anders@melander.dk
//                                   http://www.melander.dk
// Copyright        © 1997-99 Angus Johnson & Anders Melander
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Acknowledgements:
// 1. Thanks to Jim O'Brien for some tips on Shortcuts and Scrap files.
// 2. Thanks to Zbysek Hlinka for sugestions on Copying to Clipboard.
// 3. Thanks to Jan Debis for spotting a small bug in TDropFileSource.
// 4. Thanks to 'Scotto the Unwise' for spotting a Delphi4 compatibility bug.
// 5. Thanks to Alexandre Bento Freire who spotted a bug in GetShellFolderOfPath().
// -----------------------------------------------------------------------------
// Adapted for HiAsm by Nic. May 2011

interface

uses
  Windows, kol, ActiveX;

const
  MAXFORMATS = 20;

type
  TFileName = String;
  TInterfacedComponent = class(TObject, IUnknown)
  private
    fRefCount: Integer;
  protected
    function QueryInterface(const IID: TGuid; out Obj): HRESULT;
               {$IFDEF VER13_PLUS} override; {$ELSE}
               {$IFDEF VER12_PLUS} reintroduce; {$ENDIF}{$ENDIF} stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  TDragType = (dtCopy, dtMove, dtLink);
  TDragTypes = set of TDragType;

  TDragResult = (drDropCopy, drDropMove,
    drDropLink, drCancel, drOutMemory, drUnknown);

  TDropEvent = procedure(Sender: TObject;
    DragType: TDragType; var ContinueDrop: Boolean) of object;
  TFeedbackEvent = procedure(Sender: TObject;
    Effect: LongInt; var UseDefaultCursors: Boolean) of object;

  TDropSource = class(TInterfacedComponent, IDropSource, IDataObject)
  private
    fDragTypes      : TDragTypes;
    fDropEvent      : TDropEvent;
    fFBEvent        : TFeedBackEvent;
    fDataFormats    : array[0..MAXFORMATS-1] of TFormatEtc;
    fDataFormatsCount: integer;

    //drag images...
    fImages: PImageList;
    fShowImage: boolean;
    fImageIndex: integer;
    fImageHotSpot: TPoint;
    procedure SetShowImage(Value: boolean);
  protected
    FeedbackEffect  : LongInt;

    // IDropSource implementation
    function QueryContinueDrag(fEscapePressed: bool;
      grfKeyState: LongInt): HRESULT; stdcall;
    function GiveFeedback(dwEffect: LongInt): HRESULT; stdcall;
    procedure Init; virtual; //Abstract;

    // IDataObject implementation
    function GetData(const FormatEtcIn: TFormatEtc;
      out Medium: TStgMedium):HRESULT; stdcall;
    function GetDataHere(const FormatEtc: TFormatEtc;
      out Medium: TStgMedium):HRESULT; stdcall;
    function QueryGetData(const FormatEtc: TFormatEtc): HRESULT; stdcall;
    function GetCanonicalFormatEtc(const FormatEtc: TFormatEtc;
      out FormatEtcout: TFormatEtc): HRESULT; stdcall;
    function SetData(const FormatEtc: TFormatEtc; var Medium: TStgMedium;
      fRelease: Bool): HRESULT; stdcall;
    function EnumFormatEtc(dwDirection: LongInt;
      out EnumFormatEtc: IEnumFormatEtc): HRESULT; stdcall;
    function dAdvise(const FormatEtc: TFormatEtc; advf: LongInt;
      const advsink: IAdviseSink; out dwConnection: LongInt): HRESULT; stdcall;
    function dUnadvise(dwConnection: LongInt): HRESULT; stdcall;
    function EnumdAdvise(out EnumAdvise: IEnumStatData): HRESULT; stdcall;

    //New functions...
    function DoGetData(const FormatEtcIn: TFormatEtc;
             out Medium: TStgMedium):HRESULT; virtual; abstract;
    procedure AddFormatEtc(cfFmt: TClipFormat;
                pt: PDVTargetDevice; dwAsp, lInd, tym: longint); virtual;
    function InternalCutCopyToClipboard(Effect: Integer): boolean;
    function CutOrCopyToClipboard: boolean; virtual;

    procedure SetImages(const Value: pImageList);
    procedure SetImageIndex(const Value: integer);
    procedure SetPoint(Index: integer; Value: integer);
    function GetPoint(Index: integer): integer;

  public
    constructor Create; virtual;
    function Execute: TDragResult;
    function CutToClipboard: boolean; virtual;
    function CopyToClipboard: boolean; virtual;
    property Dragtypes: TDragTypes read fDragTypes write fDragTypes;
    property OnFeedback: TFeedbackEvent read fFBEvent write fFBEvent;
    property OnDrop: TDropEvent read fDropEvent write fDropEvent;
    //Drag Images...
    property Images: PImageList read fImages write SetImages;
    property ImageIndex: integer read fImageIndex write SetImageIndex;
    property ShowImage: boolean read fShowImage write SetShowImage;
    property ImageHotSpotX: integer index 1 read GetPoint write SetPoint;
    property ImageHotSpotY: integer index 2 read GetPoint write SetPoint;
  end;

  TDropTextSource = class(TDropSource)
  private
    fText: String;
  protected
    function DoGetData(const FormatEtcIn: TFormatEtc;
      out Medium: TStgMedium):HRESULT; override;
    function CutOrCopyToClipboard: boolean; override;
  public
    constructor Create; override;
  published
    property Text: String read fText write fText;
  end;

  TDropFileSource = class(TDropSource)
  private
  protected
    function DoGetData(const FormatEtcIn: TFormatEtc;
      out Medium: TStgMedium):HRESULT; override;
    function CutOrCopyToClipboard: boolean; override;
  public
    Files: PStrList;
    MappedNames:PStrList;

    constructor Create; override;
    destructor Destroy; override;
    //MappedNames is only needed if files need to be renamed during a drag op
    //eg dragging from 'Recycle Bin'.
    end;

  procedure Register;

  var
    CF_FILEGROUPDESCRIPTOR, CF_FILECONTENTS, CF_FILENAMEMAP, CF_FILENAMEMAPW,
    CF_IDLIST, CF_PREFERREDDROPEFFECT, CF_URL: UINT; //see initialization.
    ShellMalloc: IMalloc;

implementation

uses ShellAPI;

const
  IID_IEnumIDList:   TGUID = (D1:$000214F2; D2:$0000; D3:$0000; D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IShellFolder:  TGUID = (D1:$000214E6; D2:$0000; D3:$0000; D4:($C0,$00,$00,$00,$00,$00,$00,$46));

  { IShellFolder.GetAttributesOf flags }
  SFGAO_FOLDER            = $20000000;       { It's a folder. }

  { Clipboard format which may be supported by IDataObject from system
  defined shell folders (such as directories, network, ...). }

  CFSTR_SHELLIDLIST           = 'Shell IDList Array';     { CF_IDLIST }
  CFSTR_SHELLIDLISTOFFSET     = 'Shell Object Offsets';   { CF_OBJECTPOSITIONS }
  CFSTR_NETRESOURCES          = 'Net Resource';           { CF_NETRESOURCE }
  CFSTR_FILEDESCRIPTORA       = 'FileGroupDescriptor';    { CF_FILEGROUPDESCRIPTORA }
  CFSTR_FILEDESCRIPTORW       = 'FileGroupDescriptorW';   { CF_FILEGROUPDESCRIPTORW }
  CFSTR_FILECONTENTS          = 'FileContents';           { CF_FILECONTENTS }
  CFSTR_FILENAMEA             = 'FileName';               { CF_FILENAMEA }
  CFSTR_FILENAMEW             = 'FileNameW';              { CF_FILENAMEW }
  CFSTR_PRINTERGROUP          = 'PrinterFriendlyName';    { CF_PRINTERS }
  CFSTR_FILENAMEMAPA          = 'FileNameMap';            { CF_FILENAMEMAPA }
  CFSTR_FILENAMEMAPW          = 'FileNameMapW';           { CF_FILENAMEMAPW }
  CFSTR_SHELLURL              = 'UniformResourceLocator';
  CFSTR_PREFERREDDROPEFFECT   = 'Preferred DropEffect';
  CFSTR_PERFORMEDDROPEFFECT   = 'Performed DropEffect';
  CFSTR_PASTESUCCEEDED        = 'Paste Succeeded';
  CFSTR_INDRAGLOOP            = 'InShellDragLoop';
  CFSTR_FILEDESCRIPTOR        = CFSTR_FILEDESCRIPTORA;
  CFSTR_FILENAME              = CFSTR_FILENAMEA;
  CFSTR_FILENAMEMAP           = CFSTR_FILENAMEMAPA;

  { FILEDESCRIPTOR.dwFlags field indicate which fields are to be used }
  FD_CLSID            = $0001;
  FD_SIZEPOINT        = $0002;
  FD_ATTRIBUTES       = $0004;
  FD_CREATETIME       = $0008;
  FD_ACCESSTIME       = $0010;
  FD_WRITESTIME       = $0020;
  FD_FILESIZE         = $0040;
  FD_LINKUI           = $8000;       { 'link' UI is prefered }
type
  { TSHItemID -- Item ID }
  PSHItemID = ^TSHItemID;
  _SHITEMID = record
    cb: Word;                         { Size of the ID (including cb itself) }
    abID: array[0..0] of Byte;        { The item ID (variable length) }
  end;
  TSHItemID = _SHITEMID;
  SHITEMID = _SHITEMID;

  { format of CF_IDLIST }
  PIDA = ^TIDA;
  _IDA = record
    cidl: UINT;                      { number of relative IDList }
    aoffset: array[0..0] of UINT;    { [0]: folder IDList, [1]-[cidl]: item IDList }
  end;
  TIDA = _IDA;
  CIDA = _IDA;

  { TItemIDList -- List if item IDs (combined with 0-terminator) }
  PItemIDList = ^TItemIDList;
  _ITEMIDLIST = record
     mkid: TSHItemID;
   end;
  TItemIDList = _ITEMIDLIST;
  ITEMIDLIST = _ITEMIDLIST;

{ record for returning strings from IShellFolder member functions }
  PSTRRet = ^TStrRet;
  _STRRET = record
     uType: UINT;              { One of the STRRET_* values }
     case Integer of
       0: (pOleStr: LPWSTR);                    { must be freed by caller of GetDisplayNameOf }
       1: (pStr: LPSTR);                        { NOT USED }
       2: (uOffset: UINT);                      { Offset into SHITEMID (ANSI) }
       3: (cStr: array[0..MAX_PATH-1] of Char); { Buffer to fill in }
    end;
  TStrRet = _STRRET;
  STRRET = _STRRET;

  IEnumIDList = interface(IUnknown)
    ['{000214F2-0000-0000-C000-000000000046}']
    function Next(celt: ULONG; out rgelt: PItemIDList;
      var pceltFetched: ULONG): HResult; stdcall;
    function Skip(celt: ULONG): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out ppenum: IEnumIDList): HResult; stdcall;
  end;

  IShellFolder = interface(IUnknown)
    ['{000214E6-0000-0000-C000-000000000046}']
    function ParseDisplayName(hwndOwner: HWND;
      pbcReserved: Pointer; lpszDisplayName: POLESTR; out pchEaten: ULONG;
      out ppidl: PItemIDList; var dwAttributes: ULONG): HResult; stdcall;
    function EnumObjects(hwndOwner: HWND; grfFlags: DWORD;
      out EnumIDList: IEnumIDList): HResult; stdcall;
    function BindToObject(pidl: PItemIDList; pbcReserved: Pointer;
      const riid: TIID; out ppvOut): HResult; stdcall;
    function BindToStorage(pidl: PItemIDList; pbcReserved: Pointer;
      const riid: TIID; out ppvObj): HResult; stdcall;
    function CompareIDs(lParam: LPARAM;
      pidl1, pidl2: PItemIDList): HResult; stdcall;
    function CreateViewObject(hwndOwner: HWND; const riid: TIID;
      out ppvOut): HResult; stdcall;
    function GetAttributesOf(cidl: UINT; var apidl: PItemIDList;
      var rgfInOut: UINT): HResult; stdcall;
    function GetUIObjectOf(hwndOwner: HWND; cidl: UINT; var apidl: PItemIDList;
      const riid: TIID; prgfInOut: Pointer; out ppvOut): HResult; stdcall;
    function GetDisplayNameOf(pidl: PItemIDList; uFlags: DWORD;
      var lpName: TStrRet): HResult; stdcall;
    function SetNameOf(hwndOwner: HWND; pidl: PItemIDList; lpszName: POLEStr;
      uFlags: DWORD; var ppidlOut: PItemIDList): HResult; stdcall;
  end;

  PFileDescriptorA = ^TFileDescriptorA;
  PFileDescriptorW = ^TFileDescriptorW;
  PFileDescriptor = {$ifdef bUnicode}PFileDescriptorW{$else}PFileDescriptorA{$endif bUnicode};

  _FILEDESCRIPTORA = record
    dwFlags: DWORD;
    clsid: TCLSID;
    sizel: TSize;
    pointl: TPoint;
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    cFileName: array[0..MAX_PATH-1] of AnsiChar;
  end;
  _FILEDESCRIPTORW = record
    dwFlags: DWORD;
    clsid: TCLSID;
    sizel: TSize;
    pointl: TPoint;
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    cFileName: array[0..MAX_PATH-1] of WideChar;
  end;
  _FILEDESCRIPTOR = {$ifdef bUnicode}_FILEDESCRIPTORW{$else}_FILEDESCRIPTORA{$endif bUnicode};

  TFileDescriptorA = _FILEDESCRIPTORA;
  TFileDescriptorW = _FILEDESCRIPTORW;
  TFileDescriptor = {$ifdef bUnicode}TFileDescriptorW{$else}TFileDescriptorA{$endif bUnicode};

  FILEDESCRIPTORA = _FILEDESCRIPTORA;
  FILEDESCRIPTORW = _FILEDESCRIPTORW;
  FILEDESCRIPTOR = {$ifdef bUnicode}FILEDESCRIPTORW{$else}FILEDESCRIPTORA{$endif bUnicode};

{ format of CF_FILEGROUPDESCRIPTOR }

  PFileGroupDescriptorA = ^TFileGroupDescriptorA;
  PFileGroupDescriptorW = ^TFileGroupDescriptorW;
  PFileGroupDescriptor = {$ifdef bUnicode}PFileGroupDescriptorW{$else}PFileGroupDescriptorA{$endif bUnicode};

  _FILEGROUPDESCRIPTORA = record
    cItems: UINT;
    fgd: array[0..0] of TFileDescriptor;
  end;
  _FILEGROUPDESCRIPTORW = record
    cItems: UINT;
    fgd: array[0..0] of TFileDescriptor;
  end;
  _FILEGROUPDESCRIPTOR = {$ifdef bUnicode}_FILEGROUPDESCRIPTORW{$else}_FILEGROUPDESCRIPTORA{$endif bUnicode};

  TFileGroupDescriptorA = _FILEGROUPDESCRIPTORA;
  TFileGroupDescriptorW = _FILEGROUPDESCRIPTORW;
  TFileGroupDescriptor = {$ifdef bUnicode}TFileGroupDescriptorW{$else}TFileGroupDescriptorA{$endif bUnicode};

  FILEGROUPDESCRIPTORA = _FILEGROUPDESCRIPTORA;
  FILEGROUPDESCRIPTORW = _FILEGROUPDESCRIPTORW;
  FILEGROUPDESCRIPTOR = {$ifdef bUnicode}FILEGROUPDESCRIPTORW{$else}FILEGROUPDESCRIPTORA{$endif bUnicode};

function SHGetDesktopFolder(var ppshf: IShellFolder): HResult;
                            stdcall; external 'shell32.dll' name 'SHGetDesktopFolder';
function SHGetMalloc(ppMalloc: IMalloc): HResult;
                     stdcall; external 'shell32.dll' name 'SHGetMalloc';

// -----------------------------------------------------------------------------
//			Miscellaneous functions.
// -----------------------------------------------------------------------------

function GetSizeOfPidl(pidl: pItemIDList): integer;
var
  i: integer;
begin
  result := SizeOf(Word);
  repeat
    i := pSHItemID(pidl)^.cb;
    inc(result,i);
    inc(longint(pidl),i);
  until i = 0;
end;
// -----------------------------------------------------------------------------

function GetShellFolderOfPath(FolderPath: TFileName): IShellFolder;
var
  DeskTopFolder: IShellFolder;
  PathPidl: pItemIDList;
  OlePath: array[0..MAX_PATH] of WideChar;
  dummy,pdwAttributes: ULONG;
begin
  result := nil;
  StringToWideChar( FolderPath, OlePath, MAX_PATH );
  pdwAttributes := SFGAO_FOLDER;
  try
    if not (SHGetDesktopFolder(DeskTopFolder) = NOERROR) then exit;
    if (DesktopFolder.ParseDisplayName(0,
          nil,OlePath,dummy,PathPidl,pdwAttributes) = NOERROR) and
          (pdwAttributes and SFGAO_FOLDER <> 0) then
      DesktopFolder.BindToObject(PathPidl,nil,IID_IShellFolder,pointer(result));
    ShellMalloc.Free(PathPidl);
  except
  end;
end;
// -----------------------------------------------------------------------------

function GetFullPIDLFromPath(Path: TFileName): pItemIDList;
var
   DeskTopFolder: IShellFolder;
   OlePath: array[0..MAX_PATH] of WideChar;
   dummy1,dummy2: ULONG;
begin
  result := nil;
  StringToWideChar( Path, OlePath, MAX_PATH );
  try
    if (SHGetDesktopFolder(DeskTopFolder) = NOERROR) then
      DesktopFolder.ParseDisplayName(0,nil,OlePath,dummy1,result,dummy2);
  except
  end;
end;
// -----------------------------------------------------------------------------

function GetSubPidl(Folder: IShellFolder; Sub: TFilename): pItemIDList;
var
  dummy1,dummy2: ULONG;
  OleFile: array[0..MAX_PATH] of WideChar;
begin
  result := nil;
  try
    StringToWideChar( Sub, OleFile, MAX_PATH );
    Folder.ParseDisplayName(0,nil,OleFile,dummy1,result,dummy2);
  except
  end;
end;
// -----------------------------------------------------------------------------

//See "Clipboard Formats for Shell Data Transfers" in Ole.hlp...
//(Needed to drag links (shortcuts).)

type
  POffsets = ^TOffsets;
  TOffsets = array[0..$FFFF] of UINT;

function ConvertFilesToShellIDList(path: string; files: PStrList): HGlobal;
var
  shf: IShellFolder;
  PathPidl, pidl: pItemIDList;
  Ida: PIDA;
  pOffset: POffsets;
  ptrByte: ^Byte;
  i, PathPidlSize, IdaSize, PreviousPidlSize: integer;
begin
  result := 0;
  shf := GetShellFolderOfPath(path);
  if shf = nil then exit;
  //Calculate size of IDA structure ...
  // cidl: UINT ; Directory pidl offset: UINT ; all file pidl offsets
  IdaSize := (files.count + 2) * sizeof(UINT);

  PathPidl := GetFullPIDLFromPath(path);
  if PathPidl = nil then exit;
  PathPidlSize := GetSizeOfPidl(PathPidl);

  //Add to IdaSize space for ALL pidls...
  IdaSize := IdaSize + PathPidlSize;
  for i := 0 to files.count-1 do
  begin
    pidl := GetSubPidl(shf,files.Items[i]);
    IdaSize := IdaSize + GetSizeOfPidl(Pidl);
    ShellMalloc.Free(pidl);
  end;

  //Allocate memory...
  Result := GlobalAlloc(GMEM_SHARE or GMEM_ZEROINIT, IdaSize);
  if (Result = 0) then
  begin
    ShellMalloc.Free(PathPidl);
    Exit;
  end;

  Ida := GlobalLock(Result);
  try
    FillChar(Ida^,IdaSize,0);

    //Fill in offset and pidl data...
    Ida^.cidl := files.count; //cidl = file count
    pOffset := @(Ida^.aoffset);
    pOffset^[0] := (files.count+2) * sizeof(UINT); //offset of Path pidl

    ptrByte := pointer(Ida);
    inc(ptrByte,pOffset^[0]); //ptrByte now points to Path pidl
    move(PathPidl^, ptrByte^, PathPidlSize); //copy path pidl
    ShellMalloc.Free(PathPidl);

    PreviousPidlSize := PathPidlSize;
    for i := 1 to files.count do
    begin
      pidl := GetSubPidl(shf,files.Items[i-1]);
      pOffset^[i] := pOffset^[i-1] + UINT(PreviousPidlSize); //offset of pidl
      PreviousPidlSize := GetSizeOfPidl(Pidl);

      ptrByte := pointer(Ida);
      inc(ptrByte,pOffset^[i]); //ptrByte now points to current file pidl
      move(Pidl^, ptrByte^, PreviousPidlSize); //copy file pidl
                            //PreviousPidlSize = current pidl size here
      ShellMalloc.Free(pidl);
    end;
  finally
    GlobalUnLock(Result);
  end;
end;
// -----------------------------------------------------------------------------

procedure Register;
begin
  //RegisterComponents('DragDrop',[TDropFileSource, TDropTextSource]);
end;

// -----------------------------------------------------------------------------
//			TInterfacedComponent
// -----------------------------------------------------------------------------

function TInterfacedComponent.QueryInterface(const IID: TGuid; out Obj): HRESULT;
begin
  if GetInterface(IID, Obj) then result := 0 else result := E_NOINTERFACE;
end;
// -----------------------------------------------------------------------------

function TInterfacedComponent._AddRef: Integer;
begin
  result := InterlockedIncrement(fRefCount);
end;
// -----------------------------------------------------------------------------

function TInterfacedComponent._Release: Integer;
begin
  Result := InterlockedDecrement(fRefCount);
  if (Result = 0) then
    Free;
end;

// -----------------------------------------------------------------------------
//			TEnumFormatEtc
// -----------------------------------------------------------------------------

type

pFormatList = ^TFormatList;
TFormatList = array[0..255] of TFormatEtc;

TEnumFormatEtc = class(TInterfacedObject, IEnumFormatEtc)
private
  fFormatList: pFormatList;
  fFormatCount: Integer;
  fIndex: Integer;
public
  constructor Create(FormatList: pFormatList; FormatCount, Index: Integer);
  { IEnumFormatEtc }
  function Next(Celt: LongInt; out Elt; pCeltFetched: pLongInt): HRESULT; stdcall;
  function Skip(Celt: LongInt): HRESULT; stdcall;
  function Reset: HRESULT; stdcall;
  function Clone(out Enum: IEnumFormatEtc): HRESULT; stdcall;
end;
// -----------------------------------------------------------------------------

constructor TEnumFormatEtc.Create(FormatList: pFormatList;
            FormatCount, Index: Integer);
begin
  inherited Create;
  fFormatList := FormatList;
  fFormatCount := FormatCount;
  fIndex := Index;
end;
// -----------------------------------------------------------------------------

function TEnumFormatEtc.Next(Celt: LongInt;
  out Elt; pCeltFetched: pLongInt): HRESULT;
var
  i: Integer;
begin
  i := 0;
  WHILE (i < Celt) and (fIndex < fFormatCount) do
  begin
    TFormatList(Elt)[i] := fFormatList[fIndex];
    Inc(fIndex);
    Inc(i);
  end;
  if pCeltFetched <> NIL then pCeltFetched^ := i;
  if i = Celt then result := S_OK else result := S_FALSE;
end;
// -----------------------------------------------------------------------------

function TEnumFormatEtc.Skip(Celt: LongInt): HRESULT;
begin
  if Celt <= fFormatCount - fIndex then
  begin
    fIndex := fIndex + Celt;
    result := S_OK;
  end else
  begin
    fIndex := fFormatCount;
    result := S_FALSE;
  end;
end;
// -----------------------------------------------------------------------------

function TEnumFormatEtc.ReSet: HRESULT;
begin
  fIndex := 0;
  result := S_OK;
end;
// -----------------------------------------------------------------------------

function TEnumFormatEtc.Clone(out Enum: IEnumFormatEtc): HRESULT;
begin
  enum := TEnumFormatEtc.Create(fFormatList, fFormatCount, fIndex);
  result := S_OK;
end;

// -----------------------------------------------------------------------------
//			TDropSource
// -----------------------------------------------------------------------------

constructor TDropSource.Create;
begin
  inherited Create;
  DragTypes := [dtCopy]; //default to Copy.
  //to avoid premature release ...
  _AddRef;
  fDataFormatsCount := 0;
  fImageHotSpot := MakePoint(16,16);
  fImages := nil;
end;
// -----------------------------------------------------------------------------

function TDropSource.GiveFeedback(dwEffect: LongInt): HRESULT; stdcall;
var
  UseDefaultCursors: Boolean;
begin
  UseDefaultCursors := true;
  FeedbackEffect := dwEffect;
  if Assigned(OnFeedback) then
    OnFeedback(Self, dwEffect, UseDefaultCursors);
  if UseDefaultCursors then
    result := DRAGDROP_S_USEDEFAULTCURSORS else
    result := S_OK;
end;
// -----------------------------------------------------------------------------

function TDropSource.GetCanonicalFormatEtc(const FormatEtc: TFormatEtc;
         out FormatEtcout: TFormatEtc): HRESULT;
begin
  result := DATA_S_SAMEFORMATETC;
end;
// -----------------------------------------------------------------------------

function TDropSource.SetData(const FormatEtc: TFormatEtc; var Medium: TStgMedium;
         fRelease: Bool): HRESULT;
begin
  result := E_NOTIMPL;
end;
// -----------------------------------------------------------------------------

function TDropSource.DAdvise(const FormatEtc: TFormatEtc; advf: LongInt;
         const advSink: IAdviseSink; out dwConnection: LongInt): HRESULT;
begin
  result := OLE_E_ADVISENOTSUPPORTED;
end;
// -----------------------------------------------------------------------------

function TDropSource.DUnadvise(dwConnection: LongInt): HRESULT;
begin
  result := OLE_E_ADVISENOTSUPPORTED;
end;
// -----------------------------------------------------------------------------

function TDropSource.EnumDAdvise(out EnumAdvise: IEnumStatData): HRESULT;
begin
  result := OLE_E_ADVISENOTSUPPORTED;
end;
// -----------------------------------------------------------------------------

function TDropSource.GetData(const FormatEtcIn: TFormatEtc;
  out Medium: TStgMedium):HRESULT; stdcall;
begin
  result := DoGetData(FormatEtcIn, Medium);
end;
// -----------------------------------------------------------------------------

function TDropSource.GetDataHere(const FormatEtc: TFormatEtc;
  out Medium: TStgMedium):HRESULT; stdcall;
begin
  result := E_NOTIMPL;
end;
// -----------------------------------------------------------------------------

function TDropSource.QueryGetData(const FormatEtc: TFormatEtc): HRESULT; stdcall;
var
  i: integer;
begin
  result:= S_OK;
  for i := 0 to fDataFormatsCount-1 do
    with fDataFormats[i] do
    begin
      if (FormatEtc.cfFormat = cfFormat) and
         (FormatEtc.dwAspect = dwAspect) and
         (FormatEtc.tymed and tymed <> 0) then exit; //result:= S_OK;
    end;
  result:= E_FAIL;
end;
// -----------------------------------------------------------------------------

function TDropSource.EnumFormatEtc(dwDirection: LongInt;
  out EnumFormatEtc:IEnumFormatEtc): HRESULT; stdcall;
begin
  if (dwDirection = DATADIR_GET) then
  begin
    EnumFormatEtc :=
      TEnumFormatEtc.Create(@fDataFormats, fDataFormatsCount, 0);
    result := S_OK;
  end else if (dwDirection = DATADIR_SET) then
    result := E_NOTIMPL
  else result := E_INVALIDARG;
end;
// -----------------------------------------------------------------------------

function TDropSource.QueryContinueDrag(fEscapePressed: bool;
  grfKeyState: LongInt): HRESULT; stdcall;
var
  ContinueDrop: Boolean;
  dragtype: TDragType;
begin
  if fEscapePressed then
    result := DRAGDROP_S_CANCEL
  // will now allow drag and drop with either mouse button.
  else if (grfKeyState and (MK_LBUTTON or MK_RBUTTON) = 0) then
  begin
    ContinueDrop := True;
    dragtype := dtCopy;
    if (FeedbackEffect and DROPEFFECT_COPY <> 0) then DragType := dtCopy
    else if (FeedbackEffect and DROPEFFECT_MOVE <> 0) then dragtype := dtMove
    else if (FeedbackEffect and DROPEFFECT_LINK <> 0) then dragtype := dtLink
    else ContinueDrop := False;

    if not (DragType in dragtypes) then ContinueDrop := False;
    //if a valid drop then do OnDrop event if assigned...
    if {ContinueDrop and }Assigned(OnDrop) then
      OnDrop(Self, dragtype, ContinueDrop);

    if ContinueDrop then result := DRAGDROP_S_DROP
    else result := DRAGDROP_S_CANCEL;
  end else
    result := NOERROR;
end;
// -----------------------------------------------------------------------------

function TDropSource.Execute: TDragResult;
var
  res: HRESULT;
  okeffect, effect: longint;
  IsDraggingImage: boolean;
begin
  Init;
  result := drUnknown;
  okeffect := DROPEFFECT_NONE;
  if (dtCopy in fDragTypes) then okeffect := okeffect or DROPEFFECT_COPY;
  if (dtMove in fDragTypes) then okeffect := okeffect or DROPEFFECT_MOVE;
  if (dtLink in fDragTypes) then okeffect := okeffect or DROPEFFECT_LINK;

  if (fShowImage) and (fImages <> nil) then
    IsDraggingImage := ImageList_BeginDrag(fImages.Handle, fImageIndex, fImageHotSpot.X, fImageHotSpot.Y)
  else
    IsDraggingImage := False;

  res := DoDragDrop(Self as IDataObject, Self as IDropSource, okeffect, effect);

  if IsDraggingImage then ImageList_EndDrag;

  case res of
    DRAGDROP_S_DROP:
      begin
        if (okeffect and effect <> 0) then
        begin
          if (effect and DROPEFFECT_COPY <> 0) then result := drDropCopy
          else if (effect and DROPEFFECT_MOVE <> 0) then result := drDropMove
          else result := drDropLink;
        end else
          result := drCancel;
      end;
    DRAGDROP_S_CANCEL: result := drCancel;
    E_OUTOFMEMORY:     result := drOutMemory;
  end;
end;

// -----------------------------------------------------------------------------

procedure TDropSource.AddFormatEtc(cfFmt: TClipFormat;
  pt: PDVTargetDevice; dwAsp, lInd, tym: longint);
begin
  if fDataFormatsCount = MAXFORMATS then exit;

  fDataFormats[fDataFormatsCount].cfFormat := cfFmt;
  fDataFormats[fDataFormatsCount].ptd := pt;
  fDataFormats[fDataFormatsCount].dwAspect := dwAsp;
  fDataFormats[fDataFormatsCount].lIndex := lInd;
  fDataFormats[fDataFormatsCount].tymed := tym;
  inc(fDataFormatsCount);
end;
// -----------------------------------------------------------------------------

function TDropSource.CutToClipboard: boolean;
begin
  //sets CF_PREFERREDDROPEFFECT...
  Result := InternalCutCopyToClipboard(DROPEFFECT_MOVE);
end;
// -----------------------------------------------------------------------------

function TDropSource.CopyToClipboard: boolean;
begin
  //sets CF_PREFERREDDROPEFFECT...
  Result := InternalCutCopyToClipboard(DROPEFFECT_COPY);
end;
// -----------------------------------------------------------------------------

function TDropSource.CutOrCopyToClipboard: boolean;
begin
  Result := False;
end;
// -----------------------------------------------------------------------------

//1. Renders the CF_PREFERREDDROPEFFECT clipboard dataobject.
//2. Encloses all calls to Clipboard.SetAsHandle() between Clipboard.Open and
//Clipboard.Close so multiple clipboard formats can be rendered in CutOrCopyToClipboard().
function TDropSource.InternalCutCopyToClipboard(Effect: LongInt): boolean;
var
  FormatEtc: TFormatEtc;
  Medium: TStgMedium;
begin
  OpenClipboard(Applet.Handle);
  try
    Result := CutOrCopyToClipboard;
    if not Result then exit;

    FeedbackEffect := Effect;
    FormatEtc.cfFormat := CF_PREFERREDDROPEFFECT;
    FormatEtc.dwAspect := DVASPECT_CONTENT;
    FormatEtc.tymed := TYMED_HGLOBAL;

    if GetData(FormatEtc, Medium) = S_OK then
    begin
      SetClipboardData(CF_PREFERREDDROPEFFECT, Medium.hGlobal);
    end else
      Result := False;
  finally
    CloseClipboard;
  end;
end;
// -----------------------------------------------------------------------------

procedure TDropSource.SetImages(const Value: pImageList);
begin
  if fImages = Value then exit;
  fImages := Value;

  fImageIndex := 0;
  if (fImages <> nil) then
    fShowImage := true else
    fShowImage := False;
end;
// -----------------------------------------------------------------------------

procedure TDropSource.SetImageIndex(const Value: integer);
begin
  if (Value < 0) or (FImages.Count = 0) or (FImages = nil) then
  begin
    fImageIndex := 0;
    fShowImage := False;
  end
  else if (Value < fImages.Count) then
    fImageIndex := Value;
end;
// -----------------------------------------------------------------------------

procedure TDropSource.SetPoint(Index: integer; Value: integer);
begin
  if (Index = 1) then
    fImageHotSpot.x := Value
  else
    fImageHotSpot.y := Value;
end;
// -----------------------------------------------------------------------------

function TDropSource.GetPoint(Index: integer): integer;
begin
  if (Index = 1) then
    Result := fImageHotSpot.x
  else
    Result := fImageHotSpot.y;
end;
// -----------------------------------------------------------------------------

procedure TDropSource.SetShowImage(Value: boolean);
begin
  fShowImage := Value;
  if (fImages = nil) then fShowImage := False;
end;
// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------
//			TDropTextSource
// -----------------------------------------------------------------------------

constructor TDropTextSource.Create;
begin
  inherited ;
  fText := '';

  AddFormatEtc(CF_TEXT, NIL, DVASPECT_CONTENT, -1, TYMED_HGLOBAL);
  //These next two formats have been commented out (for the time being)
  //as they interfer with text drag and drop in Word97.
  //AddFormatEtc(CF_FILEGROUPDESCRIPTOR, NIL, DVASPECT_CONTENT, -1, TYMED_HGLOBAL);
  //AddFormatEtc(CF_FILECONTENTS, NIL, DVASPECT_CONTENT, 0, TYMED_HGLOBAL);
end;
// -----------------------------------------------------------------------------

function TDropTextSource.CutOrCopyToClipboard: boolean;
var
  FormatEtcIn: TFormatEtc;
  Medium: TStgMedium;
begin
  FormatEtcIn.cfFormat := CF_TEXT;
  FormatEtcIn.dwAspect := DVASPECT_CONTENT;
  FormatEtcIn.tymed := TYMED_HGLOBAL;
  if fText = '' then result := false
  else if GetData(formatetcIn,Medium) = S_OK then
  begin
    SetClipboardData(CF_TEXT,Medium.hGlobal);
    result := true;
  end else result := false;
end;
// -----------------------------------------------------------------------------

function TDropTextSource.DoGetData(const FormatEtcIn: TFormatEtc;
  out Medium: TStgMedium):HRESULT;
var
  pFGD: PFileGroupDescriptor;
  pText: PChar;
begin

  Medium.tymed := 0;
  Medium.UnkForRelease := NIL;
  Medium.hGlobal := 0;

  //--------------------------------------------------------------------------
  if ((FormatEtcIn.cfFormat = CF_TEXT) or
    (FormatEtcIn.cfFormat = CF_FILECONTENTS)) and
    (FormatEtcIn.dwAspect = DVASPECT_CONTENT) and
    (FormatEtcIn.tymed and TYMED_HGLOBAL <> 0) then
  begin
    Medium.hGlobal := GlobalAlloc(GMEM_SHARE or GHND, Length(fText)+1);
    if (Medium.hGlobal = 0) then
      result := E_outOFMEMORY
    else
    begin
      medium.tymed := TYMED_HGLOBAL;
      pText := PChar(GlobalLock(Medium.hGlobal));
      try
        StrCopy(pText, PChar(fText));
      finally
        GlobalUnlock(Medium.hGlobal);
      end;
      result := S_OK;
    end;
  end
  //--------------------------------------------------------------------------
  else if (FormatEtcIn.cfFormat = CF_FILEGROUPDESCRIPTOR) and
    (FormatEtcIn.dwAspect = DVASPECT_CONTENT) and
    (FormatEtcIn.tymed and TYMED_HGLOBAL <> 0) then
  begin
    Medium.hGlobal := GlobalAlloc(GMEM_SHARE or GHND, SizeOf(TFileGroupDescriptor));
    if (Medium.hGlobal = 0) then
    begin
      result := E_outOFMEMORY;
      Exit;
    end;
    medium.tymed := TYMED_HGLOBAL;
    pFGD := pointer(GlobalLock(Medium.hGlobal));
    try
      with pFGD^ do
      begin
        cItems := 1;
        fgd[0].dwFlags := FD_LINKUI;
        fgd[0].cFileName := 'Text Scrap File.txt';
      end;
    finally
      GlobalUnlock(Medium.hGlobal);
    end;
    result := S_OK;
  end else
    result := DV_E_FORMATETC;
end;

// -----------------------------------------------------------------------------
//			TDropFileSource
// -----------------------------------------------------------------------------

constructor TDropFileSource.Create;
begin
  inherited Create;
  Files := NewStrList;
  MappedNames := NewStrList;

  AddFormatEtc(CF_HDROP, NIL, DVASPECT_CONTENT, -1, TYMED_HGLOBAL);
  AddFormatEtc(CF_IDLIST, NIL, DVASPECT_CONTENT, -1, TYMED_HGLOBAL);
  AddFormatEtc(CF_PREFERREDDROPEFFECT, NIL, DVASPECT_CONTENT, -1, TYMED_HGLOBAL);
  AddFormatEtc(CF_FILENAMEMAP, NIL, DVASPECT_CONTENT, -1, TYMED_HGLOBAL);
  AddFormatEtc(CF_FILENAMEMAPW, NIL, DVASPECT_CONTENT, -1, TYMED_HGLOBAL);
end;
// -----------------------------------------------------------------------------

destructor TDropFileSource.destroy;
begin
  Files.Free;
  MappedNames.free;
  inherited Destroy;
end;
// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------

function TDropFileSource.CutOrCopyToClipboard: boolean;
var
  FormatEtcIn: TFormatEtc;
  Medium: TStgMedium;
begin
  FormatEtcIn.cfFormat := CF_HDROP;
  FormatEtcIn.dwAspect := DVASPECT_CONTENT;
  FormatEtcIn.tymed := TYMED_HGLOBAL;
  if (Files.count = 0) then result := false
  else if GetData(formatetcIn,Medium) = S_OK then
  begin
    SetClipboardData(CF_HDROP,Medium.hGlobal);
    result := true;
  end else result := false;
end;
// -----------------------------------------------------------------------------

function TDropFileSource.DoGetData(const FormatEtcIn: TFormatEtc;
         out Medium: TStgMedium):HRESULT;
var
  i: Integer;
  dropfiles: PDragInfoA;
  pFile: PChar;
  pFileW: PWideChar;
  DropEffect: ^DWORD;
  strlength: Integer;
  tmpFilenames: PStrList;
begin
  Medium.tymed := 0;
  Medium.UnkForRelease := NIL;
  Medium.hGlobal := 0;

  if Files.count = 0 then result := E_UNEXPECTED
  //--------------------------------------------------------------------------
  else if (FormatEtcIn.cfFormat = CF_HDROP) and
    (FormatEtcIn.dwAspect = DVASPECT_CONTENT) and
    (FormatEtcIn.tymed and TYMED_HGLOBAL <> 0) then
  begin
    strlength := 0;
    for i := 0 to Files.Count-1 do
      Inc(strlength, Length(Files.Items[i])+1);
    Medium.hGlobal :=
      GlobalAlloc(GMEM_SHARE or GMEM_ZEROINIT, SizeOf(TDragInfoA)+strlength+1);
    if (Medium.hGlobal = 0) then
      result:=E_OUTOFMEMORY
    else
    begin
      Medium.tymed := TYMED_HGLOBAL;
      dropfiles := GlobalLock(Medium.hGlobal);
      try
        dropfiles^.uSize := SizeOf(TDragInfoA);
        dropfiles^.fNC := False;
        longint(pFile) := longint(dropfiles)+SizeOf(TDragInfoA);
        for i := 0 to Files.Count-1 do
        begin
          StrPCopy(pFile,Files.Items[i]);
          Inc(pFile, Length(Files.Items[i])+1);
        end;
        pFile^ := #0;
      finally
        GlobalUnlock(Medium.hGlobal);
      end;
      result := S_OK;
    end;
  end
  //--------------------------------------------------------------------------
  else if (FormatEtcIn.cfFormat = CF_FILENAMEMAP) and
    (FormatEtcIn.dwAspect = DVASPECT_CONTENT) and
    (FormatEtcIn.tymed and TYMED_HGLOBAL <> 0) and
    //make sure there is a Mapped Name for each filename...
    (MappedNames.Count = Files.Count) then
  begin
    strlength := 0;
    for i := 0 to MappedNames.Count-1 do
      Inc(strlength, Length(MappedNames.Items[i])+1);

    Medium.hGlobal :=
      GlobalAlloc(GMEM_SHARE or GMEM_ZEROINIT, strlength+1);
    if (Medium.hGlobal = 0) then
      result:=E_OUTOFMEMORY
    else
    begin
      Medium.tymed := TYMED_HGLOBAL;
      pFile := GlobalLock(Medium.hGlobal);
      try
        for i := 0 to MappedNames.Count-1 do
        begin
          StrPCopy(pFile,MappedNames.Items[i]);
          Inc(pFile, Length(MappedNames.Items[i])+1);
        end;
        pFile^ := #0;
      finally
        GlobalUnlock(Medium.hGlobal);
      end;
      result := S_OK;
    end;
  end
  //--------------------------------------------------------------------------
  else if (FormatEtcIn.cfFormat = CF_FILENAMEMAPW) and
    (FormatEtcIn.dwAspect = DVASPECT_CONTENT) and
    (FormatEtcIn.tymed and TYMED_HGLOBAL <> 0) and
    //make sure there is a Mapped Name for each filename...
    (MappedNames.Count = Files.Count) then
  begin
    strlength := 2;
    for i := 0 to MappedNames.Count-1 do
      Inc(strlength, (Length(MappedNames.Items[i])+1)*2);

    Medium.hGlobal := GlobalAlloc(GMEM_SHARE or GMEM_ZEROINIT, strlength);
    if (Medium.hGlobal = 0) then
      result:=E_OUTOFMEMORY
    else
    begin
      Medium.tymed := TYMED_HGLOBAL;
      pFileW := GlobalLock(Medium.hGlobal);
      try
        for i := 0 to MappedNames.Count-1 do
        begin
          StringToWideChar(MappedNames.Items[i], pFileW,
            (length(MappedNames.Items[i])+1)*2);
          Inc(pFileW, Length(MappedNames.Items[i])+1);
        end;
        pFileW^ := #0;
      finally
        GlobalUnlock(Medium.hGlobal);
      end;
      result := S_OK;
    end;
  end
  //--------------------------------------------------------------------------
  else if (FormatEtcIn.cfFormat = CF_IDLIST) and
    (FormatEtcIn.dwAspect = DVASPECT_CONTENT) and
    (FormatEtcIn.tymed and TYMED_HGLOBAL <> 0) then
  begin
    tmpFilenames := NewStrList;
    try
      Medium.tymed := TYMED_HGLOBAL;
      for i := 0 to Files.count-1 do
        tmpFilenames.add(extractfilename(Files.Items[i]));
      Medium.hGlobal :=
          ConvertFilesToShellIDList(extractfilepath(Files.Items[0]),tmpFilenames);
      if Medium.hGlobal = 0 then
        result:=E_outOFMEMORY else
        result := S_OK;
    finally
      tmpFilenames.free;
    end;
  end
  //--------------------------------------------------------------------------
  //This next format does not work for Win95 but should for Win98, WinNT ...
  //It stops the shell from prompting (with a popup menu) for the choice of
  //Copy/Move/Shortcut when performing a file 'Shortcut' onto Desktop or Explorer.
  else if (FormatEtcIn.cfFormat = CF_PREFERREDDROPEFFECT) and
    (FormatEtcIn.dwAspect = DVASPECT_CONTENT) and
    (FormatEtcIn.tymed and TYMED_HGLOBAL <> 0) then
  begin
    Medium.tymed := TYMED_HGLOBAL;
    Medium.hGlobal := GlobalAlloc(GMEM_SHARE or GMEM_ZEROINIT, SizeOf(DWORD));
    if Medium.hGlobal = 0 then
      result:=E_outOFMEMORY
    else
    begin
      DropEffect := GlobalLock(Medium.hGlobal);
      try
        DropEffect^ := DWORD(FeedbackEffect);
      finally
        GlobalUnLock(Medium.hGlobal);
      end;
      result := S_OK;
    end;
  end
  else
    result := DV_E_FORMATETC;
end;
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

procedure TDropSource.Init;
begin
  //
end;

initialization
  OleInitialize(nil);

  CF_FILECONTENTS := RegisterClipboardFormat(CFSTR_FILECONTENTS);
  CF_FILEGROUPDESCRIPTOR := RegisterClipboardFormat(CFSTR_FILEDESCRIPTOR);
  CF_IDLIST := RegisterClipboardFormat(CFSTR_SHELLIDLIST);
  CF_PREFERREDDROPEFFECT := RegisterClipboardFormat('Preferred DropEffect');
  CF_URL := RegisterClipboardFormat('UniformResourceLocator');
  CF_FILENAMEMAP := RegisterClipboardFormat(CFSTR_FILENAMEMAPA);
  CF_FILENAMEMAPW := RegisterClipboardFormat(CFSTR_FILENAMEMAPW);

  CoGetMalloc(MEMCTX_TASK, ShellMalloc)
finalization
  OleUninitialize;

end.
