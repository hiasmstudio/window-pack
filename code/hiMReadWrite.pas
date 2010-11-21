unit hiMReadWrite;

interface

uses Kol, Share, Debug, hiDS_StaticData;

type
  THIMReadWrite = class(TDebug)
   private
    idx: integer;
    id: pointer;    
    data: TDataArray;
   public
    _prop_DataSource: IDS_Table;
    _prop_Column: string;
    _prop_Index: integer;

    _data_Index: THI_Event;
    _data_Value: THI_Event;
    _event_onRead: THI_Event;

    procedure _work_doRead(var _Data: TData; Index: word);
    procedure _work_doWrite(var _Data: TData; Index: word);    
    procedure _work_doColumn(var _Data: TData; Index: word);
    procedure _var_Item(var _Data: TData; Index: word);
    procedure _var_Count(var _Data: TData; Index: word);        
  end;

implementation

procedure THIMReadWrite._work_doRead;
begin
  if not assigned(_prop_DataSource) then exit;
  id := _prop_DataSource.init();
  idx := _prop_DataSource.columns(id).indexOf(_prop_Column);
  _prop_DataSource.readidx(id, data, ReadInteger(_Data, _data_Index, _prop_Index));
  if idx >= 0 then _hi_onEvent_(_event_onRead, data[idx]);
  _prop_DataSource.close(id);
end;

procedure THIMReadWrite._work_doWrite;
begin
  if not assigned(_prop_DataSource) then exit;
  id := _prop_DataSource.init();
  idx := _prop_DataSource.columns(id).indexOf(_prop_Column);
  _prop_DataSource.writeidx(id, ReadInteger(_Data, _data_Index, _prop_Index), idx, ReadData(_Data, _data_Value));
  _prop_DataSource.close(id); 
end;

procedure THIMReadWrite._var_Item;
begin
  _Data := data[idx];
end;

procedure THIMReadWrite._var_Count;
var pt: pointer;
begin
  if not assigned(_prop_DataSource) then exit;
  pt := _prop_DataSource.init();
  dtInteger(_Data, _prop_DataSource.count(pt));
  _prop_DataSource.close(pt);  
end;

procedure THIMReadWrite._work_doColumn;
begin
  _prop_Column := ToString(_Data);
end;

end.