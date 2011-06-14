unit hiImg_MultiText;

interface

uses Windows,Kol,Share,Debug,Img_Draw;

type
  THIImg_MultiText = class(THIImg)
   private
    GFont   : PGraphicTool;
    procedure SetNewFont(Value:TFontRec);
   public

    _data_X, _data_Y: THI_Event;
    _prop_X, _prop_Y: integer;

    property _prop_Font:TFontRec write SetNewFont;
    procedure _work_doDraw(var _Data:TData; Index:word);
    procedure _work_doFont(var _Data:TData; Index:word);
    procedure _var_TextWidth(var _Data:TData; Index:word);
    procedure _var_TextHeight(var _Data:TData; Index:word);
    destructor Destroy; override;
  end;


implementation

destructor THIImg_MultiText.Destroy;
begin
  GFont.free;
  inherited;
end;

procedure THIImg_MultiText._work_doDraw;
var
  dt: TData;
  rect: TRect;
  s: string;
  hOldFont: HFONT;
  OldFontSize: Integer;
begin
  dt := _Data;
  if not ImgGetDC(_Data) then exit;
  GetClipBox(pDC, rect);
  rect.Left := ReadInteger(_Data, _data_X, _prop_X);
  rect.Top  := ReadInteger(_Data, _data_Y, _prop_Y);
  ImgNewSizeDC;
  s         := ReadString(_Data,_data_Text, _prop_Text);
  SetBkMode(pDC, TRANSPARENT);
  SetTextColor(pDC, Color2RGB(GFont.Color));
  OldFontSize := GFont.FontHeight;
  GFont.FontHeight := Round(GFont.FontHeight * fScale.y);
  hOldFont := SelectObject(pDC, GFont.Handle);
  if s <> '' then DrawText(pDC, @s[1], Length(s), rect, DT_LEFT or DT_TOP);
  SelectObject(pDC, hOldFont);
  GFont.FontHeight := OldFontSize;
  ImgReleaseDC;
  _hi_CreateEvent(_Data, @_event_onDraw, dt);
end;

procedure THIImg_MultiText._var_TextWidth;
var
  SizeFont: TSize;
  DC: HDC;
  s: string;
  st: PStrList;
  i, m: integer;
begin
  m := 0;
  s := ReadString(_Data,_data_Text,_prop_Text);
  st := NewStrList;
  DC := CreateCompatibleDC(0);
TRY
  if s = '' then exit;
  st.SetText(s, true);
  SelectObject(DC, GFont.Handle);
  s := st.items[m];
  while GetTextExtentPoint32(DC, @st.items[i][1], Length(st.items[i]), SizeFont) and (i <= st.Count) do
  begin
    if SizeFont.cx > m then m := SizeFont.cx;
    Inc(i);
  end;
FINALLY
  dtInteger(_Data, m);
  DeleteDC(DC);
  st.Free;
END;
end;

procedure THIImg_MultiText._var_TextHeight;
var
  SizeFont: TSize;
  DC: HDC;
  s: string;
  st: PStrList;
  m: integer;
begin
  m := 0;
  s := ReadString(_Data,_data_Text,_prop_Text);
  st:= NewStrList;
  DC := CreateCompatibleDC(0);
TRY
  if s = '' then exit;
  st.SetText(s, true);
  SelectObject(DC, GFont.Handle);
  GetTextExtentPoint32(DC, @s[1], Length(s), SizeFont);
  m := SizeFont.cy * st.Count; 
FINALLY
  dtInteger(_Data, m);
  DeleteDC(DC);
  st.Free;
END;
end;

procedure THIImg_MultiText._work_doFont;
begin
  if _IsFont(_Data) then SetNewFont(PFontRec(_Data.idata)^);
end;


procedure THIImg_MultiText.SetNewFont;
begin
  if Assigned(GFont) then GFont.free;
  GFont := NewFont;
  with {$ifdef F_P}GFont{$else}GFont^{$endif} do
  begin
    Color       := Value.Color;
    SetFont(GFont, Value.Style);
    FontName    := Value.Name;
    FontHeight  := _hi_SizeFnt(Value.Size);
    FontCharset := Value.CharSet;
   end;
end;

end.