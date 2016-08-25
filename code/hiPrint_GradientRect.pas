unit hiPrint_GradientRect;

interface

uses Windows,Kol,Share,Debug,hiDocumentTemplate,Img_Draw,DrawControls;

type
  PTriVertex = ^TTriVertex;
  TTriVertex = packed record
    x     : Longint;
    y     : Longint;
    Red   : WORD;
    Green : WORD;
    Blue  : WORD;
    Alpha : WORD;
  end;
  THIPrint_GradientRect = class(TDocItem)
   private
    v:array[0..1] of TTriVertex;
    gr:TGradientRect;
    txPen:HPEN;
    txBrush:HBRUSH;
    blend: TBlendFunction; 

    procedure SetPen(value:TColor);
    procedure SetGrad1Color(value:TColor);
    procedure SetGrad2Color(value:TColor);    
   public
	_prop_Visible:         boolean;
    _prop_Orientation:     byte;
    _prop_FrameStyle:      byte;
    _prop_FrameSize:       integer;
    _prop_AlphaBlendValue: byte; 

    constructor Create;
    destructor Destroy; override;
    procedure Draw(dc:HDC; x,y:integer; const Scale:TScale; alpha: boolean=false); override;    
    property _prop_FrameColor:TColor write SetPen;
    property _prop_Grad1Color:TColor write SetGrad1Color;
    property _prop_Grad2Color:TColor write SetGrad2Color;    
  end;

implementation

function GradientFill(DC: HDC; Vertex: Pointer; NumVertex: Cardinal;
                      Mesh: Pointer; NumMesh, Mode: DWORD): BOOL; stdcall;
                      external 'msimg32.dll' name 'GradientFill';

constructor THIPrint_GradientRect.Create;
begin
   inherited;
   _NameType := _GRADIENTRECT;
   blend.BlendOp := AC_SRC_OVER;
   blend.BlendFlags := 0;
   blend.SourceConstantAlpha := 255;
   blend.AlphaFormat := AC_SRC_NO_PREMULT_ALPHA;   
end;

destructor THIPrint_GradientRect.Destroy; 
begin      
   DeleteObject(txPen);
   DeleteObject(txBrush);
   inherited;
end;

procedure THIPrint_GradientRect.SetPen;
begin
   DeleteObject(txPen);
   DeleteObject(txBrush);
   txPen := CreatePen(_prop_FrameStyle, _prop_FrameSize, Color2RGB(value));
   txBrush := GetStockObject(NULL_BRUSH);
   gr.UpperLeft := 0;
   gr.LowerRight := 1;
end;

procedure THIPrint_GradientRect.SetGrad1Color;
begin
   with TRGB(value) do
     begin
       v[0].Red    := r shl 8;
       v[0].Green  := g shl 8;
       v[0].Blue   := b shl 8;
       v[0].Alpha  := $0000;
     end;
end;

procedure THIPrint_GradientRect.SetGrad2Color;
begin
   with TRGB(value) do
     begin
       v[1].Red    := r shl 8;
       v[1].Green  := g shl 8;
       v[1].Blue   := b shl 8;
       v[1].Alpha  := $0000;
     end;
end;

procedure THIPrint_GradientRect.Draw;
var
  r,r1:TRect;
  pDC: HDC;
  src: PBitmap;
begin
   if not _prop_Visible then exit;
   if not alpha then
   begin
     r.Left := Round((x + _prop_X) * Scale.x);
     r.Top := Round((y + _prop_Y) * Scale.y);
     r.Right := Round( (x + _prop_X + _prop_Width) * Scale.x);
     r.Bottom := Round( (y + _prop_Y + _prop_Height) * Scale.y);
   
     v[0].x      := r.Left;
     v[0].y      := r.Top;
     v[1].x      := r.Right;
     v[1].y      := r.Bottom;

     GradientFill(dc, @V[0], 2, @gr, 1, _prop_Orientation);

     SelectObject(dc, txBrush);
     SelectObject(dc, txPen);
     Rectangle(dc, r.Left, r.Top, r.Right, r.Bottom);
   end
   else
   begin
     r.Left := x + _prop_X;
     r.Top := y + _prop_Y;
     r.Right := x + _prop_X + _prop_Width;
     r.Bottom := y + _prop_Y + _prop_Height;
   
     src := NewDIBBitmap(_prop_Width + _prop_FrameSize, _prop_Height + _prop_FrameSize, pf32bit);
     pDC := src.Canvas.Handle;     

     v[0].x      := _prop_FrameSize div 2;
     v[0].y      := _prop_FrameSize div 2;
     v[1].x      := src.width - _prop_FrameSize div 2;
     v[1].y      := src.height - _prop_FrameSize div 2;
     
     GradientFill(pdc, @V[0], 2, @gr, 1, _prop_Orientation);

     SelectObject(pdc, txBrush);
     SelectObject(pdc, txPen);
     Rectangle(pdc, v[0].x, v[0].y, v[1].x, v[1].y);

     r1 := r;
     dec(r1.Left, _prop_FrameSize div 2);
     dec(r1.Top, _prop_FrameSize div 2);
     inc(r1.Right, _prop_FrameSize div 2);
     inc(r1.Bottom, _prop_FrameSize div 2);

     ScaleRect(r1, Scale.x, Scale.y); 
     PremultAlphaTransparent(src, clDefault, true);
     blend.SourceConstantAlpha := _prop_AlphaBlendValue;
     AlphaBlend(dc, r1.Left, r1.Top, r1.Right - r1.Left, r1.Bottom - r1.Top, pDC, 0, 0, src.width, src.height, blend);
     src.free;        
   end;
end;

end.
