unit hiBitsToInt;

interface

uses windows,Kol,Share,Debug;

type
  THIBitsToInt = class(TDebug)
   private
    FCount:word;
    procedure SetCount(Value:integer);
   public
     Bit:array of THI_Event;

    _event_onNumber:THI_Event;

    procedure _work_doNumber(var _Data:TData; Index:word);
    procedure _var_Number(var _Data:TData; Index:word);
    property _prop_Count:integer write SetCount;
  end;

implementation

uses hiMathParse;

procedure THIBitsToInt._work_doNumber;
begin
   _var_Number(_Data,0);
   _hi_CreateEvent_(_Data,@_event_onNumber);
end;

procedure THIBitsToInt._var_Number;
var i:integer;val:real;
begin
   val := 0;
   for i := 0 to FCount-1 do
     val := val/2 + byte(ReadInteger(_Data,Bit[i]) <> 0);
   val := val*intPower(2,FCount-1);
   if val<=MAXDWORD then
     dtInteger(_Data,Round(val))
   else dtReal(_Data,val);
end;

procedure THIBitsToInt.SetCount;
begin
   FCount := Value;
   SetLength(Bit,Value);
end;

end.
