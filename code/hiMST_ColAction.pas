unit hiMST_ColAction;

interface
     
uses Windows, Kol, Share, Debug, hiMTStrTbl;

const
  ITM_INSERT  = -4;
  ITM_REPLACE = -5;

  COL_NAME    =  -9;
  COL_WIDTH   = -10;
  COL_IMAGE   = -11;
  COL_ALIGN   = -12;
   
type
  THIMST_ColAction = class(TDebug)
  private
    FMaxColWidth: integer;
    FMinColWidth: integer;
    FAutoWidthByHeader: boolean;
  public
    _prop_Action: byte;
    _prop_MSTControl: IMSTControl;
    _prop_Index: integer;

    _data_Index: THI_Event;
    _event_onChange,
    _event_onResult,
    _event_onChangeColLst: THI_Event;
    
    property _prop_AutoWidthByHeader: boolean write FAutoWidthByHeader;
    property _prop_MaxColWidth: integer       write FMaxColWidth;
    property _prop_MinColWidth: integer       write FMinColWidth;

    procedure _work_doColAction0(var _Data: TData; Index: word);  // AddCols
    procedure _work_doColAction1(var _Data: TData; Index: word);  // InsertCol
    procedure _work_doColAction2(var _Data: TData; Index: word);  // ReplaceCol
    procedure _work_doColAction3(var _Data: TData; Index: word);  // DeleteCol
    procedure _work_doColAction4(var _Data: TData; Index: word);  // ClearCol
    procedure _work_doColAction5(var _Data: TData; Index: word);  // NameCol
    procedure _work_doColAction6(var _Data: TData; Index: word);  // WidthCol
    procedure _work_doColAction7(var _Data: TData; Index: word);  // AlignTxtCol
    procedure _work_doColAction8(var _Data: TData; Index: word);  // IdxIconCol
    procedure _work_doColAction9(var _Data: TData; Index: word);  // AutoColWidth
    procedure _work_doColAction10(var _Data: TData; Index: word); // GetColParam
    procedure _work_doColAction11(var _Data: TData; Index: word); // StretchCol

    procedure _var_CountCol(var _Data: TData; Index: word);
    procedure _work_doMaxColWidth(var _Data: TData; Index: word);
    procedure _work_doMinColWidth(var _Data: TData; Index: word);
    procedure _work_doAutoWidthByHeader(var _Data: TData; Index: word);    
    procedure _var_EndIdxCol(var _Data: TData; Index: word); 
  end;

implementation

// Добавляет столбцы в таблицу
// ARG(FormatStrCol0, FormatStrCol1, ... FormatStrColN), где
// FormatStrCol (NameCol_WidthCol_IndexIcon_AlignTxtCol (0 - taLeft; 1 - taRight; 2 - taCenter))
//
procedure THIMST_ColAction._work_doColAction0; // проверен
begin
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.addcols(_Data);
  _hi_onEvent(_event_onChangeColLst);
end;

// Вставляет столбец в таблицу
// ARG(IndexCol, FormatStrCol (NameCol_WidthCol_IndexIcon_AlignTxtCol
// (0 - taLeft; 1 - taRight; 2 - taCenter))
//
procedure THIMST_ColAction._work_doColAction1;
begin
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.actioncol(_Data, ITM_INSERT);
  _hi_onEvent(_event_onChangeColLst);
end;

// Заменяет столбец в таблице
// ARG(IndexCol, FormatStrCol (NameCol_WidthCol_IndexIcon_AlignTxtCol
// (0 - taLeft; 1 - taRight; 2 - taCenter))
//
procedure THIMST_ColAction._work_doColAction2;
begin
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.actioncol(_Data, ITM_REPLACE);
  _hi_onEvent(_event_onChangeColLst);
end;

// Удаляет столбец из таблицы
// ARG(IndexCol)
//
procedure THIMST_ColAction._work_doColAction3;
begin
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.deletecol(_Data);
  _hi_onEvent(_event_onChangeColLst);
end;

// Очищает содержимое столбца
// ARG(IndexCol)
//
procedure THIMST_ColAction._work_doColAction4;
var
  x, y:integer;
  dt: TData;
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  sControl.BeginUpdate;
  dtNull(dt);
  x := ReadInteger(_Data, _data_Index, _prop_Index);
  if (x >= 0) and (x < _prop_MSTControl.clistcount) then
    for y := 0 to sControl.Count - 1 do
      _prop_MSTControl.mxset(x, y, dt);
  sControl.EndUpdate;
  _hi_onEvent(_event_onChange);
