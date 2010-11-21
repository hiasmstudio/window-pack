unit hiScreen;

interface

uses Windows,Kol,Share,Debug;

type
  THIScreen = class(TDebug)
   private
   public
    _prop_X:word;
    _prop_Y:word;
    _prop_Frequency:word;
    _prop_BitsPerPixel:word;
    _prop_SetChange:byte;    
    _prop_EnumMask:string;

    _data_X:THI_Event;
    _data_Y:THI_Event;
    _data_Frequency:THI_Event;
    _data_BitsPerPixel:THI_Event;
    _event_onEnum:THI_Event;

    procedure _work_doResolution(var _Data:TData; Index:word);
    procedure _work_doFrequency(var _Data:TData; Index:word);
    procedure _work_doBitsPerPixel(var _Data:TData; Index:word);
    procedure _work_doSetScreen(var _Data:TData; Index:word);
    procedure _work_doEnum(var _Data:TData; Index:word);
    procedure _var_Width(var _Data:TData; Index:word);
    procedure _var_Height(var _Data:TData; Index:word);
    procedure _var_CurFrequency(var _Data:TData; Index:word);
    procedure _var_CurBitsPerPixel(var _Data:TData; Index:word);    
    procedure _var_CurDPIX(var _Data:TData; Index:word);
    procedure _var_CurDPIY(var _Data:TData; Index:word);
    procedure _var_TopWorkarea(var _Data:TData; Index:word);
    procedure _var_LeftWorkarea(var _Data:TData; Index:word);
    procedure _var_BottomWorkarea(var _Data:TData; Index:word);
    procedure _var_RightWorkarea(var _Data:TData; Index:word);
        
  end;

implementation

procedure THIScreen._work_doResolution;
var
  dm: TDEVMODE;
begin
  ZeroMemory(@dm, sizeof(TDEVMODE));
  dm.dmSize := sizeof(TDEVMODE);
  dm.dmPelsWidth := ReadInteger(_Data,_data_X,_prop_X);
  dm.dmPelsHeight := ReadInteger(_Data,_data_Y,_prop_Y);
  dm.dmFields := DM_PELSWIDTH or DM_PELSHEIGHT;
  case _prop_SetChange of 
    0: ChangeDisplaySettings(dm, 0);
    1: ChangeDisplaySettings(dm, CDS_UPDATEREGISTRY);
  end;   
end;

procedure THIScreen._work_doFrequency;
var
  dm: TDEVMODE;
begin
  ZeroMemory(@dm, sizeof(TDEVMODE));
  dm.dmSize := sizeof(TDEVMODE);
  dm.dmDisplayFrequency := ReadInteger(_Data,_data_Frequency,_prop_Frequency);
  dm.dmFields := DM_DISPLAYFREQUENCY;
  case _prop_SetChange of 
    0: ChangeDisplaySettings(dm, 0);
    1: ChangeDisplaySettings(dm, CDS_UPDATEREGISTRY);
  end;   
end;

procedure THIScreen._work_doBitsPerPixel;
var
  dm: TDEVMODE;
  bits: word;
begin
  ZeroMemory(@dm, sizeof(TDEVMODE));
  dm.dmSize := sizeof(TDEVMODE);
  bits := ReadInteger(_Data,_data_BitsPerPixel,_prop_BitsPerPixel);
  if (bits <= 4) then bits := 4
  else if (bits > 4) and (bits <= 8) then bits := 8
  else if (bits > 8) and (bits <= 16) then bits := 16
  else if (bits > 16) and (bits <= 24) then bits := 24
  else bits := 32;    
  dm.dmBitsPerPel := bits;
  dm.dmFields := DM_BITSPERPEL;
  case _prop_SetChange of 
    0: ChangeDisplaySettings(dm, 0);
    1: ChangeDisplaySettings(dm, CDS_UPDATEREGISTRY);
  end;   
end;

procedure THIScreen._work_doSetScreen;
var
  dm: TDEVMODE;
  bits: word;
