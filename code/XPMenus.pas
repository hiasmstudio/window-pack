unit XPMenus; { основной юнит MenuXP ver 5.10}

interface

uses Windows, Messages, Kol, Share, Debug;

type TXPMenu = class(Tdebug)
  protected
    FC:                PControl;
    Menu:              PMenu;
    Old:               TOnMessage;
    _Arr,_IdxArr:      PArray;
    Matrix:            PMatrix;
    IconsIdx:          TIconsIdx;
    IconsIdxArray:     Array of Array of integer;
    FImgSize:          integer;
    FShift:            integer;
    GFont:             PGraphicTool;
    DFont:             TFontRec;
    FGutterColorLight: TColor;
    FGutterColorDark:  TColor;
    FBackColor:        TColor;
    FBackColorImage:   TColor;
    FSelColorLight:    TColor;
    GSelColorLight:    TColor;
    FSelColorDark:     TColor;
    FSelLightColor:    TColor;
    FCheckColor:       TColor;
    FSelCheckColor:    TColor;
    FSelColorText:     TColor;
    FMinWidth:         Integer;
    FMinHeight:        Integer;
    FvtOffset:         Integer;
    FIsPopup:          boolean;
    FFlatSelect:       boolean;
    FLongSepar:        boolean;
    FBumpText:         boolean;
    FBmpCheck:         PBitmap;
    FBmpRadio:         PBitmap;
    FleftBmpImage:     PBitmap;
    DbSeparator:       boolean;
    FadWidth:          word;
    FLineStyle:        byte;
    FAutoBackClrImg:   boolean;
    FLineOn:           boolean;
    FFrame:            boolean;
    fEndItemRight:     boolean;
    fIconByIndex:      boolean;

    procedure _Add(var Val:TData);
    procedure _Set(var Item: TData; var Val: TData);
    function _Get(Var Item: TData; var Val: TData): boolean;
    function _Count:integer;
    procedure SetFontRec(Value: TFontRec);
    procedure SetSelColorLight(const Value: TColor);
    procedure SetPicture(Value: HBITMAP);
    function  TextExtent(const Text: string): TSize;
    procedure InitCheckBmp;
    procedure InitRadioBmp;
    procedure IBitmaps(const Value:PStrListEx; var Arr:PArray);
    procedure SetIBitmaps(const Value:PStrListEx);
    procedure TFontToGFont(Font:TFontRec; grFont:PGraphicTool);
    procedure MX_Set(x,y:integer; var Val:TData);
    function MX_Get(x,y:integer):TData;
    function _mRows:integer;
    function _mCols:integer;
    function IndexToStr(idx:integer; s: string):string;
    
  public

    _event_MenuItemIdx:THI_Event;
    _event_MenuItemName:THI_Event;
    _event_onKeyDown:THI_Event;
    _event_onSelectItem:THI_Event;
    _event_onNameItems:THI_Event;
    _event_onCheckItems:THI_Event;
    _event_onVisibleItems:THI_Event;
    _event_onEnabledItems:THI_Event;
    _event_onEndPopup:THI_Event;
    _data_Bitmaps:THI_Event;
    _data_Index:THI_Event;
    _prop_Index:integer;

    function  _OnMes( var Msg: TMsg; var Rslt: Integer ): Boolean;
    procedure _OnMenuItem(Sender:PMenu;ItemIdx:integer);
    function  _MeasureItem(Sender: PObj;  Idx: Integer): Integer;
    function  _DrawItem(Sender: PObj; DC: HDC; const Rect: TRect;
     ItemIdx: Integer; DrawAction: TDrawAction; ItemState: TDrawState): Boolean;

    property _prop_LineColorLight:  TColor     read fGutterColorLight write fGutterColorLight;
    property _prop_LineColorDark:   TColor     read fGutterColorLight write FGutterColorDark;
    property _prop_BackColor:       TColor     read FBackColor write FBackColor;
    property _prop_BackColorImage:  TColor     read FBackColorImage write FBackColorImage;
    property _prop_SelColorLight:   TColor     read GSelColorLight write SetSelColorLight;
    property _prop_SelColorDark:    TColor     read FSelColorDark write FSelColorDark;
    property _prop_CheckColor:      TColor     read FCheckColor write FCheckColor;
    property _prop_SelCheckColor:   TColor     read FSelCheckColor write FSelCheckColor;
    property _prop_SelColorText:    TColor     read FSelColorText write FSelColorText;
    property _prop_LineStyle:       byte       read FLineStyle write FLineStyle;
    property _prop_Font:            TFontRec   read DFont write SetFontRec;
    property _prop_FlatSelect:      boolean    read fFlatSelect write fFlatSelect;
    property _prop_BumpText:        boolean    read fBumpText write fBumpText;
    property _prop_LongSeparator:   boolean    read FLongSepar write FLongSepar;
    property _prop_Shift:           integer    read FShift write FShift;
    property _prop_ImgSize:         integer    read FImgSize write FImgSize;
    property _prop_AutoBackClrImg:  boolean    read fAutoBackClrImg write fAutoBackClrImg;
    property _prop_vtOffset:        integer    read FvtOffset write FvtOffset;
    property _prop_adWidth:         word       read FadWidth write FadWidth;
    property _prop_Bitmaps:         PStrListEx write SetIBitmaps;
    property _prop_PictureLeft:     HBITMAP    write SetPicture;
    property _prop_GutterLineOn:    boolean    read fLineOn write fLineOn;
    property _prop_Frame:           boolean    read fFrame write fFrame;

    property  ItemHeight:           Integer    read FMinHeight write FMinHeight;
    property  ItemWidth:            Integer    read FMinWidth write FMinWidth;

    procedure SetPopUp(const Value:string);
    procedure SetMain(const Value:string);

    procedure _work_doLineColorLight(var _Data:TData; Index:word);
    procedure _work_doLineColorDark (var _Data:TData; Index:word);
    procedure _work_doSelColorLight (var _Data:TData; Index:word);
    procedure _work_doSelColorDark  (var _Data:TData; Index:word);
    procedure _work_doBackColor     (var _Data:TData; Index:word);
    procedure _work_doBackColorImage(var _Data:TData; Index:word);
    procedure _work_doCheckColor    (var _Data:TData; Index:word);
    procedure _work_doSelCheckColor (var _Data:TData; Index:word);
    procedure _work_doSelColorText  (var _Data:TData; Index:word);
    procedure _work_doLineStyle     (var _Data:TData; Index:word);
    procedure _work_doFlatSelect    (var _Data:TData; Index:word);
    procedure _work_doBumpText      (var _Data:TData; Index:word);
    procedure _work_doFont          (var _Data:TData; Index:word);
    procedure _work_doLongSeparator (var _Data:TData; Index:word);
    procedure _work_doPictureLeft   (var _Data:TData; Index:word);
    procedure _work_doGutterLineOn  (var _Data:TData; Index:word);
    procedure _work_doShift         (var _Data:TData; Index:word);
    procedure _work_doFrame         (var _Data:TData; Index:word);

    procedure _work_doNameItems     (var _Data:TData; Index:word);
    procedure _work_doCheckItems    (var _Data:TData; Index:word);
    procedure _work_doVisibleItems  (var _Data:TData; Index:word);
    procedure _work_doEnabledItems  (var _Data:TData; Index:word);
    procedure _work_doCheckIdx      (var _Data:TData; Index:word);
    procedure _work_doEnablIdx      (var _Data:TData; Index:word);
    procedure _work_doVisiblIdx     (var _Data:TData; Index:word);
    procedure _work_doHighlight     (var _Data:TData; Index:word);

    procedure _work_doIdxCheck      (var _Data:TData; Index:word);
    procedure _work_doIdxEnabled    (var _Data:TData; Index:word);
    procedure _work_doIdxVisible    (var _Data:TData; Index:word);
    procedure _work_doIdxHighlight  (var _Data:TData; Index:word);

    procedure _work_doClear         (var _Data:TData; Index:word);
    procedure _work_doInit          (var _Data:TData; Index:word);
    procedure _work_doInitBmp       (var _Data:TData; Index:word);
    procedure _work_doPopup         (var _Data:TData; Index:word);
    procedure _work_doPopupHere     (var _Data:TData; Index:word);

    procedure _var_Array            (var _Data:TData; Index:word);
    procedure _var_Handle           (var _Data:TData; Index:word);
    procedure _var_Count            (var _Data:TData; Index:word);
    procedure _var_Matrix           (var _Data:TData; Index:word);

    constructor Create(Control:PControl);
    destructor  Destroy; override;
    procedure   InitMenu(const Value:string);
    procedure   DrawXPstyle;
  end;

