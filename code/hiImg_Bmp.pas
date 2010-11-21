unit hiImg_Bmp;

interface

uses Windows,Kol,Share,Img_Draw;

type
  THIImg_Bmp = class(THIDraw2P)
   private
   public
    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

procedure THIImg_Bmp._work_doDraw;
var   dt: TData;
      src :PBitmap;            
      src2 :PBitmap;
      hdcMem:HDC;
      hdcBmp:HBITMAP;
begin
   dt := _Data;
TRY
   if not ImgGetDC(_Data) then exit;
   src := ReadBitmap(_Data,_data_SourceBitmap,nil);
   if (src = nil) or (src.Empty) then exit;
   If _prop_Antialias then 
    begin
      src2 := NewBitmap(0,0);
      src2.Assign(src);
      AntiAlias(src2);
      src := src2;
    end;
   ReadXY(_Data);

   x2 := x1 + src.width; 
   y2 := y1 + src.height;

   ImgNewSizeDC;

   case fDrawSource of
      dcHandle, 
      dcBitmap : if _prop_Transparent then
                    src.DrawTransparent(pDC, oldx1, oldy1, _prop_TransparentColor)
                 else
                    src.Draw(pDC, oldx1, oldy1);
      dcContext: begin
                    hdcMem:= CreateCompatibleDC(0);
                    hdcBmp:= CreateCompatibleBitmap(pDC, newwh, newhh);
                    SelectObject(hdcMem, hdcBmp);  
                    SetStretchBltMode(hdcMem, COLORONCOLOR);
                    StretchBlt(hdcMem, 0 , 0, newwh, newhh, src.Canvas.Handle, 0, 0, oldwh, oldhh, SRCCOPY);
                    BitBlt(pDC, x1, y1, newwh, newhh, hdcMem, 0, 0, SRCCOPY);
                    DeleteDC(hdcMem);
                    DeleteObject(hdcBmp);
                 end;
   end;
FINALLY
   ImgReleaseDC;
   If _prop_Antialias then
     src.free;
   _hi_CreateEvent(_Data,@_event_onDraw,dt);
END;
end;

end.