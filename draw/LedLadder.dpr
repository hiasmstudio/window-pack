library LedLadder;


uses   Windows,drawShare,kol;
  
function GradientFill(DC: HDC; Vertex: Pointer; NumVertex: Cardinal;
                      Mesh: Pointer; NumMesh, Mode: DWORD): BOOL; stdcall;
                      external 'msimg32.dll' name 'GradientFill';

procedure Draw(PRec:PParamRec; ed:pointer; dc:HDC); cdecl;
type   TRGB = record r,g,b,x:byte; end;
       AGRBQuad = array [0..0] of RGBQuad;
       PAGRBQuad = ^AGRBQuad;
       PColor = ^TColor;
       COLOR16 = $0000..$FF00;
       TTriVertex = packed record
          x, y: DWORD;
          Red, Green, Blue, Alpha: COLOR16;
       end;

var   i, ledHeight, posLED, posMinMid, posMidMax, delta: Integer;
      rect: TRect;
      SColor, GColor: integer;
      br:HBRUSH;
      hdcMem:HDC;
      hdcBmp:HBITMAP;
      
      fLEDCount:integer;
      fSpacing:integer;
      fMinMid:integer;
      fMidMax:integer;
      fMax:integer;
      fFonColor:integer;
      fSegColorMin:integer;
      fNoSegColorMin:integer;
      fSegColorMid:integer;
      fNoSegColorMid:integer;
      fSegColorMax:integer;
      fNoSegColorMax:integer;
      fGradient:boolean;

      fKind:byte;
      fLedPosition:integer;
      Width,Height:integer;

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

      procedure _Gradient(DC:HDC; cbRect:TRect; Gradient:boolean; StartColor,EndColor:TColor; Horizontal:boolean);
      var   vert: array[0..1] of TTriVertex;
            gRect: TGradientRect;
      begin

         if not Gradient then EndColor := StartColor;

         vert[0].x      := cbRect.Left;
         vert[0].y      := cbRect.Top;
         vert[1].x      := cbRect.Right;
         vert[1].y      := cbRect.Bottom;
         vert[0].Alpha  := $ff00; // ???
         vert[1].Alpha  := vert[0].Alpha;

         vert[0].Red    := GetRValue(StartColor) shl 8; // Значение цвета смещаем
         vert[0].Green  := GetGValue(StartColor) shl 8; // влево на 1 байт,
         vert[0].Blue   := GetBValue(StartColor) shl 8; // чтобы получилось 2 байта.
         vert[1].Red    := GetRValue(EndColor) shl 8;
         vert[1].Green  := GetGValue(EndColor) shl 8;
         vert[1].Blue   := GetBValue(EndColor) shl 8;

         gRect.UpperLeft  := 0;
         gRect.LowerRight := 1;

         if Horizontal then
            GradientFill(DC, @vert, 2, @gRect, 1, GRADIENT_FILL_RECT_H)
         else
            GradientFill(DC, @vert, 2, @gRect, 1, GRADIENT_FILL_RECT_V);
      end;

begin
   Width     := integer(SearchParam(PRec, 'width').Value^);
   Height    := integer(SearchParam(PRec, 'height').Value^);
   fSpacing  := integer(SearchParam(PRec, 'Spacing').Value^);
   fLEDCount := integer(SearchParam(PRec, 'Count').Value^);
   fMinMid   := integer(SearchParam(PRec, 'MinMid').Value^);
   fMidMax   := integer(SearchParam(PRec, 'MidMax').Value^);
   fMax      := integer(SearchParam(PRec, 'max').Value^);
   fKind     := byte(SearchParam(PRec, 'kind').Value^);
   fGradient := not boolean(SearchParam(PRec, 'Gradient').Value^);

   fFonColor      := ColorRGB(integer(SearchParam(PRec, 'FonColor').Value^));
   fSegColorMin   := ColorRGB(integer(SearchParam(PRec, 'SegColorMin').Value^));
   fNoSegColorMin := ColorRGB(integer(SearchParam(PRec, 'NoSegColorMin').Value^));
   fSegColorMid   := ColorRGB(integer(SearchParam(PRec, 'SegColorMid').Value^));
   fNoSegColorMid := ColorRGB(integer(SearchParam(PRec, 'NoSegColorMid').Value^));
   fSegColorMax   := ColorRGB(integer(SearchParam(PRec, 'SegColorMax').Value^));
   fNoSegColorMax := ColorRGB(integer(SearchParam(PRec, 'NoSegColorMax').Value^));


   hdcMem:= CreateCompatibleDC(0);
   hdcBmp:= CreateCompatibleBitmap(DC,Width,Height);
   SelectObject(hdcMem, hdcBmp);
   
   fLedPosition := fMax div 2;

   br := CreateSolidBrush(fFonColor);
   Fillrect(hdcMem,MakeRect (0, 0, Width, Height),br);
   DeleteObject(br);

   posLED := ((fLedPosition * fLedCount + fLedCount div 2) * fLedCount - 1) div (fMax * fLEDCount);
   posMinMid := fLedCount * fMinMid div fMax - 1;
   posMidMax := fLedCount * fMidMax div fMax - 1;
   if fKind = 1 then begin
      ledHeight := height div fLedCount;
      delta := height mod fLedCount;
   end else begin
      ledHeight := (width - fSpacing) div fLedCount - fSpacing;
      delta := 0;
   end;
   for i := 0 to fLedCount - 1 do begin
      if (i >= posLED) and (i < posMinMid) then begin
         GColor := fNoSegColorMin;
         br := CreateSolidBrush(fNoSegColorMin)
      end else if (i >= posLED) and (i < posMidMax) then begin
         GColor := fNoSegColorMid;
         br := CreateSolidBrush(fNoSegColorMid)
      end else if (i >= posLED) and (i < fLEDCount) then begin
         GColor := fNoSegColorMax;
         br := CreateSolidBrush(fNoSegColorMax)
      end else if (i < posLED) and (i < posMinMid) then begin
         GColor := fSegColorMin;
         br := CreateSolidBrush(fSegColorMin)
      end else if (i < posLED) and (i < posMidMax) then begin
         GColor := fSegColorMid;
         br := CreateSolidBrush(fSegColorMid)
      end else if (i < posLED) and (i < fLEDCount) then begin
         GColor := fSegColorMax;
         br := CreateSolidBrush(fSegColorMax);
      end else begin
         GColor := fFonColor;
         br := CreateSolidBrush(fFonColor);
      end;
      
      SColor := GetShadeColor(GColor,100);

      if fKind = 1 then begin
         rect.Left := 1;
         rect.right := width - 1;
         rect.Top := (fLedCount - i - 1) * ledHeight + delta;
         rect.Bottom := rect.Top + ledHeight - fSpacing;
         if fGradient then
            _Gradient(hdcMem,Rect,true,GColor,SColor,true)
         else
            FillRect(hdcMem,rect,br);
            DeleteObject(br);
      end else begin
         rect.top := 1;
         rect.bottom := height - 1;
         rect.left := i * (ledHeight + fSpacing) + fSpacing;
         if (i = 0) and (fSpacing = 0) then rect.left := rect.left +1;
         rect.right := rect.left + ledHeight;
         if fGradient then
            _Gradient(hdcMem,Rect,true,GColor,SColor,false)
         else
            FillRect(hdcMem,rect,br);
            DeleteObject(br);
      end;
      BitBlt(DC, 0, 0, Width, Height, hdcMem, 0, 0, SRCCOPY);
   end;
end;

exports
    Draw;

begin
end.
 