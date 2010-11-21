unit Main;

interface

uses
  kol,Windows, ActiveX, ComObj,ShlObj,ShellAPI;

type
  TMainFactory = class(TComObjectFactory)
    public
      procedure UpdateRegistry(Register: Boolean); override;
  end;

  TMainShl = class(TComObject,IShellExtInit,IContextMenu)
  protected
    function IShellExtInit.Initialize = _Init;

    function _Init(pidlFolder: PItemIDList; lpdobj: IDataObject;
      hKeyProgID: HKEY): HResult; stdcall;

    function QueryContextMenu(Menu: HMENU;
      indexMenu, idCmdFirst, idCmdLast, uFlags: UINT): HResult; stdcall;
    function InvokeCommand(var lpici: TCMInvokeCommandInfo): HResult; stdcall;
    function GetCommandString(idCmd, uType: UINT; pwReserved: PUINT;
      pszName: LPSTR; cchMax: UINT): HResult; stdcall;
  end;

implementation

uses ComServ;

type
  TReadText = function:string;
  TReadExt = function:string;
  TFile = procedure (const Dir:string);
  TCommand = procedure (cmd:integer);
  TReadGUID = function :TGUID;
var
  fn:string;
  List:PStrList;
  _rp:TReadText;
  _re:TReadExt;
  _curdir:TFile;
  _addfile:TFile;
  _cmd:TCommand;
  _rg:TReadGUID;

function ReadText:string;
begin
  if Assigned(_rp) then
   Result := _rp
  else Result := '';
end;

function ReadExt:string;
begin
  if Assigned(_re) then
   Result := _re
  else Result := '';
end;

procedure CurrentDir(const Dir:string);
begin
  if Assigned(_curdir) then
   _curdir(Dir);
end;

procedure AddFile(const Filename:string);
begin
  if Assigned(_addfile) then
   _addfile(Filename);
end;

procedure Command(cmd:integer);
begin
  if Assigned(_cmd) then
   _cmd(cmd);
end;

function ReadGUID:TGUID;
begin
   if Assigned(_rg) then
    Result := _rg
   else Result := StringToGUID('');
end;

procedure TMainFactory.UpdateRegistry;
begin
   inherited UpdateRegistry(Register);

   if Register then
      CreateRegKey(ReadExt + '\shellex\ContextMenuHandlers\' + ClassName,'',GUIDToString(ClassID))
   else
      DeleteRegKey(ReadExt + '\shellex\ContextMenuHandlers\' + ClassName);
end;

function TMainShl._Init(pidlFolder: PItemIDList; lpdobj: IDataObject;
      hKeyProgID: HKEY): HResult; stdcall;
var
  medium: TStgMedium;
  fe: TFormatEtc;
  i,Count:integer;
  szFile:array[0..MAX_PATH] of char;
begin
  with fe do
  begin
    cfFormat := CF_HDROP;
    ptd := Nil;
    dwAspect := DVASPECT_CONTENT;
    lindex := -1;
    tymed := TYMED_HGLOBAL;
  end;
  if lpdobj = Nil then
  begin
    Result := E_FAIL;
    Exit;
  end;
  Result := lpdobj.GetData(fe, medium);
  if Failed(Result) then Exit;

  Count := DragQueryFile(medium.hGlobal, $FFFFFFFF, Nil, 0);
  DragQueryFile(medium.hGlobal, 0, szFile, SizeOf(szFile));

  CurrentDir(kol.ExtractFilePath(szFile));
  for i := 0 to Count-1 do
   begin
     DragQueryFile(medium.hGlobal, i, szFile, SizeOf(szFile));
     AddFile(szFile);
   end;
  Result := NOERROR;
  ReleaseStgMedium(medium);
end;

function WideStringAsPChar(S: String): PChar;
var
  I: Integer;
  WideStr: array[0..511] of Char;
begin
  FillChar(WideStr, SizeOf(WideStr), 0);
  for I := 0 to Length(S) -1 do
  begin
    if I = 254 then
      Break;
    WideStr[I*2] := S[I];
  end;
  Result := WideStr;
end;

function StrLCopy(Dest: PChar; const Source: PChar; MaxLen: Cardinal): PChar; assembler;
asm
        PUSH    EDI
        PUSH    ESI
        PUSH    EBX
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EBX,ECX
        XOR     AL,AL
        TEST    ECX,ECX
        JZ      @@1
        REPNE   SCASB
        JNE     @@1
        INC     ECX
@@1:    SUB     EBX,ECX
        MOV     EDI,ESI
        MOV     ESI,EDX
        MOV     EDX,EDI
        MOV     ECX,EBX
        SHR     ECX,2
        REP     MOVSD
        MOV     ECX,EBX
        AND     ECX,3
        REP     MOVSB
        STOSB
        MOV     EAX,EDX
        POP     EBX
        POP     ESI
        POP     EDI
end;

function TMainShl.GetCommandString;
begin
  Result := S_OK;
  case uType of
    GCS_VERBA:
      StrLCopy(pszName, PChar('COM.FName'), cchMax);
    GCS_VERBW:
      StrLCopy(pszName, WideStringAsPChar('COM.FName'), cchMax);
    GCS_HELPTEXTA:
      StrLCopy(pszName, PChar('COM.FInfo'), cchMax);
    GCS_HELPTEXTW:
      StrLCopy(pszName, WideStringAsPChar('COM.FInfo'), cchMax);
  end;
end;

function TMainShl.InvokeCommand;
begin
  if HIWORD( Integer(lpici.lpVerb) ) <> 0 then
    Result := E_FAIL
  else
   begin
     Command(LOWORD( lpici.lpVerb ));
     Result := S_OK;
   end;
end;

function TMainShl.QueryContextMenu;
var i:integer;
begin
  for i := List.Count-1 downto 0 do
    InsertMenu(Menu,indexMenu,MF_BYPOSITION,idCmdFirst+i,PChar(List.Items[i]));
  Result := List.Count;
end;

var id:Cardinal;
    s:string;

initialization
  SetLength(fn,1024);
  SetLength(fn,GetModuleFileName(HInstance,PChar(@fn[1]),1024));

  s := ExtractFileName(fn);
  delete(s,1,3);
  fn := ExtractFilePath(fn) + s;
  List := NewStrList;

  if FileExists(fn) then
   begin
    id := LoadLibrary(PChar(fn));
    _rp := TReadText(GetProcAddress(id,'ReadText'));
    _re := TReadExt(GetProcAddress(id,'ReadExt'));
    _curdir := TFile(GetProcAddress(id,'CurrentDir'));
    _addfile := TFile(GetProcAddress(id,'AddFile'));
    _cmd := TCommand(GetProcAddress(id,'Command'));
    _rg := TReadGUID(GetProcAddress(id,'ReadGUID'));
   end
  else MessageBox(0,PChar('File ' + fn + ' not found!'),'Error',MB_OK or MB_ICONERROR);

  List.Text := ReadText;

  s := ExtractFileNameWOext(s);

  TMainFactory.Create(ComServer, TMainShl, ReadGUID,
    s + '.FName', s + '.FInfo', ciMultiInstance, tmApartment);

finalization
   FreeLibrary(id);

end.
