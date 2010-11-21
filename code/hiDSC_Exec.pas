unit hiDSC_Exec;

interface

uses Kol, Share, Debug, DS_client;

type
  THIDSC_Exec = class(TDebug)
   private

   public
    _prop_DSManager: IDataSource;
    _prop_SQL:string;
    _data_SQL:THI_Event;
    _event_onExec:THI_Event;
    _event_onError:THI_Event;

    procedure _work_doExec(var _Data: TData; Index: word);
  end;

implementation

procedure THIDSC_Exec._work_doExec;
var
  err: TData;
begin
  if not Assigned(_prop_DSManager) then exit;
  err := _prop_DSManager.procexec(ReadString(_Data, _data_SQL, _prop_SQL));
  if not _IsNull(err) then
    _hi_onEvent(_event_onError, err)
  else
    _hi_onEvent(_event_onExec);    
end;

end.