unit hiArrayMathStat;

interface

uses Windows, Kol, Share, Debug, ArrayWorkFunctions;

const
  MODE_MEAN     = 0;
  MODE_VARIANCE = 1;
  MODE_STDDEV   = 2;
  MODE_SKEWNESS = 3;
  MODE_KURTOSIS = 4;
  MODE_ADEV     = 5;  

type
  THIArrayMathStat = class(TDebug)
  private
    ArrIn: PArray;
    RealArray: Array of Real;
    Mean, Variance, StdDev, Skewness, Kurtosis, ADev: Real;
    r: real;
    procedure CopyArray(Arr: PArray);
  public
    _prop_FunctionMathStat: byte;
    _event_onResult: THI_Event;
    _data_Array: THI_Event;

    procedure _work_doFunction0(var _Data: TData; Index: word); // Mean
    procedure _work_doFunction1(var _Data: TData; Index: word); // Variance
    procedure _work_doFunction2(var _Data: TData; Index: word); // Skewness
    procedure _work_doFunction3(var _Data: TData; Index: word); // Kurtosis
    procedure _work_doFunction4(var _Data: TData; Index: word); // StdDev
    procedure _work_doFunction5(var _Data: TData; Index: word); // ADev
    procedure _work_doFunction6(var _Data: TData; Index: word); // Median
    procedure _work_doFunction7(var _Data: TData; Index: word); // Percentil
    procedure _var_Result(var _Data: TData; Index: word);
  end;

implementation

procedure THIArrayMathStat.CopyArray;
var
  i: integer;
  ind, dt: TData;
begin
  SetLength(RealArray, 0);
  for i := 0 to Arr._Count - 1 do
  begin
    Ind := _DoData(i);
    Arr._Get(Ind, dt);
    SetLength(RealArray, Length(RealArray) + 1);
    RealArray[High(RealArray)] := ToReal(dt);
  end;
end;

procedure THIArrayMathStat._work_doFunction0; // Mean
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;
  r := 0;
  CalculateMoments(ArrIn, r, Variance, StdDev, Skewness, Kurtosis, ADev, MODE_MEAN);
  _hi_CreateEvent(_Data, @_event_onResult, r);
end;

procedure THIArrayMathStat._work_doFunction1; // Variance
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;
  r := 0;
  CalculateMoments(ArrIn, Mean, r, StdDev, Skewness, Kurtosis, ADev, MODE_VARIANCE);
  _hi_CreateEvent(_Data, @_event_onResult, r);
end;

procedure THIArrayMathStat._work_doFunction2; // Skewness
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;
  r := 0;
  CalculateMoments(ArrIn, Mean, Variance, StdDev, r, Kurtosis, ADev, MODE_SKEWNESS);
  _hi_CreateEvent(_Data, @_event_onResult, r);
end;

procedure THIArrayMathStat._work_doFunction3; // Kurtosis
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;
  r := 0;
  CalculateMoments(ArrIn, Mean, Variance, StdDev, Skewness, r, ADev, MODE_KURTOSIS);
  _hi_CreateEvent(_Data, @_event_onResult, r);
end;

procedure THIArrayMathStat._work_doFunction4; // StdDev
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;
  r := 0;
  CalculateMoments(ArrIn, Mean, Variance, r, Skewness, Kurtosis, ADev, MODE_STDDEV);
  _hi_CreateEvent(_Data, @_event_onResult, r);
end;

procedure THIArrayMathStat._work_doFunction5; // ADev
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;
  r := 0;
  CalculateMoments(ArrIn, Mean, Variance, StdDev, Skewness, Kurtosis, r, MODE_ADEV);
  _hi_CreateEvent(_Data, @_event_onResult, r);
end;

procedure THIArrayMathStat._work_doFunction6; // Median
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;
  r := 0;
  CopyArray(ArrIn);
  CalculatePercentile(RealArray, 0.5, r);
  _hi_CreateEvent(_Data, @_event_onResult, r);
end;

procedure THIArrayMathStat._work_doFunction7; // Percentil
begin
  ArrIn := ReadArray(_data_Array);
  if (ArrIn = nil) or (ArrIn._Count = 0) then exit;
  r := 0;
  CopyArray(ArrIn);
  CalculatePercentile(RealArray, ToReal(_Data), r);  
  _hi_CreateEvent(_Data, @_event_onResult, r);
end;


procedure THIArrayMathStat._var_Result;
begin
  dtReal(_Data, r);
end;

end.