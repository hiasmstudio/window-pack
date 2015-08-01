unit hiTrackBarRush;

interface

uses Windows, Messages, Kol, Share, Win, hiLedLadder;

{$I share.inc}

const
  P_SKIP = -1;

type
  TBtnState = (bsUp, bsOver, bsDown, bsOut);
  TTickMark = (tmBottomRight, tmTopLeft, tmBoth);

  TGRushGradientStyle = (rgVertical, rgHorizontal, rgDoubleVert,
                         rgDoubleHorz, rgFromTopLeft, rgFromTopRight);
        
    TGRushPaintState = packed record
      ColorFrom:          TColor;
      ColorTo:            TColor;
      GradientStyle:      TGRushGradientStyle;
    end;

  PByteArray = ^TByteArray;
  TByteArray = array[0..32767] of byte;

  THITrackBarRush = class(THIWin)
  private

    FSlideFaceColor           : TColor;
    FSlideGradColor           : TColor;
    FActSlideFaceColor        : TColor;
    FActSlideGradColor        : TColor;
    FThumbFaceColor           : TColor;
    FThumbGradColor           : TColor;
    FBorderColor              : TColor;
    FTickColor                : TColor;
    
    FOverThumbFaceColor       : TColor;
    FOverThumbGradColor       : TColor;
    FDownThumbFaceColor       : TColor;
    FDownThumbGradColor       : TColor;

    FDisabledBorderColor      : TColor;
    FDisabledSlideFaceColor   : TColor;
    FDisabledSlideGradColor   : TColor;
    FDisabledThumbFaceColor   : TColor;
    FDisabledThumbGradColor   : TColor;
    FDisabledTickColor        : TColor;

    FDotsCount                : Integer;
    FDotsOrient               : byte;

    Shift: Integer;
    FPosition: Integer;
    FMin: Integer;
    FMax: Integer;
    FFrequency: Integer;
    FOrientation: byte;
    FTickMarks: TTickMark;
    
    FTickBorderWidth,
    FBorderWidth,
    FBorderWidthOver,
    FBorderWidthDown,
    FBorderWidthDis   : Byte;

    FSlideRoundWidth,
    FSlideRoundHeight,            
    FThumbRoundWidth,
    FThumbRoundHeight : Integer;            


    FSlideGradientStyle,
    FThumbGradientStyle,
    FThumbGradientStyleOver,
    FThumbGradientStyleDown,
    FSlideGradientStyleDis,
    FThumbGradientStyleDis   : TGRushGradientStyle;

    FThumbState: TBtnState;
    FSlideRect: TRect;
    FThumbRect: TRect;
    FAbsLength: Integer;
    FAbsPos: Integer;

    FThumbWidth: Integer;
    FThumbLength: Integer;

    Ms:TMouseEventData;

    procedure SetPosition(Value: Integer);
    procedure SetMin(Value: Integer);
    procedure SetMax(Value: Integer);
    procedure PaintTrackBar;
    procedure AntiAlias(var Clip: PBitmap);
    procedure _onMouseWheel(Sender: PControl; var Mouse: TMouseEventData); override;

  public

    _prop_Position : Integer;
    _prop_Min      : Integer;
    _prop_Max      : Integer;
    _prop_AbsPosition : boolean;
    _prop_AntiAlias : boolean;    
    
    _event_onPosition:THI_Event;
    _event_onStart:THI_Event;
    _event_onStop:THI_Event;

    property _prop_TickColor            : TColor write FTickColor;
    property _prop_TickColorDis         : TColor write FDisabledTickColor;
    property _prop_BorderColor          : TColor write FBorderColor;
    property _prop_SlideColorFrom       : TColor write FSlideFaceColor;
    property _prop_SlideColorTo         : TColor write FSlideGradColor;
    property _prop_ActSlideColorFrom    : TColor write FActSlideFaceColor;
    property _prop_ActSlideColorTo      : TColor write FActSlideGradColor;
    property _prop_BorderColorDis       : TColor write FDisabledBorderColor;
    property _prop_SlideColorFromDis    : TColor write FDisabledSlideFaceColor;
    property _prop_SlideColorToDis      : TColor write FDisabledSlideGradColor;
    property _prop_ThumbColorFromDis    : TColor write FDisabledThumbFaceColor;
    property _prop_ThumbColorToDis      : TColor write FDisabledThumbGradColor;
    property _prop_ThumbColorFrom       : TColor write FThumbFaceColor;
    property _prop_ThumbColorTo         : TColor write FThumbGradColor;
    property _prop_ThumbColorFromOver   : TColor write FOverThumbFaceColor;
    property _prop_ThumbColorToOver     : TColor write FOverThumbGradColor;
    property _prop_ThumbColorFromDown   : TColor write FDownThumbFaceColor;
    property _prop_ThumbColorToDown     : TColor write FDownThumbGradColor;

    property _prop_Frequency            : Integer write FFrequency;
    property _prop_TickMarks            : TTickMark write FTickMarks;
    property _prop_Kind                 : byte write FOrientation;

    property _prop_SlideGradientStyle     : TGRushGradientStyle write FSlideGradientStyle;
    property _prop_ThumbGradientStyle     : TGRushGradientStyle write FThumbGradientStyle;    
    property _prop_ThumbGradientStyleOver : TGRushGradientStyle write FThumbGradientStyleOver;    
    property _prop_ThumbGradientStyleDown : TGRushGradientStyle write FThumbGradientStyleDown;    
    property _prop_SlideGradientStyleDis  : TGRushGradientStyle write FSlideGradientStyleDis;
    property _prop_ThumbGradientStyleDis  : TGRushGradientStyle write FThumbGradientStyleDis;    

    property _prop_TickBorderWidth : Byte write FTickBorderWidth;
    property _prop_BorderWidth     : Byte write FBorderWidth;
    property _prop_BorderWidthOver : Byte write FBorderWidthOver;
    property _prop_BorderWidthDown : Byte write FBorderWidthDown;
    property _prop_BorderWidthDis  : Byte write FBorderWidthDis;
    
    property _prop_ThumbLength : Integer write FThumbLength;
    property _prop_ThumbWidth  : Integer write FThumbWidth;

    property _prop_SlideRoundWidth  : Integer write FSlideRoundWidth;
    property _prop_SlideRoundHeight : Integer write FSlideRoundHeight;            
    property _prop_ThumbRoundWidth  : Integer write FThumbRoundWidth;
    property _prop_ThumbRoundHeight : Integer write FThumbRoundHeight;

    property _prop_DotsCount        : Integer write FDotsCount;
    property _prop_DotsOrient       : byte write FDotsOrient;


