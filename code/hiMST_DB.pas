unit hiMST_DB;

interface
     
uses Kol, Share, Debug, hiMTStrTbl;

const
  ITM_ADD = -3;

type
  THIMST_DB = class(TDebug)
  private
    procedure Clear(var _Data: TData; Index: word; ClearAll: boolean = false);
  public
    _prop_MSTControl: IMSTControl;

    _event_onChange,
    _event_onChangeColLst: THI_Event;
    _event_onResult: THI_Event;

    procedure _work_doAddRow(var _Data: TData; Index: word);  // Add
    procedure _work_doAddCols(var _Data: TData; Index: word); // AddCols
    procedure _work_doClear(var _Data: TData; Index: word);
    procedure _work_doClearAll(var _Data: TData; Index: word);

    procedure _var_Count(var _Data: TData; Index: word);
    procedure _var_CountCol(var _Data: TData; Index: word);
    procedure _var_EndIdx(var _Data: TData; Index: word);     
    procedure _var_EndIdxCol(var _Data: TData; Index: word); 
  end;

implementation

// Добавляет строку в таблицу
// ARG(Col0, Col1, ... ColN)
//
procedure THIMST_DB._work_doAddRow;
begin
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.actionitm(_Data, ITM_ADD);
  _hi_onEvent(_event_onChange);
end;

// Добавляет столбцы в таблицу
// ARG(FormatStrCol0, FormatStrCol1, ... FormatStrColN), где
// FormatStrCol (NameCol_WidthCol_IndexIcon_AlignTxtCol (0 - taLeft; 1 - taRight; 2 - taCenter))
//
procedure THIMST_DB._work_doAddCols; // проверен
begin
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.addcols(_Data);
  _hi_onEvent(_event_onChangeColLst);
end;

// Очищает таблицу
//
procedure THIMST_DB.Clear;
var
  sControl: PControl;
  Item: integer;  
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  sControl.BeginUpdate;
  for Item := 0 to sControl.Count - 1 do
  begin
    if Assigned(PData(sControl.LVItemData[Item])) then
    begin
      FreeData(PData(sControl.LVItemData[Item]));
      Dispose(PData(sControl.LVItemData[Item]));
    end;
  end;
  sControl.Clear;
  if ClearAll then
  begin
    repeat
      sControl.LVColDelete(sControl.LVColCount - 1);
    until sControl.LVColCount <= 0;
    _prop_MSTControl.clistclear;
  end;
  sControl.EndUpDate;
  _hi_onEvent(_event_onChange);
end;

procedure THIMST_DB._work_doClear;
begin
  Clear(_Data, 0);
end;

procedure THIMST_DB._work_doClearAll;
begin
  Clear(_Data, 0, true);
end;

// Содержит количество строк в таблице
//
procedure THIMST_DB._var_Count;
var
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  dtInteger(_Data, sControl.Count);
end;

// Содержит количество столбцов
//
procedure THIMST_DB._var_CountCol;
begin
  if not Assigned(_prop_MSTControl) then exit;
  dtInteger(_Data, _prop_MSTControl.clistcount);
end;

// Содержит индекс последний строки в таблице
//
procedure THIMST_DB._var_EndIdx;
var
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  dtInteger(_Data, sControl.Count - 1);
end;

// Содержит индекс последнего столбца в таблице
//
procedure THIMST_DB._var_EndIdxCol;
begin
  if not Assigned(_prop_MSTControl) then exit;
  dtInteger(_Data, _prop_MSTControl.clistcount - 1);
end;

end.