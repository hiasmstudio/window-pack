unit hiAlphaImage;

interface

{$I share.inc}

uses Windows,Share,Win,Kol;

type
  THIAlphaImage = class(THIWin)
   private
    Bmp: PBitmap;
    blend: TBlendFunction;     
    procedure _OnClick( Sender: PObj );
    procedure _OnPaint( Sender: PControl; DC: HDC );
    procedure SetPicture(Value:HBITMAP);
    procedure Preparation;
    procedure Clear;
    procedure AfterLoad;
   public
    _prop_ViewStyle:procedure(DC:HDC) of object;
    _prop_AutoSize:boolean;
    _prop_Transparent:boolean;    
    
    _prop_AlphaBlendValue: Byte;
    _prop_AlphaMode: boolean;

    _data_AlphaBitmap:THI_Event;
    _event_onClick:THI_Event;

    constructor Create(Parent:PControl);
    destructor Destroy; override;
    procedure Init; override;
    procedure Center(DC:HDC);
    procedure Stretch(DC:HDC);
    procedure Scale(DC:HDC;x:boolean);
    procedure ScaleMax(DC:HDC);
    procedure ScaleMin(DC:HDC);
    procedure Mosaic(DC:HDC);
    procedure None(DC:HDC);
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doRefresh(var _Data:TData; Index:word);
    procedure _work_doViewStyle(var _Data:TData; Index:word);
    procedure _work_doColor(var _Data:TData; Index:word);
    procedure _var_ImageBitmap(var _Data:TData; Index:word);
    procedure _var_ImageWidth(var _Data:TData; Index:word);
    procedure _var_ImageHeight(var _Data:TData; Index:word);
    property _prop_Picture:HBITMAP write SetPicture;
    procedure _work_doAlphaBlendValue(var _Data:TData; Index:word);
    procedure _work_doAlphaMode(var _Data:TData; Index:word);

  end;

implementation

function AlphaBlend(hdcDest: HDC; nXOriginDest, nYOriginDest, nWidthDest, nHeightDest: Integer;
                    hdcSrc: HDC; nXOriginSrc, nYOriginSrc, nWidthSrc, nHeightSrc: Integer;
                    blendFunction: TBlendFunction): BOOL; stdcall;
                    external 'msimg32.dll' name 'AlphaBlend';

constructor THIAlphaImage.Create;
begin
  inherited Create(Parent);
  Bmp := NewBitmap(0,0);
end;

destructor THIAlphaImage.Destroy;
begin
  Bmp.Free;
  inherited;
end;

procedure THIAlphaImage.Init;
begin
  Control := NewPaintbox(FParent);
  inherited;
  Control.OnClick := _OnClick;
  Control.OnPaint := _OnPaint;
  Control.Canvas.Brush.Color := _prop_Color;
  
  if _prop_Transparent then
  begin
    Control.Canvas.Brush.BrushStyle := bsClear;
    Control.ExStyle := Control.ExStyle or WS_EX_TRANSPARENT;
  end;  
  AfterLoad;
end;

procedure THIAlphaImage.Preparation;
begin
  Control.Canvas.FillRect(Control.ClientRect);
  
  blend.BlendOp := AC_SRC_OVER;
  blend.BlendFlags := 0;
  blend.SourceConstantAlpha := _prop_AlphaBlendValue;

  if _prop_AlphaMode then
    blend.AlphaFormat := AC_SRC_NO_PREMULT_ALPHA
  else  
    blend.AlphaFormat := 0;
end;

procedure THIAlphaImage.AfterLoad;
begin
  if Bmp.Empty then exit;
  if _prop_AutoSize then
    Control.SetSize(Bmp.Width, Bmp.Height);  
end;

procedure THIAlphaImage._work_doColor;
begin
  Control.Color := ToInteger(_Data);
  Control.Canvas.Brush.Color := Control.Color;  
end;

procedure THIAlphaImage._work_doLoad;
var t:PBitmap;
begin
  t := ReadBitmap(_Data,_data_AlphaBitmap,nil);
  if t = nil then exit;
  Bmp.Assign(t);
  if Bmp.PixelFormat <> pf32bit then Bmp.PixelFormat := pf32bit;  
  AfterLoad;
  if _prop_Transparent then
  begin
    Control.Visible := false;
    Control.Visible := true;
  end
  else    
    Control.Invalidate;