//    constructor Create(Parent:PControl);
    procedure Init; override;
    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _work_doPosition2(var _Data:TData; Index:word);
    procedure _work_doMin(var _Data:TData; Index:word);
    procedure _work_doMax(var _Data:TData; Index:word);
    procedure _work_doEnabled(var _Data:TData; Index:word);
    procedure _var_Position(var _Data:TData; Index:word);
    procedure _work_doSetTheme(var _Data:TData; Index:word);
    procedure _work_doUpdate(var _Data:TData; Index:word);    

    procedure _work_doSlideRoundWidth(var _Data:TData; Index:word);          
    procedure _work_doSlideRoundHeight(var _Data:TData; Index:word);  
    procedure _work_doThumbRoundWidth(var _Data:TData; Index:word);  
    procedure _work_doThumbRoundHeight(var _Data:TData; Index:word);          
  end;

implementation

uses hiRGN_OutlinePicture;

const trHorizontal = 0;

type
  COLOR16 = $0000..$FF00;
  TTriVertex = packed record
    x, y: DWORD;
    Red, Green, Blue, Alpha: COLOR16;
  end;
function SysGradientFill(DC: HDC; Vertex: Pointer; NumVertex: Cardinal;
                         Mesh: Pointer; NumMesh, Mode: DWORD): BOOL; stdcall;
                         external 'msimg32.dll' name 'GradientFill';

function TrackMouseEvent(var EventTrack: TTrackMouseEvent): BOOL;
                         stdcall; external user32 name 'TrackMouseEvent';

procedure GradientFill(const State: TGRushPaintState; DC: HDC; const BorderRect: TRect);
type    TGradientRect = packed record
           UpperLeft: ULONG;
           LowerRight: ULONG;
        end;
const   PatternSize = 32;
        FromSize = 6;
        GRADIENT_FILL_RECT_H = $00000000;
        GRADIENT_FILL_RECT_V = $00000001;
var
//        TR, ATR: TRect;

        vert: Array[0..3] of TTriVertex;
        gTRi: TGradientRect;
        Align: Integer;
        tDC: HDC;

        C1, C2: TRGBQuad;
        R1, R2, B1, B2, G1, G2: integer;
        RectW, RectH: integer;
        W, H, DW, DH{, WH}: integer;
        Pattern: PBitmap;
        i{, C}: integer;
//        Br: HBrush;
begin
    RectH := BorderRect.Bottom - BorderRect.Top;
    RectW := BorderRect.Right - BorderRect.Left;
    if (RectH<=0) or (RectW<=0) then
        exit;
    C1 := TRGBQuad(Color2RGB(State.ColorFrom));
    C2 := TRGBQuad(Color2RGB(State.ColorTo));
    R1 := C1.rgbRed;
    R2 := C2.rgbRed;
    G1 := C1.rgbGreen;
    G2 := C2.rgbGreen;
    B1 := C1.rgbBlue;
    B2 := C2.rgbBlue;

    vert[0].x := 0;
    vert[0].y := 0;
    vert[0].Red := B1 shl 8;
    vert[0].Green := G1 shl 8;
    vert[0].Blue := R1 shl 8;
    vert[0].Alpha := $00;
    vert[1].Red := B2 shl 8;
    vert[1].Green := G2 shl 8;
    vert[1].Blue := R2 shl 8;
    vert[1].Alpha := $00;
    vert[2] := vert[0];
    vert[2].x := RectW;
    vert[2].y := 0;
    gTRi.UpperLeft := 0;
    gTRi.LowerRight := 1;

