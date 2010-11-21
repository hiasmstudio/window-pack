unit hiMST_Matrix;

interface
     
uses Kol, Share, Debug, hiMTStrTbl;

const
   EMATRIX     =  -6;
   CHK_EMATRIX =  -7;
   SEL_EMATRIX =  -8;
   
type
  THIMST_Matrix = class(TDebug)
  private
    FData_1,FData_2: TData;
    procedure _EMatrix(var Data: TData; Mode: integer);
  public
    _prop_X,
    _prop_Y: integer;
    
    _prop_MSTControl: IMSTControl;
    _event_onEMatrix: THI_Event;

    _data_X,
    _data_Y: THI_Event;
    
    
    destructor Destroy; override;
    procedure _work_doEMatrix(var _Data: TData; Index: word);
    procedure _work_doChkEMatrix(var _Data: TData; Index: word);
    procedure _work_doSelEMatrix(var _Data: TData; Index: word);
    
    procedure _var_Matrix(var _Data: TData; Index: word);
  end;

implementation

destructor THIMST_Matrix.Destroy;
begin
  FreeData(@FData_1);
  FreeData(@FData_2);
  inherited;
end;


// Читает элемент(ы) матрицы строк по координатам
// При отрицательном параметре X - выдается вся строка
// При отрицательном параметре Y - весь столбец
// ARG(X(IndexCol), Y(IndexRow))
//
procedure THIMST_Matrix._work_doEMatrix;
begin
  _EMatrix(_Data, EMATRIX);
end;

// Читает элемент(ы) матрицы строк с установленными флажками по координатам
// При отрицательном параметре X - выдается вся строка
// При отрицательном параметре Y - весь столбец
// ARG(X(IndexCol), Y(IndexRow))
//
procedure THIMST_Matrix._work_doChkEMatrix;
begin
  _EMatrix(_Data, CHK_EMATRIX);
end;

// Читает выбранные элемент(ы) матрицы строк по координатам
// При отрицательном параметре X - выдается вся строка
// При отрицательном параметре Y - весь столбец
// ARG(X(IndexCol), Y(IndexRow))
//
procedure THIMST_Matrix._work_doSelEMatrix;
begin
  _EMatrix(_Data, SEL_EMATRIX);
end;

//Универсальный MT-метод работы с матрицей
//
procedure THIMST_Matrix._EMatrix; // проверен
var
  x, y: integer;
  d: PData;
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint; 
//  if _IsNULL(Data) then exit;

  FreeData(@FData_1);
  FreeData(@FData_2);
  dtNull(FData_1);
  dtNull(FData_2);
  x := ReadInteger(Data, _data_X, _prop_X);
  y := ReadInteger(Data, _data_Y, _prop_Y);
  if (x >= 0) and (y >= 0) then
  begin
    if (((sControl.LVItemStateImgIdx[y] - 1) > 0) and (Mode = CHK_EMATRIX))  or
       ((lvisSelect in sControl.LVItemState[y])   and (Mode  = SEL_EMATRIX)) or
       (Mode = EMATRIX) then
       begin
         FData_2:= _prop_MSTControl.mxget(x, y);
         AddMTData(@FData_1, @FData_2, d);
       end;
  end
  else if (x < 0) and (y >= 0) then
  begin
    for x := 0 to sControl.LVColCount - 1 do
      if (((sControl.LVItemStateImgIdx[y] - 1) > 0) and (Mode = CHK_EMATRIX))  or
         ((lvisSelect in sControl.LVItemState[y])   and (Mode  = SEL_EMATRIX)) or
         (Mode = EMATRIX) then
         begin
           FData_2:= _prop_MSTControl.mxget(x, y);
           AddMTData(@FData_1, @FData_2, d);
         end;
  end
  else if (x >= 0) and (y < 0) then
  begin
    for y := 0 to sControl.Count - 1 do
      if (((sControl.LVItemStateImgIdx[y] - 1) > 0) and (Mode = CHK_EMATRIX))  or
         ((lvisSelect in sControl.LVItemState[y])   and (Mode  = SEL_EMATRIX)) or
         (Mode = EMATRIX) then
         begin
           FData_2:= _prop_MSTControl.mxget(x, y);
           AddMTData(@FData_1, @FData_2, d);
         end;
  end;
  _hi_onEvent_(_event_onEMatrix,FData_1);
  if (d <> nil) and not _IsNULL(d^) then FreeData(d);
end;

// Матрица строк
//
procedure THIMST_Matrix._var_Matrix;
begin
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.matrix(_Data);    
end;

end.