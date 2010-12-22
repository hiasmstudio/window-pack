unit SimpleWin;

interface

{$I share.inc}

uses Kol,Share,Windows,Messages,Debug,WinLayout;

type
 THISimpleWin = class(TDebug)
   protected
     Guid:integer;
     NoKill:boolean;
     FParent:PControl;
     OldMes:TOnMessage;
     OldPaint:TOnPaint;
     fOnPaint:THI_Event;
     Ms:TMouseEventData;
     Back:integer; //!!! KeyPreview
     fLayout:IWinLayout;

     FOnKeyDown:THI_Event;
     FOnKeyUp:THI_Event;
     
     function ctrlpoint:pointer;
     procedure KeyDown(Sender: PControl; var Key: Longint; Shift: DWORD); //!!! KeyPreview
     procedure KeyUp(Sender: PControl; var Key: Longint; Shift: DWORD); //!!! KeyPreview
     procedure _onKeyDown(Sender: PControl; var Key: Longint; Shift: DWORD);  virtual; //!!! KeyPreview
     procedure _onKeyUp(Sender: PControl; var Key: Longint; Shift: DWORD); virtual; //!!! KeyPreview
     procedure _onMouseDown(Sender: PControl; var Mouse: TMouseEventData); virtual;
     procedure _onMouseMove(Sender: PControl; var Mouse: TMouseEventData); virtual;
     procedure _onMouseEnter( Sender: PObj ); virtual;
     procedure _onMouseLeave( Sender: PObj ); virtual;
     procedure _onMouseUp(Sender: PControl; var Mouse: TMouseEventData); virtual;
     procedure _onMouseWheel(Sender: PControl; var Mouse: TMouseEventData); virtual;//!!!
     function  _onMessage( var Msg: TMsg; var Rslt: Integer ): Boolean; virtual;
     procedure _onDblClick(Sender: PControl; var Mouse: TMouseEventData);
     procedure _OnDestroy(Sender:PObj);virtual;
     procedure _onResize(Obj:PObj);virtual;
     procedure _onShow(Obj:PObj); virtual;
     procedure _OnPaint( Sender: PControl; DC: HDC );
     procedure SetOnPaint(Ev:THI_Event);
     procedure TrackMouseEvnt(Sender :PControl; Flags :DWORD);
     procedure SetLayout(value:IWinLayout);
     
     procedure SetKeyDown(event:THI_Event);
     procedure SetKeyUp(event:THI_Event);
   public
     ManFlags:cardinal;
     Control:PControl;
     _prop_Name:string;
     _prop_Left:integer;
     _prop_Top:integer;
     _prop_Width:integer;
     _prop_Height:integer;
     _prop_Align:TControlAlign;
     _prop_TabOrder:integer;
     _prop_Color:TColor;
     _prop_Ctl3D:byte;
     _prop_Hint:string;
     _prop_Font:TFontRec;
     _prop_ParentFont:boolean;
     _prop_Visible:boolean;
     _prop_Enabled:boolean;
     _prop_Cursor:integer;
     _prop_MouseCapture:boolean;
     _prop_KeyPreview:boolean; //!!! KeyPreview

     _prop_WidthScale:integer;
     _prop_HeightScale:integer;
      
     _event_onMouseDown:THI_Event;
     _event_onMouseMove:THI_Event;
     _event_onMouseUp:THI_Event;
     _event_onMouseWheel:THI_Event;
     _event_onSetFocus:THI_Event;
     _event_onKillFocus:THI_Event;
     _event_onDblClick:THI_Event;
     _event_onResize:THI_Event;
     _event_onShow:THI_Event;
     _event_onMove:THI_Event;
     _event_onMouseEnter:THI_Event;
     _event_onMouseLeave:THI_Event;

     constructor Create(Parent:PControl);
     destructor Destroy; override;
     procedure Init; virtual;

     procedure _work_doKeyPreview(var Data:TData; Index:word); //!!! KeyPreview
     procedure _work_doVisible(var Data:TData; Index:word);
     procedure _work_doEnabled(var Data:TData; Index:word);
     procedure _work_doHint(var Data:TData; Index:word);
     procedure _work_doLeft(var Data:TData; Index:word);
     procedure _work_doTop(var Data:TData; Index:word);
     procedure _work_doWidth(var Data:TData; Index:word);
     procedure _work_doHeight(var Data:TData; Index:word);
     procedure _work_doColor(var Data:TData; Index:word);
     procedure _work_doCursor(var Data:TData; Index:word);
     procedure _work_doSendToBack(var Data:TData; Index:word);
     procedure _work_doBringToFront(var Data:TData; Index:word);
     procedure _work_doCenterPos(var Data:TData; Index:word);
     procedure _work_doFont(var Data:TData; Index:word);
     procedure _work_doAlign(var Data:TData; Index:word);
     procedure _work_doSetFocus(var Data:TData; Index:word);
     procedure _work_doKeyBack(var Data:TData; Index:word); //!!! KeyPreview
     procedure _var_Handle(var Data:TData; Index:word);
     procedure _var_PHandle(var Data:TData; Index:word);
     procedure _var_MouseX(var Data:TData; Index:word);
     procedure _var_MouseY(var Data:TData; Index:word);
     procedure _var_Left(var Data:TData; Index:word);
     procedure _var_Top(var Data:TData; Index:word);
     procedure _var_Width(var Data:TData; Index:word);
     procedure _var_Height(var Data:TData; Index:word);
     procedure _var_Position(var Data:TData; Index:word);

     property _prop_Layout:IWinLayout write SetLayout;

     property _event_onPaint:THI_Event read fOnPaint write SetOnPaint;
     property _event_onKeyDown:THI_Event write SetKeyDown;
     property _event_onKeyUp:THI_Event write SetKeyUp;
 end;

