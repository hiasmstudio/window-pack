unit ArrayWorkFunctions;

//
//  Основные функции для работы с массивами
//

interface

uses Windows, Kol, Share, Debug;

const
  MODE_MEAN     = 0;
  MODE_VARIANCE = 1;
  MODE_STDDEV   = 2;
  MODE_SKEWNESS = 3;
  MODE_KURTOSIS = 4;
  MODE_ADEV     = 5;

type
  PReal = ^Real;

function CompareReals(const Sender: Pointer; const e1, e2: Cardinal): integer;
procedure SwapReals(const Sender: Pointer; const e1, e2: Cardinal);
procedure SortRealArray(var A: Array of Real);
function CompareSListItemsCase(const Sender: Pointer; const e1, e2: Cardinal): integer;
function CompareSListItemsNoCase(const Sender: Pointer; const e1, e2: Cardinal): integer;
procedure SortStrList(var FList: PStrList; const CaseSensitive: boolean);
function AbsReal(X: Extended): Extended;
function Floor(X: Extended): integer;
procedure CalculateMoments(const Arr: PArray; var Mean: Real; var Variance: Real; var StdDev: Real;
                           var Skewness: Real; var Kurtosis: Real; var ADev: Real; Mode: byte);
procedure CalculatePercentile(X: Array of Real; P: Real; var V: Real);

implementation

function AbsReal(X: Extended): Extended;
begin
  if X >= 0 then
    Result := X
  else
    Result := -X;
end;

function Floor(X: Extended): integer;
begin
  Result := Integer(Trunc(X));
  if Frac(X) < 0 then
    Dec(Result);
end;

function CompareReals(const Sender: Pointer; const e1, e2: Cardinal): integer;
var
  I1, I2: Real;
begin
  I1 := PReal(Cardinal(Sender) + e1 * Sizeof(Real))^;
  I2 := PReal(Cardinal(Sender) + e2 * Sizeof(Real))^;
  Result := 0;
  if I1 < I2 then
    Result := -1
  else if I1 > I2 then
    Result := 1;
end;

procedure SwapReals(const Sender: Pointer; const e1, e2: Cardinal);
var
  Tmp: Real;
begin
  Tmp := PReal(Cardinal(Sender) + e1 * SizeOf(Real))^;
  PReal(Cardinal(Sender ) + e1 * Sizeof(Real))^ :=
  PReal(cardinal(Sender ) + e2 * Sizeof(Real))^;
  PReal(Cardinal(Sender ) + e2 * Sizeof(Real))^ := Tmp;
end;

procedure SortRealArray(var A: Array of Real);
begin
  SortData(@A[0], High(A) - Low(A) + 1, @CompareReals, @SwapReals);
end;

function CompareSListItemsCase(const Sender: Pointer; const e1, e2: Cardinal): integer;
var
  S1, S2: PChar;
begin
  S1 := PChar(PStrList(Sender).Items[e1]);
  S2 := PChar(PStrList(Sender).Items[e2]);
  Result := StrComp(S1, S2);
end;

function CompareSListItemsNoCase(const Sender: Pointer; const e1, e2: Cardinal): integer;
var
  S1, S2: PChar;
begin
  S1 := CharLower(PChar(PStrList(Sender).Items[e1]));
  S2 := CharLower(PChar(PStrList(Sender).Items[e2]));  
  Result := StrComp(S1, S2);
end;

procedure SwapStrListItems(const Sender: Pointer; const e1, e2: Cardinal);
begin
  PStrList(Sender).Swap(e1, e2);
end;

procedure SortStrList(var FList: PStrList; const CaseSensitive: boolean);
begin
  if CaseSensitive then 
    SortData(FList, FList.Count, @CompareSListItemsCase, @SwapStrListItems)
  else  
    SortData(FList, FList.Count, @CompareSListItemsNoCase, @SwapStrListItems)
end;

function GetX(Arr: PArray; I: integer): Real;
var
  ind, dt: TData;
