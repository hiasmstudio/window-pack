unit hiTimeCounter;

interface

uses windows,Kol,Share,Debug,mmsystem;

type
  THITimeCounter = class(TDebug)
   private
    sp:int64;
    FCounter:cardinal;
   public
    _prop_Precision:byte;
    _event_onStop:THI_Event;
    _event_onStart:THI_Event;

    procedure _work_doStart0(var _Data:TData; Index:word);
    procedure _work_doStart1(var _Data:TData; Index:word);
    procedure _work_doStop0(var _Data:TData; Index:word);
    procedure _work_doStop1(var _Data:TData; Index:word);
  end;

implementation

procedure THITimeCounter._work_doStart0;
begin
   FCounter := timeGetTime;
   _hi_CreateEvent_(_Data,@_event_onStart);
end;

procedure THITimeCounter._work_doStart1;
begin
   QueryPerformanceCounter(sp);
   _hi_CreateEvent_(_Data,@_event_onStart);
end;

procedure THITimeCounter._work_doStop0;
begin
   _hi_CreateEvent(_Data,@_event_onStop,integer(timeGetTime - FCounter));
end;

procedure THITimeCounter._work_doStop1;
var ep,cnt:int64;
begin
   QueryPerformanceCounter(ep);
   QueryPerformanceFrequency(cnt);
   cnt := cnt div 1000000;
   _hi_CreateEvent(_Data,@_event_onStop,integer((ep-sp)div cnt));
end;

end.
