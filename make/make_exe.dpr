library make_exe;

uses
  Windows,
  kol,
  CGTShare in '..\..\CGTShare.pas';

type
  TCGrec = record
    MainForm:string;
    Units,IBody:PStrList;
  end;
  PCGrec = ^TCGrec;

function buildGetParamsProc(var params:TBuildParams):integer; cdecl;
begin
  params.flags := CGMP_COMPRESSED or CGMP_RUN or CGMP_RUN_DEBUG;
  Result := CG_SUCCESS;
end;

function buildMakePrj(const params:TBuildMakePrjRec):integer; cdecl;
var Res:PStrList;
    i:integer;
    P:PCGrec;
begin
   p := params.result;
   Res := NewStrList;
   Res.Add('Program HiAsm;');
   Res.Add('{$ifdef F_P} {$APPTYPE GUI} {$endif}');
   Res.Add('{$R allres.res}');
   Res.Add('uses ');
   for i := 0 to p.Units.Count-1 do
     Res.Add('  ' + p.Units.Items[i] + ',');
   Res.Add('  kol,Share;');
   Res.Add('');
   Res.Add('begin');
   Res.Add('if ParamStr(1) = ''/ih'' then');
   Res.Add('  begin');
   Res.Add('    MessageBox(0,''Сделано в HiAsm.'',''HiAsm Info'',MB_OK);');
   Res.Add('    Halt;');
   Res.Add('  end;');

   Res.Add('  ClassMain := TClass' + p.MainForm + '.Create;');
   Res.Add('  ClassMain.' + p.MainForm + '.Start;');
   Res.Add('  Run(Applet);');  //Applet
   Res.Add('  ClassMain.Destroy;');
   Res.Add('end.');

   Res.SaveToFile(params.prjFilename);
   Res.free;
   
   Result := CG_SUCCESS;
end;

function buildCompliteProc(const params:TBuildCompliteRec):integer; cdecl;
var src:string;
begin
  src := ExtractFilePath(params.prjFilename) + ExtractFileNameWOext(params.prjFilename) + '.exe';
  MoveFile(PChar(src), PChar(params.appFilename));
  Result := CG_SUCCESS;
end;

function buildRunProc(var params:TBuildRunRec):integer; cdecl;
var AppName:string;
    si:TStartupInfo;
    p: TProcessInformation;
    res:cardinal;
begin
   AppName := ExtractFilePath(params.FileName) + ExtractFileNameWOext(params.FileName) + '.exe';

   FillChar( Si, SizeOf( Si ) , 0 );
   with Si do
    begin
      cb := SizeOf( Si);
      dwFlags := STARTF_USESHOWWINDOW;
      wShowWindow := 4;
    end;
   SetCurrentDirectory(PChar(ExtractFilePath(AppName)));
   CreateProcess(nil,PChar('"' + AppName + '"'), nil, nil,false,CREATE_DEFAULT_ERROR_MODE, nil, nil, si, p);
   res := WAIT_TIMEOUT;
   Params.data := pointer(p.hProcess);
   while (res = WAIT_TIMEOUT) do
     res := WaitForSingleObject(p.hProcess,10);
   SetCurrentDirectory(PChar( GetStartDir ));

   Result := CG_SUCCESS;
end;

function buildStopProc(var params:TBuildRunRec):integer; cdecl;
begin
   TerminateProcess(cardinal(Params.data),0);
   Result := CG_SUCCESS;
end;

exports
    buildGetParamsProc,
    buildMakePrj,
    buildCompliteProc,
    buildRunProc,
    buildStopProc;

begin
end.

