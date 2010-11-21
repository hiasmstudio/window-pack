unit hiMT_MultiData;

interface

uses Kol,Share,Debug;

type
  THIMT_MultiData = class(TDebug)
   private
    FCount:integer;
    FData: TData;
    FData_1: TData;    
    procedure SetCount(value:integer);
   public
    _prop_From:Integer;
    onData:array of THI_Event;
    _data_Data:THI_Event;
    
    property _prop_Count:integer write SetCount;
    
    destructor Destroy; override;
    procedure _work_doSeparateMT(var _Data:TData; Index:word);
    procedure _var_RemaindData(var _Data:TData; Index:word);
  end;

implementation

destructor THIMT_MultiData.Destroy;
begin
  FreeData(@FData);
  FreeData(@FData_1);
  inherited;
end;

procedure THIMT_MultiData.SetCount;
begin
  SetLength(onData,Value);
  FCount := Value;
end;

procedure THIMT_MultiData._work_doSeparateMT;
var i:integer;
    d:PData;
    dt: TData;
begin
  FreeData(@FData);
  FreeData(@FData_1);
//  dtNull(dt);
  FData := ReadMTData(_data,_data_Data);
  CopyData(@FData,@FData);
  d := @FData;
  i := 0;
  while i < _prop_From do begin
    if (d = nil) or (d.data_type = data_null) then exit;
    d := d.ldata;
    inc(i);
  end;  
  i := 0;
  while i < FCount do begin
    if (d = nil) or (d.data_type = data_null) then exit;
    dtData(dt, d^);
//    dt := ReadData(d^,Null); 
    _hi_onEvent_(onData[i], dt);
    d := d.ldata; 
    inc(i);
  end;
  if (d = nil) or (d.data_type = data_null) then exit;
  CopyData(@FData_1, d);
end;

procedure THIMT_MultiData._var_RemaindData;
begin
  _Data := FData_1;
end;

end.