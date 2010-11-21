unit hiDSC_QueryScalar;

interface

uses Kol, Share, Debug, DS_client;

type
  THIDSC_QueryScalar = class(TDebug)
   private
     FData: TData;
   public
    _prop_DSManager: IDataSource;
    _prop_SQL:string;

    _data_SQL:THI_Event;
    _data_dbHandle:THI_Event;
    _event_onError:THI_Event;
    _event_onQuery:THI_Event;

    procedure _work_doQuery(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

procedure THIDSC_QueryScalar._work_doQuery;
var
  err: TData;
begin
  if not Assigned(_prop_DSManager) then exit;
  dtString(FData, '');
  err := _prop_DSManager.procqueryscalar(ReadString(_Data, _data_SQL, _prop_SQL), FData);
  if not _IsNull(err) then
    _hi_onEvent(_event_onError, err)
  else
    begin
      err := FData;
      _hi_onEvent(_event_onQuery, err);
    end;    
end;
       
procedure THIDSC_QueryScalar._var_Result;
begin
  _Data := FData;
end;

end.