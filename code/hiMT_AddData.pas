unit hiMT_AddData; { Компонент MT_AddData (добавление данных в многомерный поток) ver 1.21 }

interface

uses Kol,Share,Debug;

type
  ThiMT_AddData = class(TDebug)
   private
    FCount:word;
    procedure SetCount(Value:integer);
   public
    _prop_InputMT:byte;
    _prop_Data:TData;
    _event_onAdd:THI_Event;

    data:array of THI_Event;
    
    property _prop_Count:integer write SetCount;
    procedure _work_doAdd0(var _Data:TData; Index:word);
    procedure _work_doAdd1(var _Data:TData; Index:word);
    procedure _work_doAdd2(var _Data:TData; Index:word);
    procedure _work_doAdd3(var _Data:TData; Index:word);
  end;

implementation

procedure ThiMT_AddData._work_doAdd0;//ToHead
var   i:integer;
      dt,di,dp:TData;
      s:PData;
begin
  dtNull(di);
  CopyData(@dt,@_Data);
  for i := 0 to High(data) do 
  begin
    dp := ReadMTData(di,data[i],@_prop_Data);
    CopyData(@dp,@dp); //копия верхних данных
    AddMTData(@dt,@dp,s);
  end;
  _hi_onEvent_(_event_onAdd, dt);
  FreeData(@dp);
  FreeData(@dt);
end;

procedure ThiMT_AddData._work_doAdd1;//ToTail
var   i:integer;
      dt,di,dp:TData;
      s:PData;
begin
  dtNull(dt);
  dtNull(di);
  for i := 0 to High(data) do 
   begin
     dp := ReadMTData(di,data[i],@_prop_Data);
     CopyData(@dp,@dp); //копия верхних данных
     AddMTData(@dt,@dp,s);
   end; 
  AddMTData(@dt,@_Data,s);
  _hi_onEvent_(_event_onAdd,dt);
  FreeData(@dp);
  FreeData(@dt);
end;

procedure ThiMT_AddData._work_doAdd2;//Null
var   i:integer;
      di,dp:TData;
      s:PData;
begin
  dtNull(_Data);
  dtNull(di);
  for i := 0 to High(data) do 
   begin
     dp := ReadMTData(di,data[i],@_prop_Data);
     CopyData(@dp,@dp); //копия верхних данных
     AddMTData(@_Data,@dp,s);
   end; 
  _hi_onEvent_(_event_onAdd,_Data);
  FreeData(@dp);
  FreeData(@_Data);
end;

procedure ThiMT_AddData._work_doAdd3;//Standart
var   i:integer;
      di,dp:TData;
      s:PData;
begin
  dtNull(di);
  for i := 0 to High(data) do 
   begin
     dp := ReadData(_Data,data[i],@_prop_Data);
     AddMTData(@di,@dp,s);
   end; 
  _hi_onEvent_(_event_onAdd,di);
  FreeData(@dp);
//  FreeData(s);
  FreeData(@di);
end;

procedure ThiMT_AddData.SetCount;
begin
   FCount := Value;
   SetLength(data,FCount);
end;

end.