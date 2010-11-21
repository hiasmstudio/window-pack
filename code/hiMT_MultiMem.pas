unit hiMT_MultiMem;

interface

uses Kol,Share,Debug;

type
  THIMT_MultiMem = class(TDebug)
   private
    l:array of TData;

    procedure SetCount(value:word);
   public
    _prop_From:Integer;
    _event_onData:THI_Event;
    _data_Data:THI_Event;
    
    procedure _work_doValue(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure Value(var _Data:TData; Index:word);
    property _prop_Count:word write SetCount;
  end;

implementation

procedure THIMT_MultiMem.SetCount;
var i:integer;
begin
  SetLength(l,Value);
  for i := 0 to High(l) do 
    l[i] := _Data_Empty;
end;

procedure THIMT_MultiMem._work_doValue;
var i:integer;
    p:PData;
    FData:TData;
begin
  FData := ReadMTData(_data,_data_Data);
  p := @FData;   
  for i := 0 to High(l) + _prop_From do
    begin
      if i >= _prop_From then l[i - _prop_From] := p^; 
      
      if assigned(p.ldata) then
        p := p.ldata 
      else p := @_Data_Empty;
    end;
  _hi_CreateEvent(_Data,@_event_onData,FData);
end;

procedure THIMT_MultiMem._work_doClear;
var i:integer;
begin
  for i := 0 to High(l) do 
    l[i] := _Data_Empty;
end;

procedure THIMT_MultiMem.Value;
//var dt:TData;
begin     
//  dt := l[index]; 
//  dtData(_data, dt);
  dtData(_data,l[index]);
end;

end.
