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
    _prop_Quality:function:real;

    _data_Min:THI_Event;
    _data_Max:THI_Event;
    _event_onRandom:THI_Event;

    procedure _work_doRandom0(var _Data:TData; Index:word);
    procedure _work_doRandom1(var _Data:TData; Index:word);
    procedure _work_doRandomize(var _Data:TData; Index:word);
    procedure _work_doRandSeed0(var _Data:TData; Index:word);
    procedure _work_doRandSeed1(var _Data:TData; Index:word);
    procedure _work_doMin(var _Data:TData; Index:word);
    procedure _work_doMax(var _Data:TData; Index:word);
    procedure _work_doRandomWithoutRepeats(var _Data:TData; Index:word);
    procedure _var_Random0(var _Data:TData; Index:word);
    procedure _var_Random1(var _Data:TData; Index:word);
    procedure _var_RandSeed0(var _Data:TData; Index:word);
    procedure _var_RandSeed1(var _Data:TData; Index:word);
  end;

function Simple:real;
function Xorshift128:real;
//function Random:real;
//procedure Randomize;

var RandSeed: dword=$12345678;
    RandSeed1:dword=$36243606;
    RandSeed2:dword=$52128862;
    RandSeed3:dword=$88675123;

implementation

function Simple:real;
asm
  imul        edx,[RandSeed],$008088405
  inc         edx
  mov         [RandSeed],edx
  push        -32
  fild        dword[esp]
  push        0
  push        edx
  fild        qword[esp]
  add         esp,12
  fscale
  fstp        st(1)
end;

function Xorshift128:real;
{------------------------------------------------------------------------------;
; Используется алгоритм ГПСЧ Джорджа Марсаглии - "Xorshift - 128"              ;
; Данный алгоритм прошел тест DIEHARD его период 2^128-1                       ;
;------------------------------------------------------------------------------}
asm
  mov         eax,[RandSeed]
  shl         eax,11
  xor         eax,[RandSeed]
  mov         edx,[RandSeed3]
  shr         edx,19
  xor         edx,[RandSeed3]
  xor         edx,eax
  shr         eax,8
  xor         edx,eax
  push        -32
  fild        dword[esp]
  push        0
  push        edx
  xchg        edx,[RandSeed3]
  xchg        edx,[RandSeed2]
  xchg        edx,[RandSeed1]
  mov         [RandSeed],edx
  fild        qword[esp]
  add         esp,12
  fscale
  fstp        st(1)
end;

procedure THIRandom._work_doRandom0;
begin
  FRnd := _prop_Quality*(_prop_Max - _prop_Min + 1) + _prop_Min - 0.5;
  _hi_CreateEvent(_Data,@_event_onRandom,integer(Round(FRnd)));
end;

procedure THIRandom._work_doRandom1;
begin
  FRnd := _prop_Quality*(_prop_Max - _prop_Min) + _prop_Min;
  _hi_CreateEvent(_Data,@_event_onRandom,FRnd);
end;

procedure THIRandom._work_doRandomWithoutRepeats;
var
  i, j, _min: integer;
  IRnd: Array of integer;
begin
  _min := Round(_prop_Min); 
  SetLength(IRnd, Round(_prop_Max) + 1 - _min);
  for i := 0 to High(IRnd) do IRnd[i] := _min + i;
  
  for i := 0 to High(IRnd) do begin
    j := Round(_prop_Quality *(Length(IRnd) - i) - 0.5 + i);
    FRnd := IRnd[j];
    if i <> j then swap(IRnd[i],IRnd[j]); 
    _hi_onEvent(_event_onRandom, integer(Round(FRnd)));
  end;
  SetLength(IRnd, 0);
end;

procedure THIRandom._work_doRandomize;
var T:TSystemTime;
begin
  GetSystemTime(T);
  with T do
    inc(RandSeed,((wHour*60+wMinute)*60+wSecond)*1000+wMilliseconds);
  _prop_Quality;
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
  _prop_Min := ReadReal(_Data,_data_Min);
end;

procedure THIRandom._work_doMax;
begin
  _prop_Max := ReadReal(_Data,_data_Max);
end;

procedure THIRandom._work_doRandSeed0;
begin
   RandSeed := ToInteger(_Data);
end;

procedure THIRandom._work_doRandSeed1;
var S:string;
begin
   S := ToString(_Data);
   RandSeed3 := Hex2Int(Copy(S, 1,8));
   RandSeed2 := Hex2Int(Copy(S, 9,8));
   RandSeed1 := Hex2Int(Copy(S,17,8));
   RandSeed  := Hex2Int(Copy(S,25,8));
end;

procedure THIRandom._var_RandSeed0;
begin
   dtInteger(_Data,RandSeed);
end;

procedure THIRandom._var_RandSeed1;
begin
   dtString(_Data,Int2Hex(RandSeed3,8)+Int2Hex(RandSeed2,8)+Int2Hex(RandSeed1,8)+Int2Hex(RandSeed,8));
end;

end.
