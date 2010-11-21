library Grapher;

uses
  drawShare,Windows,kol;

type
  TRPoint = record x,y:real; end;
  TLoc = record
    Bmp:PBitmap;
    Values:array[0..100]of TRPoint;
  end;
  PLoc = ^TLoc;

procedure Init(PRec:PParamRec; var ed:pointer; DTools:PDrawTools); cdecl;
var   p:PLoc;
      i:byte;
begin    //MessageBox(0,'Init','',mb_ok);
   new(p);
   ed := p;
   p.Bmp := NewBitmap(integer(SearchParam(PRec, 'Width').Value^), integer(SearchParam(PRec, 'Height').Value^));
   for i := 0 to 100 do begin
      p.Values[i].x := i;
      p.Values[i].y := Random(50);
   end;
end;

procedure Close(PRec:PParamRec; ed:pointer); cdecl;
var   p:PLoc;
begin
   p := PLoc(ed);
   p.Bmp.Free;
   dispose(p);
end;

procedure Change(PRec:PParamRec; ed:pointer; Index:integer); cdecl;
var i:byte;
begin
   if PRec[Index].Name = 'Width' then
      PLoc(ed).Bmp.Width := integer(SearchParam(PRec, 'Width').Value^)
   else if PRec[Index].Name = 'Height' then
      PLoc(ed).Bmp.Height := integer(SearchParam(PRec, 'Height').Value^)
   else if PRec[Index].Name = 'Step' then begin
      if real(PRec[Index].value^) = 0 then
         real(PRec[Index].value^) := 1;
      for i := 0 to 100 do
         PLoc(ed).Values[i].X := i*real(PRec[Index].value^);
   end;
end;

function Max(r1,r2:real):real;
begin
   if r1 > r2 then
      Result := r1
   else
      Result := r2;
end;

procedure Draw(PRec:PParamRec; ed:pointer; dc:HDC); cdecl;
var i,j:integer;
    x,dx:real;
    _Grid,ix:real;
    FY,FX:real;
    fstartY,fstartX:real;
    VSpace,HSpace:integer;

    _prop_Color,_prop_BorderColor,_prop_GridColor,_prop_AxisColor:cardinal;
    //Width,Height:integer;
    _prop_LeftMargin,_prop_TopMargin,_prop_RightMargin,_prop_BottomMargin:integer;
    FGrid:integer;
    graphMin,graphMax,FCount:integer;
begin
   _prop_Color := ColorRGB(integer(SearchParam(PRec, 'Color').value^));
   _prop_BorderColor := ColorRGB(integer(SearchParam(PRec, 'BorderColor').value^));
   _prop_GridColor := ColorRGB(integer(SearchParam(PRec, 'GridColor').value^));
   _prop_AxisColor := ColorRGB(integer(SearchParam(PRec, 'AxisColor').value^));
   //Width := integer(PRec[2].value^);
   //Height := integer(PRec[3].value^);
   _prop_LeftMargin := integer(SearchParam(PRec, 'LeftMargin').value^);
   _prop_RightMargin := integer(SearchParam(PRec, 'RightMargin').value^);
   _prop_BottomMargin := integer(SearchParam(PRec, 'BottomMargin').value^);
   _prop_TopMargin := integer(SearchParam(PRec, 'TopMargin').value^);
   FGrid := integer(SearchParam(PRec, 'Grid').value^);
   graphMin := 0;
   graphMax := 50;
   FCount := 101;

   with PLoc(ed).Bmp^,Canvas^ do
    begin
      Font.FontHeight := 8;
      Brush.Color := _prop_Color;
      FillRect(MakeRect(0,0,Width,Height));

      Pen.Color := _prop_BorderColor;
      Pen.PenStyle := psSolid;
      Rectangle(_prop_LeftMargin,_prop_TopMargin,Width - _prop_RightMargin,Height - _prop_BottomMargin);

      VSpace := Width - _prop_LeftMargin - _prop_RightMargin;
      HSpace := Height - _prop_TopMargin - _prop_BottomMargin;

      _Grid := max(1,VSpace/FGrid);
      Pen.Color := _prop_GridColor;
      Font.Color := _prop_AxisColor;
      //Pen.PenStyle := psDot;

      fstartY := graphMin;
      FY := graphMax - fstartY;
      if FCount > 0 then
       fstartX := Round(PLoc(ed).Values[0].X*100)/100
      else fstartX := 0;

      if FCount > 1 then
       begin
        FX := PLoc(ed).Values[FCount-1].X - PLoc(ed).Values[0].X;
        dx := FX/FGrid;
       end
      else
       begin
        dx := 0;
        FX := 1;
       end;
      if FY = 0 then FY := 1; /// else FY := 10;
      x := 0;
      if _Grid > 10 then
       TextOut(_prop_LeftMargin-2,Height - _prop_BottomMargin + 1,Double2Str(Round(x*100)/100 + fstartX));
      ix := _prop_LeftMargin + _Grid;;
      while ix < Width - _prop_RightMargin + 1 do
       begin
         MoveTo(Round(ix),_prop_TopMargin);
         LineTo(Round(ix),Height - _prop_BottomMargin);
         x := x + dx;
         if _Grid > 10 then
          TextOut(Round(ix)-2,Height - _prop_BottomMargin + 1,Double2Str(Round(x*100)/100 + fstartX));
         ix := ix + _Grid;
       end;

      if FCount > 0 then
        dx := FY / FGrid
      else dx := 0;
      _Grid := max(1,HSpace/FGrid);
      x := fstartY;
      if _Grid > 12 then
        TextOut(2,Height - _prop_BottomMargin - 4,Double2Str(Round(x*100)/100));
      ix := Height - _prop_BottomMargin - _Grid;
      while ix > _prop_TopMargin-1 do
       begin
         MoveTo(_prop_LeftMargin,Round(ix));
         LineTo(Width - _prop_RightMargin,Round(ix));
         x := x + dx;
         if _Grid > 12 then
          TextOut(2,Round(ix)-4,Double2Str(Round(x*100)/100));
         ix := ix - _Grid;
       end;

      Pen.Color := clRed;
      Pen.PenStyle := psSolid;
      if FCount > 0 then
       MoveTo(_prop_LeftMargin + Round(VSpace*(PLoc(ed).Values[0].x - fstartX)/FX),
              _prop_TopMargin + Round(HSpace - HSpace*(PLoc(ed).Values[0].y - fstartY)/FY));
      for i := 1 to FCount-1 do
       with PLoc(ed).Values[i] do
        if x > FX + fstartX then break
        else LineTo(_prop_LeftMargin + Round(VSpace*(x - fstartX)/FX),
               _prop_TopMargin + Round(HSpace - HSpace*(y-fstartY)/FY));

      Draw(dc,0,0);
    end;
end;

exports
   Init,
   Close,
   Draw,
   Change;

begin
end.
 