//    R2 := R2 - R1;
//    G2 := G2 - G1;
//    B2 := B2 - B1;
    DW := 0;
    DH := 0;
        
    case State.GradientStyle of
        rgHorizontal:
            begin
                W := RectW;
                H := PatternSize;
//                WH := W;
            end;
        rgVertical:
            begin
                W := PatternSize;
                H := RectH;
//                WH := H;
            end;
        rgDoubleHorz:
            begin
                DW := RectW;
                W := DW shr 1;
                H := PatternSize;
                DH := H;
//                WH := W;

            end;
        rgDoubleVert:
            begin
                W := PatternSize;
                DH := RectH;
                H := DH shr 1;
                DW := W;
//                WH := H;

                vert[2].x := 0;
                vert[2].y := RectH;

            end;
        rgFromTopLeft,
        rgFromTopRight:
            begin
                W := RectH + RectW;
                H := 1 + (RectH div 32);
                if H > 6 then
                    H := 6;
//                WH := W;
            end;
        else exit;
    end;

    if not (State.GradientStyle in [rgDoubleVert, rgDoubleHorz]) then begin
        DW := W;
        DH := H;
    end;
    Pattern := NewBitMap(DW, DH);

    vert[1].x := W;
    vert[1].y := H;
        
    if State.GradientStyle in [rgVertical, rgDoubleVert] then
        align := GRADIENT_FILL_RECT_V
    else
        align := GRADIENT_FILL_RECT_H;

    tDC := Pattern.Canvas.Handle;
    if State.GradientStyle in [rgDoubleHorz, rgDoubleVert] then
        sysGradientFill(tDC, @(vert[1]), 2, @gTRI, 1, align);
    sysGradientFill(tDC, @vert, 2, @gTRI, 1, align);
(*
    case State.GradientStyle of
        rgVertical, rgDoubleVert:
            begin
                TR := MakeRect(0, 0, DW, 1);
                DW := 0;
                DH := 1;
            end;
        rgHorizontal, rgFromTopLeft, rgFromTopRight, rgDoubleHorz:
            begin
                TR := MakeRect(0, 0, 1, DH);
                DW := 1;
                DH := 0;
            end;
    end;
    if State.GradientStyle = rgDoubleVert then
        ATR := MakeRect(0, RectH-1, PatternSize, RectH);
    if State.GradientStyle = rgDoubleHorz then
        ATR := MakeRect(RectW-1, 0, RectW, PatternSize);
    for i := 0 to WH do begin
        C := ((( R1 + R2 * I div WH ) and $FF) shl 16) or
             ((( G1 + G2 * I div WH ) and $FF) shl 8) or
             ( B1 + B2 * I div WH ) and $FF;
        Br := CreateSolidBrush( C );
        Windows.FillRect(Pattern.Canvas.Handle, TR, Br );

        if State.GradientStyle in [rgDoubleHorz, rgDoubleVert] then
            Windows.FillRect(Pattern.Canvas.Handle, ATR, Br);
        OffsetRect(ATR, -DW, -DH);
        OffsetRect(TR, DW, DH);
        DeleteObject( Br );
    end;
*)
    case State.GradientStyle of
        rgHorizontal, rgDoubleHorz:
            for i := 0 to (BorderRect.Bottom div PatternSize) do
                Pattern.Draw(DC, BorderRect.Left, BorderRect.Top + i*PatternSize);
        rgVertical, rgDoubleVert:
            for i := 0 to (BorderRect.Right div PatternSize) do
                Pattern.Draw(DC, BorderRect.Left + i*PatternSize, BorderRect.Top);
        rgFromTopLeft:
            for i := 0 to ((BorderRect.Bottom + H -1) div H)-1 do
                if BorderRect.Right - BorderRect.Left < BorderRect.Bottom - BorderRect.Top then   
                    Pattern.Draw(DC, BorderRect.Left + -i*H, BorderRect.Top + i*H)
                else
                    Pattern.Draw(DC, BorderRect.Left, BorderRect.Top + i*H);                  
        rgFromTopRight:
            for i := 0 to ((BorderRect.Bottom + H -1) div H)-1 do
                if BorderRect.Right - BorderRect.Left < BorderRect.Bottom - BorderRect.Top then
                    Pattern.Draw(DC, BorderRect.Left - BorderRect.Bottom + i*H, BorderRect.Top + i*H)
                else
                    Pattern.Draw(DC, BorderRect.Left, BorderRect.Top + i*H);
    end;
    Pattern.Free;
end;

