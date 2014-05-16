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
  mTransform: PTransform;
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

  mTransform := ReadObject(_Data, _data_Transform, TRANSFORM_GUID);
  if mTransform <> nil then
   begin 
    DrawText(pDC, PChar(s), -1, rect, DT_CALCRECT);
    inc(rect.Right, 2);    
    inc(rect.Bottom, 2);
    if mTransform._Set(pDC,rect.Left,rect.Top,rect.Right,rect.Bottom) then  //если необходимо изменить координаты (rotate, flip)
     begin
      rect := mTransform._GetRect(rect); 
     end;
   end;
  DrawText(pDC, @s[1], Length(s), rect, DT_LEFT or DT_TOP);

  if mTransform <> nil then mTransform._Reset(pDC); // сброс трансформации

  SelectObject(pDC, hOldFont);
  GFont.FontHeight := OldFontSize;
  ImgReleaseDC;
  _hi_CreateEvent(_Data, @_event_onDraw, dt);
end;

procedure THIImg_MultiText._var_TextWidth;
var
  pDC: HDC;
  s: string;
  r: TRect;
begin
  pDC := CreateCompatibleDC(0);
  s := ReadString(_Data,_data_Text,_prop_Text);
TRY
  if s = '' then exit;
  SelectObject(pDC, GFont.Handle);
  DrawText(pDC, PChar(s), -1, r, DT_LEFT or DT_TOP or DT_CALCRECT);
FINALLY
  DeleteDC(pDC);
  dtInteger(_Data, r.Right - r.Left);
END;
end;

procedure THIImg_MultiText._var_TextHeight;
var
  pDC: HDC;
  s: string;
  r: TRect;
begin
  pDC := CreateCompatibleDC(0);
  s := ReadString(_Data,_data_Text,_prop_Text);
TRY
  if s = '' then exit;
  SelectObject(pDC, GFont.Handle);
  DrawText(pDC, PChar(s), -1, r, DT_LEFT or DT_TOP or DT_CALCRECT);
FINALLY
  DeleteDC(pDC);
  dtInteger(_Data, r.Bottom - r.Top);
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