library make_hiasm;

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
   Res.Add('{$I share.inc}');
   Res.Add('{$ifdef F_P} {$SMARTLINK OFF} {$endif}');
   Res.Add('{$R allres.res}');
   Res.Add('uses ');
   for i := 0 to p.Units.Count-1 do
     Res.Add('   ' + p.Units.Items[i] + ',');
   Res.Add('  hihiPlugs,kol,Share;');
   Res.Add('');
   Res.Add('procedure Init(Param,wproc:pointer); export;');
   Res.Add('begin');
   Res.Add('  ClassMain.' + p.MainForm + '.Param := Param;');
   Res.Add('  ClassMain.' + p.MainForm + '.doWork := TWork(wproc);');
   Res.Add('  ClassMain.' + p.MainForm + '.Init;');
   Res.Add('end;');
   Res.Add('');
   Res.Add('procedure doWork(var Data:TValue; Index:word); export;');
   Res.Add('var dt:TData;');
   Res.Add('begin');
   Res.Add('  case Data.vtype of');
   Res.Add('   data_int: dtInteger(dt,integer(Data.vdata));');
   Res.Add('   data_str: dtString(dt,string(Data.vdata^));');
   Res.Add('   else dtNull(dt);');
   Res.Add('  end;');
   Res.Add('  ClassMain.' + p.MainForm + '.onEvent(dt,Index);');
   Res.Add('end;');
   Res.Add('');
   Res.Add('procedure Dead; export;');
   Res.Add('begin');
   Res.Add('  ClassMain.Destroy;');
   Res.Add('end;');
   Res.Add('');
   Res.Add('exports');
   Res.Add(' Init,doWork,Dead;');
   Res.Add('begin');
   Res.Add('  ClassMain := TClass' + p.MainForm + '.Create;');
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
