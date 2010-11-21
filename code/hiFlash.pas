unit hiFlash;

interface

uses Kol,Share,Debug,Win,Windows,KOLFlash,Flash_TLB;

type
  THIFlash = class(THIWin)
   private
    FlashP:TKOLFlash;
   public
    _prop_FileName:string;
    _prop_BgColor:TColor;

    _data_FileName:THI_Event;

    _event_onPlay:THI_Event;
    _event_onPause:THI_Event;
    _event_onStop:THI_Event;
    
    procedure Init; override;
    procedure _work_doPlay(var _Data:TData; Index:word);
    procedure _work_doPause(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _work_doGoToFrame(var _Data:TData; Index:word);
    procedure _work_doBgColor(var _Data:TData; Index:word);
    procedure _var_CurrentFrame(var _Data:TData; Index:word);
  end;

implementation

type TRGB = record r,g,b,x:byte; end;

procedure THIFlash.Init;
begin
  FlashP := NewKOLFlash(FParent);
  Control := FlashP;
  //FlashP.SetSize(_prop_Width,_prop_Height);
  //FlashP.SetPosition(_prop_Left,_prop_Top);
  inherited;
  with TRGB(_prop_BgColor) do
   FlashP.BackgroundColor := RGB(b,g,r);
end;

procedure THIFlash._work_doBgColor;
begin
  with TRGB(ToInteger(_Data)) do
   FlashP.BackgroundColor := RGB(b,g,r);
end;

procedure THIFlash._work_doPlay;
begin
  FlashP.LoadMovie(0,ReadFileName(ReadString(_Data,_data_FileName,_prop_FileName)));
  FlashP.Play;
  _hi_CreateEvent(_Data,@_event_onPlay);
end;

procedure THIFlash._work_doPause;
begin
  if FlashP.Playing then
    FlashP.Stop
   else FlashP.Play;
  _hi_CreateEvent(_Data,@_event_onPause);
end;

procedure THIFlash._work_doStop;
begin
  FlashP.Stop;
  FlashP.FrameNum := 0;
  _hi_CreateEvent(_Data,@_event_onStop);
end;

procedure THIFlash._work_doGoToFrame;
begin
  FlashP.FrameNum:=ReadInteger(_Data,null,0);
  FlashP.Play
end;

procedure THIFlash._var_CurrentFrame;
begin
  dtInteger(_Data,FlashP.FrameNum);
end;

end.
