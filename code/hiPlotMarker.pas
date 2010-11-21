unit hiPlotMarker;

interface

uses Windows,Kol,Share,Debug,hiPlotAxis,hiPlotter,PlotSeries;

type
  TMarkerSeries = class(TSeries)
    Text:string;
    Style:TPenStyle;
    AxisX:^TAxisSeries;
    AxisY:^TAxisSeries;
    FrameColor:TColor;
    FrameStyle:TPenStyle;
    BgStyle:byte;
    BgColor:TColor;
    GFont:PGraphicTool;
    VAlign,HAlign:byte;
    
    procedure Draw(Canvas:PCanvas; startX,startY,fX,fY:real; VSpace, HSpace:integer); override;
    destructor Destroy; override;
  end;

  THIPlotMarker = class(TPlotSeries)
   protected
    procedure SetGrapher(value:THIPlotter); override;
   public
    _prop_Style:byte;
    _prop_FrameStyle:byte;
    _prop_FrameColor:TColor;
    _prop_BgStyle:byte;
    _prop_BgColor:TColor;
    _prop_Font:TFontRec;
    _prop_X:real;
    _prop_Y:real;
    _prop_AxisX:TAxisSeries;
    _prop_AxisY:TAxisSeries;
    _prop_Text:string;
    _prop_VAlign:byte;
    _prop_HAlign:byte;

    _data_Y:THI_Event;
    _data_X:THI_Event;
    _event_onAxis:THI_Event;

    constructor Create;
    procedure _work_doAxis(var _Data:TData; Index:word);
  end;

implementation

uses hiMathParse;

destructor TMarkerSeries.Destroy;
begin
   GFont.Free;
   inherited;
end;

procedure TMarkerSeries.Draw;
var
   _x,_y:integer;
   _px,_py,w,h:integer;
   b:real;
   r:TRect;
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
 
      with Values[0] do
        begin
          _y := Parent._prop_TopMargin + Round(HSpace - HSpace*(y - startY)/FY);  
          if AxisY^ = nil then
            _x := Parent._prop_LeftMargin 
          else
            begin 
              b := tan(AxisY^.Angle/180*pi + pi/2);
              _x := Parent._prop_LeftMargin + Round(VSpace*((AxisY^.X + (AxisY^.Y - Y)*b) - startX)/FX);
            end;
          MoveTo(_x, _y);
          _x := Parent._prop_LeftMargin + Round(VSpace*(x - startX)/FX);
          _y := Parent._prop_TopMargin + Round(HSpace - HSpace*(y-startY)/FY);
          _px := _x;
          _py := _y;
          LineTo(_x, _y);          
          if AxisX^ = nil then
            _y := Parent._prop_TopMargin + VSpace
          else
            begin 
              b := tan(AxisX^.Angle/180*pi + pi/2);
              _y := Parent._prop_TopMargin + Round(HSpace - HSpace*((AxisX^.Y - (x - AxisX^.X)/b) - startY)/FY);
            end;
          LineTo(_x, _y);  
        end;
        
      if length(Text) > 0 then
        begin
          Pen.Color := FrameColor;
          Pen.PenStyle := FrameStyle;                            
          Pen.PenWidth := 1;
          
          r.left := _px + 6;
          r.top := _py + 6;
          r.right := 0;
          r.bottom := 0;
           
          SelectObject(Handle, GFont.Handle);
          Windows.DrawText(Handle, PChar(Text), Length(Text), r, DT_CALCRECT);

          w := r.right - r.left;
          h := r.bottom - r.top;
          FillChar(r, sizeof(r), 0);
          case VAlign of
           0: begin r.bottom := _py - 6; r.top := r.bottom - h; end;
           1: begin r.top := _py - h div 2; r.bottom := r.top + h; end;
           2: begin r.top := _py + 6; r.bottom := r.top + h; end;
          end;
          case HAlign of
           0: begin r.right := _px - 6; r.left := r.right - w; end;
           1: begin r.left := _px - w div 2; r.right := r.left + w; end;
           2: begin r.left := _px + 6; r.right := r.left + w; end;
          end;
          
          Brush.BrushStyle := TBrushStyle(BgStyle);
          Brush.Color := BgColor;
          Rectangle(r.left-2, r.top-2, r.right+2, r.bottom+2); 
          Brush.BrushStyle := bsClear;
          SelectObject(Handle, GFont.Handle);
          SetTextColor(Handle, GFont.Color);
          SetBkMode(Handle, TRANSPARENT);
          Windows.DrawText(Handle, PChar(Text), Length(Text), r, 0);
        end; 
    end;
end;

//------------------------------------------------------------------------------

constructor THIPlotMarker.Create;
begin
   inherited;
   FSeries := TMarkerSeries.Create; 
end;

procedure THIPlotMarker.SetGrapher(value:THIPlotter);
begin
   inherited;
   with TMarkerSeries(FSeries) do
     begin
       Style := TPenStyle(_prop_Style);
       Text := _prop_Text; 
       FrameColor := _prop_FrameColor;
       FrameStyle := TPenStyle(_prop_FrameStyle);
       BgStyle := _prop_BgStyle;
       BgColor := _prop_BgColor;
   
       GFont := NewFont;
       GFont.Color:= _prop_Font.Color;
       Share.SetFont(GFont,_prop_Font.Style);
       GFont.FontName:= _prop_Font.Name;
       GFont.FontHeight:= _hi_SizeFnt(_prop_Font.Size);
       GFont.FontCharset:= _prop_Font.CharSet;
       
       VAlign := _prop_VAlign;
       HAlign := _prop_HAlign;
   
       Add(_prop_Y, _prop_X);
       AxisX := @_prop_AxisX;
       AxisY := @_prop_AxisY; 
     end;
end;

procedure THIPlotMarker._work_doAxis;
begin
   with FSeries.Values[0] do
     begin
       x := ReadReal(_Data, _data_X, _prop_X);
       y := ReadReal(_Data, _data_Y, _prop_Y); 
     end;
   FGrapher.ReDraw;  
end;

end.
