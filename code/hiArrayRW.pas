unit hiArrayRW;

interface

uses Kol,Share,Debug;

type
  THIArrayRW = class(TDebug)
   private
    FItem:TData;
   public
    _prop_Index:TData;
    _data_Index:THI_Event;
    _data_Value:THI_Event;
    _data_Array:THI_Event;
    _event_onRead:THI_Event;

    procedure _work_doRead(var _Data:TData; Index:word);
    procedure _work_doWrite(var _Data:TData; Index:word);
    procedure _work_doAdd(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_Item(var _Data:TData; Index:word);
  end;

implementation

procedure THIArrayRW._work_doRead;
var
  Arr:PArray;
  Ind:TData;
begin
  Arr := ReadArray(_data_Array);
  if Arr=nil then exit;
  Ind := ReadData(_Data,_data_Index,@_prop_Index);
  if not Arr._Get(ind,FItem) then exit;
  dtData(_Data, FItem);
  _hi_CreateEvent_(_Data,@_event_onRead);
end;

procedure THIArrayRW._work_doWrite;
var
  Arr:PArray;
  Ind:TData;
begin
  Arr := ReadArray(_data_Array);
  if Arr=nil then exit;
  Ind := ReadData(_Data,_data_Index,@_prop_Index);
  _Data := ReadData(_Data,_data_Value);
  Arr._Set(ind,_Data);
end;

procedure THIArrayRW._work_doAdd;
var Arr:PArray;
begin
  Arr := ReadArray(_data_Array);
  if Arr=nil then exit;
  _Data := ReadData(_Data,_data_Value);
  Arr._Add(_Data);
end;

procedure THIArrayRW._var_Count;
var Arr:PArray;
begin
  Arr := ReadArray(_data_Array);
  if Arr=nil then exit;
  dtInteger(_data,Arr._Count);
end;

procedure THIArrayRW._var_Item;
begin
  dtData(_Data,FItem);
end;

end.
