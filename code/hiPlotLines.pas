unit hiPlotLines;

interface

uses Kol,Share,Debug,hiPlotter,PlotSeries;

type
  TLineSeries = class(TSeries)
    procedure Draw(Canvas:PCanvas; startX,startY,fX,fY:real; VSpace, HSpace:integer); override;
  end;

  THIPlotLines = class(TPlotSeries)
   protected
   public
    constructor Create;
  end;

implementation

procedure TLineSeries.Draw;
var i:integer;
    _x,_y:integer;
begin
   {$ifdef F_P}
   with Canvas do
   {$else}
   with Canvas^ do
   {$endif}
    begin
      Pen.Color := Color;
      Pen.PenStyle := psSolid;              
      Pen.PenWidth := Size;
      
      Brush.Color := Color;
      Brush.BrushStyle := bsSolid; 
      
      for i := 0 to Count-1 do
        with Values[i] do
          begin
            _x := Parent._prop_LeftMargin + Round(VSpace*(x - startX)/FX);
            _y := Parent._prop_TopMargin + Round(HSpace - HSpace*(y-startY)/FY);  
            //if _prop_EnabledPoints  then
            //  Ellipse(_x - _prop_SizePoints, _y - _prop_SizePoints, _x + _prop_SizePoints, _y + _prop_SizePoints);
            if i = 0 then
              MoveTo(_x, _y)
            else LineTo(_x, _y);
          end;
  end;
end;

//------------------------------------------------------------------------------

constructor THIPlotLines.Create;
begin
   inherited;
   FSeries := TLineSeries.Create; 
end;

end.
