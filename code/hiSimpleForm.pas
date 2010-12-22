unit hiSimpleForm;

interface

{$I share.inc}

uses Windows,Kol,Share,SimpleWin,Messages;

type
 THISimpleForm = class(THISimpleWin)
   private
     First:boolean;

     procedure SetCaption(const Value:string);
     procedure SetBorderStyle(Value:byte);
     procedure SetTaskBar(Value:byte);
     procedure SetIcon(value:HICON);

     procedure Load;

     function _OnClose( Sender: PObj; Accept: Boolean ):boolean;
   protected  
     procedure _onMouseDown(Sender: PControl; var Mouse: TMouseEventData); override;
     function  _onMessage( var Msg: TMsg; var Rslt: Integer ): Boolean; override;
     procedure _onShow(Obj:PObj); override;
   public
     _prop_DragForm:boolean;
     _prop_WindowsState:byte;
     _prop_ShowIcon:boolean;

     _data_Close:THI_Event;
     _event_onClick:THI_Event;
     _event_onCreate:THI_Event;
     _event_onClose:THI_Event;

     constructor Create(Parent:PControl);
     destructor Destroy; override;
     procedure Init; override;
     procedure Start;

     procedure _work_doCaption(var Data:TData; Index:word);
     procedure _work_doRestore(var Data:TData; Index:word);
     procedure _work_doMinimize(var Data:TData; Index:word);
     procedure _work_doClose(var Data:TData; Index:word);
     procedure _work_doVisible(var Data:TData; Index:word);
     procedure _work_doFlashWindow(var _Data:TData; Index:word);
     procedure _work_doIcon(var _Data:TData; Index:word);

     procedure _work_doBorderStyle(var _Data:TData; Index:word);
     procedure _work_doShowModal(var _Data:TData; Index:word);
     procedure _work_doPlaceInTaskBar(var _Data:TData; Index:word);
     procedure _var_SizeHeader(var Data:TData; Index:word);

     property _prop_Caption:string write SetCaption;
     property _prop_Icon:HICON write SetIcon;
     property _prop_TaskBar:byte write SetTaskBar;
     property _prop_BorderStyle:byte write SetBorderStyle;
 end;

implementation

constructor THISimpleForm.Create;
begin
   inherited Create(Parent);
   if not Assigned(Applet) then
     Applet := NewApplet('');

   Control := NewForm(Applet,'Form');
   
   with Control{$ifndef F_P}^{$endif} do
    begin
       Visible:=false;
       onShow := _onShow;
       Border := 0;
    end;
   InitAdd(Load);
end;

destructor THISimpleForm.Destroy;
begin
  inherited;
end;

procedure THISimpleForm._work_doFlashWindow;
begin
  FlashWindow(Applet.Handle,true);
end;

procedure THISimpleForm._work_doIcon;
begin
   if _IsIcon(_data) then
    begin
      Control.Icon := ToIcon(_data).handle;
      Applet.Icon := Control.Icon;
    end;
end;

procedure THISimpleForm._work_doBorderStyle;
begin
  SetBorderStyle(ToInteger(_Data));
end;

function THISimpleForm._onClose;
begin
   Result := true;
   if Accept and(ToIntegerEvent(_data_Close)<>0) then exit;

   Result := false;
   _hi_OnEvent(_event_onClose);
   EventOff;
end;

function THISimpleForm._onMessage;
begin
   Result := false;
   case Msg.message of
     WM_CLOSE: Result := _onClose(Control,(Msg.lParam=0));
     WM_SIZE:
       if Assigned(Applet) then Applet.Width := Control.Width;
     WM_MOVE:
       begin
         if Assigned(Applet) then
           Applet.SetPosition(Control.Left,Control.Top);
         _hi_OnEvent(_event_onMove);
       end;
   end;
   Result := Result or inherited _onMessage(Msg,Rslt);
end;

procedure THISimpleForm.SetCaption;
begin
   Control.Caption := Value;
   if Assigned(Applet) then
     Applet.Caption := Value;
end;