implementation

//-------------------------------------------------------------------------------------------------

function TrackMouseEvent(var EventTrack: TTrackMouseEvent): BOOL; stdcall; external user32 name 'TrackMouseEvent';

//-------------------------------------------------------------------------------------------------

procedure THISimpleWin.TrackMouseEvnt;
var
     t_MouseEvent: TTrackMouseEvent;
begin
   t_MouseEvent.cbSize:=SizeOf(TTrackMouseEvent);
   t_MouseEvent.dwFlags:=Flags;
   t_MouseEvent.hwndTrack:=Sender.GetWindowHandle;
   t_MouseEvent.dwHoverTime:=HOVER_DEFAULT;
   TrackMouseEvent(t_MouseEvent);
end;

function THISimpleWin.ctrlpoint;
begin
  Result := Control;
end;

constructor THISimpleWin.Create;
begin
   inherited Create;
   FParent := Parent;
   if Parent <> nil then _prop_Color := Parent.Color;
   _prop_Ctl3D := 2;
   _prop_Visible := true;
   _prop_Enabled := true;
   _prop_KeyPreview := true; //!!! KeyPreview
   _prop_MouseCapture := false;
end;

destructor THISimpleWin.Destroy;
begin
   if fLayout <> nil then 
     ExplodeLayout(FLayout, Control);
     
   if not NoKill then begin
      Control.Visible := false; //for Global_Align(Parent)
      Control.Free;
   end;
   
   inherited;
end;

procedure THISimpleWin._onShow;
begin
   _hi_OnEvent(_event_onShow);
end;

procedure THISimpleWin._OnDestroy;
begin
   NoKill := true;
end;

procedure THISimpleWin.Init;
const wpFlag = SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOOWNERZORDER or SWP_HIDEWINDOW;
begin
   with Control{$ifndef F_P}^{$endif} do begin
      Color := _prop_Color;
      SetPosition(_prop_Left,_prop_Top);
      SetSize(_prop_Width,_prop_Height);
      if _prop_Ctl3D<2 then Ctl3D := _prop_Ctl3D=0;
      Enabled := _prop_Enabled;
//      Cursor := _prop_Cursor;
      CursorLoad(0, MakeIntResource(_prop_Cursor));
      {
      if _prop_ParentFont then
         Font.Assign(Parent.Font)
      else begin
         Font.Color := _prop_Font.Color;
         SetFont(Font,_prop_Font.Style);
         Font.FontName :=  _prop_Font.Name;
         Font.FontHeight := _hi_SizeFnt(_prop_Font.Size);
         Font.FontCharset := _prop_Font.CharSet;
      end;
      }
      if _prop_TabOrder > 0 then begin
         Style := Style or WS_TABSTOP;
         LookTabKeys := [tkTab];
         TabOrder := _prop_TabOrder;
      end else
         TabStop := _prop_TabOrder = 0;

      OldMes        :=  OnMessage;
      onMouseDown   := _onMouseDown;
      onMouseMove   := _onMouseMove;
      onMouseUp     := _onMouseUp;
      onMouseWheel  := _onMouseWheel;
      OnMouseDblClk := _onDblClick;
      OnMessage     := _onMessage;
      OnDestroy     := _OnDestroy;
      onResize      := _onResize;
      onShow        := _onShow;

      Align := _prop_Align;
