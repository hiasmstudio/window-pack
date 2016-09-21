unit hiMST_Clear;

interface
     
uses Kol, Share, Debug, hiMTStrTbl;

type
  THIMST_Clear = class(TDebug)
  private

  public
    _prop_MSTControl: IMSTControl;

    _prop_ClearAll: boolean;
    _event_onChange: THI_Event;

    procedure _work_doClear(var _Data: TData; Index: word);
    procedure _work_doClearAll(var _Data: TData; Index: word);    
  end;

implementation

// Очищает таблицу
//
procedure THIMST_Clear._work_doClear;
var
  sControl: PControl;
  l: TListViewOptions;  
  i, Item: integer;
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
  if _prop_ClearAll then
  begin
    repeat
      sControl.LVColDelete(sControl.LVColCount - 1);
    until sControl.LVColCount <= 0;
    _prop_MSTControl.clistclear;
  end;
  l := sControl.LVOptions;
  if (lvoOwnerData in l) then
    for i := 0 to sControl.LVPerPage - 1 do
      sControl.LVItemAdd('');  
  sControl.EndUpDate;
  _hi_onEvent(_event_onChange);
end;

procedure THIMST_Clear._work_doClearAll;
begin
  _prop_ClearAll := ReadBool(_Data);
end;

end.