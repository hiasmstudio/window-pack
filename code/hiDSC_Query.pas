unit hiDSC_Query;

interface

uses Kol, Share, Debug, DS_client;

type
  THIDSC_Query = class(TDebug)
   private
     procedure callBackFields(list:PStrList);
     procedure callBackData(var Data: TData);
   public
    _prop_DSManager: IDataSource;
    _prop_SQL:string;

    _data_SQL:THI_Event;
    _event_onQuery:THI_Event;
    _event_onColumns:THI_Event;
    _event_onError:THI_Event;

    procedure _work_doQuery(var _Data:TData; Index:word);
  end;

implementation

procedure THIDSC_Query.callBackFields(list: PStrList);
var
  dt,
  ndt: TData;
  s: PData;  
  i: integer;
begin
  if list.Count = 0 then exit; 
  dtNull(dt);
  for i := 0 to list.Count - 1 do
  begin
    dtString(ndt, list.Items[i]); 
    AddMTData(@dt, @ndt, s);
  end;
  _hi_onEvent_(_event_onColumns, dt);
  FreeData(@ndt);
  FreeData(@dt);
end;

procedure THIDSC_Query.callBackData(var Data: TData);
begin
  _hi_onEvent(_event_onQuery, Data);
end;

procedure THIDSC_Query._work_doQuery;
var
  err: TData;
begin
  if not Assigned(_prop_DSManager) then exit;
  err := _prop_DSManager.procquery(ReadString(_Data, _data_SQL, _prop_SQL), callBackFields, callBackData);
  if not _IsNull(err) then
    _hi_onEvent(_event_onError, err);
end;

end.