function WndTrackBarExProc(Sender: PControl; var Msg: TMsg; var Rslt: Integer): Boolean;
var
  HiClass: THITrackBarRush;
  point : TPoint;
  t_MouseEvent: TTrackMouseEvent;
  oldAbsPos, AbsPos, Pos: Integer;
begin
  Result := FALSE;
  HiClass := THITrackBarRush(Sender.Tag);

  with HiClass do
    case msg.Message of
      //Обрабатываем изменения компонента
      WM_SIZE, WM_PAINT, WM_ENABLE: PaintTrackbar;
      //Обрабатываем нажатие стрелок на клавиатуре
      WM_KEYDOWN:
        if Sender.Focused then
        begin
          case Msg.WParam of
            VK_LEFT, VK_UP, VK_PAGE_UP: dec(FPosition);
            VK_RIGHT, VK_DOWN, VK_PAGE_DOWN: inc(FPosition);
            VK_END:  FPosition := FMax;
            VK_HOME: FPosition := FMin;
          end;
          SetPosition(FPosition);
          if _prop_AbsPosition then
            _hi_onEvent(_event_onStart, abs(integer(Round(FAbsPos * (FMax - FMin) / FAbsLength) + FMin)))
          else
            _hi_onEvent(_event_onStart, integer(Round(FAbsPos * (FMax - FMin) / FAbsLength) + FMin))
        end;
      //Пользователь нажал на л.кнопку мыши
      WM_KEYUP:
        if Sender.Focused then
        begin
          if _prop_AbsPosition then
            _hi_onEvent(_event_onStop, abs(integer(trunc(FAbsPos * (FMax - FMin) / FAbsLength) + FMin)))
          else
            _hi_onEvent(_event_onStop, integer(trunc(FAbsPos * (FMax - FMin) / FAbsLength) + FMin))
        end;    
      WM_LBUTTONDOWN:
        begin
          if not Sender.Enabled then exit;
          if FOrientation = trHorizontal then
            Shift:= FAbsPos - loword(Msg.lParam)
          else
            Shift:= FAbsPos - hiword(Msg.lParam);

          Sender.Focused := true;
          Point := MakePoint(loword(Msg.lParam), hiword(Msg.lParam));
          if PointInRect(Point, FThumbRect) then
          begin
            SetCapture(Sender.Handle);
            FThumbState:= bsDown;
            PaintTrackbar;
          end
          else if PointInRect(Point, FSlideRect) then
          begin
            oldAbsPos := FAbsPos;
            if FOrientation = trHorizontal then
              AbsPos:= loword(Msg.lParam)
            else
              AbsPos:= hiword(Msg.lParam);
            if AbsPos < 0 then AbsPos:= 0;
            if AbsPos > FAbsLength then AbsPos:= FAbsLength;
            Pos := Round(AbsPos * (FMax - FMin) / FAbsLength) + FMin;
            if AbsPos > oldAbsPos then
            begin
              FPosition := FPosition + 2;
              if (FPosition > Pos) then FPosition := Pos;
            end  
            else
            begin
              FPosition := FPosition - 2;
              if (FPosition < Pos) then FPosition := Pos;
            end;  
            SetPosition(FPosition);
          end;
          if _prop_AbsPosition then
            _hi_onEvent(_event_onStart, abs(integer(Round(FAbsPos * (FMax - FMin) / FAbsLength) + FMin)))
          else
            _hi_onEvent(_event_onStart, integer(Round(FAbsPos * (FMax - FMin) / FAbsLength) + FMin))
        end;
      WM_LBUTTONUP:
        begin
          if not Sender.Enabled then exit;
          Point := MakePoint(loword(Msg.lParam), hiword(Msg.lParam));
          if PointInRect(Point, FThumbRect) then
            FThumbState:= bsOver else FThumbState:= bsOut;
          PaintTrackbar;
          ReleaseCapture;
          if _prop_AbsPosition then
            _hi_onEvent(_event_onStop, abs(integer(Round(FAbsPos * (FMax - FMin) / FAbsLength) + FMin)))
          else
            _hi_onEvent(_event_onStop, integer(Round(FAbsPos * (FMax - FMin) / FAbsLength) + FMin))
        end;
      WM_MOUSEMOVE:
        begin
          t_MouseEvent.cbSize := SizeOf(TTrackMouseEvent);
          t_MouseEvent.dwFlags := TME_LEAVE;
          t_MouseEvent.hwndTrack := Sender.GetWindowHandle;
          t_MouseEvent.dwHoverTime := HOVER_DEFAULT;
          TrackMouseEvent(t_MouseEvent);

          if not Sender.Enabled then exit;
          GetCursorPos( Point );
          Point := Sender.Screen2Client( Point );

          if not PtInRect( Sender.ClientRect, Point) then exit;
          if FThumbState <> bsDown then
            if not PointInRect(Point, FThumbRect) then
              FThumbState:= bsOut else FThumbState := bsOver;
          if FThumbState = bsDown then
          begin
            if FOrientation = trHorizontal then
              FAbsPos:= loword(Msg.lParam) + Shift
            else
              FAbsPos:= hiword(Msg.lParam) + Shift;
            if FAbsPos < 0 then FAbsPos:= 0;
            if FAbsPos > FAbsLength then FAbsPos:= FAbsLength;
            FPosition:= Round(FAbsPos * (FMax - FMin) / FAbsLength) + FMin;
            FAbsPos:= Round((FAbsLength / (FMax - FMin)) * (FPosition - FMin));
            if _prop_AbsPosition then
              _hi_onEvent(_event_onPosition, abs(FPosition))
            else              
              _hi_onEvent(_event_onPosition, FPosition);            
          end;
          PaintTrackbar;
        end;
      WM_MOUSELEAVE:
        begin
          FThumbState := bsOut;
          PaintTrackbar;          
          t_MouseEvent.cbSize := SizeOf(TTrackMouseEvent);
          t_MouseEvent.dwFlags := TME_HOVER;
          t_MouseEvent.hwndTrack := Sender.GetWindowHandle;
          t_MouseEvent.dwHoverTime := HOVER_DEFAULT;
          TrackMouseEvent(t_MouseEvent);
        end;
    end;
