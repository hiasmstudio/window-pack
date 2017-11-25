library make_dll;

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
    Header:PStrList;
    i:integer;
    P:PCGrec;
begin
   p := params.result;
   Res := NewStrList;

   Res.Add('library HiAsm;');
   Res.Add('{$I share.inc}');
   Res.Add('{$ifdef F_P} {$SMARTLINK OFF} {$endif}');
   Res.Add('{$R allres.res}');
   Res.Add('uses hiCallDLL,');
   for i := 0 to p.Units.Count-1 do
     Res.Add('   ' + p.Units.Items[i] + ',');
   Res.Add('  hiDLL,kol,Share;');
   Res.Add('');

   Res.Add('type');
   Res.Add('  TGlobalRec = record');
   Res.Add('    Param:pointer; //указатель на класс(CallDLL,UseDLL)');
   Res.Add('    onEvent:pointer; //TdllInitProc для CallDLL, T_hi_dllProc - для UseDLL');
   Res.Add('    GetData:pointer;');
   Res.Add('    ClassMain:TClass' + p.MainForm + ';');
   Res.Add('  end;');
   Res.Add('  PGlobalRec = ^TGlobalRec;');
   Res.Add('');
   Res.Add('var CallDLL_Var:TGlobalRec;');
   Res.Add('');

   Res.Add('procedure doWork (var _Data:TValue; Index:word); cdecl;');
   Res.Add('var Dt:TData;');
   Res.Add('begin');
   Res.Add('  Dt := ValueToData(_Data);');
   Res.Add('  CallDLL_Var.ClassMain.' + p.MainForm + '.doWork(dt,Index);');
   Res.Add('end;');
   Res.Add('');
   Res.Add('procedure GetVar (var _Data:TValue; Index:word); cdecl;');
   Res.Add('var Dt:TData;');
   Res.Add('begin');
   Res.Add('  Dt := ValueToData(_Data);');
   Res.Add('  CallDLL_Var.ClassMain.' + p.MainForm + '.GetVar(dt,Index);');
   Res.Add('  _Data := DataToValue(dt);');
   Res.Add('end;');
   Res.Add('');
   Res.Add('procedure gate_OnEvent(var _Data:TData; Index:word; GlobalRec:pointer);');
   Res.Add('var val:TValue;');
   Res.Add('begin');
   Res.Add('   val := DataToValue(_Data);');
   Res.Add('   TdllInitProc(CallDLL_Var.onEvent)(val,Index,CallDLL_Var.Param);');
   Res.Add('end;');
   Res.Add('');
   Res.Add('procedure gate_GetData(var _Data:TData; Index:word; GlobalRec:pointer);');
   Res.Add('var val:TValue;');
   Res.Add('begin');
   Res.Add('   val := DataToValue(_Data);');
   Res.Add('   TdllInitProc(CallDLL_Var.GetData)(val,Index,CallDLL_Var.Param);');
   Res.Add('   _Data := ValueToData(val);');
   Res.Add('end;');
   Res.Add('');

   Res.Add('procedure DllInit(_onEvent,_Data:pointer; _Param:pointer); cdecl;');
   Res.Add('begin');
   Res.Add('  CallDLL_Var.ClassMain := TClass' + p.MainForm + '.Create;');
   Res.Add('  CallDLL_Var.Param := _Param;');
   Res.Add('  CallDLL_Var.onEvent := _onEvent;');
   Res.Add('  CallDLL_Var.GetData := _Data;');
   Res.Add('  CallDLL_Var.ClassMain.' + p.MainForm + '.onEvent := gate_OnEvent;');
   Res.Add('  CallDLL_Var.ClassMain.' + p.MainForm + '.GetData := gate_GetData;');
   Res.Add('end;');
   Res.Add('');

   Res.Add('procedure _hi_doWork (var _Data:TData; Index:word; GlobalRec:PGlobalRec);');
   Res.Add('begin');
   Res.Add('  GlobalRec.ClassMain.' + p.MainForm + '.doWork(_Data,Index);');
   Res.Add('end;');
   Res.Add('');
   Res.Add('procedure _hi_GetVar (var _Data:TData; Index:word; GlobalRec:PGlobalRec);');
   Res.Add('begin');
   Res.Add('  GlobalRec.ClassMain.' + p.MainForm + '.GetVar(_Data,Index);');
   Res.Add('end;');
   Res.Add('');
   Res.Add('procedure _hi_gate_OnEvent(var _Data:TData; Index:word; GlobalRec:pointer);');
   Res.Add('begin');
   Res.Add(' with PGlobalRec(GlobalRec)^ do');
   Res.Add('   T_hi_dllProc(onEvent)(_Data,Index,Param);');
   Res.Add('end;');
   Res.Add('');
   Res.Add('procedure _hi_gate_GetData(var _Data:TData; Index:word; GlobalRec:pointer);');
   Res.Add('begin');
   Res.Add(' with PGlobalRec(GlobalRec)^ do');
   Res.Add('   T_hi_dllProc(GetData)(_data,Index,Param);');
   Res.Add('end;');
   Res.Add('');
   Res.Add('procedure _hi_PointsInfo(var _prop_WorkPoints,_prop_EventPoints,_prop_VarPoints,_prop_DataPoints:PChar); export; stdcall;');
   Res.Add('begin');

   Header := p.IBody;
    for i := 0 to Header.Count-1 do
     if pos('_prop_WorkPoints',Header.Items[i]) > 0 then
       Res.Add(Header.Items[i]);
    for i := 0 to Header.Count-1 do
     if pos('_prop_EventPoints',Header.Items[i]) > 0 then
       Res.Add(Header.Items[i]);
    for i := 0 to Header.Count-1 do
     if pos('_prop_VarPoints',Header.Items[i]) > 0 then
       Res.Add(Header.Items[i]);
    for i := 0 to Header.Count-1 do
     if pos('_prop_DataPoints',Header.Items[i]) > 0 then
       Res.Add(Header.Items[i]);

   Res.Add('end;');
   Res.Add('');
   Res.Add('procedure _hi_Icon(var _prop_Icon:cardinal); export; stdcall;');
   Res.Add('begin');
    for i := 0 to Header.Count-1 do
     if pos('_prop_Icon ',Header.Items[i]) > 0 then
      if not (pos('_prop_Icon := 0;',Header.Items[i]) > 0) then
       Res.Add(Header.Items[i]);

   //Header.Free;

   Res.Add('end;');
   Res.Add('');
   Res.Add('procedure _hi_DllInit(_onEvent,GetData:pointer; _Param:pointer; var GlobalRec:PGlobalRec); export;');
   Res.Add('begin');
   Res.Add('  new(GlobalRec);');
   //Res.Add('  DllMain(GlobalRec);');
   Res.Add('  GlobalRec.ClassMain := TClass' + p.MainForm + '.Create;');
   Res.Add('  GlobalRec.Param := _Param;');
   Res.Add('  GlobalRec.onEvent := _onEvent;');
   Res.Add('  GlobalRec.GetData := GetData;');
   Res.Add('  GlobalRec.ClassMain.' + p.MainForm + '.DLL_Param := GlobalRec;');
   Res.Add('  GlobalRec.ClassMain.' + p.MainForm + '.onEvent := _hi_gate_OnEvent;');
   Res.Add('  GlobalRec.ClassMain.' + p.MainForm + '.GetData := _hi_gate_GetData;');
   Res.Add('end;');
   Res.Add('');

   Res.Add('exports');
   Res.Add('   doWork,');
   Res.Add('   GetVar,');
   Res.Add('   _hi_PointsInfo,');
   Res.Add('   _hi_Icon,');
   Res.Add('   _hi_DllInit,');
   Res.Add('   _hi_doWork,');
   Res.Add('   _hi_GetVar,');
   Res.Add('   DllInit;');

   //Res.Add(Dead);
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
