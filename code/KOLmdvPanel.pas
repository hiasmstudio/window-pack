unit KOLmdvPanel;

interface

{$I share.inc}

uses Windows, Messages, KOL;

type
  TBevelCut = (bvNone, bvLowered, bvRaised, bvSpace);
  TBorderStyle = (bsNone, bsSingle);


  TmdvPanel = {$ifdef F_P}class{$else}object{$endif}(TControl)
  private
    procedure Paint(DC: HDC);
    procedure SetBevelInner(const Value: TBevelCut);
    procedure SetBevelOuter(const Value: TBevelCut);
    procedure SetBevelWidth(const Value: Word);
    procedure SetBorderStyle(const Value: TBorderStyle);
    procedure SetBorderWidth(const Value: Word);
    function GetBevelInner: TBevelCut;
    function GetBevelOuter: TBevelCut;
    function GetBevelWidth: Word;
    function GetBorderStyle: TBorderStyle;
    function GetBorderWidth: Word;
    procedure UpdateBorder;
    procedure SetOnPaint(const Value: TOnPaint);
    function GetOnPaint: TOnPaint;
  public
    property BevelOuter: TBevelCut read GetBevelOuter write SetBevelOuter;
    property BevelInner: TBevelCut read GetBevelInner write SetBevelInner;
    property BevelWidth: Word read GetBevelWidth write SetBevelWidth;
    property BorderWidth: Word read GetBorderWidth write SetBorderWidth;
    property BorderStyle: TBorderStyle read GetBorderStyle write SetBorderStyle;
    property OnPaint: TOnPaint read GetOnPaint write SetOnPaint;
  end;

  PmdvPanel = {$ifndef F_P}^{$endif}TmdvPanel;
  TKOLmdvPanel = PmdvPanel;

function NewmdvPanel(AParent: PControl;
                     ABevelOuter: TBevelCut;
                     ABevelInner: TBevelCut;
                     ABevelWidth: Word;
                     ABorderStyle: TBorderStyle;
                     ABorderWidth: Word): TKOLmdvPanel;

implementation

type

  TmdvPanelData = {$ifdef F_P}class{$else}object{$endif}(TObj)
    FBevelOuter: TBevelCut;
    FBevelInner: TBevelCut;
    FBevelWidth: Word;
    FBorderWidth: Word;

    FBorderStyle: TBorderStyle;
    FOnPaint: TOnPaint;
  end;

  PmdvPanelData = {$ifndef F_P}^{$endif}TmdvPanelData;

function WndProcmdvPanel(Sender: PControl; var Msg: TMsg; var Rslt: Integer): Boolean;
var PaintStruct: TPaintStruct;
    DC: HDC;
begin
    Result := FALSE;
    case Msg.message of
      WM_PAINT,WM_PRINTCLIENT: Begin
        if PmdvPanel(Sender).fUpdCount>0 then Exit;
        if Msg.wParam = 0 then DC:= BeginPaint(Sender.Handle, PaintStruct) else DC := Msg.wParam;
        PmdvPanel(Sender).Paint(DC);
        if Assigned(PmdvPanelData(PmdvPanel(Sender).FCustomObj).FOnPaint) then PmdvPanelData(PmdvPanel(Sender).FCustomObj).FOnPaint(Sender, DC);
        if Msg.wParam = 0 then EndPaint(Sender.Handle, PaintStruct);
        Result:= True;
        Rslt:= 0;
      end;
      WM_SETTEXT: begin  //anti border-flicks after text changing 
        if lStrCmp(PChar(Msg.lParam),PmdvPanel(Sender).fCaption)<>0 then
          Sender.Caption := PChar(Msg.lParam)+#0; //#0 - not fixed kol(fpc)
        Result:= True;
        Rslt:= 1;
      end;
    end;
end;
function NewmdvPanel(AParent: PControl;
                     ABevelOuter: TBevelCut;
                     ABevelInner: TBevelCut;
                     ABevelWidth: Word;
                     ABorderStyle: TBorderStyle;
                     ABorderWidth: Word): TKOLmdvPanel;
var mdvPanelData: PmdvPanelData;
begin
    Result:= TKOLmdvPanel(NewPanel(AParent, esNone));
    {$ifdef F_P}
    mdvPanelData := PmdvPanelData.Create;
    {$else}
    New(mdvPanelData, Create);
    {$endif}
   
    Result.FCustomObj:= mdvPanelData;
    mdvPanelData.FBevelOuter:= ABevelOuter; 
    mdvPanelData.FBevelInner:= ABevelInner;
    mdvPanelData.FBevelWidth:= ABevelWidth;
    mdvPanelData.FBorderWidth:= ABorderWidth;
    mdvPanelData.FOnPaint:= nil;
    Result.BorderStyle := ABorderStyle;
    Result.AttachProc(WndProcmdvPanel);
end;

{ TmdvPanel }
function TmdvPanel.GetBevelInner: TBevelCut;
begin
    Result:= PmdvPanelData(FCustomObj).FBevelInner;
end;

function TmdvPanel.GetBevelOuter: TBevelCut;
begin
    Result:= PmdvPanelData(FCustomObj).FBevelOuter;
end;

function TmdvPanel.GetBevelWidth: Word;
begin
    Result:= PmdvPanelData(FCustomObj).FBevelWidth;
end;

function TmdvPanel.GetBorderStyle: TBorderStyle;
begin
    Result:= PmdvPanelData(FCustomObj).FBorderStyle;
end;

function TmdvPanel.GetBorderWidth: Word;
begin
    Result:= PmdvPanelData(FCustomObj).FBorderWidth;
