unit hiAlphaRotate; { компонент поворота изображени€ на любой угол } 

interface

uses Windows, Kol, Share, Debug;
         
type
  THIAlphaRotate = class(TDebug)
  private
    Bitmap: PBitmap;
    RotateBmp: PBitmap;
  public
    _prop_angle: real;
    _data_AlphaBitmap: THI_Event;
    _data_angle: THI_Event;
    _event_onRotate: THI_Event;
    constructor Create;
    destructor Destroy; override;
    procedure _work_doRotate(var _Data: TData; Index: Word);
    procedure _work_doFlipVertical(var _Data: TData; Index: Word);
    procedure _work_doFlipHorizontal(var _Data: TData; Index: Word);
    procedure _var_Width(var _Data: TData; Index: Word);
    procedure _var_Height(var _Data: TData; Index: Word);
    procedure _var_Result(var _Data: TData; Index: Word);      
  end;
implementation

function AlphaBlend(hdcDest: HDC; nXOriginDest, nYOriginDest, nWidthDest, nHeightDest: Integer;
                    hdcSrc: HDC; nXOriginSrc, nYOriginSrc, nWidthSrc, nHeightSrc: Integer;
                    blendFunction: TBlendFunction): BOOL; stdcall;
                    external 'msimg32.dll' name 'AlphaBlend';

constructor THIAlphaRotate.Create;
begin
  inherited;
  Bitmap := NewBitmap(0, 0);
  RotateBmp := NewDIBBitmap(0, 0, pf32bit);
end;

destructor THIAlphaRotate.Destroy;
begin
  RotateBmp.Free;
  Bitmap.free;
  inherited;
end;

procedure THIAlphaRotate._work_doRotate;
var
  bmp: PBitmap;
  blend: TBlendFunction;  
  degree: real;
  cosA, sinA: real;
  topoverh, leftoverh: integer; 
  x, y, H, W: integer;
  XF: TXForm;

begin
  bmp := ReadBitmap(_Data, _data_AlphaBitmap, nil);
  degree := ReadReal(_Data, _data_angle, _prop_angle);
  if (Bmp = nil) or Bmp.Empty then exit;   

  Bitmap.Assign(bmp);
  if Bitmap.PixelFormat <> pf32bit then Bitmap.PixelFormat := pf32bit;

  while degree >= 360 do degree := degree - 360;
  while degree < 0 do degree := degree + 360;

  H := Bitmap.Height;
  W := Bitmap.Width;
  cosA := cos(degree*Pi/180);
  sinA := sin(degree*Pi/180);

  if (degree <= 90) then
  begin 
    topoverh  := 0; 
    y := Round(W * sinA + H * cosA); 
    leftoverh := Round(- H * sinA);
    x := Round(W * cosA) + Abs(leftoverh);
  end
  else if (degree <= 180) then
  begin 
    topoverh  := Round(H * cosA); 
    y := Round(W * sinA) + Abs(topoverh); 
    leftoverh := Round(W * cosA - H * sinA);
    x := Abs(leftoverh);
  end
  else if (degree <= 270) then
  begin 
    topoverh  := Round(W * sinA + H * cosA); 
    y := Abs(topoverh); 
    leftoverh := Round(W * cosA);
    x := Round(- H * sinA) + Abs(leftoverh);
  end
  else
  begin 
    topoverh  := Round(W * sinA); 
    y := Round(H * cosA) + Abs(topoverh); 
    leftoverh := 0;
    x := Round(W * cosA - H * sinA) + Abs(leftoverh);
  end;

  blend.BlendOp := AC_SRC_OVER;
  blend.BlendFlags := 0;
  blend.SourceConstantAlpha := 255;
  blend.AlphaFormat := AC_SRC_NO_PREMULT_ALPHA;

  if Assigned(RotateBmp) then RotateBmp.free; 
  RotateBmp := NewDIBBitmap(x, y, pf32bit);
  RotateBmp.Canvas.Brush.Color := clBlack;
  FillRect(RotateBmp.Canvas.handle, RotateBmp.BoundsRect, RotateBmp.Canvas.Brush.Handle);

  SetGraphicsMode(RotateBmp.Canvas.handle,GM_ADVANCED);
  XF.eM11:= CosA;
  XF.eM12:= SinA;
  XF.eM21:= -SinA;
  XF.eM22:= CosA;
  XF.eDx:= -leftoverh;
  XF.eDy:= -topoverh;
  SetWorldTransform(RotateBmp.Canvas.handle, XF);
  AlphaBlend(RotateBmp.Canvas.handle, 0, 0, Bitmap.width, Bitmap.height,
             Bitmap.Canvas.Handle, 0, 0, Bitmap.width, Bitmap.height, blend);

  _hi_OnEvent(_event_onRotate, RotateBmp);
end;

procedure THIAlphaRotate._work_doFlipVertical;
var
  bmp: PBitmap;
begin  
  Bmp := ReadBitmap(_Data, _data_AlphaBitmap, nil);
  if (Bmp = nil) or Bmp.Empty then exit;   
  RotateBmp.Assign(Bmp);
  if RotateBmp.PixelFormat <> pf32bit then RotateBmp.PixelFormat := pf32bit; 
  RotateBmp.FlipVertical;
  _hi_onEvent(_event_onRotate, RotateBmp);
end;

procedure THIAlphaRotate._work_doFlipHorizontal;
var
  bmp: PBitmap;
begin  
  Bmp := ReadBitmap(_Data, _data_AlphaBitmap, nil);
  if (Bmp = nil) or Bmp.Empty then exit;   
  RotateBmp.Assign(Bmp);
  if RotateBmp.PixelFormat <> pf32bit then RotateBmp.PixelFormat := pf32bit;
  RotateBmp.FlipHorizontal;
  _hi_onEvent(_event_onRotate, RotateBmp);
end;

procedure THIAlphaRotate._var_Width;
begin
  dtInteger(_Data, RotateBmp.Width);
end;

procedure THIAlphaRotate._var_Height;
begin
  dtInteger(_Data, RotateBmp.Height);
end;

procedure THIAlphaRotate._var_Result;
begin
  dtBitmap(_Data, RotateBmp);
end;

end.