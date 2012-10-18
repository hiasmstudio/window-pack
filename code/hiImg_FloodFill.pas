unit hiImg_FloodFill;

interface

uses windows,Kol,Share,Debug,Img_Draw;

type
  THIImg_FloodFill = class(THIDraw2P)
   private
   public
    _prop_FillType:integer;
    _prop_ColorBorder:integer;

    _data_ColorBorder:THI_Event;
    _data_FillType:THI_Event;

//    _prop_Color:TColor;

//    _data_Color:THI_Event;

    procedure _work_doDraw(var _Data:TData; Index:word);
    procedure _work_doFillType(var _Data:TData; Index:word);    
  end;

implementation

procedure THIImg_FloodFill._work_doDraw;
var   dt: TData;
      sColor, sColorborder: TColor;
      br:HBRUSH;
      Pattern: PBitmap;
begin
   dt := _Data;
TRY
   if not ImgGetDC(_Data) then exit;
   sColor := Color2RGB(ReadInteger(_Data,_data_Color,_prop_Color));
   sColorBorder := Color2RGB(ReadInteger(_Data,_data_ColorBorder,_prop_ColorBorder));  
    
   ReadXY(_Data);
   ImgNewSizeDC;

   if _prop_PatternStyle then
   begin
     Pattern := ReadBitmap(_Data,_data_Pattern);
     if not Assigned(Pattern) or Pattern.Empty then
       br := GetStockObject(NULL_BRUSH)
     else
       br := CreatePatternBrush(Pattern.Handle);
   end
   else
   begin
     if _prop_Style = bsSolid then
        br := CreateSolidBrush(sColor)
     else if _prop_Style = bsClear then
        br := GetStockObject(NULL_BRUSH)
     else
        br := CreateHatchBrush(ord(_prop_Style) - 2, sColor);
   end; 

   SelectObject(pDC, br);
   
   case _prop_FillType of
    0: ExtFloodFill(pDC, x1, y1, GetPixel(pDC, x1, y1), FLOODFILLSURFACE);
    1: ExtFloodFill(pDC, x1, y1, sColorBorder, FLOODFILLBORDER);
   end; 

FINALLY
   DeleteObject(br);
   ImgReleaseDC;
   _hi_CreateEvent(_Data,@_event_onDraw,dt);
END;
end;

procedure THIImg_FloodFill._work_doFillType;
begin
  _prop_FillType := ToInteger(_Data);
end;

end.
