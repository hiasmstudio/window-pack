unit hiGLabel; { Компонент градиентной надписи ver 2.30 }

interface

uses Windows,Messages,Kol,Share,Win,hiLedLadder;

//type
//  TOrientation = (orVertical, orHorizontal); //Направления заливки

type
 ThiGLabel = class(THIWin)
   private
     FHAlign: TTextAlign; 
     FVAlign: TVerticalAlign;
     FCaption: string;
     FAutoSize: boolean;
     FDepthShadow: Integer;
     FContrastGradient: Integer;
     FColorShadow: TColor;
     FColorHover: TColor;
     FFaceColor: TColor;     
     GFont:PGraphicTool;
     FInversGrad: boolean;
     FHorizontal: boolean;
     FUnderLine: boolean;
     FFonGradient: boolean;
     FInvFonGrad: boolean;
     FHorizFonGrad: boolean;
     FContrastFon: integer;
     FDepthGrad: integer;
     FTextGradient: boolean;
     FHSymbolGrad: boolean;

     // anti-aliasing mode
     FAntiAliased: boolean;

     // internal bitmaps
     FBackBmp: PBitmap;
     FGBitmap: PBitmap;

     procedure SetFontRec(Value: TFontRec);
     procedure DrawText;

     procedure _OnPaint( Sender: PControl; DC: HDC );
     procedure _OnClick( Sender: PObj );
     procedure TFontToGFont(Font:TFontRec; grFont:PGraphicTool);
   protected
     procedure _onMouseEnter( Sender: PObj ); override;
     procedure _onMouseLeave( Sender: PObj ); override;
   public
     _data_Text:THI_Event;
     _event_OnClick:THI_Event;

     property _prop_AutoSize: Boolean  write FAutoSize;
     property _prop_AntiAliased: boolean write FAntiAliased;
     property _prop_Alignment: TTextAlign write FHAlign;     
     property _prop_VAlignment: TVerticalAlign write FVAlign;
     property _prop_DepthShadow: Integer write FDepthShadow;
     property _prop_Contrast: Integer write FContrastGradient;
     property _prop_Caption: String write FCaption;
     property _prop_ColorShadow: Integer write FColorShadow;
     property _prop_ColorHover: Integer write FColorHover;     
     property _prop_InversGrad:boolean write FInversGrad;
     property _prop_Horizontal:boolean write FHorizontal;
     property _prop_HSymbolGrad:boolean write FHSymbolGrad;
     property _prop_UnderLine:boolean write FUnderline;

     property _prop_FonGradient: boolean write FFonGradient; 
     property _prop_InvFonGrad: boolean write FInvFonGrad;
     property _prop_HorizFonGrad: boolean write FHorizFonGrad;
     property _prop_ContrastFon: integer write FContrastFon;
     property _prop_DepthGrad: integer write FDepthGrad;
     property _prop_TextGradient: boolean write FTextGradient;

     procedure Init; override;
     destructor Destroy; override;

     procedure _work_doText(var _Data:TData; Index:word);

     procedure _work_doColor(var _Data:TData; Index:word);
     procedure _work_doAntiAliased(var _Data:TData; Index:word);
     procedure _work_doAlignment(var _Data:TData; Index:word);
     procedure _work_doVAlignment(var _Data:TData; Index:word);
     procedure _work_doDepthShadow(var _Data:TData; Index:word);
     procedure _work_doContrast(var _Data:TData; Index:word);
     procedure _work_doColorShadow(var _Data:TData; Index:word);
     procedure _work_doColorHover(var _Data:TData; Index:word);
     procedure _work_doFont(var _Data:TData; Index:word);     
     procedure _work_doInversGrad(var _Data:TData; Index:word);
     procedure _work_doHorizontal(var _Data:TData; Index:word);
     procedure _work_doHSymbolGrad(var _Data:TData; Index:word);

     procedure _work_doFonGradient(var _Data:TData; Index:word); 
     procedure _work_doInvFonGrad(var _Data:TData; Index:word);
     procedure _work_doHorizFonGrad(var _Data:TData; Index:word);
     procedure _work_doContrastFon(var _Data:TData; Index:word);
     procedure _work_doTextGradient(var _Data:TData; Index:word);
     procedure _work_doDepthGrad(var _Data:TData; Index:word);
     procedure _work_doUnderLine(var _Data:TData; Index:word);
     procedure _var_Caption(var _Data:TData; Index:word);

  end;

