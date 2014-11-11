unit hiRGN_Draw;

interface

uses Windows,Kol,Share,Debug;

type
  THIRGN_Draw = class(TDebug)
   private
   public
     pDC                 :HDC;
     glWnd               :HWND;
    _prop_DrawSource     :byte;
    _prop_LineWidth      :integer;
    _prop_LineHeight     :integer;
    _prop_UseOffsetFill  :byte;
    _prop_PatternStyle   :boolean;
    _prop_Outline        :boolean;
    _prop_Transparent    :boolean;
    _prop_Style          :TBrushStyle;
    _prop_Color          :TColor;
    _prop_BgColor        :TColor;
    _prop_LineColor      :TColor;
             
    _data_Bitmap       :THI_Event;
    _data_Region       :THI_Event;
    _data_LineWidth    :THI_Event;
    _data_LineHeight   :THI_Event;
    _data_Pattern      :THI_Event;
    _data_OffsetFill   :THI_Event;
    _data_Color        :THI_Event;
    _data_BgColor      :THI_Event;
    _data_LineColor    :THI_Event;
                         
    _event_onDraw      :THI_Event;
    _event_onInvert    :THI_Event;

    function  imgGetDC(var _Data:TData):boolean;
    procedure _work_doDrawSource(var _Data:TData; Index:word);
    procedure _work_doDraw(var _Data:TData; Index:word);
    procedure _work_doInvert(var _Data:TData; Index:word);    
    procedure _work_doUseOffsetFill(var _Data:TData; Index:word);
    procedure _work_doPatternStyle(var _Data:TData; Index:word);
    procedure _work_doStyle(var _Data:TData; Index:word);
    procedure _work_doOutline(var _Data:TData; Index:word);
    procedure _work_doTransparent(var _Data:TData; Index:word);
  end;

implementation

function THIRGN_Draw.imgGetDC;
var  bmp: PBitmap;
begin
  Result := true;
  case _prop_DrawSource of
   {dcBitmap}0:  begin
                   bmp := ReadBitmap(_Data,_data_Bitmap,nil);
                   if (bmp <> nil) and (not bmp.Empty) then
                      pDC := bmp.Canvas.Handle
                   else
                      Result := false;
                end;
   {dcHandle}1:  begin
                   glWnd := ReadInteger(_Data,_data_Bitmap,0);
                   pDC := GetDC(glWnd);
                end;
   {dcContext}2: pDC := ReadInteger(_Data,_data_Bitmap,0);
  end;
end;  

procedure THIRGN_Draw._work_doDraw;
var rgn      : HRGN;
    br       : HBRUSH;
    cl       : TColor;
    Pattern  : PBitmap; 
    p        : cardinal;
    dt       : TData;
    RgnDword : DWORD;
    RgnData  : PRgnData;
begin
   dt := _Data;
TRY
   if not ImgGetDC(_Data) then exit;
   rgn := ReadInteger(_Data, _data_Region);
   case _prop_UseOffsetFill of
    1: begin
        RgnDword := GetRegionData(rgn, 0, nil);
        if RgnDword > 0 then
         begin
          GetMem(RgnData, SizeOf(RgnData) * RgnDword);
          GetRegionData(rgn, RgnDword, RgnData);
          SetBrushOrgEx(pDC, RgnData.rdh.rcBound.Left, RgnData.rdh.rcBound.Top, nil);
          FreeMem(RgnData);
         end;
       end;
    2: begin
        p := cardinal(ReadInteger(_Data, _data_OffsetFill, 0));
        SetBrushOrgEx(pDC, smallint(p and $FFFF), smallint(p shr 16), nil)
       end;
   end; 
   if _prop_PatternStyle then
    begin
     Pattern := ReadBitmap(_Data,_data_Pattern);
     if not Assigned(Pattern) or Pattern.Empty then
       br := GetStockObject(NULL_BRUSH)
     else
       br := CreatePatternBrush(Pattern.Handle);
    end
   else
    begin
     cl := Color2RGB(ReadInteger(_Data,_data_Color,_prop_Color));
     if _prop_Style = bsSolid then
        br := CreateSolidBrush(cl)
     else if _prop_Style = bsClear then
        br := GetStockObject(NULL_BRUSH)
     else
       begin
        if _prop_Transparent then SetBkMode(pDC, TRANSPARENT)
         else
          begin
           SetBkMode(pDC, OPAQUE);
           SetBkColor(pDC, Color2RGB(ReadInteger(_Data,_data_bgColor,_prop_bgColor)));
          end;
        br := CreateHatchBrush(ord(_prop_Style) - 2, cl);
       end;
     end;    
   FillRgn(pDC, rgn, br);
   DeleteObject(br);
   if _prop_Outline then
    begin
     br := CreateSolidBrush(Color2RGB(ReadInteger(_Data,_data_LineColor,_prop_LineColor)));
     FrameRgn(pDC, rgn, br, ReadInteger(_Data, _data_LineWidth,_prop_LineWidth), ReadInteger(_Data, _data_LineHeight,_prop_LineHeight));
     DeleteObject(br);
    end;
FINALLY
   if _prop_DrawSource = 1 then ReleaseDC(glWnd, pDC); {dcHandle}
   _hi_CreateEvent(_Data,@_event_onDraw,dt);
END;
end;

procedure THIRGN_Draw._work_doInvert;
var rgn: HRGN;
begin
    rgn := ReadInteger(_Data, _data_Region);
TRY
    if not ImgGetDC(_Data) then exit;
    InvertRgn(pDC, rgn);
FINALLY
    if _prop_DrawSource = 1 then ReleaseDC(glWnd, pDC);   {dcHandle}
    _hi_CreateEvent(_Data,@_event_onInvert, integer(rgn));
END;
end;

procedure THIRGN_Draw._work_doDrawSource;
begin
   _prop_DrawSource := ToInteger(_Data);
end;

procedure THIRGN_Draw._work_doPatternStyle;
begin
   _prop_PatternStyle := ReadBool(_Data);
end;

procedure THIRGN_Draw._work_doStyle;
var
  tmp: Integer;
begin
  tmp := ToInteger(_Data);
  case tmp of
    0: tmp := 1;
    1: tmp := 0;
  end;
  _prop_Style := TBrushStyle(tmp);
end;

procedure THIRGN_Draw._work_doUseOffsetFill;
begin
   _prop_UseOffsetFill := ToInteger(_Data);
end;

procedure THIRGN_Draw._work_doOutline;
begin
   _prop_Outline := ReadBool(_Data);
end;

procedure THIRGN_Draw._work_doTransparent;
begin
   _prop_Transparent := ReadBool(_Data);
end;

end.