end;

procedure THIAlphaImage._work_doClear;
begin
  Clear;
end;

procedure THIAlphaImage._work_doRefresh;
begin
  Control.Invalidate;
end;

procedure THIAlphaImage._work_doViewStyle;
begin
  case ToInteger(_Data) of
    0: _prop_ViewStyle := Center;
    1: _prop_ViewStyle := Stretch;
    2: _prop_ViewStyle := ScaleMin;
    3: _prop_ViewStyle := Mosaic;
    4: _prop_ViewStyle := None;
    5: _prop_ViewStyle := ScaleMax;
  end;
  Control.Invalidate;
end;

procedure THIAlphaImage._var_ImageBitmap;
begin
   dtBitmap(_data, Bmp);
end;

procedure THIAlphaImage._var_ImageWidth;
begin
   dtInteger(_Data, Bmp.Width)
end;

procedure THIAlphaImage._var_ImageHeight;
begin
   dtInteger(_Data, Bmp.Height)
end;

procedure THIAlphaImage._OnClick;
begin
  _hi_OnEvent(_event_onClick);
end;

procedure THIAlphaImage.Center;
var
  x, y: integer;
begin
  x := (Control.Width - Bmp.Width) div 2;
  y := (Control.Height - Bmp.Height) div 2;  
  Preparation;
  AlphaBlend(DC, x, y, bmp.width, bmp.height,
             bmp.Canvas.Handle, 0, 0, bmp.width, bmp.height, blend);
end;

procedure THIAlphaImage.Stretch;
begin
  Preparation;
  AlphaBlend(DC, 0, 0, Control.Width, Control.Height,
             bmp.Canvas.Handle, 0, 0, bmp.width, bmp.height, blend);
end;

procedure  THIAlphaImage.Mosaic;
var
  i, j: integer;
begin
  Preparation;
  for i := 0 to Control.Width div bmp.Width do
    for j := 0 to Control.Height div Bmp.Height do
      AlphaBlend(DC, i * Bmp.Width, j * Bmp.Height, Bmp.Width, Bmp.Height,
                 bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, blend);
end;

procedure THIAlphaImage.ScaleMax;
begin
  Scale(DC,true);
end;

procedure THIAlphaImage.ScaleMin;
begin
  Scale(DC,false);
end;

procedure THIAlphaImage.Scale;
var
  r: TRect;
  k: real;
begin
  r := Control.ClientRect;
  k := Bmp.Height/Bmp.Width;

  Preparation;

  if (Control.Height < Control.Width*k) = x then 
  begin
    r.Top := Round((Control.Height - Control.Width * k) / 2);
    r.Bottom := Control.Height - r.Top;
  end 
  else 
  begin
    r.Left := Round((Control.Width - Control.Height / k) / 2);
    r.Right := Control.Width - r.Left;
  end;
  AlphaBlend(DC, r.left, r.top, r.right - r.left, r.bottom - r.top,
             bmp.Canvas.Handle, 0, 0, bmp.width, bmp.height, blend);
end;

procedure THIAlphaImage.None;
begin
  Preparation;
  AlphaBlend(DC, 0, 0, bmp.width, bmp.height,
             bmp.Canvas.Handle, 0, 0, bmp.width, bmp.height, blend);
end;

procedure THIAlphaImage._OnPaint;
begin
  if Bmp.Empty then 
    Control.Canvas.FillRect(Control.ClientRect)
  else
    _prop_ViewStyle(DC);
end;

procedure THIAlphaImage.SetPicture;
begin
  if Value = 0 then exit;
  Bmp.Handle := Value;
end;

procedure THIAlphaImage.Clear;
begin
  if Bmp.Empty then exit;
  Bmp.Clear;
  Control.Invalidate;
end;

procedure THIAlphaImage._work_doAlphaBlendValue;
begin
  _prop_AlphaBlendValue := ToInteger(_Data);
end;

procedure THIAlphaImage._work_doAlphaMode;
begin
  _prop_AlphaMode := ReadBool(_Data);
end;

end.