implementation

procedure TXPMenu._work_doSelColorLight; begin SetSelColorLight(ToInteger(_Data));end;
procedure TXPMenu._work_doLineColorLight;begin FGutterColorLight:=ToInteger(_Data);end;
procedure TXPMenu._work_doLineColorDark; begin FGutterColorDark :=ToInteger(_Data);end;
procedure TXPMenu._work_doSelColorDark;  begin fSelColorDark    :=ToInteger(_Data);end;
procedure TXPMenu._work_doBackColor;     begin fBackColor       :=ToInteger(_Data);end;
procedure TXPMenu._work_doCheckColor;    begin fCheckColor      :=ToInteger(_Data);end;
procedure TXPMenu._work_doSelCheckColor; begin fSelCheckColor   :=ToInteger(_Data);end;
procedure TXPMenu._work_doSelColorText;  begin fSelColorText    :=ToInteger(_Data);end;
procedure TXPMenu._work_doLineStyle;     begin fLineStyle       :=ToInteger(_Data);end;
procedure TXPMenu._work_doShift;         begin fShift           :=ToInteger(_Data);end;
procedure TXPMenu._work_doFlatSelect;    begin fFlatSelect      :=Readbool(_Data) ;end;
procedure TXPMenu._work_doBumpText;      begin fBumpText        :=Readbool(_Data) ;end;
procedure TXPMenu._work_doLongSeparator; begin fLongSepar       :=Readbool(_Data) ;end;
procedure TXPMenu._work_doGutterLineOn;  begin fLineOn          :=Readbool(_Data) ;end;
procedure TXPMenu._work_doFrame;         begin fFrame           :=Readbool(_Data) ;end;
procedure TXPMenu._work_doBackColorImage;begin If not fAutoBackClrImg then fBackColorImage:= ToInteger(_Data);end;

procedure TXPMenu._work_doPictureLeft;
begin
   if not _IsBitmap(_Data) then exit;
   fleftBmpImage.Assign(PBitmap(_data.idata));
   if fAutoBackClrImg then
     fBackColorImage:= fleftBmpImage.DIBPixels[0,0];
end;

type

  AGRBQuad = array [0..0] of RGBQuad;
  PAGRBQuad = ^AGRBQuad;

  PPoints = ^TPoints;
  TPoints = array[0..0] of TPoint;

function GetLightColor(Color: TColor; Light: Byte) : TColor;
var   fFrom: TRGB;
begin
  PColor(@fFrom)^:= Color2RGB(Color);
  Result := RGB(
    (FFrom.R*100 + (255 - FFrom.R) * Light) div 100,
    (FFrom.G*100 + (255 - FFrom.G) * Light) div 100,
    (FFrom.B*100 + (255 - FFrom.B) * Light) div 100
  );
end;

function GetShadeColor(Color: TColor; Shade: Byte) : TColor;
var   fFrom: TRGB;
begin
  PColor(@fFrom)^:= Color2RGB(Color);
  Result := RGB(
    Max(0, FFrom.R - Shade),
    Max(0, FFrom.G - Shade),
    Max(0, FFrom.B - Shade)
  );
end;

//****************************** Градиент **************************************
  
type
  COLOR16 = $0000..$FF00;
  TTriVertex = packed record
    x, y: DWORD;
    Red, Green, Blue, Alpha: COLOR16;
  end;
function GradientFill(DC: HDC; Vertex: Pointer; NumVertex: Cardinal;
                      Mesh: Pointer; NumMesh, Mode: DWORD): BOOL; stdcall;
                      external 'msimg32.dll' name 'GradientFill';

procedure _Gradient(DC:HDC; cbRect:TRect; Gradient:boolean; DepthGradient:integer;
                    StartColor,EndColor,ColorFrame:TColor; Frame,Horizontal,InversGrad:boolean);
