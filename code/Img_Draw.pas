unit Img_Draw;

interface

uses WIndows,kol,Share,Debug;

type
  TDCMode = (dcBitmap,dcHandle,dcContext);

type
  TScale = record
  x,y : Real;
end;

type
  PByteArray = ^TByteArray;
  TByteArray = array[0..32767] of byte;

type
  THIImg = class(TDebug)
   public
     fScale,SingleScale      : TScale;
     fMode,fDirection        : byte;
     newwh,newhh,oldwh,oldhh : integer;
     pDC                     : HDC;
     glWnd                   : HWND;
     bmp                     : PBitmap;
     fDrawSource             : TDCMode;
     oldx1,oldy1,oldx2,oldy2 : integer;
     x1,y1,x2,y2             : integer;
     x3,y3,x4,y4             : integer;
     rx, ry                  : integer;

     _prop_Point1            : integer;
     _prop_Point2            : integer;
     _prop_Point2AsOffset    : boolean;
     _prop_Size              : integer;
     _prop_LineStyle         : TPenStyle;
     _prop_Style             : TBrushStyle;
     _prop_PatternStyle      : boolean;
     _prop_Color             : TColor;
     _prop_BgColor           : TColor;
     _prop_Transparent       : boolean;
     _prop_TransparentColor  : TColor;
     _prop_AntiAlias         : boolean;
     _prop_Text              : string;

     _data_Text              : THI_Event;
     _data_Bitmap            : THI_Event;
     _data_SourceBitmap      : THI_Event;
     _data_Size              : THI_Event;
     _data_Color             : THI_Event;
     _data_BgColor           : THI_Event;
     _data_Point1            : THI_Event;
     _data_Point2            : THI_Event;
     _data_LineSize          : THI_Event;
     _data_Pattern             :THI_Event;

     _event_onDraw           : THI_Event;

     procedure SetDrawSource(Value:byte);
     procedure AntiAlias(var Clip: PBitmap);
     property  _prop_DrawSource: byte write SetDrawSource;
     function  imgGetDC(var _Data:TData):boolean;
     procedure imgReleaseDC;
     procedure imgNewSizeDC;

     procedure _work_doDrawSource(var _Data:TData; Index:word);
     procedure _work_doLineStyle(var _Data:TData; Index:word);
     procedure _work_doStyle(var _Data:TData; Index:word);
     procedure _work_doPattern(var _Data:TData; Index:word);

   protected
     procedure ReadXY(var _Data:TData);
   end;
  
  THIDraw2P = class(THIImg)
   public
     _prop_X                 : integer;
     _prop_Y                 : integer;
     _data_X                 : THI_Event;
     _data_Y                 : THI_Event;
   protected
     procedure ReadXY(var _Data:TData);
   public
  end;

  THIDraw2PR = class(THIImg)
   public
     _prop_rX                 : integer;
     _prop_rY                 : integer;
     _data_rX                 : THI_Event;
     _data_rY                 : THI_Event;
   protected
     procedure ReadXY(var _Data:TData);
   public
  end;

  THIDraw2PA = class(THIImg)
   public
     _prop_Point3             : integer;
     _prop_Point4             : integer;
     _data_Point3             : THI_Event;
     _data_Point4             : THI_Event;
     _prop_Point4AsOffset     : boolean;
     property _prop_Mode      : byte write fMode;
     property _prop_Direction : byte write fDirection;
     procedure _work_doMode(var _Data:TData; Index:word);
     procedure _work_doDirection(var _Data:TData; Index:word);
   protected
     procedure ReadXY(var _Data:TData);
   public
  end;

implementation

procedure THIImg.AntiAlias;
var X,Y: integer;
    P0,P1,P2: PByteArray;
begin
  Clip.PixelFormat := pf24bit;
  for Y := 1 to Clip.Height-2 do
  begin
    P0 := Clip.ScanLine[Y-1];
    P1 := Clip.ScanLine[Y];
    P2 := Clip.ScanLine[Y+1];
    for X := 1 to Clip.Width-2 do
    begin
      P1[X*3]   := (P0[X*3]   + P2[X*3]   + P1[(X-1)*3]   + P1[(x+1)*3])   div 4;
      P1[X*3+1] := (P0[X*3+1] + P2[X*3+1] + P1[(X-1)*3+1] + P1[(X+1)*3+1]) div 4;
      P1[X*3+2] := (P0[X*3+2] + P2[X*3+2] + P1[(X-1)*3+2] + P1[(X+1)*3+2]) div 4;
    end;
  end;
