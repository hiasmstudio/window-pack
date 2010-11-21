unit hiWebBrowser;

interface

{$ifndef F_P}
uses Kol,Share,Win,ActiveX;

{$I share.inc}
{$I def.inc}

type
  THIWebBrowser = class(THIWin)
   private
    Count:word;
    Max:word;
    LastState:string;
    
    procedure OnNavigate(Sender: TObject; const pDisp: IDispatch;
              var URL: OleVariant;
              var Flags: OleVariant;
              var TargetFrameName: OleVariant;
              var PostData: OleVariant;
              var Headers: OleVariant;
              var Cancel: WordBool);
    procedure OnNewWindow(Sender: TObject; var ppDisp: IDispatch; var Cancel: WordBool);
    procedure OnComplit(Sender: TObject; const pDisp: IDispatch; var URL: OleVariant);
    procedure OnStatus(Sender: TObject; const Text: WideString);
    procedure OnProgress(Sender: TObject; Progress: Integer; ProgressMax: Integer);
    procedure OnTitle(Sender: TObject; const Text: WideString);
    procedure OnQuit( Sender: PObj );
    procedure LoadUrl;
   protected
     procedure _OnDestroy(Sender:PObj); override;
   public
    _prop_URL:string;
    _prop_Silent:boolean;
    _event_onNavigate:THI_Event;
    _event_onStatus:THI_Event;
    _event_onProgress:THI_Event;
    _event_OnTitle:THI_Event;
    _event_OnQuit:THI_Event;
    _data_URL:THI_Event;
    _data_Navigate:THI_Event;
    _data_NewWindow:THI_Event;

    constructor Create(Parent:PControl);
    destructor Destroy; override;
    procedure Init; override;

    procedure _work_doNavigate(var _Data:TData; Index:word);
    procedure _work_doRefresh(var _Data:TData; Index:word);
    procedure _work_doBack(var _Data:TData; Index:word);
    procedure _work_doForward(var _Data:TData; Index:word);
    procedure _work_doFromText(var _Data:TData; Index:word);
    procedure _work_doSavePage(var _Data:TData; Index:word);
    procedure _work_doPrint(var _Data:TData; Index:word);
    procedure _work_doPreview(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _var_CurrentURL(var _Data:TData; Index:word);
    procedure _var_Page(var _Data:TData; Index:word);
  end;

implementation

uses KOLSHDocVw, Windows;

type
  TKOLWebBrowser = PWebBrowser;
  PKOLWebBrowser = PWebBrowser;

  TStreamAdapter = class(TInterfacedObject,IStream)
  private
    FStream: PStream;
    //FOwnership: TStreamOwnership;
  public
    constructor Create(Stream: PStream);
    destructor Destroy; override;
    function Read(pv: Pointer; cb: Longint;
      pcbRead: pLongint): HResult; virtual; stdcall;
    function Write(pv: Pointer; cb: Longint;
      pcbWritten: PLongint): HResult; virtual; stdcall;
    function Seek(dlibMove: Largeint; dwOrigin: Longint;
      out libNewPosition: Largeint): HResult; virtual; stdcall;
    function SetSize(libNewSize: Largeint): HResult; virtual; stdcall;
    function CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint;
      out cbWritten: Largeint): HResult; virtual; stdcall;
    function Commit(grfCommitFlags: Longint): HResult; virtual; stdcall;
    function Revert: HResult; virtual; stdcall;
    function LockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; virtual; stdcall;
    function UnlockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; virtual; stdcall;
    function Stat(out statstg: TStatStg;
      grfStatFlag: Longint): HResult; virtual; stdcall;
    function Clone(out stm: IStream): HResult; virtual; stdcall;
    property Stream: PStream read FStream;
  end;

{ TStreamAdapter }

constructor TStreamAdapter.Create(Stream: PStream);
begin
  inherited Create;
  FStream := Stream;
end;

destructor TStreamAdapter.Destroy;
begin
  inherited Destroy;
end;

function TStreamAdapter.Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult;
var
  NumRead: Longint;