var   vert: array[0..1] of TTriVertex;
      gRect : TGradientRect;
      FBr1  : HBrush;
      Color : TColor;
begin
   StartColor := Color2RGB(StartColor);
   EndColor := Color2RGB(EndColor); 
   if Gradient then
      StartColor:= GetLightColor(StartColor, max(0,min(100,DepthGradient)))
   else
      EndColor := StartColor; 

   if InversGrad then begin
      Color := EndColor;
      EndColor := StartColor;
      StartColor := Color;
   end;

   if Frame then begin
      vert[0].x      := cbRect.Left + 1;
      vert[0].y      := cbRect.Top + 1;
      vert[1].x      := cbRect.Right - 1;
      vert[1].y      := cbRect.Bottom - 1;
      FBr1 := CreateSolidBrush(Color2RGB(ColorFrame));
      FillRect(DC, cbRect, FBr1);
      DeleteObject(FBr1);
   end else begin
      vert[0].x      := cbRect.Left;
      vert[0].y      := cbRect.Top;
      vert[1].x      := cbRect.Right;
      vert[1].y      := cbRect.Bottom;
   end;

   vert[0].Red    := GetRValue(StartColor) shl 8;
   vert[0].Green  := GetGValue(StartColor) shl 8;
   vert[0].Blue   := GetBValue(StartColor) shl 8;
   vert[0].Alpha  := $0000; // ???
   vert[1].Red    := GetRValue(EndColor) shl 8;
   vert[1].Green  := GetGValue(EndColor) shl 8;
   vert[1].Blue   := GetBValue(EndColor) shl 8;
   vert[1].Alpha  := $0000; // ???
   
   gRect.UpperLeft  := 0;
   gRect.LowerRight := 1;

   if Horizontal then
      GradientFill(DC, @vert, 2, @gRect, 1, GRADIENT_FILL_RECT_H)
   else
      GradientFill(DC, @vert, 2, @gRect, 1, GRADIENT_FILL_RECT_V);

end;

//******************************************************************************

procedure TXPMenu._OnMenuItem;
begin
   _hi_OnEvent(_event_MenuItemName,Menu.Items[ItemIdx].Caption);
   _hi_OnEvent(_event_MenuItemIdx,ItemIdx);
end;

procedure TXPMenu.TFontToGFont;
begin
   GrFont.Color:= Font.Color;
   Share.SetFont(GrFont,Font.Style);
   GrFont.FontName:= Font.Name;
   GrFont.FontHeight:= _hi_SizeFnt(Font.Size);
   GrFont.FontCharset:= Font.CharSet;
end;

{$ifdef F_P}
var ListMenu: array[0..200] of PChar;
{$endif}

procedure TXPMenu.InitMenu(const Value:string);
var   i,j:integer;
      s:string;
      ListMenuStr: array  of string;
      List:PStrList;
      {$ifndef F_P}
      ListMenu: array of PChar;
      {$endif}
begin
   {$ifdef F_P}
   FillChar(ListMenu, sizeof(ListMenu), 0);
   {$endif}
   List := NewStrList;
   List.text := Value;
   if List.Count > 0 then begin
   TRY
      i := List.Count-1;
      repeat
         if List.items[i] = '' then List.Delete(i);
         dec(i);
      until i < 0;
      if List.Count = 0 then exit;
      SetLength(ListMenuStr,List.Count);
      {$ifndef F_P}
      SetLength(ListMenu,List.Count);
      {$endif}
      for i := 0 to List.Count-1 do
         if List.Items[i] <> '' then begin
            ListMenuStr[i] := List.Items[i];
            ListMenu[i] := PChar(@ListMenuStr[i][1]);
         end;
   FINALLY
      List.free;
   END;
   end;

  Menu:= NewMenu(FC, 0, ListMenu, _OnMenuItem);

  if Assigned(GFont) then GFont.free;
  GFont := NewFont;
  TFontToGFont(DFont, GFont);

  FBmpCheck.free;
  FBmpRadio.free;
  FleftBmpImage:= NewBitmap(0, 0);

  if Menu.Count <> 0 then begin
     SetLength(IconsIdx,3);
     SetLength(IconsIdxArray, Menu.Count, Length(IconsIdx));
     if fIconByIndex then begin
        for i := 0 to Menu.Count - 1 do begin
           s := Menu.ItemText[i];
           ParseIconsIdx(s,IconsIdx,true);
           for j:=0 to High(IconsIdx) do IconsIdxArray[i][j] := IconsIdx[j];
           Menu.ItemText[i] := s;
        end;
     end;
     if fEndItemRight then begin
        i := Menu.ItemHandle[Menu.ParentItem(Menu.Count-1)];
        if i = 0 then i := Menu.ItemHandle[Menu.Count-1];
        ModifyMenu(Menu.Handle, i, MF_BYCOMMAND or MF_HELP, i, PChar(Menu.ItemText[Menu.Count-1]));
     end;
  end;
  DrawXPStyle;
end;

function TXPMenu._OnMes;
var
  p:PMenu;
  m:TMenuItemInfo;
  function TestMenu(i:dword):boolean;
  begin
    m.cbSize := MenuStructSize;//sizeof(TMenuItemInfo);
    m.fMask := MIIM_ID;
    Result := GetMenuItemInfo(Msg.lParam,i,true,PMenuitemInfo(@m)^);
    p := Menu.Items[m.wID];
    Result := Result and (p<>nil);
  end;
begin
  case Msg.message of
    WM_MENUCHAR:
      if (HIWORD(Msg.wParam)=MF_POPUP)and TestMenu(0) then
        _hi_OnEvent(_event_onKeyDown,char(LOWORD(Msg.wParam)));//MenuChar
    WM_MENUSELECT:
      if ((HIWORD(Msg.wParam)and MF_POPUP)<>0) then begin
        if TestMenu(LOWORD(Msg.wParam)) then
          _hi_OnEvent(_event_onSelectItem,Menu.IndexOf(p));
      end else begin
        p := Menu.Items[LOWORD(Msg.wParam)];
        if (p<>nil) then
          _hi_OnEvent(_event_onSelectItem,Menu.IndexOf(p));
      end;
  end;
  Result := Old(Msg,Rslt);
