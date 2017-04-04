unit HiAlphaTween;

interface

uses Windows,Messages,Kol,Share,Debug;

type
 THiAlphaTween = class(TDebug)
   private
     BitmapA, BitmapB, BitmapC: PBitmap;
     blend: TBlendFunction;
   public
     _prop_Mode: byte;
     
     _data_BitmapA:THI_Event;
     _data_BitmapB:THI_Event;
     _data_DiffB2A:THI_Event;

     _event_onTween:THI_Event;

     constructor Create; 
     destructor Destroy; override;

     procedure _work_doLoad(var _Data:TData; Index:word);
     procedure _work_doTween(var _Data:TData; Index:word);
     procedure _work_doMode(var _Data:TData; Index:word);
     procedure _var_Result(var _Data:TData; Index:word);
 end;

implementation

function AlphaBlend(hdcDest: HDC; nXOriginDest, nYOriginDest, nWidthDest, nHeightDest: Integer;
                    hdcSrc: HDC; nXOriginSrc, nYOriginSrc, nWidthSrc, nHeightSrc: Integer;
                    blendFunction: TBlendFunction): BOOL; stdcall;
                    external 'msimg32.dll' name 'AlphaBlend';

constructor THiAlphaTween.Create;
begin
   inherited;
   BitmapA := NewBitmap(0,0);   
   BitmapB := NewBitmap(0,0);
   BitmapC  := NewBitmap(0,0);

   blend.BlendOp := AC_SRC_OVER;
   blend.BlendFlags := 0;
   blend.AlphaFormat := AC_SRC_NO_PREMULT_ALPHA
end;

destructor THiAlphaTween.Destroy;
begin
   BitmapA.free;
   BitmapB.free;  
   BitmapC.free;
   inherited;
end;

procedure THiAlphaTween._work_doLoad;
var
  bmp_inA, bmp_inB: PBitmap;
begin
  bmp_inA := ReadBitmap(_Data, _data_BitmapA);
  bmp_inB := ReadBitmap(_Data, _data_BitmapB);
  if (bmp_inA = nil) or bmp_inA.Empty or
     (bmp_inB = nil) or bmp_inB.Empty then exit;
  BitmapA.Assign(bmp_inA);
  BitmapB.Assign(bmp_inB);
end;

procedure THiAlphaTween._work_doTween;
var
  Diff: integer;
  Left, Top, Right, Bottom: integer;
  k: real;  
begin
  if (BitmapA = nil) or BitmapA.Empty or
     (BitmapB = nil) or BitmapB.Empty then exit;

  BitmapC.Clear;
  BitmapC.Width := BitmapA.Width;
  BitmapC.Height := BitmapA.Height;    

  if BitmapA.PixelFormat <> pf32bit then BitmapA.PixelFormat := pf32bit;
  if BitmapB.PixelFormat <> pf32bit then BitmapB.PixelFormat := pf32bit;
  if BitmapC.PixelFormat <> pf32bit then BitmapC.PixelFormat := pf32bit;  

  Diff := max(0, min(255, ReadInteger(_Data, _data_DiffB2A)));

  k := BitmapB.Height/BitmapB.Width;
   
  Left := 0;
  Top := 0;
  Right := BitmapC.Width;
  Bottom := BitmapC.Height; 

  if (BitmapC.Height >= BitmapC.Width * k) then 
  begin
    Top := Round((BitmapC.Height - BitmapC.Width * k) / 2);
    Bottom := BitmapC.Height - Top;
  end 
  else 
  begin
    Left := Round((BitmapC.Width - BitmapC.Height / k) / 2);
    Right := BitmapC.Width - Left;
  end;

  case _prop_Mode of
    0: blend.SourceConstantAlpha := 255;
    1: blend.SourceConstantAlpha := 255 - Diff;    
  end;
  AlphaBlend(BitmapC.Canvas.Handle, 0, 0, BitmapC.Width, BitmapC.Height,
             BitmapA.Canvas.Handle, 0, 0, BitmapA.Width, BitmapA.Height, blend);   

  blend.SourceConstantAlpha := Diff;
  AlphaBlend(BitmapC.Canvas.Handle, left, Top, Right - left, Bottom - Top,
             BitmapB.Canvas.Handle, 0, 0, BitmapB.Width, BitmapB.Height, blend);   

  _hi_onEvent(_event_onTween, BitmapC);
end;

procedure THiAlphaTween._var_Result;
begin
  if (BitmapC = nil) or BitmapC.Empty then exit;
  dtBitmap(_Data, BitmapC);
end;

procedure THiAlphaTween._work_doMode;
begin
  _prop_Mode := max(0, min(1, ToInteger(_Data)));
end;

end.