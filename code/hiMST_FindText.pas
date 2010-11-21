unit hiMST_FindText;

interface
     
uses Windows, Kol, Share, Debug, hiMTStrTbl;

type
  THIMST_FindText = class(TDebug)
  private
    FStrFind, FStrReplace: String;
    FCol, FRow: Integer;
    FData_1, FData_2: TData;
  public
    _prop_MSTControl: IMSTControl;
    _prop_ReplaceFind: boolean;
    _prop_SelectFind: boolean;
    _prop_StartRow: integer;
    _prop_StartCol: integer;
    _prop_FindText:string;
    _prop_ReplaceText:string;
    
    _data_StartRow,
    _data_StartCol,
    _data_FindText,
    _data_ReplaceText,
    _event_onFindText: THI_Event;

    destructor Destroy; override;
    procedure _work_doFindText(var _Data: TData; Index: word);
    procedure _work_doFindNext(var _Data: TData; Index: word);
    procedure _work_doEnsureVisible(var _Data:TData; Index:word);
    procedure _work_doSetFocus(var _Data: TData; Index: word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_EndIdx(var _Data:TData; Index:word);
    procedure _var_Index(var _Data:TData; Index:word);
    procedure _var_Select(var _Data:TData; Index:word);
  end;

implementation

function PosABM(const SubStr, S: string; Offset: Integer = 1): Integer;
var
  Ps, lp, ls, i : integer;
  chr: Char;
  BMT: array[Char] of integer;
begin
  ls := Length(S);

  if Length(SubStr) <> 1 then
  begin
    lp := Length(SubStr);
    for i := 0 to 255 do
      BMT[char(i)] := lp;
    for i := 1 to (lp - 1) do
      BMT[SubStr[i]] := lp - i;

    Ps := Offset + lp - 1;

    while Ps <= ls do
      if (SubStr[lp] <> S[Ps]) then
        Ps := Ps + BMT[S[Ps]]
      else
        for i := lp downto 1 do
          if SubStr[i] <> S[Ps - lp + i] then
          begin
            Ps := Ps + BMT[S[Ps]];
            Break;
          end
          else if i = 1 then
          begin
            Result := Ps - lp + 1;
            Exit;
          end;
  end
  else
  begin
    Ps := Offset;
    chr := SubStr[1];

    while Ps <= ls do
      if (S[Ps] <> Chr) then
        Ps := Ps + 1
      else
      begin
        Result := Ps;
        Exit;
      end;
  end;
  Result := 0;
end;

destructor THIMST_FindText.Destroy;
begin
  FreeData(@FData_1);
  FreeData(@FData_2);
  inherited;
end;

//--------------------   MT-поиск вхождений текста   ---------------------
//
// Ищет (заменяет) вхождения текста из потока в таблице (метод не чувствителен к регистру)
// Поиск ведется слева направо и сверху вниз до ближайшего вхождения
// ARG(FindText, StartRow, StartCol, ReplaceText(for ReplaceFind=True)
//
procedure THIMST_FindText._work_doFindText; // проверен
var
  sstr, str, strrepl, S2, S3: string;
  Row,Col,FPos: integer;
  dp,dt,ds: TData;
  d: PData;
  sControl: PControl;
begin
//  if _IsNULL(_Data) then exit;

  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;

  sstr := ReadString(_Data, _data_FindText, _prop_FindText);
  Row := ReadInteger(_Data, _data_StartRow, _prop_StartRow);
  Col := ReadInteger(_Data, _data_StartCol, _prop_StartCol);
  if _prop_ReplaceFind then
    strrepl := ReadString(_Data, _data_ReplaceText, _prop_ReplaceText)
  else 
    strrepl := '';

  FreeData(@FData_1);
  FreeData(@FData_2);
  dtNull(FData_1);   
  dtNull(FData_2);

TRY
  if (sControl.LVColCount = 0) or (sControl.Count = 0) or (sstr = '') or (Col = -1) or (Row = -1) then
  begin
    Row := -1;
    Col := -1;
    S3 := '';
    exit;
  end; 

  str := sstr + #0; 
  Delete(str, length(str), 1);
  if str <> '' then CharLower(PChar(str));

  FStrReplace := strrepl; 
  FStrFind := str;

  repeat
    repeat
      FPos := 1;
      S3 := sControl.LVItems[Row,Col];
      S2 := S3 + #0;
      Delete(S2, length(S2), 1);
      if S2 <> '' then CharLower(PChar(S2));
      FPos := PosABM(str, S2, FPos);
      if FPos <> 0 then
      begin
        while FPos <> 0 do
        begin 
          if _prop_ReplaceFind then
          begin
            Delete(S3, FPos, Length(str));
            if strrepl <> '' then
              Insert(strrepl, S3, FPos);
            sControl.LVItems[Row, Col] := S3;
            S2 := S3 + #0;
            Delete(S2, length(S2), 1);
            if S2 <> '' then CharLower(PChar(S2));
          end;
          if (not _prop_ReplaceFind) or (_prop_ReplaceFind and (strrepl <> '')) then
          begin
            dtInteger(FData_2, FPos);            
            AddMTData(@FData_1, @FData_2, d);
          end;
          if not _prop_ReplaceFind then
            inc(FPos, Length(str))
          else if _prop_ReplaceFind and (strrepl <> '') then
            inc(FPos, Length(strrepl));
          FPos := PosABM(str, S2, FPos);
        end;
        exit;
      end;
      inc(Col);
    until Col = sControl.LVColCount;   
    inc(Row);
    Col := 0;
  until Row = sControl.Count;   
  Row := -1;
  Col := -1;
  S3 := '';
FINALLY
  if (Row >= 0) and _prop_SelectFind then
    sControl.LVCurItem := Row;
  dtInteger(dp, Row);
  dtInteger(dt, Col);
  FCol := Col;
  FRow := Row;
  dtString(ds, S3);
  dp.ldata := @dt;
  dt.ldata := @ds;
  ds.ldata := @FData_1;
  _hi_onEvent_(_event_onFindText, dp);
  if (d <> nil) and not _IsNULL(FData_2) then
    FreeData(d);
END;
end;

//-------------   MT-поиск следующего вхождений текста   --------------
//
// Обрабаытывает и передает параметры методу doFindText для поиска (замены)
// следующего вхождения текста
//
procedure THIMST_FindText._work_doFindNext; // проверен
var
  dp, dt, ds: TData;
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
   
  dtNull(_Data);
  if (FRow <> -1) or (FCol <> -1) then
  begin
    inc(FCol);
    if FCol = _prop_MSTControl.clistcount then
    begin
      FCol := 0;
      inc(FRow);
      if FRow = sControl.Count then
      begin
        FRow := -1;
        FCol := -1;
        FStrFind := '';
      end;
    end;
  end;
  dtString(_Data, FStrFind);
  dtInteger(dt, FRow);
  dtInteger(ds, FCol);
  _Data.ldata := @dt;
  dt.ldata := @ds;
  if _prop_ReplaceFind then
  begin
    dtString(dp, FStrReplace);
    ds.ldata := @dp;      
  end;
  _work_doFindText(_Data, 0);
end;

// Устанавливает фокус на элементе
//
procedure THIMST_FindText._work_doSetFocus;
begin
  if not Assigned(_prop_MSTControl) then exit;
  _prop_MSTControl.setfocus(_Data, 0);
end;

// Делает видимой строку
// ARG(IndexRow)
//
procedure THIMST_FindText._work_doEnsureVisible;
var
  sControl: PControl;
begin
  if (not Assigned(_prop_MSTControl)) or (not _prop_SelectFind) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  sControl.LVMakeVisible(FRow, false);
end;

// Содержит выбранную строку,
// где строка - это набор MT-элементов со значениями каждой колонки
//
procedure THIMST_FindText._var_Select;
var
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  if sControl.LVCurItem = -1 then
     dtNull(_Data)
   else
     _Data := _prop_MSTControl.getstring(sControl.LVCurItem);
end;

// Содержит индекс выделенной строки
//
procedure THIMST_FindText._var_Index;
var
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  dtInteger(_Data, sControl.CurIndex);
end;

// Содержит количество строк в таблице
//
procedure THIMST_FindText._var_Count;
var
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  dtInteger(_Data, sControl.Count);
end;

// Содержит индекс последний строки в таблице
//
procedure THIMST_FindText._var_EndIdx;
var
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  if sControl.Count = 0 then
    dtNull(_Data)
  else
    dtInteger(_Data, sControl.Count - 1);
end;

end.