begin
  try
    if pv = Nil then
    begin
      Result := STG_E_INVALIDPOINTER;
      Exit;
    end;
    NumRead := FStream.Read(pv^, cb);
    if pcbRead <> Nil then pcbRead^ := NumRead;
    Result := S_OK;
  except
    Result := S_FALSE;
  end;
end;

function TStreamAdapter.Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult;
var
  NumWritten: Longint;
begin
  try
    if pv = Nil then
    begin
      Result := STG_E_INVALIDPOINTER;
      Exit;
    end;
    NumWritten := FStream.Write(pv^, cb);
    if pcbWritten <> Nil then pcbWritten^ := NumWritten;
    Result := S_OK;
  except
    Result := STG_E_CANTSAVE;
  end;
end;

function TStreamAdapter.Seek(dlibMove: Largeint; dwOrigin: Longint;
  out libNewPosition: Largeint): HResult;
var
  NewPos: LargeInt;
begin
  try
    if (dwOrigin < STREAM_SEEK_SET) or (dwOrigin > STREAM_SEEK_END) then
    begin
      Result := STG_E_INVALIDFUNCTION;
      Exit;
    end;
    NewPos := FStream.Seek(dlibMove,TMoveMethod(dwOrigin));
    if @libNewPosition <> nil then libNewPosition := NewPos;
    Result := S_OK;
  except
    Result := STG_E_INVALIDPOINTER;
  end;
end;

function TStreamAdapter.SetSize(libNewSize: Largeint): HResult;
begin
  try
    FStream.Size := libNewSize;
    if libNewSize <> FStream.Size then
      Result := E_FAIL
    else
      Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TStreamAdapter.CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint;
  out cbWritten: Largeint): HResult;
const
  MaxBufSize = 1024 * 1024;  // 1mb
var
  Buffer: Pointer;
  BufSize, N, I, R: Integer;
  BytesRead, BytesWritten, W: LargeInt;
begin
  Result := S_OK;
  BytesRead := 0;
  BytesWritten := 0;
  try
    if cb > MaxBufSize then
      BufSize := MaxBufSize
    else
      BufSize := Integer(cb);
    GetMem(Buffer, BufSize);
    try
      while cb > 0 do
      begin
        if cb > MaxInt then
          I := MaxInt
        else
          I := cb;
        while I > 0 do
        begin
          if I > BufSize then N := BufSize else N := I;
          R := FStream.Read(Buffer^, N);
          if R = 0 then Exit; // The end of the stream was hit.
          Inc(BytesRead, R);
          W := 0;
          Result := stm.Write(Buffer, R, @W);
          Inc(BytesWritten, W);
          if (Result = S_OK) and (Integer(W) <> R) then Result := E_FAIL;
          if Result <> S_OK then Exit;
          Dec(I, R);
          Dec(cb, R);
        end;
      end;
    finally
      FreeMem(Buffer);
      if (@cbWritten <> nil) then cbWritten := BytesWritten;
      if (@cbRead <> nil) then cbRead := BytesRead;
    end;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TStreamAdapter.Commit(grfCommitFlags: Longint): HResult;
begin
  Result := S_OK;
end;

function TStreamAdapter.Revert: HResult;
begin
  Result := STG_E_REVERTED;
end;

function TStreamAdapter.LockRegion(libOffset: Largeint; cb: Largeint;
  dwLockType: Longint): HResult;
begin
  Result := STG_E_INVALIDFUNCTION;
end;

function TStreamAdapter.UnlockRegion(libOffset: Largeint; cb: Largeint;
  dwLockType: Longint): HResult;
begin
  Result := STG_E_INVALIDFUNCTION;
end;

function TStreamAdapter.Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult;
begin
  Result := S_OK;
  try
    if (@statstg <> nil) then
      with statstg do
      begin
        dwType := STGTY_STREAM;
        cbSize := FStream.Size;
        mTime.dwLowDateTime := 0;
        mTime.dwHighDateTime := 0;
        cTime.dwLowDateTime := 0;
        cTime.dwHighDateTime := 0;
        aTime.dwLowDateTime := 0;
        aTime.dwHighDateTime := 0;
        grfLocksSupported := LOCK_WRITE;
      end;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TStreamAdapter.Clone(out stm: IStream): HResult;
