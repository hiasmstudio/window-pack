unit hiMemFifo;

interface

uses Kol,Share,Debug;

type
  THIMemFifo = class(TDebug)
   private
    FData:array of TData;
    highF:integer;
    procedure SetCount(cnt:integer);
   public
    _event_onData:THI_Event;
    _data_Data:THI_Event;
    _prop_Default:TData;

    procedure _work_doValue(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure Value(var _Data:TData; Index:word);

    property _prop_Count:integer write SetCount;
  end;

implementation

procedure THIMemFifo.SetCount;
var i:integer;
begin
   SetLength(FData,cnt);
   highF := high(FData);
   for i := 0 to highF do
     FData[i] := _prop_Default;
end;

procedure THIMemFifo._work_doValue;
var dt:TData; i:integer;
begin
   if highF<0 then exit;
   dt := FData[highF];
   for i := highF downto 1 do
     FData[i] := FData[i-1];               
   FData[0] := ReadData(_Data,_data_Data);
   _hi_CreateEvent(_Data,@_event_onData,dt);
end;

procedure THIMemFifo._work_doClear;
begin
   _prop_Count := highF+1;
end;

procedure THIMemFifo.Value;
begin
   _Data := FData[Index];
end;

end.
