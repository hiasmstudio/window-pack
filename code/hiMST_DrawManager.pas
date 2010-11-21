unit hiMST_DrawManager;

interface
     
uses Windows, Messages, Kol, Share, Debug;

const
   _Flags_NEV = DT_NOPREFIX or DT_END_ELLIPSIS or DT_VCENTER;
   _Flags_WL  = DT_NOPREFIX or DT_END_ELLIPSIS or DT_VCENTER or DT_WORDBREAK or DT_LEFT; 
   _Flags_WR  = DT_NOPREFIX or DT_END_ELLIPSIS or DT_VCENTER or DT_WORDBREAK or DT_RIGHT;
   _Flags_WC  = DT_NOPREFIX or DT_END_ELLIPSIS or DT_VCENTER or DT_WORDBREAK or DT_CENTER;
   _Flags_SL  = DT_NOPREFIX or DT_END_ELLIPSIS or DT_VCENTER or DT_SINGLELINE or DT_LEFT;
   _Flags_SR  = DT_NOPREFIX or DT_END_ELLIPSIS or DT_VCENTER or DT_SINGLELINE or DT_RIGHT;
   _Flags_SC  = DT_NOPREFIX or DT_END_ELLIPSIS or DT_VCENTER or DT_SINGLELINE or DT_CENTER;

type
  PColor = ^TColor;
  COLOR16 = $0000..$FF00;
  TTriVertex = packed record
    x, y: Cardinal;
    Red, Green, Blue, Alpha: COLOR16;
  end;

  TIDrawManager = record
    customdraw: function(Sender: PControl; DC: HDC; Stage: Cardinal;
                         ItemIdx, SubItemIdx: Integer; const Rect: TRect;
                         ItemState: TDrawState; var TextColor, BackColor,
                         NewCurIdx: integer; SmIList, StIList:PImageList): Cardinal of object;
  end;
  IDrawManager = ^TIDrawManager;

  THIMST_DrawManager = class(TDebug)
   private
     twbm: TIDrawManager;
     FTabGrid,
     FTabGridFrame,
     FGradient,
     FSingleString,
     FGrid3D,
     FColorRowSel,
     FLightTextSel,
     FBumpText: boolean;

     FGutterStyle,
     FIconSize,
     FStyleGrid3D: byte;

     FFrameColor,
     FBkFrameColor,
     FGradientColor,
     FShadowColor,
     FGutterColor: TColor;
     FLightTxtColor: TColor;

     Bitmap: PBitmap;
     Icon: PIcon;

     procedure SetIconSize(Value:byte);
     function TWBMCustomDraw(Sender: PControl; DC: HDC; Stage: Cardinal;
                             ItemIdx, SubItemIdx: Integer; const Rect: TRect;
                             ItemState: TDrawState; var TextColor, BackColor,
                             NewCurIdx: integer; SmIList, StIList: PImageList): Cardinal;
   public
     _prop_Name: string;
     _event_onChangeProperty :THI_Event;

     property _prop_SingleString: boolean write FSingleString;
     property _prop_TabGrid: boolean      write FTabGrid;
     property _prop_TabGridFrame: boolean write FTabGridFrame;
     property _prop_Gradient: boolean     write FGradient;
     property _prop_ColorRowSel: boolean  write FColorRowSel;
     property _prop_LightTextSel: boolean write FLightTextSel;
     property _prop_LightTxtColor: TColor write FLightTxtColor;
     property _prop_Grid3D: boolean       write FGrid3D;
     property _prop_BumpText: boolean     write FBumpText;
     property _prop_StyleGrid3D: byte     write FStyleGrid3D;
     property _prop_GutterStyle: byte     write FGutterStyle;
     property _prop_IconSize: byte        write SetIconSize;
     property _prop_FrameColor: TColor    write FFrameColor;
     property _prop_BkFrameColor: TColor  write FBkFrameColor;
     property _prop_GradientColor: TColor write FGradientColor;
     property _prop_ShadowColor: TColor   write FShadowColor;    
     property _prop_GutterColor: TColor   write FGutterColor;
     
     constructor Create;
     destructor Destroy; override;
     function getInterfaceDrawManager: IDrawManager;

     procedure _work_doGrid3D(var _Data:TData; Index:word);
     procedure _work_doBumpText(var _Data:TData; Index:word);
     procedure _work_doStyleGrid3D(var _Data:TData; Index:word);
     procedure _work_doTabGrid(var _Data:TData; Index:word);    
     procedure _work_doTabGridFrame(var _Data:TData; Index:word); 
     procedure _work_doGradient(var _Data:TData; Index:word);
     procedure _work_doColorRowSel(var _Data:TData; Index:word);
     procedure _work_doLightTextSel(var _Data:TData; Index:word);
     procedure _work_doLightTxtColor(var _Data:TData; Index:word);
     procedure _work_doSingleString(var _Data:TData; Index:word);    
     procedure _work_doFrameColor(var _Data:TData; Index:word);
     procedure _work_doBkFrameColor(var _Data:TData; Index:word);
     procedure _work_doIconSize(var _Data:TData; Index:word);
     procedure _work_doGradientColor(var _Data:TData; Index:word);
     procedure _work_doGutterColor(var _Data:TData; Index:word);
     procedure _work_doShadowColor(var _Data:TData; Index:word);          
     procedure _work_doGutterStyle(var _Data:TData; Index:word);
  end;

