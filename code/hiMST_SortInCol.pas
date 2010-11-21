unit hiMST_SortInCol;

interface
     
uses Windows, Kol, Share, Debug, hiMTStrTbl;

type
  THIMST_SortInCol = class(TDebug)
  private
    FMethodSort: byte;
    SortCol:integer;
    sControl: PControl;
    function _OnCmpText( Sender: PControl; Idx1, Idx2: Integer ): Integer;
    function _OnCmpReal( Sender: PControl; Idx1, Idx2: Integer ): Integer;
    function _OnCmpExt( Sender: PControl; Idx1, Idx2: Integer ): Integer;
  public
    _prop_MSTControl: IMSTControl;

    _data_ExtCmp: THI_Event;
    _event_onChange: THI_Event;

    property _prop_MethodSort: byte write FMethodSort;
    procedure _work_doMethodSort(var _Data: TData; Index: word);

    procedure _work_doSort(var _Data: TData; Index: word);
    procedure _work_doSortDigit(var _Data: TData; Index: word);
    procedure _work_doSortExtCmp(var _Data: TData; Index: word);
  end;

implementation

//Обработчик метода doSort;
//
function THIMST_SortInCol._OnCmpText;
var
  S1, S2: string;
begin
  S1 := Sender.LVItems[ Idx1, SortCol ];
  S2 := Sender.LVItems[ Idx2, SortCol ];
  if FMethodSort = 1 then
    Result := AnsiCompareStrNoCase( S2, S1 )
  else
    Result := AnsiCompareStrNoCase( S1, S2 );
end;

//Обработчик метода doSortDigit;
//
function THIMST_SortInCol._OnCmpReal;
var
  S1, S2: string;
  r: real;
begin
  S1 := Sender.LVItems[ Idx1, SortCol ];
  S2 := Sender.LVItems[ Idx2, SortCol ];
  r := str2double(S1) - str2double(S2);
  if FMethodSort = 1 then
    Result := ord(r < 0) - ord(r > 0)
  else
    Result := ord(r > 0) - ord(r < 0);
end;

//Обработчик метода doSortExtCmp;
//
function THIMST_SortInCol._OnCmpExt;
var
  dt1, dt2: TData;
  r: real;
begin
  dtString(dt1, Sender.LVItems[ Idx1, SortCol ]);
  dtString(dt2, Sender.LVItems[ Idx2, SortCol ]);
  dt1.ldata := @dt2;
  _ReadData(dt1, _data_ExtCmp);
  r := ToReal(dt1);
  if FMethodSort = 1 then
    Result := ord(r < 0) - ord(r > 0)
  else
    Result := ord(r > 0) - ord(r < 0);
end;

// Сортирует столбец, согласно выбрнного MethodSort
// ARG(IndexCol)
//
procedure THIMST_SortInCol._work_doSort;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  sControl.OnCompareLVItems := _OnCmpText;
  SortCol := ToInteger(_Data);
  sControl.LVSort;
  _hi_onEvent(_event_onChange);
end;

// Сортирует столбец как число, согласно выбрнного MethodSort
// ARG(IndexCol)
//
procedure THIMST_SortInCol._work_doSortDigit;
var
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  sControl.OnCompareLVItems := _OnCmpReal;
  SortCol := ToInteger(_Data);
  sControl.LVSort;
  _hi_onEvent(_event_onChange);
end;

// Сортирует столбец, используя для сравнения значение из ExtCmp: >0, =0, или <0, согласно выбрнного MethodSort
// ARG(IndexCol)
//
procedure THIMST_SortInCol._work_doSortExtCmp;
var
  sControl: PControl;
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  sControl.LVMakeVisible(sControl.LVCurItem, false);
  sControl.OnCompareLVItems := _OnCmpExt;
  SortCol := ToInteger(_Data);
  sControl.LVSort;
  _hi_onEvent(_event_onChange);
end;

procedure THIMST_SortInCol._work_doMethodSort;
begin
  FMethodSort := ToInteger(_Data);
end;

end.