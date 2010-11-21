unit hiSleep;

interface

uses Kol,Share,Windows,Debug;

type
  THISleep = class(TDebug)
   private
   public
    _prop_Delay:integer;
    _event_onSleep:THI_Event;

    procedure _work_doSleep(var _Data:TData; Index:word);
    procedure _work_doSleepMks(var _Data:TData; Index:word);
  end;

implementation

procedure THISleep._work_doSleep;
var sp,ep:int64;
begin
   QueryPerformanceCounter(sp);
   repeat
     QueryPerformanceCounter(ep);
   until ep - sp > _prop_Delay;
   _hi_OnEvent(_event_onSleep,_Data);
end;

procedure THISleep._work_doSleepMks;
var sp,ep,cnt:int64;
begin
   QueryPerformanceCounter(sp);
   QueryPerformanceFrequency(cnt);
   cnt := cnt div 1000000;
   repeat
     QueryPerformanceCounter(ep);
   until (ep - sp)div cnt > _prop_Delay;
   _hi_OnEvent(_event_onSleep,_Data);
end;

end.
