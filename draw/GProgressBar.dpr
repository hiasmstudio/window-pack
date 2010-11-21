library GProgressBar;


uses
  drawShare,kol,Windows;

procedure Draw(PRec:PParamRec; ed:pointer; dc:HDC); cdecl;
type TRGB = record r,g,b,x:byte; end;
var
  dr,dg,db:byte;
  _Color:cardinal;
  t:real;
  i:integer;
  br:HBRUSH;
  pen:HPEN;

  _prop_Color:integer;
  _prop_Kind:byte;
  _prop_Max,FPosition:integer;
  Width,Height:integer;
  _prop_LightProgress,_prop_DarkProgress:integer;
  function CalcViewPos(Value:integer):integer;
  begin
   if _prop_Max = 0 then
     Result := 0
   else
   case _prop_Kind of
    0: Result := Round( Width*(value)/(_prop_Max) );
    1: Result := Height - Round( Height*(value)/(_prop_Max) );
   end;
  end;
begin
     Width := integer(SearchParam(PRec, 'width').Value^);
     Height := integer(SearchParam(PRec, 'height').Value^);
     _prop_Color := ColorRGB(integer(SearchParam(PRec, 'color').Value^));
     _prop_Max := integer(SearchParam(PRec, 'max').Value^);
     _prop_Kind := byte(SearchParam(PRec, 'kind').Value^);
     _prop_LightProgress := ColorRGB(integer(SearchParam(PRec, 'LightProgress').Value^));
     _prop_DarkProgress := ColorRGB(integer(SearchParam(PRec, 'DarkProgress').Value^));
     FPosition := _prop_Max div 2;

     br := CreateSolidBrush(_prop_Color);
     SelectObject(dc,br);
     if _prop_Kind = 0 then
       FillRect(dc,MakeRect(CalcViewPos(FPosition),0,Width,Height),br)
     else FillRect(dc,MakeRect(0,0,Width,CalcViewPos(FPosition)),br);
     deleteobject(br);

     dr := TRGB(_prop_LightProgress).r - TRGB(_prop_DarkProgress).r;
     dg := TRGB(_prop_LightProgress).g - TRGB(_prop_DarkProgress).g;
     db := TRGB(_prop_LightProgress).b - TRGB(_prop_DarkProgress).b;

     if _prop_Kind = 0 then
      for i := 0 to Height-1 do
       begin
        t := i/(Height-1);
        with TRGB(_prop_DarkProgress) do
         _Color := RGB(round(dr*t + r),Round(dg*t + g),Round(db*t + b));

        pen := CreatePen(0,1,_Color);
        SelectObject(dc,Pen);
        MoveToEx(dc,0,Height - i - 1,nil);
        LineTo(dc,CalcViewPos(FPosition),Height - i - 1);
        DeleteObject(pen);
       end
     else
      for i := 0 to Width-1 do
       begin
        t := i/(Width-1);
        with TRGB(_prop_DarkProgress) do
         _Color := RGB(round(dr*t + r),Round(dg*t + g),Round(db*t + b));
        pen := CreatePen(0,1,_Color);
        SelectObject(dc,Pen);
        MoveToEx(dc,Width - i - 1,CalcViewPos(FPosition),nil);
        LineTo(dc,Width - i - 1,Height);
        DeleteObject(pen);
       end
end;

exports
    Draw;

begin
end.
 