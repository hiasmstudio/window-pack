library CodeGen;

{define _debug_}

uses
  Windows,kol,
  CGTShare in '..\CGTShare.pas';

type
  TCGrec = object
    MainForm:string;
    Vars,Units,IBody,Dead,RUnit:PStrList;
    PrInt,PrImp:PStrList;
    procedure Clear;
   end;
  PCGrec = ^TCGrec;

  TCGrecOut = object
    MainForm:string;
    Units,IBody:PStrList;
  end;
  PCGrecOut = ^TCGrecOut;

var
    dbg:integer;
    Cgt:PCodeGenTools=nil;
    UnitList:PStrList=nil;

const DataTypes:array[0..21]of string =
   (
     '0',
     'Integer',
     'String',
     'TData',
     'byte', //Combo
     'PStrList', //data_list
     'PIcon',
     'Real',
     'TColor',
     'string', //data_script = 9;
     'PStream',
     'PBitmap',
     'PStream',
     'nil', //data_array = 13;
     'byte', //combo Ex
     'PFont', // font
     '', // matrix
     'PStream', //jpeg
     'string', //menu
     'string',
     '',       //element
     ''        //flag
   );

//My function......

//const _ru:array[]

function ConvertToTranslite(const value:string):string;
var i:integer;
begin
  Result := value;
  for i := 1 to length(value) do
     ;
end;

procedure TCGrec.Clear;
begin
  Vars.Free;
  Units.Free;
  IBody.Free;
  Dead.Free;
  RUnit.Free;
  PrInt.Free;
  PrImp.Free;
  MainForm := '';
end;

function GetPROP(name:string; e:cardinal):id_prop;
var j:integer;
begin
  for j := 0 to cgt.elGetPropCount(e)-1 do begin
    Result := cgt.elGetProperty(e,j);
    if LowerCase(cgt.propGetName(Result))=LowerCase(name) then exit;
  end;
  Result := 0;
end;

function GetCLASS(e:cardinal):string;
begin
  Result := cgt.elGetClassName(e);
  case cgt.elGetClassIndex(e) of
    CI_InlineCode: begin
     if cgt.elLinkIs(e) then e := cgt.elLinkMain(e);
     Result := Result + '_' + Int2Hex(e,6);
    end;
  end;
end;
//.................

procedure AddUnit(Units:PStrList; const UnitName:string);
begin
  if Units.IndexOf(UnitName) < 0 then Units.Add(UnitName);
end;

function StringToCode(const s:string):string;
var i:integer; intostr:bool;
begin
  if Length(s) > 254 then begin
    Result := 'PChar(LoadResData(''' + cgt.resAddStr(PChar(s)) + '''))';
    exit;
  end;
  Result := 'PChar(';
  intostr := false;
  for i := 1 to Length(s) do
    if ord(s[i])<32 then begin
      if intostr then Result := Result + '''';
      Result := Result + '#' + Int2Str(ord(s[i]));
      intostr := false;
    end else begin
      if not intostr then Result := Result + '''';
      if s[i]='''' then Result := Result + '''';
      Result := Result + s[i];
      intostr := true;
    end;
  if intostr then Result := Result + '''';
  Result := Result + '#0)';
end;

function ReplaceSChar(const s:string):string;
var i,j,k,w:integer;
    t:string;
