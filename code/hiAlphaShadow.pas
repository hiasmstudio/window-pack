unit hiAlphaShadow;

interface

uses Windows, Kol, Share, Debug, hiPBlur;

type
  THIAlphaShadow = class(TDebug)
   private
    fAlphaBmp: PBitmap;
   public
    _prop_ShiftX: integer;
    _prop_ShiftY: integer;
    _prop_TransparentColor: TColor;
    _prop_DeepBlur: real;
    _prop_AlphaValue: integer;
    _prop_Overlay: boolean;	    

    _data_Bitmap: THI_Event;
    _data_BitmapForOverlay: THI_Event;    
    _data_ShiftX: THI_Event;
    _data_ShiftY: THI_Event;
    _data_TransparentColor: THI_Event;
    _data_DeepBlur: THI_Event;
    _data_AlphaValue: THI_Event;

    _event_onShadow: THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doShadow(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

constructor THIAlphaShadow.Create;
begin
  inherited;
end;   

destructor THIAlphaShadow.Destroy;
begin
  fAlphaBmp.free;
  inherited;
end;

procedure THIAlphaShadow._work_doShadow;
var
  Bmp, BmpOver, fmask, shadow, dest, stretchdest: PBitmap;
  fShiftX, fShiftY: integer;
  fTransparent: TColor;
  fDeep: Real;
  fAlphaShadow, fAlpha: byte;
  x, y: integer;
  MS, S: PColor;
  ffrom, ffrommask: TRGB;
  
  procedure FinalAlphaBmp(dst: PBitmap);
  var
    x, y: integer;
  begin
    for y := 0 to fAlphaBmp.Height - 1 do
    begin
      MS := dst.Scanline[y];
      S := fAlphaBmp.Scanline[y];
      for x := 0 to fAlphaBmp.Width - 1 do
      begin
        PColor(@ffrom)^ := S^;
        PColor(@ffrommask)^ := MS^;
        S^ := RGB(ffrom.r*ffrommask.r div 255, ffrom.g*ffrommask.g div 255, ffrom.b*ffrommask.b div 255) + ffrommask.r shl 24;
        inc(S);
        inc(MS);      
      end;  
    end;  
  end;
  
begin
  Bmp := ReadBitmap(_Data, _data_Bitmap);
  fShiftX := ReadInteger(_Data, _data_ShiftX, _prop_ShiftX);
  fShiftY := ReadInteger(_Data, _data_ShiftY, _prop_ShiftY);
  fTransparent := Color2RGB(ReadInteger(_Data, _data_TransparentColor, _prop_TransparentColor));
  fDeep := ReadReal(_Data, _data_DeepBlur, _prop_DeepBlur);
  fAlphaShadow := Byte(ReadInteger(_Data, _data_AlphaValue, _prop_AlphaValue));     
  BmpOver := ReadBitmap(_Data, _data_BitmapForOverlay); 

  if (Bmp = nil) or bmp.Empty then exit;

  fmask := NewBitmap(0, 0);
  fmask.Assign(Bmp);
  if fmask.PixelFormat <> pf24bit then fmask.PixelFormat := pf24bit;  
  fmask.Convert2Mask(fTransparent);
  fmask.PixelFormat  := pf24bit;    

  if Assigned(fAlphaBmp) then fAlphaBmp.free;
  fAlphaBmp := NewBitmap(Bmp.Width, Bmp.Height);

  shadow := NewBitmap(0, 0);
  shadow.Assign(Bmp);
  shadow.DrawMasked(fAlphaBmp.Canvas.Handle, 0, 0, fmask.Handle);
  if shadow.PixelFormat <> pf24bit then shadow.PixelFormat := pf24bit;

  dest := NewBitmap(Bmp.Width, Bmp.Height);  
TRY
  if fDeep <> 0 then
  begin
    if not _prop_Overlay then 
      BitBlt(shadow.Canvas.Handle, fShiftX, fShiftY, shadow.width, shadow.height, fmask.Canvas.Handle, 0, 0, NOTSRCCOPY)
	else
      BitBlt(shadow.Canvas.Handle, 0, 0, shadow.width, shadow.height, fmask.Canvas.Handle, 0, 0, NOTSRCCOPY);
    Gaus_Method(shadow, dest, fDeep);
    dest.PixelFormat  := pf32bit;
 
    for y := 0 to dest.Height - 1 do
    begin
      S := dest.Scanline[y];
      for x := 0 to dest.Width - 1 do
      begin
        PColor(@ffrom)^ := S^;
        if S^ and $00FFFFFF <> 0 then
        begin
          fAlpha := ffrom.r * fAlphaShadow div 255;        
          S^ := RGB(fAlpha, fAlpha, fAlpha);
        end;
        inc(S);
      end;  
    end;
    
    if not _prop_Overlay then 
    begin
      BitBlt(dest.Canvas.Handle, 0, 0, dest.width, dest.height, fmask.Canvas.Handle, 0, 0, SRCERASE);
      BitBlt(dest.Canvas.Handle, 0, 0, dest.width, dest.height, 0, 0, 0, DSTINVERT);
    end;  
  end  
  else
  begin
    dest.Assign(fmask);
    dest.PixelFormat := pf32bit;    
    BitBlt(dest.Canvas.Handle, 0, 0, dest.width, dest.height, 0, 0, 0, DSTINVERT);
  end;  

  fmask.free;
  shadow.free; 
  
  if not _prop_Overlay then 
  begin
    if fAlphaBmp.PixelFormat <> pf32bit then fAlphaBmp.PixelFormat := pf32bit;
    FinalAlphaBmp(dest);
  end
  else
  begin
    if (BmpOver = nil) or bmpOver.Empty then exit;
    fAlphaBmp.Assign(BmpOver);	  
    if fAlphaBmp.PixelFormat <> pf32bit then fAlphaBmp.PixelFormat := pf32bit;

    stretchdest := NewBitmap(BmpOver.Width, BmpOver.Height); 
    stretchdest.PixelFormat := pf32bit;
    
    SetStretchBltMode(stretchdest.Canvas.Handle, HALFTONE);
    StretchBlt(stretchdest.Canvas.Handle, 0, 0, stretchdest.width, stretchdest.height, 
	           dest.Canvas.Handle, 0, 0, dest.width, dest.height, SRCCOPY);

    FinalAlphaBmp(stretchdest);
    stretchdest.free;
  end;  

  _hi_OnEvent(_event_onShadow, fAlphaBmp);

FINALLY  
  dest.free;
END;
end;

procedure THIAlphaShadow._var_Result;
begin
   if (fAlphaBmp = nil) or fAlphaBmp.Empty then exit;
   dtBitmap(_Data, fAlphaBmp);
end;

end.