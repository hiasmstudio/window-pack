unit hiMathParse;

interface

{$I share.inc}

uses Kol,
     {$ifndef F_P}err,{$endif}
     Share,Debug;

type
  THIMathParse = class(TDebug)
   private
    FDataCount:integer;
    Token:string;
    TokType:byte;
    Line:string;
    SafeLine:string;
    LPos:smallint;
    FResult:real;
    FDefault:real;
    AngleMode:real;
    Err:smallint;
    dt:TData;
    Args:array of real;
    flags:array of boolean;

    procedure SetCount(Value:integer);
    procedure SetLine(Value:string);
    procedure SetDefault(Value:real);
    procedure SetAngleMode(Value:byte);
    function CalcErrPos(Value:integer): string;

    procedure GetToken;

    procedure Level0(var x:real);
    procedure Level1a(var x:real); // < > <= >= =
    procedure Level1b(var x:real); // + -
    procedure Level2(var x:real); // / *
    procedure Level3(var x:real); // ^
    procedure Level4(var x:real); // unar + - not
    procedure Level5(var x:real); // and or xor
    procedure Level6(var x:real); // ( function
    function ReadFunc(var x:real; f:string):boolean;
   public
    X:array of THI_Event;
    _event_onError:THI_Event;
    _event_onResult:THI_Event;
    _prop_ResultType:byte;
    _prop_ExtNames:integer;

    procedure _work_doCalc(var _Data:TData; Index:word);
    procedure _work_doMathStr(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doAngleMode(var _Data:TData; Index:word);
    procedure _work_doDefault(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
    procedure _var_reCalc(var _Data:TData; Index:word);
    procedure _var_PosErr(var _Data:TData; Index:word);
    property _prop_DataCount:integer write SetCount;
    property _prop_MathStr:string write SetLine;
    property _prop_Default:real write SetDefault;
    property _prop_AngleMode:byte write SetAngleMode;
  end;

function IntPower(const Base:Extended; const Exponent:Integer):Extended;
function ArcTan2(const Y,X:Extended):Extended;
function LogN(const Base,X:Extended):Extended;
function Tan(const X: Extended): Extended;

implementation

const
  TokName   = 1;
  TokReal   = 2;
  TokNumber = 3;
  TokSymbol = 4;
  TokMath   = 5;
  TokEnd    = 6;
  TokHex    = 7;
  digE      = 2.718281828459045; //may be defined in Delphi
  serr      = 'MathParse Exception';
  s:array[0..1]of string = ('Ошибка синтаксиса в элементе MathParser'#13#10'Обнаружена в позиции '
                           ,'Ошибка вычисления в элементе MathParser'#13#10'Обнаружена в позиции ');

function THIMathParse.CalcErrPos;
var
  ListLine: PStrListEx;
  i: integer;
  s: string;
begin
  Result := '0:1';
  ListLine := NewStrListEx;
TRY
  s := SafeLine;
  Replace(s, #1, '');
  ListLine.SetText(s, false);
  if ListLine.Count = 0 then exit;
  i := 0;
  ListLine.Objects[0] := 1;
  if ListLine.Count > 1 then
    for i := 1 to ListLine.Count - 1 do
    begin
      ListLine.Objects[i] := Length(ListLine.Items[i - 1]) + integer(ListLine.Objects[i - 1]);
      if Value < integer(ListLine.Objects[i]) + Length(ListLine.Items[i]) then break;
    end;
  Result := int2str(Value - integer(ListLine.Objects[i]) + 1) + ':' + int2str(i + 1);
FINALLY
  ListLine.free;
END;
end;

procedure THIMathParse.SetLine;
begin
  Line := Value+#1;
  SafeLine := Line;
  Replace(Line, #13#10, '');
end;

procedure THIMathParse.SetAngleMode;
begin
  if Value=0 then AngleMode :=1
  else AngleMode:=pi/180;
end;

procedure THIMathParse.SetDefault;
begin
  FDefault:=Value;
  FResult:=FDefault;
  LPos:=-1;
  Err :=-1;
end;

procedure THIMathParse._work_doDefault;
begin
  SetDefault(ToReal(_Data));
end;

procedure THIMathParse._work_doAngleMode;
begin
  SetAngleMode(ToInteger(_Data));
end;

procedure THIMathParse._work_doClear;
begin
  FResult:=FDefault;
  LPos:=-1;
  Err :=-1;
end;

procedure THIMathParse.SetCount;
begin
  SetLength(X,Value);
  SetLength(Args,Value);
  SetLength(Flags,Value);
  FDataCount := Value;
end;

procedure THIMathParse._work_doCalc;
var Res:integer;
    x:real;
begin
  dt  := _Data;
  Res := 0;
  {$ifndef F_P}
  try
  {$endif}
    Level0(x);
    FResult:=x;
    if _prop_ResultType=0 then
      Res:=Round(FResult);
  {$ifndef F_P}
  except on E:Exception do
    case E.Code of
      e_Custom: Err:=0;//SyntaxError
      else      Err:=1;//CalcError
    end;//case
  end;//except
  {$endif}
  if Err < 0 then begin
    LPos:=-1;
    if _prop_ResultType=0 then _hi_CreateEvent(_Data,@_event_onResult,Res)
    else _hi_CreateEvent(_Data,@_event_onResult,FResult)
  end else begin
    dec(LPos);
    if assigned(_event_onError.Event) then
      _hi_CreateEvent(_Data,@_event_onError,Err)
//    else _debug(s[Err]+ int2Str(LPos));
    else _debug(s[Err]+ CalcErrPos(LPos));

  end;
end;//_work_doCalc

procedure THIMathParse._var_reCalc;
var Y:real;
begin
  dt := _Data;
  {$ifndef F_P}
  try
  {$endif}
    Level0(Y);
    FResult:=Y;
    if _prop_ResultType=0 then dtInteger(_Data,Round(FResult))
    else dtReal(_Data,Y);
    LPos:=-1;
  {$ifndef F_P}
  except on E:Exception do
    case E.Code of
      e_Custom: Err:=0;//SyntaxError
      else      Err:=1;//CalcError
    end;//case
  end;
  {$endif}
  if Err>=0 then begin
    dtNULL(_Data);
    _Data.idata := Err;
    _Data.sdata := serr;
   end
  else dec(LPos);
end;

procedure THIMathParse._work_doMathStr;
begin
  if _IsStr(_Data) then _prop_MathStr := ToString(_Data);
end;

procedure THIMathParse._var_Result;
begin
  if Err>=0 then begin
    dtNULL(_Data);
    _Data.idata := Err;
    _Data.sdata := serr;
   end
  else if _prop_ResultType = 0 then dtInteger(_Data,Round(FResult))
  else dtReal(_Data,FResult);
end;

procedure THIMathParse._var_PosErr;
begin
  dtInteger(_Data,LPos);
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PARSE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

procedure THIMathParse.GetToken;
begin
   Token := '';
   TokType := 0;
   while Line[LPos] in [' ',#9] do inc(LPos);
   case Line[LPos] of
     'a'..'z','A'..'Z','_','а'..'я','А'..'Я':
       begin
         repeat
           Token := Token + Line[LPos];
           inc(LPos);
         until not(Line[LPos] in ['a'..'z','A'..'Z','_','а'..'я','А'..'Я','0'..'9']);
         //Token := LowerCase(Token);
         TokType := TokName;
       end;
     '.','$','0'..'9':
       begin
         if (Line[LPos]='$')or((Line[LPos]='0')and(Line[LPos+1]='x')) then
          begin
           if Line[LPos]<>'$' then inc(LPos);
           inc(LPos);
           while Line[LPos] in ['0'..'9','a'..'f','A'..'F'] do begin
             Token := Token + Line[LPos];
             inc(LPos)
            end;
           if Token<>'' then TokType := TokHex;
           exit;
          end;
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
             TokType := 0; exit end;
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
             TokType := 0; exit end;
           while Line[LPos] in ['0'..'9'] do begin
             Token := Token + Line[LPos];
             inc(LPos);
            end;
           TokType := TokReal;
          end
       end;
     '(',')','%',',','[',']':
        begin Token := Line[LPos]; inc(LPos); TokType := TokSymbol end;
     '<','>','=':
        begin
          Token := Line[LPos];
          inc(LPos);
          TokType := TokSymbol;
          if(Token = '<')and(Line[LPos] = '=') then
          begin
             Token := '{';
             inc(LPos);
          end
          else if(Token = '>')and(Line[LPos] = '=') then
          begin
             Token := '}';
             inc(LPos);
          end
          else if(Token = '<')and(Line[LPos] = '>') then
          begin
             Token := '#';
             inc(LPos);
          end;
        end;
     '+','-','/','*','^':
       begin
        Token := Line[LPos];
        inc(LPos);
        while Line[LPos] in [' ',#9] do inc(LPos);
        if not(Line[LPos] in ['+','-']) then TokType := TokMath
        else Token := '';
       end;
     #1: TokType := TokEnd;
   end;
end;

procedure THIMathParse.Level0; // Формула целиком
var i:integer;
begin
  for i:=0 to FDataCount-1 do Flags[i] := false;
  if LPos>=0 then FResult:=FDefault;
  LPos := 1; Err := -1;
  GetToken; Level1a(x); {$ifdef F_P} if Err>=0 then exit; {$endif}
  if TokType<>TokEnd then
    {$ifndef F_P}
    raise Exception.Create(e_Custom,'');
    {$else}Err:=0;{$endif};
end;

procedure THIMathParse.Level1a;  // Логическое сравнение (если есть)
var
  op:char;
  x2:real;
  b:boolean;
begin
  Level1b(x); {$ifdef F_P} if Err>=0 then exit; {$endif}
  while (Token = '<')or(Token = '>')or(Token = '{')or(Token = '}')or(Token = '=')or(Token = '#') do
   begin
    op := Token[1];
    GetToken; Level1b(x2); {$ifdef F_P} if Err>=0 then exit; {$endif}
    case op of
     '<': b := (x  < x2);
     '>': b := (x  > x2);
     '{': b := (x <= x2);
     '}': b := (x >= x2);
     '=': b := (x  = x2);
     '#': b := (x <> x2);
     else b := false; // нафига - непонятно....
    end;
    x := ord(b);
   end;
end;

procedure THIMathParse.Level1b;  // Сложение
var
  op:char;
  x2:real;
begin
  Level2(x); {$ifdef F_P} if Err>=0 then exit; {$endif}
  while (Token = '-')or(Token = '+') do
   begin
    op := Token[1];
    GetToken; Level2(x2); {$ifdef F_P} if Err>=0 then exit; {$endif}
    if op = '+' then x := x + x2
    else x := x - x2;
   end;
end;

procedure THIMathParse.Level2;   // Умножение
var op:char;
    x2:real;
begin
  Level3(x); {$ifdef F_P} if Err>=0 then exit; {$endif}
  while (Token='/')or(Token='*')or(Token='div')or(Token='mod')do begin
    op :=  Token[1];
    GetToken; Level3(x2); {$ifdef F_P} if Err>=0 then exit; {$endif}
    {$ifdef F_P} Err:=1; {$endif}
    case op of
    '*': x := x*x2;
    '/': {$ifdef F_P} if x2 = 0 then exit else {$endif} x := x/x2;
    'd': {$ifdef F_P} if round(x2) = 0 then exit else {$endif} x := round(x) div round(x2);
    else {$ifdef F_P} if round(x2) = 0 then exit else {$endif} x := round(x) mod round(x2);
    end;
    {$ifdef F_P} Err:=-1; {$endif}
  end
end;

function IntPower(const Base:Extended; const Exponent:Integer):Extended;
asm
        fld1                      { Result := 1 }
        fld     Base
        test    eax,eax
        jg      @@2
        fdivr   ST,ST(1)          { Base := 1 / Base }
        neg     eax
        jnz     @@2
        jmp     @@3
@@1:    fmul    ST,ST             { X := Base * Base }
@@2:    shr     eax,1
        jnc     @@1
        fmul    ST(1),ST          { Result := Result * X }
        jnz     @@1
@@3:    fstp    st                { pop X from FPU stack }
        fwait
end;

procedure Power(var x, Exponent: real);
var y:integer;
begin
  y := Round(Exponent);
  if Exponent=y then x := IntPower(x, y)
  else if (x=0)and(Exponent>0) then x := 0
  else x := Exp(Exponent*Ln(x));
end;

procedure THIMathParse.Level3;   // Возведение в степень
var x2:real;
begin
  Level4(x); {$ifdef F_P} if Err>=0 then exit; {$endif}
  while (Token = '^') do begin
    GetToken;
    Level4(x2);
    {$ifdef F_P}
    if Err>=0 then exit;
    if (Round(x2)<>x2)and(x<=0) then Err:=1
    else{$endif} Power(x,x2);
  end;
end;

procedure THIMathParse.Level4;   // Смена знака
var op:char;
begin
  op := ' ';
  if (Token = '-')or(Token = '+') then begin
    op := Token[1];
    GetToken;
  end;
  Level5(x);
  if op = '-' then x := -x;
end;

procedure THIMathParse.Level5;   // Логические операции
var op:char;
    x2:real;
    b:boolean;
begin
  Level6(x); {$ifdef F_P} if Err>=0 then exit; {$endif}
  while (Token = 'and')or(Token = 'or')or(Token = 'xor')do begin
    op := Token[1];
    GetToken; Level6(x2); {$ifdef F_P} if Err>=0 then exit; {$endif}
    {$ifdef F_P} Err:=1; {$endif}
    case op of
      'a': b := (x <> 0) and (x2 <> 0);
      'o': b := (x <> 0) or (x2 <> 0);
      'x': b := (x <> 0) xor (x2 <> 0);
      else b := false;
    end;
    x := ord(b);
//    if b then
//      x := 1
//    else x := 0;
    {$ifdef F_P} Err:=-1; {$endif}
  end
end;

procedure THIMathParse.Level6;   // Атомы, или рекурсия
var i,j:integer; Y:real;
    Fd,FItem:TData; f:boolean;
    tmp:PData;
    Arr:PArray;
    Mtx:PMatrix;
begin
  if Token = '%' then begin
    // Имя пина, иначе - syntax error
    GetToken;
    if TokType=TokNumber then begin
      i := Str2Int(Token)-1;
      if i=-1 then x := FResult
      else if i<FDataCount then begin
        GetToken;
        if Token = '[' then begin
        // Однако матрица или массив (по количеству аргументов)
          GetToken; Level1a(Y); {$ifdef F_P} if Err>=0 then exit; {$endif}
          if Token <> ',' then begin
          // Таки это массив
            Arr := ReadArray(self.X[i]);
            if Arr=nil then
              {$ifdef F_P}
              begin Err:=1; exit; end;
              {$else}
              raise Exception.Create(e_Math_InvalidArgument,'');
              {$endif}
            if Token <> ']' then
              {$ifdef F_P}
              begin Err:=0; exit; end;
              {$else}
              raise Exception.Create(e_Custom,'');
              {$endif}
            dtReal(Fd,Y);
            if not Arr._Get(Fd,FItem) then
              {$ifdef F_P}
              begin Err:=1; exit; end;
              {$else}
              raise Exception.Create(e_Math_InvalidArgument,'');
              {$endif}
            x := ToReal(FItem);
          end
          else begin
          // Таки это матрица
            Mtx := ReadMatrix(self.X[i]);
            if Mtx=nil then
              {$ifdef F_P}
              begin Err:=1; exit; end;
              {$else}
              raise Exception.Create(e_Math_InvalidArgument,'');
              {$endif}
            GetToken; Level1a(x); {$ifdef F_P} if Err>=0 then exit; {$endif}
            if Token <> ']' then
              {$ifdef F_P}
              begin Err:=0; exit; end;
              {$else}
              raise Exception.Create(e_Custom,'');
              {$endif}
            i:=round(Y);j:=round(x);
            Fd:= Mtx._Get(i,j);
            if _IsNull(Fd) then
              {$ifdef F_P}
              begin Err:=1; exit; end;
              {$else}
              raise Exception.Create(e_Math_InvalidArgument,'');
              {$endif}
            x := ToReal(Fd);
          end
        end
        else if Token = '(' then begin
        // Однако функция (одного аргумента ???)
          GetToken;
          Level1a(Y); {$ifdef F_P} if Err>=0 then exit; {$endif}
          dtReal(Fd,Y);
          TRY
            while Token = ',' do begin  // уже не только одного
              GetToken;
              Level1a(Y); {$ifdef F_P} if Err>=0 then exit; {$endif}
              dtReal(FItem,Y);
              AddMTData(@Fd, @FItem, tmp);
            end;
            FItem := Fd;
            if Token <> ')' then
              {$ifdef F_P} begin Err:=0; exit; end;
              {$else}      raise Exception.Create(e_Custom,''); {$endif}
            _ReadData(FItem,self.X[i]);
          FINALLY
            FreeData(@Fd);
          END;
          if _IsNULL(FItem) then
            {$ifdef F_P} begin Err:=1; exit; end;
            {$else}      raise Exception.Create(e_Math_InvalidArgument,''); {$endif}
          x := ToReal(FItem);
        end
        else begin
        // Однако просто внешний аргумент. И все
          if Flags[i] then x:=Args[i] // читаем из кэша
          else begin
            Fd := ReadData(dt,self.X[i],nil);
            if _IsNULL(Fd) and (Fd.sdata=serr) then
              {$ifdef F_P}begin Err := Fd.idata; exit; end
              {$else}if Fd.idata>0 then raise Exception.Create(e_Math_InvalidArgument,'')
              else raise Exception.Create(e_Custom,'')
              {$endif};
            x := ToReal(Fd);
            // кэшируем данные, чтобы попусту не суетиться еще раз
            Args[i] := x;
            Flags[i] := true;
          end;
          exit;
        end
      end
      else{$ifdef F_P}begin Err:=0;exit;end{$else}raise Exception.Create(e_Custom,''){$endif};
    end
    else  {$ifdef F_P}begin Err:=0;exit;end{$else}raise Exception.Create(e_Custom,''){$endif};
  end
  else if Token = '(' then begin
    // Скобочная рекурсия
    GetToken; Level1a(x); {$ifdef F_P} if Err>=0 then exit; {$endif}
    if Token <> ')' then
      {$ifdef F_P}
      begin Err:=0; exit; end;
      {$else}
      raise Exception.Create(e_Custom,'');
      {$endif}
  end
  else case TokType of
    TokName: begin if ReadFunc(x,LowerCase(Token)) then // Встроенные функции => уже посчитаны
      else begin
        if (_prop_ExtNames>0)and(_prop_ExtNames<=FDataCount) then begin
        // Вот тут и запузырим "внешнее распознавание имени"
          dtString(FItem,Token);
          Fd := FItem;
          GetToken;
          f := Token = '(';
          TRY
            if f then begin
              GetToken;
              Level1a(Y); {$ifdef F_P} if Err>=0 then exit; {$endif}
              dtReal(FItem,Y);
              AddMTData(@Fd, @FItem, tmp);
              while Token = ',' do begin  // уже не одного
                GetToken;
                Level1a(Y); {$ifdef F_P} if Err>=0 then exit; {$endif}
                dtReal(FItem,Y);
                AddMTData(@Fd, @FItem, tmp);
              end;
              FItem := Fd;
              if Token <> ')' then
                {$ifdef F_P} begin Err:=0; exit; end;
                {$else}      raise Exception.Create(e_Custom,''); {$endif}
            end;
            _ReadData(FItem,self.X[_prop_ExtNames-1]);
          FINALLY
            FreeData(@Fd);
          END;
          if _IsNULL(FItem) then
            {$ifdef F_P} begin Err:=0; exit; end;
            {$else}      raise Exception.Create(e_Custom,''); {$endif}
          x := ToReal(FItem); if not f then exit; // О как!
        end else
          {$ifdef F_P} begin Err:=0;if Err>=0 then exit; end;
          {$else}raise Exception.Create(e_Custom,''){$endif};
      end;
    end;
    // Просто числа в разных форматах
    TokReal,TokNumber: x := Str2Double(Token);
    TokHex: x:= Hex2Int(Token);
    else  {$ifdef F_P}begin Err:=0; exit; end{$else}raise Exception.Create(e_Custom,''){$endif};
  end;
  GetToken;
end;

function Tan(const X: Extended): Extended;
//  Tan := Sin(X) / Cos(X)
asm
        FLD    X
        FPTAN
        FSTP   ST(0)      // FPTAN pushes 1.0 after result
        FWAIT
end;

function CoTan(const X: Extended): Extended;
// CoTan := Cos(X) / Sin(X) = 1 / Tan(X)
asm
        FLD   X
        FPTAN
        FDIVRP
        FWAIT
end;

function ArcTan2(const Y, X: Extended): Extended;
asm
        FLD     Y
        FLD     X
        FPATAN
        FWAIT
end;

function LogN(const Base, X: Extended): Extended;
// Log.N(X) := Log.2(X) / Log.2(N)
asm
        FLD1
        FLD     X
        FYL2X
        FLD1
        FLD     Base
        FYL2X
        FDIV
        FWAIT
end;

function THIMathParse.ReadFunc;
const FuncNames:array[1..34] of pchar = (
  'cos','sin','tg','ctg','arccos','arcsin','arctg','arcctg','atan',  //1..9
  'ch','sh','th','cth','arcch','arcsh','arcth','arccth',             //10..17
  'log','lg','ln','exp','sqr','sqrt','abs','sign',                   //18..25
  'round','frac','trunc','floor','ceil','min','max','odd','even');   //26..34
Var y:real; I:integer;
begin
  Result := True;
  if      f = 'pi' then begin  x := pi;   exit end
  else if f = 'e'  then begin  x := digE; exit end;
  Result := false;
  for I := 1 to length(FuncNames) do if FuncNames[I]=f then begin Result := True;  break end;
  if not Result then exit;
  GetToken;
  if Token <> '(' then
    {$ifdef F_P} begin Err:=0; exit; end;
    {$else}raise Exception.Create(e_Custom,'');{$endif}
  GetToken; Level1a(x); {$ifdef F_P} if Err>=0 then exit; {$endif}
  case I of
    1:  x := cos(x*AngleMode);
    2:  x := sin(x*AngleMode);
    3:  {$ifdef F_P}if cos(x*AngleMode)=0 then begin Err:=1;exit;end else{$endif}x := Tan(x*AngleMode);
    4:  {$ifdef F_P}if sin(x*AngleMode)=0 then begin Err:=1;exit;end else{$endif}x := CoTan(x*AngleMode);
    5:  {$ifdef F_P}if (x>1)or(x<-1) then begin Err:=1;exit;end else{$endif}x := ArcTan2(sqrt(1-x*x),x)/AngleMode;
    6:  {$ifdef F_P}if (x>1)or(x<-1) then begin Err:=1;exit;end else{$endif}x := ArcTan2(x,sqrt(1-x*x))/AngleMode;
    7:  x := ArcTan2(x,1)/AngleMode;
    8:  x := ArcTan2(1,x)/AngleMode;
    9:  begin
         if Token<>',' then
           {$ifdef F_P}
           begin Err:=0; exit; end;
           {$else}
           raise Exception.Create(e_Custom,'');
           {$endif}
         GetToken; Level1a(y); {$ifdef F_P} if Err>=0 then exit; {$endif}
         x := ArcTan2(x,y)/AngleMode;
        end;
    10: begin y := exp(x); x := (y+1/y)/2 end;
    11: begin y := exp(x); x := (y-1/y)/2 end;
    12: begin y := exp(2*x); x := (y-1)/(y+1) end;
    13: {$ifdef F_P}if x=0 then begin Err:=1;exit;end else{$endif}begin y := exp(2*x); x := (y+1)/(y-1) end;
    14: {$ifdef F_P}if x<1 then begin Err:=1;exit;end else{$endif}x := LogN(digE,x+sqrt(x*x-1));
    15: x := LogN(digE,x+sqrt(x*x+1));
    16: {$ifdef F_P}if (x>=1)or(x<=-1) then begin Err:=1;exit;end else{$endif}x := LogN(digE,(1+x)/(1-x))/2;
    17: {$ifdef F_P}if (x<=1)and(x>=-1)then begin Err:=1;exit;end else{$endif}x := LogN(digE,(x+1)/(x-1))/2;
    18: begin
          if Token<>',' then
            {$ifdef F_P}
            begin Err:=0; exit; end;
            {$else}
            raise Exception.Create(e_Custom,'');
            {$endif}
          GetToken; Level1a(y); {$ifdef F_P} if Err>=0 then exit; {$endif}
          {$ifdef F_P}if (x<=0)or(y<=0) then begin Err:=1;exit;end;{$endif}
          x := LogN(x,y)
        end;
    19: {$ifdef F_P}if x<=0 then begin Err:=1;exit;end else{$endif}x := LogN(10,x);
    20: {$ifdef F_P}if x<=0 then begin Err:=1;exit;end else{$endif}x := LogN(digE,x);
    21: x := exp(x);
    22: x := sqr(x);
    23: {$ifdef F_P}if x<0 then begin Err:=1;exit;end else{$endif}x := sqrt(x);
    24: if x<0 then x := -x;
    25: if x<0 then x := -1 else if x>0 then x:=1;
    26..30:
        begin
          y:=1;
          if Token=',' then begin
            GetToken; Level1a(y); {$ifdef F_P} if Err>=0 then exit; {$endif}
          end;
          x := x/y;
          case I of
            26:  x := y*round(x);
            27:  x := y*frac (x);
            28:  x := y*trunc(x);
            29:  if frac(x)<0 then x := y*(trunc(x)-1) //floor
                 else x := y*trunc(x);
            else if frac(x)>0 then x := y*(trunc(x)+1) //ceil
                 else x := y*trunc(x);
          end;
        end;
    31,32:
        while Token=',' do begin
          GetToken; Level1a(y); {$ifdef F_P} if Err>=0 then exit; {$endif}
          case I of
            31:  if x>y then x := y;
            else if x<y then x := y;
          end;
        end;
    33: x := ord(odd(round(x)));     {odd}
    34: x := ord(not odd(round(x))); {even}
                         
  end;
  if Token <> ')' then {$ifdef F_P}Err:=0{$else}raise Exception.Create(e_Custom,''){$endif};
end;

end.