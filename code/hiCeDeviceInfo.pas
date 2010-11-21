unit hiCeDeviceInfo;

interface

uses Kol,KolRapi,Share,Windows,Debug;

type
  THICeDeviceInfo = class(TDebug)
   private
    lpSystemInfo:TSystemInfo;
   public
    _event_onInfo:THI_Event;
    
    procedure _work_doGetInfo(var _Data:TData; Index:word);
    procedure _var_ProcArchitecture(var _Data:TData; Index:word);
    procedure _var_ProcLevel(var _Data:TData; Index:word);
    procedure _var_ProcRevision(var _Data:TData; Index:word);
    procedure _var_ScreenWidth(var _Data:TData; Index:word);
    procedure _var_ScreenHeight(var _Data:TData; Index:word);
    procedure _var_NumColors(var _Data:TData; Index:word);
  end;

implementation

procedure THICeDeviceInfo._work_doGetInfo;
begin
  CeGetSystemInfo(@lpSystemInfo);
  _hi_onEvent(_event_onInfo);
end;

procedure THICeDeviceInfo._var_ProcArchitecture;
var S:String;
begin
    case lpSystemInfo.wProcessorArchitecture of
     PROCESSOR_ARCHITECTURE_INTEL: s := 'INTEL';
     PROCESSOR_ARCHITECTURE_MIPS: s := 'MIPS';
     PROCESSOR_ARCHITECTURE_SHX: s := 'SHX';
     PROCESSOR_ARCHITECTURE_ARM: s := 'ARM';
     else s := 'UNKNOWN';
    end;
    dtString(_Data,s);
end;

procedure THICeDeviceInfo._var_ProcLevel;
begin
   dtInteger(_Data,lpSystemInfo.wProcessorLevel);
end;

procedure THICeDeviceInfo._var_ProcRevision;
begin
   dtInteger(_Data,lpSystemInfo.wProcessorRevision);
end;

procedure THICeDeviceInfo._var_ScreenWidth;
begin
   dtInteger(_Data,CeGetDesktopDeviceCaps(HORZRES));
end;

procedure THICeDeviceInfo._var_ScreenHeight;
begin
   dtInteger(_Data,CeGetDesktopDeviceCaps(VERTRES));
end;

procedure THICeDeviceInfo._var_NumColors;
begin
   dtInteger(_Data,CeGetDesktopDeviceCaps(NUMCOLORS));
end;
end.
