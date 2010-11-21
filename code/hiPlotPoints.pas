unit hiPlotPoints;

interface

uses windows,Kol,Share,Debug,hiPlotter,PlotSeries;

type
  TPointSeries = class(TSeries)
    Shape:byte;
    procedure Draw(Canvas:PCanvas; startX,startY,fX,fY:real; VSpace, HSpace:integer); override;
  end;

  THIPlotPoints = class(TPlotSeries)
   protected
    procedure SetGrapher(value:THIPlotter); override;
   public
    _prop_Shape:byte;

    constructor Create;
  end;

implementation

procedure TPointSeries.Draw;
var i:integer;
    _x,_y:integer;
    pa: array[0..3] of TPoint;
begin
   {$ifdef F_P}
   with Canvas do
   {$else}
   with Canvas^ do
   {$endif}
    begin
      Pen.Color := Color;
      Pen.PenStyle := psSolid;              
      Pen.PenWidth := 1;
      
      Brush.Color := Color;
      Brush.BrushStyle := bsSolid; 
      
      for i := 0 to Count-1 do
        with Values[i] do
          begin
            _x := Parent._prop_LeftMargin + Round(VSpace*(x - startX)/FX);
            _y := Parent._prop_TopMargin + Round(HSpace - HSpace*(y-startY)/FY);  
            case Shape of
             0: 
               begin
                 MoveTo(_x - Size, _y);
                 LineTo(_x + Size + 1, _y);
                 MoveTo(_x, _y - Size);
                 LineTo(_x, _y + Size + 1);
               end; 
             1: Rectangle(_x - Size, _y - Size, _x + Size, _y + Size);
             2: Ellipse(_x - Size, _y - Size, _x + Size, _y + Size);
             3:
               begin
                 pa[0].x := _x - Size;
                 pa[0].y := _y + Size div 2;
                 pa[1].x := _x;
                 pa[1].y := _y - Size div 2;   
                 pa[2].x := _x + Size;
                 pa[2].y := _y + Size div 2;   
                 pa[3] := pa[0];
                 Polygon(pa);
               end;
            end;
          end;
    end;
end;

//------------------------------------------------------------------------------

constructor THIPlotPoints.Create;
begin
   inherited;
   FSeries := TPointSeries.Create; 
end;

procedure THIPlotPoints.SetGrapher(value:THIPlotter);
begin
   inherited;
   with TPointSeries(FSeries) do
      Shape := _prop_Shape;
end;

end.