begin
  Ind := _DoData(i);
  Arr._Get(Ind, dt);
  Result := ToReal(dt);
end;


(*************************************************************************
Расчет моментов распределения: матожидания, дисперсии, стандартного отклонения, скоса и эксцесса.

Входные параметры:
    X       -   массив значений с нумерацией элементов [0..N-1],
                где: N  - число значений в массиве

Выходные параметры
    Mean    -   математическое ожидание
    Variance-   дисперсия
    StdDev  -   стандартное отклонение
    Skewness-   скос (если дисперсия не равна 0)
    Kurtosis-   эксцесс (если дисперсия не равна 0)
    ADev    -   среднее отклонение
*************************************************************************)
procedure CalculateMoments(const Arr: PArray; var Mean: Real; var Variance: Real;
                           var StdDev: Real; var Skewness: Real; var Kurtosis: Real; var ADev: Real; Mode: byte);
var
  I: integer;
  N: integer;
  V: Real;
  V1: Real;
  V2: Real;

begin
  Mean := 0;
  Variance := 0;
  Skewness := 0;
  Kurtosis := 0;
  StdDev := 0;

  N := Arr._Count;
  if N <= 0 then exit;
  //
  // Mean
  //
  I := 0;
  while I <= N - 1 do
  begin
    Mean := Mean + GetX(Arr, I);
    Inc(I);
  end;
  Mean := Mean / N;
  if Mode = MODE_MEAN then exit;

  if Mode = MODE_ADEV then
  begin
    //
    // ADev
    //
    I := 0;
    while I <= N - 1 do
    begin
      ADev := ADev + AbsReal(GetX(Arr, I) - Mean);
      Inc(I);
    end;
    ADev := ADev / N;
    exit;
  end;
  //
  // Variance and  StdDev (using corrected two-pass algorithm)
  //
  if N <> 1 then
  begin
    V1 := 0;
    I := 0;
    while I <= N - 1 do
    begin
      V1 := V1 + Sqr(GetX(Arr, I) - Mean);
      Inc(I);
    end;
    V2 := 0;
    I := 0;
    while I <= N - 1 do
    begin
      V2 := V2 + (GetX(Arr, I) - Mean);
      Inc(I);
    end;
    V2 := Sqr(V2) / N;
    Variance := (V1 - V2) / (N - 1);
    if Variance < 0 then Variance := 0;
    StdDev := Sqrt(Variance);
  end;
  if (Mode = MODE_VARIANCE) or (Mode = MODE_STDDEV) then exit;
  //
  // Skewness and Kurtosis
  //
  if StdDev <> 0 then
  begin
    I := 0;
    while I <= N - 1 do
    begin
      V := (GetX(Arr, I) - Mean) / StdDev;
      V2 := Sqr(V);
      Skewness := Skewness + V2 * V;
      Kurtosis := Kurtosis + Sqr(V2);
      Inc(I);
    end;
    Skewness := Skewness / N;
    Kurtosis := Kurtosis / N - 3;
  end;
end;

(*************************************************************************
Рсчет перцентиля

Входные параметры:
    X       -   массив значений с нумерацией элементов [0..N-1],
                где: N  - число значений в массиве
    P       -   перцентиль, 0 <= P <= 1

Выходные параметры
    V       -   значение перцентиля (при необходимости, для расчета
                используется интерполяция)
*************************************************************************)
procedure CalculatePercentile(X: Array of Real; P: Real; var V: Real);
var
  N: integer;
  I1: integer;
  T: Real;
  
begin
  N := Length(X);
  if (N <= 1) or (P < 0) or (P > 1) then exit;
  SortRealArray(X);
  if P = 0 then
  begin
    V := X[0];
    exit;
  end;
  if P = 1 then
  begin
    V := X[N - 1];
    exit;
  end;
  T := P * (N - 1);
  I1 := Floor(T);
  T := T - Floor(T);
  V := X[I1] * (1 - T) + X[I1 + 1] * T;
end;

end.