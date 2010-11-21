unit hiPlotHistogram;

interface

uses windows,Kol,Share,Debug,hiPlotAxis,hiPlotter,PlotSeries;

type
  THistogramSeries = class(TSeries)
    BgColor:TColor;
    Axis:^TAxisSeries;
    Offset:real;
    
    procedure Draw(Canvas:PCanvas; startX,startY,fX,fY:real; VSpace, HSpace:integer); override;
    procedure Add(valY, valX:real); override;
  end;
  
  THIPlotHistogram = class(TPlotSeries)
   protected
    procedure SetGrapher(value:THIPlotter); override;
   public
    _prop_BgColor:TColor;
    _prop_Axis:TAxisSeries;
    _prop_Offset:real;

    constructor Create;
  end;

implementation

uses hiMathParse;

procedure THistogramSeries.Add(valY, valX:real);
begin
   if count = 0 then
     valX := Offset;
   inherited;
end;

procedure THistogramSeries.Draw;
var i:integer;
    _x1,_x2,_y1,_y2:integer;
    b:real;
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
      
      Brush.Color := BgColor;
      Brush.BrushStyle := bsSolid; 
      
      for i := 0 to Count-1 do
        with Values[i] do
          begin
            _x1 := Parent._prop_LeftMargin + Round(VSpace*(x-Size - startX)/FX);
            _x2 := Parent._prop_LeftMargin + Round(VSpace*(x+Size - startX)/FX);
            _y1 := Parent._prop_TopMargin + Round(HSpace - HSpace*(y-startY)/FY);  
            if Axis^ = nil then
               _y2 := Parent._prop_TopMargin + HSpace
            else
              begin
                b := tan(Axis^.Angle/180*pi + pi/2);
                _y2 := Parent._prop_TopMargin + Round(HSpace - HSpace*((Axis^.Y - (x - Axis^.X)/b) - startY)/FY);
              end;
            
            Rectangle(_x1, _y1, _x2, _y2);
          end;
    end;
end;

//------------------------------------------------------------------------------

constructor THIPlotHistogram.Create;
begin
   inherited;
   FSeries := THistogramSeries.Create; 
end;

procedure THIPlotHistogram.SetGrapher(value:THIPlotter);
begin
   inherited;
   with THistogramSeries(FSeries) do
     begin
       BgColor := _prop_BgColor;
       Axis := @_prop_Axis;
       Offset := _prop_Offset;
     end;
end;

end.
