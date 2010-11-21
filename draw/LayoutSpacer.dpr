library LayoutSpacer;

uses
  drawShare,kol,Windows;

procedure Draw(PRec:PParamRec; ed:pointer; dc:HDC); cdecl;
var
   R0:TRect;
   br:HBRUSH;
   pen:HPEN;
   i:integer;
begin
   R0.Left := 0;
   R0.Top := 0;
   R0.Right := integer(SearchParam(PRec, 'Width').Value^);
   R0.Bottom := integer(SearchParam(PRec, 'Height').Value^);
   br := CreateSolidBrush(Color2RGB(clBtnFace));
   pen := CreatePen(0,1,clBlue);
   SelectObject(dc, pen);
   FillRect(dc,R0,br);
   i := 2;
   while i < R0.Right div 2 - 6 do
     begin
       MoveToEx(dc, i, R0.Bottom div 2 - 3, nil);
       LineTo(dc, i, R0.Bottom div 2 + 3);
       MoveToEx(dc, R0.Right div 2 + 5 + i, R0.Bottom div 2 - 3, nil);
       LineTo(dc, R0.Right div 2 + 5 + i, R0.Bottom div 2 + 3);
       inc(i, 3);
     end;
   i := 2;
   while i < R0.Bottom div 2 - 6 do
     begin
       MoveToEx(dc, R0.Right div 2 - 3, i, nil);
       LineTo(dc, R0.Right div 2 + 3, i);
       MoveToEx(dc, R0.Right div 2 - 3, R0.Bottom div 2 + 5 + i, nil);
       LineTo(dc, R0.Right div 2 + 3, R0.Bottom div 2 + 5 + i);
       inc(i, 3);
     end;

   DrawFocusRect(dc, R0);
   DeleteObject(br);
   DeleteObject(pen);
end;

exports
    Draw;

begin
end.
 