unit hiAlphaBitmap;

interface

uses Windows,Kol,Share,Debug;

type
  THIAlphaBitmap = class(TDebug)
   private
    Bmp:PBitmap;
    procedure SetPicture(Value:HBITMAP);
   public
    _prop_HWidth  : integer;
    _prop_HHeight : integer;
    _prop_FillColor : TColor;    
    _prop_PremultAlpha: boolean;
    _data_HWidth  : THI_Event;
    _data_HHeight : THI_Event;
    _data_FillColor : THI_Event;
    _event_onCreate : THI_Event;
    _event_onLoad : THI_Event;    

    constructor Create;
    destructor Destroy; override;
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doCreate(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);    
    procedure _work_PremultAlpha(var _Data:TData; Index:word);
    procedure _var_Bitmap(var _Data:TData; Index:word);
    procedure _var_Width(var _Data:TData; Index:word);
    procedure _var_Height(var _Data:TData; Index:word);
    property _prop_Picture:HBITMAP write SetPicture;
  end;

implementation

constructor THIAlphaBitmap.Create;
begin
  inherited;
  Bmp := NewBitmap(0, 0);
end;

destructor THIAlphaBitmap.Destroy;
begin
  Bmp.free;
  inherited;
end;

procedure PremultAlphaTransparent(BMP: PBitmap; TransparentColor: TColor; DeleteAlpha: Boolean);
var
  i: Integer;
  q: PRGBQuad;
  Red, Green, Blue: byte;
begin
  Red := GetRValue(TransparentColor);
  Green := GetGValue(TransparentColor);
  Blue := GetBValue(TransparentColor);
  q := BMP.ScanLine[BMP.Height - 1];

  for i:=0 to BMP.Height * BMP.Width - 1 do
  begin
    if (q.rgbRed = Red) and (q.rgbGreen = Green) and (q.rgbBlue = Blue) then
      q.rgbReserved := 0
    else if DeleteAlpha then
      q.rgbReserved := 255;
    q.rgbBlue := q.rgbBlue * q.rgbReserved Shr 8;
    q.rgbGreen := q.rgbGreen * q.rgbReserved Shr 8;
    q.rgbRed := q.rgbRed * q.rgbReserved Shr 8;
    Inc(q);
  end;
end;

procedure THIAlphaBitmap._work_doLoad;
var tmp:PBitmap;
begin
  tmp := ToBitmap(_Data);
  if tmp <> nil then
    Bmp.Assign(tmp);
  if bmp.PixelFormat <> pf32bit then bmp.PixelFormat := pf32bit;
  if _prop_PremultAlpha then PremultAlphaTransparent(bmp, clNone, true);
  _hi_onEvent(_event_onLoad, bmp);    
end;

procedure THIAlphaBitmap._work_doCreate;
var
  br: HBRUSH;
begin
  With Bmp{$ifndef F_P}^{$endif} do
  begin
    Clear;
    Width := ReadInteger(_Data, _data_HWidth, _prop_HWidth);
    Height := ReadInteger(_Data, _data_HHeight, _prop_HHeight);
    PixelFormat := pf32bit;
    if not Bmp.Empty then
    begin
      br := CreateSolidBrush(ReadInteger(_Data, _data_FillColor, _prop_FillColor));
      SelectObject(Canvas.Handle, br);
      Rectangle(Canvas.Handle, 0, 0, Width, Height);
      DeleteObject(br);
//      Canvas.Brush.Color := ReadInteger(_Data, _data_FillColor, _prop_FillColor);
//      Canvas.Brush.BrushStyle := bsSolid;
//      Canvas.FillRect(MakeRect(0,0,Bmp.Width,Bmp.Height));
    end;
  end;
//  bmp.PixelFormat := pf32bit;
  if _prop_PremultAlpha then PremultAlphaTransparent(bmp, clNone, true);
  _hi_onEvent(_event_onCreate, bmp);
end;

procedure THIAlphaBitmap._work_doClear;
begin
  Bmp.Clear;
end;

procedure THIAlphaBitmap._var_Bitmap;
begin
  dtBitmap(_Data,Bmp);
end;

procedure THIAlphaBitmap.SetPicture;
begin
  if Value = 0 then exit;
  bmp.handle := CopyImage(Value, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION);
  if bmp.PixelFormat <> pf32bit then bmp.PixelFormat := pf32bit;
  if _prop_PremultAlpha then PremultAlphaTransparent(bmp, clNone, true);
end;

procedure THIAlphaBitmap._var_Width;
begin
  dtInteger(_Data,Bmp.Width);
end;

procedure THIAlphaBitmap._var_Height;
begin
  dtInteger(_Data,Bmp.Height);
end;

procedure THIAlphaBitmap._work_PremultAlpha;
begin
  _prop_PremultAlpha := ReadBool(_Data);
end;

end.