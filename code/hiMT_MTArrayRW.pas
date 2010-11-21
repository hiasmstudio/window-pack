unit hiMT_MTArrayRW; { Компонент MT_MTArrayRW (доступ к массиву MT-потоков) ver 1.00 }

interface

uses Kol,Share,Debug;

type
  ThiMT_MTArrayRW = class(TDebug)
  private
     FItem:TData;
  public
     _prop_Index:TData;
     _data_Index:THI_Event;
     _data_Value:THI_Event;
     _data_Array:THI_Event;
     _event_onRead:THI_Event;

   destructor Destroy; override;
   procedure _work_doRead(var _Data:TData; Index:word);
   procedure _work_doWrite(var _Data:TData; Index:word);
   procedure _work_doAdd(var _Data:TData; Index:word);
   procedure _var_Count(var _Data:TData; Index:word);
   procedure _var_Item(var _Data:TData; Index:word);
  end;

implementation

destructor ThiMT_MTArrayRW.Destroy;
begin
   FreeData(@FItem);
   inherited;
end;

procedure ThiMT_MTArrayRW._work_doRead;
var   Arr:PArray;
      Ind:TData;
begin
   Arr := ReadArray(_data_Array);
   if Arr=nil then exit;
   Ind := ReadData(_Data,_data_Index,@_prop_Index);
   if not Arr._Get(ind,FItem) then exit;
   _hi_CreateEvent(_Data,@_event_onRead,FItem);
end;

procedure ThiMT_MTArrayRW._work_doWrite;
var   Arr:PArray;
      Ind:TData;
      dt:TData;
begin
   Arr := ReadArray(_data_Array);
   if Arr=nil then exit;
   Ind := ReadData(_Data,_data_Index,@_prop_Index);
   dt := ReadMTData(_Data,_data_Value);
   CopyData(@dt,@dt);
   Arr._Set(ind,dt);
   FreeData(@dt);   
end;

procedure ThiMT_MTArrayRW._work_doAdd;
var   Arr:PArray;
      dt:TData;
begin
   Arr := ReadArray(_data_Array);
   if Arr=nil then exit;
   dt := ReadMTData(_Data,_data_Value);
   CopyData(@dt,@dt);
   Arr._Add(dt);
   FreeData(@dt);
end;

procedure ThiMT_MTArrayRW._var_Count;
var   Arr:PArray;
begin
   Arr := ReadArray(_data_Array);
   if Arr=nil then exit;
   dtInteger(_data,Arr._Count);
end;

procedure ThiMT_MTArrayRW._var_Item;
begin
   _Data := FItem;
end;

end.