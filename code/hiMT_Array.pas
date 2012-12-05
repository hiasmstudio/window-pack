unit hiMT_Array;

interface

uses Kol,Share,Debug;

type
  THIMT_Array = class(TDebug)
   private
    FData:TData;
    Arr:PArray;

    procedure _Set(var Item:TData; var Val:TData);
    function _Get(Var Item:TData; var Val:TData):boolean;
    function _Count:integer;
    procedure _Add(var Val:TData);
   public
    destructor Destroy; override;
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);    
    procedure _var_Array(var _Data:TData; Index:word);
    procedure _var_MThread(var _Data:TData; Index:word);
  end;

implementation

destructor THIMT_Array.Destroy;
begin
  FreeData(@FData);
  inherited;
end;

procedure THIMT_Array._work_doLoad;
begin
  FreeData(@FData);
  CopyData(@FData,@_Data);
end;

procedure THIMT_Array._work_doClear;
begin
  FreeData(@FData);
  dtNull(FData);
end;

procedure THIMT_Array._var_MThread;
begin
  _Data := FData;
end;

procedure THIMT_Array._Set;
var ind:integer;
    d,p:PData;
begin
  if _isNULL(Val) then exit;
  ind := ToIntIndex(Item);
  if ind < 0 then exit;
  d := @FData;
  while ind > 0 do begin
    dec(ind);
    d := d.ldata;
    if (d=nil)or(d.data_type=data_null) then exit;
  end;
  p := d.ldata;
  d^ := Val;
  d.ldata := p;
end;

procedure THIMT_Array._Add;
var s:PData;
begin
  AddMTData(@FData,@Val,s);
end;

function THIMT_Array._Get;
var ind:integer;
    d:PData;
begin
  Result := false;
  ind := ToIntIndex(Item);
  if ind < 0 then exit;
  d := @FData;
  while ind > 0 do begin
    dec(ind);
    d := d.ldata;
    if (d=nil)or(d.data_type=data_null) then exit;
  end;
  Result := true;
  dtData(Val,d^);
end;

function THIMT_Array._Count;
var d:PData;
begin
  d := @FData;
  Result := 0;
  while (d <> nil)and(d.data_type <> data_null)do begin
    d := d.ldata;
    inc(Result);
  end;
end;

procedure THIMT_Array._var_Array;
begin
  if Arr = nil then
    Arr := CreateArray(_Set, _Get, _Count, _Add);
  dtArray(_Data,Arr);
end;

end.
