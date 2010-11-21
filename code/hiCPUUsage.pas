unit hiCPUUsage;

interface

uses Windows,Kol,Share,adCpuUsage;

type
 THICPUUsage = class
 private

 public
  _prop_NumberCPU:integer;
  _event_onUsage:THI_Event;

  constructor Create;
  destructor Destroy; override;
  procedure _work_doCollectCPUData(var _Data:TData; Index:word);
  procedure _work_doReleaseCPUData(var _Data:TData; Index:word);
  procedure _var_CPUCount(var _Data:TData; Index:word);
 end;

implementation

constructor THICPUUsage.Create;
begin
   inherited;
   OpenCPU_Mon;
end;

destructor THICPUUsage.Destroy;
begin
   CloseCPU_Mon;
   inherited;
end;

procedure THICPUUsage._work_doCollectCPUData;
 var
     CPUUsage:real;
begin
    CollectCPUData;
    CPUUsage := GetCPUUsage(_prop_NumberCPU)*100;
    
    if CPUUsage < 0 then CPUUsage := 0;
    _hi_OnEvent(_event_onUsage, Round(CPUUsage));
end;

procedure THICPUUsage._var_CPUCount;
var lpSystemInfo:_SYSTEM_INFO;
begin
    GetSystemInfo(lpSystemInfo);
    dtInteger(_Data,lpSystemInfo.dwNumberOfProcessors);
end;

procedure THICPUUsage._work_doReleaseCPUData;
begin
    ReleaseCPUData;
end;

end.
