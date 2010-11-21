unit hiPrint_Shape;

interface

uses Windows,Kol,Share,Debug,hiDocumentTemplate,Img_Draw;

type
  THIPrint_Shape = class(TDocItem)
   private
    txPen:HPEN;
    txBrush:HBRUSH;
    txShadowPen:HPEN;
    
    procedure SetPen(value:TColor);
    procedure SetBrush(value:TColor);  

    procedure DrawFig(dc:HDC; const r:TRect; sx, sy:real);
   public
    _prop_FrameStyle:byte;
    _prop_FrameSize:TColor;
    _prop_BackStyle:byte;
    _prop_Type:byte;
    _prop_Shadow:boolean;
    
    destructor Destroy; override;
    procedure Draw(dc:HDC; x,y:integer; const Scale:TScale); override;    
    property _prop_FrameColor:TColor write SetPen;
    property _prop_BackColor:TColor write SetBrush;
  end;

implementation

destructor THIPrint_Shape.Destroy; 
begin      
   DeleteObject(txPen);
   DeleteObject(txBrush);
   DeleteObject(txShadowPen);
   inherited;
end;

procedure THIPrint_Shape.SetPen;
begin
   txPen := CreatePen(_prop_FrameStyle, _prop_FrameSize, Color2RGB(value));
   txShadowPen := CreatePen(_prop_FrameStyle, _prop_FrameSize, Color2RGB(clGray));
end;

procedure THIPrint_Shape.SetBrush;
begin
   if _prop_BackStyle = 0 then
     txBrush := GetStockObject(NULL_BRUSH)
   else txBrush := CreateSolidBrush(Color2RGB(value));
end;

procedure THIPrint_Shape.DrawFig;
var
    p:array[0..3] of TPoint;
    t:integer;
begin
   case _prop_Type of
     0: Rectangle(dc, r.Left, r.Top, r.Right, r.Bottom);
     1: Ellipse(dc, r.Left, r.Top, r.Right, r.Bottom);
     2: RoundRect(dc, r.Left, r.Top, r.Right, r.Bottom, Round(8*sx), Round(8*sy));
     3:
       begin
          p[0].X := r.Left + (r.Right-r.Left) div 2;
          p[0].Y := r.Top;
          p[1].X := r.Right;
          p[1].Y := r.Top + (r.Bottom-r.Top) div 2;
          p[2].X := p[0].X;
          p[2].Y := r.Bottom;
          p[3].X := r.Left;
          p[3].Y := p[1].Y;
          Polygon(dc,p[0],4);
       end;
     4:
      begin
         t := r.Top + (r.Bottom - r.Top) div 2;
         MoveToEx(dc, r.Left, t, nil);
         LineTo(dc, r.Right, t);
      end;
     5:
      begin
         t := r.Left + (r.Right - r.Left) div 2;
         MoveToEx(dc, t, r.Top, nil);
         LineTo(dc, t, r.Bottom);
      end;
   end;
end;

procedure THIPrint_Shape.Draw;
var
  r,r1:TRect;
begin
   r.Left := Round((x + _prop_X) * Scale.x);
   r.Top := Round((y + _prop_Y) * Scale.y);
   r.Right := Round( (x + _prop_X + _prop_Width) * Scale.x);
   r.Bottom := Round( (y + _prop_Y + _prop_Height) * Scale.y);
   
   SelectObject(dc, txBrush);
   if _prop_Shadow then
    begin
      SelectObject(dc, txShadowPen);
      r1 := r;
      inc(r1.Left);
      inc(r1.Top);
      inc(r1.Right);
      inc(r1.Bottom);
      DrawFig(dc, r1, Scale.x, Scale.y);
    end;

   SelectObject(dc, txPen);
   DrawFig(dc, r, Scale.x, Scale.y);
end;

end.
