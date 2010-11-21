unit hiCeInit;

interface

uses Kol,KOLRapi,Share,Windows,Debug;

type
  THICeInit = class(TDebug)
   private
    ri: TRapiInit;
    hr: HRESULT;
    fInitialized,fConnected: Boolean;
    dwRapiInit: DWORD;
    function OpenSession(dwTimeOut: Integer): Integer;
    procedure CloseSession;
   public
    _prop_TimeOut:Integer;
    _event_onInit:THI_Event;
    _data_TimeOut:THI_Event;

    destructor Destroy; override;
    procedure _work_doInit(var _Data:TData; Index:word);
    procedure _work_doUnInit(var _Data:TData; Index:word);
    procedure _work_doSyncStart(var _Data:TData; Index:word);
    procedure _work_doSyncStop(var _Data:TData; Index:word);
    procedure _var_Active(var _Data:TData; Index:word);
  end;

implementation

destructor THICeInit.Destroy;
begin
  CloseSession; 
  inherited; 
end;

function THICeInit.OpenSession(dwTimeOut: Integer): Integer;//HRESULT;
begin
  if not fInitialized then
   begin
     ri.cbSize := sizeof(ri);
     hr := CeRapiInitEx(ri);
     if SUCCEEDED(hr) then fInitialized := true else
      begin
        Result := 1; //ActiveSync not in work/installed?
        Exit;
      end;
   end;
   dwRapiInit := MsgWaitForMultipleObjects(1, ri.heRapiInit, FALSE, dwTimeOut, QS_ALLINPUT);
   //dwRapiInit := WaitForSingleObject(ri.heRapiInit,dwTimeOut);
   case dwRapiInit of
     WAIT_OBJECT_0:           //All right, heRapiInit signaled
      if SUCCEEDED(ri.hrRapiInit) then
       begin
        fConnected := true;
        //hr := ri.hrRapiInit;
        Result := 0;
       end else Result := 4;
     WAIT_OBJECT_0 + 1:       //Need to process the messages
      Result := 2;
     WAIT_TIMEOUT:            //Device not connected, time is out
      Result := 3;
     else Result := 4;
   end;
   //Result := hr;
end;

procedure THICeInit.CloseSession;
begin
  fInitialized := false;
  fConnected := false;
  CeRapiUninit;
end;

procedure THICeInit._work_doInit;
begin
  _hi_OnEvent(_event_onInit,OpenSession(ReadInteger(_Data,_data_TimeOut,_prop_TimeOut)));
end;

procedure THICeInit._work_doUnInit;
begin
  CloseSession;
end;

procedure THICeInit._work_doSyncStart;
begin
  CeSyncStart(nil);
end;

procedure THICeInit._work_doSyncStop;
begin
  CeSyncStop;
end;

procedure THICeInit._var_Active;
begin
  dtInteger(_Data,byte(fConnected));
end;


end.
