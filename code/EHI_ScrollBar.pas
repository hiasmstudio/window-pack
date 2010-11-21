unit EHI_ScrollBar;

interface

uses Windows, Messages, KOL, Share;

{$I share.inc}

type
  THIScrollEvent = procedure(Pos:integer) of object;

  {$ifdef F_P}
  TScrollBar = class(TControl)
  {$else}
  TScrollBar = object(TControl)
  {$endif}
  private
    procedure Paint(DC: HDC);
    procedure MouseDown(X,Y:integer);
    procedure MouseMove(X,Y:integer);
    procedure MouseUp(X,Y:integer);
    function CurInCaret(var X,Y:integer):boolean;

    procedure SetScroll(Value:THIScrollEvent);
    procedure SetMax(Value:integer);
    procedure SetMin(Value:integer);
    procedure SetKind(Value:byte);
    procedure SetPosition(Value:integer);
    procedure SetUserPosition(Value:integer);
    function  GetPosition:integer;
    procedure SetBodyColor(Value:TColor);
    procedure SetSM(Value:byte);

    procedure SetLightColor(Value:TColor);
    procedure SetFaceColor(Value:TColor);
    procedure SetDarkColor(Value:TColor);
    procedure SetArrowColor(Value:TColor);

    procedure _OnTimer(Obj:PObj);
  public
    property OnCScroll:THIScrollEvent write SetScroll;
    property Max:integer write SetMax;
    property Min:integer write SetMin;
    property Kind:byte write SetKind;
    property Position:integer read GetPosition write SetUserPosition;
    property BodyColor:TColor write SetBodyColor;
    property ScrollMode:byte write SetSM;
    property LightColor:TColor write SetLightColor;
    property FaceColor:TColor write SetFaceColor;
    property DarkColor:TColor write SetDarkColor;
    property ArrowColor:TColor write SetArrowColor;
  end;
  {$ifdef F_P}
  PScrollBar = TScrollBar;
  {$else}
  PScrollBar = ^TScrollBar;
  {$endif}
   TKOLScrollBar = PScrollBar;
function NewHiScrollBar(AParent: PControl): TKOLScrollBar;

implementation

type
  {$ifdef F_P}
  TScrollBarData = class(TObj)
  {$else}
  TScrollBarData = object(TObj)
  {$endif}
    FLightColor:TColor;
    FFaceColor:TColor;
    FDarkColor:TColor;
    FArrowColor:TColor;
    FOrientation:byte;
    FPosition:integer;
    FMin:integer;
    FMax:integer;
    FScrollMode:byte;
    FX,FY:integer;
    FOnScroll:THIScrollEvent;
    State:boolean;
    k:real;
    Timer:PTimer;
    destructor Destroy; virtual;
  end;
 {$ifdef F_P}
 PScrollBarData = TScrollBarData;
 {$else}
 PScrollBarData = ^TScrollBarData;
 {$endif}

function WndProcScrollBar(Sender: PControl; var Msg: TMsg; var Rslt: Integer): Boolean;
var PaintStruct: TPaintStruct;
    DC: HDC;
begin
    Result := FALSE;
    case Msg.message of
      WM_PRINTCLIENT,
      WM_PAINT:
       Begin
        if PScrollBar(Sender).fUpdCount>0 then Exit;
        if Msg.wParam = 0 then
          DC := BeginPaint(Sender.Handle, PaintStruct)
        else DC := Msg.wParam;
        PScrollBar(Sender).Paint(DC);
        if Msg.wParam = 0 then
          EndPaint(Sender.Handle, PaintStruct);
        Result:= True;
        Rslt:= 0;
       end;
      WM_LBUTTONDOWN: PScrollBar(Sender).MouseDown(Msg.lParam and $FFFF,Msg.lParam shr 16);
      WM_MOUSEMOVE: PScrollBar(Sender).MouseMove(Msg.lParam and $FFFF,Msg.lParam shr 16);
      WM_LBUTTONUP: PScrollBar(Sender).MouseUp(Msg.lParam and $FFFF,Msg.lParam shr 16);
      WM_SIZE: PScrollBar(Sender).Invalidate;
    end;
end;

