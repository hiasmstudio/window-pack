unit hiImg_TextInRect;

interface

{$I share.inc}

uses Windows,Kol,Share,Img_Draw;

type
  THIImg_TextInRect= class(THIDraw2PR)
   private
    GFont: PGraphicTool;
    procedure SetNewFont(Value:TFontRec);
   public
    _prop_OffsetLeft: integer;
    _prop_OffsetRight: integer;
    _prop_OffsetTop: integer;
    _prop_OffsetBottom: integer;        
    _prop_AlignHorizon: integer;
    _prop_AlignVertical: integer;
    _prop_WordBreak: integer;
    _prop_Ellipsis: integer;
    _prop_RtlReading: boolean;
    _prop_NoPrefix: boolean;    
    _prop_SingleLine: boolean; 
    
    _event_onDraw: THI_Event;
    _event_onTextRect: THI_Event;
            
    property _prop_Font:TFontRec write SetNewFont;

    destructor Destroy; override;
    procedure _work_doDraw(var _Data:TData; Index:word);

    procedure _work_doFont(var _Data:TData; Index:word);
    procedure _work_doOffsetLeft(var _Data:TData; Index:word);
    procedure _work_doOffsetRight(var _Data:TData; Index:word);
    procedure _work_doOffsetTop(var _Data:TData; Index:word);
    procedure _work_doOffsetBottom(var _Data:TData; Index:word);
    procedure _work_doAlignHorizon(var _Data:TData; Index:word);
    procedure _work_doAlignVertical(var _Data:TData; Index:word);
    procedure _work_doWordBreak(var _Data:TData; Index:word);
    procedure _work_doEllipsis(var _Data:TData; Index:word);
    procedure _work_doRtlReading(var _Data:TData; Index:word);
    procedure _work_doNoPrefix(var _Data:TData; Index:word);
    procedure _work_doSingleLine(var _Data:TData; Index:word);
  end;

implementation

destructor THIImg_TextInRect.Destroy;
begin
   GFont.free;
   inherited;
end;

procedure THIImg_TextInRect._work_doDraw;
var dt: TData;
    hOldFont: HFONT;
    OldFontSize, h: Integer;
    s:string;
    flag: Cardinal;
    newRect, rect: TRect;
    dTop, dWidth, dHeight, Data: TData;
    mTransform: PTransform;
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

   flag := DT_TOP;
   SetRect(Rect, x1 + _prop_OffsetLeft, y1 + _prop_OffsetTop,
                 x2 - _prop_OffsetRight, y2 - _prop_OffsetBottom);

   newRect := Rect;

   case _prop_AlignHorizon of // выравнивание по горизонтали
    0: flag := flag OR DT_LEFT;
    1: flag := flag OR DT_RIGHT;
    2: flag := flag OR DT_CENTER; 
   end; 

   if _prop_WordBreak = 1 then flag := flag OR DT_WORDBREAK; 
   case _prop_Ellipsis of
    1: flag := flag OR DT_WORD_ELLIPSIS;
    2: flag := flag OR DT_PATH_ELLIPSIS;
    3: flag := flag OR DT_END_ELLIPSIS;
   end;
   if _prop_RtlReading then flag := flag OR DT_RTLREADING; 
   if _prop_NoPrefix   then flag := flag OR DT_NOPREFIX;
   if _prop_SingleLine then flag := flag OR DT_SINGLELINE;

   // h - высота прямоугольника в который помещается текст
   // в newRect - заносится размер прямоугольника занимаемый текстом
   // (DT_CALCRECT - вычесляет размер, рисование не происходит)
   h := DrawText(pDC,PChar(s), -1, newRect, flag OR DT_CALCRECT); 
  
   case _prop_AlignVertical of // выравнивание по вертикали
    0: SetRect(Rect, Rect.Left, Rect.Top, Rect.Right, newRect.Bottom);
    1: SetRect(Rect, Rect.Left, Rect.Bottom - h, Rect.Right, Rect.Bottom);
    2: SetRect(Rect, Rect.Left, Rect.Top + (Rect.Bottom - newRect.Bottom) div 2, Rect.Right, newRect.Bottom + (Rect.Bottom - newRect.Bottom) div 2);
   end; 

   case _prop_AlignHorizon of
    0: SetRect(Rect, Rect.Left, Rect.Top, newRect.Right, Rect.Bottom);
    1: SetRect(Rect, Rect.Left + Rect.Right - newRect.Right, Rect.Top, Rect.Right, Rect.Bottom);
    2: SetRect(Rect, Rect.Left + (Rect.Right - newRect.Right) div 2, Rect.Top, Rect.Right - (Rect.Right - newRect.Right) div 2, Rect.Bottom);   
   end;

   
   mTransform := ReadObject(_Data, _data_Transform, TRANSFORM_GUID);
   if mTransform <> nil then
    begin
     InflateRect(Rect, 1, 1);
     with Rect do
      if mTransform._Set(pDC, Left, Top, Right, Bottom) then  //если необходимо изменить координаты (rotate, flip)
        Rect := mTransform._GetRect(Rect);
    end;
   dtInteger(Data, Rect.Left);
   dtInteger(dWidth, Rect.Right);
   dtInteger(dTop, Rect.Top);
   dtInteger(dHeight, Rect.Bottom);
   Data.ldata:= @dTop;
   dTop.ldata:= @dWidth;
   dWidth.ldata:= @dHeight;
   _hi_OnEvent(_event_onTextRect, Data);

   DrawText(pDC,PChar(s), -1, Rect, flag);
   
   if mTransform <> nil then mTransform._Reset(pDC); // сброс трансформации
 
   SelectObject(pDC, hOldFont);
   GFont.FontHeight := OldFontSize;
FINALLY
   ImgReleaseDC;
   _hi_onEvent(_event_onDraw, dt);
END;
end;

procedure THIImg_TextInRect._work_doFont;
begin
   if _IsFont(_Data) then SetNewFont(PFontRec(_Data.idata)^);
end;

procedure THIImg_TextInRect._work_doAlignHorizon;
begin
   _prop_AlignHorizon := ToInteger(_Data);
end;

procedure THIImg_TextInRect._work_doAlignVertical;
begin
   _prop_AlignVertical := ToInteger(_Data);
end;

procedure THIImg_TextInRect._work_doWordBreak;
begin
   _prop_WordBreak := ToInteger(_Data);
end;

procedure THIImg_TextInRect._work_doEllipsis;
begin
   _prop_Ellipsis := ToInteger(_Data);
end;

procedure THIImg_TextInRect._work_doRtlReading;
begin
   _prop_RtlReading := ReadBool(_Data);
end;

procedure THIImg_TextInRect._work_doNoPrefix;
begin
   _prop_NoPrefix := ReadBool(_Data);
end;

procedure THIImg_TextInRect._work_doSingleLine;
begin
   _prop_SingleLine := ReadBool(_Data);
end;

procedure THIImg_TextInRect._work_doOffsetLeft;
begin
   _prop_OffsetLeft:= ToInteger(_Data);
end;

procedure THIImg_TextInRect._work_doOffsetRight;
begin
   _prop_OffsetRight:= ToInteger(_Data);
end;

procedure THIImg_TextInRect._work_doOffsetTop;
begin
   _prop_OffsetTop:= ToInteger(_Data);
end;

procedure THIImg_TextInRect._work_doOffsetBottom;
begin
   _prop_OffsetBottom:= ToInteger(_Data);
end;

procedure THIImg_TextInRect.SetNewFont;
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