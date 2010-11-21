unit hiGlow;

interface

uses Windows,Kol,Share,Debug;

type
  THIGlow = class(TDebug)
   private
    src:PBitmap;
   public  
    _prop_Level:integer;
    _prop_Background:TColor;
    
    _data_Bitmap:THI_Event;
    _event_onResult:THI_Event;

    destructor Destroy; override;
    procedure _work_doGlow(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

destructor THIGlow.Destroy;
begin
   if Assigned(src) then src.free;
   inherited;
end;

procedure THIGlow._work_doGlow;
type  TLine = array[0..4]of byte;
      PLine = ^TLine;
var   bmp: PBitmap;
      Line:PLine;
      i, j, k, m : integer;
      sum: integer;    
      iarr:array of array of integer;
      bg:TColor;
      
      function GetIValue(x,y:integer):byte;
      var k,l,s,c:integer;
      begin
        s := 0;
        c := 0;
        for l := max(0, y - 2) to min(Bmp.Height - 1, y + 2) do
         for k := max(0, x - 2) to min(Bmp.Width - 1, x + 2) do
           begin
              inc(c);
              inc(s, iarr[l][k]);
           end;          
        Result := s div c;   
      end;
begin
   bmp := ReadBitmap(_Data,_data_Bitmap,nil);
   if (bmp = nil) or bmp.Empty then exit;
   if not Assigned(src) then 
     src := NewBitmap(0,0);
   
   bg := Color2RGB(_prop_BackGround);
   
   src.handle := CopyImage( bmp.Handle, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION );
   src.PixelFormat := pf24bit;
   setlength(iarr, bmp.Height); 
   for i := 0 to bmp.Height - 1 do
    begin
      Line := src.ScanLine[i];
      setlength(iarr[i], Bmp.Width);
      for j := 0 to Bmp.Width - 1 do
        begin
           k := j * 3; 
           if(Line^[k] <> PLine(@bg)^[2])or(Line^[k + 1] <> PLine(@bg)^[1])or(Line^[k + 2] <> PLine(@bg)^[0]) then 
            begin
              sum := 255 - (Line^[k] + Line^[k + 1] + Line^[k + 2]) div 3; 
    
              iarr[i][j] := sum;
            end
           else iarr[i][j] := 0;
        end;
    end;
    
   for i := 0 to bmp.Height - 1 do
    begin
      Line := src.ScanLine[i];
      for j := 0 to Bmp.Width - 1 do 
       begin
         k := j * 3; 
         sum := GetIValue(j,i); 
         for m := 0 to 2 do
           begin
             Line^[ k+m ] := min(round(sum/_prop_level + Line^[k+m]), 255)
           end;
       end;
    end;
   _hi_OnEvent(_event_onResult, src);
end;

procedure THIGlow._var_Result;
begin
   if (src = nil) or src.Empty then exit;
   dtBitmap(_Data, src);
end;

end.
