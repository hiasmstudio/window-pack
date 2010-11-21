unit hiSCR;

interface

uses Windows,Kol,Share,Debug,Messages;

type
  THISCR = class(TDebug)
   private
   public
    _prop_FileSCR:string;
    _prop_Interval:string;
    _prop_SetChange:byte;     

    _data_Interval:THI_Event;
    _data_FileSCR:THI_Event;

    procedure _work_doStartSCR(var _Data:TData; Index:word);
    procedure _work_doDisableSCR(var _Data:TData; Index:word);
    procedure _work_doEnableSCR(var _Data:TData; Index:word);
    procedure _work_doDisablePass(var _Data:TData; Index:word);
    procedure _work_doEnablePass(var _Data:TData; Index:word);
    procedure _work_doFileSCR(var _Data:TData; Index:word);
    procedure _work_doInterval(var _Data:TData; Index:word);
    procedure _var_varInterval(var _Data:TData; Index:word);
    procedure _var_varFileSCR(var _Data:TData; Index:word);
    procedure _var_EnableSCR(var _Data:TData; Index:word);
    procedure _var_EnablePass(var _Data:TData; Index:word);
  end;

implementation


procedure THISCR._work_doStartSCR;
begin
  SendMessage(Applet.Handle, WM_SYSCOMMAND, SC_SCREENSAVE, 0);
end;

procedure THISCR._work_doDisableSCR;
begin
  case _prop_SetChange of 
    0: SystemParametersInfo(SPI_SETSCREENSAVEACTIVE, 0, nil, 0);
    1: SystemParametersInfo(SPI_SETSCREENSAVEACTIVE, 0, nil, SPIF_UPDATEINIFILE);
  end;  
end;

procedure THISCR._work_doEnableSCR;
begin
  case _prop_SetChange of 
    0: SystemParametersInfo(SPI_SETSCREENSAVEACTIVE, 1, nil, 0);
    1: SystemParametersInfo(SPI_SETSCREENSAVEACTIVE, 1, nil, SPIF_UPDATEINIFILE);
  end;  
end;

procedure THISCR._work_doDisablePass;
var
 reg:HKey;
begin
  reg:=RegKeyOpenWrite(HKEY_CURRENT_USER,'Control Panel\Desktop');
  RegKeySetStr(reg,'ScreenSaverIsSecure','0');
  RegKeyClose(reg);
end;

procedure THISCR._work_doEnablePass;
var
  reg:HKey;
begin
  reg := RegKeyOpenWrite(HKEY_CURRENT_USER,'Control Panel\Desktop');
  RegKeySetStr(reg,'ScreenSaverIsSecure','1');
  RegKeyClose(reg);
end;

procedure THISCR._work_doFileSCR;
var
  reg:HKey;
  FileSCR:string;
begin
  FileSCR := ReadString(_Data,_data_FileSCR,_prop_FileSCR);
  reg := RegKeyOpenWrite(HKEY_CURRENT_USER,'Control Panel\Desktop');
  if FileSCR = '' then
    RegKeyDeleteValue(reg, 'SCRNSAVE.EXE')
  else  
    RegKeySetStr(reg, 'SCRNSAVE.EXE', FileSCR);
  RegKeyClose(reg);
end;

procedure THISCR._work_doInterval;
var
  Interval: Cardinal;
begin
  Interval := str2int(ReadString(_Data,_data_Interval,_prop_Interval));
  case _prop_SetChange of 
    0: SystemParametersInfo(SPI_SETSCREENSAVETIMEOUT, Interval, nil, 0); 
    1: SystemParametersInfo(SPI_SETSCREENSAVETIMEOUT, Interval, nil, SPIF_UPDATEINIFILE);
  end;  
end;

procedure THISCR._var_varInterval;
var
  ScreenSaveTimeOut: integer;
begin
  SystemParametersInfo(SPI_GETSCREENSAVETIMEOUT, 0, @ScreenSaveTimeOut, 0);
  dtInteger(_Data, ScreenSaveTimeOut);
end;

procedure THISCR._var_varFileSCR;
var
  reg:HKey;
begin
  reg := RegKeyOpenRead(HKEY_CURRENT_USER,'Control Panel\Desktop');
  dtString(_Data,RegKeyGetStr(reg,'SCRNSAVE.EXE'));
  RegKeyClose(reg);
end;

procedure THISCR._var_EnableSCR;
var
  Bl : boolean;
begin
  SystemParametersInfo(SPI_GETSCREENSAVEACTIVE, 0, @Bl, 0);
  dtInteger(_Data, ord(Bl));
end;

procedure THISCR._var_EnablePass;
var
  reg:HKey;
begin
  reg := RegKeyOpenRead(HKEY_CURRENT_USER,'Control Panel\Desktop');
  dtInteger(_Data,Str2Int(RegKeyGetStr(reg,'ScreenSaverIsSecure')));
  RegKeyClose(reg);
end;

end.
