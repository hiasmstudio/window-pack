unit hiCeBatteryStatus;

interface

uses Kol,KolRapi,Share,Windows,Debug;

type
  THICeBatteryStatus = class(TDebug)
   private
     lpPowerStatus: TSystemPowerStatusEx;
   public
    _prop_DataFromDriver:boolean;
    _event_onRefresh:THI_Event;

    procedure _work_doRefresh(var _Data:TData; Index:word);
    procedure _var_BattLifePercent(var _Data:TData; Index:word);
    procedure _var_BattLifeTime(var _Data:TData; Index:word);
    procedure _var_BattFullLifeTime(var _Data:TData; Index:word);
    procedure _var_BattFlag(var _Data:TData; Index:word);
  end;

implementation

procedure THICeBatteryStatus._work_doRefresh;
begin
  CeGetSystemPowerStatusEx(@lpPowerStatus,_prop_DataFromDriver);
  _hi_onEvent(_event_onRefresh);
end;

procedure THICeBatteryStatus._var_BattLifePercent;
begin
   dtInteger(_Data,lpPowerStatus.BatteryLifePercent);
end;

procedure THICeBatteryStatus._var_BattLifeTime;
begin
   dtInteger(_Data,lpPowerStatus.BatteryLifeTime);
end;

procedure THICeBatteryStatus._var_BattFullLifeTime;
begin
   dtInteger(_Data,lpPowerStatus.BatteryFullLifeTime);
end;

procedure THICeBatteryStatus._var_BattFlag;
begin
   dtInteger(_Data,lpPowerStatus.BatteryFlag);
end;

end.
