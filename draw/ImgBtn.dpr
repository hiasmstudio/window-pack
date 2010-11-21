library ImgBtn;

uses
  drawShare,Windows,kol;

type
  TLoc = record
    Bmp:cardinal;
  end;
  PLoc = ^TLoc;

var DT:PDrawTools;

procedure Init(PRec:PParamRec; var ed:pointer; DTools:PDrawTools); cdecl;
var p:PLoc;
begin    //MessageBox(0,'Init','',mb_ok);
   new(p);
   ed := p;
   DT := DTools;
//   p.Bmp := DT.CreateBitmap(@PRec[13]);
   p.Bmp := DT.CreateBitmap(SearchParam(PRec, 'Normal'));
end;

procedure Close(PRec:PParamRec; ed:pointer); cdecl;
var p:PLoc;
begin
   p := PLoc(ed);
   DT.DeleteBitmap( p.Bmp );
   dispose(p);
end;

procedure Change(PRec:PParamRec; ed:pointer; Index:integer); cdecl;
var i:byte;
begin
   if PRec[Index].Name = 'Normal' then begin
      DT.DeleteBitmap( PLoc(ed).bmp );
      PLoc(ed).Bmp := DT.CreateBitmap(@PRec[Index]);
   end;
end;

function Max(r1,r2:real):real;
begin
   if r1 > r2 then
    Result := r1
   else Result := r2;
end;

procedure Draw(PRec:PParamRec; ed:pointer; dc:HDC); cdecl;
var br:HBRUSH;
begin
   br := CreateSolidBrush(ColorRGB(integer(SearchParam(PRec, 'Color').Value^)));
   SelectObject(dc,br);
   FillRect(dc,MakeRect(0,0,integer(SearchParam(PRec, 'Width').Value^),integer(SearchParam(PRec, 'Height').Value^)),br);
   DT.DrawBitmap(PLoc(ed).Bmp,dc,0,0);
   DeleteObject(br);
end;

exports
   Init,
   Close,
   Draw,
   Change;

begin
end.
 