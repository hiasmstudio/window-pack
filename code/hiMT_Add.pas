unit hiMT_Add;

interface

uses Kol,Share,Debug;

type
  THIMT_Add = class(TDebug)
   private
   public
    _prop_InputMT:byte;
    _prop_Data:TData;
    _data_Data:THI_Event;
    _event_onAdd:THI_Event;

    procedure _work_doAdd0(var _Data:TData; Index:word);
    procedure _work_doAdd1(var _Data:TData; Index:word);
    procedure _work_doAdd2(var _Data:TData; Index:word);
    procedure _work_doAdd3(var _Data:TData; Index:word);
  end;

implementation

procedure THIMT_Add._work_doAdd0;//ToHead
var dt,ndt:TData;s:PData;
begin
  dtNull(dt);
  dt := ReadMTData(dt,_data_Data,@_prop_Data);
  CopyData(@ndt,@_Data); //копия потока
  AddMTData(@ndt,@dt,s);
  _hi_onEvent_(_event_onAdd,ndt);
  FreeData(@ndt);
end;

procedure THIMT_Add._work_doAdd1;//ToTail
var dt:TData;s:PData;
begin
  dtNull(dt);
  dt := ReadMTData(dt,_data_Data,@_prop_Data);
  CopyData(@dt,@dt); //копия верхних данных
  AddMTData(@dt,@_Data,s);
  _hi_onEvent_(_event_onAdd,dt);
  FreeData(@dt);
end;

procedure THIMT_Add._work_doAdd2;//Null
begin
  dtNull(_Data);
  _Data := ReadMTData(_Data,_data_Data,@_prop_Data);
  CopyData(@_Data,@_Data); //копия верхних данных
  _hi_onEvent_(_event_onAdd,_Data);
  FreeData(@_Data);
end;

procedure THIMT_Add._work_doAdd3;//SendUp
begin
  if not _isNull(_prop_Data) then _Data := _prop_Data;
  _ReadData(_Data,_data_Data);
  CopyData(@_Data,@_Data); //копия верхних данных
  _hi_onEvent_(_event_onAdd,_Data);
  FreeData(@_Data);
end;

end.
