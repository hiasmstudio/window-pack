unit hiImg_Text;

interface

{$I share.inc}

uses Windows,Kol,Share,Img_Draw;

type
  THIImg_Text = class(THIDraw2P)
   private
    GFont   : PGraphicTool;
    procedure SetNewFont(Value:TFontRec);
   public

    property _prop_Font:TFontRec write SetNewFont;

    destructor Destroy; override;
    procedure _work_doDraw(var _Data:TData; Index:word);
    procedure _work_doFont(var _Data:TData; Index:word);
    procedure _var_TextWidth(var _Data:TData; Index:word);
    procedure _var_TextHeight(var _Data:TData; Index:word);
  end;

implementation

destructor THIImg_Text.Destroy;
begin
   GFont.free;
   inherited;
end;

procedure THIImg_Text._work_doDraw;
var   dt: TData;
      hOldFont: HFONT;
      OldFontSize: Integer;
      s:string;
begin
   dt := _Data;
TRY
   if not ImgGetDC(_Data) then exit;
   ReadXY(_Data);
   ImgNewSizeDC;
   s := ReadString(_Data,_data_Text,_prop_Text);
   SetBkMode(pDC, TRANSPARENT);
   SetTextColor(pDC, Color2RGB(GFont.Color));   
   OldFontSize := GFont.FontHeight;
   GFont.FontHeight := Round(GFont.FontHeight * fScale.y);
   hOldFont := SelectObject(pDC, GFont.Handle);
   TextOut(pDC, x1, y1, PChar(s), length(s));
   SelectObject(pDC, hOldFont);
   GFont.FontHeight := OldFontSize;
FINALLY
   ImgReleaseDC;
   _hi_CreateEvent(_Data,@_event_onDraw,dt);
END;
end;

procedure THIImg_Text._var_TextWidth;
var   SizeFont: TSize;
      s: string;
      hOldFont: HFONT;
begin
TRY
   if not ImgGetDC(_Data) then exit;
   s := ReadString(_Data,_data_Text,_prop_Text);
   hOldFont := SelectObject(pDC, GFont.Handle);
   GetTextExtentPoint32(pDC, PChar(s), Length(s), SizeFont);
   SelectObject(pDC, hOldFont);
   dtInteger(_Data, SizeFont.cx);
FINALLY
   ImgReleaseDC;
END;
end;

procedure THIImg_Text._var_TextHeight;
var   SizeFont: TSize;
      s: string;
      hOldFont: HFONT;
begin
TRY
   if not ImgGetDC(_Data) then exit;
   s := ReadString(_Data,_data_Text,_prop_Text);
   hOldFont := SelectObject(pDC, GFont.Handle);
   GetTextExtentPoint32(pDC, PChar(s), Length(s), SizeFont);
   SelectObject(pDC, hOldFont);
   dtInteger(_Data, SizeFont.cy);
FINALLY
   ImgReleaseDC;
END;
end;

procedure THIImg_Text._work_doFont;
begin
   if _IsFont(_Data) then SetNewFont(pfontrec(_Data.idata)^);
end;

procedure THIImg_Text.SetNewFont;
begin
   if Assigned(GFont) then GFont.free;
   GFont := NewFont;
   GFont.Color:= Value.Color;
   Share.SetFont(GFont,Value.Style);
   GFont.FontName:= Value.Name;
   GFont.FontHeight:= _hi_SizeFnt(Value.Size);
   GFont.FontCharset:= Value.CharSet;
end;

end.