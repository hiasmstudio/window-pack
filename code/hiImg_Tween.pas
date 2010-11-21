unit HiImg_Tween;

interface

uses Windows,Messages,Kol,Share,Debug;

type
 THiImg_Tween = class(TDebug)
   private
     BitmapA2,BitmapB2,BitmapC: PBitmap;
     BkColor: TColor;
   public
     _prop_BackColor:TColor;
     _data_BackColor:THI_Event;
     _data_BitmapA:THI_Event;
     _data_BitmapB:THI_Event;
     _data_DiffB2A:THI_Event;
     _event_onTween:THI_Event;

     constructor Create; 
     destructor Destroy; override;
     procedure _work_doLoad(var _Data:TData; Index:word);
     procedure _work_doTween(var _Data:TData; Index:word);
     procedure _var_Result(var _Data:TData; Index:word);
 end;

implementation

function CreateTweenBitmap(Var   BitmapC:  PBitmap;
                           Const BitmapA:  PBitmap;
                           Const WeightA:  CARDINAL;
                           Const BitmapB:  PBitmap;
                           Const WeightB:  CARDINAL):  boolean;
  Const
    MaxPixelCount = 65536;

  Type
    TRGBArray = ARRAY[0..MaxPixelCount-1] OF TRGBTriple;
    pRGBArray = ^TRGBArray;

  var
    i         :  INTEGER;
    j         :  INTEGER;
    RowA      :  pRGBArray;
    RowB      :  pRGBArray;
    RowTween  :  pRGBArray;
    SumWeights:  CARDINAL;

  function WeightPixels (Const pixelA, pixelB:  Cardinal):  byte;
  begin
    RESULT := BYTE((WeightA*pixelA + WeightB*pixelB) div SumWeights)
  end {WeightPixels};

begin

  Result := false;
  if   (BitmapA.PixelFormat <> pf24bit)  or
       (BitmapB.PixelFormat <> pf24bit)  or
       (BitmapA.Width  <> BitmapB.Width) or
       (BitmapA.Height <> BitmapB.Height)
  then exit;

  SumWeights := WeightA + WeightB;

  BitmapC.Width  := BitmapA.Width;
  BitmapC.Height := BitmapA.Height;
  BitmapC.PixelFormat := pf24bit;
  
  if SumWeights > 0 then begin
    for j := 0 TO BitmapC.Height-1 do begin
      RowA     := BitmapA.Scanline[j];
      RowB     := BitmapB.Scanline[j];
      RowTween := BitmapC.Scanline[j];
      for i := 0 to BitmapC.Width-1 do begin
        with RowTween[i] do begin
          rgbtRed   := WeightPixels(rowA[i].rgbtRed,   rowB[i].rgbtRed);
          rgbtGreen := WeightPixels(rowA[i].rgbtGreen, rowB[i].rgbtGreen);
          rgbtBlue  := WeightPixels(rowA[i].rgbtBlue,  rowB[i].rgbtBlue)
        end
      end
    end
  end;
  Result := true;
end {CreateTweenBitmap};

procedure THiImg_Tween._work_doLoad;
var   BitmapA,BitmapB: PBitmap;
begin
   BitmapA := ReadBitmap(_Data, _data_BitmapA);
   BitmapB := ReadBitmap(_Data, _data_BitmapB);
   if (BitmapA = nil) or BitmapA.Empty or
      (BitmapB = nil) or BitmapB.Empty then exit;
   BitmapA.PixelFormat := pf24bit;
   BitmapB.PixelFormat := pf24bit;
   BkColor := ReadInteger(_Data,_data_BackColor,_prop_BackColor);

   BitmapA2.Clear;
   BitmapB2.Clear;   
   
   if BitmapA.Width > BitmapB.Width then begin
      BitmapA2.Width := BitmapA.Width; 
      BitmapB2.Width := BitmapA.Width;
   end else begin      
      BitmapA2.Width := BitmapB.Width; 
      BitmapB2.Width := BitmapB.Width;
   end;
   if BitmapA.Height > BitmapB.Height then begin
      BitmapA2.Height := BitmapA.Height; 
      BitmapB2.Height := BitmapA.Height;
   end else begin     
      BitmapA2.Height := BitmapB.Height; 
      BitmapB2.Height := BitmapB.Height;
   end;

   BitmapA2.BkColor := BkColor;
   BitmapA2.Canvas.FillRect(MakeRect(0, 0, BitmapA2.Width, BitmapA2.Height));
   BitmapB2.BkColor := BkColor;
   BitmapB2.Canvas.FillRect(MakeRect(0, 0, BitmapB2.Width, BitmapB2.Height));

   BitBlt(BitmapA2.Canvas.Handle, (BitmapA2.Width - BitmapA.Width) div 2,
                                  (BitmapA2.Height - BitmapA.Height) div 2,
                                  BitmapA.Width, BitmapA.Height,
          BitmapA.Canvas.Handle, 0, 0, SRCCOPY);                             

   BitBlt(BitmapB2.Canvas.Handle, (BitmapB2.Width - BitmapB.Width) div 2,
                                  (BitmapB2.Height - BitmapB.Height) div 2,
                                  BitmapB.Width, BitmapB.Height,
          BitmapB.Canvas.Handle, 0, 0, SRCCOPY);                             

   BitmapA2.PixelFormat := pf24bit;
   BitmapB2.PixelFormat := pf24bit;
   BitmapC.Clear;
end;

procedure THiImg_Tween._work_doTween;
var   Diff: integer;
begin
   if (BitmapA2 = nil) or BitmapA2.Empty or
      (BitmapB2 = nil) or BitmapB2.Empty then exit;
   Diff := ReadInteger(_Data, _data_DiffB2A);
   if Diff <= 0 then Diff := 0
   else if Diff >= 255 then Diff := 255;
   CreateTweenBitmap(BitmapC, BitmapA2, 255 - Diff, BitmapB2, Diff);                  
   _hi_onEvent(_event_onTween, BitmapC);
end;

constructor THiImg_Tween.Create;
begin
   inherited;
   BitmapA2 := NewBitmap(0,0);   
   BitmapB2 := NewBitmap(0,0);
   BitmapC  := NewBitmap(0,0);    
end;

destructor THiImg_Tween.Destroy;
begin
   BitmapA2.free;
   BitmapB2.free;  
   BitmapC.free;
   inherited;
end;

procedure THiImg_Tween._var_Result;
begin
   if (BitmapC = nil) or BitmapC.Empty then exit;
   dtBitmap(_Data, BitmapC);
end;

end.