implementation

//------------------------------------------------------------------------------
//
function GradientFill(DC: HDC; Vertex: Pointer; NumVertex: Cardinal;
                      Mesh: Pointer; NumMesh, Mode: Cardinal): BOOL; stdcall;
                      external 'msimg32.dll' name 'GradientFill';
function GetLightColor(Color: TColor; Light: Byte) : TColor;
var
  fFrom: TRGB;
begin
  PColor(@fFrom)^ := Color2RGB(Color);
  Result := RGB((FFrom.R*100 + (255 - FFrom.R) * Light) div 100,
                (FFrom.G*100 + (255 - FFrom.G) * Light) div 100,
                (FFrom.B*100 + (255 - FFrom.B) * Light) div 100);
end;
            
procedure _Gradient(DC: HDC; cbRect: TRect; Gradient: boolean; StartColor, EndColor: TColor;
                    Horizontal: boolean);
var
  vert: array[0..1] of TTriVertex;
  gRect: TGradientRect;
begin
  if not Gradient then EndColor := StartColor;

  vert[0].x      := cbRect.Left;
  vert[0].y      := cbRect.Top;
  vert[1].x      := cbRect.Right;
  vert[1].y      := cbRect.Bottom;
  vert[0].Alpha  := $ff00; // ???
  vert[1].Alpha  := vert[0].Alpha;

  vert[0].Red    := GetRValue(StartColor) shl 8;
  vert[0].Green  := GetGValue(StartColor) shl 8;
  vert[0].Blue   := GetBValue(StartColor) shl 8;
  vert[1].Red    := GetRValue(EndColor)   shl 8;
  vert[1].Green  := GetGValue(EndColor)   shl 8;
  vert[1].Blue   := GetBValue(EndColor)   shl 8;

  gRect.UpperLeft  := 0;
  gRect.LowerRight := 1;

  if Horizontal then
    GradientFill(DC, @vert, 2, @gRect, 1, GRADIENT_FILL_RECT_H)
  else
    GradientFill(DC, @vert, 2, @gRect, 1, GRADIENT_FILL_RECT_V);
end;

constructor THIMST_DrawManager.Create;
begin
  inherited;
  Bitmap := NewBitmap(0,0);
  Icon := NewIcon;
  twbm.customdraw := TWBMCustomDraw;
end;

destructor THIMST_DrawManager.Destroy;
begin
  Bitmap.free;
  Icon.free;
  inherited;
end; 

function THIMST_DrawManager.getInterfaceDrawManager;
begin
  Result := @twbm;