end;

procedure THITrackBarRush.AntiAlias;
var X,Y: integer;
    P1,P2: PByteArray;
begin
  Clip.PixelFormat := pf24bit;
  for Y := 0 to Clip.Height - 2 do
  begin
    P1 := Clip.ScanLine[Y];
    P2 := Clip.ScanLine[Y + 1];
    for X := 0 to Clip.Width - 1 do
    begin
      P1[X * 3]     := (P2[X *3]     + P1[(X) * 3])     div 2;
      P1[X *3 + 1]  := (P2[X *3 + 1] + P1[(X) * 3 + 1]) div 2;
      P1[X * 3 + 2] := (P2[X *3 + 2] + P1[(X) * 3 + 2]) div 2;
    end;
  end;
end;

procedure THITrackBarRush.PaintTrackbar;
var
  aBorderColor, aSlideFaceColor, aSlideGradColor, aTickColor: TColor;
  aActSlideFaceColor, aActSlideGradColor: TColor;
  aThumbFaceColor, aThumbGradColor: TColor;
  aSlideGradientStyle, aThumbGradientStyle: TGRushGradientStyle;
  aBorderWidth, ThumbBorderWidth: Byte;
  ScrBmp, ActScrBmp, SrcThumb, src2: Kol.PBitmap;
  i: integer;
  State: TGRushPaintState;
  ARect: TRect;
  M, N: Integer;
  
begin
  with Control{$ifndef F_P}^{$endif}  do
  begin
  aBorderColor:= FBorderColor;

  aSlideFaceColor:= FSlideFaceColor;
  aSlideGradColor:= FSlideGradColor;
  aActSlideFaceColor:= FActSlideFaceColor;
  aActSlideGradColor:= FActSlideGradColor;
  aSlideGradientStyle := FSlideGradientStyle;
  aBorderWidth := FBorderWidth;  
  aTickColor:= FTickColor;

  case FThumbState of
    bsOver:   begin
                aThumbFaceColor := FOverThumbFaceColor;
                aThumbGradColor := FOverThumbGradColor;
                aThumbGradientStyle := FThumbGradientStyleOver;
                ThumbBorderWidth := FBorderWidthOver;
              end;
    bsDown:   begin
                aThumbFaceColor:= FDownThumbFaceColor;
                aThumbGradColor:= FDownThumbGradColor;
                aThumbGradientStyle := FThumbGradientStyleDown;
                ThumbBorderWidth := FBorderWidthDown;
              end
    else
              begin
                aThumbFaceColor:= FThumbFaceColor;
                aThumbGradColor:= FThumbGradColor;
                aThumbGradientStyle := FThumbGradientStyle;
                ThumbBorderWidth := FBorderWidth;                
              end;
  end;

  if not Enabled then begin
    aBorderColor:= FDisabledBorderColor;
    aSlideFaceColor:= FDisabledSlideFaceColor;
    aSlideGradColor:= FDisabledSlideGradColor;
    aActSlideFaceColor:= FDisabledSlideFaceColor;
    aActSlideGradColor:= FDisabledSlideGradColor;
    aThumbFaceColor:= FDisabledThumbFaceColor;
    aThumbGradColor:= FDisabledThumbGradColor;
    aThumbGradientStyle := FThumbGradientStyleDis;
    aSlideGradientStyle := FSlideGradientStyleDis;
    aBorderWidth := FBorderWidthDis;
    aTickColor:= FDisabledTickColor;
  end;

  ScrBmp := NewBitmap(0,0);
  ActScrBmp := NewBitmap(0,0);  
  SrcThumb := NewBitmap(0,0);  
  ScrBmp.Width:= ClientWidth;
  ScrBmp.Height:= ClientHeight;

  ScrBmp.Canvas.Brush.BrushStyle:= bsSolid;
  ScrBmp.Canvas.Brush.Color:= Color2RGB(Color);
  ScrBmp.Canvas.Rectangle(-1, -1, ScrBmp.Width + 1, ScrBmp.Height + 1);
  ActScrBmp.Assign(ScrBmp);

  if FOrientation = trHorizontal then
  begin
    if FThumbLength = 0 then FThumbLength := ClientHeight - 10; 
    FThumbLength := min(FThumbLength, ClientHeight - 10);
    if FThumbWidth = 0 then FThumbWidth := FThumbLength div 2;    
    FAbsLength:= ClientWidth - FThumbWidth;

    FThumbRect.Top:= (ClientHeight - FThumbLength) div 2;
    FThumbRect.Bottom:= FThumbRect.Top + FThumbLength;
    FThumbRect.Left:= FAbsPos;
    FThumbRect.Right:= FThumbRect.Left + FThumbWidth;

    FSlideRect.Left:= 0;
    FSlideRect.Right:= ClientWidth;
    FSlideRect.Top:= ClientHeight div 3 + 1;
    FSlideRect.Bottom:= ClientHeight - FSlideRect.Top;

    SrcThumb.Width:= FThumbWidth;
    SrcThumb.Height:= FThumbLength;

  end
  else
  begin
    if FThumbLength = 0 then FThumbLength := ClientWidth - 10; 
    FThumbLength := min(FThumbLength, ClientWidth - 10);
    if FThumbWidth = 0 then FThumbWidth := FThumbLength div 2; 
    FAbsLength:= ClientHeight - FThumbWidth;

