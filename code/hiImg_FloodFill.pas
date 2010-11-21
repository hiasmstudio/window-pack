unit hiImg_FloodFill;

interface

uses windows,Kol,Share,Debug,Img_Draw;

type
  THIImg_FloodFill = class(THIDraw2P)
   private
   public
    _prop_Color:TColor;

    _data_Color:THI_Event;

    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

procedure THIImg_FloodFill._work_doDraw;
var   dt: TData;
      c:TColor;
      br:HBRUSH;
begin
   dt := _Data;
TRY
   if not ImgGetDC(_Data) then exit;
   c := Color2RGB(ReadInteger(_Data,_data_Color,_prop_Color)); 
   ReadXY(_Data);
   ImgNewSizeDC;
   br := CreateSolidBrush(c);
   SelectObject(pDC, br);
   FloodFill(pDC, x1, y1, 0);
FINALLY
   DeleteObject(br);
   ImgReleaseDC;
   _hi_CreateEvent(_Data,@_event_onDraw,dt);
END;
end;

end.