implementation

//-----------------------   Графические методы   ----------------------

type

  AGRBQuad = array [0..0] of RGBQuad;
  PAGRBQuad = ^AGRBQuad;

  PColor = ^TColor;

function GetLightColor(Color: TColor; Light: Byte) : TColor;
var   fFrom: TRGB;
begin
  PColor(@fFrom)^:= Color2RGB(Color);
  Result := RGB(
    (FFrom.R*100 + (255 - FFrom.R) * Light) div 100,
    (FFrom.G*100 + (255 - FFrom.G) * Light) div 100,
    (FFrom.B*100 + (255 - FFrom.B) * Light) div 100
  );
end;

function GetShadeColor(Color: TColor; Shade: Byte) : TColor;
var   fFrom: TRGB;
begin
  PColor(@fFrom)^:= Color2RGB(Color);
  Result := RGB(
    Max(0, FFrom.R - Shade),
    Max(0, FFrom.G - Shade),
    Max(0, FFrom.B - Shade)
  );
end;

/////////////////////////////////////////////////////////////////
//            Градиентная заливка прямоугольника               //
/////////////////////////////////////////////////////////////////
type
  COLOR16 = $0000..$FF00;
  TTriVertex = packed record
    x, y: DWORD; // Координаты вершины
    Red, Green, Blue, Alpha: COLOR16; //Каналы цветов
  end;
function GradientFill(DC: HDC; Vertex: Pointer; NumVertex: Cardinal;
                      Mesh: Pointer; NumMesh, Mode: DWORD): BOOL; stdcall;
                      external 'msimg32.dll' name 'GradientFill';

procedure _Gradient(DC:HDC; cbRect:TRect; Gradient:boolean; ContrastGradient:integer;
                    StartColor,EndColor:TColor; Orientation:TOrientation; InversGrad:boolean);
var
  vert: array[0..1] of TTriVertex;
  gRect: TGradientRect;
begin

   if Gradient then
      StartColor:= GetLightColor(StartColor, max(0,100-ContrastGradient))
   else
      EndColor := StartColor; 
       
   vert[0].x      := cbRect.Left;
   vert[0].y      := cbRect.Top;
   vert[1].x      := cbRect.Right;
   vert[1].y      := cbRect.Bottom;
   vert[0].Alpha  := $ff00; // ???
   vert[1].Alpha  := vert[0].Alpha;  

   if not InversGrad then begin
      vert[0].Red    := GetRValue(StartColor) shl 8;
      vert[0].Green  := GetGValue(StartColor) shl 8;
      vert[0].Blue   := GetBValue(StartColor) shl 8;
      vert[1].Red    := GetRValue(EndColor) shl 8;
      vert[1].Green  := GetGValue(EndColor) shl 8;
      vert[1].Blue   := GetBValue(EndColor) shl 8;
   end else begin
      vert[1].Red    := GetRValue(StartColor) shl 8;
      vert[1].Green  := GetGValue(StartColor) shl 8;
      vert[1].Blue   := GetBValue(StartColor) shl 8;
      vert[0].Red    := GetRValue(EndColor) shl 8;
      vert[0].Green  := GetGValue(EndColor) shl 8;
      vert[0].Blue   := GetBValue(EndColor) shl 8;
   end;

   gRect.UpperLeft  := 0;
   gRect.LowerRight := 1;

   if Orientation = orHorizontal then
      GradientFill(DC, @vert, 2, @gRect, 1, GRADIENT_FILL_RECT_H)
   else
      GradientFill(DC, @vert, 2, @gRect, 1, GRADIENT_FILL_RECT_V);
end;

