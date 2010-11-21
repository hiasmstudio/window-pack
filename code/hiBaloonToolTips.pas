unit hiBaloonToolTips;

interface

uses Messages,Windows,Kol,Share,Debug;

type
  THIBaloonToolTips = class(TDebug)
   private
    hToolTip:HWND;
    ti: TToolInfo;
    hintbuffer:array[0..1023] of Char;
   public
    _prop_Text:string;
    _prop_Title:string;
    _prop_Icon:byte;
    _prop_Mode:byte;

    _data_Text:THI_Event;
    _data_Handle:THI_Event;
    _data_Point:THI_Event;

    procedure _work_doCreate(var _Data:TData; Index:word);
    procedure _work_doDestroy(var _Data:TData; Index:word);
    procedure _work_doShow(var _Data:TData; Index:word);
  end;

implementation

const
  TTS_ALWAYSTIP           = $01;
  TTS_NOPREFIX            = $02;
  TTS_NOANIMATE           = $10;
  TTS_NOFADE              = $20;
  TTS_BALLOON             = $40;
  TTS_CLOSE               = $80;

  TTM_SETTITLE            = (WM_USER + 32);
  TTM_SETMAXTIPWIDTH      = (WM_USER + 24);
  TTM_SETTIPBKCOLOR       = (WM_USER + 19);
  TTM_SETTIPTEXTCOLOR     = (WM_USER + 20);

  TTF_PARSELINKS          = $1000;

  TTM_GETBUBBLESIZE        = WM_USER + 30;
  TTM_ADJUSTRECT           = WM_USER + 31;
  TTM_SETTITLEA            = WM_USER + 32;
  TTM_SETTITLEW            = WM_USER + 33;

  TTM_POPUP                = WM_USER + 34;
  TTM_GETTITLE             = WM_USER + 35;

  TTF_IDISHWND            = $0001;
  TTF_CENTERTIP           = $0002;
  TTF_RTLREADING          = $0004;
  TTF_SUBCLASS            = $0010;
  TTF_TRACK               = $0020;

  TTDT_AUTOMATIC          = 0;
  TTDT_RESHOW             = 1;
  TTDT_AUTOPOP            = 2;
  TTDT_INITIAL            = 3;

  TTM_ACTIVATE            = WM_USER + 1;
  TTM_SETDELAYTIME        = WM_USER + 3;

  TTM_ADDTOOLA            = WM_USER + 4;
  TTM_DELTOOLA            = WM_USER + 5;
  TTM_NEWTOOLRECTA        = WM_USER + 6;
  TTM_GETTOOLINFOA        = WM_USER + 8;
  TTM_SETTOOLINFOA        = WM_USER + 9;
  TTM_HITTESTA            = WM_USER + 10;
  TTM_GETTEXTA            = WM_USER + 11;
  TTM_UPDATETIPTEXTA      = WM_USER + 12;
  TTM_ENUMTOOLSA          = WM_USER + 14;
  TTM_GETCURRENTTOOLA     = WM_USER + 15;
  TTM_WINDOWFROMPOINT     = WM_USER + 16;
  TTM_TRACKACTIVATE       = WM_USER + 17;
  TTM_TRACKPOSITION       = WM_USER + 18;

  TTM_GETDELAYTIME        = WM_USER + 21;
  TTM_GETTIPBKCOLOR       = WM_USER + 22;
  TTM_GETTIPTEXTCOLOR     = WM_USER + 23;
  TTM_GETMAXTIPWIDTH      = WM_USER + 25;
  TTM_SETMARGIN           = WM_USER + 26;
  TTM_GETMARGIN           = WM_USER + 27;
  TTM_POP                 = WM_USER + 28;
  TTM_UPDATE              = WM_USER + 29;

  TTM_ADDTOOLW            = WM_USER + 50;
  TTM_DELTOOLW            = WM_USER + 51;
  TTM_NEWTOOLRECTW        = WM_USER + 52;
  TTM_GETTOOLINFOW        = WM_USER + 53;
  TTM_SETTOOLINFOW        = WM_USER + 54;
  TTM_HITTESTW            = WM_USER + 55;
  TTM_GETTEXTW            = WM_USER + 56;
  TTM_UPDATETIPTEXTW      = WM_USER + 57;
  TTM_ENUMTOOLSW          = WM_USER + 58;
  TTM_GETCURRENTTOOLW     = WM_USER + 59;

  TTM_ADDTOOL             = TTM_ADDTOOLA;
  TTM_DELTOOL             = TTM_DELTOOLA;
  TTM_NEWTOOLRECT         = TTM_NEWTOOLRECTA;
  TTM_GETTOOLINFO         = TTM_GETTOOLINFOA;
  TTM_SETTOOLINFO         = TTM_SETTOOLINFOA;
  TTM_HITTEST             = TTM_HITTESTA;
  TTM_GETTEXT             = TTM_GETTEXTA;
  TTM_UPDATETIPTEXT       = TTM_UPDATETIPTEXTA;
  TTM_ENUMTOOLS           = TTM_ENUMTOOLSA;
  TTM_GETCURRENTTOOL      = TTM_GETCURRENTTOOLA;

  TTM_RELAYEVENT          = WM_USER + 7;
  TTM_GETTOOLCOUNT        = WM_USER +13;

procedure THIBaloonToolTips._work_doCreate;
begin
   InitCommonControls;

   ti.cbSize := SizeOf(TToolInfo);
   ti.hwnd := ReadInteger(_data,_data_Handle);

   hToolTip := CreateWindowEx(WS_EX_TOOLWINDOW or WS_EX_TOPMOST, 'Tooltips_Class32', nil,
     TTS_ALWAYSTIP or TTS_BALLOON or TTS_CLOSE, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
      CW_USEDEFAULT, ti.hwnd ,0,hInstance, nil);
   SetWindowPos(hToolTip, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);

   ti.uFlags := TTF_SUBCLASS or (TTF_TRACK*_prop_Mode);
   ti.hInst := hInstance;
   GetClientRect(ti.hwnd,ti.Rect);
   ti.lpszText := PChar(ReadString(_Data,_data_Text));
   FillChar(hintbuffer, SizeOf(hintbuffer), #0);
   lstrcpy(hintbuffer, PChar(_prop_Title));
   SendMessage(hToolTip,TTM_SETTITLE,_prop_Icon, Integer(@hintbuffer));
   SendMessage(hToolTip,TTM_ADDTOOL,0,Integer(@ti));
end;

procedure THIBaloonToolTips._work_doShow;
begin
  SendMessage(hToolTip,TTM_TRACKPOSITION,0,ToIntegerEvent(_data_Point));
  SendMessage(hToolTip,TTM_TRACKACTIVATE,integer(ReadBool(_Data)),Integer(@ti));
end;

procedure THIBaloonToolTips._work_doDestroy;
begin
  SendMessage(hToolTip, TTM_DELTOOL, 0, Integer(@ti));
  DestroyWindow(hToolTip);
end;

end.