end;

// Устанавливает имя столбца
// ARG(IndexCol, NameCol)
//
procedure THIMST_ColAction._work_doColAction5;
begin
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.propercol(_Data, COL_NAME);
  _hi_onEvent(_event_onChangeColLst);
end;

// Устанавливает ширину столбца
// ARG(IndexCol, WidthCol)
//
procedure THIMST_ColAction._work_doColAction6;
begin
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.propercol(_Data, COL_WIDTH);
  _hi_onEvent(_event_onChangeColLst);
end;

// Назначает выравнивание текста в столбце
// ARG(IndexCol, AlignTxtCol (0 - taLeft; 1 - taRight; 2 - taCenter))
//
procedure THIMST_ColAction._work_doColAction7;
begin
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.propercol(_Data, COL_ALIGN);
  _hi_onEvent(_event_onChangeColLst);
end;

// Назначает столбцу иконку из списка иконок
// ARG(IndexCol, IndexIcon)
//
procedure THIMST_ColAction._work_doColAction8;
begin
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.propercol(_Data, COL_IMAGE);
  _hi_onEvent(_event_onChangeColLst);
end;

//-----------------   Автоустановка ширины столбцов   -----------------
//
// Автоматически подстраивает ширину столбца по длине строки
// ( при индексе равном -1 - все столбцы)
// ARG(IndexCol)
//
procedure THIMST_ColAction._work_doColAction9; // проверен
var   FCol,Col,Row:integer;
      _Length, TempLength:integer;
      dt,di:TData;
      sControl: PControl;
      l: TListViewOptions;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  FCol := ReadInteger(_Data, _data_Index, _prop_Index);;
  l := sControl.LVOptions;
  if (sControl.LVColCount <= 0) or ((sControl.Count <= 0) and not FAutoWidthByHeader) or (FCol > sControl.LVColCount - 1) then exit;
  sControl.BeginUpdate;
    if FCol < 0 then
    begin
      FCol := sControl.LVColCount;
      Col:= 0;
    end
    else
    begin
      Col := FCol;
      inc(FCol);
    end;
    repeat
      sControl.LVColWidth[Col] := LVSCW_AUTOSIZE;
      if (sControl.LVStyle = lvsDetail) or (sControl.LVStyle = lvsDetailNoHeader) then
	  begin
        if FAutoWidthByHeader then
		begin
          sControl.LVColWidth[Col] := LVSCW_AUTOSIZE_USEHEADER;
          if Col = (FCol - 1) then		                                                         
            _Length := sControl.LVColWidth[Col]
          else
            _Length := sControl.LVColWidth[Col] + 2 * sControl.Canvas.TextExtent('M').cx;		  
        end   
        else
          _Length := sControl.LVColWidth[Col] + 2 * sControl.Canvas.TextExtent('M').cx;
	  end
	  else
      begin   
        Row:= 0;
        _Length:= 0;
        repeat
           TempLength:= (sControl.Canvas.TextWidth(sControl.LVItems[Row,Col])) + 2 * sControl.Canvas.TextExtent('M').cx;
           if Col = 0 then
           begin
             if (lvoCheckBoxes in l) then
               TempLength:= TempLength + GetSystemMetrics(SM_CXICON);
             if Assigned(_prop_MSTControl.smiconlist) then
               TempLength:= TempLength + _prop_MSTControl.imgsize;              
           end;
           _Length:= max(_Length, TempLength);
           inc(Row);                                                     
        until Row = sControl.Count;
      end;

      if FMaxColWidth > 0 then
        _Length:= min(_Length, FMaxColWidth);
      _Length:= max(_Length, FMinColWidth);
      dtInteger(dt,Col);
      dtInteger(di,_Length);
      dt.ldata:= @di;
      _prop_MSTControl.propercol(dt, COL_WIDTH);
      inc(Col);
    until Col = FCol;
  sControl.EndUpdate;
  _hi_onEvent(_event_onChangeColLst);
end;

// Получает параметры столбца из таблицы
// ARG(IndexCol)
//
procedure THIMST_ColAction._work_doColAction10; // проверен
var   idx: integer;
      dt, di, dj, dk, dl: TData;
      sControl: PControl;