begin
  Result := E_NOTIMPL;
end;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function NewKOLWebBrowser(AOwner: PControl): PKOLWebBrowser;
begin
  New(Result,CreateParented(AOwner));
end;

constructor THIWebBrowser.Create;
begin
   inherited;
   InitAdd(LoadUrl);
end;

destructor THIWebBrowser.Destroy;
begin
//   PKOLWebBrowser(Control).OnBeforeNavigate2 := nil;
//   PKOLWebBrowser(Control).OnNavigateComplete2 := nil;
//   PKOLWebBrowser(Control).OnNewWindow2 := nil;
   inherited;
end;

procedure THIWebBrowser._OnDestroy(Sender:PObj);
begin
   inherited;
end;

procedure THIWebBrowser.OnQuit( Sender: PObj );
begin
   _hi_OnEvent(_event_OnQuit);
end;

procedure THIWebBrowser.Init;
begin
   Control := NewKOLWebBrowser(FParent);
   PKOLWebBrowser(Control).OnBeforeNavigate2 := OnNavigate;
   PKOLWebBrowser(Control).OnNavigateComplete2 := OnComplit;
   PKOLWebBrowser(Control).OnStatusTextChange := OnStatus;
   PKOLWebBrowser(Control).OnProgressChange := OnProgress;
   PKOLWebBrowser(Control).OnTitleChange := OnTitle;
   PKOLWebBrowser(Control).OnQuit := OnQuit;
   PKOLWebBrowser(Control).OnNewWindow2 := OnNewWindow;
   PKOLWebBrowser(Control).Silent := _prop_Silent; 
   inherited;
end;


procedure THIWebBrowser.LoadUrl;
begin
   if _prop_URL <> '' then
     PKOLWebBrowser(Control).Navigate(_prop_URL);
end;

procedure THIWebBrowser._work_doNavigate;
begin
   PKOLWebBrowser(Control).Navigate(ReadString(_Data,_data_URL,_prop_URL));
end;

procedure THIWebBrowser._work_doRefresh;
begin
   if PKOLWebBrowser(Control).Document <> nil then
     PKOLWebBrowser(Control).Refresh;
end;

procedure THIWebBrowser._work_doSavePage;
begin
  if PKOLWebBrowser(Control).Document <> nil then
    PKOLWebBrowser(Control).ExecWB(4, 0);
end;

procedure THIWebBrowser._work_doBack;
begin
  if Count > 1 then
   begin
    PKOLWebBrowser(Control).GoBack;
    dec(Count,2);
   end;
end;

procedure THIWebBrowser._work_doForward;
begin
  if Count < max then
    begin
      PKOLWebBrowser(Control).GoForward;
      //inc(Count);
      dec(max);
      //debug(int2str(count));
    end;
end;

procedure THIWebBrowser._var_CurrentURL;
begin
   dtString(_Data,PKOLWebBrowser(Control).LocationURL);
end;

procedure THIWebBrowser._var_Page;
var p:PStream;
    s:string;
begin
   s := '';
   if PKOLWebBrowser(Control).Document <> nil then
    begin
     p := NewMemoryStream;
     (PKOLWebBrowser(Control).Document as IPersistStreamInit).Save(TStreamAdapter.Create(p),true);
     p.Position := 0;
     SetLength(s,p.Size);
     if p.Size > 0 then
      p.Read(s[1],p.Size);
     p.Free;
    end;
   dtString(_Data,s);
end;

procedure THIWebBrowser._work_doFromText;
var p:PStream;
begin
   if PKOLWebBrowser(Control).Document = nil then
     PKOLWebBrowser(Control).Navigate('about:blank');
   p := NewMemoryStream;
   p.WriteStr(ToString(_Data));
   p.Position := 0;
   (PKOLWebBrowser(Control).Document as IPersistStreamInit).Load(TStreamAdapter.Create(p));
   p.Free;