end;

procedure THIImg.SetDrawSource;
begin
   fDrawSource := TDCMode(Value);
end;

procedure THIImg._work_doDrawSource;
begin
   SetDrawSource(ToInteger(_Data));
end;

procedure THIImg._work_doLineStyle;
begin
   _prop_LineStyle := TPenStyle(ToInteger(_Data));
end;

procedure THIImg._work_doPattern;
begin
   _prop_PatternStyle := ReadBool(_Data);
end;

procedure THIImg._work_doStyle;
var
  tmp: Integer;
begin
  tmp := ToInteger(_Data);
  case tmp of
    0: tmp := 1;
    1: tmp := 0;
  end;
  _prop_Style := TBrushStyle(tmp);
end;

procedure THIImg.ReadXY;
var   p:cardinal;
begin
   p := ReadInteger(_Data,_data_Point1,_prop_Point1);
   y1 := smallint(p shr 16);
   x1 := smallint(p and $FFFF);
   p := ReadInteger(_Data,_data_Point2,_prop_Point2);
   y2 := smallint(p shr 16);
   x2 := smallint(p and $FFFF);
   if _prop_Point2AsOffset then begin
      inc(x2,x1);
      inc(y2,y1);
   end;
end;

procedure THIDraw2P.ReadXY;
begin
   x1 := ReadInteger(_Data,_data_X,_prop_X);
   y1 := ReadInteger(_Data,_data_Y,_prop_Y);
end;

procedure THIDraw2PR.ReadXY;
begin
   THIImg(self).ReadXY(_Data);
   rx := ReadInteger(_Data,_data_rX,_prop_rX);
   ry := ReadInteger(_Data,_data_rY,_prop_rY);
end;

procedure THIDraw2PA.ReadXY;
var   p:cardinal;
begin
   THIImg(self).ReadXY(_Data);
   p := ReadInteger(_Data,_data_Point3,_prop_Point3);
   y3 := smallint(p shr 16);
   x3 := smallint(p and $FFFF);
   p := ReadInteger(_Data,_data_Point4,_prop_Point4);
   y4 := smallint(p shr 16);
   x4 := smallint(p and $FFFF);
   if _prop_Point4AsOffset then begin
      inc(x4,x3);
      inc(y4,y3);
   end;
end;

procedure THIDraw2PA._work_doMode;
begin
   fMode := ToInteger(_Data);
end;

procedure THIDraw2PA._work_doDirection;
begin
   fDirection := ToInteger(_Data);
end;

function THIImg.imgGetDC;
var   DC2: HDC;
begin
  Result := true;
  case fDrawSource of
     dcHandle:  begin
                   glWnd := ReadInteger(_Data,_data_Bitmap,0);
                   pDC := GetDC(glWnd);
                end;
     dcBitmap:  begin
                   bmp := ReadBitmap(_Data,_data_Bitmap,nil);
                   if (bmp <> nil) and (not bmp.Empty) then
                      pDC := bmp.Canvas.Handle
                   else
                      Result := false;
                end;
     dcContext: pDC := ReadInteger(_Data,_data_Bitmap,0);
  end;
  DC2 := GetDC(0);
  fScale.x := GetDeviceCaps(pDC,LOGPIXELSX) / GetDeviceCaps(DC2,LOGPIXELSX);
  fScale.y := GetDeviceCaps(pDC,LOGPIXELSY) / GetDeviceCaps(DC2,LOGPIXELSY);
  SingleScale.x := 1;
  SingleScale.y := 1;
  ReleaseDC(0, DC2);
end;

procedure THIImg.imgReleaseDC;
begin
   case fDrawSource of
      dcHandle: ReleaseDC(glWnd, pDC);
   end;
end;

procedure THIImg.imgNewSizeDC;
begin
   oldx1 := x1;
   oldy1 := y1;
   oldx2 := x2;
   oldy2 := y2;

   oldwh := x2-x1;
   oldhh := y2-y1;

   x1 := Round(x1 * fScale.x);
   y1 := Round(y1 * fScale.y);
   x2 := Round(x2 * fScale.x);
   y2 := Round(y2 * fScale.y);
   x3 := Round(x3 * fScale.x);
   y3 := Round(y3 * fScale.y);
   x4 := Round(x4 * fScale.x);
   y4 := Round(y4 * fScale.y);

   newwh := x2-x1;
   newhh := y2-y1;
end;

end.