begin
   if not Assigned(_prop_MSTControl) then exit;
   sControl := _prop_MSTControl.ctrlpoint;
   idx := ReadInteger(_Data, _data_Index, _prop_Index);;
   if (idx < 0) or (idx > sControl.LVColCount - 1) then exit;
   dtInteger(dt,idx);
   dtString(di, sControl.LVColText[idx]);
   dtInteger(dj, sControl.LVColWidth[idx]);
   dtInteger(dk, sControl.LVColImage[idx]);
   dtInteger(dl, ord(sControl.LVColAlign[idx]));
   dt.ldata := @di;
   di.ldata := @dj;
   dj.ldata := @dk;
   dk.ldata := @dl;
   _hi_onEvent_(_event_onResult, dt);
end;

//-----------------   Автоустановка ширины столбцов   -----------------
//
// Автоматически выравнивает ширину столбца по ширине таблицы
// ( при индексе равном -1 - все столбцы равномерно)
// ( при индексе равном -2 - все столбцы пропорционально своей ширины)
// ARG(IndexCol)
//
procedure THIMST_ColAction._work_doColAction11;
var   i, idx, Wscroll: integer;
      _Length, TempLength:integer;
      Temp, Temp2: real;
      dt, di: TData;
      sControl: PControl;
      R: TRect;
      l: TListViewOptions;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  idx := ReadInteger(_Data, _data_Index, _prop_Index);
  if (idx < -2) or (idx > sControl.LVColCount - 1) and
     ((sControl.LVStyle <> lvsDetail) or (sControl.LVStyle <> lvsDetailNoHeader)) then exit;
  sControl.BeginUpdate;
  R := SControl.LVSubItemRect(sControl.Count - 1, _prop_MSTControl.clistcount - 1);
  l := sControl.LVOptions;
  if ((R.Top + R.Bottom) > sControl.Height) and not (lvoNoScroll in l) then
    Wscroll := GetSystemMetrics(SM_CXHSCROLL) + 1
  else
    Wscroll := 0;
  TempLength := 0;

  case idx of
  (-2): begin
          for i := 0 to sControl.LVColCount - 1 do
            TempLength := TempLength + sControl.LVColWidth[i];
          Temp := (sControl.Width - Wscroll - sControl.LVColCount) / 100;
          Temp2 := TempLength / 100;
          for i := 0 to sControl.LVColCount - 1 do
          begin
            _Length := Round((sControl.LVColWidth[i] / Temp2) * Temp);
            dtInteger(dt,i);
            dtInteger(di,_Length);
            dt.ldata:= @di;
            _prop_MSTControl.propercol(dt, COL_WIDTH);
          end;
        end;
  (-1): begin
          _Length := (sControl.Width - Wscroll) div sControl.LVColCount - 1;
          for i := 0 to sControl.LVColCount - 1 do
          begin
            dtInteger(dt,i);
            dtInteger(di,_Length);
            dt.ldata:= @di;
            _prop_MSTControl.propercol(dt, COL_WIDTH);
          end;
        end;
    else
    begin
      for i := 0 to sControl.LVColCount - 1 do
        if i <> idx then TempLength := TempLength + sControl.LVColWidth[i] + 2;
      _Length := sControl.Width - Wscroll - TempLength;
      if FMaxColWidth > 0 then _Length:= max(_Length, FMinColWidth);
      dtInteger(dt,idx);
      dtInteger(di,_Length);
      dt.ldata:= @di;
      _prop_MSTControl.propercol(dt, COL_WIDTH);
    end;
  end;
  sControl.EndUpdate;
  _hi_onEvent(_event_onChangeColLst);
end;

// Содержит количество столбцов
//
procedure THIMST_ColAction._var_CountCol;
begin
  if not Assigned(_prop_MSTControl) then exit;
  dtInteger(_Data, _prop_MSTControl.clistcount);
end;

// Содержит индекс последнего столбца в таблице
//
procedure THIMST_ColAction._var_EndIdxCol;
begin
  if not Assigned(_prop_MSTControl) then exit;
  dtInteger(_Data, _prop_MSTControl.clistcount - 1);
end;

procedure THIMST_ColAction._work_doMaxColWidth;
begin
  FMaxColWidth := ToInteger(_Data);
end;

procedure THIMST_ColAction._work_doMinColWidth;
begin
  FMinColWidth := ToInteger(_Data);
end;

procedure THIMST_ColAction._work_doAutoWidthByHeader;
begin
  FAutoWidthByHeader := ReadBool(_Data);
end;

end.