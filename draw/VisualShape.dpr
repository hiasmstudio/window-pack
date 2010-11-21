library LED;

uses
  drawShare,kol,Windows;

type
  TShapeType = (stArrowRight, stArrowLeft,
                stArrowUp, stArrowDown,
                stEllipse,
                stLineHorz, stLineVert,
                stRectangle, stRectangleRound,
                stTriangleUp, stTriangleDown, stTriangleLeft, stTriangleRight
                );

procedure Draw(PRec:PParamRec; ed:pointer; dc:HDC); cdecl;
var
  R0:TRect;
  br,fn:HBRUSH;
//  Rgn:HRGN;
  FShape:byte;
  Pen:HPEN;
  pt:integer;
  Points:array[0..2] of TPoint;
begin
   R0.Left := 0;
   R0.Top := 0;
   R0.Right := integer(SearchParam(PRec, 'Width').Value^);
   R0.Bottom := integer(SearchParam(PRec, 'Height').Value^);

   fn := CreateSolidBrush(ColorRGB(integer(SearchParam(PRec, 'Color').Value^)));

   br := CreateSolidBrush(ColorRGB(integer(SearchParam(PRec, 'Color2').Value^)));
   pen := CreatePen(byte(SearchParam(PRec, 'PStyle').Value^),integer(SearchParam(PRec, 'PWidth').Value^),integer(SearchParam(PRec, 'PColor').Value^));
   FShape := byte(SearchParam(PRec, 'ShapeType').Value^);

   FillRect(dc,R0,fn);

   SelectObject(dc,br);
   SelectObject(dc,pen);

   PT := 1;
   case TShapeType(FShape) of
      stRectangle: Rectangle(dc,PT,PT, R0.Right-PT, R0.Bottom-PT);
      stRectangleRound: RoundRect(dc,PT,PT, R0.Right-PT, R0.Bottom-PT, R0.Right div 4, R0.Bottom div 4);
      stEllipse: Ellipse(dc,PT, PT, R0.Right-PT, R0.Bottom-PT);
      stLineHorz:
        begin
          MoveToEx(dc,0, R0.Bottom div 2,nil);
          LineTo(dc,R0.Right-1, R0.Bottom div 2);
        end;
      stLineVert:
        begin
          MoveToEx(dc,R0.Right div 2, 0,nil);
          LineTo(dc,R0.Right div 2, R0.Bottom-1);
        end;
      stArrowLeft:
        begin
          MoveToEx(dc,R0.Right-1, R0.Bottom div 2,nil);
          LineTo(dc,PT, R0.Bottom div 2);
          LineTo(dc,R0.Bottom div 2, R0.Bottom-1);
          MoveToEx(dc,PT, R0.Bottom div 2,nil);
          LineTo(dc,R0.Bottom div 2, 0);
        end;
      stArrowRight:
        begin
          MoveToEx(dc,0, R0.Bottom div 2,nil);
          LineTo(dc,R0.Right-PT, R0.Bottom div 2);
          LineTo(dc,R0.Right-1-(R0.Bottom div 2), R0.Bottom-1);
          MoveToEx(dc,R0.Right-PT, R0.Bottom div 2,nil);
          LineTo(dc,R0.Right-1-(R0.Bottom div 2), 0);
        end;
      stArrowUp:
        begin
          MoveToEx(dc,R0.Right div 2, R0.Bottom-1,nil);
          LineTo(dc,R0.Right div 2, PT);
          LineTo(dc,0, R0.Right div 2);
          MoveToEx(dc,R0.Right div 2, PT,nil);
          LineTo(dc,R0.Right-1, R0.Right div 2);
        end;
      stArrowDown:
        begin
          MoveToEx(dc,R0.Right div 2, 0,nil);
          LineTo(dc,R0.Right div 2, R0.Bottom-PT);
          LineTo(dc,0, R0.Bottom-1-(R0.Right div 2));
          MoveToEx(dc,R0.Right div 2, R0.Bottom-PT,nil);
          LineTo(dc,R0.Right-1, R0.Bottom-1-(R0.Right div 2));
        end;
      stTriangleUp:
       begin
        Points[0].x := R0.Right div 2;
        Points[0].y := 0;
        Points[1].x := R0.Right-1;
        Points[1].y := R0.Bottom-1;
        Points[2].x := 0;
        Points[2].y := R0.Bottom-1;
        Polygon(dc,Points[0],3);
       end;
      stTriangleDown:
       begin
        Points[0].x := 0;
        Points[0].y := 0;
        Points[1].x := R0.Right-1;
        Points[1].y := 0;
        Points[2].x := R0.Right div 2;
        Points[2].y := R0.Bottom-1;
        Polygon(dc,Points[0],3);
       end;
      stTriangleLeft:
       begin
        Points[0].x := 0;
        Points[0].y := R0.Bottom div 2;
        Points[1].x := R0.Right-1;
        Points[1].y := 0;
        Points[2].x := R0.Right-1;
        Points[2].y := R0.Bottom-1;
        Polygon(dc,Points[0],3);
       end;
      stTriangleRight:
       begin
        Points[0].x := 0;
        Points[0].y := 0;
        Points[1].x := R0.Right-1;
        Points[1].y := R0.Bottom div 2;
        Points[2].x := 0;
        Points[2].y := R0.Bottom-1;
        Polygon(dc,Points[0],3);
       end;
   end;

   DeleteObject(br);
   DeleteObject(fn);
   DeleteObject(pen);
end;

exports
    Draw;

begin
end.
 