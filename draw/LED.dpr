library LED;

uses
  drawShare,kol,Windows;

procedure Draw(PRec:PParamRec; ed:pointer; dc:HDC); cdecl;
var
  R0:TRect;
  br:HBRUSH;
  Rgn:HRGN;
  FShape:byte;
  FValue,FBlick:boolean;
  FColors:array[0..2]of TColor;
  PenGray,PenWhite,Pen1,Pen2,Pen3:HPEN;
  dX,dY:integer;
begin
   R0.Left := 0;
   R0.Top := 0;
   R0.Right := integer(SearchParam(PRec, 'Width').Value^);
   R0.Bottom := integer(SearchParam(PRec, 'Height').Value^);
   br := CreateSolidBrush(ColorRGB(integer(SearchParam(PRec, 'Color').Value^)));
   FShape := byte(SearchParam(PRec, 'Shape').Value^);
   FBlick := byte(SearchParam(PRec, 'Blick').Value^) = 0;
   FColors[0] := ColorRGB(integer(SearchParam(PRec, 'ColorOn').Value^));
   FColors[1] := ColorRGB(integer(SearchParam(PRec, 'ColorOff').Value^));
   FColors[2] := ColorRGB(integer(SearchParam(PRec, 'ColorBlick').Value^));
   FValue := byte(SearchParam(PRec, 'Value').Value^) = 0;

   PenGray := CreatePen(0,1,clGray);
   PenWhite := CreatePen(0,1,clWhite);

   FillRect(dc,R0,br);

   Rgn := 0;
   case FShape of
    0: Rgn := CreateEllipticRgnIndirect(R0);
    1: Rgn := CreateRectRgn(R0.Left,R0.Top,R0.Right,R0.Bottom);
   end;

        if FValue
         then Br := CreateSolidBrush(FColors[0])
         else Br := CreateSolidBrush(FColors[1]);
        if Rgn <> 0 then begin
          Windows.FillRgn(DC,Rgn,Br);
          DeleteObject(Rgn);
        end;
        DeleteObject(Br);
        if FBlick then
         begin
          SelectObject(DC,PenGray);
          Pen1 := CreatePen(0,1,FColors[1]);
          if FValue
           then begin
             Pen2 := CreatePen(0,1,FColors[2]);
             Pen3 := CreatePen(0,2,clWhite);
           end
           else begin
             Pen2 := CreatePen(0,1,FColors[1]);
             Pen3 := CreatePen(0,2,FColors[0]);
           end;
          case FShape of
            0 :
              begin
                dX := (R0.Right - R0.Left) div 8;
                dY := (R0.Bottom - R0.Top) div 8;
                Windows.Arc(DC,R0.Left,R0.Top,R0.Right,R0.Bottom,
                               R0.Right,R0.Top,R0.Left,R0.Bottom);
                SelectObject(DC,PenWhite);
                Windows.Arc(DC,R0.Left,R0.Top,R0.Right,R0.Bottom,
                               R0.Left,R0.Bottom,R0.Right,R0.Top);
                if FValue then begin
                  SelectObject(DC,Pen1);
                  Windows.Arc(DC,R0.Left+1,R0.Top+1,R0.Right-1,R0.Bottom-1,
                                 R0.Left+dX-1,R0.Bottom-1,R0.Right-1,R0.Top+dY-1);
                end;
                R0.Left := R0.Right div 5; R0.Right := R0.Right - R0.Left;
                R0.Top := R0.Bottom div 5; R0.Bottom := R0.Bottom - R0.Top;
                SelectObject(DC,Pen2);
                dX := Round((R0.Right - R0.Left) * 0.52);
                dY := Round((R0.Bottom - R0.Top) * 0.52);
                Windows.Arc(DC,R0.Left,R0.Top,R0.Right,R0.Bottom,
                               R0.Left + dX,R0.Top,R0.Left,R0.Top + dY);
                SelectObject(DC,Pen3);
                dX := Round((R0.Right - R0.Left) * 0.24);
                dY := Round((R0.Bottom - R0.Top) * 0.24);
                Windows.Arc(DC,R0.Left,R0.Top,R0.Right,R0.Bottom,
                               R0.Left+dX,R0.Top,R0.Left,R0.Top+dY);
              end;
            1 :
              begin
                Windows.MoveToEx(DC,R0.Left,R0.Bottom,nil);
                Windows.LineTo(DC,R0.Left,R0.Top);
                Windows.LineTo(DC,R0.Right,R0.Top);
                SelectObject(DC,PenWhite);
                Windows.MoveToEx(DC,R0.Right-1,R0.Top,nil);
                Windows.LineTo(DC,R0.Right-1,R0.Bottom-1);
                Windows.LineTo(DC,R0.Left,R0.Bottom-1);
                if FValue then begin
                  SelectObject(DC,Pen1);
                  Windows.MoveToEx(DC,R0.Right-2,R0.Top+1,nil);
                  Windows.LineTo(DC,R0.Right-2,R0.Bottom-2);
                  Windows.LineTo(DC,R0.Left,R0.Bottom-2);
                end;
                R0.Left := R0.Right div 12; R0.Right := R0.Right - R0.Left;
                R0.Top := R0.Bottom div 8; R0.Bottom := R0.Bottom - R0.Top;
                SelectObject(DC,Pen2);
                Windows.MoveToEx(DC,R0.Left+1,R0.Bottom-2,nil);
                Windows.LineTo(DC,R0.Left+1,R0.Top+1);
                Windows.LineTo(DC,R0.Right-2,R0.Top+1);
                SelectObject(DC,Pen3);
                Windows.MoveToEx(DC,R0.Left+1,R0.Top+2,nil);
                Windows.LineTo(DC,R0.Left+1,R0.Top+1);
                Windows.LineTo(DC,R0.Left+2,R0.Top+1);
                Windows.LineTo(DC,R0.Left+1,R0.Top+2);
              end;
          end;
          DeleteObject(Pen1);
          DeleteObject(Pen2);
          DeleteObject(Pen3);
        end;
      DeleteObject(br);
      DeleteObject(PenGray);
      DeleteObject(PenWhite);

end;

exports
    Draw;

begin
end.
 