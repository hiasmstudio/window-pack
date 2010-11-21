unit hiVisualShape;

{$I share.inc}

interface

uses Kol,Share,Win,Windows,Messages;

type
  THIVisualShape = class(THIWin)
   private
     FShape: byte;
     PColor:TColor;
     PWidth:integer;
     PStyle:byte;
     Color2:TColor;
     procedure Paint(sender:pControl;DC:HDC);
   public
    property _prop_Color2:TColor  write Color2;
    property _prop_PColor:TColor  write PColor;
    property _prop_ShapeType:byte write FShape;
    property _prop_PWidth:integer write PWidth;
    property _prop_PStyle:byte    write PStyle;
        
    procedure Init; override;
    procedure _work_doColor2(var _Data:TData; Index:word);
    procedure _work_doPColor(var _Data:TData; Index:word);
    procedure _work_doShapeType(var _Data:TData; Index:word);
    procedure _work_doPWidth(var _Data:TData; Index:word);
    procedure _work_doPStyle(var _Data:TData; Index:word);               
  end;


implementation

type TShapeType = (stArrowRight, stArrowLeft,
                   stArrowUp, stArrowDown,
                   stEllipse,
                   stLineHorz, stLineVert,
                   stRectangle, stRectangleRound,
                   stTriangleUp, stTriangleDown, stTriangleLeft, stTriangleRight
                   );

procedure THIVisualShape.Init;
begin
  Control := NewPaintBox(FParent);
  Control.Color2 := Color2;
  Control.OnPaint := Paint;
  Inherited;
end;

procedure THIVisualShape.Paint(sender:PControl;DC:HDC);
var
  PT: Integer;
begin
  with sender.canvas{$ifndef F_P}^{$endif} do
   begin
    Brush.Color := Sender.Color;
    if not Control.Transparent then
      FillRect(Sender.ClientRect);
    Pen.Color := Color2RGB(PColor);
    Pen.PenWidth := PWidth;
    Pen.PenStyle := TPenStyle(PStyle);
    Brush.Color := Color2RGB(Sender.Color2);
    PT := Pen.PenWidth div 2;
    case TShapeType(FShape) of
      stRectangle: Rectangle(PT,PT, sender.Width-PT, sender.Height-PT);
      stRectangleRound: RoundRect(PT,PT, sender.Width-PT, sender.Height-PT, sender.Width div 4, sender.Height div 4);
      stEllipse: Ellipse(PT, PT, sender.Width-PT, sender.Height-PT);
      stLineHorz:
        begin
          MoveTo(0, sender.Height div 2);
          LineTo(sender.Width-1, sender.Height div 2);
        end;
      stLineVert:
        begin
          MoveTo(sender.Width div 2, 0);
          LineTo(sender.Width div 2, sender.Height-1);
        end;
      stArrowLeft:
        begin
          MoveTo(sender.Width-1, sender.Height div 2);
          LineTo(PT, sender.Height div 2);
          LineTo(sender.Height div 2, sender.Height-1);
          MoveTo(PT, sender.Height div 2);
          LineTo(sender.Height div 2, 0);
        end;
      stArrowRight:
        begin
          MoveTo(0, sender.height div 2);
          LineTo(sender.width-PT, sender.height div 2);
          LineTo(sender.width-1-(sender.height div 2), sender.height-1);
          MoveTo(sender.width-PT, sender.height div 2);
          LineTo(sender.width-1-(sender.height div 2), 0);
        end;
      stArrowUp:
        begin
          MoveTo(sender.width div 2, sender.height-1);
          LineTo(sender.width div 2, PT);
          LineTo(0, sender.width div 2);
          MoveTo(sender.width div 2, PT);
          LineTo(sender.width-1, sender.width div 2);
        end;
      stArrowDown:
        begin
          MoveTo(sender.width div 2, 0);
          LineTo(sender.width div 2, sender.height-PT);
          LineTo(0, sender.height-1-(sender.width div 2));
          MoveTo(sender.width div 2, sender.height-PT);
          LineTo(sender.width-1, sender.height-1-(sender.width div 2));
        end;
      stTriangleUp:
        Polygon([MakePoint(sender.width div 2, 0), MakePoint(sender.width-1, sender.height-1), MakePoint(0, sender.height-1)]);
      stTriangleDown:
        Polygon([MakePoint(0, 0), MakePoint(sender.width-1, 0), MakePoint(sender.width div 2, sender.height-1)]);
      stTriangleLeft:
        Polygon([MakePoint(0, sender.height div 2), MakePoint(sender.width-1, 0), MakePoint(sender.width-1, sender.height-1)]);
      stTriangleRight:
        Polygon([MakePoint(0, 0), MakePoint(sender.width-1, sender.height div 2), MakePoint(0, sender.height-1)]);
    end;
   end;
end;

procedure THIVisualShape._work_doColor2;
begin
  Color2 := ToInteger(_Data);
  Control.Color2 := Color2;
  Control.Invalidate;
end;

procedure THIVisualShape._work_doPColor;
begin
  PColor := ToInteger(_Data);
  Control.Invalidate;
end;

procedure THIVisualShape._work_doShapeType;
begin
  FShape := ToInteger(_Data);
  Control.Invalidate;
end;

procedure THIVisualShape._work_doPWidth;
begin
  PWidth := ToInteger(_Data); 
  Control.Invalidate;
end;

procedure THIVisualShape._work_doPStyle(var _Data:TData; Index:word);               
begin
  PStyle := ToInteger(_Data);
  Control.Invalidate;
end;


end.
