unit hiImg_Rotate; { компонент поворота изображени€ на любой угол } 

interface

uses Windows, Kol, Share, Debug;
         
type
  THIImg_Rotate = class(TDebug)
  private
    Bitmap: PBitmap;
    RotateBmp: PBitmap;
  public
    _prop_angle: real;
    _prop_BackgroundColor: integer;
    _data_Bitmap: THI_Event;
    _data_angle: THI_Event;
    _data_BackgroundColor: THI_Event;
    _event_onResult: THI_Event;
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

constructor THIImg_Rotate.Create;
begin
  inherited;
  RotateBmp := NewDIBBitmap(1, 1, pf24bit);
end;

destructor THIImg_Rotate.Destroy;
begin
  RotateBmp.Free;
  inherited;
end;

procedure THIImg_Rotate._work_doRotate;
var
  color: integer;
  degree: real;
  cosA, sinA: real;
  topoverh, leftoverh: integer; 
  x, y, H, W: integer;

  {$ifdef F_P} 
  XF: TXForm;
  {$else}
  newx, newy, SizeDstLine: integer;  
  Sor, Des, Des1: PDword;
  {$endif}

begin
  Bitmap := ReadBitmap(_Data, _data_Bitmap, nil);
  if (Bitmap = nil) or Bitmap.Empty then exit;   
  Bitmap.PixelFormat := pf24bit;
//  if Bitmap.HandleType = bmDDB then Bitmap.HandleType := bmDIB;

  degree := ReadReal(_Data, _data_angle, _prop_angle);
  color := ReadInteger(_Data, _data_BackgroundColor, _prop_BackgroundColor);

  while degree >= 360 do degree := degree - 360;
  while degree < 0 do degree := degree + 360;

  case Round(degree) of
      0: RotateBmp.Assign(Bitmap);
     90: begin
           RotateBmp.Assign(Bitmap);
           RotateBmp.RotateRightTrueColor;
         end;
    180: begin
           RotateBmp.Assign(Bitmap);
           RotateBmp.RotateRightTrueColor;
           RotateBmp.RotateRightTrueColor;
         end;
    270: begin
           RotateBmp.Assign(Bitmap);
           RotateBmp.RotateLeftTrueColor;
         end
    else
    begin
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

      if Assigned(RotateBmp) then RotateBmp.free; 
      RotateBmp := NewDIBBitmap(x, y{$ifndef F_P} + 2{$endif}, pf24bit);
      RotateBmp.Canvas.Brush.Color := Color;
      FillRect(RotateBmp.Canvas.handle, RotateBmp.BoundsRect, RotateBmp.Canvas.Brush.Handle);

      {$ifdef F_P}
      SetGraphicsMode(RotateBmp.Canvas.handle,GM_ADVANCED);
      XF.eM11:= CosA;
      XF.eM12:= SinA;
      XF.eM21:= -SinA;
      XF.eM22:= CosA;
      XF.eDx:= -leftoverh;
      XF.eDy:= -topoverh;
      SetWorldTransform(RotateBmp.Canvas.handle, XF);
      Bitmap.Draw(RotateBmp.Canvas.handle, 0, 0);
      {$else}
      Des  := RotateBmp.ScanLine[0];
      Des1 := RotateBmp.ScanLine[1];
      SizeDstLine := Integer(Des) - Integer(Des1);

      for y := 0 to H - 1 do
      begin
        Sor := Bitmap.ScanLine[y];
        for x := 0 to W - 1 do
        begin
          newX := Round(x * cosA - y * sinA - leftoverh) * 3; 
          newY := Round(x * sinA + y * cosA - topoverh);
          Des := RotateBmp.ScanLine[newY];
          inc(PByte(Des), newx);
          Des^ := (Des^ and $FF000000) or (Sor^ and $00FFFFFF);
          Dec(PByte(Des), SizeDstLine);
          Des^ := (Des^ and $FF000000) or (Sor^ and $00FFFFFF);
          Inc(PByte(Sor), 3);
        end;
      end;
      {$endif}  
    end;
  end;
  _hi_OnEvent(_event_onResult, RotateBmp);
end;

procedure THIImg_Rotate._work_doFlipVertical;
begin
  Bitmap := ReadBitmap(_Data, _data_Bitmap, nil);
  if (Bitmap = nil) or Bitmap.Empty then exit;   
  Bitmap.PixelFormat := pf24bit;
  if Bitmap.HandleType = bmDDB then Bitmap.HandleType := bmDIB;
  RotateBmp.Assign(Bitmap);
  RotateBmp.FlipVertical;
  _hi_onEvent(_event_onResult, RotateBmp);
end;

procedure THIImg_Rotate._work_doFlipHorizontal;
begin
  Bitmap := ReadBitmap(_Data, _data_Bitmap, nil);
  if (Bitmap = nil) or Bitmap.Empty then exit;   
  Bitmap.PixelFormat := pf24bit;
  if Bitmap.HandleType = bmDDB then Bitmap.HandleType := bmDIB;
  RotateBmp.Assign(Bitmap);
  RotateBmp.FlipHorizontal;
  _hi_onEvent(_event_onResult, RotateBmp);
end;

procedure THIImg_Rotate._var_Width;
begin
  dtInteger(_Data, RotateBmp.Width);
end;

procedure THIImg_Rotate._var_Height;
begin
  dtInteger(_Data, RotateBmp.Height);
end;

procedure THIImg_Rotate._var_Result;
begin
  dtBitmap(_Data, RotateBmp);
end;

end.