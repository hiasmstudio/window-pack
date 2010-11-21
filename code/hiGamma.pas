unit hiGamma;

interface

uses Windows,Kol,Share,Debug;

type
  THIGamma = class(TDebug)
   private
    src:PBitmap;
   public
    _prop_Level:integer;

    _data_Level:THI_Event;
    _data_Bitmap:THI_Event;
    _event_onResult:THI_Event;

    destructor Destroy; override;
    procedure _work_doGamma(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

destructor THIGamma.Destroy;
begin
   if Assigned(src) then src.free;
   inherited;
end;

procedure THIGamma._work_doGamma;
type  TLine = array[0..0]of byte;
      PLine = ^TLine;
var   bmp: PBitmap;
      Line:PLine;
      i, j, k: integer;
      r, g, b: integer;
      level:real;
begin
   bmp := ReadBitmap(_Data,_data_Bitmap,nil);
   if (bmp = nil) or bmp.Empty then exit;
   level := ReadInteger(_Data, _data_Level, _prop_Level);
   if level < 0 then level := 0
   else if level > 100 then level := 100;

   level := (level - 50) / 100;

   if not Assigned(src) then src.free;
   src := NewBitmap(0,0);
   src.handle := CopyImage( bmp.Handle, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION );
   src.PixelFormat := pf24bit;
   for i := 0 to bmp.Height - 2 do begin
      Line := src.ScanLine[i];
      for j := 0 to Bmp.Width - 1 do begin
         k := j * 3; 
         r := Round(Line^[ k ] + Line^[ k ]*level);
         g := Round(Line^[k+1] + Line^[k+1]*level);
         b := Round(Line^[k+2] + Line^[k+2]*level);

         if r > 255 then r := 255 else if r < 0 then r := 0;
         if g > 255 then g := 255 else if g < 0 then g := 0;
         if b > 255 then b := 255 else if b < 0 then b := 0;

         Line^[ k ] := r;
         Line^[k+1] := g;
         Line^[k+2] := b;
      end;
   end;
   _hi_OnEvent(_event_onResult,src);
end;

procedure THIGamma._var_Result;
begin
   if (src = nil) or src.Empty then exit;
   dtBitmap(_Data, src);
end;

end.