procedure ThiGLabel.TFontToGFont;
begin
   GrFont.Color:= Font.Color;
   Share.SetFont(GrFont,Font.Style);
   GrFont.FontName:= Font.Name;
   GrFont.FontHeight:= _hi_SizeFnt(Font.Size);
   GrFont.FontCharset:= Font.CharSet;
end;

function TrackMouseEvent(var EventTrack: TTrackMouseEvent): BOOL; stdcall; external user32 name 'TrackMouseEvent';

function WndProcGLabel( Sender: PControl; var Msg: TMsg; var Rslt: Integer ): Boolean;
var
  HiClass: ThiGLabel; 
  fs: TFontStyle;
  Track: TTrackMouseEvent;  
begin
  Result := false;
  HiClass := ThiGLabel(Sender.Tag); 
  if msg.message = WM_SIZE then
    HiClass.DrawText;
end;

procedure ThiGLabel.Init;
begin
   if FCaption = '' then FCaption := ' ';
   Control:= NewPaintBox(FParent);
   Control.Tag := longint(Self);
   Control.Attachproc(WndProcGLabel);
   SetFontRec(_prop_Font);
   FFaceColor := Color2RGB(Control.Font.Color);
   Control.OnPaint := _OnPaint;
   Control.OnClick := _OnClick;
   if (FColorHover <> 0) or FUnderline then
    begin
     Control.onMouseEnter := _OnMouseEnter;
     Control.onMouseLeave := _OnMouseLeave;
    end;
inherited;
   DrawText;
end;

destructor ThiGLabel.Destroy;
begin
  if Assigned(FBackBmp) then FBackBmp.Free;
  if Assigned(FGBitmap) then FGBitmap.free;
  if Assigned(GFont) then GFont.free;
  inherited;
end;

procedure ThiGLabel.SetFontRec;
begin
   if Assigned(GFont) then GFont.free;
   GFont := NewFont;
   TFontToGFont(Value, GFont);   
   Control.Font.Assign(GFont);
   FFaceColor := Color2RGB(Control.Font.Color);
end;

procedure ThiGLabel._OnClick;
begin
   _hi_OnEvent(_event_OnClick);
end;

procedure ThiGLabel._OnMouseEnter;
var   fs:TFontStyle;
begin
   inherited;
   if FColorHover <> 0 then FFaceColor := FColorHover;
   fs := Control.Font.FontStyle;
   if FUnderline then
      Include(fs, fsUnderline);
   Control.Font.FontStyle := fs;
   DrawText;
end;

procedure ThiGLabel._OnMouseLeave;
var   fs:TFontStyle;
begin
   inherited;
   if FColorHover <> 0 then FFaceColor := Color2RGB(Control.Font.Color);
   fs := Control.Font.FontStyle;
   if FUnderline then
      Exclude(fs, fsUnderline);   
   Control.Font.FontStyle := fs;
   DrawText;
end;

