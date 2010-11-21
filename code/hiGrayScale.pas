unit hiGrayScale;

interface

uses Windows,Kol,Share,Debug;

type
  THIGrayScale = class(TDebug)
   private
    src:PBitmap;
   public  
    _data_Bitmap:THI_Event;
    _event_onResult:THI_Event;

    destructor Destroy; override;
    procedure _work_doGrayScale(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

destructor THIGrayScale.Destroy;
begin
   if Assigned(src) then src.free;
   inherited;
end;

procedure THIGrayScale._work_doGrayScale;
type  TLine = array[0..0]of byte;
      PLine = ^TLine;
var   bmp: PBitmap;
      Line:PLine;
      i, j, k : integer;
      b, sum: integer;
begin
   bmp := ReadBitmap(_Data,_data_Bitmap,nil);
   if (bmp = nil) or bmp.Empty then exit;
   if not Assigned(src) then 
     src := NewBitmap(0,0);
   
   src.handle := CopyImage( bmp.Handle, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION );
   src.PixelFormat := pf24bit;
   for i := 0 to bmp.Height - 1 do
    begin
      Line := src.ScanLine[i];
      for j := 0 to Bmp.Width - 1 do 
       begin
         k := j * 3; 
         sum := (Line^[k] + Line^[k + 1] + Line^[k + 2]) div 3; 

         Line^[ k ] := sum;
         Line^[k+1] := sum;
         Line^[k+2] := sum;
       end;
    end;
   _hi_OnEvent(_event_onResult, src);
end;

procedure THIGrayScale._var_Result;
begin
   if (src = nil) or src.Empty then exit;
   dtBitmap(_Data, src);
end;

end.