end;

procedure DrawBmp(Var bmp: PBitmap; const ArrBMP: array of word; CheckColor:TColor);
var   i,j: Byte;
      row: PAGRBQuad;
      x:word;
begin
   with bmp{$ifndef F_P}^{$endif} do begin
      if CheckColor=clWhite then Canvas.Brush.Color := clBlack else Canvas.Brush.Color := clWhite;
      Canvas.FillRect(MakeRect(0, 0, Width, Height));
      for j:=0 to Height-1 do begin
         row:=ScanLine[j];  x:=ArrBMP[j];
         for i:=0 to Width-1 do begin
            if (x and 2048)=2048 then row[i]:=Color2RGBQuad(CheckColor);
            x:=x shl 1;
         end;
      end;
   end;
end;

procedure TXPMenu.InitCheckBmp;
const   CheckBMP: array[0..11] of word=(1,3,7,2063,3103,3646,3964,4088,2032,992,448,128);
begin
   FBmpCheck:=NewDIBBitmap(12,12,pf32bit);
   DrawBmp(FBmpCheck, CheckBMP, FCheckColor);
end;

procedure TXPMenu.InitRadioBmp;
const   RadioBMP: array[0..11] of word=(0,0,496,1016,2044,2044,2044,2044,2044,1016,496,0);
begin
   FBmpRadio:=NewDIBBitmap(12,12,pf32bit);
   DrawBmp(FBmpRadio, RadioBMP, FCheckColor);
end;

function TXPMenu.TextExtent(const Text: string): TSize;
var   DC: HDC;
begin
   DC := CreateCompatibleDC( 0 );
   SelectObject(DC, GFont.Handle);
   GetTextExtentPoint32( DC, PChar(Text), Length(Text), Result);
   DeleteDC(DC);
end;

constructor TXPMenu.Create;
begin
   inherited Create;
   FC:= Control;
   old:= FC.OnMessage;
   FC.OnMessage := _OnMes;
end;

destructor TXPMenu.Destroy;
begin
   GFont.free;
   FBmpCheck.free;
   FBmpRadio.free;
   fleftBmpImage.free;
   if _Arr <> nil then Dispose(_Arr);
   if _IdxArr <> nil then Dispose(_IdxArr);
   inherited Destroy;
end;

procedure TXPMenu.DrawXPstyle;
var   i:integer;
begin
   DbSeparator:= true;
   for i:=0 to Menu.Count - 1 do begin
      with Menu.Items[i]{$ifndef F_P}^{$endif} do begin
         OwnerDraw := false;
         OnMeasureItem := _MeasureItem;
         OnDrawItem := _DrawItem;
         OwnerDraw := true;
      end;
   end;
end;

//собственно отрисовка-c
function  TXPMenu._DrawItem(Sender: PObj; DC: HDC; const Rect: TRect; ItemIdx: Integer;
                            DrawAction: TDrawAction; ItemState: TDrawState): Boolean;

var BitmapSize:tagBITMAP;
    aBrush, aPen, aFont: PGraphicTool;
    i:byte;
    BMP:PBitmap;
    oldBrush:HBrush;
    oldPen:HPen;
    oldFont:HFont;
    GutterWidth, PictWidth:Integer;
    TopLevel:boolean;
    ARect,BRect:TRect;
    _Color:TColor;
    k,l :integer;
    c:byte;
    fFrom: TRGB;
    EmptyBMP:boolean;

  function GetGutterWidth(IsLine: Boolean): Integer;
  begin
     with PMenu(Sender){$ifndef F_P}^{$endif} do begin
        if Pointer(Bitmap)<>nil then begin
           Result := Max(BitmapSize.bmWidth + 4, Rect.Bottom - Rect.Top);
           if IsLine then
              Result := Max(Result, TextExtent(Caption).cy  + 7);
        end else
           if IsLine then
              Result := TextExtent(Caption).cy  + 7
           else
              Result := Rect.Bottom - Rect.Top + 3;
     end;
     Result := Max(Result, ItemHeight) + 1;
  end;

procedure MyPolyline(DC: HDC;const Points: array of TPoint);
begin
  Polyline(DC, PPoints(@Points)^, High(Points) + 1);
end;

const
  //текстовые флаги
  _Flags: LongInt = DT_NOCLIP or DT_VCENTER or DT_END_ELLIPSIS or DT_SINGLELINE;
  _FlagsTopLevel: array[Boolean] of Longint = (DT_LEFT, DT_CENTER);
  _FlagsShortCut: Longint = (DT_RIGHT);

