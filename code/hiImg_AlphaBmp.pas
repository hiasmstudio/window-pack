unit hiImg_AlphaBmp;

interface

uses Windows,Kol,Share,Img_Draw;

type
  THIImg_AlphaBmp = class(THIDraw2P)
   private
     bitmap: PBitmap;
   public
    _prop_AlphaBlendValue: Byte;
    _prop_AlphaMode: boolean;    
    _data_AlphaBitmap: THI_Event;
    constructor Create;
    destructor Destroy; override;
       
    procedure _work_doDraw(var _Data:TData; Index:word);
    procedure _work_doAlphaBlendValue(var _Data:TData; Index:word);
    procedure _work_doAlphaMode(var _Data:TData; Index:word);    
  end;

implementation

function AlphaBlend(hdcDest: HDC; nXOriginDest, nYOriginDest, nWidthDest, nHeightDest: Integer;
                    hdcSrc: HDC; nXOriginSrc, nYOriginSrc, nWidthSrc, nHeightSrc: Integer;
                    blendFunction: TBlendFunction): BOOL; stdcall;
                    external 'msimg32.dll' name 'AlphaBlend';

constructor THIImg_AlphaBmp.Create;
begin
  inherited;
  Bitmap := NewBitmap(0, 0);
end;   

destructor THIImg_AlphaBmp.Destroy;
begin
  Bitmap.free;
  inherited;
end;

procedure THIImg_AlphaBmp._work_doDraw;
var   dt: TData;
      src: PBitmap;
      blend: TBlendFunction;
begin
   dt := _Data;
   if not ImgGetDC(_Data) then exit;
TRY
   src := ReadBitmap(_Data,_data_AlphaBitmap);
   if (src = nil) or (src.Empty) then exit;

   Bitmap.Assign(Src);
   if (Bitmap.PixelFormat <> pf32bit) then Bitmap.PixelFormat := pf32bit;

   blend.BlendOp := AC_SRC_OVER;
   blend.BlendFlags := 0;
   blend.SourceConstantAlpha := _prop_AlphaBlendValue;

   if _prop_AlphaMode then
     blend.AlphaFormat := AC_SRC_NO_PREMULT_ALPHA
   else  
     blend.AlphaFormat := 0;

   ReadXY(_Data);
   x2 := x1 + src.width; 
   y2 := y1 + src.height;
   ImgNewSizeDC;

   case fDrawSource of
      dcHandle, 
      dcBitmap:  AlphaBlend(pDC, oldx1, oldy1, oldwh, oldhh, Bitmap.Canvas.Handle, 0, 0, oldwh, oldhh, blend);
      dcContext: AlphaBlend(pDC, x1, y1, newwh, newhh, Bitmap.Canvas.Handle, 0, 0, oldwh, oldhh, blend);
   end;
FINALLY
   ImgReleaseDC;
   _hi_CreateEvent(_Data, @_event_onDraw, dt);
END;
end;

procedure THIImg_AlphaBmp._work_doAlphaBlendValue;
begin
  _prop_AlphaBlendValue := ToInteger(_Data);
end;

procedure THIImg_AlphaBmp._work_doAlphaMode;
begin
  _prop_AlphaMode := ReadBool(_Data);
end;

end.