//      SetWindowPos(GetWindowHandle, HWND_TOP, 0, 0, 0, 0, wpFlag);
      Visible := _prop_Visible;
      CreateWindow;
   end;
end;

procedure THISimpleWin._onDblClick;
begin
   _hi_OnEvent(_event_onDblClick, integer(Mouse.Button)-1);
end;

procedure THISimpleWin._work_doColor;
begin
   Control.Color := ToInteger(Data);
end;

procedure THISimpleWin._work_doCursor;
begin
   Control.CursorLoad(0, MakeIntResource(ToInteger(Data)));
//   Control.Cursor := ToInteger(Data);
end;

procedure THISimpleWin._work_doVisible;
begin
   Control.Visible := ReadBool(Data);
end;

procedure  THISimpleWin._work_doEnabled;
begin
   Control.Enabled := ReadBool(Data);
end;

procedure THISimpleWin._work_doHint;
begin

end;

procedure THISimpleWin._work_doLeft;
begin
   Control.Left := ToInteger(Data);
end;

procedure THISimpleWin._work_doTop;
begin
   Control.Top := ToInteger(Data);
end;

procedure THISimpleWin._work_doWidth;
begin
   Control.Width := ToInteger(Data);
end;

procedure THISimpleWin._work_doHeight;
begin
   Control.Height := ToInteger(Data);
end;

procedure THISimpleWin._work_doSendToBack;
begin
   Control.SendToBack;
end;

procedure THISimpleWin._work_doBringToFront;
begin
   Control.BringToFront;
end;

procedure THISimpleWin._work_doCenterPos;
begin
   if Assigned(FParent) then
   begin
     Control.Left := max((FParent.Left + (FParent.Width  - Control.Width)  div 2), 0);
     Control.Top  := max((FParent.Top  + (FParent.Height - Control.Height) div 2), 0);
   end
   else
   begin
     Control.Left := (ScreenWidth  - Control.Width)  div 2;
     Control.Top  := (ScreenHeight - Control.Height) div 2;
   end;
end;

procedure THISimpleWin._work_doFont;
begin
   if _IsFont(Data) then
      with pfontrec(Data.idata)^ do begin
         Control.Font.Color := Color;
         SetFont(Control.Font,Style);
         Control.Font.FontName :=  Name;
         Control.Font.FontHeight := _hi_SizeFnt(Size);
         Control.Font.FontCharset := CharSet;
      end;
end;

procedure THISimpleWin._work_doAlign;
begin
   Control.Align := TControlAlign(ToInteger(Data));
end;

procedure THISimpleWin._onPaint;
begin
   if assigned(OldPaint) then
     OldPaint(Sender, DC);
   _hi_onEvent(fOnPaint, integer(DC));
end;

procedure THISimpleWin.SetOnPaint;
begin
   OldPaint := Control.OnPaint;
   Control.OnPaint := _OnPaint;
   fOnPaint := Ev;
end;

procedure THISimpleWin.SetLayout;
begin
  if value <> nil then
    value.addControl(Control, _prop_WidthScale, _prop_HeightScale);
  fLayout := value;  
end;

procedure THISimpleWin._work_doSetFocus;
begin
   Control.Focused := true;
end;

procedure THISimpleWin._var_Handle;
begin
   dtInteger(Data,Control.GetWindowHandle);
end;

procedure THISimpleWin._var_PHandle;
begin
   dtInteger(Data, integer(Control) );
end;

procedure THISimpleWin._onMouseDown;
begin
   Ms := Mouse;
   _hi_OnEvent(_event_onMouseDown, integer(Ms.Button)-1);
   if _prop_MouseCapture then begin
      ReleaseCapture;
      SetCapture(Control.Handle);
   end;
end;