begin

  with PMenu(Sender){$ifndef F_P}^{$endif} do begin
    if (FleftBmpImage <> nil) and (TopParent.IndexOf( Parent )=-1) then PictWidth:= FleftBmpImage.Width else PictWidth:= 0;
    if Pointer(Bitmap)<>nil then
       GetObject(Bitmap , sizeof(tagBITMAP), @BitmapSize);
    if fLineOn then GutterWidth:=GetGutterWidth(IsSeparator) else GutterWidth:=0;
    TopLevel:=(TopParent.IndexOf( Parent )=-1) and not FIsPopup;
    aBrush:=NewBrush;
    aPen:=NewPen;
    aFont:=NewFont;

    oldPen:=SelectObject(DC,aPen.Handle);
    oldBrush:=SelectObject(DC,aBrush.Handle);
    if (odsSelected in ItemState) then begin //если пункт меню выделен
       if TopLevel then                  //если это полоска основного меню
          _Gradient(DC,Rect,true,0,FSelColorDark,FSelColorLight,GetShadeColor(FSelColorDark,150),fFrame,false,false)
       else if not (odsDisabled in ItemState) then //если мышь над пунктом подменю
          _Gradient(DC,MakeRect(Rect.Left+PictWidth,Rect.Top,Rect.Right,Rect.Bottom),not FFlatSelect,0,
                    FSelColorDark,FSelColorLight,GetShadeColor(FSelColorDark,150),fFrame,false,true)
    end else if TopLevel then            //если это полоска основного меню
       if (odsHotList in ItemState) then //если мышь над пунктом основного меню
          _Gradient(DC,Rect,true,0,FSelColorDark,FSelColorLight,GetShadeColor(FSelColorDark,150),FFrame,false,true)
       else begin
          aBrush.Color := clBtnFace;
          FillRect(DC,Rect,aBrush.Handle);
       end
    else begin                           //ничем не примечательный пункт меню
       _Gradient(DC,MakeRect(Rect.Left+PictWidth,Rect.Top,Rect.Left+PictWidth+GutterWidth,Rect.Bottom),true,0,
                 FGutterColorDark,FGutterColorLight,0,false,true,not boolean(FLineStyle));
        aBrush.Color := FBackColor;
        FillRect(DC,MakeRect(Rect.Left + PictWidth + GutterWidth, Rect.Top, Rect.Right, Rect.Bottom),aBrush.Handle);
        aBrush.Color := FBackColorImage;
        FillRect(DC,MakeRect(Rect.Left, Rect.Top, Rect.Left + PictWidth, Rect.Bottom),aBrush.Handle);
    end;

    if (odsChecked in ItemState) and (not TopLevel) and Checked and fLineOn then begin // подсвечиваем чекнутый пункт меню
       if (Pointer(Bitmap) = nil) then aPen.Color := GetShadeColor(FSelColorDark, 150)
       else aPen.Color := GetShadeColor(FSelColorDark, 75);
       SelectObject(DC,aPen.Handle);
       if (odsSelected in ItemState) then  aBrush.Color :=  GetShadeColor(FSelCheckColor, 40)
       else aBrush.Color := FSelCheckColor;
       SelectObject(DC,aBrush.Handle);
       if (Pointer(Bitmap) = nil) then Rectangle(DC,(PictWidth + Rect.Left + 3), (Rect.Top + 1), (PictWidth + Rect.Left - 3 + GutterWidth), (Rect.Bottom - 1))
       else Rectangle(DC,(PictWidth + Rect.Left + 1), (Rect.Top + 1), (PictWidth + Rect.Left + GutterWidth - 2), (Rect.Bottom - 1));
    end;

    if (Pointer(Bitmap) <> nil) and (not TopLevel) and not IsSeparator and fLineOn then begin
       BMP:=NewDIBBitmap(BitmapSize.bmWidth ,BitmapSize.bmHeight, pf24bit);
       BMP.Handle:=CopyImage(Bitmap,IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION);
       BMP.PixelFormat:= pf24bit;
       if (odsDisabled in ItemState) then //рисуем погасшую картинку
           for k:=0 to BMP.width-1 do
             for l:=0 to BMP.height-1 do begin
                PColor(@fFrom)^:= Color2RGB(BMP.DIBPixels[k,l]);
                with FFrom do c:=round(0.30*R+0.59*G+0.11*B);
                BMP.DIBPixels[k,l]:=GetLightColor(RGB(c,c,c),30);
             end
          else if (odsChecked in ItemState) then begin
             EmptyBMP:=true;
             c:= BMP.DIBPixels[0,0];
             k:=0; Repeat
                l:=0; Repeat
                   if c <> BMP.DIBPixels[k,l] then EmptyBMP:=false;
                   inc(l);
                Until (l = BMP.height) or (EmptyBMP = false);
                inc(k);
             Until (k = BMP.width) or (EmptyBMP = false);
             if EmptyBMP and (RadioGroup <> 0) then begin
                if FBmpRadio=nil then InitRadioBmp;
                FBmpRadio.DrawTransparent(DC,1 + (2*PictWidth + Rect.Left + GutterWidth - 1 - FBmpRadio.Width) shr 1,
                                          (Rect.Top + Rect.Bottom - FBmpRadio.Height) shr 1,FBmpRadio.DIBPixels[0,0]);
             end else if EmptyBMP then begin
                if FBmpCheck=nil then InitCheckBmp;
                FBmpCheck.DrawTransparent(DC, (2*PictWidth + Rect.Left + GutterWidth - 1 - FBmpCheck.Width) shr 1,
                                          (Rect.Top + Rect.Bottom - FBmpCheck.Height) shr 1,FBmpCheck.DIBPixels[0,0]);
             end;
          end;
          bmp.DrawTransparent(DC, (Rect.Left + 2*PictWidth + GutterWidth - BitmapSize.bmWidth ) shr 1,
                              (Rect.Top + Rect.Bottom - BitmapSize.bmHeight ) shr 1, Bmp.DIBPixels[0,0]);
          BMP.free;
       end
    else if (not TopLevel) and (odsChecked in ItemState) and (RadioGroup <> 0) and fLineOn then begin
       if FBmpRadio=nil then InitRadioBmp;
       FBmpRadio.DrawTransparent(DC,1 + (2*PictWidth + Rect.Left + GutterWidth - 1 - FBmpRadio.Width) shr 1,
                                 (Rect.Top + Rect.Bottom - FBmpRadio.Height) shr 1,FBmpRadio.DIBPixels[0,0]);
    end else if (odsChecked in ItemState) and fLineOn then begin
       if FBmpCheck=nil then InitCheckBmp;
       FBmpCheck.DrawTransparent(DC,1 + (2*PictWidth + Rect.Left + GutterWidth - 1 - FBmpCheck.Width) shr 1,
                                 (Rect.Top + Rect.Bottom - FBmpCheck.Height) shr 1,FBmpCheck.DIBPixels[0,0]);
    end;
    ARect:=Rect;
    if not TopLevel and not IsSeparator then Inc(ARect.Left, PictWidth + GutterWidth + 5); //отступ для текста
    aFont.Assign(GFont);

    with aFont{$ifndef F_P}^{$endif} do begin
       if (odsDefault in ItemState) then FontStyle := [fsBold];
       if (odsDisabled in ItemState) then Color := clGray
       else if (TopLevel and (odsHotList in ItemState)) or (odsSelected in ItemState) then Color:= FSelColorText
    end;
    oldFont:=SelectObject(DC,aFont.Handle);

    if IsSeparator and not DbSeparator then begin //если разделитель
       aPen.Color := GetShadeColor(FGutterColorDark, 40);
       SelectObject(DC,aPen.Handle);
       if FLongSepar then
          MyPolyline(DC,[MakePoint(PictWidth + 2, ARect.Top + (ARect.Bottom - ARect.Top) shr 1),
                     MakePoint(Rect.Right - 2, ARect.Top + (ARect.Bottom - ARect.Top) shr 1)])
       else
          MyPolyline(DC,[MakePoint(PictWidth + GutterWidth + 5, ARect.Top + (ARect.Bottom - ARect.Top) shr 1),
                     MakePoint(Rect.Right - 2, ARect.Top + (ARect.Bottom - ARect.Top) shr 1)]);
    end else if not IsSeparator then begin        //текст меню
       i:=1; while (i<=Length(Caption)) and (Caption[i]<>#9) do inc(i);
       SetBkMode(DC, TRANSPARENT);
       _Color:=GetLightColor(FSelColorDark,90);
       BRect:=ARect;

       inc(BRect.Right);
       inc(BRect.Left);
       inc(BRect.Top);
       inc(BRect.Bottom);

       SetTextColor(DC, _Color);
       if ((odsSelected in ItemState) or (TopLevel and (odsHotList in ItemState)))
           and not (odsDefault in ItemState) and (FSelColorDark <> FSelColorLight) and FBumpText then
           DrawText(DC,PChar(copy(Caption,1,i-1)),i-1,BRect,_Flags or _FlagsTopLevel[TopLevel]);
       SetTextColor(DC, aFont.Color);
       DrawText(DC,PChar(copy(Caption,1,i-1)),i-1,ARect,_Flags or _FlagsTopLevel[TopLevel]);
       if i < Length(Caption) then begin          //разпальцовка
          Dec(ARect.Right, 5);
          DrawText(DC,PChar(copy(Caption,i+1,Length(Caption)-i)),Length(Caption)-i,ARect,_Flags or _FlagsShortCut);
       end
    end;
    DeleteObject(SelectObject(DC, oldFont));   aFont.Free;
    DeleteObject(SelectObject(DC, oldBrush));  aBrush.Free;
    DeleteObject(SelectObject(DC, oldPen));    aPen.Free;
    if IsSeparator then DbSeparator:= true else DbSeparator:= false;
    if (TopParent.IndexOf( Parent )=-1) and (FleftBmpImage <> nil) then
       FleftBmpImage.Draw(DC, 0, FvtOffset);
  end;
  Result:=true;
end;

//размеры меню
function TXPMenu._MeasureItem(Sender: PObj;  Idx: Integer): Integer;
VAR Bound:integer;
    bb:packed record
      Height:word;
      Width:word;
      ShiftWidth:word;
    end absolute Bound;
    BitmapSize:tagBitmap;

begin

  with PMenu(Sender){$ifndef F_P}^{$endif} do
   if (TopParent.IndexOf( Parent )=-1) and not FIsPopup then begin
      bb.Width := TextExtent(Caption).cX;
      bb.Height := TextExtent(Caption).cY;
      bb.ShiftWidth := 0;
   end else begin
      if (FleftBmpImage <> nil) and (TopParent.IndexOf( Parent )=-1) then
         bb.ShiftWidth:= FleftBmpImage.Width
      else bb.ShiftWidth:= 0;
      if Pointer(Bitmap) <> nil then begin
         GetObject(Bitmap, sizeof(tagBITMAP), @BitmapSize);
         bb.Width := BitmapSize.bmWidth ;
         if IsSeparator then
            if Max(ItemHeight, BitmapSize.bmHeight ) > 20 then //при большем 20  узкая полоска некрасива
               bb.Height := 11 else bb.Height := 5
            else
               bb.Height := Max(ItemHeight, Max(TextExtent(Caption).cy , BitmapSize.bmHeight ) + 4);
         if bb.Width < bb.Height then bb.Width := bb.Height else bb.Width := bb.Width + 5;
         bb.Width := bb.ShiftWidth + Max(ItemWidth, bb.Width + TextExtent(Caption).cx + 15);
         if (FleftBmpImage <> nil) and (TopParent.IndexOf( Parent )=-1) then
            bb.Width:= bb.Width + FadWidth;
         if (TopParent.IndexOf( Parent )<>-1) and not FIsPopup then
            bb.Width:= bb.Width + FadWidth
      end else begin
         bb.Height := Max(TextExtent(Caption).cY + 4, ItemHeight);
         bb.Width := bb.ShiftWidth + Max(ItemWidth, bb.Height + TextExtent(Caption).cx  + 15) + FadWidth;
         bb.Width := bb.ShiftWidth + Max(ItemWidth, bb.Height + TextExtent(Caption).cx  + 15);
         if IsSeparator then
            if bb.Height > 20 then //при большем 20  узкая полоска некрасива
               bb.Height := 11 else bb.Height := 5;
      end;
   end;
  Result:=Bound;
end;

procedure TXPMenu.SetPopUp;
begin
  FIsPopup:=true;
  InitMenu('');
  InitMenu(Value);
end;

procedure TXPMenu.SetMain;
begin
  FIsPopup:=false;
  InitMenu(Value);
end;

procedure TXPMenu._work_doClear;
begin
  InitMenu('');
end;

procedure TXPMenu._work_doInit;
var str:string;
begin
  if not _IsStr(_Data) then exit;
  str:= ToString(_Data);
  InitMenu(str);
end;

procedure TXPMenu.IBitmaps;
var   i,j:integer;
      dt,Ind:TData;
      bmp:PBitmap;
      bmp_null:PBitmap;
      Icon:PIcon;

      procedure BmpStretch(M:PMenu);
      var   dst:PBitmap;
      begin
         if bmp.empty then
            M.Bitmap:= bmp_null.ReleaseHandle
         else begin
            dst := NewBitmap(FImgSize, FImgSize);
            SetStretchBltMode(dst.Canvas.Handle, HALFTONE);
            bmp.StretchDrawMasked(dst.Canvas.Handle, dst.BoundsRect, clFuchsia);
            M.Bitmap := dst.ReleaseHandle;
            dst.free;
         end;
      end;

begin
   bmp_null := NewBitmap(FImgSize, FImgSize);
   bmp      := NewBitmap(0, 0);
TRY
   if Arr = nil then
      if assigned(Value) and (Value.Count > 0) and (Menu.Count > 0) then begin
         i:=0;
         j:=FShift;
         repeat
            if ((not fIconByIndex) and (Menu.ItemText[i] = '')) or (fIconByIndex and (IconsIdxArray[i][0] = -2)) then
               bmp.Handle := bmp_null.ReleaseHandle
            else if (not fIconByIndex) then begin
               bmp.Handle := Value.Objects[j];
               inc(j);
            end else
               bmp.Handle := CopyImage(Value.Objects[IconsIdxArray[i][0]], IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION);
            BmpStretch(Menu.Items[i]);
            inc(i);
         until (i = Menu.Count);
      end else exit
   else if (Arr._Count > 0) and (Menu.Count > 0) then begin
      i:=0;
      j:=FShift;
      repeat
         if not fIconByIndex then begin
            Ind := _DoData(j);
            if (Menu.ItemText[i] <> '') then inc(j);
         end else
            Ind := _DoData(IconsIdxArray[i][0]);
         Arr._Get(Ind,dt);
         if ((not fIconByIndex) and (Menu.ItemText[i] = '')) or (fIconByIndex and (IconsIdxArray[i][0] = -2)) then
            bmp.Handle := bmp_null.ReleaseHandle
         else if _IsBitmap(dt) then
            bmp.assign(PBitmap(dt.idata))
         else if _IsIcon(dt) then begin
            Icon:= NewIcon;
            Icon.Handle:= PIcon(dt.idata).Handle;
            bmp.Handle := Icon.Convert2Bitmap(clFuchsia);
            Icon.free;
         end else
            bmp.Handle := bmp_null.ReleaseHandle;
         BmpStretch(Menu.Items[i]);
         inc(i);
      until (i = Menu.Count);
   end;
FINALLY
   bmp_null.free;
   bmp.free;
END;
end;

procedure TXPMenu._work_doFont;
begin
   if _IsFont(_Data) then SetFontRec(pfontrec(_Data.idata)^);
end;

procedure TXPMenu.SetFontRec;
begin
  DFont:= Value;
  if Assigned(GFont) then GFont.free;
  GFont := NewFont;
  TFontToGFont(DFont, GFont);
end;

procedure TXPMenu.SetSelColorLight(const Value: TColor);
begin
  FSelColorLight := Value;
  GSelColorLight := FSelColorLight;
  FSelLightColor := GetLightColor(Value, 75);
end;

procedure TXPMenu._work_doInitBmp;
begin
   SetIBitmaps(nil);
   DrawXPStyle;
end;

procedure TXPMenu.SetIBitmaps;
var   Arr:PArray;
begin
   Arr := ReadArray(_data_Bitmaps);
   if Assigned(Value) then IBitmaps(Value, Arr) else IBitmaps(nil, Arr);
end;

procedure TXPMenu.SetPicture;
begin
   if Value = 0 then exit;
   fleftBmpImage.Handle := CopyImage(Value, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION);
   if not fAutoBackClrImg then exit;
   fBackColorImage:= fleftBmpImage.DIBPixels[0,0];
end;

//#####################################################################

procedure TXPMenu._work_doCheckIdx;
var   Idx:integer;
begin
   Idx:= ReadInteger(_Data,_data_Index,_prop_Index);
   if (Menu.Count > 0) and (Idx >= 0 ) and (Idx < Menu.Count) then
   if Menu.ItemChecked[Idx] then
      Menu.ItemChecked[Idx]:= false
   else
      Menu.RadioCheck(Idx);
end;

procedure TXPMenu._work_doEnablIdx;
var   Idx:integer;
begin
   Idx:= ReadInteger(_Data,_data_Index,_prop_Index);
   if (Menu.Count > 0) and (Idx >= 0 ) and (Idx < Menu.Count) then
      Menu.ItemEnabled[Idx]:= not Menu.ItemEnabled[Idx];
end;

procedure TXPMenu._work_doVisiblIdx;
var   Idx:integer;
begin
   Idx:= ReadInteger(_Data,_data_Index,_prop_Index);
   if (Menu.Count > 0) and (Idx >= 0 ) and (Idx < Menu.Count) then
      Menu.ItemVisible[Idx]:= not Menu.ItemVisible[Idx];
end;

procedure TXPMenu._work_doHighlight;
var   Idx:integer;
begin
   Idx:= ReadInteger(_Data,_data_Index,_prop_Index);
   if (Menu.Count > 0) and (Idx >= 0 ) and (Idx < Menu.Count) then
      Menu.Items[Idx].Highlight:= not Menu.Items[Idx].Highlight;
end;

//-----------------------------------------------------------------

procedure TXPMenu._work_doIdxEnabled;
var
  Idx: integer;
begin
  Idx := ReadInteger(_Data,_data_Index,_prop_Index);
  if (Menu.Count > 0) and (Idx >= 0 ) and (Idx < Menu.Count) then
    Menu.ItemEnabled[Idx] := ReadBool(_Data);
end;

procedure TXPMenu._work_doIdxVisible;
var
  Idx: integer;
begin
  Idx := ReadInteger(_Data,_data_Index,_prop_Index);
  if (Menu.Count > 0) and (Idx >= 0 ) and (Idx < Menu.Count) then
    Menu.ItemVisible[Idx] := ReadBool(_Data);
end;

procedure TXPMenu._work_doIdxHighlight;
var
   Idx: integer;
begin
  Idx := ReadInteger(_Data,_data_Index,_prop_Index);
  if (Menu.Count > 0) and (Idx >= 0 ) and (Idx < Menu.Count) then
    Menu.Items[Idx].Highlight := ReadBool(_Data);
end;

procedure TXPMenu._work_doIdxCheck;
var
  Idx: integer;
begin
  Idx := ReadInteger(_Data,_data_Index,_prop_Index);
  if (Menu.Count > 0) and (Idx >= 0 ) and (Idx < Menu.Count) then
  if ReadBool(_Data) then
    Menu.RadioCheck(Idx)
  else
    Menu.ItemChecked[Idx] := false;
end;

//#####################################################################

procedure TXPMenu._work_doNameItems;
var   i: Integer;
begin
   if Menu.Count > 0 then
      for i:=0 to Menu.Count-1 do _hi_onEvent(_event_onNameItems,Menu.ItemText[i]);
end;

procedure TXPMenu._work_doCheckItems;
var   i: Integer;
begin
   if Menu.Count > 0 then
      for i:=0 to Menu.Count-1 do
         if (Menu.ItemText[i] <> '') and Menu.ItemChecked[i] then
            _hi_onEvent(_event_onCheckItems,i);
end;

procedure TXPMenu._work_doVisibleItems;
var   i: Integer;
begin
   if Menu.Count > 0 then
      for i:=0 to Menu.Count-1 do
         if (Menu.ItemText[i] <> '') and Menu.ItemVisible[i] then
            _hi_onEvent(_event_onVisibleItems,i);
end;

procedure TXPMenu._work_doEnabledItems;
var   i: Integer;
begin
   if Menu.Count > 0 then
      for i:=0 to Menu.Count-1 do
         if (Menu.ItemText[i] <> '') and Menu.ItemEnabled[i] then
            _hi_onEvent(_event_onEnabledItems,i);
end;

//#########################   Переменные   ############################

procedure TXPMenu._var_Count;
begin
   dtInteger(_Data, Menu.Count);
end;

procedure TXPMenu._var_Handle;
begin
   dtInteger(_Data, Menu.ItemHandle[0]);
end;

//#####################################################################

function TXPMenu.IndexToStr;
const _dlm = ',';
var   sind:string;
      l:integer;
begin
   Result := s;
   if not fIconByIndex then exit;
   if IconsIdxArray[idx][0] < 0 then sind := _dlm else sind := int2str(IconsIdxArray[idx][0]) + _dlm;
   if IconsIdxArray[idx][1] < 0 then sind := sind + _dlm else sind := sind + int2str(IconsIdxArray[idx][1]) + _dlm;
   if IconsIdxArray[idx][2] >= 0 then sind := sind + int2str(IconsIdxArray[idx][2]);
   l := length(sind);
   repeat
      if sind[l] <> _dlm then Continue;
      delete(sind,l,1);
      dec(l);
   until (length(sind) = 0) or (sind[l] <> _dlm);
   if sind = '' then exit;
   Result := '<' + sind + '>' + s;
end;

procedure TXPMenu._Set(var Item:TData; var Val:TData);
var   j, ind:integer;
      s: string;
begin
   ind := ToInteger(Item);
   if (ind < 0) and (ind > Menu.Count-1) then exit;
   s := ToString(Val);
   if fIconByIndex then begin
      ParseIconsIdx(s,IconsIdx,true);
      for j:=0 to High(IconsIdx) do IconsIdxArray[ind][j] := IconsIdx[j];
   end;
   Menu.ItemText[ind] := s;
   _work_doInitBmp(Val,0);
end;

function TXPMenu._Get(Var Item:TData; var Val:TData):boolean;
var   ind:integer;
      s: string;
begin
   ind := ToInteger(Item);
   if (ind >= 0 ) and (ind < Menu.Count) then begin
      s := Menu.ItemText[ind];
      dtString(Val, IndexToStr(ind, s));
      Result := true;
   end else
      Result := false;
end;

function TXPMenu._Count:integer;
begin
   Result := Menu.Count;
end;

procedure TXPMenu._Add;
var   sdt:string;
      j:integer;
begin
   sdt := ToString(Val);
   if fIconByIndex then begin
      SetLength(IconsIdxArray, Length(IconsIdxArray)+1, Length(IconsIdx));
      ParseIconsIdx(sdt,IconsIdx,true);
      for j:=0 to High(IconsIdx) do IconsIdxArray[High(IconsIdxArray)][j] := IconsIdx[j];
      if sdt = '-' then Menu.AddItem('-',nil,[moSeparator])
      else Menu.AddItem(PChar(sdt),nil,[]);
   end else begin
      if sdt = '-' then Menu.AddItem('-',nil,[moSeparator])
      else Menu.AddItem(PChar(sdt),nil,[]);
   end;
   _work_doInitBmp(Val,0);
end;

procedure TXPMenu._var_Array;
begin
   if _Arr = nil then
      _Arr := CreateArray(_Set,_Get,_Count,_Add);
   dtArray(_Data, _Arr);
end;

//#####################################################################

//Matrix - Матрица индексов иконок
//
procedure TXPMenu._var_Matrix;
begin
   if not Assigned(Matrix) then begin
      New(Matrix);
      Matrix._Set  := MX_Set;
      Matrix._Get  := MX_Get;
      Matrix._Rows := _mRows;
      Matrix._Cols := _mCols;
   end;
   dtMatrix(_Data,Matrix);
end;

function TXPMenu.MX_Get;
begin
   if (x >= 0) and (x < Length(IconsIdx)) and (y >= 0) and (y < Length(IconsIdxArray)) then
      dtInteger(Result,IconsIdxArray[y][x])
   else dtNull(Result);
end;

procedure TXPMenu.MX_Set;
begin
   if (x < 0) or (x > High(IconsIdx)) or (y < 0) or (y > High(IconsIdxArray)) then exit;
   IconsIdxArray[y][x] := ToInteger(Val);
   _work_doInitBmp(Val,0);
end;

function TXPMenu._mRows;
begin
  Result := Length(IconsIdxArray);
end;

function TXPMenu._mCols;
begin
  Result := Length(IconsIdx);
end;

//#####################################################################

procedure TXPMenu._work_doPopup;
var   pos:cardinal;
begin
   if not FIsPopup then exit;
   pos := Cardinal(ToInteger(_data));
   TrackPopupMenu(Menu.Handle, 0, pos shr 16, pos and $ffff, 0, FC.Handle, nil);
   _hi_CreateEvent(_Data,@_event_onEndPopup);
end;

procedure TXPMenu._work_doPopupHere;
var   pos:TPoint;
begin
   if not FIsPopup then exit;
   GetCursorPos(pos);
   SetForegroundWindow(FC.Handle);
   with pos do
      TrackPopupMenu(Menu.Handle, 0, x, y, 0, FC.Handle, nil);
   _hi_CreateEvent(_Data,@_event_onEndPopup);
end;

//#####################################################################

end.