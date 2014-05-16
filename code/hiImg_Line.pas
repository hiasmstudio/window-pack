unit hiImg_Line;

interface

{$I share.inc}

uses Windows,Kol,Share,Img_Draw;

type
  THIImg_Line = class(THIImg)
   private
   public
    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

procedure THIImg_Line._work_doDraw;
var   dt: TData;
      pen: HPEN;
      mTransform: PTransform;
begin
   dt := _Data;
TRY
   if not ImgGetDC(_Data) then exit;
   ReadXY(_Data);

   ImgNewSizeDC;

   pen := CreatePen(ord(_prop_LineStyle), Round((fScale.x + fScale.y) * ReadInteger(_Data,_data_Size,_prop_Size)/2), Color2RGB(ReadInteger(_Data,_data_Color,_prop_Color)));
   SelectObject(pDC,Pen);
   mTransform := ReadObject(_Data, _data_Transform, TRANSFORM_GUID);
   if mTransform <> nil then
    if mTransform._Set(pDC,x1,y1,x2,y2) then  //если необходимо изменить координаты (rotate, flip)
     PRect(@x1)^ := mTransform._GetRect(MakeRect(x1,y1,x2,y2));
   MoveToEx(pDC, x1, y1, nil);
   LineTo(pDC, x2, y2);
   DeleteObject(Pen);
   if mTransform <> nil then mTransform._Reset(pDC);
FINALLY
   ImgReleaseDC;
   _hi_CreateEvent(_Data,@_event_onDraw,dt);
END;
end;







end.