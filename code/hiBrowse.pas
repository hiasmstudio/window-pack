unit hiBrowse;

interface

uses Kol,Share,ShellAPI,Windows,Debug, Messages{,ShlObj};

type
  THIBrowse = class(TDebug)
   private
     function GetFlag(const Flag:integer):integer;
     function BrowseDialog(const Title: string; const Flag: integer): string;
   public
    _prop_DefaultFolder:string;
    _prop_BrowseObj:byte;
    _prop_Title:string;
    _prop_Edit:integer;
    _prop_NewStyle:integer;
    _prop_NewDirButton:integer;
    _event_onBrowse:THI_Event;
    _event_onCancel:THI_Event;

    procedure _work_doBrowse(var _Data:TData; Index:word);
    procedure _work_doDefaultFolder(var _Data:TData; Index:word);
  end;

implementation

const
  BFFM_INITIALIZED       = 1;
  BFFM_SETSELECTION      = WM_USER + 102;
  //BIF_RETURNONLYFSDIRS   = $0001;
  BIF_STATUSTEXT         = $0004;
  BIF_EDITBOX            = $0010;
  BIF_NEWDIALOGSTYLE     = $0040;
  BIF_NONEWFOLDERBUTTON  = $0200;  
  BIF_BROWSEFORCOMPUTER  = $1000;
  BIF_BROWSEFORPRINTER   = $2000;
  //BIF_BROWSEINCLUDEFILES = $4000;
  ObjType:array[0..3]of word = ($0001 or 28,BIF_BROWSEFORCOMPUTER,BIF_BROWSEFORPRINTER,$4000);
  CSIDL_NETWORK  = $0012;
  CSIDL_PRINTERS = $0004;  

type
  TSHItemID = record
    cb: Word;
    abID: array[0..0] of Byte;
  end;
  PItemIDList = ^TItemIDList;
  TItemIDList = record
     mkid: TSHItemID;
  end;
  TFNBFFCallBack = function(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
  TBrowseInfo = record
    hwndOwner: HWND;
    pidlRoot: PItemIDList;
    pszDisplayName: PAnsiChar;
    lpszTitle: PAnsiChar;
    ulFlags: UINT;
    lpfn: TFNBFFCallBack;
    lParam: LPARAM;
    iImage: Integer;
  end;

function THIBrowse.GetFlag(const Flag:integer):integer;
begin
  Result := Flag + BIF_STATUSTEXT;
  if _prop_Edit = 0 then
    Result := Result + BIF_EDITBOX;
  if _prop_NewStyle = 0 then
    begin
      Result := Result + BIF_NEWDIALOGSTYLE;
      if _prop_NewDirButton = 1 then
        Result := Result + BIF_NONEWFOLDERBUTTON;
    end;
end;

function SHBrowseForFolder(var lpbi: TBrowseInfo): PItemIDList;  stdcall;  external shell32 name 'SHBrowseForFolderA';
function SHGetPathFromIDList(pidl: PItemIDList; pszPath: PChar): BOOL; stdcall; external shell32 name 'SHGetPathFromIDListA';
function SHGetSpecialFolderLocation(hwnd:HWND; csidl:integer; var ppidl:PItemIDList):cardinal; stdcall; external shell32 name 'SHGetSpecialFolderLocation';

function BrowseProc(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
begin
  case uMsg of
    BFFM_INITIALIZED: SendMessage(wnd, BFFM_SETSELECTION, 1, LongInt(PChar(lpData)));
  end;
  Result := 0;
end;

function THIBrowse.BrowseDialog(const Title: string; const Flag: integer): string;
var
  lpItemID: PItemIDList;
  BrowseInfo: TBrowseInfo;
  DisplayName: array [0..MAX_PATH] of char;
  TempPath: array [0..MAX_PATH] of char;
begin
  Result := '';
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  with BrowseInfo do
   begin
    hwndOwner := ReadHandle;
    pszDisplayName := @DisplayName;
    lpszTitle := PChar(Title);
    ulFlags := GetFlag(Flag);
    if Flag and BIF_BROWSEFORCOMPUTER > 0 then
     begin
      SHGetSpecialFolderLocation(ReadHandle,CSIDL_NETWORK, lpItemID);
      pidlRoot := lpItemID;
     end
    else if Flag and BIF_BROWSEFORPRINTER > 0 then
     begin
      SHGetSpecialFolderLocation(ReadHandle,CSIDL_PRINTERS, lpItemID);
      pidlRoot := lpItemID;
     end
    else if Flag and (($0001 or 28) or $4000) > 0 then
     begin
       lpfn := BrowseProc;
       lParam := LongInt(PChar(_prop_DefaultFolder));
     end;
   end;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then
   if Flag and (BIF_BROWSEFORCOMPUTER or BIF_BROWSEFORPRINTER) > 0 then
     Result := DisplayName
   else
    begin
     SHGetPathFromIDList(lpItemID, TempPath);
     Result := TempPath;
     GlobalFreePtr(lpItemID);
    end;
end;

procedure THIBrowse._work_doBrowse;
var s:string;
begin
   s := BrowseDialog(_prop_Title, ObjType[_prop_BrowseObj]);
   if s <> '' then
    _hi_CreateEvent(_Data,@_event_onBrowse,s)
   else _hi_CreateEvent(_Data,@_event_onCancel);
end;

procedure THIBrowse._work_doDefaultFolder;
begin
  _prop_DefaultFolder := ToString(_Data);
end;

end.
