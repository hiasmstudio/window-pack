unit hiImg_ButEff;

interface

uses Kol,Share,Debug;

type
  TRim = (trRimmed,trRound,trDoubleRound);

  PByteArray = ^TByteArray;
  TByteArray = array[0..32767] of byte;

  THIImg_ButEff = class(TDebug)
   private

   public
    _prop_Contrast:integer;
    _prop_Depth:integer;
    _data_Bitmap:THI_Event;
    _data_Contrast:THI_Event;
    _data_Depth:THI_Event;
    _event_onResult:THI_Event;

    procedure _work_doButton(var _Data:TData; Index:word);
  end;

implementation

function Int2Byte(I: integer): byte;
begin
  if I > 255 then Result := 255
  else if I < 0 then Result := 0
  else Result := I;
end;

procedure THIImg_ButEff._work_doButton;
var
   Temp, Src:PBitmap;
   a: Integer;
   Depth: byte;
   p1,p2:pbytearray;
   w,w3,h,x,x3,y:integer;

   procedure lighter(p:pbytearray; x,a:integer);
   var r,g,b: Integer;
   begin
      r:=p[x];
      g:=p[x+1];
      b:=p[x+2];
      p[x]:=Int2Byte(r+((255-r)*a) div 255);
      p[x+1]:=Int2Byte(g+((255-g)*a) div 255);
      p[x+2]:=Int2Byte(b+((255-b)*a) div 255);
   end;

   procedure darker(p:pbytearray; x,a:integer);
   var r,g,b: Integer;
   begin
      r:=p[x];
      g:=p[x+1];
      b:=p[x+2];
      p[x]:=Int2Byte(r-((r)*a) div 255);
      p[x+1]:=Int2Byte(g-((g)*a) div 255);
      p[x+2]:=Int2Byte(b-((b)*a) div 255);
   end;

begin
   temp := ReadBitmap(_Data,_data_Bitmap,nil); 
   if temp = nil then exit;
   Src := NewBitmap(0, 0);
   Src.Assign(temp);
   a:=ReadInteger(_Data, _data_Contrast, _prop_Contrast);
   Depth:=ReadInteger(_Data, _data_Depth, _prop_Depth);
   
   w := Src.width;
   h := Src.height;
   
   if w > h then begin  
      if Depth > h div 8 then Depth := h div 8;
   end else begin
      if Depth > w div 8 then Depth := w div 8;     
   end;

   Src.PixelFormat:=pf24bit;
   if depth=0 then exit;
   for y:=0 to depth do begin
      p1:=Src.ScanLine[y];
      p2:=Src.ScanLine[h-y-1];
      for x:=y to w-1-y do begin
         x3:=x*3;
         lighter(p1,x3,a);
         darker(p2,x3,a);
      end;
      for x:=0 to y do begin
         x3:=x*3;
         w3:=(w-1-x)*3;
         lighter(p1,x3,a);
         darker(p1,w3,a);
         lighter(p2,x3,a);
         darker(p2,w3,a);
      end;
   end;
   for y:=depth+1 to h-2-depth do begin
      p1:=Src.ScanLine[y];
      for x:=0 to depth do begin
         x3:=x*3;
         w3:=(w-1-x)*3;
         lighter(p1,x3,a);
         darker(p1,w3,a);      
      end;
   end;
   _hi_onEvent(_event_onResult,src);
   Src.free;
end;

end.