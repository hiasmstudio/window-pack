unit hiPrint_GradientRect;

interface

uses Windows,Kol,Share,Debug,hiDocumentTemplate,Img_Draw;

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

    procedure SetPen(value:TColor);
    procedure SetGrad1Color(value:TColor);
    procedure SetGrad2Color(value:TColor);    
   public
    _prop_Orientation:byte;
    _prop_FrameStyle:byte;
    _prop_FrameSize:integer;

    destructor Destroy; override;
    procedure Draw(dc:HDC; x,y:integer; const Scale:TScale); override;    
    property _prop_FrameColor:TColor write SetPen;
    property _prop_Grad1Color:TColor write SetGrad1Color;
    property _prop_Grad2Color:TColor write SetGrad2Color;    
  end;

implementation

function GradientFill(DC: HDC; Vertex: Pointer; NumVertex: Cardinal;
                      Mesh: Pointer; NumMesh, Mode: DWORD): BOOL; stdcall;
                      external 'msimg32.dll' name 'GradientFill';

destructor THIPrint_GradientRect.Destroy; 
begin      
   DeleteObject(txPen);
   DeleteObject(txBrush);
   inherited;
end;

procedure THIPrint_GradientRect.SetPen;
begin
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
end;

end.
