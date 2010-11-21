unit hiAlphaResize;

interface

uses Windows,Kol,Share,Debug;

type
  THIAlphaResize = class(TDebug)
   private
    bmp, src:PBitmap;
   public
    _prop_Width:integer;
    _prop_Height:integer;

    _data_Height:THI_Event;
    _data_Width:THI_Event;
    _data_Bitmap:THI_Event;
    _event_onResize:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doResize(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

function AlphaBlend(hdcDest: HDC; nXOriginDest, nYOriginDest, nWidthDest, nHeightDest: Integer;
                    hdcSrc: HDC; nXOriginSrc, nYOriginSrc, nWidthSrc, nHeightSrc: Integer;
                    blendFunction: TBlendFunction): BOOL; stdcall;
                    external 'msimg32.dll' name 'AlphaBlend';

constructor THIAlphaResize.Create;
begin
  inherited;
  Bmp := NewBitmap(0, 0);
end;   

destructor THIAlphaResize.Destroy;
begin
   src.free;
   Bmp.free;
   inherited;
end;

procedure THIAlphaResize._work_doResize;
var
  bitmap : PBitmap;
  blend: TBlendFunction;
begin
  bitmap := ReadBitmap(_Data,_data_Bitmap);
  if (Bitmap = nil) or Bitmap.Empty then exit;
  bmp.Assign(Bitmap);

  if Assigned(src) then src.free;
  if bmp.PixelFormat <> pf32bit then bmp.PixelFormat := pf32bit;

  src := NewDIBBitmap(ReadInteger(_Data,_data_Width,_prop_Width),
                      ReadInteger(_Data,_data_Height,_prop_Height), pf32bit);
  blend.BlendOp := AC_SRC_OVER;
  blend.BlendFlags := 0;
  blend.SourceConstantAlpha := 255;
  blend.AlphaFormat := AC_SRC_NO_PREMULT_ALPHA;

  AlphaBlend(src.Canvas.Handle, 0, 0, src.width, src.height,
             bmp.Canvas.Handle, 0, 0, bmp.width, bmp.height, blend);

  _hi_OnEvent(_event_onResize, src);
end;

procedure THIAlphaResize._var_Result;
begin
   if (src = nil) or src.Empty then exit;
   dtBitmap(_Data, src);
end;

end.