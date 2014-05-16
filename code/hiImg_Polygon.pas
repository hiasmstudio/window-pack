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
begin
   Items.Clear;
   Items.Assign(Value);
end;

procedure ThiImg_Polygon._work_doDraw;
var dt,di: TData;
    br: HBRUSH;
    pen: HPEN;
    Arr: PArray;
    Ind: TData;
    i: integer;
    Offset: TPoint;
    p: cardinal;
    sColor: TColor;
    Pattern: PBitmap;   
    mTransform: PTransform;
    rect: TRect;
     
    procedure AddPoint(ind: integer; pnt: TPoint);
    var f: integer;
    begin
     PointsArray[ind].x := Round((pnt.x + Offset.x) * fScale.x);
     PointsArray[ind].y := Round((pnt.y + Offset.y) * fScale.y);
     if ind = 0 then begin
      x1 := PointsArray[ind].x;
      y1 := PointsArray[ind].y;
      x2 := x1;
      y2 := y1;
     end else begin 
      x1 := min(x1, PointsArray[ind].x);
      y1 := min(y1, PointsArray[ind].y);
     end;
     x2 := max(x2, PointsArray[ind].x);
     y2 := max(y2, PointsArray[ind].y);
    end;
begin
   dt := _Data;
TRY
   if not ImgGetDC(_Data) then exit;
   p := cardinal(ReadInteger(_Data, _data_Offset, _prop_Offset));
   Offset := MakePoint(smallint(p and $FFFF), smallint(p shr 16));
   Arr := ReadArray(_data_PointsArray);
   if Arr <> nil then begin                  //массив точек полигона из внешнего массива
    if Arr._Count > 0 then begin
     SetLength(PointsArray, Arr._Count); 
     for i := 0 to Arr._Count - 1 do begin
      Ind := _DoData(i);
      Arr._Get(Ind,di);
      p := cardinal(ToInteger(di));
      AddPoint(i, MakePoint(smallint(p and $FFFF), smallint(p shr 16)));
     end;
    end;
   end else                                  //массив точек полигона из свойства
    if Items.Count > 0 then begin
     SetLength(PointsArray, Items.Count);
     for i := 0 to Items.Count - 1 do begin
      p := cardinal(Items.Objects[i]);
      AddPoint(i, MakePoint(smallint(p and $FFFF), smallint(p shr 16)));
     end;
    end;

   if Length(PointsArray) > 0 then begin
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
       begin
         SetBkMode(pDC, TRANSPARENT);
         br := CreateHatchBrush(ord(_prop_Style) - 2, sColor);
       end;
    end;
    pen := CreatePen(ord(_prop_LineStyle), Round((fScale.x + fScale.y) * ReadInteger(_Data,_data_Size,_prop_Size)/2), Color2RGB(ReadInteger(_Data,_data_Color,_prop_Color)));
    SelectObject(pDC,br);
    SelectObject(pDC,Pen);
 
    mTransform := ReadObject(_Data, _data_Transform, TRANSFORM_GUID);
    if mTransform <> nil then
     if mTransform._Set(pDC,x1,y1,x2,y2) then  //если необходимо изменить координаты (rotate, flip)
      begin
       rect := mTransform._GetRect(MakeRect(x1,y1,x2,y2));
       OffsetRect(rect, -x1, -y1);
       for i := 0 to High(PointsArray) do
        begin
         inc(PointsArray[i].x, rect.Left);
         inc(PointsArray[i].y, rect.Top); 
        end;
      end;

     MyPolyline(pDC, PointsArray);  
     if (_prop_Style <> bsClear) or _prop_PatternStyle then
      MyPolygon(pDC, PointsArray);
    DeleteObject(br);
    DeleteObject(Pen);
    if mTransform <> nil then mTransform._Reset(pDC); // сброс трансформации
   end;
FINALLY
   ImgReleaseDC;
   _hi_CreateEvent(_Data,@_event_onDraw, dt);
END;
end;

end.