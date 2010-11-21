unit hiMatrixRW;

interface

uses Kol,Share,Debug;

type
  THIMatrixRW = class(TDebug)
   public
    _prop_X:integer;
    _prop_Y:integer;
    _prop_Value:TData;

    _data_Matrix:THI_Event;
    _data_Value:THI_Event;
    _data_Y:THI_Event;
    _data_X:THI_Event;
    _event_onRead:THI_Event;

    procedure _work_doRead(var _Data:TData; Index:word);
    procedure _work_doWrite(var _Data:TData; Index:word);
    procedure _work_doSize(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _var_CountCol(var _Data:TData; Index:word);
    procedure _var_CountRow(var _Data:TData; Index:word);
  end;

implementation

procedure THIMatrixRW._work_doRead;
var x:integer; m:PMatrix;
begin
   m := ReadMatrix(_data_Matrix);
   if m=nil then exit;
   x := ReadInteger(_Data,_data_X,_prop_X);
   _hi_CreateEvent(_Data,@_event_onRead,m._Get(x,ReadInteger(_Data,_data_Y,_prop_Y)));
end;

procedure THIMatrixRW._work_doWrite;
var x:integer; val:TData; m:PMatrix;
begin
   m := ReadMatrix(_data_Matrix);
   if m=nil then exit;
   val := ReadData(_Data,_data_Value,@_prop_Value);
   x := ReadInteger(_Data,_data_X,_prop_X);
   m._Set(x,ReadInteger(_Data,_data_Y,_prop_Y),val);
end;

procedure THIMatrixRW._work_doSize;
var val:cardinal; m:PMatrix;
begin
   m := ReadMatrix(_data_Matrix);
   if (m=nil)or not assigned(m._SetSize) then exit;
   val := ToInteger(_Data);
   m._SetSize(val and $FFFF, val shr 16);
end;

procedure THIMatrixRW._work_doClear;
var m:PMatrix; x,y:integer;
begin
   m := ReadMatrix(_data_Matrix);
   if (m=nil)or not assigned(m._SetSize) then exit;
   y := m._Rows; x := m._Cols;
   m._SetSize(0, 0);
   m._SetSize(x, y);
end;

procedure THIMatrixRW._var_CountCol;
var m:PMatrix;
begin
   m := ReadMatrix(_data_Matrix);
   if m=nil then dtNull(_Data)
   else dtInteger(_Data, m._Cols);
end;

procedure THIMatrixRW._var_CountRow;
var m:PMatrix;
begin
   m := ReadMatrix(_data_Matrix);
   if m=nil then dtNull(_Data)
   else dtInteger(_Data, m._Rows);
end;

end.
