unit hiFastMathParse;

interface

uses Kol,err,Share,Debug;

type
  ListArr = class
    It:array of string;
    constructor Create;
    procedure Del(i:integer);
    procedure Clear;
    procedure Add(s:string);
    procedure Put(s:string); overload;
    procedure Put(var L:ListArr); overload;
    destructor Destroy; override;
  end;
  PListArr = ^ListArr;

  THIFastMathParse = class(TDebug)
   private
    FDataCount:word;
    Token:string;
    TokType:byte;
    Line:string;
    LPos:smallint;
    FResult:real;
    FDefault:real;
    AngleMode:real;
    Vars:array of real;
    IndV:array of smallint;
    SPind:array of smallint;
    SPmin,SPmax:smallint;
    Proc:string;
    List:ListArr;

    procedure SetCount(Value:word);
    procedure SetLine(Value:string);
    procedure SetDefault(Value:real);
    procedure SetAngleMode(Value:byte);

    procedure FreeSP;
    procedure SetVAR(typ:byte;var x:real);
    procedure ProcCmd0(cmd,mnem:string);
    procedure ProcCmd1(i:integer;cmd,mnem:string);
    procedure ProcCmd2(var x:real;cmd,mnem:string);
    procedure ListCmd1(var L:ListArr;i:integer;cmd,mnem:string);
    procedure GetToken;
    procedure NegList(var typ:byte);
    procedure InvList(var typ:byte);

    procedure Compile;
    function  Level1(var x:real):byte; // + -
    function  Level2(var x:real):byte; // / *
    function  Level3(var x:real):byte; // ^
    function  Level4(var x:real):byte; // unar + - not
    function  Level5(var x:real):byte; // () function const