function NewHiScrollBar(AParent: PControl): TKOLScrollBar;
var ScrollBarData: PScrollBarData;
begin
    Result := TKOLScrollBar(NewPanel(AParent, esNone));
    {$ifdef F_P}
    ScrollBarData := TScrollBarData.Create;
    with ScrollBarData do
    {$else}
    New(ScrollBarData, Create);
    with ScrollBarData^ do
    {$endif}
     begin
      FOrientation := 0;
      FPosition := 0;
      FMax := 200;
      FMin := 0;
      k :=  (Result.Width - 2*10 - 10)/(FMax - FMin);
      Timer := NewTimer(1000);
      Timer.Enabled := false;
      Timer.OnTimer := Result._OnTimer;
     end;
    Result.Color := clAppWorkSpace;
    Result.FCustomObj:= ScrollBarData;
    Result.AttachProc(WndProcScrollBar);
    Result.fClsStyle := Result.fClsStyle and not CS_DBLCLKS;
end;

{ TScrollBar }

function TScrollBar.CurInCaret;
var n:word;
begin
   {$ifdef F_P}
   with PScrollBarData(CustomObj) do
   {$else}
   with PScrollBarData(CustomObj)^ do
   {$endif}
   if FOrientation = 0 then
     begin
      n := Round(k*(FPosition-FMin) + 10);
      Result := (x >= n)and(x <= n+10);
      x := x - n;
     end
   else
     begin
      n := Round(k*(FPosition-FMin) + 10);
      Result := (y >= n)and(y <= n+10);
      y := y - n;
     end;
end;

procedure TScrollBar.SetScroll;
begin
   PScrollBarData(CustomObj).FOnScroll := Value;
end;

procedure TScrollBar.SetKind;
begin
   PScrollBarData(CustomObj).FOrientation := Value;
end;

procedure TScrollBar.SetMax;
begin
   {$ifdef F_P}
   with PScrollBarData(CustomObj) do
   {$else}
   with PScrollBarData(CustomObj)^ do
   {$endif}
    begin
     FMax := Value;
     if FPosition > Value then
       FPosition := Value;
    end;
   Invalidate;
end;

procedure TScrollBar.SetMin;
begin
   {$ifdef F_P}
   with PScrollBarData(CustomObj) do
   {$else}
   with PScrollBarData(CustomObj)^ do
   {$endif}
    begin
     FMin := Value;
     if FPosition < Value then
       FPosition := Value;
    end;
   Invalidate;
end;

procedure TScrollBar.SetPosition;
var Old:integer;
    r:TRect;
begin
  {$ifdef F_P}
  with PScrollBarData(CustomObj) do
  {$else}
  with PScrollBarData(CustomObj)^ do
  {$endif}
  begin
   Old := FPosition;
   FPosition := kol.max(kol.min(Value,FMax),FMin);
   if Old <> Value then
    begin
     if FOrientation = 0 then
      begin
        r.left := 10;
        r.Right := ClientWidth - 10;
        r.Top := 0;
        r.Bottom := ClientHeight;
      end
     else
      begin
        r.Top := 10;
        r.Bottom := ClientHeight - 10;
        r.Left := 0;
        r.Right := ClientWidth;
      end;
     InvalidateRect(Handle,@r,false);

     if FScrollMode = 0 then
      if Assigned(FOnScroll) then
       FOnScroll(FPosition);
    end;
  end;
end;

procedure TScrollBar.SetUserPosition;
begin
  if not PScrollBarData(CustomObj).State then
    SetPosition(value);
end;

function TScrollBar.GetPosition;
begin
   Result := PScrollBarData(CustomObj).FPosition;
end;

procedure TScrollBar.SetBodyColor;
begin
   Color := Value;
end;

procedure TScrollBar.SetLightColor;
begin
   PScrollBarData(CustomObj).FLightColor := Value;
end;

procedure TScrollBar.SetFaceColor;
begin
   PScrollBarData(CustomObj).FFaceColor := Value;
end;

procedure TScrollBar.SetDarkColor;
begin
   PScrollBarData(CustomObj).FDarkColor := Value;
end;

procedure TScrollBar.SetArrowColor;
begin
   PScrollBarData(CustomObj).FArrowColor := Value;