begin
  t := '';
  i := 1;
  while i<=Length(s) do
   begin
    if (s[i] = '\')and(i < Length(s)) then
     begin
      inc(i);
      case s[i] of
       '\': t := t + '\';
       'n': t := t + #10;
       'r': t := t + #13;
       't': t := t + #9;
       '0'..'9':
        begin
         w := 0;
         for j := 1 to 3 do
          begin //ограничение на текстовую длину числа
           k := w*10 + ord(s[i]) - ord('0');
           if k > 255 then break; //ограничение на величину числа
           w := k; inc(i);
           if i > Length(s) then break; //правая граница входной строки
           if not(s[i] in ['0'..'9']) then break; //значит число кончилось
          end;
         dec(i); t := t + char(w);
        end
       else t := t + '\' + s[i];
      end;
     end
    else t := t + s[i];
    inc(i);
   end;
  Result := StringToCode(t);
end;

function Int_Str(i:integer):string;
begin
  if i = integer($80000000) then
    Result := '$80000000'
  else Result := int2str(i);
end;

function DoData(dt:id_data):string;
begin
  case cgt.dtType(dt) of
    data_null: Result := '';
    data_int:  Result := '_DoData(' + Int_Str(cgt.dtInt(dt)) + ')';
    data_str:  Result := '_DoData(' + ReplaceSChar(cgt.dtStr(dt)) + ')';
    data_real: begin
      Result := '_DoData(' + Double2Str(cgt.dtReal(dt));
      if Pos('.',Result) = 0 then Result := Result + '.0';
      Result := Result + ')'
    end;
  end;
end;

function FontToStr(f:id_font):string;
begin
  with cgt^ do
    Result := Format('hiCreateFont(''%s'',%d,%d,%d,%d)',[fntName(f),fntSize(f),fntStyle(f),fntColor(f),fntCharSet(f)]);
end;

function SaveParam(e:cardinal; const pr:id_prop):string; forward;

function PlacecAtRes(_Arr:cardinal):string;
var i:integer;
    s:string;
begin
  s := '';
  if cgt.arrCount(_arr) > 0 then s := cgt.arrItemName(_arr,0);
  for i := 1 to cgt.arrCount(_arr)-1 do
    s := s + #13#10 + cgt.arrItemName(_arr,i);
  Result := StringToCode(s);
end;

function ArrayToRes(e:cardinal; _Arr:id_array):string;
var
   i,cnt:integer;
   p:string;
begin
  Result := '';
  cnt := cgt.arrCount(_arr);
  if cnt = 0 then Exit;
  Result := 'MakeArray' + DataNames[cgt.arrType(_Arr)] +'(' + PlacecAtRes(_Arr) + ',[';
  for i := 0 to cnt-1 do begin
    p := SaveParam(e,cgt.arrGetItem(_Arr,i));
    if p = '' then p := '0';
    if i mod 8 = 0 then
      Result := Result + #13#10#9#9;
    Result := Result + p;
    if i < cnt-1 then
      Result := Result + ',';
  end;
  Result := Result + '])';
end;

function SaveParam(e:cardinal; const pr:id_prop):string;
var k:string;
    rs:PChar;
begin
  k := '';
  case cgt.propGetType(pr) of
    data_int,data_color,data_flags:
      k := Int_Str(cgt.propToInteger(pr));
    data_str,data_list:
      k := ReplaceSChar(cgt.propToString(pr));
    data_script,data_code:
      k := StringToCode(cgt.propToString(pr));
    data_data:
      if cgt.dtType(id_data(cgt.propGetValue(pr))) <> data_null then
        k := DoData(id_data(cgt.propGetValue(pr)));
    data_combo:
      k := Int2Str(cgt.propToByte(pr));
    data_icon:
      k := 'LoadIcon(hInstance,''' + cgt.resAddIcon(pr) + ''')';
    data_stream,data_jpeg: begin
      rs := cgt.resAddStream(pr);
      if Assigned(rs) then
        k := 'LoadResStream(''' + rs + ''')'
      else
        k := 'nil';
    end;
    data_bitmap:  begin
      rs := cgt.resAddBitmap(pr);
      if Assigned(rs) then
        k := 'LoadBitmap(HInstance,''' + rs + ''')';
    end;
    data_real: begin
      k := Double2Str(cgt.propToReal(pr));
      if Pos('.',k) = 0 then k := k + '.0';
    end;
    data_wave: begin
      rs := cgt.resAddWave(pr);
      if Assigned(rs) then
        k := '''' + rs + '''';
    end;
    data_array:
      k := ArrayToRes(e,id_array(cgt.propGetValue(pr)));
    data_comboEx:
      k := cgt.propToString(pr);
    data_font:
      k := FontToStr(id_font(cgt.propGetValue(pr)));
{    temporary
    data_element:
      begin
       _e := cgt.propGetLinkedElementInfo(e, pr, buf);
       if _e = 0 then
         k := 'nil'
       else k := cgt.elGetCodeName(_e) + '.getInterface' + string(buf);
     end;
}
  end;
  Result := k;
end;

function getParentName(sdk:id_sdk):string;
var i:integer;
begin
   for i := 0 to cgt.sdkGetCount(sdk)-1 do
     if cgt.elGetFlag(cgt.sdkGetElement(sdk, i)) and IS_PARENT > 0 then
      begin
         Result := cgt.elGetCodeName(cgt.sdkGetElement(sdk, i));
         exit;
      end;
   Result := '';
end;

function getSDKName(sdk:id_sdk):string;
var e:id_element;
    i:integer;
begin
   Result := '';
   e := cgt.sdkGetParent(sdk);
   if cgt.elGetClassIndex(e) = CI_PolyMulti then
     begin
       for i := 0 to cgt.elGetSDKCount(e)-1 do
         if cgt.elGetSDKByIndex(e, i) = sdk then
           begin
             Result := cgt.elGetSDKName(e, i) + '_' + Int2Hex(e,6);
             exit;
           end;
     end
   else
     Result := cgt.elGetCodeName(e); 
end;

function getParentPath(cur_e, target_e:id_element; Res:PCGrec):string;
var sdk:id_sdk;
    i:integer;
    s:string;
begin
   sdk := cgt.elGetParent(cur_e);
   Result := '';
   repeat
     for i := 0 to cgt.sdkGetCount(sdk)-1 do
       if cgt.sdkGetElement(sdk, i) = target_e then
         exit;
     sdk := cgt.elGetParent(cgt.sdkGetParent(sdk));
     if cgt.sdkGetParent(sdk) = 0 then
        s := getParentName(sdk)
     else s := getSDKName(sdk);
     if Res.RUnit.IndexOf('hi' + s) = -1 then
       Res.RUnit.Add('hi' + s);
     Result := 'TClass' + s + '(' + Result + 'ParentClass).';
   until false;
end;

procedure initDataElementprops(res:PCGrec; e:id_element);
var i:integer;
    pr:id_prop;
    _e:id_element;
    buf:array[0..128]of char;
    k:string;
begin
    for i := 0 to cgt.elGetPropCount(e)-1 do
     begin
       pr := cgt.elGetProperty(e, i);
       if cgt.propGetType(pr) <> data_element then continue;

       _e := cgt.propGetLinkedElementInfo(e, pr, buf);
       if _e = 0 then
         k := 'nil'
       else k := getParentPath(e, _e, res) + cgt.elGetCodeName(_e) + '.getInterface' + string(buf);
       Res.IBody.Add('  ' + cgt.elGetCodeName(e) + '._prop_' + cgt.propGetName(pr) + ' := ' + k + ';');
     end;
end;

function GetPointCount(e:cardinal; ptype:byte):integer;
var i:smallint;
begin
   Result := 0;
   for i := 0 to cgt.elGetPtCount(e)-1 do
    if cgt.ptGetType(cgt.elGetPt(e,i)) = PType then
      inc(Result);
end;

function getParentUnits(e:id_element):string;
var sdk:id_sdk;
begin
   sdk := cgt.elGetParent(e);
   while cgt.sdkGetParent(sdk) > 0 do
    begin
      sdk := cgt.elGetParent(cgt.sdkGetParent(sdk));
    end;

   Result := 'hi' + getParentName(sdk);
end;

procedure MakeMulti(e:id_element; const CodeName,EMN,EMCN:string;pr:PCGrec; inherit:string = ''; ListAdd:boolean = false; sdk:id_sdk = 0);
var i:integer;
    Res:PStrList;
    UnitName,s,p:string;
begin
  Res := NewStrList;
  Res.Add('unit hi' + CodeName + ';');
  Res.Add('');
  Res.Add('interface');
  Res.Add('');
  Res.Add('uses ');
  for i := 0 to pr.Units.Count-1 do
    Res.Add('  ' + pr.Units.Items[i] + ',');
  if inherit <> '' then
   Res.Add('  hi' + inherit + ',');
  Res.Add('  kol,Share;');
  Res.Add('');
  Res.Add('type');
  if inherit = '' then
    Res.Add('TClass' + CodeName + ' = class')
  else Res.Add('TClass' + CodeName + ' = class(TClass' + inherit + ')');
  if pr.PrInt.Count > 0 then
    begin
      Res.Add(' protected');
      Res.AddStrings(pr.PrInt);
    end;
  Res.Add(' public');
  Res.AddStrings(pr.Vars);
  Res.Add('');
  if inherit = '' then
  Res.Add('  Child:THI' + EMN + ';');
  Res.Add('  ParentClass:TObject;');
  Res.Add('');
  Res.Add('  constructor Create(_parent:pointer; _Control:PControl; _ParentClass:TObject);');
  Res.Add('  destructor Destroy; override;');
//  Res.Add('  procedure Init;');
  Res.Add(' end;');
  Res.Add('');
  Res.Add('  function Create_hi' + CodeName + '(_parent:pointer; Control:PControl; _ParentClass:TObject):THi' + EMN + ';');
  Res.Add('');
  Res.Add('implementation');
  Res.Add('');
  if pr.RUnit.Count > 0 then
   begin
     Res.Add('uses ' + pr.RUnit.Items[0]);
     for i := 1 to pr.RUnit.Count-1 do
       Res.Add(',' + pr.RUnit.Items[i]);
     Res.Add(';');  
   end;
  if pr.PrImp.Count > 0 then
    begin
      Res.Add('');
      Res.AddStrings(pr.PrImp);
    end;
  Res.Add('');
  Res.Add('function Create_hi' + CodeName + ';');
  Res.Add('begin');
  Res.Add('  Result := THi' + EMN + '(TClass' + CodeName + '.Create(_parent, Control, _ParentClass).Child);');
  Res.Add('end;');
  Res.Add('');
  Res.Add('constructor TClass' + CodeName + '.Create;');
  Res.Add('begin');
  if inherit = '' then
    Res.Add('  inherited Create;')
  else Res.Add('  inherited;');
  Res.Add('  ParentClass := _ParentClass;');
  Res.AddStrings(pr.IBody);
  Res.Add('');
//  Res.Add('  Child := ' + EMCN + ';');
//  Res.Add('  ' + EMCN + '.MainClass := Self;');
  //Res.IBody.Add(' //%multi%');
  s := Res.text;
  if not ListAdd then
    begin
      p := ' Child := ' + EMCN + ';'#13#10'  ' + EMCN + '.MainClass := Self;'#13#10'  ' + EMCN + '.Parent := _parent;';
      if inherit = 'PolyBase' then
        p := p + #13#10'  Base := Child;';
      replace(s, '//%multi%', p);
    end;
  Res.text := s;

  {if sdk = 0 then
    s := ''
  else }s := getParentName(sdk);
  if s <> '' then
    Res.Add('  ParentElement := ' + s + ';');

  if ListAdd then
   begin
     for i := 0 to cgt.sdkGetCount(sdk)-1 do
       Res.Add('  List.Add(' + cgt.elGetCodeName(cgt.sdkGetElement(sdk, i)) + ');');
   end;
  Res.Add('end;');
  Res.Add('');
//  Res.Add('procedure TClass' + CodeName + '.Init;');
//  Res.Add('begin');
//  Res.AddStrings(pr.RInit);
//  Res.Add('end;');
//  Res.Add('');
  Res.Add('destructor TClass' + CodeName + '.Destroy;');
  Res.Add('begin');
  Res.AddStrings(pr.Dead);
  Res.Add('  inherited;');
  Res.Add('end;');
  Res.Add('');
  Res.Add('');
  Res.Add('end.');

  UnitName := cgt.ReadCodeDir(e) + 'hi' + CodeName + '.pas';
  Res.SaveToFile(UnitName);
  cgt.resAddFile(PChar(UnitName));
  Res.free;
end;

type TbuildProcessProc = function (var params:TBuildProcessRec):integer; cdecl;
     TbuildPrepareProc = function (const params:TBuildPrepareRec):integer; cdecl;

procedure MakeFTCG(const cn:string; e:id_element; cgt:PCodeGenTools);
var sdk:id_sdk;
    id:cardinal;
    buildPrepareProc:TbuildPrepareProc;
    buildProcessProc:TbuildProcessProc;
    prep:TBuildPrepareRec;
    proc:TbuildProcessRec;
    UnitName:string;
    Res:PStrList;
begin
  sdk := cgt.elGetSDK(e);
  id := LoadLibrary(PChar(GetStartDir + 'Elements\Delphi\FTCG_CodeGen.dll'));
  if id = 0 then exit;

  buildPrepareProc := TbuildPrepareProc(GetProcAddress(id, 'buildPrepareProc'));
  buildProcessProc := TbuildProcessProc(GetProcAddress(id, 'buildProcessProc'));

  buildPrepareProc(prep);

  proc.cgt := cgt;
  proc.sdk := sdk;
  proc.result := nil;
  buildProcessProc(proc);

  UnitName := cgt.ReadCodeDir(e) + 'hi' + cn + '.pas';
  Res := NewStrList;
  Res.Text := PChar(proc.result);
  Res.SaveToFile(UnitName);
  cgt.resAddFile(PChar(UnitName));
  Res.free;

  FreeLibrary(id);
end;

const Names:  array[1..4] of PChar = ('_work_','_event_','_var_','_data_');
      MNames: array[1..4] of PChar = ('doWork','Events','getVar','Datas');
      EMNames:array[1..4] of PChar = ('OnEvent','Works','_Data','Vars');
      Uhi:    array[1..4] of PChar = ('_work_Work','_event_Event','_var_Var','_data_Data');

function codePoint(p:cardinal):string;
var e:cardinal;
    s:string;
begin
  e := cgt.ptGetParent(p);
  Result := 'nil'; if cgt.elGetFlag(e) and IS_HIDE <> 0 then exit;
  s := cgt.ptGetName(p);
  Result := cgt.elGetCodeName(e) + '.' + Names[cgt.ptGetType(p)] + s;
  case cgt.elGetClassIndex(e) of
   0:;
   CI_DPElement: begin
     if Length(cgt.pt_dpeGetName(p)) = 0 then
     else if cgt.ptGetType(p) in [pt_Event,pt_Data] then
       Result := cgt.elGetCodeName(e) + '.' + cgt.pt_dpeGetName(p) + '[' + int2str(cgt.ptGetIndex(p)) + ']'
     else Result := cgt.elGetCodeName(e) + '.' + cgt.pt_dpeGetName(p);
   end;
   CI_DPLElement:
     if Length(cgt.pt_dpeGetName(p)) = 0 then
       Result :=  cgt.elGetCodeName(e) + '.' + s
     else
      if cgt.ptGetType(p) in [pt_Event,pt_Data] then
        Result := cgt.elGetCodeName(e) + '.' + Names[cgt.ptGetType(p)] + cgt.pt_dpeGetName(p) + '[' + Int2Str(cgt.ptGetIndex(p)) + ']'
     else  Result := cgt.elGetCodeName(e) + '.' + Names[cgt.ptGetType(p)] + cgt.pt_dpeGetName(p);

   CI_MultiElement,CI_UserElement,CI_PolyMulti:
     if copy(s,1,2) = '##' then
       Result := cgt.elGetCodeName(e) + '.' + PChar(@s[3])
     else
      if cgt.ptGetType(p) in [pt_Event,pt_Data] then
        Result := cgt.elGetCodeName(e) + '.' + MNames[cgt.ptGetType(p)] + '[' + int2str(cgt.ptGetIndex(p)) + ']'
      else Result := cgt.elGetCodeName(e) + '.' + MNames[cgt.ptGetType(p)];
   CI_EditMulti,CI_EditMultiEx:
     if cgt.ptGetType(p) in [pt_Event,pt_Data] then
       Result := cgt.elGetCodeName(e) + '.' + EMNames[cgt.ptGetType(p)] + '[' + int2str(cgt.ptGetIndex(p)) + ']'
     else Result := cgt.elGetCodeName(e) + '.' + EMNames[cgt.ptGetType(p)];
   CI_InlineCode:
     Result := cgt.elGetCodeName(e) + '.' + s;
   CI_DrawElement:;
   CI_PointHint:
     Result := 'nil';
   CI_UseHiDLL:
     if cgt.ptGetType(p) in [pt_Event,pt_Data] then
       Result := cgt.elGetCodeName(e) + '.' + Uhi[cgt.ptGetType(p)] + '[' + int2str(cgt.ptGetIndex(p)) + ']'
     else Result := cgt.elGetCodeName(e) + '.' + Uhi[cgt.ptGetType(p)];
  end;
end;

function DebugID(p:id_point):string;
begin
  if dbg = 0 then
    Result := ''
  else Result := ',' + int2str(p);
end;

function GenCodeName(e:cardinal):string;
begin
  if Length(cgt.elGetCodeName(e)) <> 0 then
    Result := cgt.elGetCodeName(e)
  else begin
    Result := cgt.elGetClassName(e) + '_' + Int2Hex(e,6);
    cgt.elSetCodeName(e,PChar(Result));
  end;
end;

procedure CreateCode_(SDK:cardinal; Res:PCGrec; parent:string); forward;

procedure SetPropertys(pcr:PCGrec; e:cardinal; base:id_element = 0);
var i,x,y,w,h:integer;
    p,sdk,me:cardinal;
    pr:TCGrec;
    cn,cd:string;
    List:Pstrlist;
    wb:boolean;
  procedure SetProps(Head:boolean=true);
  var i,j,c:integer;
      mf:cardinal;
  begin
    j := pcr.IBody.Count;
    if cgt.elGetClassIndex(e) = CI_WinElement then
      begin
        mf := 0;
        c := 0;
        for i := 0 to cgt.elGetPropCount(e)-1 do
         begin
          p := cgt.elGetProperty(e, i);
          if cgt.propGetType(p) = data_element then
           begin
             if not cgt.elIsDefProp(e, i) then
               mf := mf or (1 shl c);
             inc(c);
           end;
         end;
        pcr.IBody.Add('    ManFlags := ' + int2str(mf) + ';');
      end;

    for i := 0 to cgt.elGetPropCount(e)-1 do
         begin
           if(base > 0)and cgt.elIsDefProp(e,i) then
             p := cgt.elGetProperty(base,i) 
           else
             p := cgt.elGetProperty(e,i);        
           cd := SaveParam(e,p);
           if (cd = '') or (cd = 'nil') then continue;
           if (cgt.propGetType(p) = data_str)and(cgt.propIsTranslate(e, p) = 1) then
             cd := 'Translator.tr(' + cd + ')';
           pcr.IBody.Add('    _prop_' + cgt.propGetName(p) + ' := ' + cd + ';');
         end;
   if ((cgt.elGetFlag(e)and IS_EDIT) <> 0) then
      pcr.IBody.Add('    Init;' );
   if (pcr.IBody.Count>j)or Head then
     begin
       pcr.IBody.Insert(j,'  with ' + cgt.elGetCodeName(e) + ' do begin');
       wb := true;
     end;
  end;
begin
  wb := false;
  cn := GetClass(e);
  case cgt.elGetClassIndex(e) of
   CI_EditMulti,CI_EditMultiEx :begin
     wb := true;
     pcr.IBody.Add('  with ' + cgt.elGetCodeName(e) + ' do begin');
     pcr.IBody.Add('    SetLength(Works,'+int2str(GetPointCount(e,pt_event))+');');
     pcr.IBody.Add('    SetLength(Vars, '+int2str(GetPointCount(e,pt_data)) +');');
   end;
   CI_InlineCode: begin
     if UnitList.indexOf(cn)<0 then begin
       UnitList.Add(cn);
       cn := 'hi' + cn;
       cd := cgt.propToString(GetProp('Code',e));
       Replace(cd,'HiAsmUnit',cn);
       Replace(cd,'THiAsmClass','T' + cn);
       List := NewStrList;
       List.Text := cd;
       cd := cgt.ReadCodeDir(e) + cn + '.pas';
       List.SaveToFile(cd);
       cgt.resAddFile(PChar(cd));
       List.Free;
     end;
   end;
   CI_MultiElement, CI_UserElement:
    if cgt.elGetClassName(e) = 'FTCG_Tools' then
     begin
       me := e;
       if cgt.elLinkIs(e) then me := cgt.elLinkMain(e);
       cn := cgt.elGetClassName(me) + '_' + Int2Hex(me,6);
       if UnitList.indexOf(cn)<0 then begin
         UnitList.Add(cn);
         MakeFTCG(cn, e, cgt);
       end;
       if pcr.MainForm <> cn then AddUnit(pcr.RUnit,'hi' + cn);
       SetProps;
       //pcr.IBody.Add('    OnCreate := Create_hi' + cn + ';');
       pcr.IBody.Add('    ParentClass := Self;');
       pcr.IBody.Add('    SetLength(Events,' + int2str(GetPointCount(e,pt_event)) + ');');
       pcr.IBody.Add('    SetLength(Datas, ' + int2str(GetPointCount(e,pt_data)) + ');');
     end
    else
     begin
       me := e;
       if cgt.elLinkIs(e) then me := cgt.elLinkMain(e);
       cn := cgt.elGetClassName(me) + '_' + Int2Hex(me,6);
       if UnitList.indexOf(cn)<0 then begin
         UnitList.Add(cn);
         sdk := cgt.elGetSDK(me);
         pr.MainForm := cn;
         CreateCode_(sdk,@pr,'_Control');
         me := cgt.sdkGetElement(sdk,0); //EditMulti(Ex)
         MakeMulti(e,cn,cgt.elGetClassName(me),cgt.elGetCodeName(me),@pr,'MultiBase',false,sdk);
         pr.Clear;
       end;
       if pcr.MainForm <> cn then AddUnit(pcr.RUnit,'hi' + cn);
       if cgt.elGetClassIndex(e) <> CI_UserElement then
         SetProps
       else
        begin
         pcr.IBody.Add('  with ' + cgt.elGetCodeName(e) + ' do begin');
         wb := true;
        end;
       //pcr.IBody.Add('    OnCreate := Create_hi' + cn + ';');
       pcr.IBody.Add('    ParentClass := Self;');
       pcr.IBody.Add('    SetLength(Events,' + int2str(GetPointCount(e,pt_event)) + ');');
       pcr.IBody.Add('    SetLength(Datas, ' + int2str(GetPointCount(e,pt_data)) + ');');
     end;
   CI_PolyMulti:
    begin
       wb := true;
//       pcr.IBody.Add('  with ' + cgt.elGetCodeName(e) + ' do begin');
       SetProps;
       pcr.IBody.Insert(pcr.IBody.Count-1, '    SetLength(Events,' + int2str(GetPointCount(e,pt_event)) + ');');
       pcr.IBody.Insert(pcr.IBody.Count-1, '    SetLength(Datas, ' + int2str(GetPointCount(e,pt_data)) + ');');
       pcr.IBody.Insert(pcr.IBody.Count-1, '    ParentClass := Self;');
       if cgt.elLinkIs(e) then e := cgt.elLinkMain(e);
       for i := 0 to cgt.elGetSDKCount(e)-1 do
        begin
           cn := cgt.elGetSDKName(e, i) + '_' + Int2Hex(e,6);
           if UnitList.indexOf(cn)<0 then begin
             UnitList.Add(cn);
             sdk := cgt.elGetSDKByIndex(e, i);
             pr.MainForm := cn;
             CreateCode_(sdk,@pr,'_Control');
             me := cgt.sdkGetElement(sdk,0); //EditMulti(Ex)
             if i = 0 then cd := 'PolyBase' else cd := cgt.elGetSDKName(e, 0) + '_' + Int2Hex(e,6);
             MakeMulti(e,cn,cgt.elGetClassName(me),cgt.elGetCodeName(me),@pr,cd,false,sdk);
             pr.Clear;
           end;
           if pcr.MainForm <> cn then AddUnit(pcr.RUnit,'hi' + cn);
           pcr.IBody.Insert(pcr.IBody.Count-1, '    AddCreator(''' + cgt.elGetSDKName(e, i) + ''',Create_hi' + cn + ');');
        end;
    end;
   CI_DocumentTemplate:
    begin
       me := e;
       if cgt.elLinkIs(e) then me := cgt.elLinkMain(e);
       cn := cgt.elGetClassName(me) + '_' + Int2Hex(me,6);
       if UnitList.indexOf(cn)<0 then begin
         UnitList.Add(cn);
         sdk := cgt.elGetSDK(me);
         pr.MainForm := cn;
         CreateCode_(sdk,@pr,'_Control');
         MakeMulti(e,cn,'ClassDocumentTemplate','',@pr,'DocumentTemplate',true,sdk);
         pr.Clear;
       end;
       if pcr.MainForm <> cn then AddUnit(pcr.RUnit,'hi' + cn);
       SetProps;
       pcr.IBody.Add('    OnCreate := Create_hi' + cn + ';');
    end;
   CI_DrawElement: begin
     SetProps;
     sdk := cgt.elGetSDK(e);
     for i := 0 to cgt.sdkGetCount(sdk)-1 do begin
       me := cgt.sdkGetElement(sdk,i);
       if cgt.elGetClassIndex(me) = CI_AS_Special then begin
         cgt.elGetPos(me,x,y);
         cgt.elGetSize(me,w,h);
         cn := cgt.propToString(cgt.elGetProperty(me,2));
         if cgt.propToByte(cgt.elGetProperty(me,7)) in [0,2] then
           pcr.IBody.Add(Format('    AddRect(''%s'',%d,%d,%d,%d,%s);',[cn,x,y,x+w,y+h,
             cgt.propToString(cgt.elGetProperty(me,5))]));
         if cgt.propToByte(cgt.elGetProperty(me,7)) in [1,2] then
           pcr.IBody.Add(Format('    AddDRect(''%s'',%d,%d,%d,%d,%d = 0,%d);',[cn,x,y,x+w,y+h,
             cgt.propToByte(cgt.elGetProperty(me,4)),cgt.propToInteger(cgt.elGetProperty(me,6))]));
       end;
     end;
   end;
   CI_UseHiDLL: begin
     SetProps;
     pcr.IBody.Add('    SetLength(_event_Event, ' + int2str(GetPointCount(e,pt_Event)) + ');');
     pcr.IBody.Add('    SetLength(_data_Data, ' + int2str(GetPointCount(e,pt_Data)) + ');');
   end;
   else SetProps(false);
  end;
  if wb then pcr.IBody.Add('  end;');
end;

function CheckVersionProc(const params:THiAsmVersion):integer;
begin
  if(params.build >= 162)then
    Result := CG_SUCCESS
  else Result := CG_INVALID_VERSION;
end;

function buildPrepareProc(const params:TBuildPrepareRec):integer; cdecl;
begin
  Result := CG_SUCCESS;
end;

procedure SaveMainUnit(Res:PCGrec; sdk:id_sdk);
var lst:PStrList;
    UnitName,cn:string;
    i:integer;
begin
   cn := getParentName(sdk);
   lst := NewStrList;
   lst.Add('unit hi' + cn + ';');
   lst.Add('');
   lst.Add('interface');
   lst.Add('');
   lst.Add('uses ');
   Res.Units.AddStrings(Res.RUnit);
   for i := 0 to Res.Units.Count-1 do
    lst.Add('  ' + Res.Units.Items[i] + ',');
   lst.Add('kol,Share;');
   lst.Add('');
   lst.Add('type');
   lst.Add('  TClass' + cn + ' = class');
   lst.Add('   public');
   lst.AddStrings(res.Vars);
   lst.Add('    constructor Create;');
   lst.Add('    destructor Destroy; override;');
   lst.Add('  end;');
   lst.Add('');
   lst.Add('var');
   lst.Add('  ClassMain:TClass' + cn + ';');
   lst.Add('');
   lst.Add('implementation');
   lst.Add('');
   lst.Add('constructor TClass' + cn + '.Create;');
   lst.Add('begin');
   lst.Add('  inherited;');
   lst.Add('  ClassMain := self;');
   lst.AddStrings(res.IBody);
//   lst.AddStrings(res.RInit);
   lst.Add('end;');
   lst.Add('');
   lst.Add('destructor TClass' + cn + '.Destroy;');
   lst.Add('begin');
   lst.AddStrings(res.Dead);
   lst.Add('  inherited;');
   lst.Add('end;');
   lst.Add('');
   lst.Add('end.');
   UnitName := cgt.ReadCodeDir(cgt.sdkGetElement(sdk, 0)) + 'hi' + cn + '.pas';
   lst.SaveToFile(UnitName);
   cgt.resAddFile(PChar(UnitName));
   lst.Free;

   Res.Vars.Clear;
   Res.Units.Clear;
//   Res.IBody.Clear;
   Res.Dead.Clear;
   Res.RUnit.Clear;

   Res.Units.Add('hi' + cn);
   Res.Units.Add('Windows');
end;

function buildProcessProc(var params:TBuildProcessRec):integer; cdecl;
var def,old_def:PStrList;
    s:string;
    e:id_element;
    i:byte;
    oRes:PCGrecOut;
    Res:TCGrec;
begin
  Cgt := params.cgt;

  // ----------------- CREATE def.inc ------------------------------------------------
  //Генерируем def.inc с отладочной информацией
  dbg := integer(cgt.isDebug(params.sdk) = true)*(1+cgt.ReadIntParam(PARAM_DEBUG_MODE));
  def := NewStrList;
  old_def := NewStrList;
  if dbg > 0 then
   begin
     def.Add('{$define _DEBUG_}');
     if dbg = 1 then
        def.Add('{$define _DEBUG_MAIL_}')
     else
      begin
        def.Add('const _dbServer = ' + Int2Str(cgt.ReadIntParam(PARAM_DEBUG_CLIENT_PORT)) + ';');
        def.Add('const _dbClient = ' + Int2Str(cgt.ReadIntParam(PARAM_DEBUG_SERVER_PORT)) + ';');
      end;
    end;
  e := cgt.sdkGetElementName(params.sdk, 'Project');
  if e <> 0 then
   begin
     i := cgt.propToByte(cgt.elGetProperty(e, 0));
     if i > 0 then
       def.Add('{$define _PROTECT_STD_}');
     if i = 2 then
       def.Add('{$define _PROTECT_MAX_}');

     i := cgt.propToByte(cgt.elGetProperty(e, 1));
     if i > 0 then
       def.Add('{$define _ERROR_STD_}');
     if i = 2 then
       def.Add('{$define _ERROR_MAX_}');
   end
  else
   begin
     def.Add('{$define _PROTECT_STD_}');
     def.Add('{$define _PROTECT_MAX_}');
     def.Add('{$define _ERROR_STD_}');
     def.Add('{$define _ERROR_MAX_}');
   end;

  s := cgt.ReadCodeDir(cgt.sdkGetElement(params.sdk,0)) + 'def.inc';
  old_def.LoadFromFile(s);
  if old_def.Text <> def.Text then
    def.SaveToFile(s);
  def.free;
  old_def.Free;

  UnitList := NewStrList;
  CreateCode_(params.sdk, @Res, 'nil');
  SaveMainUnit(@Res, params.sdk);

  Res.Units.AddStrings(Res.RUnit);
  new(oRes);
  oRes.MainForm := Res.MainForm;
  oRes.Units := NewStrList;
  oRes.Units.Assign(Res.Units);
  oRes.IBody := NewStrList;
  oRes.IBody.Assign(Res.IBody);
  params.result := oRes;
  UnitList.Free;

  Result := CG_SUCCESS;
end;

procedure CreateCode_(SDK:cardinal; Res:PCGrec; parent:string);
var i,j{,t,q}:integer;
    e,eind,p,lp:cardinal;
    _Parent,CodeName,s:string;
    tmp_list:PStrList;
  function Extend(s:string; len:integer):string;
  var i:integer;
  begin
    Result := s;
    for i :=1 to len-Length(s) do
      Result := Result+' ';
  end;
  procedure InitElement(e:id_element);
  var s:string;
  begin
   if cgt.elGetData(e) <> nil then exit;

   {
   for i := 0 to cgt.elGetPropCount(e)-1 do
     if cgt.propGetType(cgt.elGetProperty(e, i)) = data_element then
      begin
        p := cgt.propGetLinkedElement(e, cgt.propGetName(cgt.elGetProperty(e, i)));
        if p <> 0 then
          InitElement(p);
      end;
   }
   s := '  ' + cgt.elGetCodeName(e) + ' := THI' + GetCLASS(e) + '.Create';
   if(cgt.elGetInfSub(e) = 'Form')or(cgt.elGetFlag(e) and (IS_EDIT+IS_MULTI) <> 0) then
     if (eind <> 0)and(cgt.elGetFlag(eind)and IS_EDIT<>0) then
       s := s + '(' + _Parent + '.Control)'
     else s := s + '(' + parent + ')';
   Res.IBody.Add(s + ';');
   SetPropertys(Res,e);

   cgt.elSetData(e, pointer(e));
  end;
begin
  {$ifdef _debug_}
  cgt._debug('Lists creating', clGreen);
  {$endif}

  with Res^ do begin
    Vars  := NewStrList;
    Units := NewStrList;
    IBody := NewStrList;
    Dead  := NewStrList;
    RUnit := NewStrList;
    PrInt := NewStrList;
    PrImp := NewStrList;
  end;
  {$ifdef _debug_}
  cgt._debug('End of create.', clGreen);
  {$endif}

  Res.Units.Add('Windows');
  {$ifdef _debug_}
  cgt._Debug('Заполняем имена элементов, секции Units, Vars, находим Parent-а', clGreen);
  {$endif}
  for i := 0 to cgt.sdkGetCount(sdk)-1 do
   begin
     e := cgt.sdkGetElement(sdk,i);
     if (cgt.elGetFlag(e) and IS_HIDE > 0)and(cgt.elGetClassIndex(e) = CI_Translate) then
      begin
        CodeName := cgt.elGetClassName(e) + '_' + Int2Hex(e,6);
        cgt.elSetCodeName(e,PChar(CodeName));
        AddUnit(Res.Units,'hiTranslator');
        // сделать выбор конкретного translator для языка
        Res.Vars.Add('  ' + CodeName + ':THITranslator;');
        SetPropertys(Res,e);
        Res.IBody.Add('  ' + CodeName + '.init;');
      end;
   end;

  eind := 0;
  for i := 0 to cgt.sdkGetCount(sdk)-1 do begin
    e := cgt.sdkGetElement(sdk,i);
    if (cgt.elGetFlag(e)and IS_HIDE)<>0 then
       continue;
    CodeName := cgt.elGetClassName(e) + '_' + Int2Hex(e,6);
    cgt.elSetCodeName(e,PChar(CodeName));
    cgt.elSetData(e, nil);
    if cgt.elGetFlag(e) and IS_PARENT <> 0 then begin
      _Parent := CodeName;
      eind := e;
    end;
    s := GetCLASS(e);
    Res.Vars.Add('  ' + CodeName + ':THI' + s + ';');
    AddUnit(Res.Units,'hi' + s);
  end;
  {$ifdef _debug_}
  cgt._Debug('Создаем Parent-а и инициализируем его', clGreen);
  {$endif}
  if eind <> 0 then begin
    Res.IBody.Add(' //' + cgt.elGetCodeName(eind) + ' - Main');
    e := cgt.sdkGetParent(cgt.elGetParent(eind));
    if(e > 0)and(cgt.elGetClassIndex(e) = CI_PolyMulti) then
      begin
        for i := 0 to cgt.elGetSDKCount(e)-1 do
         if cgt.elGetSDKByIndex(e, i) = cgt.elGetParent(eind) then
           begin
             if i = 0 then
               Res.PrInt.Add('  procedure CreateParentElement(_Control:PControl); virtual;')
             else
               Res.PrInt.Add('  procedure CreateParentElement(_Control:PControl); override;');
        
             Res.PrImp.Add('procedure TClass' + cgt.elGetSDKName(e, i) + '_' + Int2Hex(e,6) + '.CreateParentElement;');
             break;
           end; 
        
        Res.PrImp.Add('begin');
        Res.PrImp.Add('  ' + _Parent + ' := THI' + cgt.elGetClassName(eind) + '.Create(_Control);');
        tmp_list := Res.IBody;
        Res.IBody := Res.PrImp; 
        if cgt.elGetSDKByIndex(e, 0) = cgt.elGetParent(eind) then
          SetPropertys(Res,eind)
        else
          begin 
            p := cgt.sdkGetElement(cgt.elGetSDKByIndex(e, 0), 1); 
            Res.IBody.Add('  ' + cgt.elGetCodeName(p) + ' := ' + _Parent + ';');
            SetPropertys(Res,eind,p);
          end;
        Res.IBody := tmp_list;
        Res.PrImp.Add('end;');  
         
        if cgt.elGetSDKByIndex(e, 0) = cgt.elGetParent(eind) then 
          Res.IBody.Add('  CreateParentElement(_Control);');
      end
    else
      begin
        s := '  ' + _Parent + ' := THI' + cgt.elGetClassName(eind) + '.Create';
        if cgt.elGetFlag(eind) and IS_EDIT <> 0 then
          s := s + '(' + parent + ')';
        Res.IBody.Add(s + ';');
        SetPropertys(Res,eind);
      end;     
  end;
  {$ifdef _debug_}
  cgt._Debug('Запускаем конструкторы и инициализацию остальных элементов схемы', clGreen);
  {$endif}
  for i := 0 to cgt.sdkGetCount(sdk)-1 do begin
    e := cgt.sdkGetElement(sdk,i);
    if(e=eind)or((cgt.elGetFlag(e)and IS_HIDE)<>0) then continue;
    Res.IBody.Add('//Init for ' + cgt.elGetClassName(e) + ';');
    InitElement(e);
  end;

  {$ifdef _debug_}
  cgt._Debug('Создаем линки и привязку data_element для всей схемы', clGreen);
  {$endif}
  Res.IBody.Add(' //%multi%');
  Res.IBody.Add(' //Make all connection in scheme');
  for i := 0 to cgt.sdkGetCount(sdk)-1 do begin
    e := cgt.sdkGetElement(sdk,i);
    if(cgt.elGetFlag(e)and IS_HIDE)<>0 then continue;

    for j := 0 to cgt.elGetPtCount(e)-1 do begin
      p := cgt.elGetPt(e,j);
      lp := cgt.ptGetRLinkPoint(p);
      if(lp <> 0)and(cgt.ptGetType(p) in [pt_Event,pt_Data]) then
        Res.IBody.Add('  '+Extend(codePoint(p),40)+' := _DoEvent('+codePoint(lp)+','+int2str(cgt.ptGetIndex(lp))
                          +DebugID(p)+');');
    end;
  end;
  for i := 0 to cgt.sdkGetCount(sdk)-1 do begin
    e := cgt.sdkGetElement(sdk,i);
    if(cgt.elGetFlag(e)and IS_HIDE)<>0 then continue;

    initdataElementProps(Res, e);
    if cgt.elGetClassIndex(e) = CI_MultiElement then
     begin
      if cgt.elLinkIs(e) then p := cgt.elLinkMain(e) else p := e;
      Res.IBody.Add('  ' + cgt.elGetCodeName(e) + '.OnCreate := Create_hi' + cgt.elGetCodeName(p) + ';');
     end;
  end;
  
  {$ifdef _debug_}
  cgt._Debug('Табуляция........................', clGreen);
  {$endif}
  if(eind <> 0)and(cgt.elGetClassIndex(eind) = CI_WinElement) then begin
    {j := 0; q := 1;
    repeat
      t := q; q := $7FFFFFFF;
      for i := 0 to cgt.sdkGetCount(sdk)-1 do begin
        e := cgt.sdkGetElement(sdk,i);
        p := GetPROP('TabOrder',e);
        if p <> 0 then begin
          p := cgt.propToInteger(p);
          if(p>t)and(p<q) then q := p;
          if p=t then begin
            inc(j);
            Res.IBody.Add('  ' + cgt.elGetCodeName(e) + '.Control.TabOrder := ' + int2str(j) + ';');
          end;
        end;
      end;
    until q=$7FFFFFFF;
    if j > 0 then} Res.IBody.Add('  ' + _Parent + '.Control.Tabulate;');
  end;
  {$ifdef _debug_}
  cgt._Debug('Устанавливаем деструкторы элементов схемы', clGreen);
  {$endif}
  for i := cgt.sdkGetCount(sdk)-1 downto 0 do
   begin
    e := cgt.sdkGetElement(sdk,i);
    if(e <> eind)and(cgt.elGetFlag(e) and IS_HIDE = 0) then
      Res.Dead.Add( '  ' + cgt.elGetCodeName(e) + '.Destroy;');
   end;
  {$ifdef _debug_}
  cgt._Debug('Устанавливаем деструктор Parent-а', clGreen);
  {$endif}
  if eind > 0 then
    begin
      e := cgt.sdkGetParent(cgt.elGetParent(eind));
      if(e = 0)or(cgt.elGetClassIndex(e) <> CI_PolyMulti)or(cgt.elGetSDKByIndex(e, 0) = cgt.elGetParent(eind)) then
        Res.Dead.Add( '  ' + cgt.elGetCodeName(eind) + '.Destroy;');
      // у дочерних полиморфов родительский элемент уничтожает базовый класс  
    end;

  Res.MainForm := _Parent;
end;

//**************************************************************************************
function getdata(s:string):string;
begin
   Result := getTok(s,'=') + ':';
   GetTok(s,'|');
   case Str2Int(s) of
    data_int: Result := Result + 'integer;';
    data_str,data_list,data_script: Result := Result + 'string;';
    data_data: Result := Result + 'TData;';
    data_combo: Result := Result + 'byte;';
    data_icon: Result := Result + 'PIcon;';
    data_real: Result := Result + 'real;';
    data_color: Result := Result + 'TColor;';
    data_stream,data_bitmap: Result := Result + 'PStream;';
   end;
end;

procedure ConfToCode(const Pack,UName:string);
var
   State:integer;
   List,Pas,Body:PStrList;
   i,ind:word;
   s,MName:string;
begin
   if FileExists(Pack + 'code\hi' + UName + '.pas') then exit;

   List := NewStrList;
   Pas  := NewStrList;
   Body := NewStrList;

   Pas.Add('unit hi' + UName + ';');
   Pas.Add('');
   Pas.Add('interface');
   Pas.Add('');
   Pas.Add('uses Kol,Share,Debug;');
   Pas.Add('');
   Pas.Add('type');
   Pas.Add('  THI' + UName + ' = class(TDebug)');
   Pas.Add('   private');
   Pas.Add('   public');

   State := 0;
   ind := 0;

   List.LoadFromFile(Pack + 'conf\' + UName + '.ini');
   for i := 0 to List.Count-1 do
    if List.Items[i] <> '' then
     if List.Items[i] = '[Edit]' then
      State := 1
     else if List.Items[i] = '[Property]' then
      State := 2
     else if List.Items[i] = '[Methods]' then
      begin
        State := 3;
        Pas.Add('');  Pas.Add('');
        ind := Pas.Count-1;
      end
     else if List.Items[i] = '[Type]' then
      State := 4
     else
      case State of
        0:;
        1:;
        2:
          begin
             Pas.Add('    _prop_' + getdata(List.Items[i]));
          end;
        3:
          begin
             s := List.Items[i];
             MName := getTok(s,'=');
             if MName[1] = '*' then delete(mname,1,1);
             GetTok(s,'|');
             case Str2Int(s) of
               1:
                 begin
                   Pas.Add('    procedure _work_' + MName + '(var _Data:TData; Index:word);');
                   Body.Add('');
                   Body.Add('procedure THI' + UName + '._work_' + MName + ';');
                   Body.Add('begin');
                   Body.Add('');
                   Body.Add('end;');
                 end;
               2:  Pas.Insert(ind,'    _event_' + MName + ':THI_Event;');
               3:
                 begin
                   Pas.Add('    procedure _var_' + MName + '(var _Data:TData; Index:word);');
                   Body.Add('');
                   Body.Add('procedure THI' + UName + '._var_' + MName + ';');
                   Body.Add('begin');
                   Body.Add('');
                   Body.Add('end;');
                 end;
               4:  Pas.Insert(ind,'    _data_' + MName + ':THI_Event;');
             end;
          end;
        4: ;
      end;
   Pas.Add('  end;');
   Pas.Add('');
   Pas.Add('implementation');
   Pas.Add('');
   Pas.AddStrings(Body);
   Pas.Add('');
   Pas.Add('end.');
   Pas.SaveToFile(Pack + 'code\hi' + UName + '.pas');
   List.free;
   Pas.free;
   Body.free;
end;

function isElementMaker(cgt:PCodeGenTools; e:id_element):integer; cdecl;
begin
  Result := integer(cgt.elGetClassIndex(e) = CI_MultiElement);
end;

function makeIniFile(cgt:PCodeGenTools; e:id_element; var shortinfo:string):PStrList;
var info,version,pti:string;
    ve:id_element;
    prop:id_prop;
    i,t:integer;
    pl:id_proplist;
    point:id_point;
begin
   Result := NewStrList;
   with Result^ do
    begin
      //~~~~~~~~~~~~~~~~~~~~~~~~ About ~~~~~~~~~~~~~~~~~~~~~~~~~~
      cgt._Debug('about section...', clGreen);
      Add('[About]');
      ve := cgt.sdkGetElementName(cgt.elGetSDK(e), 'Version');
      if ve = 0 then
       begin
         info := 'Automatic user element';
         shortinfo := 'MyElement';
         version := '1.0';
       end
      else
       begin
         prop := cgt.elGetProperty(ve, 0);
         version := cgt.propToString(prop);
         prop := cgt.elGetProperty(ve, 1);
         info := cgt.propToString(prop);
         prop := cgt.elGetProperty(ve, 2);
         shortinfo := cgt.propToString(prop);
       end;
      Add('Version=' + version);
      Add('Author=' + cgt.ReadStrParam(PARAM_USER_NAME));
      Add('Mail=' + cgt.ReadStrParam(PARAM_USER_MAIL));
      Add('');

      //~~~~~~~~~~~~~~~~~~~~~~~~ Type ~~~~~~~~~~~~~~~~~~~~~~~~~~
      cgt._Debug('type section...', clGreen);
      Add('[Type]');
      Add('Class=Element');
      Add('Info=' + info);
      Add('');

      //~~~~~~~~~~~~~~~~~~~~~~~~ Property ~~~~~~~~~~~~~~~~~~~~~~~~~~
      cgt._Debug('property section...', clGreen);
      Add('[Property]');
      for i := 0 to cgt.elGetPropertyListCount(e)-1 do
       begin
         pl := cgt.elGetPropertyListItem(e, i);
         if cgt.plGetName(pl) <> 'Mode' then // будет неверный при совпадении имен пользовательских свойств
          begin
            prop := cgt.plGetProperty(pl);
            Add(cgt.plGetName(pl) + '=' + cgt.plGetInfo(pl) + '|' + int2str(cgt.propGetType(prop)) + '|' + cgt.propToString(prop));
          end;
       end;
      Add('');

      //~~~~~~~~~~~~~~~~~~~~~~~~ Methods ~~~~~~~~~~~~~~~~~~~~~~~~~~
      cgt._Debug('method section...', clGreen);
      Add('[Methods]');
      for i := 0 to cgt.elGetPtCount(e)-1 do
       begin
         point := cgt.elGetPt(e,i);
         t := cgt.ptGetDataType(point);
         if t > 0 then
           info := int2str(t)
         else info := '';
         pti := cgt.ptGetInfo(point); 
         Add(cgt.ptGetName(point) + '=' + pti + '|' + int2str(cgt.ptGetType(point)) + '|' + info);
       end;
    end;
end;

function makePasFile(_cgt:PCodeGenTools; e:id_element; const en:string):PStrList;
var
    i:integer;
    sdk:id_sdk;
    pl:id_proplist;
    prop:id_prop;
    prn:id_element;
    point:id_point;
    Res:TCGrec;
begin
  dbg := 0;
  cgt := _cgt;
  Result := NewStrList;

  cgt._debug('Подготовка кода...', clGreen);
  UnitList := NewStrList;
  sdk := cgt.elGetSDK(e);
  Res.MainForm := 'EditMultiEx';
  CreateCode_(sdk, @Res, 'nil');
//  Res.Units.AddStrings(Res.RUnit);
  UnitList.Free;

  cgt._debug('Генерация юнита...', clGreen);
  with Result^ do
   begin
     Add('unit hi' + en + ';');
     Add('');
     Add('interface');
     Add('');
     if cgt.resEmpty() = 0 then
      begin
        Add('{$I ' + en + '.res}');
        Add('');
      end;
     Add('uses ');
     for i := 0 to Res.Units.Count-1 do
       Add('  ' + Res.Units.Items[i] + ',');
     Add('  hiMultiElementEx,hiMultiBase,kol,Share;');
     Add('');
     Add('type');
     Add('  THI' + en + ' = class(ThiMultiElementEx)');
     Add('   private');
     AddStrings(Res.Vars);
     for i := 0 to cgt.elGetPropertyListCount(e)-1 do
      begin
        pl := cgt.elGetPropertyListItem(e, i);
        if cgt.plGetName(pl) <> 'Mode' then
         begin
           prop := cgt.plGetProperty(pl);
           Add('    procedure SetProp' + cgt.plGetName(pl) + '(value: ' + DataTypes[cgt.propGetType(prop)] + ');');
         end;
      end;
     for i := 0 to cgt.elGetPtCount(e)-1 do
      begin
        point := cgt.elGetPt(e, i);
        if cgt.ptGetType(point) = pt_event then
          Add('    procedure Set' + cgt.ptGetName(point) + '(event:THI_Event);')
        else if cgt.ptGetType(point) = pt_data then
          Add('    procedure Set' + cgt.ptGetName(point) + '(data:THI_Event);');
      end;
     Add('   public');
     Add('    Child:THIEditMultiEx;');
     Add('');
     //Add('    constructor Create(_Control:PControl);');
     Add('    constructor Create;');
     Add('    destructor Destroy; override;');
     for i := 0 to cgt.elGetPtCount(e)-1 do
      begin
        point := cgt.elGetPt(e, i);
        if cgt.ptGetType(point) = pt_work then
          Add('    procedure _work_' + cgt.ptGetName(point) + '(var Data:TData; index:word);')
        else if cgt.ptGetType(point) = pt_var then
          Add('    procedure _var_' + cgt.ptGetName(point) + '(var Data:TData; index:word);')
        else if cgt.ptGetType(point) = pt_event then
          Add('    property _event_' + cgt.ptGetName(point) + ':THI_Event write Set' + cgt.ptGetName(point) + ';')
        else if cgt.ptGetType(point) = pt_data then
          Add('    property _data_' + cgt.ptGetName(point) + ':THI_Event write Set' + cgt.ptGetName(point) + ';');
      end;

     for i := 0 to cgt.elGetPropertyListCount(e)-1 do
      begin
        pl := cgt.elGetPropertyListItem(e, i);
        if cgt.plGetName(pl) <> 'Mode' then
         begin
           prop := cgt.plGetProperty(pl);
           Add('    property _prop_' + cgt.plGetName(pl) + ':' + DataTypes[cgt.propGetType(prop)] + ' write SetProp' + cgt.plGetName(pl) + ';');
         end;
      end;
     Add('  end;');
     Add('');
     Add('implementation');
     Add('');
     if Res.RUnit.Count > 0 then
      begin
        Add('uses ');
        for i := 0 to Res.RUnit.Count-2 do
          Add('  ' + Res.RUnit.Items[i] + ',');
        Add('  ' + Res.RUnit.Items[Res.RUnit.Count - 1] + ';'#13#10);
      end;
     Add('');
     Add('constructor THI' + en + '.Create;');
     Add('begin');
     Add('  inherited Create;');
     AddStrings(Res.IBody);
     Add('');
     Add('  Child := ' + cgt.elGetCodeName(cgt.sdkGetElement(sdk, 0)) + ';');
     Add('  Child.MainClass := TClassMultiBase(Self); // work but not correct... :(');
     Add('  Child.Parent := Self;');
     Add('  SetLength(Events, ' + int2str(GetPointCount(e,pt_event)) + ');');
     Add('  SetLength(Datas, ' + int2str(GetPointCount(e,pt_data)) + ');');
     Add('end;');
     Add('');
     Add('destructor THI' + en + '.Destroy;');
     Add('begin');
     AddStrings(Res.Dead);
     Add('  inherited;');
     Add('end;');
     Add('');
     for i := 0 to cgt.elGetPtCount(e)-1 do
      begin
        point := cgt.elGetPt(e, i);
        if cgt.ptGetType(point) = pt_work then
         begin
           Add('procedure THI' + en + '._work_' + cgt.ptGetName(point) + '(var Data:TData; index:word);');
           Add('begin');
           Add('  _hi_onEvent(Child.Works[' + int2str(cgt.ptGetIndex(point)) + '], Data);');
           Add('end;');
           Add('');
         end
        else if cgt.ptGetType(point) = pt_var then
         begin
           Add('procedure THI' + en + '._var_' + cgt.ptGetName(point) + '(var Data:TData; index:word);');
           Add('begin');
           Add('  _ReadData(Data, Child.Vars[' + int2str(cgt.ptGetIndex(point)) + ']);');
           Add('end;');
           Add('');
         end
        else if cgt.ptGetType(point) = pt_event then
         begin
           Add('procedure THI' + en + '.Set' + cgt.ptGetName(point) + ';');
           Add('begin');
           Add('  Events[' + int2str(cgt.ptGetIndex(point)) + '] := event;');
           Add('end;');
           Add('');
         end
        else if cgt.ptGetType(point) = pt_data then
         begin
           Add('procedure THI' + en + '.Set' + cgt.ptGetName(point) + ';');
           Add('begin');
           Add('  Datas[' + int2str(cgt.ptGetIndex(point)) + '] := data;');
           Add('end;');
           Add('');
         end;
      end;

     Add('');
     for i := 0 to cgt.elGetPropertyListCount(e)-1 do
      begin
        pl := cgt.elGetPropertyListItem(e, i);
        if cgt.plGetName(pl) <> 'Mode' then
         begin
           prop := cgt.plGetProperty(pl);
           Add('procedure THI' + en + '.SetProp' + cgt.plGetName(pl) + ';');
           Add('begin');
           prn := cgt.plGetOwner(pl);
           Add('  ' + cgt.elGetCodeName(prn) + '._prop_' + cgt.propGetName(prop) + ' := value;');
           Add('end;');
         end;
      end;
     Add('');
     Add('end.');
   end;
  Res.Clear;
end;

function MakeElement(cgt:PCodeGenTools; e:id_element):integer; cdecl;
var list:PStrList;
    s,en:string;
    path:array[0..MAX_PATH] of char;
begin
  if cgt.elGetClassName(e) = 'MultiElementEx' then
   begin
     list := makeIniFile(cgt, e, en);
     integer(pointer(@path)^) := e;
     cgt.GetParam(PARAM_PROJECT_PATH, @path);
     s := path + en + '.ini';
     cgt._Debug(PChar('Save to file: ' + s), clGreen);
     list.SaveToFile(s);
     list.free;

     cgt.resSetPref(PChar(en + '_'));

     list := makePasFile(cgt, e, en);
     s := path + 'hi' + en + '.pas';
     cgt._Debug(PChar('Save to file: ' + s), clGreen);
     list.SaveToFile(s);
     list.free;
   end;
  Result := 0;
end;

//**************************************************************************************

procedure hintForElement(var p:THintParams); cdecl;
type ThintForElement = procedure (var p:THintParams); cdecl;
var id:cardinal;
    txt:PChar;
begin
  id := LoadLibrary(PChar(GetStartDir + 'Elements\Delphi\FTCG_CodeGen.dll'));
  if id = 0 then exit;  
  p.sdk := p.cgt.elGetParent(p.cgt.ptGetParent(p.point));
  ThintForElement(GetProcAddress(id, 'hintForElement'))(p);
  if p.hint <> nil then
   begin
    txt := p.hint;
    GetMem(p.hint, strlen(txt));
    StrCopy(p.hint, txt);
   end;
  FreeLibrary(id);
end;

//**************************************************************************************

procedure synReadFuncList(var p:TSynParams); cdecl;
type TsynReadFuncList = procedure (var p:TSynParams); cdecl;
var id:cardinal;
    txt1,txt2:PChar;
begin
  id := LoadLibrary(PChar(GetStartDir + 'Elements\Delphi\FTCG_CodeGen.dll'));
  if id = 0 then exit;
  TsynReadFuncList(GetProcAddress(id, 'synReadFuncList'))(p);

  if p.inst_list <> nil then
   begin
    txt1 := p.inst_list;
    txt2 := p.disp_list;
    GetMem(p.inst_list, strlen(txt1));
    GetMem(p.disp_list, strlen(txt2));
    StrCopy(p.inst_list, txt1);
    StrCopy(p.disp_list, txt2);
   end;
  FreeLibrary(id);
end;

type
  TRFD_Rec = record
      name:PChar;
      className:PChar;
      inherit:PChar;
      interfaces:PChar;
      sub:PChar;
  end;

const non_fpc:array[0..12] of string = (
     'WebBrowser', 'Flash', 'PlotDiffSeries', 'UseActiveX', 'PNG', 'Jpeg',
     'ProcInfo', 'AdapterInfo', 'DiskInfo', 'ProcessInfo', 'MotherBoardInfo', 'MemoryInfo',
     'FastMathParse'
   );

function isReadyForAdd(cgt:PCodeGenTools; const rfd:TRFD_Rec; sdk:id_sdk):boolean; cdecl;
var p:id_element;
    s,c:string;
    cmp:array[0..128] of char;
    i:integer;
begin
  Result := true;
  
  p := cgt.sdkGetParent(sdk);
  if p <> 0 then
    begin
      s := cgt.elGetClassName(p); 
      if s = 'DocumentTemplate' then
        begin Result := rfd.inherit = 'PrintControl'; exit; end
      else if (s  = 'MultiElement')or(s  = 'MultiElementEx')or(s  = 'PoliMultiElement') then
        Result := (rfd.className <> 'WinElement')and(rfd.sub <> 'Form')
      else if s = 'FTCG_Tools' then
        begin
          cardinal(pointer(@cmp[0])^) := cgt.sdkGetElement(sdk, 0);
          cgt.GetParam(PARAM_CODE_PATH, @cmp[0]);
          c := cmp;
          Result := FileExists(c + 'hi' + rfd.name + '.hws');     
        end;
    end;
    
  if Result and(cgt.sdkGetCount(sdk) > 0) then
   begin
     cardinal(pointer(@cmp[0])^) := cgt.sdkGetElement(sdk, 0);
     cgt.GetParam(PARAM_COMPILER, @cmp[0]);
     c := LowerCase(cmp);
     if pos('fpc', c) > 0 then
       for i := 0 to high(non_fpc) do
        if rfd.name = non_fpc[i] then
          begin
            Result := false;
            break;
          end;
   end;  
end;

exports
  buildPrepareProc,
  buildProcessProc,
  CheckVersionProc,
  ConfToCode,
  synReadFuncList,
  hintForElement,
  isElementMaker,
  MakeElement,
  isReadyForAdd;

end.