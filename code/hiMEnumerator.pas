unit hiMEnumerator;

interface

uses Kol, Share, Debug, hiDS_StaticData;

type
  THIMEnumerator = class(TDebug)
   private
    idx,
    curitem: integer;
    id: pointer;    
    data: TDataArray;
   public
    _prop_DataSource: IDS_Table;
    _prop_Column: string;

    _event_onEnum: THI_Event;

    procedure _work_doEnum(var _Data: TData; Index: word);
    procedure _work_doColumn(var _Data: TData; Index: word);
    procedure _var_Item(var _Data: TData; Index: word);    
    procedure _var_Index(var _Data: TData; Index: word);    
  end;

implementation

procedure THIMEnumerator._work_doEnum;
begin
  if not assigned(_prop_DataSource) then exit;
  id := _prop_DataSource.init();
  idx := _prop_DataSource.columns(id).indexOf(_prop_Column); // for future...
  //DataSource.count(id) 
  curitem := -1;
  while _prop_DataSource.row(id, data) do
  begin
    inc(curitem);
    _hi_onEvent_(_event_onEnum, data[idx]);
  end;  
  _prop_DataSource.close(id); 
end;

procedure THIMEnumerator._var_Item;
begin
  _Data := data[idx];
end;

procedure THIMEnumerator._var_Index;
begin
  dtInteger(_Data, curitem);
end;

procedure THIMEnumerator._work_doColumn;
begin
  _prop_Column := ToString(_Data);
end;

end.
