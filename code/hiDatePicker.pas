unit hiDatePicker; {Календарь ver 4.51}

interface

uses Windows,Messages,Kol,Share,Win;

const
   ICC_DATE_CLASSES     = $00000100;

   DTS_SHORTDATEFORMAT  = $0000;
   DTS_UPDOWN           = $0001;
   DTS_SHOWNONE         = $0002;
   DTS_LONGDATEFORMAT   = $0004;
   DTS_TIMEFORMAT       = $0009;
   DTS_APPCANPARSE      = $0010;
   DTS_RIGHTALIGN       = $0020;
   //Notification codes
   DTN_FIRST            = 0-760;
   DTN_DATETIMECHANGE   = DTN_FIRST + 1;
   DTN_USERSTRINGA      = DTN_FIRST + 2;
   DTN_WMKEYDOWN        = DTN_FIRST + 3;
   DTN_FORMATA          = DTN_FIRST + 4;
   DTN_FORMATQUERY      = DTN_FIRST + 5;
   DTN_DROPDOWN         = DTN_FIRST + 6;
   DTN_CLOSEUP          = DTN_FIRST + 7;
   NM_RELEASEDCAPTURE   = -16;
   MCN_SELCHANGE        = -749;
   //Messages
   DTM_FIRST            = $1000;
   DTM_GETSYSTEMTIME    = DTM_FIRST + 1;
   DTM_SETSYSTEMTIME    = DTM_FIRST + 2;
   DTM_SETFORMATA       = DTM_FIRST + 5;
   DTM_SETMCCOLOR       = DTM_FIRST + 6;
   DTM_GETMCCOLOR       = DTM_FIRST + 7;
   DTM_GETMONTHCAL      = DTM_FIRST + 8;
   DTM_SETMCFONT        = DTM_FIRST + 9;   

   GDT_VALID            = 0;
   GDT_NONE             = 1;
   //Color schemma
   MCSC_BACKGROUND   =  0;   // the background color (between months)
   MCSC_TEXT         =  1;   // the dates
   MCSC_TITLEBK      =  2;   // background of the title
   MCSC_TITLETEXT    =  3;
   MCSC_MONTHBK      =  4;   // background within the month cal
   MCSC_TRAILINGTEXT =  5;   // the text color of header & trailing days

type
TPickerOption = (piShortDate,piUpDown,piCheckBox,piLongDate,piTime,piAppCanParse,piRightAlign);
TPickerOptions = Set of TPickerOption;

type

INITCOMMONCONTROLEX = packed record
    dwSize: DWORD;             // size of this structure
    dwICC: DWORD;              // flags indicating which classes to be initialized
end;

NMHDR = packed record
   hwndFrom: HWND;
   idFrom: UINT;
   code: Integer;
end;

TNMHdr = NMHDR;
PNMHdr = ^TNMHdr;

NMDATETIMECHANGE = packed record
   nmhdr: TNmHdr;
   dwFlags: DWORD;         // GDT_VALID or GDT_NONE
   st: TSystemTime;        // valid iff dwFlags = GDT_VALID
end;

PNMDateTimeChange = ^TNMDateTimeChange;
TNMDateTimeChange = NMDATETIMECHANGE;

TInitCommonControlsEx = INITCOMMONCONTROLEX;

const PickerFlags : array[TPickerOption] of Integer = (DTS_SHORTDATEFORMAT,DTS_UPDOWN,DTS_SHOWNONE,
                                                       DTS_LONGDATEFORMAT,DTS_TIMEFORMAT,
                                                       DTS_APPCANPARSE,DTS_RIGHTALIGN);
type
 THIDatePicker = class(THIWin)
   private
     opt: TPickerOptions;
     flag: boolean;
   public
     _prop_Style:byte;
     _prop_AlignPicker:byte;
     _prop_BackgroundColor:TColor;
     _prop_TitleBkColor:TColor;
     _prop_TitleTextColor:TColor;
     _prop_MonthBkColor:TColor;
     _prop_TrailingColor:TColor;
     _prop_DateFormat:integer;
     _prop_DateMode:byte;

     _prop_Time:boolean;
     _prop_SetDateOnChange:boolean;

     _data_Data:THI_Event;
     _event_OnChange:THI_Event;

     procedure Init; override;
     procedure _work_doSetDate(var _Data:TData; Index:word);
     procedure _var_DateTime(var _Data:TData; Index:word);
     procedure _var_CurrentDateTime(var _Data:TData; Index:word);
