unit hiImg_Polygon;

interface

uses Windows,Kol,Share,Img_Draw;

{$I share.inc}

type
  PPoints = ^TPoints;
  TPoints = array of TPoint;

type
  ThiImg_Polygon = class(THIImg)
   private
     Items:PStrListEx;
     PointsArray: TPoints;
    
     procedure SetItems(Value:PStrListEx);
   public
     _prop_Offset: integer;
     _data_PointsArray:THI_Event;
     _data_Offset:THI_Event;
     
     constructor Create;
     destructor Destroy; override;
     property _prop_PointsArray:PStrListEx write SetItems;
     procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

procedure MyPolyline(DC: HDC; const Points: array of TPoint);
begin
   Polyline(DC, PPoints(@Points)^, High(Points) + 1);
end;

procedure MyPolygon(DC: HDC; const Points: array of TPoint);
begin
   Polygon(DC, PPoints(@Points)^, High(Points) + 1);
end;

procedure NewSize(var Points: array of TPoint; const Offset: cardinal; Scale: TScale);
var   i,x,y: integer;
begin
   if (Length(Points) = 0) then exit;
   x := Offset and $FFFF;
   y := Offset shr 16;
   for i := 0 to High(Points) do begin
      if x <> 0 then inc(Points[i].x, x); 
      if y <> 0 then inc(Points[i].y, y);
      Points[i].x := Round(Points[i].x * Scale.x);
      Points[i].y := Round(Points[i].y * Scale.y);
   end; 
end;

constructor ThiImg_Polygon.Create;
begin
   inherited;
   Items := NewStrListEx;   
end;   

destructor ThiImg_Polygon.Destroy;
begin
   Items.Free;
   SetLength(PointsArray, 0);
   inherited;
end;   

procedure ThiImg_Polygon.SetItems;
var   p: cardinal;
      i: integer;
begin
   Items.Clear;
   Items.Assign(Value);
   if Items.Count = 0 then exit;
   SetLength(PointsArray, Items.Count);
   for i := 0 to Items.Count - 1 do begin
      p := cardinal(Items.Objects[i]);
      PointsArray[i] := MakePoint(p and $FFFF, p shr 16);
   end;
end;

procedure ThiImg_Polygon._work_doDraw;
var   dt,di: TData;
      br: HBRUSH;
      pen: HPEN;
      Arr: PArray;
      Ind: TData;
      i: integer;
      p: cardinal;
      sColor: TColor;
      Pattern: PBitmap;   
begin
   dt := _Data;
TRY
   if not ImgGetDC(_Data) then exit;

   Arr := ReadArray(_data_PointsArray);

   if Arr <> nil then begin
      if (Arr._Count > 0) then begin
         SetLength(PointsArray, Arr._Count); 
         for i := 0 to Arr._Count - 1 do begin
            Ind := _DoData(i);
            Arr._Get(Ind,di);
            p := cardinal(ToInteger(di));
            PointsArray[i] := MakePoint(p and $FFFF, p shr 16);
         end;
      end;
   end;
   sColor := Color2RGB(ReadInteger(_Data,_data_BgColor,_prop_BgColor));
     
   if _prop_PatternStyle then
   begin
     Pattern := ReadBitmap(_Data,_data_Pattern);
     if not Assigned(Pattern) or Pattern.Empty then
       br := GetStockObject(NULL_BRUSH)
     else
       br := CreatePatternBrush(Pattern.Handle);
   end
   else
     begin
     if _prop_Style = bsSolid then
        br := CreateSolidBrush(sColor)
     else if _prop_Style = bsClear then
        br := GetStockObject(NULL_BRUSH)
     else
        br := CreateHatchBrush(ord(_prop_Style) - 2, sColor);
   end;

   NewSize(PointsArray, cardinal(ReadInteger(_Data, _data_Offset, _prop_Offset)), fScale);

   pen := CreatePen(ord(_prop_LineStyle), Round((fScale.x + fScale.y) * ReadInteger(_Data,_data_Size,_prop_Size)/2), Color2RGB(ReadInteger(_Data,_data_Color,_prop_Color)));
   
   SelectObject(pDC,br);
   SelectObject(pDC,Pen);
   if Length(PointsArray) <> 0 then begin
      MyPolyline(pDC, PointsArray);  
      if _prop_Style <> bsClear then MyPolygon(pDC, PointsArray);
   end;
   DeleteObject(br);
   DeleteObject(Pen);
FINALLY
   ImgReleaseDC;
   _hi_CreateEvent(_Data,@_event_onDraw,dt);
END;
end;

end.