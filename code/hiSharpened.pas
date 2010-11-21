unit hiSharpened;

interface

uses Windows,Kol,Share,Debug;

type
  THISharpened = class(TDebug)
   private
    src:PBitmap;
   public
    _prop_Step:integer;

    _data_Bitmap:THI_Event;
    _data_Step:THI_Event;
    _event_onResult:THI_Event;

    destructor Destroy; override;
    procedure _work_doSharpened(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

destructor THISharpened.Destroy;
begin
   if Assigned(src) then src.free;
   inherited;
end;

procedure THISharpened._work_doSharpened;
type  TLine = array[0..0]of byte;
      PLine = ^TLine;
var   bmp: PBitmap;
      Line, Last:PLine;
      i, j, k : integer;
      r, g, b: integer;
      st:real;
begin
   bmp := ReadBitmap(_Data,_data_Bitmap,nil);
   if (bmp = nil) or bmp.Empty then exit;
   st := ReadInteger(_Data, _data_Step, _prop_Step);
   if (st < 1) or (st > 10) then st := _prop_Step;
   st := st/10;
   if not Assigned(src) then src.free;
   src := NewBitmap(0,0);
   src.handle := CopyImage( bmp.Handle, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION );
   src.PixelFormat := pf24bit;
   for i := 1 to bmp.Height - 2 do begin
      Line := src.ScanLine[i];
      Last := src.ScanLine[i-1];
      for j := 1 to Bmp.Width - 1 do begin
         k := j * 3; 
         r := Round(Line^[ k ] + st*(Line^[ k ] - Last^[k-3]));
         g := Round(Line^[k+1] + st*(Line^[k+1] - Last^[k-2]));
         b := Round(Line^[k+2] + st*(Line^[k+2] - Last^[k-1]));

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

procedure THISharpened._var_Result;
begin
   if (src = nil) or src.Empty then exit;
   dtBitmap(_Data, src);
end;

end.
