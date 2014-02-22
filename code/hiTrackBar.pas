unit hiTrackBar; { Компонент TrackBar ver 2.10 }

interface

uses Windows,Messages,Kol,Share,Win;

{$I share.inc}

type
   THITrackBar = class(THIWin)
   private
      FOrientation,FTickMarks: byte;
      FUseToolTip,Track: Boolean;
      FFrequency: integer;
      function  GetVal(const Index:Integer):DWord;
      procedure SetVal(const Index:Integer; const Value:DWord);
   protected
      property  Min:Dword index 0 read GetVal write SetVal;
      property  Max:Dword index 1 read GetVal write SetVal;
      property  Pos:Dword index 2 read GetVal write SetVal;
   public
      _prop_Max:integer;
      _prop_Min:integer;
      _prop_Position:integer;
      _prop_ThumbLength:integer;
      _prop_PageSize:integer;      

      _event_onPosition:THI_Event;
      _event_onStart:THI_Event;
      _event_onStop:THI_Event;

      property _prop_HintPosition:boolean write FUseToolTip;
      property _prop_TickMarks:byte write FTickMarks;
      property _prop_Kind:byte write FOrientation;
      property _prop_TickCount:integer write FFrequency;
            
      procedure Init; override;
      procedure _work_doPosition(var _Data:TData; Index:word);
      procedure _work_doPosition2(var _Data:TData; Index:word);
      procedure _work_doMin(var _Data:TData; Index:word);
      procedure _work_doMax(var _Data:TData; Index:word);
      procedure _work_doTickCount(var _Data:TData; Index:word);
      procedure _var_Position(var _Data:TData; Index:word);

   end;

implementation

var TRACK_GUID:integer=0;

const
   TBS_AUTOTICKS           = $0001;
   TBS_VERT                = $0002;
   TBS_HORZ                = $0000;
   TBS_TOP                 = $0004;
   TBS_BOTTOM              = $0000;
   TBS_LEFT                = $0004;
   TBS_RIGHT               = $0000;
   TBS_BOTH                = $0008;
   TBS_NOTICKS             = $0010;
   TBS_ENABLESELRANGE      = $0020;
   TBS_FIXEDLENGTH         = $0040;
   TBS_NOTHUMB             = $0080;
   TBS_TOOLTIPS            = $0100;

   TBM_GETPOS              = WM_USER;
   TBM_GETRANGEMIN         = WM_USER+1;
   TBM_GETRANGEMAX         = WM_USER+2;
   TBM_GETTIC              = WM_USER+3;
   TBM_SETTIC              = WM_USER+4;
   TBM_SETPOS              = WM_USER+5;
   TBM_SETRANGE            = WM_USER+6;
   TBM_SETRANGEMIN         = WM_USER+7;
   TBM_SETRANGEMAX         = WM_USER+8;
   TBM_CLEARTICS           = WM_USER+9;
   TBM_SETSEL              = WM_USER+10;
   TBM_SETSELSTART         = WM_USER+11;
   TBM_SETSELEND           = WM_USER+12;
   TBM_GETPTICS            = WM_USER+14;
   TBM_GETTICPOS           = WM_USER+15;

   TBM_GETNUMTICS          = WM_USER+16;
   TBM_GETSELSTART         = WM_USER+17;
   TBM_GETSELEND           = WM_USER+18;
   TBM_CLEARSEL            = WM_USER+19;
   TBM_SETTICFREQ          = WM_USER+20;
   TBM_SETPAGESIZE         = WM_USER+21;
   TBM_GETPAGESIZE         = WM_USER+22;
   TBM_SETLINESIZE         = WM_USER+23;
   TBM_GETLINESIZE         = WM_USER+24;
   TBM_GETTHUMBRECT        = WM_USER+25;
   TBM_GETCHANNELRECT      = WM_USER+26;
   TBM_SETTHUMBLENGTH      = WM_USER+27;
   TBM_GETTHUMBLENGTH      = WM_USER+28;
   TBM_SETTOOLTIPS         = WM_USER+29;
   TBM_GETTOOLTIPS         = WM_USER+30;
   TBM_SETTIPSIDE          = WM_USER+31;

   TBTS_TOP                = 0;
   TBTS_LEFT               = 1;
   TBTS_BOTTOM             = 2;
   TBTS_RIGHT              = 3;

   TBM_SETBUDDY            = WM_USER+32;
   TBM_GETBUDDY            = WM_USER+33;
   TBM_SETUNICODEFORMAT    = CCM_SETUNICODEFORMAT;
   TBM_GETUNICODEFORMAT    = CCM_GETUNICODEFORMAT;

   TB_LINEUP               = 0;
   TB_LINEDOWN             = 1;
   TB_PAGEUP               = 2;
   TB_PAGEDOWN             = 3;
   TB_THUMBPOSITION        = 4;
   TB_THUMBTRACK           = 5;
   TB_TOP                  = 6;
   TB_BOTTOM               = 7;
   TB_ENDTRACK             = 8;

   TBCD_TICS               = $0001;
   TBCD_THUMB              = $0002;
   TBCD_CHANNEL            = $0003;

   Orientation2Style: array [0..1]    of DWord = (TBS_HORZ, TBS_VERT);
   TickMarks2Style:   array [0..2]    of DWord = (TBS_BOTTOM or TBS_RIGHT, TBS_TOP or TBS_LEFT, TBS_BOTH);
   UseToolTip2Style:  array [Boolean] of DWord = ($0, TBS_TOOLTIPS);

