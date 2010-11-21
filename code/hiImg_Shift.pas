unit hiImg_Shift; { компонент сдвига изображения } 

interface

uses Windows, Kol,Share,Debug;
         
type
  ThiImg_Shift = class(TDebug)
    private
      Bitmap:PBitmap;
      ToShiftBmp:PBitmap;
      LBitmap:PBitmap;
      ShiftBmp:PBitmap;
      Color: TColor;
      fDirectShift: byte;
      procedure InitImage;
    public
      _prop_Pixels:integer;
      _prop_BackgroundColor:integer;

      _data_Bitmap:THI_Event;
      _data_ToShiftBmp:THI_Event;
      _data_Pixels:THI_Event;
      _data_BackgroundColor:THI_Event;
      _event_onResult:THI_Event;
      
      property  _prop_DirectShift: byte write fDirectShift;

      destructor Destroy ; override;
      procedure _work_doLoad(var _Data:TData; Index:word);
      procedure _work_doShift(var _Data:TData; Index:word);
      procedure _work_doDirectShift(var _Data:TData; Index:word);

      procedure _var_Result(var _Data:TData; Index:word);      
    end;
implementation

destructor ThiImg_Shift.Destroy;
begin
   if Assigned(LBitmap) then LBitmap.free;
   if Assigned(ShiftBmp) then ShiftBmp.free;
   inherited;
end;

procedure ThiImg_Shift.InitImage;
var   W, H, WW, HH, x1, y1, x2, y2 :integer;
begin
   if (Bitmap <> nil) and not Bitmap.Empty then begin
      W := Bitmap.Width; H := Bitmap.Height;
   end else if (ToShiftBmp <> nil) and not ToShiftBmp.Empty then begin
      W := ToShiftBmp.Width; H := ToShiftBmp.Height;      
   end else exit;

   case fDirectShift of
      0: begin
            WW := W * 2; HH := H; x1 := W; y1 := 0; x2 := 0; y2 := 0;
         end;
      1: begin
            WW := W * 2; HH := H; x1 := 0; y1 := 0; x2 := W; y2 := 0;
         end;
      2: begin
            WW := W; HH := H *2; x1 := 0; y1 := 0; x2 := 0; y2 := H;
         end;
      3: begin
            WW := W; HH := H *2; x1 := 0; y1 := H; x2 := 0; y2 := 0;
      end else begin
            WW := 0; HH := 0; x1 := 0; y1 := 0; x2 := 0; y2 := 0;
      end;
   end;

   if Assigned(LBitmap) then LBitmap.free;
   LBitmap := NewBitmap(WW, HH);
   LBitmap.Canvas.Brush.Color := Color;
   FillRect(LBitmap.Canvas.handle, LBitmap.BoundsRect, LBitmap.Canvas.Brush.Handle);

   if (Bitmap <> nil) and not Bitmap.Empty then
      BitBlt(LBitmap.Canvas.Handle,x1 ,y1, W, H, Bitmap.Canvas.Handle, 0, 0, SRCCOPY);
   if (ToShiftBmp <> nil) and not ToShiftBmp.Empty then  
      BitBlt(LBitmap.Canvas.Handle,x2 ,y2, W, H, ToShiftBmp.Canvas.Handle, 0, 0, SRCCOPY);

   if Assigned(ShiftBmp) then ShiftBmp.free;
   ShiftBmp := NewBitmap(W, H);
end;

procedure ThiImg_Shift._work_doLoad;
begin
   Bitmap := ReadBitmap(_Data,_data_Bitmap,nil);
   color := ReadInteger(_Data, _data_BackgroundColor, _prop_BackgroundColor);
   ToShiftBmp := ToBitmapEvent(_data_ToShiftBmp);
   InitImage;
end;

procedure ThiImg_Shift._work_doShift;
var   pixels, H, W, shx, shy : integer;
begin
   if (ShiftBmp = nil) or ShiftBmp.Empty then exit; 
   pixels := ReadInteger(_Data,_data_Pixels,_prop_Pixels);
   H := ShiftBmp.Height; W := ShiftBmp.Width;
   case fDirectShift of
      0: begin
            if pixels > W then pixels := W;
            shx := W - pixels; shy := 0;
         end;
      1: begin
            if pixels > W then pixels := W;
            shx := pixels; shy := 0;
         end;   
      2: begin
            if pixels > H then pixels := H;
            shx := 0; shy := pixels;
         end;
      3: begin
            if pixels > H then pixels := H;
             shx := 0; shy := H - pixels;
      end else begin
             shx := 0; shy := 0;
      end;                
   end;  
   BitBlt(ShiftBmp.Canvas.Handle, 0, 0, W, H, LBitmap.Canvas.Handle, shx, shy, SRCCOPY);
   _hi_OnEvent(_event_onResult,ShiftBmp);
end;

procedure ThiImg_Shift._work_doDirectShift;
begin
   fDirectShift := ToInteger(_Data);
   InitImage;   
end;

procedure ThiImg_Shift._var_Result;
begin
   if (ShiftBmp = nil) or ShiftBmp.Empty then exit;
   dtBitmap(_Data, ShiftBmp);
end;

end.