end;

function TmdvPanel.GetOnPaint: TOnPaint;
begin
    Result:= PmdvPanelData(FCustomObj).FOnPaint;
end;

procedure TmdvPanel.Paint;

procedure Frame3D(Canvas: PCanvas; var Rect: TRect; TopColor, BottomColor: TColor; Width: Integer);
  procedure DoRect;
  var TopRight, BottomLeft: TPoint;
  begin
     TopRight.X := Rect.Right;
     TopRight.Y := Rect.Top;
     BottomLeft.X := Rect.Left;
     BottomLeft.Y := Rect.Bottom;
     Canvas.Pen.Color := TopColor;
     Canvas.PolyLine([BottomLeft, Rect.TopLeft, TopRight]);
     Canvas.Pen.Color := BottomColor;
     Dec(BottomLeft.X);
     Canvas.PolyLine([TopRight, Rect.BottomRight, BottomLeft]);
  end;

begin
  Canvas.Pen.PenWidth := 1; Dec(Rect.Bottom); Dec(Rect.Right);
  while Width > 0 do begin
    Dec(Width);
    DoRect;
    InflateRect(Rect, -1, -1);
  end;
  Inc(Rect.Bottom); Inc(Rect.Right);
end;

const Alignments:  array[TTextAlign] of Longint = (DT_LEFT, DT_RIGHT, DT_CENTER);
      VAlignments: array[TVerticalAlign] of Longint = (DT_VCENTER, DT_TOP, DT_BOTTOM);
var Rect: TRect;
    TopColor, BottomColor: TColor;
    Flags: Longint;
  procedure AdjustColors(Bevel: KOLmdvPanel.TBevelCut);
  begin
    if Bevel = KOLmdvPanel.bvLowered then begin
      TopColor := ColorsMix(0,Color);//}clBtnShadow;
      BottomColor := ColorsMix(clWhite,Color);//}clBtnHighlight;
    end  else begin
      TopColor := ColorsMix(clWhite,Color);//}clBtnHighlight;
      BottomColor := ColorsMix(0,Color);//}clBtnShadow;
    end;
  end;
begin
    Canvas.Handle:= DC;
    GetClientRect(Handle, Rect);
    if PmdvPanelData(FCustomObj).FBevelOuter <> bvNone then
    begin
      AdjustColors(PmdvPanelData(FCustomObj).FBevelOuter);
      Frame3D(Canvas, Rect, TopColor, BottomColor, PmdvPanelData(FCustomObj).FBevelWidth);
    end;
    Frame3D(Canvas, Rect, Color, Color, PmdvPanelData(FCustomObj).FBorderWidth);
    if PmdvPanelData(FCustomObj).FBevelInner <> bvNone then
    begin
      AdjustColors(PmdvPanelData(FCustomObj).FBevelInner);
      Frame3D(Canvas, Rect, TopColor, BottomColor, PmdvPanelData(FCustomObj).FBevelWidth);
    end;
    if not fTransparent then begin
       Canvas.Brush.BrushStyle := bsSolid; Canvas.Brush.Color := Color;
       Canvas.FillRect(Rect);
    end;
    Canvas.Brush.BrushStyle := bsClear;
    Canvas.Font.Assign(Font);
    //Canvas.Font.FontWidth := Font.FontHeight;

    Canvas.RequiredState(BrushValid or FontValid);
    Flags := DT_EXPANDTABS or DT_SINGLELINE or VAlignments[fVerticalAlign] or Alignments[fTextAlign];
    Windows.DrawText(Canvas.Handle, fCaption, -1, Rect, Flags);
end;

procedure TmdvPanel.SetBevelInner(const Value: TBevelCut);
begin
    PmdvPanelData(FCustomObj).FBevelInner := Value;
    UpdateBorder;
    Invalidate;
end;

procedure TmdvPanel.SetBevelOuter(const Value: TBevelCut);
begin
    PmdvPanelData(FCustomObj).FBevelOuter := Value;
    UpdateBorder;
    Invalidate;
end;

procedure TmdvPanel.SetBevelWidth(const Value: Word);
begin
    PmdvPanelData(FCustomObj).FBevelWidth := Value;
    UpdateBorder;
    Invalidate;
end;

procedure TmdvPanel.SetBorderStyle(const Value: TBorderStyle);
const BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
      BorderStylesEx: array[TBorderStyle] of DWORD = (0, WS_EX_CLIENTEDGE);
begin
    PmdvPanelData(FCustomObj).FBorderStyle := Value;
    Style := Style and not WS_DLGFRAME and not WS_BORDER and not SS_SUNKEN and not WS_BORDER or BorderStyles[PmdvPanelData(FCustomObj).FBorderStyle];
    ExStyle := ExStyle and not WS_EX_TRANSPARENT and not WS_EX_STATICEDGE and not WS_EX_CLIENTEDGE or BorderStylesEx[PmdvPanelData(FCustomObj).FBorderStyle];
    UpdateBorder;
end;

procedure TmdvPanel.SetBorderWidth(const Value: Word);
begin
    PmdvPanelData(FCustomObj).FBorderWidth := Value;
    UpdateBorder;
    Invalidate;
end;

procedure TmdvPanel.SetOnPaint(const Value: TOnPaint);
begin
    PmdvPanelData(FCustomObj).FOnPaint := Value;
end;

procedure TmdvPanel.UpdateBorder;
begin
  Border:= BorderWidth + BevelWidth*Ord(BevelOuter <> bvNone) + BevelWidth*Ord(BevelInner <> bvNone);
  Global_Align({$ifndef F_P}@{$endif}Self)
end;

end.