procedure THISimpleForm.SetBorderStyle;
const
  NmMask = not(WS_CAPTION or WS_THICKFRAME or WS_MAXIMIZEBOX or WS_MINIMIZEBOX);
  NmSet:array[0..9] of dword =(0,
  WS_CAPTION or WS_MINIMIZEBOX,
  WS_CAPTION or WS_THICKFRAME or WS_MAXIMIZEBOX or WS_MINIMIZEBOX,
  WS_CAPTION,
  WS_CAPTION,
  WS_CAPTION or WS_THICKFRAME,
  0,
  WS_THICKFRAME,
  0,
  WS_THICKFRAME
  );
  ExMask = not(WS_EX_DLGMODALFRAME or WS_EX_WINDOWEDGE or WS_EX_TOOLWINDOW);
  ExSet:array[0..9] of dword =(0,0,0,
  WS_EX_WINDOWEDGE,
  WS_EX_TOOLWINDOW,
  WS_EX_TOOLWINDOW,
  WS_EX_DLGMODALFRAME,
  WS_EX_TOOLWINDOW,
  WS_EX_CLIENTEDGE or WS_EX_DLGMODALFRAME,
  WS_EX_CLIENTEDGE
  );
begin
  if Value > 9 then exit;
  with Control{$ifndef F_P}^{$endif} do
   begin
    GetWindowHandle;
    Style   := NmSet[Value]or(NmMask and Style);
    ExStyle := ExSet[Value]or(ExMask and ExStyle);
   end;
end;

procedure THISimpleForm.SetTaskBar;
begin
   if (Value = 1)and Assigned(Applet) then
     Applet.ExStyle :={ Applet.ExStyle or} WS_EX_DLGMODALFRAME or WS_EX_TOOLWINDOW;
end;

procedure THISimpleForm.SetIcon;
begin
   if Assigned(Applet) then
    Applet.Icon := Value;
   if Value = 0 then Value := FParent.Icon;
   Control.Icon := Value;
end;

procedure THISimpleForm._onMouseDown;
begin
   if _prop_DragForm then
    begin
     ReleaseCapture;
     Control.Perform(WM_SYSCOMMAND, $F012, 0);
    end;
   inherited;
end;

procedure THISimpleForm._onShow;
begin
  if not First then
    First := true;
  inherited;
end;

procedure THISimpleForm.Load;
begin
  _hi_OnEvent(_event_onCreate);
  Control.Visible := _prop_Visible;
end;

procedure THISimpleForm.Init;
var vsb:boolean;
begin
  vsb:= _prop_Visible;
  _prop_Visible:= false;
  inherited;
  _prop_Visible:= vsb;
end;

procedure THISimpleForm.Start;
begin
  if Assigned(Applet) then
    Applet.Visible := _prop_Visible;
  EventOn;
  InitDo;
end;

procedure THISimpleForm._work_doCaption;
var Str:string;
begin
  Str := ToString(Data);
  SetWindowText( Control.Handle, @Str[ 1 ] );
end;

procedure THISimpleForm._work_doRestore;
begin
  Applet.WindowState := wsNormal;
end;

procedure THISimpleForm._work_doMinimize;
begin
  Applet.WindowState := wsMinimized;
end;

procedure THISimpleForm._work_doClose;
begin
  Control.Perform(WM_CLOSE,0,1);
end;

procedure THISimpleForm._work_doVisible;
begin
  _prop_Visible := ReadBool(Data);
  if not _prop_Visible then begin
    Control.Hide;
    Applet.Hide;
  end else begin
    Control.Show;
    Applet.show;
  end
end;

procedure THISimpleForm._work_doShowModal;
var p:PControl;
begin
  p := Control.Parent;
  {$ifndef SUPER_PARENT}
  while not p.isForm do p := p.Parent;
  {$endif}
  Control.ShowModalParented(p);
end;

procedure THISimpleForm._work_doPlaceInTaskBar(var _Data:TData; Index:word);
begin
  Control.ExStyle := Control.ExStyle or WS_EX_APPWINDOW; 
end;

procedure THISimpleForm._var_SizeHeader;
var
  Pt: TPoint;
begin
   Pt.x := 0; Pt.y := 0;
   ClientToScreen(Control.Handle, Pt);
   dtInteger(Data, Pt.Y - Control.Top);
end;

end.