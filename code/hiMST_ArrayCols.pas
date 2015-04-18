unit hiMST_ArrayCols;

interface
     
uses Kol, Share, Debug, hiMTStrTbl;

const
   COL_NAME   =  -9;
   COL_WIDTH  = -10;
   COL_IMAGE  = -11;
   COL_ALIGN  = -12;

type
  THIMST_ArrayCols = class(TDebug)
  private
    FData_1,
    FData_2: TData;
  public
    _prop_MSTControl: IMSTControl;
        
    destructor Destroy; override;
    procedure _var_ColumnArray(var _Data: TData; Index: word);
    procedure _var_CountCol(var _Data: TData; Index: word);
    procedure _var_MTCols(var _Data: TData; Index: word);
    procedure _var_EndIdxCol(var _Data: TData; Index: word);         
  end;

implementation

destructor THIMST_ArrayCols.Destroy;
begin
  FreeData(@FData_1);
  FreeData(@FData_2);
  inherited;
end;

// Массив форматных свойств столбцов
//
procedure THIMST_ArrayCols._var_ColumnArray;
begin
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.columnarray(_Data);
end;

// Содержит количество столбцов
//
procedure THIMST_ArrayCols._var_CountCol;
begin
  if not Assigned(_prop_MSTControl) then exit;
  dtInteger(_Data, _prop_MSTControl.clistcount);
end;

// Содержит индекс последнего столбца в таблице
//
procedure THIMST_ArrayCols._var_EndIdxCol;
begin
  if not Assigned(_prop_MSTControl) then exit;
  dtInteger(_Data, _prop_MSTControl.clistcount - 1);
end;

// Содержит MT-элементы форматных свойств столбцов
//
procedure THIMST_ArrayCols._var_MTCols;
var
  ind: integer;
  d: PData;
  dt: TData;
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  FreeData(@FData_1);
  FreeData(@FData_2);
  dtNull(FData_1);
  dtNull(FData_2);
  if sControl.LVColCount > 0 then
    for ind := 0 to _prop_MSTControl.colcount - 1 do
    begin
      dtString(dt, _prop_MSTControl.clistitems(ind));
      AddMtData(@FData_1, @dt, d);
    end;
  CopyData(@FData_2, @FData_1);
  _Data := FData_2; 
  FreeData(d);
end;

end.