end;

procedure TScrollBar.SetSM;
begin
   PScrollBarData(CustomObj).FScrollMode := Value;
end;

procedure TScrollBar._OnTimer;
begin
  {$ifdef F_P}
  with PScrollBarData(CustomObj) do
  {$else}
  with PScrollBarData(CustomObj)^ do
  {$endif}
   begin
    Timer.Interval := 50;
    if Timer.Tag = 1 then
     Position := kol.max(FPosition-1,FMin)
    else Position := kol.min(FPosition+1,FMax);
   end;
end;

procedure TScrollBar.MouseDown;
var r:TRect;
  procedure Clip(X1,Y1,X2,Y2:integer);
  begin
    r := ClientRect;
    r.BottomRight := Client2Screen(r.BottomRight);
    r.TopLeft := Client2Screen(r.TopLeft);
    ClipCursor(@r);
  end;
  procedure SetTimer(State:byte);
  begin
   {$ifdef F_P}
    with PScrollBarData(CustomObj).Timer do
   {$else}
    with PScrollBarData(CustomObj).Timer^ do
    {$endif}
     begin
       Enabled := true;
       Tag := State;
       Interval := 500;
     end;
  end;
begin
  {$ifdef F_P}
  with PScrollBarData(CustomObj) do
  {$else}
  with PScrollBarData(CustomObj)^ do
  {$endif}
   if(FOrientation = 0)and(x < 10)then
     begin
       SetTimer(1);
       Position := kol.max(FPosition-1,FMin);
       Clip(0,0,10,Height);
     end
   else if(FOrientation = 0)and(x>Width-10)then
     begin
       SetTimer(2);
       Position := kol.min(FPosition+1,FMax);
       Clip(Width-10,0,Width,Height);
     end
   else if(FOrientation = 1)and(y < 10)then
     begin
       SetTimer(1);
       Position := kol.max(FPosition-1,FMin);
       Clip(0,0,Width,10);
     end
   else if(FOrientation = 1)and(y>Height-10)then
     begin
       SetTimer(2);
       Position := kol.min(FPosition+1,FMax);
       Clip(0,Height-10,Width,Height);
     end
   else
   begin
    Fx := x;
    Fy := y;
    State := CurInCaret(FX,FY);
    if FOrientation = 0 then
      Clip(10,0,Width-10,Height)
    else Clip(0,10,Width,Height-10);
   end;
  Invalidate; 
end;

procedure TScrollBar.MouseMove;
begin
  {$ifdef F_P}
  with PScrollBarData(CustomObj) do
  {$else}
  with PScrollBarData(CustomObj)^ do
  {$endif}
   if State then
     if FOrientation = 0 then
       SetPosition(FMin + kol.min(FMax - FMin,kol.max(0,Round( (x - 10 - Fx)/k ) )))
     else SetPosition(FMin + kol.min(FMax - FMin,kol.max(0,Round( (y - 10 - Fy)/k ) )));
end;

procedure TScrollBar.MouseUp;
begin
  ClipCursor(nil);
  {$ifdef F_P}
  with PScrollBarData(CustomObj) do
  {$else}
  with PScrollBarData(CustomObj)^ do
  {$endif}
   begin
    State := false;
    Timer.Enabled := false;
    Timer.Tag := 0;
    if FScrollMode = 1 then
     if Assigned(FOnScroll) then
      FOnScroll(FPosition);
   end;
  Invalidate;
end;

