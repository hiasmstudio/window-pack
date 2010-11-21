unit hiAlphaCopy;

interface

uses Windows,Kol,Share,Debug;

type
  THIAlphaCopy = class(TDebug)
   private
    bmp, dest:PBitmap;
   public
    _prop_X:integer;
    _prop_Y:integer;
    _prop_Width:integer;
    _prop_Height:integer;

    _data_Height:THI_Event;
    _data_Width:THI_Event;
    _data_Y:THI_Event;
    _data_X:THI_Event;
    _data_Bitmap:THI_Event;
    _event_onCopy:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doCopy(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

function AlphaBlend(hdcDest: HDC; nXOriginDest, nYOriginDest, nWidthDest, nHeightDest: Integer;
                    hdcSrc: HDC; nXOriginSrc, nYOriginSrc, nWidthSrc, nHeightSrc: Integer;
                    blendFunction: TBlendFunction): BOOL; stdcall;
                    external 'msimg32.dll' name 'AlphaBlend';

constructor THIAlphaCopy.Create;
begin
  inherited;
  Bmp := NewBitmap(0, 0);
end; 

destructor THIAlphaCopy.Destroy;
begin
   bmp.free;
   dest.free;
   inherited;
end;

procedure THIAlphaCopy._work_doCopy; //Bitmap
var
  bitmap:PBitmap;
  x,y,w,h,nw,nh:integer;
  blend: TBlendFunction;      
begin
  bitmap := ReadBitmap(_Data, _data_Bitmap);
  if (Bitmap = nil) or Bitmap.Empty then exit;
  bmp.Assign(Bitmap);

  x := ReadInteger(_Data,_data_X,_prop_X);
  y := ReadInteger(_Data,_data_Y,_prop_Y);
  w := ReadInteger(_Data,_data_Width,_prop_Width);
  h := ReadInteger(_Data,_data_Height,_prop_Height);

  if Assigned(dest) then dest.free;
  if bmp.PixelFormat <> pf32bit then bmp.PixelFormat := pf32bit;

  dest := NewDIBBitmap(w, h, pf32bit);

  blend.BlendOp := AC_SRC_OVER;
  blend.BlendFlags := 0;
  blend.SourceConstantAlpha := 255;
  blend.AlphaFormat := AC_SRC_NO_PREMULT_ALPHA;

  if w > bmp.Width - X then
    nw := bmp.Width - X
  else   
    nw := w;
  if h > bmp.Height - Y then
    nh := bmp.Height - Y
  else   
    nh := h;
    
  AlphaBlend(dest.Canvas.Handle, 0, 0, nw, nh, bmp.Canvas.Handle, X, Y, nw, nh, blend);

  _hi_onEvent(_event_onCopy, dest);
end;

procedure THIAlphaCopy._var_Result;
begin
   if (dest = nil) or dest.Empty then exit;
   dtBitmap(_Data, dest);
end;

end.