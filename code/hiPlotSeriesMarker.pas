unit hiPlotSeriesMarker;

interface

uses Windows,Kol,Share,Debug,hiPlotter,PlotSeries;

type
  TSMarkerSeries = class(TSeries)
    Text:PStrList;
    Style:TPenStyle;
    FrameColor:TColor;
    FrameStyle:TPenStyle;
    BgStyle:byte;
    BgColor:TColor;
    GFont:PGraphicTool;
    VAlign,HAlign:byte;
    Series:^TSeries;
    
    procedure Draw(Canvas:PCanvas; startX,startY,fX,fY:real; VSpace, HSpace:integer); override;
    constructor Create;
    destructor Destroy; override;
  end;
  
  THIPlotSeriesMarker = class(TPlotSeries)
   protected
    procedure SetGrapher(value:THIPlotter); override;
   public
    _prop_FrameStyle:byte;
    _prop_FrameColor:TColor;
    _prop_BgStyle:byte;
    _prop_BgColor:TColor;
    _prop_Font:TFontRec;
    _prop_HAlign:byte;
    _prop_VAlign:byte;
    _prop_TextList:string;
    _prop_Series:TSeries;

    _hi_onSetText:THI_Event;

    _data_QueryText:THI_Event;

    constructor Create;
    procedure _work_doSetText(var Data:TData; index:word);
  end;

implementation

uses hiMathParse;

constructor TSMarkerSeries.Create;
begin
   inherited;
   Text := NewStrList;
end;

destructor TSMarkerSeries.Destroy;
begin
   GFont.Free;
   Text.Free;
   inherited;
end;

procedure TSMarkerSeries.Draw;
var
   _x,_y,i:integer;
   _px,_py,w,h:integer;
   b:real;
   r:TRect;
   txt:string;
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
 
      for i := 0 to Series.Count-1 do 
      with Series.Values[i] do
        begin
          _px := Parent._prop_LeftMargin + Round(VSpace*(x - startX)/FX);
          _py := Parent._prop_TopMargin + Round(HSpace - HSpace*(y-startY)/FY);
          
          if i < Text.Count then
            begin
              txt := Text.Items[i];
              Pen.Color := FrameColor;
              Pen.PenStyle := FrameStyle;                            
              Pen.PenWidth := 1;
              
              r.left := _px + 6;
              r.top := _py + 6;
              r.right := 0;
              r.bottom := 0;
               
              SelectObject(Handle, GFont.Handle);
              Windows.DrawText(Handle, PChar(Txt), Length(Txt), r, DT_CALCRECT);
    
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
              Windows.DrawText(Handle, PChar(Txt), Length(Txt), r, 0);
            end; 
       end;
    end;
end;

//------------------------------------------------------------------------------

constructor THIPlotSeriesMarker.Create;
begin
   inherited;
   FSeries := TSMarkerSeries.Create; 
end;

procedure THIPlotSeriesMarker.SetGrapher(value:THIPlotter);
begin
   inherited;
   with TSMarkerSeries(FSeries) do
     begin
       Text.Text := _prop_TextList; 
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
       
       Series := @_prop_Series;
     end;
end;

procedure THIPlotSeriesMarker._work_doSetText;
var i:integer;
begin
   TSMarkerSeries(FSeries).Text.Clear;
   for i := 0 to _prop_Series.Count-1 do
     begin
        dtInteger(Data, i);
        _hi_onEvent(_data_QueryText, Data);
        TSMarkerSeries(FSeries).Text.Add(ToString(Data));
     end; 
end;

end.
