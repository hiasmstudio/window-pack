unit hiInformer;

interface

uses Kol,Share,Debug;

type
  THIInformer = class(TDebug)
   private
   public
    _prop_Data:string;

    _event_onInfo:THI_Event;
    _event_onContinue:THI_Event;

    procedure _work_doInfo(var _Data:TData; Index:word);
  end;

implementation

procedure THIInformer._work_doInfo;
begin
   _hi_OnEvent(_event_onInfo,_prop_Data);
   _hi_CreateEvent_(_Data,@_event_onContinue);
end;

end.
