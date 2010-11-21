unit hiImg_Rectangle;

interface

uses Windows,Kol,Share,Img_Draw;

{$I share.inc}

type
  THIImg_Rectangle = class(THIDraw2PR)
   private
   public
    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

procedure THIImg_Rectangle._work_doDraw;
var   dt: TData;
      br: HBRUSH;
      pen: HPEN;
begin
   dt := _Data;
TRY
   if not ImgGetDC(_Data) then exit;
   ReadXY(_Data);

   if _prop_Style = bsSolid then begin
      br := CreateSolidBrush(Color2RGB(ReadInteger(_Data,_data_BgColor,_prop_BgColor)));
   end else
      br := GetStockObject(NULL_BRUSH);

   ImgNewSizeDC;

   pen := CreatePen(PS_SOLID, Round((fScale.x + fScale.y) * ReadInteger(_Data,_data_Size,_prop_Size)/2), Color2RGB(ReadInteger(_Data,_data_Color,_prop_Color)));
   
   SelectObject(pDC,br);
   SelectObject(pDC,Pen);
   RoundRect(pDC, x1, y1, x2, y2, rx, ry);
   DeleteObject(br);
   DeleteObject(Pen);
FINALLY
   ImgReleaseDC;
   _hi_CreateEvent(_Data,@_event_onDraw,dt);
END;
end;

end.