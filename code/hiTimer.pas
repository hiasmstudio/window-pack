unit hiTimer;

interface

uses Kol,Share,Debug;

type
  THITimer = class(TDebug)
   private
    flag:integer;
    FTimer:PTimer;
    AutoStop:integer;
    AutoStopDEF:integer;
    procedure SetInterval(Value:integer);
    procedure SetEnable(Value:boolean);
    procedure SetAutoStop(Value:integer);
    procedure OnTimer(Obj:PObj);
    procedure OnStop;
   public
    _prop_OverCall:byte;
    _event_onTimer:THI_Event;
    _event_onStop:THI_Event;
    constructor Create;
    destructor Destroy; override;
    procedure _work_doTimer(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _work_doStopAll(var _Data:TData; Index:word);
    procedure _work_doInterval(var _Data:TData; Index:word);
    procedure _work_doAutoStop(var _Data:TData; Index:word);
    property  _prop_Interval:integer write SetInterval;
    property  _prop_Enable:boolean write SetEnable;
    property  _prop_AutoStop:integer write SetAutoStop; 
  end;

implementation

constructor THITimer.Create;
begin
   inherited Create;
   FTimer := NewTimer(1000);
   FTimer.Enabled := false;
   FTimer.OnTimer := onTimer;
   flag := 0;
end;

destructor THITimer.Destroy;
begin
// Этот костыль связан с некооректностью уничтожения класса в FPC
{$ifndef F_P}
   FTimer.Free;
{$endif}
   inherited Destroy;
end;

procedure THITimer._work_doTimer;
begin
   AutoStop := AutoStopDEF;
   FTimer.Enabled := true;
end;

procedure THITimer._work_doStop;
begin
   OnStop;
end;

procedure THITimer._work_doStopAll;
begin
   flag := 0;
   OnStop;
end;

procedure THITimer._work_doInterval;
begin
   FTimer.Interval := ToInteger(_Data);
end;

procedure THITimer._work_doAutoStop;  
begin                                 
   AutoStopDEF := ToInteger(_Data);
   AutoStop:=AutoStopDEF;
end;                                  

procedure THITimer.SetInterval;
begin
   FTimer.Interval := Value;
end;

procedure THITimer.SetEnable;
begin
   FTimer.Enabled := Value;
end;

procedure THITimer.SetAutoStop;
begin                           
   AutoStop:=Value;
   AutoStopDEF:=Value;
end;                            

procedure THITimer.OnTimer;
var f:boolean;
begin
   inc(flag); 
   if flag > 1 then begin 
      if _prop_OverCall=0 then dec(flag);
      exit;
   end;
   repeat
      if AutoStop >= 0 then dec(AutoStop);
      f := AutoStop = 0;
      _hi_OnEvent(_event_onTimer);
      if f then begin 
         flag := 0;
         OnStop;
      end;
      if flag > 0 then dec(flag);
   until flag = 0;
end;

procedure THITimer.OnStop;
begin
    FTimer.Enabled := false;
   _hi_OnEvent(_event_onStop);
end;

end.
