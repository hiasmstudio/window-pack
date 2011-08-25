unit hiMath;

interface

uses Kol,Share,Debug;

type
  THIMath = class(TDebug)
   private
    _Err:boolean;
    Res:real;
    Def:real;
    AngleMode:real;

    procedure SetDefault(Value:real);
    procedure SetAngleMode(Value:byte);
   public
    _prop_OpType:byte;
    _prop_Op1:real;
    _prop_Op2:real;
    _prop_ResultType:byte;
    _event_onResult:THI_Event;
    _event_onError:THI_Event;
    _data_Op1:THI_Event;
    _data_Op2:THI_Event;

    procedure _work_doOperation0 (var _Data:TData; Index:word);
    procedure _work_doOperation1 (var _Data:TData; Index:word);
    procedure _work_doOperation2 (var _Data:TData; Index:word);
    procedure _work_doOperation3 (var _Data:TData; Index:word);
    procedure _work_doOperation4 (var _Data:TData; Index:word);
    procedure _work_doOperation5 (var _Data:TData; Index:word);
    procedure _work_doOperation6 (var _Data:TData; Index:word);
    procedure _work_doOperation7 (var _Data:TData; Index:word);
    procedure _work_doOperation8 (var _Data:TData; Index:word);
    procedure _work_doOperation9 (var _Data:TData; Index:word);
    procedure _work_doOperation10(var _Data:TData; Index:word);
    procedure _work_doOperation11(var _Data:TData; Index:word);
    procedure _work_doOperation12(var _Data:TData; Index:word);
    procedure _work_doOperation13(var _Data:TData; Index:word);
    procedure _work_doOperation14(var _Data:TData; Index:word);
    procedure _work_doOperation15(var _Data:TData; Index:word);
    procedure _work_doOperation16(var _Data:TData; Index:word);
    procedure _work_doOperation17(var _Data:TData; Index:word);
    procedure _work_doOperation18(var _Data:TData; Index:word);
    procedure _work_doOperation19(var _Data:TData; Index:word);
    procedure _work_doOperation20(var _Data:TData; Index:word);
    procedure _work_doOperation21(var _Data:TData; Index:word);
    procedure _work_doOperation22(var _Data:TData; Index:word);
    procedure _work_doOperation23(var _Data:TData; Index:word);
    procedure _work_doOperation24(var _Data:TData; Index:word);
    procedure _work_doOperation25(var _Data:TData; Index:word);
    procedure _work_doOperation26(var _Data:TData; Index:word);
    procedure _work_doOperation27(var _Data:TData; Index:word);
    procedure _work_doOperation28(var _Data:TData; Index:word);
    procedure _work_doOperation29(var _Data:TData; Index:word);
    procedure _work_doOperation30(var _Data:TData; Index:word);
    procedure _work_doOperation31(var _Data:TData; Index:word);
    procedure _work_doOperation32(var _Data:TData; Index:word);
    procedure _work_doOperation33(var _Data:TData; Index:word);
    procedure _work_doOperation34(var _Data:TData; Index:word);
    procedure _work_doOperation35(var _Data:TData; Index:word);
    procedure _work_doOperation36(var _Data:TData; Index:word);
    procedure _work_doOperation37(var _Data:TData; Index:word);
    procedure _work_doOperation38(var _Data:TData; Index:word);
    procedure _work_doOperation39(var _Data:TData; Index:word);
    procedure _work_doOperation40(var _Data:TData; Index:word);
    procedure _work_doOperation41(var _Data:TData; Index:word);
    procedure _work_doOperation42(var _Data:TData; Index:word);
    procedure _work_doOperation43(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doDefault(var _Data:TData; Index:word);
    procedure _work_doAngleMode(var _Data:TData; Index:word);        
    procedure _var_Result(var _Data:TData; Index:word);
    property _prop_Default:real write SetDefault;
    property _prop_AngleMode:byte write SetAngleMode;
  end;

implementation

uses hiMathParse;

const
 digE = 2.718281828459045; //may be defined in Delphi

procedure THIMath.SetDefault;
begin
  Def:=Value;
  Res:=Def;
  _Err:=false;
end;

procedure THIMath.SetAngleMode;
begin
  if Value=0 then AngleMode :=1
  else AngleMode:=pi/180
end;

procedure THIMath._work_doDefault;
begin
  SetDefault(ToReal(_Data));
end;

procedure THIMath._work_doAngleMode;
begin
  SetAngleMode(ToInteger(_Data));
end;

procedure THIMath._work_doClear;
begin
  Res:=Def;
  _Err:=false;
end;

procedure THIMath._var_Result;
begin
  if _Err then dtNull(_Data)
  else if _prop_ResultType = 0 then
    dtInteger(_Data,integer(Round(Res)))
  else
    dtReal(_Data,Res);
end;

procedure THIMath._work_doOperation0;{+}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err :=false;
  Res := Res+op1;
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation1;{-}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err:=false;
  Res := op1 - Res;
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation2;{*}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err:=false;
  Res := op1 * Res;
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation3;{/}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err := Res = 0;
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := op1 / Res;
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation4;{and}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err:=false;
  Res := Round(op1) and Round(Res);
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation5;{or}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err:=false;
  Res := Round(op1) or Round(Res);
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation6;{xor}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err:=false;
  Res := Round(op1) xor Round(Res);
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation7;{div}
var
  op1:real;
  op2:integer;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  op2 := Round(ReadReal(_Data,_data_Op2,_prop_Op2));
  _Err := op2=0;
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := Round(op1) div op2;
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation8;{mod}
var
  op1:real;
  op2:integer;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  op2 := Round(ReadReal(_Data,_data_Op2,_prop_Op2));
  _Err := op2=0;
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := Round(op1) mod op2;
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation9;{shl}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err:=false;
  Res := Round(op1) shl Round(Res);
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation10;{shr}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err:=false;
  Res := Round(op1) shr Round(Res);
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

function Power(var X, Exponent: real):boolean;
begin
  Result := true;               { 0**n = 0, n > 0 }
  if Exponent = 0.0 then
    X := 1.0                    { n**0 = 1 }
  else if (X = 0.0) then begin
    if (Exponent < 0.0) then Result := false end
  else if (Frac(Exponent)=0.0)and(System.Abs(Exponent)<=MaxInt) then
    X := IntPower(X, Integer(Trunc(Exponent)))
  else if (X > 0.0) then X := Exp(Exponent*Ln(X))
  else Result := false
end;

procedure THIMath._work_doOperation11;{X^Y}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err := not Power(op1,Res);
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := op1;
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation12;{cos}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err:=false;
  Res := cos(Res*AngleMode);
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation13;{sin}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err:=false;
  Res := sin(Res*AngleMode);
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation14;{tg}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := cos(op1*AngleMode);
  _Err := Res=0;
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := sin(op1*AngleMode)/Res;
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation15;{ctg}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := sin(op1*AngleMode);
  _Err := Res=0;
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := cos(op1*AngleMode)/Res;
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation16;{arccos}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err := (Res>1)or(Res<-1);
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := ArcTan2(sqrt(1-Res*Res),Res)/AngleMode;
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation17;{arcsin}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err := (Res>1)or(Res<-1);
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := ArcTan2(Res,sqrt(1-Res*Res))/AngleMode;
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation18;{atan}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err:=false;
  Res := ArcTan2(op1,Res)/AngleMode;
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation19;{ch}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := exp(Res);
  _Err:=false;
  Res := (Res+1/Res)/2;
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation20;{sh}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := exp(Res);
  _Err:=false;
  Res := (Res-1/Res)/2;
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation21;{th}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := exp(2*Res);
  _Err:=false;
  Res := (Res-1)/(Res+1);
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation22;{cth}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err := Res=0;
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := exp(2*Res);
    Res := (Res+1)/(Res-1);
    if _prop_ResultType = 0 then
      _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation23;{arcch}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err := Res<1;
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := LogN(digE,Res+sqrt(Res*Res-1));
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation24;{arcsh}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err:=false;
  Res := LogN(digE,Res+sqrt(Res*Res+1));
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation25;{arcth}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err := (Res>=1)or(Res<=-1);
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := LogN(digE,(1+Res)/(1-Res))/2;
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation26;{arccth}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err := (Res<=1)and(Res>=-1);
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := LogN(digE,(Res+1)/(Res-1))/2;
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation27;{log}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err := (op1<=0)or(Res<=0);
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := LogN(op1,Res);
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation28;{lg}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err := Res<=0;
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := LogN(10,Res);
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation29;{ln}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err := Res<=0;
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := LogN(digE,Res);
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation30;{exp}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err:=false;
  Res := exp(Res);
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation31;{sqr}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err:=false;
  Res := sqr(Res);
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation32;{sqrt}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err := Res<0;
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := sqrt(Res);
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation33;{abs}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err:=false;
  if Res<0 then Res := -Res;
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation34;{sign}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err:=false;
  if Res<0 then Res := -1 else if Res>0 then Res := 1;
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation35;{round}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err := Res=0;
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := round(op1/Res)*Res;
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation36;{frac}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err := Res=0;
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := frac(op1/Res)*Res;
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation37;{trunc}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err := Res=0;
  if _Err then begin
    Res:=Def;
    _hi_OnEvent(_event_onError)
   end
  else begin
    Res := trunc(op1/Res)*Res;
    if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
    else _hi_OnEvent(_event_onResult,Res)
  end
end;

procedure THIMath._work_doOperation38;{min}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err:=false;
  if op1<Res then Res:=op1;
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation39;{max}
var
  op1:real;
begin
  op1 := ReadReal(_Data,_data_Op1,_prop_Op1);
  Res := ReadReal(_Data,_data_Op2,_prop_Op2);
  _Err:=false;
  if op1>Res then Res:=op1;
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation40;{odd}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err:=false;
  Res := ord(odd(round(Res)));
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation41;{even}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err:=false;
  Res := ord(not odd(round(Res)));
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation42;{Floor}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err := false;
  if frac(Res) < 0 then
    Res := trunc(Res) - 1
  else  
    Res := trunc(Res); 
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

procedure THIMath._work_doOperation43;{Ceil}
begin
  Res := ReadReal(_Data,_data_Op1,_prop_Op1);
  _Err := false;
  if frac(Res) > 0 then
    Res := trunc(Res) + 1
  else  
    Res := trunc(Res);
  if _prop_ResultType = 0 then
    _hi_OnEvent(_event_onResult,integer(Round(Res)))
  else _hi_OnEvent(_event_onResult,Res);
end;

end.
