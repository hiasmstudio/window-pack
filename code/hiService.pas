unit hiService;

interface

uses Kol,Share,Windows,Debug;

type
  THIService = class
   private
   public
    SStop:boolean;
    _prop_Icon:HICON;
    _prop_Wait:byte;

    _event_onStop:THI_Event;
    _event_onStart:THI_Event;

    procedure Start;
    procedure Stop;
    procedure _work_doStop(var _DAta:TData; Index:word);
   end;

implementation

procedure THIService.Start;
begin
   EventOn;
   InitDo;
   _hi_OnEvent(_event_onStart);
end;

procedure THIService.Stop;
begin
  _hi_OnEvent(_event_onStop);
  EventOff;
end;

procedure THIService._work_doStop;
begin
  SStop := true;
  NewTimer(1).Enabled := true;
end;

end.
