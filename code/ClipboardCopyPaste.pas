unit ClipboardCopyPaste;

interface

uses kol, Windows, Share, Debug;

procedure GetDropType(var dt: cardinal);
procedure PutClipboard(PutType: integer; Arr: PArray);
function StringToWideString(const s: String; codePage: Word): WideString;
function WideStringToString(const ws: WideString): String;

implementation

uses ShellAPI, ActiveX;

const
  IID_IEnumIDList:   TGUID = (D1:$000214F2; D2:$0000; D3:$0000; D4:($C0,$00,$00,$00,$00,$00,$00,$46));
  IID_IShellFolder:  TGUID = (D1:$000214E6; D2:$0000; D3:$0000; D4:($C0,$00,$00,$00,$00,$00,$00,$46));

  DROPEFFECT_NONE   = 0;
  DROPEFFECT_COPY   = 1;
  DROPEFFECT_MOVE   = 2;
  DROPEFFECT_LINK   = 4;
  DROPEFFECT_SCROLL = $80000000;

  { IShellFolder.GetAttributesOf flags }
  SFGAO_FOLDER            = $20000000;       { It's a folder. }

type
  TFileName = String;
  POffsets = ^TOffsets;
  TOffsets = array[0..$FFFF] of UINT;

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

function SHGetDesktopFolder(var ppshf: IShellFolder): HResult;
                            stdcall; external 'shell32.dll' name 'SHGetDesktopFolder';

function StringToWideString(const s: String; codePage: Word): WideString;
  var len: integer;
  begin
    Result := '';
    if s = '' then exit;
    len := MultiByteToWideChar(codePage, MB_PRECOMPOSED, PChar(@s[1]), -1, nil, 0);
    SetLength(Result, len - 1);
    if len <= 1 then exit;
    MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PChar(@s[1]), -1, PWideChar(@Result[1]), len);
  end;

function WideStringToString(const ws: WideString): String;
  var
    l: integer;
  begin
    if ws = '' then
      Result := ''
    else
    begin
      l := WideCharToMultiByte(CP_ACP, WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR, PWChar(ws), -1, nil, 0, nil, nil);
      SetLength(Result, l - 1);
      if l > 1 then
        WideCharToMultiByte(CP_ACP, WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR, PWChar(ws), -1, PChar(Result), l - 1, nil, nil);
    end;
  end;

function ExtractShortPathName(const FileName: string): string;
  var Buffer: array[0..MAX_PATH - 1] of Char;
  begin
    SetString(Result, Buffer, GetShortPathName(PChar(FileName), Buffer, SizeOf(Buffer)));
  end;

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

function GetSubPidl(Folder: IShellFolder; Sub: TFilename): pItemIDList;
  var
    pchEaten, Attr: Cardinal;
    CDir: PWideChar;
  begin
    result := nil;
    try
      CDir := PWideChar(StringToWideString(Sub, 3));
      Folder.ParseDisplayName(Applet.Handle, nil, CDir, pchEaten, result, Attr);
    finally
    end;
  end;

function ConvertFilesToShellIDList(path: string; files: PStrList): HGlobal;
  var
    shf: IShellFolder;
    PathPidl, pidl: pItemIDList;
    Ida: PIDA;
    pOffset: POffsets;
    ptrByte: ^Byte;
    i, PathPidlSize, IdaSize, PreviousPidlSize: integer;
    MAlloc: IMAlloc;
    CDir: PWideChar;
    pchEaten, Attr: Cardinal;
  begin
    result := 0;
    PathPidl := nil;
    MAlloc := nil;
    Attr := 0;
    try
      if CoGetMalloc(MEMCTX_TASK, MAlloc) <> S_OK then Exit;
      if SHGetDesktopFolder(shf) <> S_OK then exit;
      CDir := PWideChar(StringToWideString(ExtractFilePath(path), 3));
      if shf.ParseDisplayName(Applet.Handle, nil, CDir, pchEaten, PathPIDL, Attr) <> S_OK then exit;
      if PathPidl = nil then exit;
      IdaSize := (files.count + 2) * sizeof(UINT);
      PathPidlSize := GetSizeOfPidl(PathPidl);
      //Add to IdaSize space for ALL pidls...
      IdaSize := IdaSize + PathPidlSize;
      for i := 0 to files.count-1 do begin
        pidl := GetSubPidl(shf, files.Items[i]);
        IdaSize := IdaSize + GetSizeOfPidl(pidl);
        MAlloc.Free(pidl);
      end;
      //Allocate memory...
      Result := GlobalAlloc(GMEM_SHARE or GMEM_ZEROINIT, IdaSize);
      if Result = 0 then
      begin
        MAlloc.Free(PathPidl);
        Exit;
      end;
      Ida := GlobalLock(Result);
      FillChar(Ida^,IdaSize,0);
      //Fill in offset and pidl data...
      Ida^.cidl := files.count; //cidl = file count
      pOffset := @(Ida^.aoffset);
      pOffset^[0] := (files.count+2) * sizeof(UINT); //offset of Path pidl
      ptrByte := pointer(Ida);
      inc(ptrByte,pOffset^[0]); //ptrByte now points to Path pidl
      move(PathPidl^, ptrByte^, PathPidlSize); //copy path pidl
      MAlloc.Free(PathPidl);
      PreviousPidlSize := PathPidlSize;
      for i := 1 to files.count do
      begin
        pidl := GetSubPidl(shf, files.Items[i-1]);
        pOffset^[i] := pOffset^[i-1] + UINT(PreviousPidlSize); //offset of pidl
        PreviousPidlSize := GetSizeOfPidl(Pidl);
        ptrByte := pointer(Ida);
        inc(ptrByte,pOffset^[i]); //ptrByte now points to current file pidl
        move(Pidl^, ptrByte^, PreviousPidlSize); //copy file pidl
                              //PreviousPidlSize = current pidl size here
        MAlloc.Free(pidl);
      end;
    finally
      GlobalUnLock(Result);
    end;
  end;