//    FPosition:= Round(FAbsPos * (FMax - FMin) / FAbsLength) + FMin;
    FAbsPos:= Round((FAbsLength / (FMax - FMin)) * (Round(FAbsPos * (FMax - FMin) / FAbsLength) + FMin - FMin));

    FThumbRect.Left:= (ClientWidth - FThumbLength) div 2;
    FThumbRect.Right:= FThumbRect.Left + FThumbLength;
    FThumbRect.Top:= FAbsPos;
    FThumbRect.Bottom:= FThumbRect.Top + FThumbWidth;

    FSlideRect.Left:= ClientWidth div 3 + 1;
    FSlideRect.Right:= ClientWidth - FSlideRect.Left;
    FSlideRect.Top:= 0;
    FSlideRect.Bottom:= ClientHeight;

    SrcThumb.Width:= FThumbLength;
    SrcThumb.Height:= FThumbWidth;
  end;

  with SrcThumb.Canvas{$ifndef F_P}^{$endif}  do
  begin
    Brush.BrushStyle:= bsClear;
    Pen.PenWidth := aBorderWidth;
    State.GradientStyle := aThumbGradientStyle;
    State.ColorFrom := aThumbFaceColor;
    State.ColorTo := aThumbGradColor; 
    GradientFill(State, Handle, MakeRect(0, 0, SrcThumb.Width, SrcThumb.Height));  
    Pen.Color := aBorderColor;
    Pen.PenWidth := ThumbBorderWidth;
    RoundRect(0, 0, SrcThumb.Width, SrcThumb.Height, FThumbRoundWidth, FThumbRoundHeight);
    Brush.BrushStyle := bsSolid;
    Brush.Color := clGray;

    M := (SrcThumb.Width - 3) div 2;
    N := (SrcThumb.Height - 3) div 2;
    for i := 0 to FDotsCount - 1 do
    begin
      if (FDotsOrient = 1) then
        N := ((SrcThumb.Height - (5 * FDotsCount - 2)) div 2) + i * 5
      else
        M := ((SrcThumb.Width - (5 * FDotsCount - 2)) div 2) + i * 5;
      FillRect(MakeRect(M, N, M + 3, N + 3));
      Pixels[M, N] := clWhite;
    end;

    Brush.Color := 65793;

    if (FThumbRoundWidth > 0) and (FThumbRoundHeight > 0) then
    begin  
      FloodFill(0, 0, aBorderColor, fsBorder);
      FloodFill(0, SrcThumb.Height - 1, aBorderColor, fsBorder);
      FloodFill(SrcThumb.Width - 1, 0, aBorderColor, fsBorder);        
      FloodFill(SrcThumb.Width - 1, SrcThumb.Height - 1, aBorderColor, fsBorder);
    end;      

  end;

  with ActScrBmp.Canvas{$ifndef F_P}^{$endif}  do
  begin
    State.GradientStyle := aSlideGradientStyle;
    State.ColorFrom := aActSlideFaceColor;
    State.ColorTo := aActSlideGradColor; 
    GradientFill(State, Handle, FSlideRect);
  end;

  with ScrBmp.Canvas{$ifndef F_P}^{$endif}  do
  begin
    Brush.BrushStyle:= bsClear;
    Pen.PenWidth := aBorderWidth;

    State.GradientStyle := aSlideGradientStyle;
    State.ColorFrom := aSlideFaceColor;
    State.ColorTo := aSlideGradColor; 
    
    GradientFill(State, Handle, FSlideRect);
    if FOrientation = trHorizontal then
      BitBlt(Handle, 0, 0, FThumbRect.Right - FSlideRect.Left, ActScrBmp.Height,
             ActScrBmp.Canvas.Handle, 0, 0, SRCCOPY)
    else
      BitBlt(Handle, 0, FThumbRect.Bottom, ActScrBmp.Width, ActScrBmp.Height - FThumbRect.Bottom,
             ActScrBmp.Canvas.Handle, 0, FThumbRect.Bottom, SRCCOPY);

    Pen.Color := aBorderColor;
    RoundRect(FSlideRect.Left, FSlideRect.Top, FSlideRect.Right, FSlideRect.Bottom, FSlideRoundWidth, FSlideRoundHeight);

    Brush.Color := Color2RGB(Color);
    Brush.BrushStyle:= bsSolid;
    FloodFill(1, 1, aBorderColor, fsBorder);
    FloodFill(1, ScrBmp.Height - 2, aBorderColor, fsBorder);
    FloodFill(ScrBmp.Width - 2, 1, aBorderColor, fsBorder);        
    FloodFill(ScrBmp.Width - 2, ScrBmp.Height - 2, aBorderColor, fsBorder);    

    SrcThumb.DrawTransparent(Handle, FThumbRect.Left, FThumbRect.Top, 65793);

    Pen.PenWidth := FTickBorderWidth;

    for i:= 0 to (FMax - FMin) do
    begin
      if not ((i = FMax - FMin)) then if FFrequency <> 0 then
        if i div FFrequency * FFrequency <> i then continue;

      Pen.Color:= aTickColor;
      if FOrientation = trHorizontal then
      begin
        if (FTickMarks = tmTopLeft) or (FTickMarks = tmBoth) then
        begin
          MoveTo(Round(FAbsLength * i / (FMax - FMin) + FThumbWidth / 2), min((ScrBmp.Height - FThumbLength - 8) div 2 - 1, FSlideRect.Top - 8));
          LineTo(Round(FAbsLength * i / (FMax - FMin) + FThumbWidth / 2), min((ScrBmp.Height - FThumbLength - 8) div 2 - 1, FSlideRect.Top - 8) + 3);
        end;
        if (FTickMarks = tmBottomRight) or (FTickMarks = tmBoth) then
        begin
          MoveTo(Round(FAbsLength * i / (FMax - FMin)) + FThumbWidth div 2, max(FThumbLength + (ScrBmp.Height - FThumbLength) div 2 + 1, FSlideRect.Bottom + 5));
          LineTo(Round(FAbsLength * i / (FMax - FMin)) + FThumbWidth div 2, max(FThumbLength + (ScrBmp.Height - FThumbLength) div 2 + 1, FSlideRect.Bottom + 5) + 3);
        end;
      end
      else
      begin
        if (FTickMarks = tmTopLeft) or (FTickMarks = tmBoth) then
        begin
          MoveTo(min((ScrBmp.Width - FThumbLength - 8) div 2 - 1, FSlideRect.Left - 8), Round(FAbsLength * i / (FMax - FMin)) + (FThumbRect.Bottom - FThumbRect.Top) div 2);
          LineTo(min((ScrBmp.Width - FThumbLength - 8) div 2 - 1, FSlideRect.Left - 8) + 3, Round(FAbsLength * i / (FMax - FMin)) + (FThumbRect.Bottom - FThumbRect.Top) div 2);
        end;
        if (FTickMarks = tmBottomRight) or (FTickMarks = tmBoth) then
        begin
          MoveTo(max(FThumbLength + (ScrBmp.Width - FThumbLength) div 2 + 1, FSlideRect.Right + 5), Round(FAbsLength * i / (FMax - FMin)) + (FThumbRect.Bottom - FThumbRect.Top) div 2);
          LineTo(max(FThumbLength + (ScrBmp.Width - FThumbLength) div 2 + 1, FSlideRect.Right + 5) + 3, Round(FAbsLength * i / (FMax - FMin)) + (FThumbRect.Bottom - FThumbRect.Top) div 2);
        end;
      end;
    end;
  end;

  if _prop_AntiAlias then
  begin
    src2 := NewBitmap(0, 0);
    src2.Assign(ScrBmp);
    ScrBmp.Free;
    AntiAlias(src2);
    ScrBmp := src2;
  end;   

  ScrBmp.Draw(Canvas.Handle, 0, 0);

  ScrBmp.Free;
  ActScrBmp.Free;
  SrcThumb.Free;
  end;
