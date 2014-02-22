unit hiRandom;

interface

uses windows,Kol,Share,Debug;

type
  THIRandom = class(TDebug)
   private
    FRnd:real;
   public
    _prop_Min:real;
    _prop_Max:real;
    _prop_Mode:byte;

    _data_Min:THI_Event;
    _data_Max:THI_Event;
    _event_onRandom:THI_Event;

    procedure _work_doRandom0(var _Data:TData; Index:word);
    procedure _work_doRandom1(var _Data:TData; Index:word);
    procedure _work_doRandomize(var _Data:TData; Index:word);
    procedure _work_doRandSeed(var _Data:TData; Index:word);
    procedure _work_doMin(var _Data:TData; Index:word);
    procedure _work_doMax(var _Data:TData; Index:word);
    procedure _work_doRandomWithoutRepeats(var _Data:TData; Index:word);
    procedure _var_Random0(var _Data:TData; Index:word);
    procedure _var_Random1(var _Data:TData; Index:word);
    procedure _var_RandSeed(var _Data:TData; Index:word);
  end;

function Random:real;
procedure Randomize;

var RandSeed:dword=$12345678;

implementation

function Random:real;
asm
  imul        edx,[RandSeed],$008088405
  inc         edx
  mov         [RandSeed],edx
  push        -32
  fild        dword ptr[esp]
  push        0
  push        edx
  fild        qword ptr[esp]
  add         esp,12
  fscale
  fstp        st(1)
end;

procedure Randomize;
var T:TSystemTime;
begin
  GetSystemTime(T);
  with T do
    inc(RandSeed,((wHour*60+wMinute)*60+wSecond)*1000+wMilliseconds);
  Random;
end;

procedure THIRandom._work_doRandom0;
begin
  FRnd := Random*(_prop_Max - _prop_Min + 1) + _prop_Min - 0.5;
  _hi_CreateEvent(_Data,@_event_onRandom,integer(Round(FRnd)));
end;

procedure THIRandom._work_doRandom1;
begin
  FRnd := Random*(_prop_Max - _prop_Min) + _prop_Min;
  _hi_CreateEvent(_Data,@_event_onRandom,FRnd);
end;

procedure THIRandom._work_doRandomWithoutRepeats;
var
  i, j, rndidx, _max, _min: integer;
  IRnd: Array of integer;
begin
  _max := Round(_prop_Max) + 1;
  _min := Round(_prop_Min); 
  SetLength(IRnd, _max - _min);
  for i := 0 to High(IRnd) do
    IRnd[i] := _min + i;
  for i := 0 to High(IRnd) do
  begin
    j := Round(Random *(High(IRnd) - i + 1) - 0.5 + i);
    FRnd := IRnd[j];
    if i <> j then
    begin    
      rndidx := IRnd[i];
      IRnd[i] := IRnd[j];
      IRnd[j] := rndidx;
    end;
    _hi_onEvent(_event_onRandom, integer(Round(FRnd)));
  end;
  SetLength(IRnd, 0);
end;

procedure THIRandom._work_doRandomize;
begin
  Randomize;
end;

procedure THIRandom._var_Random0;
begin
  dtInteger(_Data,Round(FRnd));
end;

procedure THIRandom._var_Random1;
begin
  dtReal(_Data,FRnd);
end;

procedure THIRandom._work_doMin;
begin
  _prop_Min := ReadReal(_Data,_data_Min,0);
end;

procedure THIRandom._work_doMax;
begin
  _prop_Max := ReadReal(_Data,_data_Max,0);
end;

procedure THIRandom._work_doRandSeed;
begin
   RandSeed := ToInteger(_Data);
end;

procedure THIRandom._var_RandSeed;
begin
   dtInteger(_Data,RandSeed);
end;

end.
