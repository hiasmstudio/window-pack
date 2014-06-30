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
    _prop_Antialias: boolean;

    constructor Create;
    destructor Destroy; override;
       
    procedure _work_doDraw(var _Data:TData; Index:word);
    procedure _work_doAlphaBlendValue(var _Data:TData; Index:word);
    procedure _work_doAlphaMode(var _Data:TData; Index:word);
    procedure _work_doAntialias(var _Data:TData; Index:word);     
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

procedure _AntiAlias(var Clip: PBitmap);
const
  Pix = 4;
var X,Y: integer;
    P0,P1,P2: PByteArray;
begin
  for Y := 1 to Clip.Height-2 do
  begin
    P0 := Clip.ScanLine[Y-1];
    P1 := Clip.ScanLine[Y];
    P2 := Clip.ScanLine[Y+1];
    for X := 1 to Clip.Width-2 do
    begin
      P1[X*4]   := (P0[X*4]   + P2[X*4]   + P1[(X-1)*4]   + P1[(x+1)*4])   div Pix;
      P1[X*4+1] := (P0[X*4+1] + P2[X*4+1] + P1[(X-1)*4+1] + P1[(X+1)*4+1]) div Pix;
      P1[X*4+2] := (P0[X*4+2] + P2[X*4+2] + P1[(X-1)*4+2] + P1[(X+1)*4+2]) div Pix;
      P1[X*4+3] := (P0[X*4+3] + P2[X*4+3] + P1[(X-1)*4+3] + P1[(X+1)*4+3]) div Pix;
    end;
  end;
end;

procedure THIImg_AlphaBmp._work_doDraw;
var   dt: TData;
      src: PBitmap;
      blend: TBlendFunction;
      mTransform: PTransform;
begin
   dt := _Data;
   if not ImgGetDC(_Data) then exit;
TRY
   src := ReadBitmap(_Data,_data_AlphaBitmap);
   if (src = nil) or (src.Empty) then exit;

   Bitmap.Assign(Src);
   if (Bitmap.PixelFormat <> pf32bit) then Bitmap.PixelFormat := pf32bit;

   if _prop_Antialias then _AntiAlias(Bitmap);

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

   mTransform := ReadObject(_Data, _data_Transform, TRANSFORM_GUID);
   case fDrawSource of
      dcHandle, 
      dcBitmap:  begin
                  if mTransform <> nil then
                   if mTransform._Set(pDC,oldx1,oldy1,oldx2,oldy2) then  //если необходимо изменить координаты (rotate, flip)
                     begin
                      PRect(@oldx1)^ := mTransform._GetRect(MakeRect(oldx1, oldy1, oldx2, oldy2));
                      oldwh := x2-x1;
                      oldhh := y2-y1;
                     end;
                  AlphaBlend(pDC, oldx1, oldy1, oldwh, oldhh, Bitmap.Canvas.Handle, 0, 0, oldwh, oldhh, blend);
                 end;
      dcContext: begin
                  if mTransform <> nil then
                   if mTransform._Set(pDC,x1,y1,x2,y2) then  //если необходимо изменить координаты (rotate, flip)
                    begin
                     PRect(@x1)^ := mTransform._GetRect(MakeRect(x1,y1,x2,y2));
                     newwh := x2-x1;
                     newhh := y2-y1;
                    end; 
                  AlphaBlend(pDC, x1, y1, newwh, newhh, Bitmap.Canvas.Handle, 0, 0, oldwh, oldhh, blend);
                 end;
   end;
   if mTransform <> nil then mTransform._Reset(pDC); // сброс трансформации
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

procedure THIImg_AlphaBmp._work_doAntialias;
begin
  _prop_Antialias := ReadBool(_Data);
end;

end.