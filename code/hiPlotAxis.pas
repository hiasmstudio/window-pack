unit hiPlotAxis;

interface

uses Kol,Share,Debug,hiPlotter;

type
  TAxisSeries = class(TSeries)
    X,Y:real;
    Angle:real;
    Style:TPenStyle;
    procedure Draw(Canvas:PCanvas; startX,startY,fX,fY:real; VSpace, HSpace:integer); override;
  end;

  THIPlotAxis = class(TDebug)
   private
    FSeries:TAxisSeries;
    FGrapher:THIPlotter;
    procedure SetGrapher(value:THIPlotter);
   public
    _prop_Color:TColor;
    _prop_Size:integer;
    _prop_Style:byte;
    _prop_X:real;
    _prop_Y:real;
    _prop_Angle:real;
    _prop_Name:string;
    
    _data_X:THI_Event;
    _data_Y:THI_Event;
    _data_Angle:THI_Event;
    _event_onAxis:THI_Event;
    
    constructor Create;
    destructor Destroy; override;
    procedure _work_doAxis(var _data:TData; index:word);
    function getInterfacePlotterAxis:TAxisSeries;
    property _prop_Grapher:THIPlotter read FGrapher write SetGrapher;
  end;

implementation

uses hiMathParse;

procedure TAxisSeries.Draw;
var
   _x,_y:integer;
   b,endY:real;
begin
   {$ifdef F_P}
   with Canvas do
   {$else}
   with Canvas^ do
   {$endif}
    begin
      Pen.Color := Color;
      Pen.PenStyle := Style;                            
      Pen.PenWidth := Size;
      
      Brush.BrushStyle := bsClear; 
 
      if(Angle = 0)or(Angle = 180)then
        begin
          _y := Parent._prop_TopMargin + Round(HSpace - HSpace*(Y - startY)/FY);  
          MoveTo(Parent._prop_LeftMargin, _y);
          LineTo(Parent._prop_LeftMargin + VSpace, _y);        
        end
      else
        begin
          b := tan(Angle/180*pi + pi/2);
          endY := FX + startY; 
          _x := Parent._prop_LeftMargin + Round(VSpace*((X + (Y - startY)*b) - startX)/FX);
          _y := Parent._prop_TopMargin + HSpace;  
          MoveTo(_x, _y);
          _x := Parent._prop_LeftMargin + Round(VSpace*((X + (Y - endY)*b) - startX)/FX);
          _y := Parent._prop_TopMargin;  
          LineTo(_x, _y);
        end;
    end;
end;

//------------------------------------------------------------------------------

constructor THIPlotAxis.Create;
begin
   inherited;
   FSeries := TAxisSeries.Create; 
end;

destructor THIPlotAxis.Destroy;
begin
   if FSeries.Parent <> nil then
      FSeries.Parent.RemoveSeries(FSeries)
   else FSeries.Destroy;
   inherited;
end;

function THIPlotAxis.getInterfacePlotterAxis:TAxisSeries;
begin
   Result := FSeries;
end;

procedure THIPlotAxis.SetGrapher(value:THIPlotter);
begin
   FGrapher := value;   
   FGrapher.AddSeries(FSeries);
   with FSeries do
     begin
       Color := _prop_Color;
       Size := _prop_Size;
       Style := TPenStyle(_prop_Style); 
       X := _prop_X;
       Y := _prop_Y;
       Angle := _prop_Angle; 
     end;
end;

procedure THIPlotAxis._work_doAxis;
begin
   with FSeries do
     begin
       X := ReadReal(_Data, _data_X, _prop_X);
       Y := ReadReal(_Data, _data_Y, _prop_Y);
       Angle := ReadReal(_Data, _data_Angle, _prop_Angle); 
     end;
   FGrapher.ReDraw;
   _hi_onEvent(_event_onAxis);
end;

end.
