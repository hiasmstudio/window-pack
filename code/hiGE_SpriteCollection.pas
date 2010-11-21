unit hiGE_SpriteCollection;

interface

uses Kol,Share,Debug;

type
  TSpriteBitmap = record
    bmp:PBitmap;
    Mask:PBitmap;
  end;
  PSpriteBitmap = ^TSpriteBitmap;
  THIGE_SpriteCollection = class(TArray)
   private
     function DataToPointer(var Data:TData):cardinal; override;
     procedure PointerToData(Data:cardinal; var Result:TData); override;
     procedure Delete(Value:cardinal); override;

     procedure CreateMask(bmp:PBitmap; Color:TColor);
     procedure FillWhite(bmp:PBitmap; Color:TColor);

     procedure SetArray(const value:PStrListEx);
     function getBitmap(index:integer):PBitmap;
     function getBitmapByStr(const index:string):PBitmap;
     function getMaskByStr(const index:string):PBitmap;
   public
    _prop_Name:string;
    _prop_MaskColor:TColor;

    function getInterfaceGESpriteCollection:THIGE_SpriteCollection;
    property _prop_Bitmaps:PStrListEx write SetArray;
    property BMPbyIndex[index:integer]:PBitmap read getBitmap;
    property BMPbyName[const index:string]:PBitmap read getBitmapByStr;
    property MaskbyName[const index:string]:PBitmap read getMaskByStr;
  end;

implementation

function THIGE_SpriteCollection.getInterfaceGESpriteCollection:THIGE_SpriteCollection;
begin
    Result := self;
end;

function THIGE_SpriteCollection.DataToPointer;
var 
    sb:PSpriteBitmap;
begin
   if Data.Data_type = data_bitmap then
    begin
      new(sb);
      sb.bmp := NewBitmap(0,0);
      sb.bmp.Assign(PBitmap(data.idata));
      sb.mask := nil;
      Result := integer(sb);
    end
   else result := 0;
end;

procedure THIGE_SpriteCollection.PointerToData;
begin
   dtBitmap(Result,PBitmap(Data));
end;

procedure THIGE_SpriteCollection.Delete;
begin
   PSpriteBitmap(Value).bmp.Free;
   if Assigned(PSpriteBitmap(Value).mask) then
     PSpriteBitmap(Value).mask.Free;
   Dispose(PSpriteBitmap(Value));
end;

procedure THIGE_SpriteCollection.CreateMask;
type  TLine = array[0..0]of byte;
      PLine = ^TLine;
var   
      Line:PLine;
      i, j, k : integer;
      r, g, b: integer;
begin
   r := Color and $FF;
   g := (Color and $FF00) shr 8;
   b := (Color and $FF0000) shr 16;
   
   bmp.PixelFormat := pf24bit;
   for i := 0 to bmp.Height - 1 do
     begin
       Line := bmp.ScanLine[i];
       for j := 0 to Bmp.Width - 1 do
         begin
           k := j*3;
           if (Line^[k+0] = r)and(Line^[k+1] = g)and(Line^[k+2] = b) then 
             FillChar(Line^[k],3,$FF)
           else
             FillChar(Line^[k],3,$00);
         end;
     end;
end;

procedure THIGE_SpriteCollection.FillWhite;
type  TLine = array[0..0]of byte;
      PLine = ^TLine;
var   
      Line:PLine;
      i, j, k : integer;
      r, g, b: integer;
begin
   r := Color and $FF;
   g := (Color and $FF00) shr 8;
   b := (Color and $FF0000) shr 16;
   
   bmp.PixelFormat := pf24bit;
   for i := 0 to bmp.Height - 1 do
     begin
       Line := bmp.ScanLine[i];
       for j := 0 to Bmp.Width - 1 do
         begin
           k := j*3;
           if (Line^[k+0] = r)and(Line^[k+1] = g)and(Line^[k+2] = b) then 
             FillChar(Line^[k],3,$00);
         end;
     end;
end;

procedure THIGE_SpriteCollection.SetArray;
var 
    i:integer;
    sb:PSpriteBitmap;
begin
   SetItems(Value);
   for i := 0 to value.Count-1 do
     begin
       new(sb);
       sb.bmp := NewBitmap(0,0);
       sb.bmp.Handle := Value.Objects[i];
       sb.mask := nil;
       value.Objects[i] := cardinal(sb);
     end;
end;

function THIGE_SpriteCollection.getBitmap(index:integer):PBitmap;
begin
   Result := PSpriteBitmap(Items.Objects[index]).bmp; 
end;

function THIGE_SpriteCollection.getBitmapByStr;
var i:integer;
begin
   i := Items.IndexOf(index);
   if i = -1 then
     Result := nil
   else Result := PSpriteBitmap(Items.Objects[i]).bmp; 
end;

function THIGE_SpriteCollection.getMaskByStr;
var i:integer;
    msk,bmp:^PBitmap;
begin
   i := Items.IndexOf(index);
   if i = -1 then
     Result := nil
   else
     begin
       bmp := @PSpriteBitmap(Items.Objects[i]).bmp;
       msk := @PSpriteBitmap(Items.Objects[i]).mask;
       if msk^ = nil then
         begin
           msk^ := NewBitmap(0,0);
           msk^.Assign(bmp^);
           CreateMask(msk^, _prop_MaskColor);
           FillWhite(bmp^, _prop_MaskColor); 
         end;
       Result := msk^;
     end; 
end;

end.
