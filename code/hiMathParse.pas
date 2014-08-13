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
    Token,rToken:string;
    TokType:byte;
    Line:string;
    EPos,ELen,LPos:smallint;
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
    procedure Parse;

    procedure Level0(var x:real); // Логические операторы (and or xor)
    procedure Level1(var x:real); // Логический not, и сравнение (< > <= >= = <>))
    procedure Level2(var x:real); // Сложение/Вычитание
    procedure Level3(var x:real); // Умножение/Деление
    procedure Level4(var x:real); // Возведение в степень
    procedure Level5(var x:real); // Бинарные операторы (& | ! << >>)
    procedure Level6(var x:real); // Бин.оператор (~)Атомы (read, const, func), или рекурсия ()
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
    procedure _var_LenErr(var _Data:TData; Index:word);
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
  TokErr    = 0;
  TokName   = 1;
  TokReal   = 2;
  TokNumber = 3;
  TokSymbol = 4;
  TokHex    = 5;
  TokArg    = 6;
  TokCmp    = 7;
  TokBin    = 8;

  digE      = 2.718281828459045; //may be defined in Delphi
  serr      = 'MathParse Exception';
  s:array[0..1]of string =
    ('Ошибка синтаксиса в элементе MathParser'#13#10'Обнаружена в строке:позиции - '
    ,'Ошибка вычисления в элементе MathParser'#13#10'Обнаружена в строке:позиции - ');

function THIMathParse.CalcErrPos;
var nStr, nPos, i:integer;
begin
  nStr := 1; nPos := 1; i := 0;
  while i < Value do begin
    inc(nPos);
    if Line[i+1] = #13 then begin
      inc(nStr);
      nPos := 1;
      if Line[i+2] = #10 then inc(i);
    end;
    inc(i);
  end;
  Result := int2str(nStr) + ':' + int2str(nPos);
end;

procedure THIMathParse.SetLine;
begin
  Line := Value+#1; // На случай Value=nil... под FPC
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
  ELen:= 0;
  EPos:=-1;
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
  ELen:= 0;
  EPos:=-1;
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
begin
  dt := _Data; Parse;
  if Err < 0 then begin
    if _prop_ResultType<>0 then _hi_CreateEvent(_Data,@_event_onResult,FResult)
    else _hi_CreateEvent(_Data,@_event_onResult,integer(round(FResult)));
  end else begin
    if assigned(_event_onError.Event) then
      _hi_CreateEvent(_Data,@_event_onError,Err)
    else _debug(s[Err]+ CalcErrPos(EPos));
  end;
end;//_work_doCalc

procedure THIMathParse._var_reCalc;
begin
  dt := _Data; Parse;
  if Err < 0 then begin
    if _prop_ResultType<>0 then dtReal(_Data,FResult)
    else dtInteger(_Data, round(FResult));
  end else begin
    dtNULL(_Data);
    _Data.idata := Err;
    _Data.sdata := serr;
  end;
end;

procedure THIMathParse.Parse;
var i:integer; x:real;
begin
  for i:=0 to FDataCount-1 do Flags[i] := false;
  if Err>=0 then FResult:=FDefault;
  LPos := 1; Err := -1;
  {$ifndef F_P}try{$endif}
    Level0(x);
    {$ifdef F_P}if Err<0 then{$endif}
    if EPos+1<>length(Line) then Err:=0;
  {$ifndef F_P}
  except on E:Exception do
    case E.Code of
      e_Custom: Err:=0;//SyntaxError
      else      Err:=1;//CalcError
    end;//case
  end;//except
  {$endif}
  if Err >= 0 then exit;
  ELen:= 0; EPos:=-1; FResult := x;
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
  else if _prop_ResultType<>0 then dtReal(_Data,FResult)
  else dtInteger(_Data,Round(FResult));
end;

procedure THIMathParse._var_PosErr;
begin
  dtInteger(_Data,EPos);
end;

procedure THIMathParse._var_LenErr;
begin
  dtInteger(_Data,ELen);
end;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PARSE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

procedure THIMathParse.GetToken;
begin
  Token := ''; TokType := 0;
  while Line[LPos] in [' ',#9,#10,#13] do inc(LPos);
  EPos := LPos-1; ELen := 1; // Длина "незвестного символа" пусть =1
  case Line[LPos] of
    'a'..'z','A'..'Z','_','а'..'я','А'..'Я':
      begin
        repeat
          Token := Token + Line[LPos]; inc(LPos);
        until not(Line[LPos] in ['a'..'z','A'..'Z','_','а'..'я','А'..'Я','0'..'9']);
        TokType := TokName;
      end;
    '.','$','0'..'9':
      if (Line[LPos]='$')or((Line[LPos]='0')and(Line[LPos+1]='x')) then begin
      // Это ХЕКС
        if Line[LPos]<>'$' then inc(LPos);
        inc(LPos);
        while Line[LPos] in ['0'..'9','a'..'f','A'..'F'] do begin
          Token := Token + Line[LPos]; inc(LPos)
        end;
        if Token<>'' then TokType := TokHex;
      end else begin
        // Тест на целое
        while Line[LPos] in ['0'..'9'] do begin
          Token := Token + Line[LPos]; inc(LPos)
        end;
        if Line[LPos]='.' then begin
        // Таки есть дробная честь
          Token := Token + '.'; inc(LPos);
          while Line[LPos] in ['0'..'9'] do begin
            Token := Token + Line[LPos]; inc(LPos);
          end;
          if Token<>'.' then TokType := TokReal;
        end else TokType := TokNumber;
        // Тест на степень десятки
        if (TokType<>0)and(Line[LPos] in ['e','E']) then begin
          Token := Token + Line[LPos]; inc(LPos);
          if Line[LPos] in ['+','-'] then begin
            Token := Token + Line[LPos]; inc(LPos);
          end;
          TokType := 0; // Откаты не предусмотрены
          if Line[LPos] in ['0'..'9'] then begin
            TokType := TokReal;
            repeat Token := Token + Line[LPos]; inc(LPos)
            until not(Line[LPos] in ['0'..'9']);
          end;
        end;
      end;
    '%': // Входные пины
      begin
        inc(LPos);
        while Line[LPos] in ['0'..'9'] do begin
          Token := Token + Line[LPos]; inc(LPos);
        end;
        if Token<>'' then TokType := TokArg;
      end;
    '(',')',',','[',']','+','-','/','*','^','~':
      begin
        Token := Line[LPos]; inc(LPos); TokType := TokSymbol;
      end;
    '&','|','!':
      begin
        Token := Line[LPos]; inc(LPos); TokType := TokBin;
      end;
    '<','>','=':
      begin
        Token := Line[LPos]; inc(LPos);
        TokType := TokCmp;
        if Token = '<' then begin
          if Line[LPos] = '=' then begin
            Token := '{'; inc(LPos);
          end else
          if Line[LPos] = '>' then begin
            Token := '#'; inc(LPos);
          end else
          if Line[LPos] = '<' then begin
            Token := Token + Line[LPos]; inc(LPos);
            TokType := TokBin;
          end
        end else
        if Token = '>' then begin
          if Line[LPos] = '=' then begin
            Token := '}'; inc(LPos);
          end else
          if Line[LPos] = '>' then begin
            Token := Token + Line[LPos]; inc(LPos);
            TokType := TokBin;
          end
        end;
      end;
    else exit; // ELen=1, Token=''
  end;
  rToken := Token; // Резервная копия оригинала
  Token := LowerCase(Token);
  ELen := LPos-EPos-1;
end;

procedure THIMathParse.Level0;   // Логические операторы (and or xor)
var op:char; x2:real;
begin // Токена еще нету
  Level1(x);{$ifdef F_P}if Err>=0 then exit;{$endif}
  while (Token = 'and')or(Token = 'or')or(Token = 'xor')do begin
    op := Token[1];
    Level1(x2);{$ifdef F_P}if Err>=0 then exit;{$endif}
    case op of
      'a': x := ord((x<>0)and(x2<>0));
      'o': x := ord((x<>0) or(x2<>0));
      'x': x := ord((x<>0)xor(x2<>0));
    end;
  end;
end;

procedure THIMathParse.Level1;  // Логический not, и сравнение (< > <= >= = <>)
var n:boolean; op:char; x2,save:real;
begin // Токена еще нету
  GetToken; n := Token = 'not';
  if n then GetToken;
  Level2(x);{$ifdef F_P}if Err>=0 then exit;{$endif}
  if TokType=TokCmp then begin
    save := x; x := 1;
    repeat
      op := Token[1]; GetToken;
      Level2(x2);{$ifdef F_P}if Err>=0 then exit;{$endif}
      case op of
        '<': x :=  x * ord(save< x2);
        '>': x :=  x * ord(save> x2);
        '{': x :=  x * ord(save<=x2);
        '}': x :=  x * ord(save>=x2);
        '=': x :=  x * ord(save= x2);
        '#': x :=  x * ord(save<>x2);
      end;
      save := x2;
    until TokType<>TokCmp;
  end;
  if n then x := ord(x=0);
end;

procedure THIMathParse.Level2;  // Сложение/Вычитание
var op:char; x2:real;
begin // Токен уже есть
  op := ' ';
  if (Token = '-')or(Token = '+') then begin
    op := Token[1]; GetToken;
  end;
  Level3(x);{$ifdef F_P}if Err>=0 then exit;{$endif}
  if op = '-' then x := -x;
  while (Token = '-')or(Token = '+') do begin
    op := Token[1]; GetToken;
    Level3(x2);{$ifdef F_P}if Err>=0 then exit;{$endif}
    if op = '+' then x := x + x2
    else x := x - x2;
  end;
end;

procedure THIMathParse.Level3;   // Умножение/Деление
var op:char; x2:real;
begin // Токен уже есть
  Level4(x);{$ifdef F_P}if Err>=0 then exit;{$endif}
  while (Token='/')or(Token='*')or(Token='div')or(Token='mod')do begin
    op :=  Token[1]; GetToken;
    Level4(x2);{$ifdef F_P}if Err>=0 then exit;{$endif}
    case op of
      '*': x := x*x2;
      '/': {$ifdef F_P}if x2 = 0      then begin Err:=1;exit end else {$endif}
           x := x/x2;
      'd': {$ifdef F_P}if round(x2)=0 then begin Err:=1;exit end else {$endif}
           x := round(x) div round(x2);
      else {$ifdef F_P}if round(x2)=0 then begin Err:=1;exit end else {$endif}
           x := round(x) mod round(x2);
    end;
  end;
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

procedure THIMathParse.Level4;   // Возведение в степень
var x2:real;
begin // Токен уже есть
  Level5(x);{$ifdef F_P}if Err>=0 then exit;{$endif}
  while (Token = '^') do begin
    GetToken; Level5(x2);
    {$ifdef F_P}if Err>=0 then exit;
    if (round(x2)<>x2)and(x<=0) then begin Err:=1;exit end;{$endif}
    Power(x,x2);
  end;
end;

procedure THIMathParse.Level5;   //  Бинарные операторы (& | ! << >>)
var op:char; x2:real;
begin // Токен уже есть
  Level6(x);{$ifdef F_P}if Err>=0 then exit;{$endif}
  while TokType = TokBin do begin
    op := Token[1]; GetToken;
    Level6(x2);{$ifdef F_P}if Err>=0 then exit;{$endif}
    case op of
      '&': x := round(x)and round(x2);
      '|': x := round(x) or round(x2);
      '!': x := round(x)xor round(x2);
      '<': x := round(x)shl round(x2);
      '>': x := round(x)shr round(x2);
    end;
  end;
end;

function _IsBREAK(var dt:TData):boolean;
begin
  Result := (dt.data_type=data_break)or(dt.data_type=data_null);
end;

procedure THIMathParse.Level6; // Бин.инверсия (~), атомы (read, const, func), или рекурсия ()
var i,j:integer; Y:real;
    inv,noToken:boolean; //следующий токен еще НЕ ВЫБРАН
    Fd,FItem:TData;
    tmp:PData;
    Arr:PArray;
    Mtx:PMatrix;
begin // Токен уже есть
  inv := Token='~'; if inv then GetToken; // Бин.инверсия
  noToken := true;
  if TokType=TokArg then begin // Имя пина
    i := Str2Int(Token)-1;
    if i=-1 then x := FResult else // Предыдущий результат
    if (i<FDataCount)and(i<>(_prop_ExtNames-1)) then begin
      GetToken;
      if Token = '[' then begin
      // Однако матрица или массив (по количеству аргументов)
        Level0(Y);{$ifdef F_P}if Err>=0 then exit;{$endif}
        if Token <> ',' then begin
        // Таки это массив
          Arr := ReadArray(self.X[i]);
          if Arr=nil then
            {$ifndef F_P}raise Exception.Create(e_Math_InvalidArgument,'');
            {$else} begin Err := 1; exit; end; {$endif}
          if Token <> ']' then
            {$ifndef F_P}raise Exception.Create(e_Custom,'');
            {$else} begin Err := 0; exit; end; {$endif}
          dtReal(Fd,Y);
          if not Arr._Get(Fd,FItem) then
            {$ifndef F_P}raise Exception.Create(e_Math_InvalidArgument,'');
            {$else} begin Err := 1; exit; end; {$endif}
          x := ToReal(FItem);
        end
        else begin
        // Таки это матрица
          Mtx := ReadMatrix(self.X[i]);
          if Mtx=nil then
            {$ifndef F_P}raise Exception.Create(e_Math_InvalidArgument,'');
            {$else} begin Err := 1; exit; end; {$endif}
          Level0(x); {$ifdef F_P}if Err>=0 then exit;{$endif}
          if Token <> ']' then
            {$ifndef F_P}raise Exception.Create(e_Custom,'');
            {$else} begin Err := 0; exit; end; {$endif}
          Fd:= Mtx._Get(round(Y),round(x));
          if _IsNull(Fd) then
            {$ifndef F_P}raise Exception.Create(e_Math_InvalidArgument,'');
            {$else} begin Err := 1; exit; end; {$endif}
          x := ToReal(Fd);
        end
      end else
      if Token = '(' then begin
      // Однако функция (пока одного аргумента)
        Level0(Y);{$ifdef F_P}if Err>=0 then exit;{$endif}
        dtReal(Fd,Y);
        TRY
          while Token = ',' do begin  // Функция нескольких аргументов
            Level0(Y);{$ifdef F_P}if Err>=0 then exit;{$endif}
            dtReal(FItem,Y);
            AddMTData(@Fd, @FItem, tmp);
          end;
          FItem := Fd;
          if Token <> ')' then
            {$ifndef F_P}raise Exception.Create(e_Custom,'');
            {$else} begin Err := 0; exit; end; {$endif}
          _ReadData(FItem,self.X[i]);
        FINALLY
          FreeData(@Fd);
        END;
        if _IsBREAK(FItem) then // Пин: либо тупо не подключен, либо - NULL
          {$ifndef F_P}raise Exception.Create(e_Math_InvalidArgument,'');
          {$else} begin Err := 1; exit; end; {$endif}
        x := ToReal(FItem);
      end
      else begin
      // Однако просто внешний аргумент. И все
        if not Flags[i] then begin
          Fd := ReadData(dt,self.X[i]);
          if _IsNULL(Fd) and (Fd.sdata=serr) then begin
            {$ifdef F_P}Err := Fd.idata; exit;
            {$else}if Fd.idata>0 then raise Exception.Create(e_Math_InvalidArgument,'')
            else raise Exception.Create(e_Custom,'');
            {$endif}
          end;
          Args[i] := ToReal(Fd); // кэшируем данные для следующего раза
          Flags[i] := true;
        end;
        x := Args[i]; // читаем из кэша
        noToken := false; //следующий токен ВЫБРАН, но неопознан как '[', или'('
      end
    end else // Неправильный номер Пина
      {$ifndef F_P}raise Exception.Create(e_Custom,'');
      {$else} begin Err := 0; exit; end; {$endif}
  end else
  if Token = '(' then begin
    // Скобочная рекурсия
    Level0(x);{$ifdef F_P} if Err>=0 then exit;{$endif}
    if Token <> ')' then
      {$ifndef F_P}raise Exception.Create(e_Custom,'');
      {$else} begin Err := 0; exit; end; {$endif}
  end else
    case TokType of
    TokName: if ReadFunc(x, Token) then begin
      // Встроенные функции - посчитаны, токен - не выбран
        {$ifdef F_P}if Err>=0 then exit;{$endif}
      end else if (_prop_ExtNames>0)and(_prop_ExtNames<=FDataCount) then begin
      // Вот тут и запузырим "внешнее распознавание имени"
        dtString(FItem,rToken);
        Fd := FItem;
        i := EPos; j := ELen; GetToken;
        noToken := Token = '(';
        TRY
          if noToken then begin  // Именованная Функция (пока одного аргумента)
            Level0(Y);{$ifdef F_P} if Err>=0 then exit;{$endif}
            dtReal(FItem,Y);
            AddMTData(@Fd, @FItem, tmp);
            while Token = ',' do begin // Именованная Функция нескольких аргументов
              Level0(Y); {$ifdef F_P} if Err>=0 then exit; {$endif}
              dtReal(FItem,Y);
              AddMTData(@Fd, @FItem, tmp);
            end;
            FItem := Fd;
            if Token <> ')' then
              {$ifndef F_P}raise Exception.Create(e_Custom,'');
              {$else} begin Err := 0; exit; end; {$endif}
          end;
          _ReadData(FItem,self.X[_prop_ExtNames-1]);
        FINALLY
          FreeData(@Fd);
        END;
        if _IsBREAK(FItem) then begin // Пин: либо тупо не подключен, либо - NULL
          EPos := i; ELen := j; // Типа - неизвестное имя, ДО аргументов
          {$ifndef F_P}raise Exception.Create(e_Custom,'');
          {$else} Err := 0; exit; {$endif}
        end;
        x := ToReal(FItem);
      end else // Имя вообще неопознано
        {$ifndef F_P}raise Exception.Create(e_Custom,'');
        {$else} begin Err := 0; exit; end; {$endif}
    // Просто числа в разных форматах
    TokReal,TokNumber: x := Str2Double(Token);
    TokHex: x:= Hex2Int(Token);
    else // Вообще, не понять чего !!!
      {$ifndef F_P}raise Exception.Create(e_Custom,'');
      {$else} begin Err := 0; exit; end; {$endif}
    end;
  if noToken then GetToken;
  if inv then x := not round(x); // Бин.инверсия
end;

function Tan(const X: Extended): Extended;
//  Tan := Sin(X) / Cos(X)
asm
        FLD     X
        FPTAN
        FSTP    ST(0) // FPTAN pushes 1.0 after result
        FWAIT
end;

function CoTan(const X: Extended): Extended;
// CoTan := Cos(X) / Sin(X)
asm
        FLD     X
        FSINCOS
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

const FuncNames:array[1..40] of pchar = (
  'cos','sin','tg','ctg','arccos','arcsin','arctg','arcctg',       // 1..8
  'ch','sh','th','cth','arcch','arcsh','arcth','arccth',           // 9..16
  'lg','ln','exp','sqr','sqrt','abs','sign','odd','even',          //17..25
  'frac','trunc','round','floor','ceil','log','atan','min','max',  //26..34
  'and','or','xor','not','div','mod');  // KeyWords

function THIMathParse.ReadFunc;
var y:real; I:integer;
begin
  Result := True;
  if f = 'pi' then begin  x := pi;   exit end else
  if f = 'e'  then begin  x := digE; exit end;
  Result := false;
  for I := 1 to length(FuncNames) do
    if FuncNames[I]=f then begin Result := True;  break end;
  if not Result then exit;
  if I>34 then // Не допустим! Использовать служебные слова в качестве имен
    {$ifndef F_P}raise Exception.Create(e_Custom,'');
    {$else} begin Err := 0; exit; end; {$endif}
  GetToken;
  if Token <> '(' then
    {$ifndef F_P}raise Exception.Create(e_Custom,'');
    {$else} begin Err := 0; exit; end; {$endif}
  Level0(x);{$ifdef F_P} if Err>=0 then exit;{$endif}
  if I >= 26 then begin // Функции двух аргументов
    if Token = ',' then begin
      Level0(y);{$ifdef F_P}if Err>=0 then exit;{$endif}
    end else if I < 31 then y := 1 // frac, trunc, round, floor, ceil
    else
      {$ifndef F_P}raise Exception.Create(e_Custom,'');
      {$else} begin Err := 0; exit; end; {$endif}
  // Считаем функции от двух аргументов
    if I < 31 then begin // frac, trunc, round, floor, ceil
      if y<>0 then begin // y=0 надо обрабатывать, хотя бы под FPC
        x := x/y;
        case I of
          26: x := frac (x);
          27: x := trunc(x);
          28: x := round(x);
          29: if frac(x)<0 then x := trunc(x)-1 //floor
              else x := trunc(x);
          30: if frac(x)>0 then x := trunc(x)+1 //ceil
              else x := trunc(x);
        end;
        x := x*y;
      end else if I=26 then x := 0; // frac(x,0)=0, а остальное =x (при y=0)
    end else begin
      case I of
        31: {$ifdef F_P}if (x<=0)or(y<=0) then begin Err:=1;exit;end else{$endif}
            x := LogN(x,y);
        32: x := ArcTan2(x,y)/AngleMode;
        33: if x > y then x := y; // min
        34: if x < y then x := y; // max
      end;
  // Проверяем (и обрабатываем) множественные аргументы для min, max
      if I >= 33 then while Token = ',' do begin // Много аргументов
        Level0(y);{$ifdef F_P}if Err>=0 then exit;{$endif}
        if I=33 then begin
          if x > y then x := y; // min
        end else
          if x < y then x := y; // max
      end;
    end;
  end else case I of
  // Функции одного аргумента
    1:  x := cos(x*AngleMode);
    2:  x := sin(x*AngleMode);
    3:  {$ifdef F_P}if cos(x*AngleMode)=0 then begin Err:=1;exit;end else{$endif}
        x := Tan(x*AngleMode);
    4:  {$ifdef F_P}if sin(x*AngleMode)=0 then begin Err:=1;exit;end else{$endif}
        x := CoTan(x*AngleMode);
    5:  {$ifdef F_P}if (x>1)or(x<-1) then begin Err:=1;exit;end else{$endif}
        x := ArcTan2(sqrt(1-x*x),x)/AngleMode;
    6:  {$ifdef F_P}if (x>1)or(x<-1) then begin Err:=1;exit;end else{$endif}
        x := ArcTan2(x,sqrt(1-x*x))/AngleMode;
    7:  x := ArcTan2(x,1)/AngleMode;
    8:  x := ArcTan2(1,x)/AngleMode;
    9:  begin y := exp(x); x := (y+1/y)/2 end;
    10: begin y := exp(x); x := (y-1/y)/2 end;
    11: begin y := exp(2*x); x := (y-1)/(y+1) end;
    12: {$ifdef F_P}if x=0 then begin Err:=1;exit;end else{$endif}
        begin y := exp(2*x); x := (y+1)/(y-1) end;
    13: {$ifdef F_P}if x<1 then begin Err:=1;exit;end else{$endif}
        x := LogN(digE,x+sqrt(x*x-1));
    14: x := LogN(digE,x+sqrt(x*x+1));
    15: {$ifdef F_P}if (x>=1)or(x<=-1) then begin Err:=1;exit;end else{$endif}
        x := LogN(digE,(1+x)/(1-x))/2;
    16: {$ifdef F_P}if (x<=1)and(x>=-1)then begin Err:=1;exit;end else{$endif}
        x := LogN(digE,(x+1)/(x-1))/2;
    17: {$ifdef F_P}if x<=0 then begin Err:=1;exit;end else{$endif}
        x := LogN(10,x);
    18: {$ifdef F_P}if x<=0 then begin Err:=1;exit;end else{$endif}
        x := LogN(digE,x);
    19: x := exp(x);
    20: x := sqr(x);
    21: {$ifdef F_P}if x<0 then begin Err:=1;exit;end else{$endif}
        x := sqrt(x);
    22: if x<0 then x := -x;
    23: if x<0 then x := -1 else if x>0 then x:=1;
    24: x := ord(odd(round(x)));     {odd}
    25: x := ord(not odd(round(x))); {even}
  end;
  if Token <> ')' then
    {$ifndef F_P}raise Exception.Create(e_Custom,'');
    {$else} begin Err := 0; exit; end; {$endif}
end;

end.
