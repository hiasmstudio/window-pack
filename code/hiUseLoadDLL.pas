unit hiUseLoadDLL;

interface
     
uses Kol, Share, Debug, hiDynamicHiDLL;

type
  THIUseLoadDLL = class(TDebug)
  private
  public
    _prop_LoadDllManager: ILoadDllManager;
    _prop_DLLName:string;
    
    _data_DLLName,
    _event_onLoad,
    _event_onUnLoad: THI_Event;
    
    procedure _work_doLoad(var _Data: TData; Index: word);
    procedure _work_doUnLoad(var _Data: TData; Index: word);
    procedure _var_Handle(var _Data: TData; Index: word);
  end;

implementation

procedure THIUseLoadDLL._work_doLoad;
begin
  if not Assigned(_prop_LoadDllManager) then exit;
  _prop_LoadDllManager.loaddll(ExtractFileNameWOext(ReadString(_Data, _data_DLLName, _prop_DllName)));
  _hi_onEvent(_event_onLoad);
end;

procedure THIUseLoadDLL._work_doUnLoad;
begin
  if not Assigned(_prop_LoadDllManager) then exit;
  _prop_LoadDllManager.unloaddll;
  _hi_onEvent(_event_onUnLoad);
end;

procedure THIUseLoadDLL._var_Handle;
begin
  if Assigned(_prop_LoadDllManager) then
    dtInteger(_Data, _prop_LoadDllManager.getfid)
  else
    dtNull(_Data);
end;

end.