//  function  ReadFunc(var x:real; f:byte):byte;
   public
    X:array of THI_Event;
    _event_onError:THI_Event;
    _event_onResult:THI_Event;
    _prop_ResultType:byte;
    _event_onDebugStrings:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doCalc(var _Data:TData; Index:word);
    procedure _work_doMathStr(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doAngleMode(var _Data:TData; Index:word);
    procedure _work_doDefault(var _Data:TData; Index:word);    
    procedure _var_Result(var _Data:TData; Index:word);
    procedure _var_reCalc(var _Data:TData; Index:word);
    procedure _var_PosErr(var _Data:TData; Index:word);
    procedure _var_Proc(var _Data:TData; Index:word);
    property _prop_DataCount:word write SetCount;
    property _prop_MathStr:string write SetLine;
    property _prop_Default:real write SetDefault;
    property _prop_AngleMode:byte write SetAngleMode;
  end;

implementation

type
  Tproc = function(S,Dat:pointer):real;

const
 //Результат синтаксической выборки подпрограммой GetToken
  TokName   = 1;
  TokReal   = 2;
  TokNumber = 3;
  TokSymbol = 4;
  TokMath   = 5;
  TokEnd    = 6;
 //Результаты генерации кода/значения ф-ями LevelX
  SyntaxErr = 0;
  CalcErr   = 1;
  Constant  = 2;
  Variable  = 3;
  Neg_Var   = 4;
  C_plus_V  = 5;
  C_minus_V = 6;
  C_mul_V   = 7;
  C_div_V   = 8;
  Argument  = 9;
  Neg_Arg   = 10;
  C_plus_A  = 11;
  C_minus_A = 12;
  C_mul_A   = 13;
  C_div_A   = 14;
 //Просто константа
  digE      = 2.718281828459045; //возможно определена в Delphi
//var TTT:integer=0;
{
function QQQ(t:integer):string;
begin
  if t=0 then Result:='SyntaxErr'
  else if t=1 then Result:='CalcErr'
  else if t=2 then Result:='Constant'
  else if t=3 then Result:='Variable'
  else if t=4 then Result:='Neg_Var'
  else if t=5 then Result:='C_plus_V'
  else if t=6 then Result:='C_minus_V'
  else if t=7 then Result:='C_mul_V'
  else if t=8 then Result:='C_div_V'
  else if t=9 then Result:='Argument'
  else if t=10 then Result:='Neg_Arg'
  else if t=11 then Result:='C_plus_A'
  else if t=12 then Result:='C_minus_A'
  else if t=13 then Result:='C_mul_A'
  else if t=14 then Result:='C_div_A';
end;

procedure DBG(t:integer;x:real;var Lst:ListArr);
var i:integer;
    s:string;
begin
  s:=QQQ(t)+#13+#10;//'Type='+int2str(t)
  s:=s+'Const='+Double2Str(x)+#13+#10;
  if assigned(Lst) then begin
    i:=0;while i<high(Lst.It) do begin
      s:=s+int2str(Length(Lst.It[i]))+':: '+Lst.It[i+1]+#13#10;
      inc(i,2);
    end;
  end
  else s:=s+'NULL'#13#10;
  _debug(s);
end;
}
procedure ListArr.Add(s:string);
var i:integer;
begin
  i:=high(It)+1;
  SetLength(It,i+1);
  It[i]:=s;
end;

procedure ListArr.Clear;
var i:integer;
begin
  for i:=high(It) downto 0 do It[i]:='';
  SetLength(It,0);
end;

constructor ListArr.Create;
begin
  inherited Create;
  SetLength(It,0);
  //inc(TTT);
end;

destructor ListArr.Destroy;
begin
  //dec(TTT);
  Clear;
  inherited;
end;

procedure ListArr.Put(s:string);
begin
  Clear;
  SetLength(It,1);
  It[0]:=s;
end;

procedure ListArr.Put(var L:ListArr);
var i,j:integer;
begin
  Clear;
  j:=high(L.It)+1;
  SetLength(It,j);
  for i:=0 to j-1 do It[i]:=L.It[i];
end;

procedure ListArr.Del(i:integer);
var j:integer;
begin
  j:=high(It);
  while i<j do begin It[i]:=It[i+1];inc(i);end;
  if j>=0 then begin
    It[j]:='';
    SetLength(It,j);
  end;
end;

constructor THIFastMathParse.Create;
begin
  inherited Create;
  Proc := '';
  List:=ListArr.Create;
end;

destructor THIFastMathParse.Destroy;
begin
  //dec(TTT);
  Proc := '';
  Vars := nil;
  SpInd := nil;
  IndV := nil;
  List.Destroy;
  inherited;
end;

procedure THIFastMathParse.SetAngleMode;
begin
  if Value=0 then AngleMode :=1
  else AngleMode:=pi/180;
end;

procedure THIFastMathParse.SetDefault;
begin
  FDefault:=Value;
  FResult:=FDefault;
  LPos:=-1;
end;

procedure THIFastMathParse.SetCount;
begin
  SetLength(X,Value);
  SetLength(IndV,Value+1);
  FDataCount := Value;
end;

procedure THIFastMathParse._work_doDefault;
begin
  SetDefault(ToReal(_Data));
end;

procedure THIFastMathParse._work_doAngleMode;
begin
  SetAngleMode(ToInteger(_Data));
end;

procedure THIFastMathParse._work_doClear;
begin
  FResult:=FDefault;
  LPos:=-1;
end;

procedure THIFastMathParse._var_Result;
begin
  if LPos>=0 then _Data.data_type := data_null
  else if _prop_ResultType = 0 then begin
    _Data.data_type := data_int;
    _Data.idata := Round(FResult);
  end
  else begin
    _Data.data_type := data_real;
    _Data.rdata := FResult;
  end
end;

procedure THIFastMathParse._var_Proc;
begin
  _Data.data_type := data_str;
  _Data.sdata := Proc;
end;

procedure THIFastMathParse._var_PosErr;
begin
  _Data.data_type := data_int;
  _Data.idata := LPos;
end;
{
function fR(x:extended):extended;
asm frndint
end;
}
procedure THIFastMathParse._work_doCalc;
var i,Res,Err:integer;
begin
//asm mov eax,$12345678 end;
  Err:=-1;Res:=0;
  try
    if Proc='' then Compile;
    LPos := 0;
    if IndV[0]>=0 then Vars[IndV[0]]:=ToReal(_Data);
    _Data.data_type:=data_null;
    for i:=1 to FDataCount do
      if IndV[i]>=0 then begin
        _ReadData(_Data,X[i-1]);
        if _Data.data_type=data_null then
          raise Exception.Create(e_Math_InvalidArgument,'');
        Vars[IndV[i]]:= ToReal(_Data);
      end;
    FResult := Tproc(@Proc[1])(self,Vars);
    if _prop_ResultType=0 then Res:=Round(FResult);
    LPos := -1;
  except on E:Exception do
    case E.Code of
      e_Custom: Err:=SyntaxErr;
      else      Err:=CalcErr;
    end;//case
  end;
  if Err < 0 then
    if _prop_ResultType=0 then _hi_OnEvent(_event_onResult,Res)
    else _hi_OnEvent(_event_onResult,FResult)
  else begin
    if LPos>0 then begin
      dec(LPos);
      Proc := '';
      Vars := nil;
    end;
    FResult := FDefault;
    _hi_OnEvent(_event_onError,Err);
  end;
end;

procedure THIFastMathParse._var_reCalc;
var i:integer;
begin
  try
    if Proc='' then Compile;
    LPos := 0;
    if IndV[0]>=0 then Vars[IndV[0]]:=ToReal(_Data);
    for i:=1 to FDataCount do
      if IndV[i]>=0 then begin
        _ReadData(_Data,X[i-1]);
        if _Data.data_type=data_null then
          raise Exception.Create(e_Math_InvalidArgument,'');
        Vars[IndV[i]]:= ToReal(_Data);
      end;
    FResult := Tproc(@Proc[1])(self,Vars);
    if _prop_ResultType=0 then begin
      _Data.data_type := data_int;
      _Data.idata := Round(FResult);
    end
    else begin
      _Data.data_type := data_real;
      _Data.rdata := FResult;
    end;
    LPos := -1;
  except
    if LPos>0 then begin
      dec(LPos);
      Proc := '';
      Vars := nil;
    end;
    FResult := FDefault;
    _Data.data_type := data_null;
  end;
end;

procedure THIFastMathParse._work_doMathStr;
var Err:integer;
begin
  Err:=-1;
  try
    LPos := 1;
    if _data.Data_type<>data_str then
      raise Exception.Create(e_Custom,'');
    Line := _data.sdata+#1;
    Compile;
    LPos := -1;
  except on E:Exception do begin
      case E.Code of
        e_Custom: Err:=SyntaxErr;
        else      Err:=CalcErr;
      end;//case
      dec(LPos);
      Proc := '';
      Vars := nil;
      FResult:=FDefault;
    end;//do
  end;//except
  if Err>=0 then _hi_OnEvent(_event_onError,Err);
  //_debug(Int2Str(TTT));
end;

procedure THIFastMathParse.SetLine;
begin
  Line := Value+#1;
end;


procedure THIFastMathParse.Compile;
var x:real;
    i:integer;
begin
  for i:=0 to FDataCount do IndV[i]:=-1;
  SPind:= nil;SPmax:=-1;SPmin:=-1;
  Vars := nil;
  Proc := '';
  LPos := 1;
  List.Clear;
  ProcCmd0(#$53,'push    ebx');
  ProcCmd0(#$56,'push    esi');
  ProcCmd0(#$8B + #$D8,'mov     ebx,eax '#9'self');
  ProcCmd0(#$8B + #$F2,'mov     esi,edx '#9'data array');
  _hi_OnEvent(_event_onDebugStrings,'--------'#9'-----------------'#9'BEGIN equation');
  GetToken;x:=0; SetVAR(Level1(x),x);
  _hi_OnEvent(_event_onDebugStrings,'--------'#9'-----------------'#9'END equation');
  ProcCmd0(#$9B,'fwait');
  ProcCmd0(#$5E,'pop     esi');
  ProcCmd0(#$5B,'pop     ebx');
  ProcCmd0(#$C3,'ret');
  if TokType<>TokEnd then
    raise Exception.Create(e_Custom,'');
end;


function THIFastMathParse.Level1;
var op:char;
    typ:byte;
    x1:real;
    L:ListArr;
    s0,s1:string;
    i:integer;
  procedure SetFirst(t:byte);
  begin
    s0:=List.It[0];s0[1]:=char(ord(s0[1])-1);
    s1:=List.It[1];
    if t=C_minus_A then begin
      s0[2]:=char(ord(s0[2])+$20);
      s1[2]:='s';s1[3]:='u';s1[4]:='b';
    end
    else begin
      s1[2]:='a';s1[3]:='d';s1[4]:='d';
    end;
    List.Del(1);List.Del(0);
  end;
  function SetAll(t1,t2:byte):byte;
  begin
    Result:=t1;
    if t1=C_minus_V then begin
      if t2=C_plus_A then begin
        s0:=List.It[0];
        s1:=List.It[1];
        s0[1]:=char(ord(s0[1])-1);
        s0[2]:=char(ord(s0[2])+$28);
        s1[2]:='s';s1[3]:='u';s1[4]:='b';s1[5]:='r';
        Result:=C_plus_V;
        List.Del(1);List.Del(0);
      end
      else begin
        i:=3;
        while i<=high(List.It) do begin
          s1:=List.It[i];
          if s1[2]='a' then begin
            s0:=List.It[0];
            s0[1]:=char(ord(s0[1])-1);
            s0[2]:=char(ord(s0[2])+$20);
            List.It[0]:=s0;
            s0:=List.It[1];
            s0[2]:='s';s0[3]:='u';s0[4]:='b';
            List.It[1]:=s0;
            s0:=List.It[i-1];
            s0[2]:=char(ord(s0[2])+$28);
            s1[2]:='s';s1[3]:='u';s1[4]:='b';s1[5]:='r';
            List.Del(i);List.Del(i-1);
            Result:=C_plus_V;
            break;
          end;
          inc(i,2);
        end;
        if Result=C_minus_V then begin
          NegList(t2);
          SetFirst(t2);
        end;
      end;
    end
    else SetFirst(t2);
    ProcCmd0(s0,s1);
    i:=0;while i<=high(List.It) do begin
      ProcCmd0(List.It[i],List.It[i+1]);
      inc(i,2);
    end;
  end;
begin
  Result := Level2(x);
  if (Token <>'-')and(Token<>'+') then exit;//DBG(Result,x,List);
  L:=ListArr.Create;
  case Result of
    C_mul_A:
      if (x=1)and(high(List.It)<2) then begin x:=0;Result:=C_plus_A;end
      else if (x=-1)and(high(List.It)<2) then begin x:=0;Result:=C_minus_A;end
      else begin SetVAR(Result,x);x:=0;Result:=C_plus_V;end;
    C_mul_V,C_div_V,C_div_A: begin
      SetVAR(Result,x);x:=0;Result:=C_plus_V;
    end;
    Variable: begin x:=0;Result:=C_plus_V;end;
    Neg_Var: begin x:=0;Result:=C_minus_V;end;
    Argument: begin x:=0;Result:=C_plus_A;end;
    Neg_Arg: begin x:=0;Result:=C_minus_A;end;
  end;
  L.Put(List);
  repeat
    op := Token[1]; //DBG(Result,x,L);
    i:=SPmax;
    GetToken;x1:=0; typ := Level2(x1);//DBG(typ,x1,List);
    if (Result in[C_minus_V,C_plus_V])and(i=SPmin) then begin
      inc(Result,Argument-Variable);
      dec(SPmin);
      i:=SPind[i];
      ListCmd1(L,8*i,#$DD + #$46,'fld     [esi+8*'+Int2Str(i)+']'#9'Pop FPU');
    end;
    case typ of
      C_mul_A:
        if (x1=1)and(high(List.It)<2) then begin x1:=0;typ:=C_plus_A;end
        else if (x1=-1)and(high(List.It)<2) then begin x1:=0;typ:=C_minus_A;end
        else begin SetVAR(typ,x1);x1:=0;typ:=C_plus_V;end;
      C_mul_V,C_div_V,C_div_A: begin
        SetVAR(typ,x1);x1:=0;typ:=C_plus_V;
      end;
      Variable: begin x1:=0;typ:=C_plus_V;end;
      Neg_Var: begin x1:=0;typ:=C_minus_V;end;
      Argument: begin x1:=0;typ:=C_plus_A;end;
      Neg_Arg: begin x1:=0;typ:=C_minus_A;end;
    end;
    if op='-' then begin
      x1:=-x1;
      if (typ in[C_plus_A,C_minus_A]) then NegList(typ)
      else if typ=C_plus_V then typ:=C_minus_V
      else if typ=C_minus_V then typ:=C_plus_V;
    end;
    x:=x+x1;
    if typ<>Constant then
      if Result=Constant then begin
        Result:=typ;L.Put(List);
      end
      else if(Result>Argument)and(typ>Argument)then begin
        SetFirst(typ);
        L.Add(s0);
        L.Add(s1);
        for i:=0 to high(List.It) do L.Add(List.It[i]);
      end
      else if(Result<Argument)and(typ>Argument)then
        Result:=SetAll(Result,typ)
      else if(Result>Argument)and(typ<Argument)then begin
        List.Put(L);
        Result:=SetAll(typ,Result);
      end
      else begin
        dec(SPmax);
        if typ=Result then
          ProcCmd0(#$DE + #$C1,'faddp   st(1),st')
        else if typ=C_minus_V then
          ProcCmd0(#$DE + #$E9,'fsubp   st(1),st')
        else begin
          ProcCmd0(#$DE + #$E1,'fsubrp  st(1),st');
          Result:=typ;
        end;
      end;
  until (Token <>'-')and(Token<>'+');
  List.Put(L);L.Destroy;
end;

function THIFastMathParse.Level2;
var op:char;
    typ:byte;
    x1:real;
    L:ListArr;
    s0,s1:string;
    i:integer;
  procedure SetFirst(t:byte);
  begin
    s0:=List.It[0];s0[1]:=char(ord(s0[1])-1);
    s1:=List.It[1];
    if t=C_div_A then begin
      s0[2]:=char(ord(s0[2])+$30);
      s1[2]:='d';s1[3]:='i';s1[4]:='v';
    end
    else begin
      s0[2]:=char(ord(s0[2])+8);
      s1[2]:='m';s1[3]:='u';s1[4]:='l';
    end;
    List.Del(1);List.Del(0);
  end;
  function SetAll(t1,t2:byte):byte;
  begin
    Result:=t1;
    if t1=C_div_V then begin
      if t2=C_mul_A then begin
        s0:=List.It[0];
        s1:=List.It[1];
        s0[1]:=char(ord(s0[1])-1);
        s0[2]:=char(ord(s0[2])+$38);
        s1[2]:='d';s1[3]:='i';s1[4]:='v';s1[5]:='r';
        Result:=C_mul_V;
        List.Del(1);List.Del(0);
      end
      else begin
        i:=3;
        while i<=high(List.It) do begin
          s1:=List.It[i];
          if s1[2]='m' then begin
            s0:=List.It[0];
            s0[1]:=char(ord(s0[1])-1);
            s0[2]:=char(ord(s0[2])+$30);
            List.It[0]:=s0;
            s0:=List.It[1];
            s0[2]:='d';s0[3]:='i';s0[4]:='v';
            List.It[1]:=s0;
            s0:=List.It[i-1];
            s0[2]:=char(ord(s0[2])+$30);
            s1[2]:='d';s1[3]:='i';s1[4]:='v';s1[5]:='r';
            List.Del(i);List.Del(i-1);
            Result:=C_mul_V;
            break;
          end;
          inc(i,2);
        end;
        if Result=C_div_V then begin
          InvList(t2);
          SetFirst(t2);
        end;
      end;
    end
    else SetFirst(t2);
    ProcCmd0(s0,s1);
    i:=0;while i<=high(List.It) do begin
      ProcCmd0(List.It[i],List.It[i+1]);
      inc(i,2);
    end;
  end;
begin
  Result := Level3(x);
  if (Token <>'*')and(Token<>'/') then exit;//DBG(Result,x,List);
  L:=ListArr.Create;
  case Result of
    C_plus_A:
      if (x=0)and(high(List.It)<2) then begin x:=1;Result:=C_mul_A;end
      else begin SetVAR(Result,x);x:=1;Result:=C_mul_V;end;
    C_minus_A:
      if (x=0)and(high(List.It)<2) then begin x:=-1;Result:=C_mul_A;end
      else begin SetVAR(Result,x);x:=1;Result:=C_mul_V;end;
    C_plus_V,C_minus_V: begin
      SetVAR(Result,x);x:=1;Result:=C_mul_V;
    end;
    Variable: begin x:=1;Result:=C_mul_V;end;
    Neg_Var: begin x:=-1;Result:=C_mul_V;end;
    Argument: begin x:=1;Result:=C_mul_A;end;
    Neg_Arg: begin x:=-1;Result:=C_mul_A;end;
  end;
  L.Put(List);
  repeat
    op :=  Token[1];//DBG(Result,x,L);
    i:=SPmax;
    GetToken;x1:=0; typ := Level3(x1);//DBG(typ,x1,List);
    if (Result in[C_mul_V,C_div_V])and(i=SPmin) then begin
      inc(Result,Argument-Variable);
      dec(SPmin);
      i:=SPind[i];
      ListCmd1(L,8*i,#$DD + #$46,'fld     [esi+8*'+Int2Str(i)+']'#9'Pop FPU');
    end;
    case typ of
      C_plus_A:
        if (x1=0)and(high(List.It)<2) then begin x1:=1;typ:=C_mul_A;end
        else begin SetVAR(typ,x1);x1:=1;typ:=C_mul_V;end;
      C_minus_A:
        if (x1=0)and(high(List.It)<2) then begin x1:=-1;typ:=C_mul_A;end
        else begin SetVAR(typ,x1);x1:=1;typ:=C_mul_V;end;
      C_plus_V,C_minus_V: begin SetVAR(typ,x1);x1:=1;typ:=C_mul_V;end;
      Variable: begin x1:=1;typ:=C_mul_V;end;
      Neg_Var: begin x1:=-1;typ:=C_mul_V;end;
      Argument: begin x1:=1;typ:=C_mul_A;end;
      Neg_Arg: begin x1:=-1;typ:=C_mul_A;end;
    end;
    if op='/' then begin
      x1:=1/x1;
      if (typ=C_mul_A)or(typ=C_div_A) then InvList(typ)
      else if typ=C_mul_V then typ:=C_div_V
      else if typ=C_div_V then typ:=C_mul_V
    end;
    x:=x*x1;
    if typ<>Constant then begin
      if Result=Constant then begin
        Result:=typ;L.Put(List);
      end
      else if(Result>Argument)and(typ>Argument)then begin
        SetFirst(typ);
        L.Add(s0); L.Add(s1);
        for i:=0 to high(List.It) do L.Add(List.It[i]);
      end
      else if(Result<Argument)and(typ>Argument)then
        Result:=SetAll(Result,typ)
      else if(Result>Argument)and(typ<Argument)then begin
        List.Put(L);
        Result:=SetAll(typ,Result);
      end
      else begin
        dec(SPmax);
        if typ=Result then
          ProcCmd0(#$DE + #$C9,'fmulp   st(1),st')
        else if typ=C_div_V then
          ProcCmd0(#$DE + #$F9,'fdivp   st(1),st')
        else begin
          ProcCmd0(#$DE + #$F1,'fdivrp  st(1),st');
          Result:=typ;
        end;
      end;
    end;
  until (Token <>'*')and(Token<>'/');
  List.Put(L);L.Destroy;
end;

function THIFastMathParse.Level3;
begin
  Result := Level4(x);
end;

function THIFastMathParse.Level4;
var op:char;
begin
  op := '+';
  if (Token = '-')or(Token = '+') then begin
    op := Token[1];
    GetToken;
  end;
  Result := Level5(x);
  if op = '-' then begin
    x:=-x;
    case Result of
      Variable: Result:=Neg_Var;
      Neg_Var:  Result:=Variable;
      Argument: Result:=Neg_Arg;
      Neg_Arg:  Result:=Argument;
      C_plus_V: Result:=C_minus_V;
      C_minus_V:Result:=C_plus_V;
      C_plus_A: Result:=C_minus_A;
      C_minus_A:Result:=C_plus_A;
    end;
  end;
end;

function THIFastMathParse.Level5;
var i,j:integer;
begin
  Result := Constant;
  if Token = '%' then begin
    GetToken;
    if TokType=TokNumber then begin
      Result:=Argument;
      i := Str2Int(Token);
      if i=0 then begin//x := FResult
        i:=integer(@FResult)-integer(self);
        ListCmd1(List,i,#$DD + #$43,'fld     [ebx+'+Int2Str(i)+']  '#9'FResult');
      end
      else if i<=FDataCount then
        if Assigned(self.X[i-1].Event) then begin
          j:=IndV[i];
          if j<0 then begin
            j:=high(Vars)+1;
            SetLength(Vars,j+1);
            IndV[i]:=j;
          end;
          ListCmd1(List,8*j,#$DD + #$46,'fld     [esi+8*'+Int2Str(j)+']'#9'X'+Int2Str(i));
        end
        else begin
          j:=IndV[0];
          if j<0 then begin
            j:=high(Vars)+1;
            SetLength(Vars,j+1);
            IndV[0]:=j;
            IndV[i]:=-2;
          end;
          if IndV[i]=-2 then
            ListCmd1(List,8*j,#$DD + #$46,'fld     [esi+8*'+Int2Str(j)+']'#9'from input Data')
          else raise Exception.Create(e_Math_InvalidArgument,'');
        end
      else raise Exception.Create(e_Custom,'');
    end
    else raise Exception.Create(e_Custom,'');
  end
  else if Token = '(' then begin
    GetToken; Result := Level1(x);
    if Token <> ')' then raise Exception.Create(e_Custom,'');
  end
  else case TokType of
    TokName:
      if      Token = 'pi'     then       x := pi
      else if Token = 'e'      then       x := digE
      else raise Exception.Create(e_Custom,'');
    TokReal  : x := Str2Double(Token);
    TokNumber: x := Str2Int(Token);
    else raise Exception.Create(e_Custom,'');
  end;
  GetToken;
end;



procedure THIFastMathParse.SetVAR(typ:byte;var x:real);
var s,s0,s1:string;
    pi_:real;
    i:integer;
    tmp:byte;
//Довожу полуфабрикат до результата в стеке сопроцессора
begin
  if typ >= Argument then begin
    FreeSP;
    case typ of
      C_minus_A: begin
        i:=3;
        while i<=high(List.It) do begin
          s1:=List.It[i];
          if s1[2]='a' then begin
            s0:=List.It[0];
            s0[1]:=char(ord(s0[1])-1);
            s0[2]:=char(ord(s0[2])+$20);
            List.It[0]:=s0;
            s0:=List.It[1];
            s0[2]:='s';s0[3]:='u';s0[4]:='b';
            List.It[1]:=s0;
            s0:=List.It[i-1];
            s0[1]:=char(ord(s0[1])+1);
            s1[2]:='l';s1[4]:=' ';
            ProcCmd0(s0,s1);
            List.Del(i);List.Del(i-1);
            typ:=C_plus_A;
            break;
          end;
          inc(i,2);
        end;
        tmp:=typ;
        if tmp=C_minus_A then NegList(tmp);
      end;
      C_div_A: begin
        i:=3;
        while i<=high(List.It) do begin
          s1:=List.It[i];
          if s1[2]='m' then begin
            s0:=List.It[0];
            s0[1]:=char(ord(s0[1])-1);
            s0[2]:=char(ord(s0[2])+$30);
            List.It[0]:=s0;
            s0:=List.It[1];
            s0[2]:='d';s0[3]:='i';s0[4]:='v';
            List.It[1]:=s0;
            s0:=List.It[i-1];
            s0[1]:=char(ord(s0[1])+1);
            s0[2]:=char(ord(s0[2])-8);
            s1[2]:='l';s1[3]:='d';s1[4]:=' ';
            ProcCmd0(s0,s1);
            List.Del(i);List.Del(i-1);
            typ:=C_mul_A;
            break;
          end;
          inc(i,2);
        end;
        tmp:=typ;
        if tmp=C_div_A then InvList(tmp);
      end;
    end;
    i:=0; while i<=high(List.It) do begin
      ProcCmd0(List.It[i],List.It[i+1]);
      inc(i,2);
    end;
    dec(typ,Argument-Variable);
  end;
  s:='   [esi+8*'+Int2Str(high(Vars)+1)+']'+#9+Double2Str(x);
  case typ of
    Constant: begin
      pi_:=pi;
      FreeSP;
      if x=1 then
        ProcCmd0(  #$D9 + #$E8,'fld1')
      else if x=0 then
        ProcCmd0(  #$D9 + #$EE,'fldz')
      else if x=pi_ then
        ProcCmd0(  #$D9 + #$EB,'fldpi')
      else
        ProcCmd2(x,#$DD + #$46,'fld  '+s);
    end;
    Neg_Var:
        ProcCmd0(  #$D9 + #$E0,'fchs');
    C_plus_V:
      if x<>0 then
        ProcCmd2(x,#$DC + #$46,'fadd '+s);
    C_minus_V:
      if x=0 then
        ProcCmd0(  #$D9 + #$E0,'fchs')
      else
        ProcCmd2(x,#$DC + #$6E,'fsubr'+s);
    C_mul_V:
      if x=-1 then
        ProcCmd0(  #$D9 + #$E0,'fchs')
      else if x<>1 then
        ProcCmd2(x,#$DC + #$4E,'fmul '+s);
    C_div_V:
        ProcCmd2(x,#$DC + #$7E,'fdivr'+s);
  end;
end;

procedure THIFastMathParse.NegList(var typ:byte);
var i:integer;
    s:string;
begin
  if typ=C_minus_A then typ:=C_plus_A
  else typ:=C_minus_A;
  i:=2;while i<=high(List.It) do begin
    s:=List.It[i];
    s[2] := char(ord(s[2])xor $20);
    List.It[i]:=s;
    inc(i);
    s:=List.It[i];
    if s[2]='a' then begin
      s[2]:='s'; s[3]:='u'; s[4]:='b';
    end
    else begin
      s[2]:='a'; s[3]:='d'; s[4]:='d';
    end;
    List.It[i]:=s;
    inc(i);
  end;
end;

procedure THIFastMathParse.InvList(var typ:byte);
var i:integer;
    s:string;
begin
  if typ=C_div_A then typ:=C_mul_A
  else typ:=C_div_A;
  i:=2;while i<=high(List.It) do begin
    s:=List.It[i];
    s[2] := char(ord(s[2])xor $38);
    List.It[i]:=s;
    inc(i);
    s:=List.It[i];
    if s[2]='m' then begin
      s[2]:='d'; s[3]:='i'; s[4]:='v';
    end
    else begin
      s[2]:='m'; s[3]:='u'; s[4]:='l';
    end;
    List.It[i]:=s;
    inc(i);
  end;
end;

procedure THIFastMathParse.FreeSP;
var i:integer;
begin
  inc(SPmax);
  if SPmax>SPmin+8 then begin
    inc(SPmin);
    if SPmin>high(SPind) then begin
      i:=high(Vars)+1;
      SetLength(Vars,i+1);
      SetLength(SPind,SPmin+1);
      SPind[SPmin]:=i;
    end
    else i:=SPind[SPmin];
    //ProcCmd0(    #$DD + #$C7,'ffree   ST(7)');
    ProcCmd0(    #$D9 + #$F6,'fdecstp');
    ProcCmd1(8*i,#$DD + #$5E,'fstp    [esi+8*'+Int2Str(i)+']'#9'Push FPU');
  end;
end;

procedure THIFastMathParse.ProcCmd2(var x:real;cmd,mnem:string);
var i:integer;
begin
  i:=high(Vars)+1;
  SetLength(Vars,i+1);
  Vars[i]:=x;
  ProcCmd1(i*8,cmd,mnem);
end;

procedure THIFastMathParse.ProcCmd1(i:integer;cmd,mnem:string);
var s:string[4];
begin
  SetLength(s,1);
  integer(pointer(@s[1])^):=i;
  if i=0 then begin
    SetLength(s,0);
    i:=Length(cmd);
    cmd[i]:=char(ord(cmd[i])-$40);
  end
  else if i>=128 then begin
    SetLength(s,4);
    i:=Length(cmd);
    cmd[i]:=char(ord(cmd[i])+$40);
  end;
  ProcCmd0(cmd+s,mnem);
end;

procedure THIFastMathParse.ProcCmd0(cmd,mnem:string);
var i:integer;
    b:byte;
    s:string;
begin
  Proc := Proc + cmd;
  s:='';
  for i:=1 to Length(cmd) do begin
    b:=ord(cmd[i]) div 16 + 48;
    if b>=58 then inc(b,7);
    s:=s+char(b);
    b:=ord(cmd[i]) mod 16 + 48;
    if b>=58 then inc(b,7);
    s:=s+char(b);
  end;
  while Length(s)<8 do s:=s+' ';
  _hi_OnEvent(_event_onDebugStrings,s+#9+mnem);
end;

procedure THIFastMathParse.ListCmd1(var L:ListArr;i:integer;cmd,mnem:string);
var s:string[4];
begin
  SetLength(s,1);
  integer(pointer(@s[1])^):=i;
  if i=0 then begin
    SetLength(s,0);
    i:=Length(cmd);
    cmd[i]:=char(ord(cmd[i])-$40);
  end
  else if i>=128 then begin
    SetLength(s,4);
    i:=Length(cmd);
    cmd[i]:=char(ord(cmd[i])+$40);
  end;
  L.Put(cmd+s);
  L.Add(mnem);
end;

procedure THIFastMathParse.GetToken;
begin
  Token := '';
  TokType := 0;
  while Line[LPos] in [' ',#9] do inc(LPos);
  case Line[LPos] of
    'a'..'z','A'..'Z','_':
      begin
        repeat
          Token := Token + Line[LPos];
          inc(LPos);
        until not(Line[LPos] in ['a'..'z','A'..'Z','_','0'..'9']);
        Token := LowerCase(Token);
        TokType := TokName;
      end;
    '.','0'..'9':
      begin
        while Line[LPos] in ['0'..'9'] do begin
          Token := Token + Line[LPos];
          inc(LPos)
        end;
        TokType := TokNumber;
        if Line[LPos]='.' then
         begin
          Token := Token + '.';
          inc(LPos);
          while Line[LPos] in ['0'..'9'] do begin
            Token := Token + Line[LPos];
            inc(LPos);
          end;
          if Token='.' then begin
            TokType := 0; exit
          end;
          TokType := TokReal;
        end;
        while Line[LPos] in [' ',#9] do inc(LPos);
        if Line[LPos] in ['e','E'] then begin
          Token := Token + Line[LPos];
          inc(LPos);
          while Line[LPos] in [' ',#9] do inc(LPos);
          if Line[LPos] in ['+','-'] then begin
            Token := Token + Line[LPos];
            inc(LPos);
            while Line[LPos] in [' ',#9] do inc(LPos);
          end;
          if not(Line[LPos] in ['0'..'9']) then begin
            TokType := 0; exit
          end;
          while Line[LPos] in ['0'..'9'] do begin
            Token := Token + Line[LPos];
            inc(LPos);
          end;
          TokType := TokReal;
        end
      end;
    {
    '''': while Line[LPos] <> #1 do inc(LPos);
    '"':
      begin
        inc(LPos);
        while (Line[LPos] <> '"')and(Line[LPos] <> #1) do
         begin
          Token := Token + Line[LPos];
          inc(LPos);
         end;
        TokType := TokString;
        if Line[LPos] = #1 then
          AddError('Lexem " not found',true)
        else inc(LPos);
      end;
    '.':
      if Line[LPos+1] = '.' then
      begin
         Token := '..';
         TokType := TokSymbol;
         inc(LPos,2);
      end
      else AddError('Operator . don''t support');
    }
    '(',')','%',','{,'[',']','=',':',';'}:
      begin Token := Line[LPos]; inc(LPos); TokType := TokSymbol end;
    '+','-','/','*','^':
      begin
        Token := Line[LPos];
        inc(LPos);
        while Line[LPos] in [' ',#9] do inc(LPos);
        if not(Line[LPos] in ['+','-']) then TokType := TokMath
        else Token := '';
      end;
    {
    '>','<':
      begin
        Token := Line[LPos];
        inc(LPos);
        if Line[LPos] = '=' then
        begin
          Token := Token + Line[LPos];
          inc(LPos);
        end
        else if ( Token = '<' )and(Line[LPos] = '>')then
        begin
          Token := '<>';
          inc(LPos);
        end;
        TokType := TokMath;
      end;
    }
    #1: TokType := TokEnd;
  end;
end;

end.