end;

procedure THITrackBarRush.SetPosition(Value: Integer);
begin
  if (Value < FMin) then Value:= FMin;
  if (Value > FMax) then Value:= FMax;
  FPosition:= Value;
  if (FMax - FMin) = 0 then exit;
  FAbsPos:= Round((FAbsLength / (FMax - FMin)) * (FPosition - FMin));
  PaintTrackbar;
end;

procedure THITrackBarRush.SetMin(Value: Integer);
begin
  FMin:= Value;
  if FPosition < FMin then FPosition:= FMin;
  if (FMax - FMin) = 0 then exit;
  FAbsPos:= Round((FAbsLength / (FMax - FMin)) * (FPosition - FMin));
  PaintTrackbar;
end;

procedure THITrackBarRush.SetMax(Value: Integer);
begin
  FMax:= Value;
  if FPosition > FMax then FPosition:= FMax;
  if (FMax - FMin) = 0 then exit;
  FAbsPos:= Round((FAbsLength / (FMax - FMin)) * (FPosition - FMin));
  PaintTrackbar;
end;

//==============================================================================

//constructor THITrackBarRush.Create;
//begin
//  inherited Create(Parent);
//end;

procedure THITrackBarRush.Init;
begin
  Control := _NewControl(FParent, 'GRUSH_TRACKBAR', WS_VISIBLE or WS_CHILD, FALSE, nil);
  Control.ClsStyle := Control.ClsStyle or CS_DBLCLKS;
  inherited;
  FThumbState  := bsOut;
  SetMax(_prop_Max); 
  SetMin(_prop_Min);
  SetPosition(_prop_Position);
  Control.onMouseWheel  := _onMouseWheel;  
  Control.AttachProc(WndTrackBarExProc); 
  Control.Tag := dword(Self);
