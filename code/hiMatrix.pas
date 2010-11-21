unit hiMatrix;

interface

uses Windows,Kol,Share,Debug;

type
  TSetMatrixType = procedure of object;
  THIMatrix = class(TDebug)
   private
    MatrI:array of array of integer;
    MatrR:array of array of real;
    MatrS:array of array of string;
    Col,Row:integer;
    Obj:TMatrix;

    procedure SetRows(Value:integer);

    procedure _SetSizeI(x,y:integer);
    procedure _SetI(x,y:integer; var Val:TData);
    function _GetI(x,y:integer):TData;

    procedure _SetSizeR(x,y:integer);
    procedure _SetR(x,y:integer; var Val:TData);
    function _GetR(x,y:integer):TData;

    procedure _SetSizeS(x,y:integer);
    procedure _SetS(x,y:integer; var Val:TData);
    function _GetS(x,y:integer):TData;

    function _R:integer;
    function _C:integer;
   public
    _prop_MatrixType:TSetMatrixType;
    _data_Size :THI_Event;

    procedure mxInteger;
    procedure mxString;
    procedure mxReal;

    procedure _work_doSize(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _var_Matrix(var _Data:TData; Index:word);
    property _prop_Row:integer write SetRows;
    property _prop_Col:integer write Col;
    procedure _var_CountCol(var _Data:TData; Index:word);
    procedure _var_CountRow(var _Data:TData; Index:word);
  end;

implementation

procedure THIMatrix.mxInteger;
begin
   Obj._SetSize := _SetSizeI;
   Obj._Set := _SetI;
   Obj._Get := _GetI;
   Obj._Rows := _R;
   Obj._Cols := _C;
end;

procedure THIMatrix.mxString;
begin
   Obj._SetSize := _SetSizeS;
   Obj._Set := _SetS;
   Obj._Get := _GetS;
   Obj._Rows := _R;
   Obj._Cols := _C;
end;

procedure THIMatrix.mxReal;
begin
   Obj._SetSize := _SetSizeR;
   Obj._Set := _SetR;
   Obj._Get := _GetR;
   Obj._Rows := _R;
   Obj._Cols := _C;
end;


function THIMatrix._GetI;
begin
   if(x >=0 )and(y >=0)and(x < Col)and(y < Row) then
     dtInteger(Result,MatrI[y,x])
   else dtNull(Result);
end;

procedure THIMatrix._SetSizeI;
var i:integer;
begin
   Row := y;
   Col := x;
   SetLength(MatrI,Row);
   for i := 0 to Row-1 do
      SetLength(MatrI[i],Col);
end;

procedure THIMatrix._SetI;
begin
   if(x >=0 )and(y >=0)and(x < Col)and(y < Row) then
    MatrI[y,x] := ToInteger(Val);
end;

function THIMatrix._GetR;
begin
   if(x >=0 )and(y >=0)and(x < Col)and(y < Row) then
     dtReal(Result,MatrR[y,x])
   else dtNull(Result);
end;

procedure THIMatrix._SetSizeR;
var i:integer;
begin
   Row := y;
   Col := x;
   SetLength(MatrR,Row);
   for i := 0 to Row-1 do
      SetLength(MatrR[i],Col);
end;

procedure THIMatrix._SetR;
begin
   if(x >=0 )and(y >=0)and(x < Col)and(y < Row) then
    MatrR[y,x] := ToReal(Val);
end;

function THIMatrix._GetS;
begin
   if(x >=0 )and(y >=0)and(x < Col)and(y < Row) then
     dtString(Result,MatrS[y,x])
   else dtNull(Result);
end;

procedure THIMatrix._SetSizeS;
var i:integer;
begin
   Row := y;
   Col := x;
   SetLength(MatrS,Row);
   for i := 0 to Row-1 do
      SetLength(MatrS[i],Col);
end;

procedure THIMatrix._SetS;
begin
   if(x >=0 )and(y >=0)and(x < Col)and(y < Row) then
    MatrS[y,x] := ToString(Val);
end;

function THIMatrix._C;
begin
   Result := Col;
end;

function THIMatrix._R;
begin
   Result := Row;
end;

procedure THIMatrix._work_doSize;
var val:cardinal;
begin
   val := ReadInteger(_Data,_data_Size);
   Obj._SetSize(val and $FFFF, val shr 16);
end;

procedure THIMatrix._work_doClear;
var x,y:integer;
begin
   x := Col; y := Row;
   Obj._SetSize(0, 0);
   Obj._SetSize(x, y);
end;

procedure THIMatrix._var_Matrix;
begin
   dtMatrix(_Data,@Obj);
end;

procedure THIMatrix.SetRows;
begin
   Row := Value;
   _prop_MatrixType;
   Obj._SetSize(Col, Row);
end;

procedure THIMatrix._var_CountCol;
begin
   dtInteger(_Data, Col);
end;

procedure THIMatrix._var_CountRow;
begin
   dtInteger(_Data, Row);
end;

end.
