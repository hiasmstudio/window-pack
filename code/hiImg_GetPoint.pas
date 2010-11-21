unit hiImg_GetPoint;

interface

uses Windows,Kol,Share,Img_Draw;

type
  THIImg_GetPoint = class(THIDraw2P)
   private
    FColor:TColor;
   public
    _event_onGetPixel:THI_Event;
    procedure _work_doGetPixel(var _Data:TData; Index:word);
    procedure _var_Color(var _Data:TData; Index:word);
  end;

implementation

procedure THIImg_GetPoint._work_doGetPixel;
begin
TRY
   if not ImgGetDC(_Data) then exit;
   ReadXY(_Data);
   ImgNewSizeDC;
   FColor := GetPixel(pDC, x1, y1);
FINALLY
   ImgReleaseDC;
   _hi_CreateEvent(_Data, @_event_onGetPixel, FColor);
END;
end;

procedure THIImg_GetPoint._var_Color;
begin
   dtInteger(_data,FColor);
end;

end.