end;

procedure THIWebBrowser.OnNavigate;
var dt:TData;
begin
   dtString(dt, string(URL));
   _ReadData(dt,_data_Navigate);
   Cancel := ToInteger(dt) = 1;
end;

procedure THIWebBrowser.OnNewWindow;
var dt:TData;
begin
   dtString(dt, LastState);
   _ReadData(dt,_data_NewWindow);
   Cancel := ToInteger(dt) = 1;
end;

procedure THIWebBrowser.OnComplit;
begin
   _hi_OnEvent(_event_onNavigate,PKOLWebBrowser(Control).LocationURL);
   inc(Count);
   if Count > max then max := Count;
end;

procedure THIWebBrowser.OnStatus;
begin
   if copy(Text, 1, 4) = 'http' then
     LastState := Text;
   _hi_OnEvent(_event_onStatus, Text);
end;

procedure THIWebBrowser.OnProgress;
begin
   _hi_OnEvent(_event_onProgress,{rogressMax shl 16 + }Progress);
end;

procedure THIWebBrowser.OnTitle;
begin
   _hi_OnEvent(_event_OnTitle,string(Text));
end;

procedure THIWebBrowser._work_doPrint;
var vaIn, vaOut: OleVariant;
begin
   if PKOLWebBrowser(Control).Document <> nil then
   PKOLWebBrowser(Control).ControlInterface.ExecWB(OLECMDID_PRINT,OLECMDEXECOPT_DONTPROMPTUSER, vaIn, vaOut);
end;

procedure THIWebBrowser._work_doPreview;
var vaIn, vaOut: OleVariant;
begin
   if PKOLWebBrowser(Control).Document <> nil then
   PKOLWebBrowser(Control).ControlInterface.ExecWB(OLECMDID_PRINTPREVIEW,OLECMDEXECOPT_PROMPTUSER, vaIn, vaOut);
end;

procedure THIWebBrowser._work_doStop;
begin
  PKOLWebBrowser(Control).Stop;
end;

{$else}

uses Kol, Share, Win;

type
  THIWebBrowser = class(THIWin)
   private
   public
    _prop_URL:string;
    _prop_Silent:boolean;
    _event_onNavigate:THI_Event;
    _event_onStatus:THI_Event;
    _event_onProgress:THI_Event;
    _event_OnTitle:THI_Event;
    _event_OnQuit:THI_Event;
    _data_URL:THI_Event;
    _data_Navigate:THI_Event;
    _data_NewWindow:THI_Event;

    procedure Init; override;
    
    procedure _work_doNavigate(var _Data:TData; Index:word);
    procedure _work_doRefresh(var _Data:TData; Index:word);
    procedure _work_doBack(var _Data:TData; Index:word);
    procedure _work_doForward(var _Data:TData; Index:word);
    procedure _work_doFromText(var _Data:TData; Index:word);
    procedure _work_doSavePage(var _Data:TData; Index:word);
    procedure _work_doPrint(var _Data:TData; Index:word);
    procedure _work_doPreview(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _var_CurrentURL(var _Data:TData; Index:word);
    procedure _var_Page(var _Data:TData; Index:word);
  end;

implementation

procedure THIWebBrowser.Init;
begin
   Control := NewPaintbox(FParent);
   inherited;
end;

procedure THIWebBrowser._work_doNavigate;begin end;
procedure THIWebBrowser._work_doRefresh;begin end;
procedure THIWebBrowser._work_doBack;begin end;
procedure THIWebBrowser._work_doForward;begin end;
procedure THIWebBrowser._work_doFromText;begin end;
procedure THIWebBrowser._work_doSavePage;begin end;
procedure THIWebBrowser._work_doPrint;begin end;
procedure THIWebBrowser._work_doPreview;begin end;
procedure THIWebBrowser._work_doStop;begin end;
procedure THIWebBrowser._var_CurrentURL;begin end;
procedure THIWebBrowser._var_Page;begin end;

initialization
  _debug('Компонент WebBrowser не работает под FPC. Установите компилятор Delphi.');

{$endif}
end.