procedure TScrollBar.Paint;
var
  r:Trect;
  n:word;
  procedure Frame3D(X1,Y1,X2,Y2:integer);
  begin
     {$ifdef F_P}
     with Canvas do
     {$else}
     with Canvas^ do
     {$endif}
      begin
       Rectangle(X1,Y1,X2,Y2);
       Pen.Color := clBtnHighlight;
       MoveTo(X1,Y2-1);
       LineTo(X1,Y1);
       Lineto(X2-1,Y1);
       Pen.Color := clBtnShadow;
       LineTo(X2-1,Y2-1);
       LineTo(X1,Y2-1);
      end;
  end;
  procedure Frame3D_Down(X1,Y1,X2,Y2:integer);
  begin
    {$ifdef F_P}
     with Canvas do
     {$else}
     with Canvas^ do
     {$endif}
      begin
       Rectangle(X1,Y1,X2,Y2);
       Pen.Color := PScrollBarData(CustomObj).FDarkColor;
       MoveTo(X1,Y2-1);
       LineTo(X1,Y1);
       Lineto(X2-1,Y1);
       Pen.Color := PScrollBarData(CustomObj).FLightColor;
       LineTo(X2-1,Y2-1);
       LineTo(X1,Y2-1);
      end;
  end;
  procedure DrawArrow(X,Y:integer; State:boolean; ch:char);
  begin
     {$ifdef F_P}
     with Canvas do
     {$else}
     with Canvas^ do
     {$endif}
      begin
       Brush.BrushStyle := bsClear;
       if not State then
         TextOut(X,Y,ch)
       else TextOut(X+1,Y+1,ch);
       Brush.BrushStyle := bsSolid;
      end;
  end;
begin
    Canvas.Handle := DC;
    GetClientRect(Handle, R);
    {$ifdef F_P}
    with PScrollBarData(CustomObj) do
    {$else}
    with PScrollBarData(CustomObj)^ do
    {$endif}
     if FOrientation = 0 then
      begin
       if FMax = FMin then k := 1
       else k :=  (r.Right - 2*10 - 10)/(FMax - FMin);
       n := Round(k*(FPosition - FMin)) + 10;
       Canvas.Pen.Color := Color;
       //Canvas.Rectangle(0,0,10,r.Bottom);
       //Canvas.Rectangle(r.Right-10,0,r.Right,r.Bottom);
       Canvas.Brush.Color := Color;
       Canvas.Rectangle(10,0,r.Right-10,r.Bottom);
       Canvas.Brush.Color := FFaceColor;

       Canvas.Font.FontName := 'Webdings';
       Canvas.Font.Color := FArrowColor;
       Canvas.Font.FontCharset := 1; 

       if Timer.Tag = 1 then
         Frame3D_Down(0,0,10,r.Bottom)
       else Frame3d(0,0,10,r.Bottom);

       DrawArrow(0,Height div 2 - 9,Timer.Tag = 1,#51);

       if Timer.Tag = 2 then
         Frame3D_Down(r.Right-10,0,r.Right,r.Bottom)
       else Frame3D(r.Right-10,0,r.Right,r.Bottom);

       DrawArrow(r.Right-10,Height div 2 - 9,Timer.Tag = 2,#52);

       Canvas.Rectangle(n,0,n + 10,r.Bottom);
       Frame3D(n,0,n + 10,r.Bottom);
      end
     else
      begin
       if FMax = FMin then k := 1
       else   k :=  (r.Bottom - 2*10 - 10)/(FMax - FMin);
       n := Round(k*(FPosition - FMin)) + 10;
       Canvas.Pen.Color := Color;
       //Canvas.Rectangle(0,0,10,r.Bottom);
       //Canvas.Rectangle(r.Right-10,0,r.Right,r.Bottom);
       Canvas.Brush.Color := Color;
       Canvas.Rectangle(0,10,r.Right,r.Bottom-10);
       Canvas.Brush.Color := FFaceColor;

       Canvas.Font.FontName := 'Webdings';
       Canvas.Font.Color := FArrowColor;
       Canvas.Font.FontCharset := 1; 

       if Timer.Tag = 1 then
           Frame3D_Down(0,0,r.Right,10)
       else Frame3d(0,0,r.Right,10);

       DrawArrow(Width div 2 - 6,-4,Timer.Tag = 1,#53);

       if Timer.Tag = 2 then
           Frame3D_Down(0,r.Bottom-10,r.Right,r.Bottom)
       else Frame3D(0,r.Bottom-10,r.Right,r.Bottom);

       DrawArrow(Width div 2 - 6,r.Bottom-10-5,Timer.Tag = 2,#54);

       Canvas.Rectangle(0,n,r.Right,n + 10);
       Frame3D(0,n,r.Right,n + 10);
      end;
end;

{ TmdvPanelData }

destructor TScrollBarData.Destroy;
begin
    inherited;
end;

end.

