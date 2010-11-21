library make_cpl;

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
  params.flags := CGMP_COMPRESSED;
  Result := CG_SUCCESS;
end;

function buildMakePrj(const params:TBuildMakePrjRec):integer; cdecl;
var Res:PStrList;
    i:integer;
    P:PCGrec;
begin
   p := params.result;
   Res := NewStrList;
   Res.Add('library HiAsm;');
   Res.Add('{$ifdef F_P} {$SMARTLINK OFF} {$endif}');
   Res.Add('{$R allres.res}');
   Res.Add('uses ');
   for i := 0 to p.Units.Count-1 do
     Res.Add('   ' + p.Units.Items[i] + ',');
   Res.Add('  hiCPL,kol,Share;');
   Res.Add('');
   Res.Add('procedure Init;');
   Res.Add('begin');
   Res.Add('  ClassMain := TClass' + p.MainForm + '.Create;');
   Res.Add('end;');
   Res.Add('');
   Res.Add('function CPlApplet(hwndCPl: THandle; uMsg: DWORD;lParam1, lParam2: LongInt): LongInt; stdcall;');
   Res.Add('begin');
   Res.Add('  Result := 0;');
   Res.Add('  case uMsg of');
   Res.Add('    1: begin Init; Result := 1; end; //Init');
   Res.Add('    2: Result := 1; //Count');
   Res.Add('    8: ClassMain.' + p.MainForm + '.SetInfo(PNewCplInfo(lParam2));');
   Res.Add('    5: ClassMain.' + p.MainForm + '.Exec;');
   Res.Add('    else Result := 0;');
   Res.Add('  end;');
   Res.Add('end;');
   Res.Add('');
   Res.Add('exports CPlApplet;');
   Res.Add('');
   Res.Add('begin');
   Res.Add('end.');

   Res.SaveToFile(params.prjFilename);
   Res.free;

   Result := CG_SUCCESS;
end;

function buildCompliteProc(const params:TBuildCompliteRec):integer; cdecl;
var src:string;
begin
  src := ExtractFilePath(params.prjFilename) + ExtractFileNameWOext(params.prjFilename) + '.dll';
  MoveFile(PChar(src), PChar(params.appFilename));
  Result := CG_SUCCESS;
end;

exports
    buildGetParamsProc,
    buildMakePrj,
    buildCompliteProc;

begin
end.
 