procedure GetDropType(var dt: cardinal);
  var
    ClipFormat, hn, op: Cardinal;
    szBuffer: array[0..511] of Char;
    FormatID: string;
    pMem: Pointer;
  begin
    ClipFormat := EnumClipboardFormats(0);
    while (ClipFormat <> 0) do begin
      GetClipboardFormatName(ClipFormat, szBuffer, SizeOf(szBuffer));
      FormatID := string(szBuffer);
      if FormatID = 'Preferred DropEffect' then begin
        hn := GetClipboardData(ClipFormat);
        pMem := GlobalLock(hn);
        Move(pMem^, op, 4);
        if op = DROPEFFECT_MOVE then dt := 1 else dt := 0;
        GlobalUnlock(hn);
        Break;
      end;
      ClipFormat := EnumClipboardFormats(ClipFormat);
    end;
  end;

procedure PutClipboard;
  type 
    pcardinal = ^cardinal;
  var
    DropFiles: PDragInfoA;
    Data: PWideString;
    d: pcardinal;
    hGlobal: THandle;
    f: UINT;
    Item: TData;
    eIndex: TData;
    op, Size: integer;
    FileList, st: string;
    iLen, i: Integer;
    s: WideString;
    tmpFilenames: PStrList;
    CoInit: HRESULT;
    pst: PString;
  begin
    if not OpenClipboard(Applet.Handle) then Exit;
    EmptyClipboard();
    if bool(PutType) then op := DROPEFFECT_MOVE else op := DROPEFFECT_COPY or DROPEFFECT_LINK;
    tmpFilenames := NewStrList;
    for i := 0 to Arr._Count-1 do begin
      dtInteger(eIndex, i);
      Arr._Get(eIndex, Item);
      st := ToString(Item);
      FileList := FileList + st + #0;
      tmpFilenames.add(st);
    end;
    try
      // Shell IDList Array
      f := RegisterClipboardFormat(PChar('Shell IDList Array'));
      CoInit := CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
      hGlobal := ConvertFilesToShellIDList(tmpFilenames.Items[0], tmpFilenames);
      SetClipboardData(f, hGlobal);
      GlobalUnlock(hGlobal);

      // CF_HDROP
      iLen := Length(FileList) + 2;
      FileList := FileList + #0#0;
      hGlobal := GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT, SizeOf(TDragInfoA) + iLen);
      DropFiles := GlobalLock(hGlobal);
      DropFiles^.uSize := SizeOf(TDragInfoA);
      Move(FileList[1], (PChar(DropFiles) + SizeOf(TDragInfoA))^, iLen);
      GlobalUnlock(hGlobal);
      SetClipboardData(CF_HDROP, hGlobal);

      // Preferred DropEffect
      f := RegisterClipboardFormat(PChar('Preferred DropEffect'));
      hGlobal := GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT, sizeof(dword));
      d := pcardinal(GlobalLock(hGlobal));
      d^ := op;
      SetClipboardData(f, hGlobal);
      GlobalUnlock(hGlobal);

      // Shell Object Offsets
      // TODO
    
      // Item ansi shotname
      f := RegisterClipboardFormat(PChar('FileName'));
      st := ExtractShortPathName(ToString(Item));
      Size := Length(st) + 1;
      hGlobal := GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT, Size);
      pst := GlobalLock(hGlobal);
      Move(Pointer(st)^, pst^, Size);
      SetClipboardData(f, hGlobal);
      GlobalUnlock(hGlobal);

      // Item widestring name
      f := RegisterClipboardFormat(PChar('FileNameW'));
      s := StringToWideString(ToString(Item), 3);
      Size := Length(s) * 2 + 2;
      hGlobal := GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT, Size);
      Data := GlobalLock(hGlobal);
      Move(Pointer(s)^, Data^, Size);
      SetClipboardData(f, hGlobal);
      GlobalUnlock(hGlobal);
    finally
      CloseClipboard;
      tmpFilenames.free;
      if CoInit = S_OK then CoUninitialize;
    end;
  end;

end.