end;

function THIMST_DrawManager.TWBMCustomDraw;
var
  str: string;
  ARect, BRect, CRect: TRect;
  _Flags: Cardinal;
  SCT_cx, SCT_cy: integer;
  ColorText: TColor;
  fw: integer;
  l: TListViewOptions;
  _Color: TColor;
  wImage, hImage, check, shift, wb, hb: integer;
begin
  Result:= CDRF_DODEFAULT;
  if (Stage = CDDS_SUBITEM OR CDDS_ITEMPREPAINT) then
  begin   
    l := Sender.LVOptions;
    ARect := Sender.LVSubItemRect(ItemIdx,SubItemIdx);
    if (lvoGridLines in l) then
    begin
      inc(ARect.Left);
      dec(ARect.Bottom);
    end;  
    if SubItemIdx = 0 then
    begin
      ARect.Right := Arect.Left + Sender.LVColWidth[SubItemIdx];
      if (lvoGridLines in l) then
        dec(ARect.Right);
      if FGutterStyle <> 0 then
      begin
        CRect := Sender.LVItemRect(ItemIdx, lvipBounds);
        BRect := Sender.LVItemRect(ItemIdx, lvipLabel);
        CRect.Right := BRect.Left;
        if (lvoGridLines in l) then
        begin
          inc(CRect.Left);
          dec(CRect.Bottom);
        end;  
        Sender.Canvas.Brush.Color := Color2RGB(FGutterColor); 
        case FGutterStyle of
          1: FillRect(DC, CRect, Sender.Canvas.Brush.Handle);
          2: DrawEdge(DC, CRect, EDGE_RAISED, BF_RECT);
          3: _Gradient(DC, ARect, true,
                       GetLightColor(Color2RGB(FGutterColor),70),
                       GetLightColor(Color2RGB(FGutterColor),20), true);
        end;  
        ARect.Left := CRect.Right;
      end; 
    end;
    if FColorRowSel then
      _Color := Color2RGB(BackColor)    
    else
      _Color := Color2RGB(FGradientColor);
    str:= Sender.LVItems[ItemIdx, SubItemIdx];
    if (odsSelected in ItemState) and ((lvoRowSelect in l) or
       (not (lvoRowSelect in l)) and (SubItemIdx = 0)) then
    begin
      Sender.Canvas.Brush.Color := _Color;
      if FGradient then
        _Gradient(DC, ARect, FGradient, GetLightColor(_Color,70), GetLightColor(_Color,20), false)
      else
        FillRect(DC, ARect, Sender.Canvas.Brush.Handle);

      if FTabGrid and FTabGridFrame and (SubItemIdx = NewCurIdx) then
      begin 
        Sender.Canvas.Brush.Color := Color2RGB(FBkFrameColor);
        if (lvoGridLines in l) then
          if FGrid3D then
            fw := 3
          else
            fw := 2  
        else
          fw := 1;
        if SubItemIdx = 0 then
          CRect := Sender.LVItemRect(ItemIdx, lvipLabel)
        else
        begin
          CRect := ARect;
          if (lvoGridLines in l) then
          begin
            dec(CRect.Left);
            inc(CRect.Bottom);
          end;  
        end;  
        Sender.Canvas.Pen.Color := Color2RGB(FFrameColor);
        Sender.Canvas.Pen.PenWidth := 1;
        SelectObject(DC, Sender.Canvas.Brush.Handle);
        SelectObject(DC, Sender.Canvas.Pen.Handle);
        Rectangle(DC, CRect.Left + fw, CRect.Top + fw, CRect.Right - fw, CRect.Bottom - fw);
      end;
    end
    else
    begin
      Sender.Canvas.Brush.Color := Color2RGB(BackColor);
      FillRect(DC, ARect, Sender.Canvas.Brush.Handle);
    end;
    BRect := ARect;
    if (lvoGridLines in l) then
    begin
      dec(ARect.Left);
      inc(ARect.Bottom);
    end;       
    if SubItemIdx = 0 then
      ARect:= Sender.LVItemRect(ItemIdx, lvipLabel);
    SCT_cx := Sender.Canvas.TextExtent('M').cx; 
    SCT_cy := Sender.Canvas.TextExtent('W').cy; 
    ARect.Left := ARect.Left + SCT_cx div 2;
    ARect.Right := ARect.Right - SCT_cx div 2; 
    case ord(Sender.LVColAlign[SubItemIdx]) of
      0: _Flags := _Flags_SL; 
      1: _Flags := _Flags_SR;
      2: _Flags := _Flags_SC
      else
         _Flags := _Flags_NEV; 
    end;
    if (Sender.Canvas.TextExtent(Sender.LVItems[ItemIdx,SubItemIdx]).cx > ARect.Right - ARect.Left) and
       not FSingleString then
    begin
      CRect := ARect;
      ARect.Top := ARect.Top + SCT_cy div 4;
      ARect.Bottom := ARect.Bottom - SCT_cy div 4;
      if ARect.Bottom - ARect.Top < SCT_cy then
        ARect := CRect;   
      case ord(Sender.LVColAlign[SubItemIdx]) of
        0: _Flags := _Flags_WL; 
        1: _Flags := _Flags_WR;
        2: _Flags := _Flags_WC
        else
           _Flags := _Flags_NEV; 
      end;
    end;
    CRect := ARect;
    inc(CRect.Left);
    inc(CRect.Top);
    inc(CRect.Right);
    inc(CRect.Bottom);
    if FBumpText then
    begin
      ColorText := FShadowColor;
      if (odsSelected in ItemState) and ((lvoRowSelect in l) or
         (not (lvoRowSelect in l)) and (SubItemIdx = 0)) then
        CRect := ARect;    
      SetBkMode(DC, Windows.TRANSPARENT);
      SetTextColor(DC, Color2RGB(ColorText));
      DrawText(DC,PChar(str), -1, CRect, _Flags);
    end;
    if (odsSelected in ItemState) and ((lvoRowSelect in l) or
       (not (lvoRowSelect in l)) and (SubItemIdx = 0)) then
      if (FTabGrid and ((SubItemIdx <> NewCurIdx) or FTabGridFrame)) then
        ColorText := TextColor
      else
        if FLightTextSel then
          ColorText := Color2RGB(FLightTxtColor)
        else  
          ColorText := TextColor
    else
      ColorText := TextColor;
    SetBkMode(DC, Windows.TRANSPARENT);
    SetTextColor(DC, Color2RGB(ColorText));
    DrawText(DC, PChar(str), -1, ARect, _Flags);

    if (lvoGridLines in l) and FGrid3D then
    begin
      case FStyleGrid3D of
        0: DrawEdge(DC, BRect, EDGE_RAISED, BF_RECT);
        1: DrawEdge(DC, BRect, EDGE_SUNKEN, BF_RECT)
        else
           DrawEdge(DC, BRect, EDGE_RAISED, BF_RECT);
      end;
    end;
    Result := CDRF_SKIPDEFAULT;
  end
  else if (Stage = CDDS_ITEMPOSTPAINT) then
  begin 
    if Assigned(SmIList) then
    begin
      wImage := Min(SmIList.ImgWidth, FIconSize);
      hImage := Min(SmIList.ImgHeight, FIconSize);
      ARect := Sender.LVItemRect(ItemIdx, lvipIcon);
      BRect := ARect;
      ARect.Left := ARect.Left + (ARect.Right - ARect.Left - wImage - 1) div 2; 
      ARect.Top  := ARect.Top  + (ARect.Bottom - ARect.Top - hImage - 1) div 2;
      Icon.Clear;
      Icon.Handle := SmIList.ExtractIcon(Sender.LVItemImageIndex[ItemIdx]);
      DrawIconEx(DC, ARect.Left, ARect.Top, Icon.Handle, wImage, hImage, 0, 0, DI_NORMAL);
    end;
    l := Sender.LVOptions;
    if (lvoCheckBoxes in l) then
    begin    
      check := Sender.LVItemStateImgIdx[ItemIdx];

      if Assigned(SmIList) then
        ARect:= Sender.LVItemRect(ItemIdx, lvipBounds)
      else  
        ARect:= Sender.LVItemRect(ItemIdx, lvipLabel);
      ARect.Right := BRect.Left;

      if check <> 0 then
      begin
        if not Assigned(StIList) then
        begin
          bitmap.Clear;
          bitmap.LoadFromResourceID(0, OBM_CHECKBOXES);
          wb := bitmap.width div 4;
          hb := bitmap.height div 3;     
          ARect.Left := ARect.Left + (ARect.Right - ARect.Left - wb) div 2;
          ARect.Top  := ARect.Top  + (ARect.Bottom - ARect.Top - hb - 1) div 2;
          if check = 1 then
            shift := 0
          else  
            shift := wb;
          BitBlt(DC, ARect.Left, ARect.Top, wb, hb, Bitmap.Canvas.Handle, shift, 0, SRCCOPY);     
        end
        else
        begin
          wImage := Min(StIList.ImgWidth, FIconSize);
          hImage := Min(StIList.ImgHeight, FIconSize);
          ARect.Left := ARect.Left + (ARect.Right - ARect.Left - wImage) div 2; 
          ARect.Top  := ARect.Top  + (ARect.Bottom - ARect.Top - hImage - 1) div 2;
          Icon.Clear;
          if check = 1 then
            Icon.Handle := StIList.ExtractIcon(0)
          else  
            Icon.Handle := StIList.ExtractIcon(1);
          DrawIconEx(DC, ARect.Left, ARect.Top, Icon.Handle, wImage, hImage, 0, 0, DI_NORMAL);
        end;
      end;
    end;
    Result:= CDRF_SKIPDEFAULT;
  end;
