unit hiDateDiff; // Вычисление разницы между датами

interface

uses Kol, Share, Debug;

type
  THIDateDiff = class(TDebug)
  private
    hms: real;
    H, M, S, D: integer;
  public
    _data_DateTime2: THI_Event;
    _data_DateTime1: THI_Event;
    _event_onCalc: THI_Event;

    procedure _work_doCalc(var _Data: TData; Index: Word);
    procedure _var_Days(var _Data: TData; Index: Word);
    procedure _var_Hours(var _Data: TData; Index: Word);
    procedure _var_Minuts(var _Data: TData; Index: Word);
    procedure _var_Seconds(var _Data: TData; Index: Word);
  end;

implementation

procedure THIDateDiff._work_doCalc;
var
  d1, d2, raz: real;
  sec: integer;
  dr, dd, dh, dm, ds: TData; 
begin
  d1 := ReadReal(_Data, _Data_DateTime1, 0);
  d2 := ReadReal(_Data, _Data_DateTime2, 0);
  if d1 > d2  then
    raz := d1 - d2
  else
    raz := d2 - d1;
  D := Trunc(raz);           // получаем дни
  hms := raz - D;            // отделяем дробную часть (часы, минуты, секунды)
  sec := round(86400 * hms); // переводим в секунды
  H := Trunc(sec / 3600);
  M := Trunc((sec - H * 3600) / 60);
  S := sec - (M * 60) - ( H * 3600);
  dtInteger(dr, round(86400 * raz));
  dtInteger(dd, D);
  dtInteger(dh, H);
  dtInteger(dm, M);
  dtInteger(ds, S);
  dr.ldata:= @dd;
  dd.ldata:= @dh;
  dh.ldata:= @dm;
  dm.ldata:= @ds;         
   _hi_OnEvent_(_event_onCalc, dr);
end;

procedure THIdateDiff._var_Days;
begin
  dtInteger(_Data, D);
end;

procedure THIDateDiff._var_Hours;
begin
  dtInteger(_Data, H);
end;

procedure THIDateDiff._var_Minuts;
begin
  dtInteger(_Data, M);
end;

procedure THIdateDiff._var_Seconds;
begin
  dtInteger(_Data, S);
end;

end.