procedure ThiGLabel._OnPaint; // перерисовка текста
var   R0: TRect;
begin
   if not Assigned(FBackBmp) then exit; 
   R0 := Sender.ClientRect;
   BitBlt(DC, R0.Left, R0.Top, R0.Right-R0.Left, R0.Bottom-R0.Top, FBackBmp.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure ThiGLabel.DrawText; // отрисовка текста 
var   ARect, BRect :TRect;
      R0: TRect;
      m,i,j: integer;
      SColor,GColor: TColor;
      tl, tt, tw, th: integer;
      _Flags: dword;
begin
   th := Control.Canvas.TextExtent(FCaption).cy;
   tw := Control.Canvas.TextWidth(FCaption);

   if FAntiAliased then  
      Control.Font.Fontquality := fqAntiAliased
   else   
      Control.Font.Fontquality := fqNonAntialiased;

   If FAutoSize then
   begin 
     if Control.Align = caNone then
     begin
       Control.Width  := tw;
       Control.Height := th;
     end
     else if (Control.Align = caTop) or (Control.Align = caBottom) then
       Control.Height := th
     else if (Control.Align = caLeft) or (Control.Align = caRight) then
       Control.Width  := tw                     
   end;

   R0 := Control.ClientRect;

   if Assigned(FGBitmap) then FGBitmap.Free;
   FGBitmap :=  NewDIBBitmap(tw, th, pf32Bit);

   if Assigned(FBackBmp) then FBackBmp.Free;
   FBackBmp :=  NewDIBBitmap(Control.Width, Control.Height, pf32Bit);

   FBackBmp.Canvas.Font.Assign(Control.Font);   
   FBackBmp.Canvas.Font.Color := FColorShadow;

   BRect := R0;
   BRect.Left   := BRect.Left   + FDepthShadow;
   BRect.Top    := BRect.Top    + FDepthShadow;
   BRect.Right  := BRect.Right  + FDepthShadow;
   BRect.Bottom := BRect.Bottom + FDepthShadow;

   _Flags := DT_SINGLELINE or DT_NOPREFIX;

   case FHAlign of 
      taCenter: _Flags := _Flags or DT_CENTER; 
      taLeft  : _Flags := _Flags or DT_LEFT;
      taRight : _Flags := _Flags or DT_RIGHT;
   end;
   case FVAlign of
      vaCenter: _Flags := _Flags or DT_VCENTER;
      vaTop   : _Flags := _Flags or DT_TOP;
      vaBottom: _Flags := _Flags or DT_BOTTOM;
   end;      

   with FBackBmp.Canvas{$ifndef F_P}^{$endif} do begin

      Brush.Color := Control.Color;
      Brush.BrushStyle := bsClear;

      SColor := GetShadeColor(Color2RGB(Control.Color),100);
      GColor := Color2RGB(Control.Color);
   
      ARect := MakeRect(0,0,FBackBmp.Width,FBackBmp.Height);
      if not FHorizFonGrad then 
         _Gradient(Handle,ARect,FFonGradient,FContrastFon,GColor,SColor,orVertical,FInvFonGrad)
      else
         _Gradient(Handle,ARect,FFonGradient,FContrastFon,GColor,SColor,orHorizontal,FInvFonGrad);      
  
      SetTextColor(Handle,FColorShadow);
      SetBkMode(Handle, Windows.TRANSPARENT);
      RequiredState( HandleValid or FontValid or BrushValid or ChangingCanvas );
      Windows.DrawText(Handle, PChar(FCaption), -1, BRect, _Flags);

      if FTextGradient then
         SColor := GetShadeColor(FFaceColor,max(0,min(250,FDepthGrad)))
      else
         SColor := FFaceColor;
      GColor := FFaceColor;
      
      SetTextColor(Handle,SColor);
      SetBkMode(Handle, Windows.TRANSPARENT);
      RequiredState( HandleValid or FontValid or BrushValid or ChangingCanvas );
      Windows.DrawText(Handle, PChar(FCaption), -1, R0, _Flags);

      case FVAlign of
         vaCenter: tt := R0.Top + (R0.Bottom - R0.Top - min(th,R0.Bottom-R0.Top)) div 2;
         vaTop   : tt := R0.Top;
         vaBottom: tt := R0.Bottom - min(th,R0.Bottom-R0.Top)
         else      tt := R0.Top;
      end;
      case FHAlign of
         taCenter: tl := R0.Left + (R0.Right - R0.Left - min(tw,R0.Right-R0.Left)) div 2;
         taLeft  : tl := R0.Left;
         taRight : tl := R0.Left - min(tw,R0.Right-R0.Left)
         else      tl := R0.Left;   
      end;
   TRY
      if not FHorizontal then begin 
         ARect := MakeRect(0,0,1,min(th,R0.Bottom-R0.Top));
         _Gradient(FGBitmap.Canvas.Handle,ARect,FTextGradient,FContrastGradient,GColor,SColor,orVertical,FInversGrad);
         if not FTextGradient then exit;
         for i := 0 to (R0.Right-R0.Left)-1 do
            for j := 0 to min(R0.Bottom-R0.Top,FGBitmap.Height)-1 do
               if FBackBmp.DIBPixels[i,tt+j] = SColor then
                  FBackBmp.DIBPixels[i,tt+j] := FGBitmap.DIBPixels[0,j]; 
      end else begin
         if FHSymbolGrad then begin
            m := 0;
            for i := 1 to length(FCaption) do begin
               ARect := MakeRect(m,0,min(tw,m + FBackBmp.Canvas.TextExtent(FCaption[i]).cx),1);
               _Gradient(FGBitmap.Canvas.Handle,ARect,FTextGradient,FContrastGradient,GColor,SColor,orHorizontal,FInversGrad);
               m := m + FBackBmp.Canvas.TextExtent(FCaption[i]).cx;
            end;
         end else begin
            ARect := MakeRect(0,0,min(tw,R0.Right-R0.Left),1);
            _Gradient(FGBitmap.Canvas.Handle,ARect,FTextGradient,FContrastGradient,GColor,SColor,orHorizontal,FInversGrad);
         end;   
         if not FTextGradient then exit;
         for j := 0 to (R0.Bottom-R0.Top)-1 do
            for i := 0 to min(R0.Right-R0.Left,FGBitmap.Width)-1 do
               if FBackBmp.DIBPixels[tl+i,j] = SColor then
                  FBackBmp.DIBPixels[tl+i,j] := FGBitmap.DIBPixels[i,0];            
      end;
   FINALLY
//      Control.Invalidate;
     InvalidateRect(Control.Handle, nil, false);
   END;
   end;
end;

procedure ThiGLabel._work_doText;
begin
   FCaption := ReadString(_Data,_data_Text,'');
   if FCaption = '' then FCaption := ' ';
   DrawText;
end;
procedure ThiGLabel._work_doAntiAliased;begin FAntiAliased := ReadBool(_Data);DrawText;end;
procedure ThiGLabel._work_doAlignment;begin FHAlign := TTextAlign(ToInteger(_Data));DrawText;end;
procedure ThiGLabel._work_doVAlignment;begin FVAlign := TVerticalAlign(ToInteger(_Data));DrawText;end;
procedure ThiGLabel._work_doDepthShadow;begin FDepthShadow := ToInteger(_Data);DrawText;end;
procedure ThiGLabel._work_doContrast;begin FContrastGradient := ToInteger(_Data);DrawText;end;
procedure ThiGLabel._work_doColorShadow;begin FColorShadow := ToInteger(_Data);DrawText;end;
procedure ThiGLabel._work_doColorHover;begin FColorHover := ToInteger(_Data);DrawText;end;
procedure ThiGLabel._work_doColor;begin inherited;DrawText;end;
procedure ThiGLabel._work_doInversGrad;begin FInversGrad := ReadBool(_Data);DrawText;end;
procedure ThiGLabel._work_doHorizontal;begin FHorizontal := ReadBool(_Data);DrawText;end;
procedure ThiGLabel._work_doHSymbolGrad;begin FHSymbolGrad := ReadBool(_Data);DrawText;end;
procedure ThiGLabel._work_doUnderLine;begin FUnderline := ReadBool(_Data);end;
procedure ThiGLabel._work_doFonGradient;begin FFonGradient := ReadBool(_Data);DrawText;end;
procedure ThiGLabel._work_doInvFonGrad;begin FInvFonGrad := ReadBool(_Data);DrawText;end;
procedure ThiGLabel._work_doHorizFonGrad;begin FHorizFonGrad := ReadBool(_Data);DrawText;end;
procedure ThiGLabel._work_doContrastFon;begin FContrastFon := ToInteger(_Data);DrawText;end;
procedure ThiGLabel._work_doDepthGrad;begin FDepthGrad := ToInteger(_Data);DrawText;end;
procedure ThiGLabel._work_doTextGradient;begin FTextGradient := ReadBool(_Data);DrawText;end;
procedure ThiGLabel._work_doFont;begin if _IsFont(_Data) then SetFontRec(PFontRec(_Data.idata)^);DrawText;end;
procedure ThiGLabel._var_Caption;begin dtString(_Data, FCaption);end;

end.