end;

procedure THIMST_DrawManager._work_doGrid3D;
begin
  FGrid3D:= ReadBool(_Data);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_DrawManager._work_doBumpText;
begin
  FBumpText:= ReadBool(_Data);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_DrawManager._work_doStyleGrid3D;
begin
  FStyleGrid3D:= ToInteger(_Data);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_DrawManager._work_doTabGrid;
begin
  FTabGrid:= ReadBool(_Data);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_DrawManager._work_doTabGridFrame;
begin
  FTabGridFrame:= ReadBool(_Data);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_DrawManager._work_doSingleString;
begin
  FSingleString:= ReadBool(_Data);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_DrawManager._work_doGradient;
begin
  FGradient:= ReadBool(_Data);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_DrawManager._work_doColorRowSel;
begin
  FColorRowSel:= ReadBool(_Data);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_DrawManager._work_doLightTextSel;
begin
  FLightTextSel:= ReadBool(_Data);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_DrawManager._work_doLightTxtColor;
begin
  FLightTxtColor:= ToInteger(_Data);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_DrawManager._work_doFrameColor;
begin
  FFrameColor:= ToInteger(_Data);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_DrawManager._work_doBkFrameColor;
begin
  FBkFrameColor:= ToInteger(_Data);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_DrawManager._work_doGutterColor;
begin
  FGutterColor:= ToInteger(_Data);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_DrawManager._work_doGradientColor;
begin
  FGradientColor:= ToInteger(_Data);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_DrawManager._work_doShadowColor;
begin
  FShadowColor:= ToInteger(_Data);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_DrawManager._work_doGutterStyle;
begin
  FGutterStyle:= ToInteger(_Data);
  _hi_onEvent(_event_onChangeProperty);
end;

procedure THIMST_DrawManager.SetIconSize;
begin
  FIconSize := Value;
  if FIconSize = 0 then
    FIconSize:= GetSystemMetrics(SM_CXICON);
end;

procedure THIMST_DrawManager._work_doIconSize;
begin
  SetIconSize(ToInteger(_Data));
end;

end.