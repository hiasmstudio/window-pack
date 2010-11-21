unit hiMMTimer; { Компонент MMTimer (независимый таймер) ver 1.20 }

interface

uses Kol,Share,Debug;

type
  THIMMTimer = class(TDebug)
   private
    flag:boolean;
    FTimer:PMMTimer;
    AutoStop:integer;
    AutoStopDEF:integer;
    procedure SetInterval(Value:integer);
    procedure SetEnable(Value:boolean);
    procedure SetResolution(Value:integer);
    procedure SetAutoStop(Value:integer);
    procedure OnTimer(Obj:PObj);
    procedure OnStop;
   public
    _event_onTimer:THI_Event;
    _event_onStop:THI_Event;
    constructor Create;
    destructor Destroy; override;
    procedure _work_doTimer(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _work_doInterval(var _Data:TData; Index:word);
    procedure _work_doAutoStop(var _Data:TData; Index:word);
    property  _prop_Interval:integer write SetInterval;
    property  _prop_Enable:boolean write SetEnable;
    property  _prop_Resolution:integer write SetResolution;
    property  _prop_AutoStop:integer write SetAutoStop; 
  end;

implementation

constructor THIMMTimer.Create;
begin
   inherited Create;
   FTimer := NewMMTimer(1000);
   FTimer.Enabled := false;
   FTimer.OnTimer := onTimer;
   flag := false;
end;

destructor THIMMTimer.Destroy;
begin
   FTimer.free;
   inherited Destroy;
end;

procedure THIMMTimer._work_doTimer;
begin
   AutoStop := AutoStopDEF;
   FTimer.Enabled := true;
end;

procedure THIMMTimer._work_doStop;
begin
   OnStop;
end;

procedure THIMMTimer._work_doInterval;
begin
   FTimer.Interval := ToInteger(_Data);
end;

procedure THIMMTimer._work_doAutoStop;  
begin                                 
   AutoStopDEF := ToInteger(_Data);
   AutoStop:=AutoStopDEF;
end;                                  

procedure THIMMTimer.SetInterval;
begin
   FTimer.Interval := Value;
end;

procedure THIMMTimer.SetEnable;
begin
   FTimer.Enabled := Value;
end;

procedure THIMMTimer.SetResolution;
begin
   FTimer.Resolution := Value;
end;

procedure THIMMTimer.SetAutoStop;
begin                           
   AutoStop:=Value;
   AutoStopDEF:=Value;
end;                            

procedure THIMMTimer.OnTimer;
var f:boolean;
begin
   if flag then exit;
   flag := true;
   if AutoStop >= 0 then dec(AutoStop);
   f := AutoStop = 0;   
   _hi_OnEvent(_event_onTimer);
   if f then OnStop;
   flag := false;
end;

procedure THIMMTimer.OnStop;
begin
    FTimer.Enabled := false;
   _hi_OnEvent(_event_onStop);
end;

end.