end;

procedure THITrackBarRush._work_doPosition;
begin
  SetPosition(ToInteger(_Data));
  if _prop_AbsPosition then
    _hi_CreateEvent(_Data, @_event_onPosition, abs(FPosition))
  else  
    _hi_CreateEvent(_Data, @_event_onPosition, FPosition);
end;

procedure THITrackBarRush._work_doPosition2;
begin
  SetPosition(ToInteger(_Data));
end;

procedure THITrackBarRush._work_doMin;
begin
  SetMin(ToInteger(_Data));
end;

procedure THITrackBarRush._work_doMax;
begin
  SetMax(ToInteger(_Data));
end;

procedure THITrackBarRush._var_Position;
begin
   dtInteger(_Data, FPosition);
end;

procedure THITrackBarRush._onMouseWheel;
var
  shift: Integer;
begin
  inherited;
  Ms := Mouse;
  shift := integer(Ms.Shift) div $10000; 
  if shift > 0 then
    dec(FPosition)
  else
    inc(FPosition);  
  SetPosition(FPosition);
  if _prop_AbsPosition then
    _hi_onEvent(_event_onPosition, abs(FPosition))
  else  
    _hi_onEvent(_event_onPosition, FPosition);
end;

procedure THITrackBarRush._work_doEnabled;
begin
   Control.Enabled := ReadBool(_Data);
   InvalidateRect(Control.Handle, nil, true);
end;

procedure THITrackBarRush._work_doSetTheme;
var
  par: integer;
begin

  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then Control.Color := par;

  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FSlideFaceColor := par;
  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FSlideGradColor := par;
  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FActSlideFaceColor := par;
  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FActSlideGradColor := par;
  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FThumbFaceColor := par;
  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FThumbGradColor := par;
  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FTickColor := par;
  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FBorderColor := par;

  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FDisabledSlideFaceColor := par;
  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FDisabledSlideGradColor := par;
  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FDisabledThumbFaceColor := par;
  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FDisabledThumbGradColor := par;
  par := ReadInteger(_Data, Null);    
  if par <> P_SKIP then FDisabledTickColor := par;
  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FDisabledBorderColor := par;

  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FOverThumbFaceColor := par;
  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FOverThumbGradColor := par;

  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FDownThumbFaceColor := par;
  par := ReadInteger(_Data, Null);
  if par <> P_SKIP then FDownThumbGradColor := par;

  PaintTrackbar;

end;

procedure THITrackBarRush._work_doSlideRoundWidth;
begin
  FSlideRoundWidth := ToInteger(_Data);
  PaintTrackbar;
end;          

procedure THITrackBarRush._work_doSlideRoundHeight;  
begin
  FSlideRoundHeight := ToInteger(_Data);
  PaintTrackbar;
end;          

procedure THITrackBarRush._work_doThumbRoundWidth;  
begin
  FThumbRoundWidth := ToInteger(_Data); 
  PaintTrackbar;
end;          

procedure THITrackBarRush._work_doThumbRoundHeight;          
begin
  FThumbRoundHeight := ToInteger(_Data);
  PaintTrackbar;
end;          

procedure THITrackBarRush._work_doUpdate;
begin
  PaintTrackbar;
end;

end.