procedure THISimpleWin._onMouseMove;
var   b:smallint;
begin
   case Ms.Shift of
      1:   b :=  0;
      2:   b :=  1;
      16:  b :=  2;
      else b := -1;
   end;
   Ms := Mouse;
   _hi_OnEvent(_event_onMouseMove, b);
end;

procedure THISimpleWin._onMouseUp;
begin
   Ms := Mouse;
   _hi_OnEvent(_event_onMouseUp, integer(Ms.Button)-1);
   if _prop_MouseCapture then ReleaseCapture;
end;

procedure THISimpleWin._onMouseWheel;
begin
   Ms := Mouse;
   _hi_OnEvent(_event_onMouseWheel, integer(Ms.Shift)div $10000);
end;

procedure THISimpleWin._var_MouseX;
begin
   dtInteger(Data,Ms.X);
end;

procedure THISimpleWin._var_MouseY;
begin
   dtInteger(Data,Ms.Y);
end;

procedure THISimpleWin._var_Left;
begin
   dtInteger(Data,Control.Left);
end;

procedure THISimpleWin._var_Top;
begin
   dtInteger(Data,Control.Top);
end;

procedure THISimpleWin._var_Width;
begin
   dtInteger(Data,Control.Width)
end;

procedure THISimpleWin._var_Height;
begin
   dtInteger(Data,Control.Height)
end;

procedure THISimpleWin._var_Position;
begin
   dtInteger(Data, Control.SelStart);
end;

function THISimpleWin._onMessage;
begin
   case Msg.message of
      WM_SETFOCUS :  _hi_OnEvent(_event_onSetFocus);
      WM_KILLFOCUS:  _hi_OnEvent(_event_onKillFocus);
      WM_MOUSEHOVER: _onMouseEnter(Control);
      WM_MOUSELEAVE: begin
                       _onMouseLeave(Control);
                       TrackMouseEvnt(Control, TME_HOVER);
                     end;
      WM_MOUSEFIRST..WM_MOUSELAST:
                     begin
                       TrackMouseEvnt(Control, TME_LEAVE);
                       _onMouseEnter(Control);
                     end;
      WM_MOVE: _hi_OnEvent(_event_onMove);
   end;
   Result := _hi_OnMessage(OldMes,Msg,Rslt);
end;

procedure THISimpleWin._onMouseEnter;
begin
   _hi_OnEvent(_event_onMouseEnter);
end;

procedure THISimpleWin._onMouseLeave;
begin
   _hi_OnEvent(_event_onMouseLeave);
end;

procedure THISimpleWin._onResize;
begin
   _hi_OnEvent(_event_onResize);
end;

procedure THISimpleWin._work_doKeyPreview; //!!! KeyPreview
begin
   _prop_KeyPreview := ReadBool(Data);
end;

procedure THISimpleWin._work_doKeyBack; //!!! KeyPreview
begin
   Back := ToInteger(Data);
end;

procedure THISimpleWin.KeyDown; //!!! KeyPreview
begin
   if _prop_KeyPreview and(FParent<> nil)and assigned(FParent.OnKeyDown) then begin
      FParent.OnKeyDown(FParent,Key,Shift);
      if Key=0 then exit;
   end;
   Back := -1;
   _onKeyDown(Sender,Key,Shift);  //virtual
   if Back >= 0 then Key:=Back
   else if Key=0 then Back:=0;
end;

procedure THISimpleWin.SetKeyDown;
begin
   Control.OnKeyDown     := KeyDown;
   FonKeyDown := event;
end;

procedure THISimpleWin.SetKeyUp;
begin
   Control.onKeyUp       := KeyUp;
   FonKeyUp := event;
end;

procedure THISimpleWin._onKeyDown;
begin
   _hi_OnEvent(FonKeyDown,Key);
end;

procedure THISimpleWin.KeyUp; //!!! KeyPreview
begin
   if _prop_KeyPreview and(FParent<> nil)and assigned(FParent.OnKeyUp) then begin
      FParent.OnKeyUp(FParent,Key,Shift);
      if Key=0 then exit;
   end;
   Back := -1;
   _onKeyUp(Sender,Key,Shift);  //virtual
   if Back >= 0 then Key:=Back;
end;

procedure THISimpleWin._onKeyUp;
begin
   _hi_OnEvent(FonKeyUp,Key);
end;

end.