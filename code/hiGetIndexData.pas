unit hiGetIndexData;

interface

uses Kol,Share,Debug;

type
  THIGetIndexData = class(TDebug)
   private
    FIndex:integer;
    FCount:word;
    procedure SetCount(Value:integer);
   public
    _event_onIndex: THI_Event;
    data:array of THI_Event;

    procedure _work_doIndex(var _Data:TData; Index:word);
    procedure _var_Var(var _Data:TData; Index:word);
    property _prop_Count:integer write SetCount;
  end;

implementation

procedure THIGetIndexData._work_doIndex;
var Ind:integer;
begin
   ind := ToInteger(_Data);
   if(ind >= 0)and(ind < FCount)then
     FIndex := ind
   else FIndex := -1;
   _hi_CreateEvent(_Data, @_event_onIndex, ind);
end;

procedure THIGetIndexData._var_Var;
begin
   if FIndex <> -1 then
     _ReadData(_Data,Data[FIndex])
   else dtNull(_Data);
end;

procedure THIGetIndexData.SetCount;
begin
   FCount := Value;
   SetLength(data,FCount);
   FIndex := -1;
end;

end.