end;

implementation

function InitCommonControlsEx(var ICC: TInitCommonControlsEx) : Bool;stdcall;external 'comctl32.dll';

function PickerWndProc(Sender : PControl;var Msg:TMsg;var Rslt:Integer):Boolean;
var
  NMDC: PNMDateTimeChange;
  fControl: THIDatePicker;
  dt: TDateTime;
begin
  Result := False;
  fControl:= THIDatePicker(Sender.Tag);
  case Msg.message of
    WM_NOTIFY : begin
                  NMDC := PNMDateTimeChange(Msg.lParam);
                  if (NMDC.nmhdr.code = DTN_DATETIMECHANGE) and (NMDC.dwFlags = GDT_VALID) and fControl.flag then
                  begin
                    SystemTime2DateTime(NMDC.st, dt);
                    _hi_OnEvent(fControl._event_onChange, dt);
                    fControl.flag := false;
                  end;  
                end;  
    WM_PAINT: fControl.flag := true;
  end;
end;

procedure THIDatePicker.Init;
var   Flags: Integer;
      icex: INITCOMMONCONTROLEX;
begin
   flag := false;
   opt:=[];
//Определение параметров
   if _prop_DateFormat=0 then include(opt,piShortDate) else include(opt,piLongDate);
   if _prop_AlignPicker = 1 then include(opt,piRightAlign);
   if _prop_DateMode = 1    then include(opt,piUpDown);
   if _prop_Time            then include(opt,piTime);
   
//Конец определения
   icex.dwSize := sizeof(INITCOMMONCONTROLEX);
   icex.dwICC := ICC_DATE_CLASSES;
   InitCommonControlsEx(icex);
   Flags := MakeFlags(@opt,PickerFlags);
   Control:= _NewCommonControl(FParent,'SysDateTimePick32',
             WS_VISIBLE or WS_CHILD or WS_TABSTOP or Flags,True,nil);
   InitCommonControlCommonNotify(Control);
   Control.ExStyle:= Control.ExStyle or WS_EX_CLIENTEDGE;
   Control.Tabstop := True;
   Control.Tag := LongInt(Self);
   Control.AttachProc(PickerWndProc);

inherited;
   if _prop_Style = 0 then exit;
   with Control{$ifndef F_P}^{$endif} do begin
      Perform(DTM_SETMCCOLOR,MCSC_BACKGROUND,   Color2RGB(_prop_Color));   
      Perform(DTM_SETMCCOLOR,MCSC_TITLEBK,      Color2RGB(_prop_TitleBkColor));
      Perform(DTM_SETMCCOLOR,MCSC_TEXT,         Color2RGB(Font.Color));   
      Perform(DTM_SETMCCOLOR,MCSC_TITLETEXT,    Color2RGB(_prop_TitleTextColor));
      Perform(DTM_SETMCCOLOR,MCSC_MONTHBK,      Color2RGB(_prop_MonthBkColor));
      Perform(DTM_SETMCCOLOR,MCSC_TRAILINGTEXT, Color2RGB(_prop_TrailingColor));      
   end;
end;

procedure THIDatePicker._work_doSetDate;
var   dt: TDateTime;
      st: TSystemTime;
begin
   dt:= ReadReal(_Data,_data_Data,0);
   DateTime2SystemTime(dt,st);
   Control.Perform(DTM_SETSYSTEMTIME,GDT_VALID,Longint(@st));   
   if _prop_SetDateOnChange then _hi_OnEvent(_event_onChange);
end;

procedure THIDatePicker._var_DateTime;
var   dt: TDateTime;
      st: TSystemTime;
begin
   Control.Perform(DTM_GETSYSTEMTIME,0,Longint(@st));
   SystemTime2DateTime(st,dt);
   dtReal(_Data, dt);
end;

procedure THIDatePicker._var_CurrentDateTime;
var   dt: TDateTime;
      st: TSystemTime;
begin
   GetLocalTime(st);
   SystemTime2DateTime(st, dt);
   dtReal(_Data, dt);
end;

end.
