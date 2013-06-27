unit hiMemFifo;

interface

uses Kol,Share,Debug;

type
  THIMemFifo = class(TDebug)
   private
    FData:array of TData;
    offSet,highF:integer;
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
   offSet := highF;
   for i := 0 to highF do
     FData[i] := _prop_Default;
end;

procedure THIMemFifo._work_doValue;
var dt:TData;
begin
   if highF<0 then exit;
   offSet := (offSet+highF)mod(highF+1);
   dt := FData[offSet];
   FData[offSet] := ReadData(_Data,_data_Data);
   _hi_CreateEvent(_Data,@_event_onData,dt);
end;

procedure THIMemFifo._work_doClear;
begin
   _prop_Count := highF+1;
end;

procedure THIMemFifo.Value;
begin
   _Data := FData[(Index+offSet)mod(highF+1)];
end;

end.