library make_com;

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
   Res.Add('');
   Res.Add('uses ');
   for i := 0 to p.Units.Count-1 do
     Res.Add('   ' + p.Units.Items[i] + ',');
   Res.Add('  kol,Share;');
   Res.Add('');
   Res.Add('');
   Res.Add('function ReadText:string; export;');
   Res.Add('begin');
   Res.Add('  Result := ClassMain.' + p.MainForm + '._prop_Menu;');
   Res.Add('end;');
   Res.Add('');
   Res.Add('function ReadExt:string; export;');
   Res.Add('begin');
   Res.Add('  Result := ClassMain.' + p.MainForm + '._prop_FileType;');
   Res.Add('end;');
   Res.Add('');
   Res.Add('procedure CurrentDir(const Dir:string); export;');
   Res.Add('begin');
   Res.Add('  _hi_onEvent(ClassMain.' + p.MainForm + '._event_onCurrentDir,Dir);');
   Res.Add('end;');
   Res.Add('');
   Res.Add('procedure AddFile(const FileName:string); export;');
   Res.Add('begin');
   Res.Add('  _hi_onEvent(ClassMain.' + p.MainForm + '._event_onFileName,FileName);');
   Res.Add('end;');
   Res.Add('');
   Res.Add('procedure Command(cmd:integer); export;');
   Res.Add('begin');
   Res.Add('  _hi_onEvent(ClassMain.' + p.MainForm + '._event_onCommand,cmd);');
   Res.Add('end;');
   Res.Add('');
   Res.Add('function ReadGUID:TGUID; export;');
   Res.Add('begin');
   Randomize;
   Res.Add('  Result.D1 := ' + int2str(Random($FFFFFF)) + ';');
   Res.Add('  Result.D2 := ' + int2str(Random($FFFF)) + ';');
   Res.Add('  Result.D3 := ' + int2str(Random($FFFF)) + ';');
   for i := 0 to 7 do
     Res.Add(Format('  Result.D4[%d] := %d;',[i,Random($FF)]));
   Res.Add('end;');
   Res.Add('');
   Res.Add('exports');
   Res.Add('   ReadText,ReadExt,CurrentDir,AddFile,Command,ReadGUID;');
   Res.Add('');
   Res.Add('begin');
   Res.Add('  ClassMain := TClass' + p.MainForm + '.Create;');
   Res.Add('end.');

   Res.SaveToFile(params.prjFilename);
   Res.free;
   
   Result := CG_SUCCESS;
end;

function buildCompliteProc(const params:TBuildCompliteRec):integer; cdecl;
var list:PStrList;
    prj_name,com_name,src:string;
begin
   src := ExtractFilePath(params.prjFilename) + ExtractFileNameWOext(params.prjFilename) + '.dll';
   copyFile(PChar(src), PChar(params.appFilename), true);

   prj_name := ExtractFileNameWOext(params.prjFilename);
   com_name := 'ex_' + prj_name + '.dll';
   copyFile(PChar(GetStartDir + 'Elements\Delphi\Make\COM_tools.dll'),
     PChar(ExtractFilePath(params.appFilename) + com_name), true);
   list := NewStrList;
   list.Add('regsvr32 ' + com_name);
   list.SaveToFile(ExtractFilePath(params.appFilename) + 'install_' + prj_name + '.bat');
   list.clear;
   list.Add('regsvr32 ' + com_name + ' /u');
   list.SaveToFile(ExtractFilePath(params.appFilename) + 'uninstall_' + prj_name + '.bat');
   list.free;
   Result := CG_SUCCESS;
end;

exports
    buildGetParamsProc,
    buildMakePrj,
    buildCompliteProc;

begin
end.
 