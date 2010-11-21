unit hiMT_Part;

interface

uses Kol,Share,Debug;

type
  THIMT_Part = class(TDebug)
   private
    FCount:integer;
    FData: TData;
    FData_1: TData;    
   public
    _prop_From:Integer;
    _data_Data:THI_Event;
    _event_onSplit: THI_Event;
    _event_onPart: THI_Event;    

    destructor Destroy; override;
    procedure _work_doSplit(var _Data:TData; Index:word);
    procedure _var_Left(var _Data:TData; Index:word);
    procedure _var_Right(var _Data:TData; Index:word);    
  end;

implementation

destructor THIMT_Part.Destroy;
begin
  FreeData(@FData);
  FreeData(@FData_1);
  inherited;
end;

procedure THIMT_Part._work_doSplit;
var i:integer;
    d:PData;
begin
  FreeData(@FData);
  FreeData(@FData_1);

  FData := ReadMTData(_data,_data_Data);
  CopyData(@FData,@FData);
  d := @FData;
  i := 0;
  while i < _prop_From do begin
    if (d = nil) or (d.ldata = nil) or (d.data_type = data_null) then exit;
    d := d.ldata;
    inc(i);
  end;  
  if d.ldata <> nil then
  begin
    CopyData(@FData_1, d.ldata);
    FreeData(d);    
  end;
  _hi_onEvent_(_event_onPart, FData);
  if _isNull(FData_1) then exit; 
  _hi_onEvent_(_event_onSplit, FData_1); 
end;

procedure THIMT_Part._var_Left;
begin
  _Data := FData;
end;

procedure THIMT_Part._var_Right;
begin
  _Data := FData_1;
end;


end.