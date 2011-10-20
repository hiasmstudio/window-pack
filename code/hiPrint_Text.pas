unit hiPrint_Text;

interface

uses Windows,Kol,Share,Debug,hiDocumentTemplate,Img_Draw;

type
  THIPrint_Text = class(TDocItem)
   private
    FontRec: TFontRec;
    FrameColor, BackColor: TColor;
    GFont   : PGraphicTool;
    txPen:HPEN;
    txBrush:HBRUSH;
    
    procedure SetNewFont(Value:TFontRec);
    procedure SetPen(value:TColor);
    procedure SetBrush(value:TColor);  
   public
    _prop_Text:string;
    _prop_FrameStyle:byte;
    _prop_FrameSize:byte;
    _prop_BackStyle:byte;
    _prop_Vertical:byte;
    _prop_Horizontal:byte;
    _prop_Left:integer;
    _prop_Top:integer;
    _prop_Right:integer;
    _prop_Bottom:integer;
    
    constructor Create;
    destructor Destroy; override;
    procedure Draw(dc:HDC; x,y:integer; const Scale:TScale); override;    
    property _prop_Font:TFontRec read FontRec write SetNewFont;
    property _prop_FrameColor:TColor read FrameColor write SetPen;
    property _prop_BackColor:TColor read BackColor write SetBrush;
  end;

implementation

const VAl:array[0..2] of byte = (0,DT_SINGLELINE or DT_VCENTER,DT_SINGLELINE or DT_BOTTOM);
      HAl:array[0..2] of byte = (DT_LEFT,DT_CENTER,DT_RIGHT);

procedure ScaleRect(var r:TRect; sx, sy:real);
begin
  r.Left := Round(r.Left * sx);
  r.Right := Round(r.Right * sx);
  r.Top := Round(r.Top * sy);
  r.Bottom := Round(r.Bottom * sy);
end;

constructor THIPrint_Text.Create;
begin
   inherited;
   _NameType := _TEXT;
end;

destructor THIPrint_Text.Destroy; 
begin      
   GFont.Free;
   DeleteObject(txPen);
   DeleteObject(txBrush);
   inherited;
end;

procedure THIPrint_Text.SetNewFont;
begin
   FontRec := Value;
   if Assigned(GFont) then GFont.free;
   GFont := NewFont;
   GFont.Color:= Value.Color;
   Share.SetFont(GFont,Value.Style);
   GFont.FontName:= Value.Name;
   GFont.FontHeight:= _hi_SizeFnt(Value.Size);
   GFont.FontCharset:= Value.CharSet;
end;

procedure THIPrint_Text.SetPen;
begin
   FrameColor := Value;
   txPen := CreatePen(_prop_FrameStyle, _prop_FrameSize, Color2RGB(value));
end;

procedure THIPrint_Text.SetBrush;
begin
   BackColor := Value;
   if _prop_BackStyle = 0 then
     txBrush := GetStockObject(NULL_BRUSH)
   else txBrush := CreateSolidBrush(Color2RGB(value));
end;

procedure THIPrint_Text.Draw;
var
  hOldFont: HFONT;
  r,rc:TRect;
  fh:integer;
begin
   fh := GFont.FontHeight;
   GFont.FontHeight := Round(GFont.FontHeight * Scale.y);
   hOldFont := SelectObject(dc, GFont.Handle);
   SetTextColor(dc, GFont.Color);
   SetBkMode(DC,TRANSPARENT);

   r.Left := x + _prop_X;
   r.Top := y + _prop_Y;
   r.Right := x + _prop_X + _prop_Width;
   r.Bottom := y + _prop_Y + _prop_Height;

   SelectObject(dc, txBrush);
   SelectObject(dc, txPen);

   rc := r;
   ScaleRect(rc, Scale.x, Scale.y); 
   Rectangle(dc, r.Left, r.Top, r.Right, r.Bottom);

   inc(r.Left, _prop_Left);
   inc(r.Top, _prop_Top);
   dec(r.Right, _prop_Right);
   dec(r.Bottom, _prop_Bottom);
   rc := r;
   ScaleRect(rc, Scale.x, Scale.y); 
   DrawText(DC,pchar(_prop_Text),length(_prop_Text),rc,hal[_prop_Horizontal] or val[_prop_Vertical] or DT_WORDBREAK);
  
   SelectObject(dc, hOldFont);
   GFont.FontHeight := fh; 
end;

end.
