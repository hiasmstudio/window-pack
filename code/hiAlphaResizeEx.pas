unit hiAlphaResizeEx;

interface

uses Windows,Kol,Share,Debug;
type
  PByteArray = ^TByteArray;
  TByteArray = array[0..32767] of byte;
  
type
  THIAlphaResizeEx = class(TDebug)
   private
    bmp_in: PBitmap;
    bmp_out: PBitmap;
    fNumIter: integer;
    blend: TBlendFunction;  
    procedure Progress;      
   public
    _prop_Width:integer;
    _prop_Height:integer;
    _prop_XBR4x: boolean;
    _prop_Smooth: boolean;
    _prop_sX: byte;
    _prop_sY: byte;     

    _data_Height:THI_Event;
    _data_Width:THI_Event;
    _data_Bitmap:THI_Event;
    _data_sX:THI_Event;
    _data_sY:THI_Event; 
	    
    _event_onStartProgress:THI_Event;
    _event_onProgress:THI_Event; 
    _event_onResize:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doResize(var _Data:TData; Index:word);
    procedure _work_doXBR4x(var _Data:TData; Index:word);
    procedure _work_doSmooth(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

uses hiResizeEx;

function AlphaBlend(hdcDest: HDC; nXOriginDest, nYOriginDest, nWidthDest, nHeightDest: Integer;
                    hdcSrc: HDC; nXOriginSrc, nYOriginSrc, nWidthSrc, nHeightSrc: Integer;
                    blendFunction: TBlendFunction): BOOL; stdcall;
                    external 'msimg32.dll' name 'AlphaBlend';

constructor THIAlphaResizeEx.Create;
begin
  inherited;
  bmp_in := NewBitmap(0, 0);
  bmp_out := NewBitmap(0, 0);
  blend.BlendOp := AC_SRC_OVER;
  blend.BlendFlags := 0;
  blend.SourceConstantAlpha := 255;
  blend.AlphaFormat := AC_SRC_NO_PREMULT_ALPHA;  
end;

destructor THIAlphaResizeEx.Destroy;
begin
  bmp_in.free;
  bmp_out.free;
  inherited;
end;

procedure THIAlphaResizeEx.Progress;
begin
  inc(fNumIter);
  _hi_onEvent(_event_onProgress, fNumIter);
end;  

procedure THIAlphaResizeEx._work_doResize;
var
  Bitmap: PBitmap;
  tbmp: PBitmap;
  sX, sY: integer;
  bw, bh: integer;       
  Count: integer;
begin
  Bitmap := ReadBitmap(_Data, _data_Bitmap, nil);
  if (Bitmap = nil) or Bitmap.Empty then exit;

  bmp_in.Assign(Bitmap);

  bw := ReadInteger(_Data,_data_Width,_prop_Width);
  bh := ReadInteger(_Data,_data_Height,_prop_Height);

  sX := ReadInteger(_Data, _data_sX, _prop_sX);
  sY := ReadInteger(_Data, _data_sY, _prop_sY);

  if _prop_XBR4x then
  begin
    Count := bmp_in.height;
    if _prop_Smooth then
    begin
      if (sX <> 0) then 
        Count := Count + bmp_in.height * 4;
      if (sY <> 0) then
        Count := Count  + bmp_in.height * 4 - sY;       
      fNumIter := 0;
      _hi_onEvent(_event_onStartProgress, Count);

      xbr4x(bmp_in, bmp_out, Progress);
      if (sX <> 0) or (sY <> 0) then Smooth(sX, sY, bmp_out, Progress);
    end   
	else
	begin
      fNumIter := 0;
      _hi_onEvent(_event_onStartProgress, Count);
      xbr4x(bmp_in, bmp_out, Progress);
	end;
  end  
  else
  begin
    if _prop_Smooth then
    begin
	  if (sX <> 0) or (sY <> 0) then
	  begin
		Count := 0;
        if (sX <> 0) then 
          Count := bmp_in.height * 4;
        if (sY <> 0) then
          Count := Count + bmp_in.height * 4 - sY;       
        fNumIter := 0;
        _hi_onEvent(_event_onStartProgress, Count);

        bmp_in.PixelFormat := pf32bit;
        tbmp := NewBitmap(bmp_in.width * 4, bmp_in.height * 4);
        tbmp.pixelFormat := pf32bit;
        SetStretchBltMode(tbmp.Canvas.Handle, COLORONCOLOR);
        StretchBlt(tbmp.Canvas.Handle, 0, 0, tbmp.width, tbmp.height, bmp_in.Canvas.Handle, 0, 0, bmp_in.width, bmp_in.height, SRCCOPY);
        bmp_out.Assign(tbmp);
        tbmp.free;    
	    Smooth(sX, sY, bmp_out, Progress);    
	  end
	  else
	    bmp_out.assign(bmp_in);
	end
	else
      bmp_out.assign(bmp_in);	  
  end;  

  if not ((bw = bmp_out.width) and (bh = bmp_out.height)) then 
  begin
    tbmp := NewBitmap(bw, bh);
    tbmp.pixelFormat := pf32bit;
    AlphaBlend(tbmp.Canvas.Handle, 0, 0, bw, bh, bmp_out.Canvas.Handle, 0, 0, bmp_out.width, bmp_out.height, blend);
    bmp_out.Assign(tbmp);
    tbmp.free;
  end;

  _hi_OnEvent(_event_onResize, bmp_out);
end;

procedure THIAlphaResizeEx._work_doXBR4x;
begin
  _prop_XBR4x := ReadBool(_Data);
end;

procedure THIAlphaResizeEx._work_doSmooth;
begin
  _prop_Smooth := ReadBool(_Data);
end;

procedure THIAlphaResizeEx._var_Result;
begin
   if (bmp_out = nil) or bmp_out.Empty then exit;
   dtBitmap(_Data, bmp_out);
end;

end.