function WndProcTrackbarParent( Sender: PControl; var Msg: TMsg; var Rslt: Integer ): Boolean;
var Bar: THITrackBar; P:integer;
begin
   Result := FALSE;
   if ((Msg.message<>WM_HSCROLL)and(Msg.message<>WM_VSCROLL))or(Msg.lParam=0) then exit;
   Sender := Pointer( GetProp( Msg.lParam, ID_SELF ) );
   if Sender = nil then exit;
   Bar := THITrackBar(Sender.Tag);
   if (Bar = nil)or(Bar.Guid <> TRACK_GUID) then exit;
   with Bar do begin
      P := Pos;
      if LoWord(Msg.wParam)= TB_ENDTRACK then begin
         _hi_onEvent(_event_onStop, P);
         Bar.Track := false;
      end else begin
         if not Track then _hi_onEvent(_event_onStart, P);
         _hi_onEvent(_event_onPosition, P);
         Track := true;
      end;
   end;
end;

procedure THITrackBar.Init;
begin
   GenGuid(TRACK_GUID);
   Guid := TRACK_GUID;
   DoInitCommonControls( ICC_BAR_CLASSES );
   Control := _NewCommonControl( FParent,'msctls_trackbar32', WS_CHILD or WS_VISIBLE or
                                 TBS_FIXEDLENGTH or TBS_AUTOTICKS or TBS_ENABLESELRANGE or
                                 Orientation2Style[ FOrientation ] or
                                 UseToolTip2Style[ FUseToolTip ] or
                                 TickMarks2Style[ FTickMarks ], False, nil );
   FParent.AttachProc(WndProcTrackbarParent);
   inherited;
   Max := _prop_Max;
   Min := _prop_Min;
   Pos := _prop_Position;
   Control.Perform(TBM_SETTHUMBLENGTH,_prop_ThumbLength,0);
   Control.Perform(TBM_SETTICFREQ,FFrequency,1);
   Control.Perform(TBM_SETPAGESIZE,0,_prop_PageSize);   
   Control.tag := dword(Self);
end;

procedure THITrackBar._work_doPosition;
begin
   Pos := ToInteger(_Data);
   _hi_CreateEvent(_Data,@_event_onPosition,integer(Pos));
end;

procedure THITrackBar._work_doPosition2;
begin
   Pos := ToInteger(_Data);
end;

procedure THITrackBar._work_doMin;
begin
   Min := ToInteger(_Data);
end;

procedure THITrackBar._work_doMax;
begin
   Max := ToInteger(_Data);
end;

procedure THITrackBar._work_doTickCount;
begin
   FFrequency := ToInteger(_Data);
   Control.Perform(TBM_SETTICFREQ,FFrequency,1);
end;

procedure THITrackBar._var_Position;
begin
   dtInteger(_Data, Pos);
end;

function THITrackBar.GetVal(const Index:Integer):DWord;
const Val:array [0..2] of DWord=(
      TBM_GETRANGEMIN,
      TBM_GETRANGEMAX,
      TBM_GETPOS);
begin
   Result:= Control.Perform(Val[Index],0,0);
end;

procedure THITrackBar.SetVal(const Index:Integer; const Value:DWord);
const Val:array [0..2] of DWord=(
      TBM_SETRANGEMIN,
      TBM_SETRANGEMAX,
      TBM_SETPOS);
begin
   Control.Perform(Val[Index],1,Value);
end;

end.