begin
  ZeroMemory(@dm, sizeof(TDEVMODE));
  dm.dmSize := sizeof(TDEVMODE);
  dm.dmPelsWidth := ReadInteger(_Data,_data_X,_prop_X);
  dm.dmPelsHeight := ReadInteger(_Data,_data_Y,_prop_Y);
  dm.dmDisplayFrequency := ReadInteger(_Data,_data_Frequency,_prop_Frequency);
  bits := ReadInteger(_Data,_data_BitsPerPixel,_prop_BitsPerPixel);
  if (bits <= 4) then bits := 4
  else if (bits > 4) and (bits <= 8) then bits := 8
  else if (bits > 8) and (bits <= 16) then bits := 16
  else if (bits > 16) and (bits <= 24) then bits := 24
  else bits := 32;    
  dm.dmBitsPerPel := bits;
  dm.dmFields := DM_PELSWIDTH or DM_PELSHEIGHT or DM_DISPLAYFREQUENCY or DM_BITSPERPEL;  
  case _prop_SetChange of 
    0: ChangeDisplaySettings(dm, 0);
    1: ChangeDisplaySettings(dm, CDS_UPDATEREGISTRY);
  end;   
end;

procedure THIScreen._work_doEnum;
var ModeNum:cardinal;
    dm:_devicemode;
    s:string;
begin
  ModeNum := 0;
  while EnumDisplaySettings(PChar(nil), ModeNum,DM) do
  begin
    Inc(ModeNum);
    s := _prop_EnumMask;
    Replace(s,'%h', int2str(DM.dmPelsHeight));
    Replace(s,'%v', int2str(DM.dmPelsWidth));
    Replace(s,'%bpp', int2str(DM.dmBitsPerPel));
    Replace(s,'%f', int2str(DM.dmDisplayFrequency));
    _hi_OnEvent(_event_onEnum,s);
  end;
end;

procedure THIScreen._var_Width;
begin
   dtInteger(_Data,ScreenWidth);
end;

procedure THIScreen._var_Height;
begin
   dtInteger(_Data,ScreenHeight);
end;

procedure THIScreen._var_CurFrequency;
var   DC:HDC;
begin
   DC := GetDC(0);
   dtInteger(_Data,GetDeviceCaps(DC, VREFRESH));
   ReleaseDC(0,DC);
end;

procedure THIScreen._var_CurBitsPerPixel;
var   DC:HDC;
begin
   DC := GetDC(0);
   dtInteger(_Data,GetDeviceCaps(DC, BITSPIXEL));
   ReleaseDC(0,DC);
end;

procedure THIScreen._var_CurDPIX;
var   DC:HDC;
begin
   DC := GetDC(0);
   dtInteger(_Data,GetDeviceCaps(DC, LOGPIXELSX));
   ReleaseDC(0,DC);
end;

procedure THIScreen._var_CurDPIY;
var   DC:HDC;
begin
   DC := GetDC(0);
   dtInteger(_Data,GetDeviceCaps(DC, LOGPIXELSY));
   ReleaseDC(0,DC);
end;

procedure THIScreen._var_TopWorkarea;
var
  n: TRect;
begin
  SystemParametersInfo(SPI_GETWORKAREA, 0, @n, 0); 
  dtInteger(_Data, n.top);
end;

procedure THIScreen._var_LeftWorkarea;
var
  n: TRect;
begin
  SystemParametersInfo(SPI_GETWORKAREA, 0, @n, 0); 
  dtInteger(_Data, n.left);
end;

procedure THIScreen._var_BottomWorkarea;
var
  n: TRect;
begin
  SystemParametersInfo(SPI_GETWORKAREA, 0, @n, 0); 
  dtInteger(_Data, n.bottom);
end;

procedure THIScreen._var_RightWorkarea;
var
  n: TRect;
begin
  SystemParametersInfo(SPI_GETWORKAREA, 0, @n, 0); 
  dtInteger(_Data, n.right);
end;

end.