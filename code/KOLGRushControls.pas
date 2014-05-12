unit KOLGRushControls;
{* 
|<b>GRushControls</b> - Controls set with high quality of visulation and effects.
|<code><font color=#0000ff>
|<br>&nbsp;&nbsp;file: KOLGRushControls.pas
|<br>&nbsp;&nbsp;file version: 0.35
|<br>&nbsp;&nbsp;last modified: 14.02.06
|<br>&nbsp;&nbsp;author: Karpinskyj Alexandr aka homm
|<br>&nbsp;&nbsp;&nbsp;&nbsp;mailto:
|<a href="mailto:homm86@mail.ru">homm86@mail.ru</a>
|<br>&nbsp;&nbsp;&nbsp;&nbsp; My humble Web-Page:
|<a href="http://www.homm86.narod.ru">www.homm86.narod.ru</a>
|</code></font><hr><h2>Symbols of conditionally compilation.</h2>
Most common rule: All symbols by default are switched on. They are located on top of unit
KOLGRushControls.pas directly after this description.
Undefination of one of them makes code smaller and unsafely or less functionality.
|<br><br><b><code>MOSTCOMPATIBILITY</code></b><br>
Switch this define on to get most functionality code versilon. 
All folowing defination are ingoring.
|<br><br><b><code>ALLOW_GLYPH</code></b><br>
Allows use Glyphs.
|<br><br><b><code>ALLOW_ANTIALIASING</code></b><br>
Allows you use antialiasing.
|<br><br><b><code>ALLOW_CONTROLSTRANSPARANSY</code></b><br>
Force right processing Transparent property.
|<br><br><b><code>FIX_16BITMODE</code></b><br>
Fixes not glide gradient in Windows 2000/XP.
|<br><br><b><code>FIX_DRAWTRANSPARENT</code></b><br>
Use TransparentBlt instead of TBitmap.DrawTransparent in Windows 2000/XP. 
Incrase performance.
|<br><br><b><code>NOT_IMMIDIATLYONLY</code></b><br>
Allow use fading controls changing.
|<br><br><b><code>USE_MMX</code></b><br>
Allow use MMX for controls fading. Incrase performance a bit. 
(Matters only with previos defination)
}
{= 
|<b>GRushControls</b>
 - Элементы управления с высоким качества отображения и визуальных эффектов
|<code><font color=#0000ff>
|<br>&nbsp;&nbsp;файл: KOLGRushControls.pas
|<br>&nbsp;&nbsp;версия файла: 0.35
|<br>&nbsp;&nbsp;последнее изменение: 14.02.06
|<br>&nbsp;&nbsp;автор: Карпинский Александр aka homm
|<br>&nbsp;&nbsp;&nbsp;&nbsp;mailto:
|<a href="mailto:homm86@mail.ru">homm86@mail.ru</a>
|<br>&nbsp;&nbsp;&nbsp;&nbsp;моя скромная интернет страница:
|<a href="http://www.homm86.narod.ru">http://www.homm86.narod.ru</a>
|</code></font><hr><h2>Символы условной компиляции</h2>
Общее правило: по умолчанию все символы определены. Они находятся в начале файла
KOLGRushControls.pas сразу за этим описанием. Убирание любого из них уменьшает код,
и в зависимости от конкретного символа уменьшает функциональность или добовляет глюков.
|<br><br><b><code>MOSTCOMPATIBILITY</code></b><br>
Включить для получения наиболее функциональной версии. Все остальные символы 
определяются автоматически.
|<br><br><b><code>ALLOW_GLYPH</code></b><br>
Позволяет использовать картинки на контролах.
|<br><br><b><code>ALLOW_ANTIALIASING</code></b><br>
Позволяет сглаживать края бордюра.
|<br><br><b><code>ALLOW_CONTROLSTRANSPARANSY</code></b><br>
Заставляет контролы правильно понимать свойство Transparent.
|<br><br><b><code>FIX_16BITMODE</code></b><br>
Исправляет не плвный градиент в 16 битах палитры для Windows 2000/XP.
|<br><br><b><code>FIX_DRAWTRANSPARENT</code></b><br>
Использует TransparentBlt вместо TBitmap.DrawTransparent в Windows 2000/XP. 
Увеличивает производительность.
|<br><br><b><code>NOT_IMMIDIATLYONLY</code></b><br>
Включает плавное перетикание контролов при изменении состояния.
|<br><br><b><code>USE_MMX</code></b><br>
Использует MMX для альфа-смешивания. Слегка увеличивает проиводительность. 
(Имеет значение только если предидушее условие определено)
}

interface

uses    Windows,
        Messages,
        KOL; 
        
const
  LabelActions: TCommandActions = (
    aAddText: nil;
    aClick: 0;
    aEnter: 0;
    aLeave: 0;
    aChange: 0;
    aSelChange: 0;
    aGetCount: 0;
    aSetCount: 0;
    aGetItemLength: 0;
    aGetItemText: 0;
    aSetItemText: 0;
    aGetItemData: 0;
    aSetItemData: 0;
    aAddItem: 0;
    aDeleteItem: 0;
    aInsertItem: 0;
    aFindItem: 0;
    aFindPartial: 0;
    aItem2Pos: 0;
    aPos2Item: 0;
    aGetSelCount: 0;
    aGetSelected: 0;
    aGetSelRange: 0;
    aGetCurrent: 0;
    aSetSelected: 0;
    aSetCurrent: 0;
    aSetSelRange: 0;
    aExSetSelRange: 0;
    aGetSelection: 0;
    aReplaceSel: 0;
    aTextAlignLeft: SS_LEFT;
    aTextAlignRight: SS_RIGHT;
    aTextAlignCenter: SS_CENTER;
    aTextAlignMask: SS_LEFTNOWORDWRAP;
    aVertAlignCenter: SS_CENTERIMAGE shr 8;
    aVertAlignTop: 0;
    aVertAlignBottom: 0;
    aDir: 0;
    aSetLimit: 0;
    aSetImgList: 0;
    aAutoSzX: 1;
    aAutoSzY: 1;
    aSetBkColor: 0;
  );
const  
  ButtonActions: TCommandActions = (
    aAddText: nil;
    aClick: BN_CLICKED;
    aEnter: BN_SETFOCUS;
    aLeave: BN_KILLFOCUS;
    aChange: 0; //BN_CLICKED;
    aSelChange: 0;
    aGetCount: 0;
    aSetCount: 0;
    aGetItemLength: 0;
    aGetItemText: 0;
    aSetItemText: 0;
    aGetItemData: 0;
    aSetItemData: 0;
    aAddItem: 0;
    aDeleteItem: 0;
    aInsertItem: 0;
    aFindItem: 0;
    aFindPartial: 0;
    aItem2Pos: 0;
    aPos2Item: 0;
    aGetSelCount: 0;
    aGetSelected: 0;
    aGetSelRange: 0;
    aGetCurrent: 0;
    aSetSelected: 0;
    aSetCurrent: 0;
    aSetSelRange: 0;
    aExSetSelRange: 0;
    aGetSelection: 0;
    aReplaceSel: 0;
    aTextAlignLeft: BS_LEFT;
    aTextAlignRight: BS_RIGHT;
    aTextAlignCenter: BS_CENTER;
    aTextAlignMask: 0;
    aVertAlignCenter: BS_VCENTER shr 8;
    aVertAlignTop: BS_TOP shr 8;
    aVertAlignBottom: BS_BOTTOM shr 8;
    aDir: 0;
    aSetLimit: 0;
    aSetImgList: 0;
    aAutoSzX: 14;
    aAutoSzY: 6;
    aSetBkColor: 0;
  );
  
{$DEFINE ALLOW_GLYPH}
{$DEFINE ALLOW_ANTIALIASING}
{$DEFINE ALLOW_CONTROLSTRANSPARANSY}
{$DEFINE FIX_16BITMODE}
{$DEFINE FIX_DRAWTRANSPARENT}
{$DEFINE NOT_IMMIDIATLYONLY}
{$DEFINE USE_MMX}
{$DEFINE USE_MEMSAVEMODE}
{$DEFINE USE_2XAA_INSTEAD_OF_4XAA}

{$IFNDEF NOT_IMMIDIATLYONLY}
    {$IFDEF USE_MMXTOO}
        {$UNDEF USE_MMXTOO}
    {$ENDIF USE_MMXTOO}
{$ENDIF NOT_IMMIDIATLYONLY}

{$IFDEF FIX_DRAWTRANSPARENT}
    {$DEFINE SYSNEED}
{$ENDIF FIX_DRAWTRANSPARENT}

{$IFDEF FIX_16BITMODE}
    {$DEFINE SYSNEED}
{$ENDIF FIX_16BITMODE}

{$UNDEF PCode}

{$C-}

type
   {$ifdef F_P}
      TGRushControl = class;
   {$endif}
    PGRushControl = {$ifndef F_P}^{$endif}TGRushControl;
   {$ifdef F_P}
      TGRushData = class;
   {$endif}
    PGRushData = {$ifndef F_P}^{$endif}TGRushData;

    TKOLGRushButton = PGRushControl;
    TKOLGRushPanel = PGRushControl;
    TKOLGRushCheckBox = PGRushControl;
    TKOLGRushRadioBox = PGRushControl;
    TKOLGRushSplitter = PGRushControl;
    TKOLGRushProgressBar = PGRushControl;
    TKOLGRushImageCollection = PBitmap;
    

    TGRushOrientation = (orHorizontal, orVertical);
    TGRushGradientStyle = (gsSolid, gsVertical, gsHorizontal, gsDoubleVert
        , gsDoubleHorz, gsFromTopLeft, gsFromTopRight);
    TGRushState = set of (gsOver, gsDown);
    TGRushStateInit = (siNone, siKey, siButton);
    TGRushCurrentOperation = (coDefToOver, coDefToDown, coOverToDef
        , coOverToDown, coDownToDef, coDownToOver);
    TGRushToUpdate = set of (tuDef, tuOver, tuDown, tuDis);
    TGRushControlType = (_ct00, _ct01, _ct02, _ct03, _ct04, _ct05, _ct06, _ct07, _ct08, _ct09, _ct0a, _ct0b, _ct0c, _ct0d, _ct0e, _ct0f
                  , _ct10, _ct11, _ct12, _ct13, _ct14, _ct15, _ct16, _ct17, _ct18, _ct19, _ct1a, _ct1b, _ct1c, _ct1d, _ct1e, _ct1f
                  , ctButton { $20}, ctPanel { $21}, ctCheckBox { $22}
                  , ctRadioBox { $23}, ctSplitter { $24}, ctProgressBar { $25});
    TGRushSpeed = (usImmediately, usVeryFast, usFast, usNormal, usSlow, usVerySlow);
    //                  64(1)          13(5)       10(7)   8(8)      6(11)   4(16)
    TGRushVAlign = (vaTop, vaCenter, vaBottom);
    TGRushHAlign = (haLeft, haCenter, haRight);

    TGRushPaintState = packed record
    {+} ColorFrom:          TColor;
    {+} ColorTo:            TColor;
    { } ColorOuter:         TColor;
    {+} ColorText:          TColor;
//16
    {+} ColorShadow:        TColor;
    {+} BorderColor:        TColor;
    { } BorderRoundWidth:   DWORD;
    { } BorderRoundHeight:  DWORD;
//32
    {+} BorderWidth:        DWORD;
    {+} GradientStyle:      TGRushGradientStyle;
    {+} ShadowOffset:       Integer;
    { } GlyphItemX:         DWORD;
    { } GlyphItemY:         DWORD;
//44
    end;

    TGrushRects = packed record
        DefBorderRect:      TRect;
        OverBorderRect:     TRect;
        DownBorderRect:     TRect;
        DisBorderRect:      TRect;
        AlphaRect:          TRect;
    end;

    TOnRecalcRects = procedure( Sender: PGRushControl; var Rects: TGRushRects ) of object;
    TOnGRushControl = procedure( Sender: PGRushControl) of object;
    TOnProgressChange = TOnGRushControl;

   {$ifdef F_P}
      TGRushData = class(TObj)
   {$else}
      TGRushData = packed object(TObj)
   {$endif}

        fPSDef:             TGRushPaintState;
        fPSOver:            TGRushPaintState;
        fPSDown:            TGRushPaintState;
        fPSDis:             TGRushPaintState;
//176
        fContentOffsets:    TRect;
        fGlyphWidth:        DWORD;
        fGlyphHeight:       DWORD;
        fSplitterDotsCount: DWORD;
        fCheckMetric:       DWORD;
        fColorCheck:        TColor;
//208
        fGlyphVAlign:       TGRushVAlign;
        fGlyphHAlign:       TGRushHAlign;
        fTextVAlign:        TGRushVAlign;
        fTextHAlign:        TGRushHAlign;
     {?}fDrawGlyph:         Boolean;
     {?}fDrawText:          Boolean;
     {?}fDrawFocusRect:     Boolean;
     {?}fDrawProgress:      Boolean;
     {?}fDrawProgressRect:  Boolean;
     {?}fGlyphAttached:     Boolean;
     {?}fCropTopFirst:      Boolean;
     {?}fAntiAliasing:      Boolean;
     {?}fProgressVertical:  Boolean;
        fUpdateSpeed:       TGRushSpeed;
        fSpacing:           DWORD;
//224
//83
        fProgress:          DWORD;
        fProgressRange:     DWORD;
        fNeedDib:           Boolean;

        fDefNeedUpdate:     Boolean;
        fOverNeedUpdate:    Boolean;
        fDownNeedUpdate:    Boolean;
        fDisNeedUpdate:     Boolean;
        fResultNeedUpdate:  Boolean;

        fControlType:       TGRushControlType;
        fOnRecalcRects:     TOnRecalcRects;
        fOnProgressChange:  TOnGRushControl;
        fGlyphBitmap:       PBitmap;
        fRects:             TGRushRects;
        fBlendPercent:      Integer;
        fState:             TGRushState;
        fActive:            Boolean;
        fStateInit:         TGRushStateInit;
        fCurrentOperation:  TGRushCurrentOperation;

        fDefPatern:         PBitmap;
        fOverPatern:        PBitmap;
        fDownPatern:        PBitmap;
        fDisPatern:         PBitmap;
        fResultPatern:      PBitmap;
        fSplDotsOrient:     TGRushOrientation;

        fAlphaChannel:      boolean;
        fAlphaBlendValue:   integer;
        
        fMouseEnter:        boolean;
    public
        destructor Destroy; virtual;
    end;

    TGRushFake = packed record
        fPSDef:             TGRushPaintState;
        fPSOver:            TGRushPaintState;
        fPSDown:            TGRushPaintState;
        fPSDis:             TGRushPaintState;
//176
        fContentOffsets:    TRect;
        fGlyphWidth:        DWORD;
        fGlyphHeight:       DWORD;
        fSplitterDotsCount: DWORD;
        fCheckMetric:       DWORD;
        fColorCheck:        TColor;
//208
        fGlyphVAlign:       TGRushVAlign;
        fGlyphHAlign:       TGRushHAlign;
        fTextVAlign:        TGRushVAlign;
        fTextHAlign:        TGRushHAlign;
        fDrawGlyph:         Boolean;
        fDrawText:          Boolean;
        fDrawFocusRect:     Boolean;
        fDrawProgress:      Boolean;
        fDrawProgressRect:  Boolean;
        fGlyphAttached:     Boolean;
        fCropTopFirst:      Boolean;
        fAntiAliasing:      Boolean;
        fProgressVertical:  Boolean;
        fUpdateSpeed:       TGRushSpeed;
        fSpacing:           DWORD;
//224
        fProgress:          DWORD;
        fProgressRange:     DWORD;
        fNeedDib:           Boolean;

        fDefNeedUpdate:     Boolean;
        fOverNeedUpdate:    Boolean;
        fDownNeedUpdate:    Boolean;
        fDisNeedUpdate:     Boolean;
        fResultNeedUpdate:  Boolean;
    end;

   {$ifdef F_P}
      TGRushControl = class(TControl)
   {$else}
      TGRushControl = object(TControl)
   {$endif}

    {* This Object implements all functionality of GRush Controls. All added properties named by followinf rule:
    If property takes effect on one of the four state, its name begining with following prefixes:
    |<b>Def_, Over_, Down_, Dis_.</b>
    if property provide common functionality, its name begining with prefix 
    |<b>All_</b>. Also all state-effect propertes can be changed with write-only property, named as
    | state-effect propertes, but with prefix <b>All_</b> }
    
    {= Объект, инкапсулирующий всю фунциональность GRush контролов. Все добавленые свойства именованы
    по следующим правилам: Если свойство оказывает влияние только на одно из четырех базовых состояний, его
    |имя начинается с следующих префиксов (по ожному на состояние): <b>Def_, Over_, Down_, Dis_.</b>
    Если свойство обеспечивает обшую функциональность, то его имя начинается с префикса
    |<b>All_</b>. Так же все свойства состояний имеют метод для записи, изменяя который изменяются
    |все свойства состояния. Он также начинается с префикса <b>All_</b>.}
    protected
        function GetAll_SplDotsOrient: TGRushOrientation;
        procedure SetAll_SplDotsOrient(const Value: TGRushOrientation);

        function GetDef_ColorFrom: integer;             procedure SetDef_ColorFrom(Val: integer);
        function GetDef_ColorTo: integer;               procedure SetDef_ColorTo(Val: integer);
        function GetDef_ColorOuter: integer;            procedure SetDef_ColorOuter(Val: integer);
        function GetDef_ColorText: integer;             procedure SetDef_ColorText(Val: integer);
        function GetDef_ColorShadow: integer;           procedure SetDef_ColorShadow(Val: integer);
        function GetDef_BorderColor: integer;           procedure SetDef_BorderColor(Val: integer);
        function GetDef_BorderWidth: DWORD;             procedure SetDef_BorderWidth(Val: DWORD);
        function GetDef_BorderRoundWidth: DWORD;        procedure SetDef_BorderRoundWidth(Val: DWORD);
        function GetDef_BorderRoundHeight: DWORD;       procedure SetDef_BorderRoundHeight(Val: DWORD);
        function GetDef_ShadowOffset: Integer;          procedure SetDef_ShadowOffset(Val: Integer);
        function GetDef_GradientStyle: TGRushGradientStyle; procedure SetDef_GradientStyle(Val: TGRushGradientStyle);
        function GetDef_GlyphItemX: DWORD;              procedure SetDef_GlyphItemX(Val: DWORD);
        function GetDef_GlyphItemY: DWORD;              procedure SetDef_GlyphItemY(Val: DWORD);

        function GetOver_ColorFrom: integer;            procedure SetOver_ColorFrom(Val: integer);
        function GetOver_ColorTo: integer;              procedure SetOver_ColorTo(Val: integer);
        function GetOver_ColorOuter: integer;           procedure SetOver_ColorOuter(Val: integer);
        function GetOver_ColorText: integer;            procedure SetOver_ColorText(Val: integer);
        function GetOver_ColorShadow: integer;          procedure SetOver_ColorShadow(Val: integer);
        function GetOver_BorderColor: integer;          procedure SetOver_BorderColor(Val: integer);
        function GetOver_BorderWidth: DWORD;            procedure SetOver_BorderWidth(Val: DWORD);
        function GetOver_BorderRoundWidth: DWORD;       procedure SetOver_BorderRoundWidth(Val: DWORD);
        function GetOver_BorderRoundHeight: DWORD;      procedure SetOver_BorderRoundHeight(Val: DWORD);
        function GetOver_ShadowOffset: Integer;         procedure SetOver_ShadowOffset(Val: Integer);
        function GetOver_GradientStyle: TGRushGradientStyle; procedure SetOver_GradientStyle(Val: TGRushGradientStyle);
        function GetOver_GlyphItemX: DWORD;             procedure SetOver_GlyphItemX(Val: DWORD);
        function GetOver_GlyphItemY: DWORD;             procedure SetOver_GlyphItemY(Val: DWORD);

        function GetDown_ColorFrom: integer;            procedure SetDown_ColorFrom(Val: integer);
        function GetDown_ColorTo: integer;              procedure SetDown_ColorTo(Val: integer);
        function GetDown_ColorOuter: integer;           procedure SetDown_ColorOuter(Val: integer);
        function GetDown_ColorText: integer;            procedure SetDown_ColorText(Val: integer);
        function GetDown_ColorShadow: integer;          procedure SetDown_ColorShadow(Val: integer);
        function GetDown_BorderColor: integer;          procedure SetDown_BorderColor(Val: integer);
        function GetDown_BorderWidth: DWORD;            procedure SetDown_BorderWidth(Val: DWORD);
        function GetDown_BorderRoundWidth: DWORD;       procedure SetDown_BorderRoundWidth(Val: DWORD);
        function GetDown_BorderRoundHeight: DWORD;      procedure SetDown_BorderRoundHeight(Val: DWORD);
        function GetDown_ShadowOffset: Integer;         procedure SetDown_ShadowOffset(Val: Integer);
        function GetDown_GradientStyle: TGRushGradientStyle; procedure SetDown_GradientStyle(Val: TGRushGradientStyle);
        function GetDown_GlyphItemX: DWORD;             procedure SetDown_GlyphItemX(Val: DWORD);
        function GetDown_GlyphItemY: DWORD;             procedure SetDown_GlyphItemY(Val: DWORD);

        function GetDis_ColorFrom: integer;             procedure SetDis_ColorFrom(Val: integer);
        function GetDis_ColorTo: integer;               procedure SetDis_ColorTo(Val: integer);
        function GetDis_ColorOuter: integer;            procedure SetDis_ColorOuter(Val: integer);
        function GetDis_ColorText: integer;             procedure SetDis_ColorText(Val: integer);
        function GetDis_ColorShadow: integer;           procedure SetDis_ColorShadow(Val: integer);
        function GetDis_BorderColor: integer;           procedure SetDis_BorderColor(Val: integer);
        function GetDis_BorderWidth: DWORD;             procedure SetDis_BorderWidth(Val: DWORD);
        function GetDis_BorderRoundWidth: DWORD;        procedure SetDis_BorderRoundWidth(Val: DWORD);
        function GetDis_BorderRoundHeight: DWORD;       procedure SetDis_BorderRoundHeight(Val: DWORD);
        function GetDis_ShadowOffset: Integer;          procedure SetDis_ShadowOffset(Val: Integer);
        function GetDis_GradientStyle: TGRushGradientStyle;  procedure SetDis_GradientStyle(Val: TGRushGradientStyle);
        function GetDis_GlyphItemX: DWORD;              procedure SetDis_GlyphItemX(Val: DWORD);
        function GetDis_GlyphItemY: DWORD;              procedure SetDis_GlyphItemY(Val: DWORD);

        function GetAll_CheckMetric: DWORD;             procedure SetAll_CheckMetric(Val: DWORD);
        function GetAll_GlyphVAlign: TGRushVAlign;      procedure SetAll_GlyphVAlign(Val: TGRushVAlign);
        function GetAll_GlyphHAlign: TGRushHAlign;      procedure SetAll_GlyphHAlign(Val: TGRushHAlign);
        function GetAll_TextVAlign: TGRushVAlign;       procedure SetAll_TextVAlign(Val: TGRushVAlign);
        function GetAll_TextHAlign: TGRushHAlign;       procedure SetAll_TextHAlign(Val: TGRushHAlign);
        function GetAll_DrawText: Boolean;              procedure SetAll_DrawText(Val: Boolean);
        function GetAll_DrawGlyph: Boolean;             procedure SetAll_DrawGlyph(Val: Boolean);
        function GetAll_DrawFocusRect: Boolean;         procedure SetAll_DrawFocusRect(Val: Boolean);
        function GetAll_DrawProgress: Boolean;          procedure SetAll_DrawProgress(Val: Boolean);
        function GetAll_DrawProgressRect: Boolean;      procedure SetAll_DrawProgressRect(Val: Boolean);
        function GetAll_ProgressVertical: Boolean;      procedure SetAll_ProgressVertical(Val: Boolean);
        function GetAll_GlyphBitmap: PBitmap;           procedure SetAll_GlyphBitmap(Val: PBitmap);
        function GetAll_ContentOffsets: TRect;          procedure SetAll_ContentOffsets(const Val: TRect);
        function GetAll_AntiAliasing: Boolean;          procedure SetAll_AntiAliasing(Val: boolean);
        function GetAll_UpdateSpeed: TGRushSpeed;       procedure SetAll_UpdateSpeed(Val: TGRushSpeed);
        function GetAll_ColorCheck: TColor;             procedure SetAll_ColorCheck(Val: TColor);
        function GetAll_GlyphWidth: DWORD;              procedure SetAll_GlyphWidth(Val: DWORD);
        function GetAll_GlyphHeight: DWORD;             procedure SetAll_GlyphHeight(Val: DWORD);
        function GetAll_Spacing: DWORD;                 procedure SetAll_Spacing(Val: DWORD);
        function GetAll_SplitterDotsCount: DWORD;       procedure SetAll_SplitterDotsCount(Val: DWORD);
        function GetAll_CropTopFirst: Boolean;          procedure SetAll_CropTopFirst(Val: Boolean);
        function GetAll_GlyphAttached: Boolean;         procedure SetAll_GlyphAttached(Val: Boolean);

        function GetAlphaChannel: Boolean;              procedure SetAlphaChannel(Val: Boolean);
        function GetAlphaBlendValue: integer;           procedure SetAlphaBlendValue(Val: integer);

        procedure SetAll_ColorFrom(Val: integer);
        procedure SetAll_ColorTo(Val: integer);
        procedure SetAll_ColorOuter(Val: integer);
        procedure SetAll_ColorText(Val: integer);
        procedure SetAll_ColorShadow(Val: integer);
        procedure SetAll_BorderColor(Val: integer);
        procedure SetAll_BorderWidth(Val: DWORD);
        procedure SetAll_BorderRoundWidth(Val: DWORD);
        procedure SetAll_BorderRoundHeight(Val: DWORD);
        procedure SetAll_ShadowOffset(Val: Integer);
        procedure SetAll_GradientStyle(Val: TGRushGradientStyle);
        procedure SetAll_GlyphItemX(Val: DWORD);
        procedure SetAll_GlyphItemY(Val: DWORD);

        function GetOnRecalcRects: TOnRecalcRects;      procedure SetOnRecalcRects (const val: TOnRecalcRects);
        function GetOnProgressChange: TOnGRushControl;  procedure SetOnProgressChange (const val: TOnGRushControl);

        procedure DoEnter (Sender: PObj);
        procedure DoExit (Sender: PObj);
        procedure DoPush;
        procedure DoPop;
        procedure DoPaint (Ctl_: PControl; DC: HDC);
        procedure DeActivateSublings;
        procedure InitLast(MEnterExit: Boolean; CT: TGRushControlType);
        procedure UpdateProgress;
        procedure TimerEvent(Data: PGRushData);
        procedure DrawControlState(var Bitmap: PBitmap; const BorderRect: TRect;
            const State: TGRushPaintState; UseDIB: boolean);
        procedure CleanMem(Data: PGRushData);
    public
//--------
        property     Def_ColorFrom:          integer
            read  GetDef_ColorFrom           write SetDef_ColorFrom;
        {* Sets the first color, used in gradient fill}
        {= Первый цвет, используемый для градиента}
        property     Def_ColorTo:            Integer
            read  GetDef_ColorTo             write SetDef_ColorTo;
        {* Sets the second color, used in gradient fill}
        {= Второй цвет, используемый для градиента}
        property     Def_ColorOuter:         Integer
            read  GetDef_ColorOuter          write SetDef_ColorOuter;
        {* Sets color, used to fill part of control, which not fills with gradient}
        {= Цвет, используемый для заполнения той части контрола, где нет градиента}
        property     Def_ColorText:          integer
            read  GetDef_ColorText           write SetDef_ColorText;
        {* Sets color, used to draw text on control}
        {= Цвет для рисования текста.}
        property     Def_ColorShadow:        Integer
            read  GetDef_ColorShadow         write SetDef_ColorShadow;
        {* Sets color, used to draw text shadow on control}
        {= Цвет для рисования тени текста}
        property     Def_BorderColor:        Integer
            read  GetDef_BorderColor         write SetDef_BorderColor;
        {* Sets color, used to draw border of control}
        {= Цвет для рисования бордюра}
        property     Def_BorderWidth:        DWORD
            read  GetDef_BorderWidth         write SetDef_BorderWidth;
        {* Width of line, used to draw border}
        {= Ширина линии бордюра контрола}
        property     Def_BorderRoundWidth:   DWORD
            read  GetDef_BorderRoundWidth    write SetDef_BorderRoundWidth;
        {* Width of arc, drawed instead of border corner. If is 0, no arc drawed}
        {= Ширина дуги, рисуемой вместо углов бордюра. Если 0, углы острые}
        property     Def_BorderRoundHeight:  DWORD
            read  GetDef_BorderRoundHeight   write SetDef_BorderRoundHeight;
        {* Height of arc, drawed instead of border corner. If is 0, no arc drawed}
        {= Высота дуги, рисуемой вместо углов бордюра. Если 0, углы острые}
        property     Def_ShadowOffset:       Integer
            read  GetDef_ShadowOffset        write SetDef_ShadowOffset;
        {* Offset of text shadow. Positiv value means offset to the bottom and right. If is 0, no shadow drawed}
        {= Смещение тени текста. Положительное значение - смещение вниз и вправо. Если 0, тень не рисуется}
        property     Def_GradientStyle:      TGRushGradientStyle
            read  GetDef_GradientStyle       write SetDef_GradientStyle;
        {* Style of gradient fill. One of following values:
        |<b> gsSolid, gsVertical, gsHorizontal, gsDoubleVert, gsDoubleHorz, gsFromTopLeft, gsFromTopRight</b>}
        {= Стиль градиента. Одно из следующих значений:
        |<b> gsSolid, gsVertical, gsHorizontal, gsDoubleVert, gsDoubleHorz, gsFromTopLeft, gsFromTopRight</b>}
        property     Def_GlyphItemX:         DWORD
            read  GetDef_GlyphItemX          write SetDef_GlyphItemX;
        {* X coordinate of Glyph, cuted from All_GlyphBitmap. See All_GlyphWidth, All_GlyphHeight}
        {= Координата Х рисунка, вырезаемого из All_GlyphBitmap. См. All_GlyphWidth, All_GlyphHeight}
        property     Def_GlyphItemY:         DWORD
            read  GetDef_GlyphItemY          write SetDef_GlyphItemY;
        {* Y coordinate of Glyph, cuted from All_GlyphBitmap. See All_GlyphWidth, All_GlyphHeight}
        {= Координата Y рисунка, вырезаемого из All_GlyphBitmap. См. All_GlyphWidth, All_GlyphHeight}
//--------
        property     Over_ColorFrom:         integer
            read  GetOver_ColorFrom          write SetOver_ColorFrom;
        property     Over_ColorTo:           integer
            read  GetOver_ColorTo            write SetOver_ColorTo;
        property     Over_ColorOuter:        integer
            read  GetOver_ColorOuter         write SetOver_ColorOuter;
        property     Over_ColorText:         integer
            read  GetOver_ColorText          write SetOver_ColorText;
        property     Over_ColorShadow:       integer
            read  GetOver_ColorShadow        write SetOver_ColorShadow;
        property     Over_BorderColor:       integer
            read  GetOver_BorderColor        write SetOver_BorderColor;
        property     Over_BorderWidth:       DWORD
            read  GetOver_BorderWidth        write SetOver_BorderWidth;
        property     Over_BorderRoundWidth:  DWORD
            read  GetOver_BorderRoundWidth   write SetOver_BorderRoundWidth;
        property     Over_BorderRoundHeight: DWORD
            read  GetOver_BorderRoundHeight  write SetOver_BorderRoundHeight;
        property     Over_ShadowOffset:      Integer
            read  GetOver_ShadowOffset       write SetOver_ShadowOffset;
        property     Over_GradientStyle:     TGRushGradientStyle
            read  GetOver_GradientStyle      write SetOver_GradientStyle;
        property     Over_GlyphItemX:        DWORD
            read  GetOver_GlyphItemX         write SetOver_GlyphItemX;
        property     Over_GlyphItemY:        DWORD
            read  GetOver_GlyphItemY         write SetOver_GlyphItemY;
//--------
        property     Down_ColorFrom:         integer
            read  GetDown_ColorFrom          write SetDown_ColorFrom;
        property     Down_ColorTo:           integer
            read  GetDown_ColorTo            write SetDown_ColorTo;
        property     Down_ColorOuter:        integer
            read  GetDown_ColorOuter         write SetDown_ColorOuter;
        property     Down_ColorText:         integer
            read  GetDown_ColorText          write SetDown_ColorText;
        property     Down_ColorShadow:       integer
            read  GetDown_ColorShadow        write SetDown_ColorShadow;
        property     Down_BorderColor:       integer
            read  GetDown_BorderColor        write SetDown_BorderColor;
        property     Down_BorderWidth:       DWORD
            read  GetDown_BorderWidth        write SetDown_BorderWidth;
        property     Down_BorderRoundWidth:  DWORD
            read  GetDown_BorderRoundWidth   write SetDown_BorderRoundWidth;
        property     Down_BorderRoundHeight: DWORD
            read  GetDown_BorderRoundHeight  write SetDown_BorderRoundHeight;
        property     Down_ShadowOffset:      Integer
            read  GetDown_ShadowOffset       write SetDown_ShadowOffset;
        property     Down_GradientStyle:     TGRushGradientStyle
            read  GetDown_GradientStyle      write SetDown_GradientStyle;
        property     Down_GlyphItemX:        DWORD
            read  GetDown_GlyphItemX         write SetDown_GlyphItemX;
        property     Down_GlyphItemY:        DWORD
            read  GetDown_GlyphItemY         write SetDown_GlyphItemY;
//--------
        property     Dis_ColorFrom:         integer
            read  GetDis_ColorFrom          write SetDis_ColorFrom;
        property     Dis_ColorTo:           integer
            read  GetDis_ColorTo            write SetDis_ColorTo;
        property     Dis_ColorOuter:        integer
            read  GetDis_ColorOuter         write SetDis_ColorOuter;
        property     Dis_ColorText:         integer
            read  GetDis_ColorText          write SetDis_ColorText;
        property     Dis_ColorShadow:       integer
            read  GetDis_ColorShadow        write SetDis_ColorShadow;
        property     Dis_BorderColor:       integer
            read  GetDis_BorderColor        write SetDis_BorderColor;
        property     Dis_BorderWidth:       DWORD
            read  GetDis_BorderWidth        write SetDis_BorderWidth;
        property     Dis_BorderRoundWidth:  DWORD
            read  GetDis_BorderRoundWidth   write SetDis_BorderRoundWidth;
        property     Dis_BorderRoundHeight: DWORD
            read  GetDis_BorderRoundHeight  write SetDis_BorderRoundHeight;
        property     Dis_ShadowOffset:      Integer
            read  GetDis_ShadowOffset       write SetDis_ShadowOffset;
        property     Dis_GradientStyle:     TGRushGradientStyle
            read  GetDis_GradientStyle      write SetDis_GradientStyle;
        property     Dis_GlyphItemX:        DWORD
            read  GetDis_GlyphItemX         write SetDis_GlyphItemX;
        property     Dis_GlyphItemY:        DWORD
            read  GetDis_GlyphItemY         write SetDis_GlyphItemY;
//--------
        property     All_ContentOffsets:    TRect
            read  GetAll_ContentOffsets     write SetAll_ContentOffsets;
        {* }
        {= }
        property     All_CheckMetric:       DWORD
            read  GetAll_CheckMetric        write SetAll_CheckMetric;
        {* }
        {= }
        property     All_GlyphHAlign:       TGRushHAlign
            read  GetAll_GlyphHAlign        write SetAll_GlyphHAlign;
        {* }
        {= }
        property     All_GlyphVAlign:       TGRushVAlign
            read  GetAll_GlyphVAlign        write SetAll_GlyphVAlign;
        {* }
        {= }
        property     All_TextHAlign:        TGRushHAlign
            read  GetAll_TextHAlign         write SetAll_TextHAlign;
        {* }
        {= }
        property     All_TextVAlign:        TGRushVAlign
            read  GetAll_TextVAlign         write SetAll_TextVAlign;
        {* }
        {= }
        property     All_DrawText:          Boolean
            read  GetAll_DrawText           write SetAll_DrawText;
        {* }
        {= }
        property     All_DrawGlyph:         Boolean
            read  GetAll_DrawGlyph          write SetAll_DrawGlyph;
        {* }
        {= }
        property     All_DrawFocusRect:     Boolean
            read  GetAll_DrawFocusRect      write SetAll_DrawFocusRect;
        {* }
        {= }
        property     All_DrawProgress:      Boolean
            read  GetAll_DrawProgress       write SetAll_DrawProgress;
        {* }
        {= }
        property     All_DrawProgressRect:  Boolean
            read  GetAll_DrawProgressRect   write SetAll_DrawProgressRect;
        {* }
        {= }
        property     All_ProgressVertical:  Boolean
            read  GetAll_ProgressVertical   write SetAll_ProgressVertical;
        {* }
        {= }
        property     All_UpdateSpeed:       TGRushSpeed
            read  GetAll_UpdateSpeed        write SetAll_UpdateSpeed;
        {* }
        {= }
        property     All_ColorCheck:        TColor
            read  GetAll_ColorCheck         write SetAll_ColorCheck;
        {* }
        {= }
        property     All_GlyphWidth:        DWORD
            read  GetAll_GlyphWidth         write SetAll_GlyphWidth;
        {* }
        {= }
        property     All_GlyphHeight:       DWORD
            read  GetAll_GlyphHeight        write SetAll_GlyphHeight;
        {* }
        {= }
        property     All_GlyphBitmap:       PBitmap
            read  GetAll_GlyphBitmap        write SetAll_GlyphBitmap;
        {* }
        {= }
        property     All_AntiAliasing:      Boolean
            read  GetAll_AntiAliasing       write SetAll_AntiAliasing;
        {* }
        {= }
        property     All_Spacing:           DWORD
            read  GetAll_Spacing            write SetAll_Spacing;
        {* }
        {= }
        property     All_SplitterDotsCount: DWORD
            read  GetAll_SplitterDotsCount  write SetAll_SplitterDotsCount;
        {* }
        {= }
        property     All_SplDotsOrient:     TGRushOrientation
             read  GetAll_SplDotsOrient      write SetAll_SplDotsOrient;
        {* }
        {= }

        property     All_CropTopFirst:      Boolean
            read  GetAll_CropTopFirst       write SetAll_CropTopFirst;
        {* }
        {= }
        property     All_GlyphAttached:     Boolean
            read  GetAll_GlyphAttached      write SetAll_GlyphAttached;
        {* }
        {= }
        property     All_ColorFrom:         Integer
            write SetAll_ColorFrom;
        property     All_ColorTo:           Integer
            write SetAll_ColorTo;
        property     All_ColorOuter:        Integer
            write SetAll_ColorOuter;
        property     All_ColorText:         Integer
            write SetAll_ColorText;
        property     All_ColorShadow:       Integer
            write SetAll_ColorShadow;
        property     All_BorderColor:       integer
            write SetAll_BorderColor;
        property     All_BorderWidth:       DWORD
            write SetAll_BorderWidth;
        property     All_BorderRoundWidth:  DWORD
            write SetAll_BorderRoundWidth;
        property     All_BorderRoundHeight: DWORD
            write SetAll_BorderRoundHeight;
        property     All_ShadowOffset:      Integer
            write SetAll_ShadowOffset;
        property     All_GradientStyle:     TGRushGradientStyle
            write SetAll_GradientStyle;
        property     All_GlyphItemX:        DWORD
            write SetAll_GlyphItemX;
        property     All_GlyphItemY:        DWORD
            write SetAll_GlyphItemY;

        property     AlphaChannel:          boolean
            read  GetAlphaChannel           write SetAlphaChannel;

        property     AlphaBlendValue:       integer
            read  GetAlphaBlendValue        write SetAlphaBlendValue;

        property     OnRecalcRects:         TOnRecalcRects
            read  GetOnRecalcRects          write SetOnRecalcRects;
        property     OnProgressChange:      TOnGRushControl
            read  GetOnProgressChange       write SetOnProgressChange;

        procedure SetAllNeedUpdate;
        procedure CheckNeedUpdate (ToUpdate: TGRushToUpdate; UseDIBs: Boolean);
    end;

    function NewGRushButton(AParent: PControl; Caption: String):PGRushControl;
    function NewGRushPanel(AParent: PControl):PGRushControl;
    function NewGRushCheckBox(AParent: PControl; Caption: String):PGRushControl;
    function NewGRushRadioBox(AParent: PControl; Caption: String):PGRushControl;
    function NewGRushSplitter(AParent: PControl; MinSizePrev, MinSizeNext: Integer):PGRushControl;
    function NewGRushProgressBar(AParent: PControl):PGRushControl;

    function AlignColorTo16Bit(Color: TColor):TColor;
    function Max4 (A, B, C, D: Integer):Integer;
    function Min4 (A, B, C, D: Integer):Integer;
    procedure BitmapAntialias4X(SrcBitmap, DstBitmap: PBitmap);  // With MMX support !!!
    procedure BitmapAntialias2X(SrcBitmap, DstBitmap: PBitmap);  // With MMX support !!!
    procedure BlendBitmaps(var DestBitmap, FromBitmap, ToBitmap: PBitmap; Factor: Integer; ClipRect:TRect); // With MMX support !!!

const
    CheckContentRect: TRect = (Left: 19; Top: 1; Right: -1; Bottom: -1);
    ProgressBarContentRect: TRect = (Left: 0; Top: 0; Right: 0; Bottom: 0);
    DefGRushData: TGRushFake = (
        fPSDef: (
            ColorFrom:          clWhite;
            ColorTo:            $D1beaf;
            ColorOuter:         clBtnFace;
            ColorText:          clBlack;
            ColorShadow:        clWhite;
            BorderColor:        clMedGray;
            BorderRoundWidth:   4;
            BorderRoundHeight:  4;
            BorderWidth:        1;
            GradientStyle:      gsVertical;
            ShadowOffset:       1;
            GlyphItemX:         0;
            GlyphItemY:         0;
        );
        fPSOver: (
            ColorFrom:          $e1cebf;
            ColorTo:            clWhite;
            ColorOuter:         clBtnFace;
            ColorText:          clBlack;
            ColorShadow:        clGray;
            BorderColor:        clMedGray;
            BorderRoundWidth:   4;
            BorderRoundHeight:  4;
            BorderWidth:        1;
            GradientStyle:      gsDoubleVert;
            ShadowOffset:       1;
            GlyphItemX:         0;
            GlyphItemY:         0;
        );
        fPSDown: (
            ColorFrom:          clCream;
            ColorTo:            $b6bFc6;
            ColorOuter:         clBtnFace;
            ColorText:          clBlack;
            ColorShadow:        clGray;
            BorderColor:        clGray;
            BorderRoundWidth:   8;
            BorderRoundHeight:  4;
            BorderWidth:        2;
            GradientStyle:      gsDoubleHorz;
            ShadowOffset:       -1;
            GlyphItemX:         0;
            GlyphItemY:         0;
        );
        fPSDis: (
            ColorFrom:          clWhite;
            ColorTo:            $9EACB4;
            ColorOuter:         clBtnFace;
            ColorText:          clBlack;
            ColorShadow:        clGray;
            BorderColor:        clGray;
            BorderRoundWidth:   5;
            BorderRoundHeight:  5;
            BorderWidth:        2;
            GradientStyle:      gsFromTopLeft;
            ShadowOffset:       2;
            GlyphItemX:         0;
            GlyphItemY:         0;
        );
        fContentOffsets:   (Left:   4;
                            Top:    4;
                            Right:  -4;
                            Bottom: -4);
        fGlyphWidth:        0;
        fGlyphHeight:       0;
        fSplitterDotsCount: 0;
        fCheckMetric:       13;
        fColorCheck:        $F3706C;
        fGlyphVAlign:       vaCenter;
        fGlyphHAlign:       haLeft;
        fTextVAlign:        vaCenter;
        fTextHAlign:        haCenter;
        fDrawGlyph:         TRUE;
        fDrawText:          TRUE;
        fDrawFocusRect:     TRUE;
        fDrawProgress:      FALSE;
        fDrawProgressRect:  FALSE;
        fGlyphAttached:     FALSE;
        fCropTopFirst:      TRUE;
        fAntiAliasing:      TRUE;
        fProgressVertical:  FALSE;
        //gsImmediately usVeryFast usFast usNormal usSlow usVerySlow
        fUpdateSpeed:       usFast;
        fSpacing:           5;
        
        fProgress:          0;
        fProgressRange:     100;
        fNeedDib:           TRUE;
        fDefNeedUpdate:     TRUE;
        fOverNeedUpdate:    TRUE;
        fDownNeedUpdate:    TRUE;
        fDisNeedUpdate:     TRUE;
        fResultNeedUpdate:  TRUE;
    );

implementation

function _AlphaBlend(hdcDest: HDC; nXOriginDest, nYOriginDest, nWidthDest, nHeightDest: Integer;
                     hdcSrc: HDC; nXOriginSrc, nYOriginSrc, nWidthSrc, nHeightSrc: Integer;
                     blendFunction: TBlendFunction): BOOL; stdcall;
                     external 'msimg32.dll' name 'AlphaBlend';

type
    TRIVERTEX = packed record
        X, Y : DWORD;
        Red, Green, Blue, Alpha : Word;
    end;
    TA = array [0..129] of byte;

var     CheckRgn,
        RadioRgn: HRGN;
        {$IFDEF USE_MMX}
        UseMMX: boolean;
        {$ENDIF USE_MMX}
        {$IFDEF SYSNEED}
        UseSystemGradient: boolean;
        hinst_msimg32: HInst;
        SysGradientFill: function(DC: hDC; pVertex: Pointer; dwNumVertex: DWORD;
            pMesh: Pointer; dwNumMesh, dwMode: DWORD): Bool; stdcall;
        {$IFDEF FIX_DRAWTRANSPARENT}
        SysTransparentBlt: function(DC: HDC; p2, p3, p4, p5: Integer; DC6: HDC;
            p7, p8, p9, p10: Integer; p11: UINT): BOOL; stdcall;
        {$ENDIF FIX_DRAWTRANSPARENT}
        {$ENDIF SYSNEED}

const
        ID_GRUSHTYPE        : {$IFDEF UNICODE_CTRLS}
                              array[0..10] of WideChar = ( 'G','R','U','S','H','_','T','Y','P','E',#0 )
                              {$ELSE}
                              array[0..10] of Char = ( 'G','R','U','S','H','_','T','Y','P','E',#0 )
                              {$ENDIF};

        AlphaIncrement      : array [TGRushSpeed] of integer = (64, 22, 13, 8, 6, 4);
        GT_RADIOBOX         : DWORD = $000023;
        msimg32             = 'msimg32.dll';
        _Check: TA =        (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                             1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                             1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
                             1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1,
                             1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1,
                             1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1,
                             1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1,
                             1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1,
                             1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1,
                             1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);

        _Radio: TA =        (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                             1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                             1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                             1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1,
                             1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1,
                             1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1,
                             1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1,
                             1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1,
                             1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                             1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);

function RegionFromArray(_A: TA):HRGN;
var     _TempRgn: HRGN;
        i, j: integer;
begin
    Result := CreateRectRgn(0, 0, 0, 0);
    For j := 0 to 9 do
        for i := 3 to 15 do
            if _A[(j*13)+i-3] = 0 then begin
                _TempRgn := CreateRectRgn(i, j, i+1, j+1);
                CombineRGN(Result, Result, _TempRgn, RGN_OR);
                DeleteObject(_TempRgn);
            end;
end;

function CPUisMMX: Boolean;
var     I: Integer;
begin
    I := 0;
    Result := false;
    asm // check if bit 21 of EFLAGS can be set and reset
        PUSHFD
        POP     EAX
        OR      EAX, 1 shl 21
        PUSH    EAX
        POPFD
        PUSHFD
        POP     EAX
        TEST    EAX, 1 shl 21
        JZ      @@1
        AND     EAX, not( 1 shl 21 )
        PUSH    EAX
        POPFD
        PUSHFD
        POP     EAX
        TEST    EAX, 1 shl 21
        JNZ     @@1
        INC     [ I ]
    @@1:
    end;
    if I = 0 then Exit;                  // CPUID not supported
    asm // get CPU features flags using CPUID command
        MOV     EAX, 1
        PUSH    EDX
        PUSH    EBX
        PUSH    ECX
        DB $0F, $A2
        MOV     [ I ], EDX  // I := features information
        POP     ECX
        POP     EBX
        POP     EDX
    end;
    if (I and (1 shl 23)) <> 0 then
        Result := true;
end;

function AlignColorTo16Bit;
begin
    Color := Color2RGB( Color );
    Result := ((((Color shr 19) and $1f) * 541052) and $FF0000) or
        (((((Color shr 10) and $3F) * 266294) shr 8) and $FF00) or
        ((((Color shr 3) and $1f) * 541052) shr 16);
end;

procedure AlignRect(var Result: TRect; const Container: TRect; VA: TGRushVAlign; HA: TGRushHAlign);
var     Wi, He: integer;
begin
    Wi := Result.Right - Result.Left;
    He := Result.Bottom - Result.Top;
    case HA of
        haLeft:
            begin
                Result.Left := Container.Left;
                Result.Right := Result.Left + Wi;
            end;
        haCenter:
            begin
                Result.Left := (Container.Right + Container.Left - Wi) div 2;
                Result.Right := Result.Left + Wi;
            end;
        haRight:
            begin
                Result.Right := Container.Right;
                Result.Left := Result.Right - Wi;
            end;
    end;
    case VA of
        vaTop:
            begin
                Result.Top := Container.Top;
                Result.Bottom := Result.Top + He;
            end;
        vaCenter:
            begin
                Result.Top := (Container.Bottom + Container.Top - He) div 2;
                Result.Bottom := Result.Top + He;
            end;
        vaBottom:
            begin
                Result.Bottom := Container.Bottom;
                Result.Top := Result.Bottom - He;
            end;
    end;
end;

function Max4 (A, B, C, D: Integer):Integer;
begin
    if (A > B) and (A > C) and (A > D) then
        result := A
    else
        if (B > C) and (B > D) then
            result := B
        else
            if (C > D) then
                Result := C
            else
                Result := D;
    if Result < 0 then
        Result := 0;
end;

function Min4 (A, B, C, D: Integer):Integer;
begin
    if (A < B) and (A < C) and (A < D) then
        result := A
    else
        if (B < C) and (B < D) then
            result := B
        else
            if (C < D) then
                Result := C
            else
                Result := D;
    if Result > 0 then
        Result := 0;
end;

function AddRects(const R1: TRect; const R2: TRect): TRect;
begin
    with Result do begin
        Left := R1.Left + R2.Left;
        Top := R1.Top + R2.Top;
        Right := R1.Right + R2.Right;
        Bottom := R1.Bottom + R2.Bottom;
    end;
end;

procedure ClickGRushRadio( Sender:PObj );
begin
  PGRushControl( Sender ).fChecked := TRUE;
end;

{$IFDEF FIX_DRAWTRANSPARENT}
procedure myDrawTransparent(Bitmap: PBitmap; DC: HDC; X: Integer; Y: Integer; Color: TColor);
var     bW, bH: integer;
begin
    bW := Bitmap.Width;
    bH := Bitmap.Height;
    Color := Color2RGB(Color);
    if UseSystemGradient then
        SysTransparentBlt(DC, X, Y, bW, bH, Bitmap.Canvas.Handle, 0, 0, bW, bH, Color)
    else
        Bitmap.DrawTransparent(DC, X, Y, Color);
end;
{$ENDIF FIX_DRAWTRANSPARENT}

procedure BitmapAntialias4X(SrcBitmap, DstBitmap: PBitmap);
type    AGRBQuad = array [0..0] of TRGBQuad;
        PAGRBQuad = ^AGRBQuad;
var     yDest: integer;
        xDest: integer;
        xSrc: integer;
        i: integer;
        R: integer;
        G: integer;
        B: integer;
        rowDest: PAGRBQuad;
        rowSrc: array [0..3] of PAGRBQuad;
        _rowSrc: PAGRBQuad;
        {$IFDEF USE_MMX}
        SrcBits: DWORD;
        DstBits: DWORD;
        dHeight: DWORD;
        dWidth: DWORD;
        Delta: DWORD;
        {$ENDIF USE_MMX}
begin
    {$IFDEF USE_MMX}
    if UseMMX then begin
        SrcBits := DWORD(SrcBitmap.DIBBits);
        DstBits := DWORD(DstBitmap.DIBBits);
        dHeight := DstBitmap.Height;
        dWidth := DstBitmap.Width;
        Delta := SrcBitmap.ScanLineSize;
        asm
            pushad
            mov esi, SrcBits
            mov edi, DstBits
            //pxor mm2, mm2
            db $0f, $ef, $d2

            mov eax, dHeight
@LM1:       push eax

            mov eax, dWidth
@LM2:       /////////
            mov ecx, esi

            //movd mm1, [ecx]
            db $0f, $6e, $09
            //punpcklbw mm1, mm2
            db $0f, $60, $ca
            //movd mm3, [ecx+4]
            db $0f, $6e, $59, $04
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb
            //movd mm3, [ecx+8]
            db $0f, $6e, $59, $08
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb
            //movd mm3, [ecx+12]
            db $0f, $6e, $59, $0c
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb

            add ecx, Delta

            //movd mm3, [ecx]
            db $0f, $6e, $19
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb
            //movd mm3, [ecx+4]
            db $0f, $6e, $59, $04
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb
            //movd mm3, [ecx+8]
            db $0f, $6e, $59, $08
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb
            //movd mm3, [ecx+12]
            db $0f, $6e, $59, $0c
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb

            add ecx, Delta

            //movd mm3, [ecx]
            db $0f, $6e, $19
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb
            //movd mm3, [ecx+4]
            db $0f, $6e, $59, $04
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb
            //movd mm3, [ecx+8]
            db $0f, $6e, $59, $08
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb
            //movd mm3, [ecx+12]
            db $0f, $6e, $59, $0c
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb

            add ecx, Delta

            //movd mm3, [ecx]
            db $0f, $6e, $19
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb
            //movd mm3, [ecx+4]
            db $0f, $6e, $59, $04
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb
            //movd mm3, [ecx+8]
            db $0f, $6e, $59, $08
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb
            //movd mm3, [ecx+12]
            db $0f, $6e, $59, $0c
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb

            //psrlw mm1, 4
            db $0f, $71, $d1, $04
            //packuswb mm1, mm2
            db $0f, $67, $ca
            //movd [edi], mm1
            db $0f, $7e, $0f
            /////////
            add edi, 4
            add esi, 16

            sub eax, 1
		    jnz @LM2

            mov ecx, Delta
            lea esi, [esi + ecx*2]
            add esi, ecx

            pop eax
            sub eax, 1
		    jnz @LM1

            //emms
            db $0f, $77

            popad
        end;
    end else
    {$ENDIF USE_MMX}
    for yDest := 0 to DstBitmap.Height -1 do begin
        rowDest := DstBitmap.ScanLine[yDest];
        for i := 0 to 3 do
            rowSrc[i] := SrcBitmap.ScanLine[yDest*4+i];
        for xDest := 0 to DstBitmap.Width-1 do begin
            xSrc := xDest*4;
            R:=0; G:=0; B:=0;
            for i := 0 to 3 do begin
                _rowSrc := rowSrc[i];
                R:= R+_rowSrc[xSrc+0].rgbRed
                    + _rowSrc[xSrc+1].rgbRed
                    + _rowSrc[xSrc+2].rgbRed
                    + _rowSrc[xSrc+3].rgbRed;
                G:= G+_rowSrc[xSrc+0].rgbGreen
                    + _rowSrc[xSrc+1].rgbGreen
                    + _rowSrc[xSrc+2].rgbGreen
                    + _rowSrc[xSrc+3].rgbGreen;
                B:= B+_rowSrc[xSrc+0].rgbBlue
                    + _rowSrc[xSrc+1].rgbBlue
                    + _rowSrc[xSrc+2].rgbBlue
                    + _rowSrc[xSrc+3].rgbBlue;
            end;
            DWORD(rowDest[xDest]) := ((R and $0ff0) shl 12) or ((G and $0ff0) shl 4) or (B shr 4);
        end;
    end;
end;

procedure BitmapAntialias2X(SrcBitmap, DstBitmap: PBitmap);
type    AGRBQuad = array [0..0] of TRGBQuad;
        PAGRBQuad = ^AGRBQuad;
var     yDest: integer;
        xDest: integer;
        xSrc: integer;
        i: integer;
        R: integer;
        G: integer;
        B: integer;
        rowDest: PAGRBQuad;
        rowSrc: array [0..3] of PAGRBQuad;
        _rowSrc: PAGRBQuad;
        {$IFDEF USE_MMX}
        SrcBits: DWORD;
        DstBits: DWORD;
        dHeight: DWORD;
        dWidth: DWORD;
        Delta: DWORD;
        {$ENDIF USE_MMX}
begin
    {$IFDEF USE_MMX}
    if UseMMX then begin
        SrcBits := DWORD(SrcBitmap.DIBBits);
        DstBits := DWORD(DstBitmap.DIBBits);
        dHeight := DstBitmap.Height;
        dWidth := DstBitmap.Width;
        Delta := SrcBitmap.ScanLineSize;
        asm
            pushad
            mov esi, SrcBits
            mov edi, DstBits
            //pxor mm2, mm2
            db $0f, $ef, $d2

            mov eax, dHeight
@LM1:       push eax

            mov eax, dWidth
@LM2:       /////////
            mov ecx, esi

            //movd mm1, [ecx]
            db $0f, $6e, $09
            //punpcklbw mm1, mm2
            db $0f, $60, $ca
            //movd mm3, [ecx+4]
            db $0f, $6e, $59, $04
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb

            add ecx, Delta

            //movd mm3, [ecx]
            db $0f, $6e, $19
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb
            //movd mm3, [ecx+4]
            db $0f, $6e, $59, $04
            //punpcklbw mm3, mm2
            db $0f, $60, $da
            //paddusw mm1, mm3
            db $0f, $dd, $cb

            //psrlw mm1, 2
            db $0f, $71, $d1, $02
            //packuswb mm1, mm2
            db $0f, $67, $ca
            //movd [edi], mm1
            db $0f, $7e, $0f
            /////////

            add edi, 4
            add esi, 8

            sub eax, 1
		    jnz @LM2

            add esi, Delta

            pop eax
            sub eax, 1
		    jnz @LM1

            //emms
            db $0f, $77

            popad
        end;
    end else
    {$ENDIF USE_MMX}
    for yDest := 0 to DstBitmap.Height -1 do begin
        rowDest := DstBitmap.ScanLine[yDest];
        for i := 0 to 1 do
            rowSrc[i] := SrcBitmap.ScanLine[yDest*2+i];
        for xDest := 0 to DstBitmap.Width-1 do begin
            xSrc := xDest*2;
            R:=0; G:=0; B:=0;
            for i := 0 to 1 do begin
                _rowSrc := rowSrc[i];
                R:= R+_rowSrc[xSrc+0].rgbRed
                    + _rowSrc[xSrc+1].rgbRed;
                G:= G+_rowSrc[xSrc+0].rgbGreen
                    + _rowSrc[xSrc+1].rgbGreen;
                B:= B+_rowSrc[xSrc+0].rgbBlue
                    + _rowSrc[xSrc+1].rgbBlue;
            end;
            DWORD(rowDest[xDest]) := ((R and $03fc) shl 14) or ((G and $03fc) shl 6) or (B shr 2);
        end;
    end;
end;

procedure BlendBitmaps(var DestBitmap, FromBitmap, ToBitmap: PBitmap; Factor: Integer; ClipRect:TRect);
type    AGRBQuad = array [0..0] of TRGBQuad;
        PAGRBQuad = ^AGRBQuad;
var     Factor2: byte;
        i, j: integer;
        DestRow: PAGRBQuad;
        FromRow: PAGRBQuad;
        ToRow: PAGRBQuad;
        {$IFDEF USE_MMX}
        FromDibBits: DWORD;
        ToDibBits: DWORD;
        DestDibBits: DWORD;
        _Width: integer;
        _Height: integer;
        _Right: integer;
        _Top: DWORD;
        {$ENDIF USE_MMX}
begin
    {$IFDEF USE_MMX}
    if UseMMX then begin
        _Top := FromBitmap.Width * 4 * ClipRect.Top + ClipRect.Left * 4;
        FromDibBits := DWORD(FromBitmap.DIBBits) + _Top;
        ToDibBits := DWORD(ToBitmap.DIBBits) + _Top;
        DestDibBits := DWORD(DestBitmap.DIBBits) + _Top;
        _Width := ClipRect.Right - ClipRect.Left;
        _Height := ClipRect.Bottom - ClipRect.Top;
        _Right := (FromBitmap.Width - ClipRect.Right + ClipRect.Left) * 4;
        asm
        mov edx, Factor
        mov dh, dl
        mov ax, dx
        shl eax, 16
        mov ax, dx

        mov esi, FromDibBits
		mov edi, ToDibBits
        mov edx, DestDibBits

        //pxor mm2, mm2
        db $0f, $ef, $d2
        //movd mm3, eax
        db $0f, $6e, $d8
        //punpcklbw mm3, mm2
        db $0f, $60, $da

        mov eax, $00404040
		//movd mm4, eax
        db $0f, $6e, $e0
        //punpcklbw mm4, mm2
        db $0f, $60, $e2
		//psubw mm4, mm3
        db $0f, $f9, $e3

        mov ecx, _Height
@LM1:
		mov ebx, _Width
@LM2:
        //movd mm0, [esi]
        db $0f, $6e, $06
		//movd mm1, [edi]
        db $0f, $6e, $0f
        //punpcklbw mm0, mm2
        db $0f, $60, $c2
		//punpcklbw mm1, mm2
        db $0f, $60, $ca
        //pmullw mm0, mm4
        db $0f, $d5, $c4
        //pmullw mm1, mm3
        db $0f, $d5, $cb
        //paddusw mm1, mm0
        db $0f, $dd, $c8
		//psrlw mm1, 6
        db $0f, $71, $d1, $06
        //packuswb mm1, mm2
        db $0f, $67, $ca
		//movd [edx], mm1
        db $0f, $7e, $0a

        add esi, 4
		add edi, 4
        add edx, 4

		sub ebx, 1
		jnz @LM2

        add esi, _Right
        add edi, _Right
        add edx, _Right

		sub ecx, 1
		jnz @LM1
		//emms
        db $0f, $77
        end
    end else
    {$ENDIF USE_MMX}
    begin
        Factor2 := 64-Factor;
        for i := ClipRect.Top to ClipRect.Bottom-1 do begin
            DestRow := DestBitmap.ScanLine[i];
            FromRow := FromBitmap.ScanLine[i];
            ToRow := ToBitmap.ScanLine[i];
            for j := ClipRect.Left to (ClipRect.Right-1) do begin
                DestRow[j].rgbBlue := ((FromRow[j].rgbBlue*Factor2) + (ToRow[j].rgbBlue*Factor)) shr 6;
                DestRow[j].rgbGreen := ((FromRow[j].rgbGreen*Factor2) + (ToRow[j].rgbGreen*Factor)) shr 6;
                DestRow[j].rgbRed := ((FromRow[j].rgbRed*Factor2) + (ToRow[j].rgbRed*Factor)) shr 6;
            end;
        end;
    end;
end;

destructor TGRushData.Destroy;
begin
    if fGlyphBitmap <> nil then
        fGlyphBitmap.RefDec;
    Free_And_Nil(fDefPatern);
    Free_And_Nil(fOverPatern);
    Free_And_Nil(fDownPatern);
    Free_And_Nil(fDisPatern);
    Free_And_Nil(fResultPatern);
    inherited;
end;

procedure TGRushControl.DrawControlState(var Bitmap: PBitmap; const BorderRect: TRect; const State: TGRushPaintState; UseDIB: boolean);


    procedure NewElipseFSAA(const State: TGRushPaintState; const BorderRect: TRect; {$IFDEF ALLOW_ANTIALIASING}AA: Boolean;{$ENDIF} aBRW:Integer; aBRH: Integer);
    {$IFDEF USE_2XAA_INSTEAD_OF_4XAA}
    const   Factor = 2;
    {$ELSE USE_2XAA_INSTEAD_OF_4XAA}
    const   Factor = 4;
    {$ENDIF USE_2XAA_INSTEAD_OF_4XAA}
    var     Wi, He: integer;
            {$IFDEF ALLOW_ANTIALIASING}
            TempBMP: PBitmap;
            {$ENDIF ALLOW_ANTIALIASING}
            DestDC: HDC;
            SrcDC: HDC;
            Rgn1: HRgn;
            Rgn2: HRgn;
            ElipseFSAA: PBitmap;
    begin
        with State do begin
            {$IFDEF ALLOW_ANTIALIASING}
            if AA then begin
                Wi := aBRW * Factor;
                He := aBRH * Factor;
                ElipseFSAA := NewDIBBitmap(Wi*2, He*2, pf32bit);
            end else {$ENDIF ALLOW_ANTIALIASING} begin
                Wi := aBRW;
                He := aBRH;
                ElipseFSAA := NewBitmap(Wi*2, He*2);
            end;
            {$IFDEF ALLOW_ANTIALIASING}
            ElipseFSAA.Canvas.Pen.PenWidth := BorderWidth * ((byte(AA)*(Factor-1))+1);
            {$ELSE ALLOW_ANTIALIASING}
            ElipseFSAA.Canvas.Pen.PenWidth := BorderWidth;
            {$ENDIF ALLOW_ANTIALIASING}
            DestDC := ElipseFSAA.Canvas.Handle;
            SrcDC := Bitmap.Canvas.Handle;
            StretchBlt(DestDC, 0, 0, Wi, He, SrcDC, BorderRect.Left, BorderRect.Top, aBRW
                , aBRH, SRCCOPY);
            StretchBlt(DestDC, Wi, 0, Wi, He, SrcDC, BorderRect.Right-aBRW, BorderRect.Top
                , aBRW, aBRH, SRCCOPY);
            StretchBlt(DestDC, 0, He, Wi, He, SrcDC, BorderRect.Left, BorderRect.Bottom-aBRH
                , aBRW, aBRH, SRCCOPY);
            StretchBlt(DestDC, Wi, He, Wi, He, SrcDC, BorderRect.Right-aBRW
                , BorderRect.Bottom-aBRH, aBRW, aBRH, SRCCOPY);

            with ElipseFSAA.Canvas{$ifndef F_P}^{$endif}, Pen{$ifndef F_P}^{$endif} do begin
                Rgn1 := CreateEllipticRgn(0, 0, Wi*2+1, He*2+1);
                Rgn2 := CreateRectRgn(0, 0, Wi*2, He*2);
                CombineRgn(Rgn1, Rgn1, Rgn2, RGN_XOR);
                Brush.Color := ColorOuter;
                FillRgn(Rgn1);
                Brush.BrushStyle := bsClear;
                DeleteObject(Rgn1);
                DeleteObject(Rgn2);
                
                if BorderWidth > 0 then begin
                    GeometricPen := true;
                    PenStyle := psInsideFrame;
                    Color := BorderColor;
                    Ellipse(-1, -1, Wi*2, He*2);
                end;
            end;
            {$IFDEF ALLOW_ANTIALIASING}
            if AA then begin
                TempBmp := NewDIBBitmap(aBRW*2, aBRH*2, pf32bit);
                {$IFDEF USE_2XAA_INSTEAD_OF_4XAA}
                BitmapAntialias2X(ElipseFSAA, TempBMP);
                {$ELSE USE_2XAA_INSTEAD_OF_4XAA}
                BitmapAntialias4X(ElipseFSAA, TempBMP);
                {$ENDIF USE_2XAA_INSTEAD_OF_4XAA}
                ElipseFsAA.Free;
                ElipseFsAA := TempBmp;
            end;
            {$ENDIF ALLOW_ANTIALIASING}
            DestDC := ElipseFSAA.Canvas.Handle;
            BitBlt(SrcDC, BorderRect.Left, BorderRect.Top
                , aBRW, aBRH, DestDC, 0, 0,  SRCCOPY);
            BitBlt(SrcDC, BorderRect.Right-aBRW, BorderRect.Top
                , aBRW, aBRH, DestDC, aBRW, 0,  SRCCOPY);
            BitBlt(SrcDC, BorderRect.Left, BorderRect.Bottom-aBRH
                , aBRW, aBRH, DestDC, 0, aBRH,  SRCCOPY);
            BitBlt(SrcDC, BorderRect.Right-aBRW, BorderRect.Bottom-aBRH
                , aBRW, aBRH, DestDC, aBRW, aBRH,  SRCCOPY);
        end;
        ElipseFsAA.Free;
    end;

    procedure GradientFill(const State: TGRushPaintState; DC: HDC; const BorderRect: TRect);
    type    TGradientRect = packed record
                UpperLeft: ULONG;
                LowerRight: ULONG;
            end;
    const   PatternSize = 32;
            FromSize = 6;
            GRADIENT_FILL_RECT_H = $00000000;
            GRADIENT_FILL_RECT_V = $00000001;
    var     TR, ATR: TRect;
            {$IFDEF FIX_16BITMODE}
            vert: Array[0..3] of TRIVERTEX;
            gTRi: TGradientRect;
            Align: Integer;
            tDC: HDC;
            {$ENDIF FIX_16BITMODE}
            C1, C2: TRGBQuad;
            R1, R2, B1, B2, G1, G2: integer;
            RectW, RectH: integer;
            W, H, DW, DH, WH: integer;
            Pattern: PBitmap;
            i, C: integer;
            Br: HBrush;
    begin
        RectH := BorderRect.Bottom - BorderRect.Top;
        RectW := BorderRect.Right - BorderRect.Left;
        if (RectH<=0) or (RectW<=0) then
            exit;

        C1 := TRGBQuad(Color2RGB(State.ColorFrom));
        C2 := TRGBQuad(Color2RGB(State.ColorTo));
        R1 := C1.rgbRed;
        R2 := C2.rgbRed;
        G1 := C1.rgbGreen;
        G2 := C2.rgbGreen;
        B1 := C1.rgbBlue;
        B2 := C2.rgbBlue;
        {$IFDEF FIX_16BITMODE}
        vert[0].x := 0;
        vert[0].y := 0;
        vert[0].Red := B1 shl 8;
        vert[0].Green := G1 shl 8;
        vert[0].Blue := R1 shl 8;
        vert[0].Alpha := $00;
        vert[1].Red := B2 shl 8;
        vert[1].Green := G2 shl 8;
        vert[1].Blue := R2 shl 8;
        vert[1].Alpha := $00;
        vert[2] := vert[0];
        vert[2].x := RectW;
        vert[2].y := 0;
        gTRi.UpperLeft := 0;
        gTRi.LowerRight := 1;
        {$ENDIF FIX_16BITMODE}
        R2 := R2 - R1;
        G2 := G2 - G1;
        B2 := B2 - B1;
        DW := 0;
        DH := 0;
        
        case State.GradientStyle of
            gsHorizontal:
                begin
                    W := RectW;
                    H := PatternSize;
                    WH := W;
                end;
            gsVertical:
                begin
                    W := PatternSize;
                    H := RectH;
                    WH := H;
                end;
            gsDoubleHorz:
                begin
                    DW := RectW;
                    W := DW shr 1;
                    H := PatternSize;
                    DH := H;
                    WH := W;
                end;
            gsDoubleVert:
                begin
                    W := PatternSize;
                    DH := RectH;
                    H := DH shr 1;
                    DW := W;
                    WH := H;
                    {$IFDEF FIX_16BITMODE}
                    vert[2].x := 0;
                    vert[2].y := RectH;
                    {$ENDIF FIX_16BITMODE}
                end;
            gsFromTopLeft,
            gsFromTopRight:
                begin
                    W := RectH + RectW;
                    H := 1 + (RectH div 32);
                    if H > 6 then
                        H := 6;
                    WH := W;
                end;
            else exit;
        end;

        if not (State.GradientStyle in [gsDoubleVert, gsDoubleHorz]) then begin
            DW := W;
            DH := H;
        end;
        Pattern := NewBitMap(DW, DH);
        {$IFDEF FIX_16BITMODE}
        vert[1].x := W;
        vert[1].y := H;
        
        if State.GradientStyle in [gsVertical, gsDoubleVert] then
            align := GRADIENT_FILL_RECT_V
        else
            align := GRADIENT_FILL_RECT_H;

        if UseSystemGradient then begin   //UseSystemGradient
            tDC := Pattern.Canvas.Handle;
            if State.GradientStyle in [gsDoubleHorz, gsDoubleVert] then
                sysGradientFill(tDC, @(vert[1]), 2, @gTRI, 1, align);
            sysGradientFill(tDC, @vert, 2, @gTRI, 1, align);
        end else begin                    //UseSystemGradient
        {$ENDIF FIX_16BITMODE}
            case State.GradientStyle of
                gsVertical, gsDoubleVert:
                    begin
                        TR := MakeRect(0, 0, DW, 1);
                        DW := 0;
                        DH := 1;
                    end;
                gsHorizontal, gsFromTopLeft, gsFromTopRight, gsDoubleHorz:
                    begin
                        TR := MakeRect(0, 0, 1, DH);
                        DW := 1;
                        DH := 0;
                    end;
            end;
            if State.GradientStyle = gsDoubleVert then
                ATR := MakeRect(0, RectH-1, PatternSize, RectH);
            if State.GradientStyle = gsDoubleHorz then
                ATR := MakeRect(RectW-1, 0, RectW, PatternSize);
            for i := 0 to WH do begin
                C := ((( R1 + R2 * I div WH ) and $FF) shl 16) or
                    ((( G1 + G2 * I div WH ) and $FF) shl 8) or
                    ( B1 + B2 * I div WH ) and $FF;
                Br := CreateSolidBrush( C );
                Windows.FillRect(Pattern.Canvas.Handle, TR, Br );

                if State.GradientStyle in [gsDoubleHorz, gsDoubleVert] then
                    Windows.FillRect(Pattern.Canvas.Handle, ATR, Br);
                OffsetRect(ATR, -DW, -DH);
                OffsetRect(TR, DW, DH);
                DeleteObject( Br );
            end;
        {$IFDEF FIX_16BITMODE}
        end;                           //UseSystemGradient
        {$ENDIF FIX_16BITMODE}

        case State.GradientStyle of
            gsHorizontal, gsDoubleHorz:
                for i := 0 to (BorderRect.Bottom div PatternSize) do
                    Pattern.Draw(DC, BorderRect.Left, BorderRect.Top + i*PatternSize);
            gsVertical, gsDoubleVert:
                for i := 0 to (BorderRect.Right div PatternSize) do
                    Pattern.Draw(DC, BorderRect.Left + i*PatternSize, BorderRect.Top);
            gsFromTopLeft:
                for i := 0 to ((BorderRect.Bottom + H -1) div H)-1 do
                    Pattern.Draw(DC, BorderRect.Left + -i*H, BorderRect.Top + i*H);
            gsFromTopRight:
                for i := 0 to ((BorderRect.Bottom + H -1) div H)-1 do
                    Pattern.Draw(DC, BorderRect.Left - BorderRect.Bottom + i*H, BorderRect.Top + i*H);
        end;
        Pattern.Free;
    end;

    function Atom1(par1: integer; par2: integer; par3: integer): integer;
    begin
        result := ((par1-(5*par3-2)) div 2) + par2*5;
    end;

    procedure MaxMin4( Data: PGRushData; var M: Integer; var N: Integer);
    begin
        M := Max(Data.fPSDef.ShadowOffset, Data.fPSOver.ShadowOffset);
        M := Max(M, Data.fPSDown.ShadowOffset);
        M := Max(M, Data.fPSDis.ShadowOffset);
        N := Min(Data.fPSDef.ShadowOffset, Data.fPSOver.ShadowOffset);
        N := Min(N, Data.fPSDown.ShadowOffset);
        N := Min(N, Data.fPSDis.ShadowOffset);
        if M < 0 then
            M := 0;
        if N > 0 then
            N := 0;
    end;

var     W, H: Integer;
        TextClipRect: TRect;
        _TextRect: TRect;
        {$IFDEF ALLOW_GLYPH}
        GlyphH, GlyphW: DWORD;
        GlyphRect: TRect;
        aDrawGlyph: Boolean;
        R1, R2: TRect;
        {$ENDIF ALLOW_GLYPH}
        ContentRect: TRect;
        Data: PGRushData;
        aDrawText: Boolean;
        M, N, i: integer;
        _ti: integer;
        Flags: integer;
        aBRW, aBRH: Integer;
        Cpt: String;
        TBM: PBitmap;
        blend: TBlendFunction;

begin
    W := Width;
    H := Height;
    if (W<=0) or (H<=0) then
        exit;
    if not (Bitmap = nil) then
        Bitmap.Free;
    {$IFDEF FIX_16BITMODE}
    if WinVer < wvY2K then



      Bitmap := NewDibBitMap(W, H, pf32bit)
    else
    {$ENDIF FIX_16BITMODE}
    if UseDIB then
      Bitmap := NewDIBBitMap(W, H, pf32bit)
    else
    Bitmap := NewBitMap(W, H);

    with Bitmap.Canvas{$ifndef F_P}^{$endif}, BorderRect, State do begin
        M := Right - Left;
        N := Bottom - Top;
        if integer(BorderRoundWidth)*2 > M then
            aBRW := (M+1) shr 1
        else
            aBRW := BorderRoundWidth;
        if integer(BorderRoundHeight)*2 > N then
            aBRH := (N+1) shr 1
        else
            aBRH := BorderRoundHeight;

        if (State.ColorFrom = State.ColorTo) or (State.GradientStyle = gsSolid) then begin
            Brush.Color := State.ColorFrom;
            FillRect(BorderRect);
        end else begin
            GradientFill(State, Handle, BorderRect);
        end;

        Pen.Color := BorderColor;
        Brush.Color := BorderColor;
        Rectangle(Left+aBRW, Top, Right-aBRW, DWORD(Top)+BorderWidth);
        Rectangle(Left+aBRW, Bottom-Integer(BorderWidth), Right-aBRW, Bottom);
        Rectangle(Left, Top+aBRH, DWORD(Left)+BorderWidth, Bottom-aBRH);
        Rectangle(Right-Integer(BorderWidth), Top+aBRH, Right, Bottom-aBRH);

        Pen.Color := ColorOuter;
        Brush.Color := ColorOuter;
        Rectangle(0, 0, Left, Bottom);
        Rectangle(Left, 0, W, Top);
        Rectangle(Right, Top, W, H);
        Rectangle(0, Bottom, Right, H);
    end;

    Data := PGRushData(CustomObj);

    if (aBRW>0) and (aBRH>0) and (M>0) and (N>0) then
        NewElipseFSAA(State, BorderRect, {$IFDEF ALLOW_ANTIALIASING}Data.fAntiAliasing,{$ENDIF} aBRW, aBRH);

    ContentRect := AddRects(ClientRect, Data.fContentOffsets);
    TextClipRect := ContentRect;
    {$IFDEF ALLOW_GLYPH}
    aDrawGlyph := (Data.fDrawGlyph) and (Data.fGlyphBitmap <> nil) and (not Data.fGlyphBitmap.Empty)
        and (Data.fGlyphWidth <= DWORD(TextClipRect.Right - TextClipRect.Left))
        and (Data.fGlyphHeight <= DWORD(TextClipRect.Bottom - TextClipRect.Top))
        and (Data.fGlyphWidth > 0) and (Data.fGlyphHeight > 0);
    aDrawText := Data.fDrawText and ((Caption <> '') or (Data.fDrawProgress));
    if aDrawGlyph then begin
        GlyphH := Data.fGlyphHeight + Data.fSpacing;
        GlyphW := Data.fGlyphWidth + Data.fSpacing;
        if Data.fCropTopFirst then
            case Data.fGlyphVAlign of
                vaTop:
                    Inc(TextClipRect.Top, GlyphH);
                vaBottom:
                    Dec(TextClipRect.Bottom, GlyphH);
                vaCenter:
                    case Data.fGlyphHAlign of
                        haLeft:
                            Inc(TextClipRect.Left, GlyphW);
                        haRight:
                            Dec(TextClipRect.Right, GlyphW);
                        haCenter:
                            if aDrawText then
                                aDrawGlyph := False;
                    end;
            end
        else
            case Data.fGlyphHAlign of
                haLeft:
                    Inc(TextClipRect.Left, GlyphW);
                haRight:
                    Dec(TextClipRect.Right, GlyphW);
                haCenter:
                    case Data.fGlyphVAlign of
                        vaTop:
                            Inc(TextClipRect.Top, GlyphH);
                        vaBottom:
                            Dec(TextClipRect.Bottom, GlyphH);
                        vaCenter:
                            if aDrawText then
                                aDrawGlyph := False;
                    end;
            end;
    end;
    {$ELSE ALLOW_GLYPH}
    aDrawText := Data.fDrawText and ((Caption <> '') or (Data.fDrawProgress));
    {$ENDIF ALLOW_GLYPH}
    MaxMin4(Data, M, N);
    TextClipRect := AddRects(TextClipRect, MakeRect(-N, -N, -M, -M));
    _TextRect := TextClipRect;

    aDrawText := aDrawText and (_TextRect.Right - _TextRect.Left > 2)
        and (_TextRect.Bottom - _TextRect.Top > 2);

    with Bitmap.Canvas{$ifndef F_P}^{$endif} do begin
        Brush.BrushStyle := bsClear;
        if  Data.fDrawProgressRect then begin
            Pen.PenStyle := psSolid;
            Pen.Color := State.BorderColor;
            Rectangle(0, 0, W, H);
        end;
    
        if aDrawText then begin
            if Data.fDrawProgress then
                {$ifndef F_P}
                Cpt := Format('%d%s',[Data.fProgress, Caption])
                {$else}
                Cpt := int2str(Data.fProgress) + Caption
                {$endif}
            else
                Cpt := Caption;
            Font.Assign(Self.Font);
            DrawText(Cpt, _TextRect, DT_EDITCONTROL or DT_CALCRECT or DT_WORDBREAK or DT_END_ELLIPSIS);
            IntersectRect(_TextRect, _TextRect, TextClipRect);
    
            _ti := TextHeight('_');
            _TextRect.Bottom := _TextRect.Bottom - ((_TextRect.Bottom - _TextRect.Top) mod _ti);
            if _TextRect.Bottom = _TextRect.Top then
                _TextRect.Bottom := _TextRect.Top + _ti;
    
            AlignRect(_TextRect, TextClipRect, Data.fTextVAlign, Data.fTextHAlign);
            Flags := DT_EDITCONTROL + DT_WORDBREAK + DT_END_ELLIPSIS or integer(Data.fTextHAlign);

            Font.Color := State.ColorShadow;
            OffsetRect(_TextRect, State.ShadowOffset, State.ShadowOffset);
            Bitmap.Canvas.DrawText(Cpt, _TextRect, Flags);

            Font.Color := State.ColorText;
            OffsetRect(_TextRect, -State.ShadowOffset, -State.ShadowOffset);
            Bitmap.Canvas.DrawText(Cpt, _TextRect, Flags);
        end;

        {$IFDEF ALLOW_GLYPH}
        if aDrawGlyph then begin
            with Data.fGlyphBitmap{$ifndef F_P}^{$endif}  do begin
                GlyphW := Data.fGlyphWidth;
                GlyphH := Data.fGlyphHeight;
                if Data.fGlyphAttached then begin

                end else begin
                    GlyphRect := MakeRect(0, 0, GlyphW, GlyphH);
                    AlignRect(GlyphRect, ContentRect, Data.fGlyphVAlign, Data.fGlyphHAlign);
                end;

                {$IFDEF FIX_16BITMODE} ///////////// +++ tool bar buttons!64K colors!
                TBM := NewDibBitMap(GlyphW, GlyphH, pf32bit);
                {$ELSE}
                TBM := NewBitMap(GlyphW, GlyphH);
                {$ENDIF FIX_16BITMODE}

                R1 := MakeRect(0, 0, GlyphW, GlyphH);
                R2 := R1;
                OffsetRect(R2, State.GlyphItemX*GlyphW, State.GlyphItemY*GlyphH);
                TBM.Canvas.CopyRect(R1, Canvas, R2);
                {$IFDEF FIX_DRAWTRANSPARENT}
                if Data.fAlphaChannel then
                begin
                  blend.BlendOp := AC_SRC_OVER;
                  blend.BlendFlags := 0;
                  blend.SourceConstantAlpha := Data.fAlphaBlendValue;
                  blend.AlphaFormat := AC_SRC_NO_PREMULT_ALPHA;
                  _AlphaBlend(Bitmap.Canvas.Handle, GlyphRect.Left, GlyphRect.Top, GlyphW, GlyphH,
                              TBM.Canvas.Handle, 0, 0, GlyphW, GlyphH, blend);
                end
                else
                  myDrawTransparent(TBM, Bitmap.Canvas.Handle, GlyphRect.Left, GlyphRect.Top, Pixels[0,0]);
                {$ELSE FIX_DRAWTRANSPARENT}
                TBM.DrawTransparent(Bitmap.Canvas.Handle, GlyphRect.Left, GlyphRect.Top, Pixels[0,0]);
                {$ENDIF FIX_DRAWTRANSPARENT}
                TBM.Free;
            end;
        end;
        {$ENDIF ALLOW_GLYPH}
        Brush.BrushStyle := bsSolid;
        Brush.Color := clGray;
        for i := 0 to Data.fSplitterDotsCount-1 do begin
            M := ((W - 3) div 2);
            N := ((H - 3) div 2);
            if (Align in [caLeft, caRight])
               or
               ( (Align = caNone) and
                 (Data.fSplDotsOrient = orVertical)
               ) then

                N := Atom1(H, i, Data.fSplitterDotsCount)
            else
                M := Atom1(W, i, Data.fSplitterDotsCount);
            FillRect(MakeRect(M, N, M + 3, N + 3));
            Pixels[M, N] := clWhite;
        end;
    end;

(*    {$IFDEF NOT_IMMIDIATLYONLY}
    if UseDIB then  begin
        TBM := NewDIBBitmap(W, H, pf32bit);
        Bitmap.Draw(TBM.Canvas.Handle, 0, 0);
        Bitmap.Free;
        Bitmap := TBM;
    end;
    {$ENDIF NOT_IMMIDIATLYONLY}*)

    Bitmap.RemoveCanvas;
end;

procedure TGRushControl.CheckNeedUpdate(ToUpdate: TGRushToUpdate; UseDIBs: Boolean);
var     Data: PGRushData;
begin
    Data := PGRushData(CustomObj);
    if Data.fDefNeedUpdate and (tuDef in ToUpdate) then begin
        DrawControlState(Data.fDefPatern, Data.fRects.DefBorderRect, Data.fPSDef, UseDIBs);
        Data.fDefNeedUpdate := false;
    end;
    if Data.fOverNeedUpdate and (tuOver in ToUpdate) then begin
        DrawControlState(Data.fOverPatern, Data.fRects.OverBorderRect, Data.fPSOver, UseDIBs);
        Data.fOverNeedUpdate := false;
    end;
    if Data.fDownNeedUpdate and (tuDown in ToUpdate) then begin
        DrawControlState(Data.fDownPatern, Data.fRects.DownBorderRect, Data.fPSDown, UseDIBs);
        Data.fDownNeedUpdate := false;
    end;
    if Data.fDisNeedUpdate and (tuDis in ToUpdate) then begin
        DrawControlState(Data.fDisPatern, Data.fRects.DisBorderRect, Data.fPSDis, FALSE);
        Data.fDisNeedUpdate := false;
    end;
end;

{$IFDEF NOT_IMMIDIATLYONLY}
procedure TGRushControl.TimerEvent(Data: PGRushData);
var     FromBitmap: PBitmap;
        ToBitmap: PBitmap;
        W, H: Integer;
begin
    case Data.fCurrentOperation of
        coDefToDown, coDefToOver:
            begin
                CheckNeedUpdate([tuDef], true);
                FromBitmap := Data.fDefPatern;
            end;
        coOverToDef, coOverToDown:
            begin
                CheckNeedUpdate([tuOver], true);
                FromBitmap := Data.fOverPatern;
            end;
        coDownToDef, coDownToOver:
            begin
                CheckNeedUpdate([tuDown], true);
                FromBitmap := Data.fDownPatern;
            end;
        else exit;
    end;
    case Data.fCurrentOperation of
        coOverToDef, coDownToDef:
            begin
                CheckNeedUpdate([tuDef], true);
                ToBitmap := Data.fDefPatern;
            end;
        coDefToOver, coDownToOver:
            begin
                CheckNeedUpdate([tuOver], true);
                ToBitmap := Data.fOverPatern;
            end;
        coDefToDown, coOverToDown:
            begin
                CheckNeedUpdate([tuDown], true);
                ToBitmap := Data.fDownPatern;
            end;
        else exit;
    end;

    W := ToBitmap.Width;
    H := ToBitmap.Height;
    if Data.fResultPatern = nil then
        Data.fResultPatern := NewDIBBitmap(W, H, pf32bit);
    with Data.fRects.AlphaRect, Data{$ifndef F_P}^{$endif}  do
        if (Left>0) or (Top>0) or (Width > Right) or (Height > Bottom) then begin
            CheckNeedUpdate([tuDef], true);
            fDefPatern.Draw (fResultPatern.Canvas.Handle, 0, 0);
        end;
    BlendBitmaps(Data.fResultPatern, FromBitmap, ToBitmap, Data.fBlendPercent, Data.fRects.AlphaRect);
    Data.fResultNeedUpdate := FALSE;
    {$IFDEF USE_MEMSAVEMODE}
    if (Data.fCurrentOperation in [coOverToDef, coDownToDef]) and (Data.fBlendPercent >= 64) then begin
        CleanMem(Data);
    end;
    {$ENDIF}
end;
{$ELSE NOT_IMMIDIATLYONLY}
procedure TGRushControl.TimerEvent(Data: PGRushData);
var     ToBitmap: PBitmap;
        W, H: Integer;
begin
    case Data.fCurrentOperation of
        coOverToDef, coDownToDef:
            begin
                CheckNeedUpdate([tuDef], true);
                ToBitmap := Data.fDefPatern;
            end;
        coDefToOver, coDownToOver:
            begin
                CheckNeedUpdate([tuOver], true);
                ToBitmap := Data.fOverPatern;
            end;
        coDefToDown, coOverToDown:
            begin
                CheckNeedUpdate([tuDown], true);
                ToBitmap := Data.fDownPatern;
            end;
        else exit;
    end;

    W := ToBitmap.Width;
    H := ToBitmap.Height;
    if Data.fResultPatern = nil then
        Data.fResultPatern := NewBitmap(W, H);
    with Data.fRects.AlphaRect, Data^ do
        if (Left>0) or (Top>0) or (Width > Right) or (Height > Bottom) then begin
            CheckNeedUpdate([tuDef], true);
            fDefPatern.Draw (fResultPatern.Canvas.Handle, 0, 0);
        end;
    Data.fResultPatern.CopyRect(Data.fRects.AlphaRect, ToBitmap, Data.fRects.AlphaRect);
    Data.fResultNeedUpdate := false;
    Invalidate;
end;
{$ENDIF NOT_IMMIDIATLYONLY}

procedure TGrushControl.UpdateProgress;
var     Data: PGRushData;
        tH: integer;
begin
    Data := PGRushData(CustomObj);
    with Data{$ifndef F_P}^{$endif}  do begin
        if Data.fProgressVertical then
            tH := Height
        else
            tH := Width;
        if tH <= 2 then exit;
        if fProgressRange > 0 then
            tH := (INT64(tH - 2) * fProgress) div fProgressRange
        else
            tH := 0;
        if Data.fProgressVertical then
            fRects.DefBorderRect := MakeRect(0, Height-tH-1, Width, Height)
        else
            fRects.DefBorderRect := MakeRect(1, 0, tH+1, Height);
        fRects.DisBorderRect := fRects.DefBorderRect;
    end;
    if assigned(Data.fOnRecalcRects) then
        Data.fOnRecalcRects({$ifndef F_P}@{$endif} Self, Data.fRects);
    SetAllNeedUpdate;
end;

procedure TGRushControl.CleanMem(Data: PGRushData);
begin
        Free_And_Nil(Data.fOverPatern);
        Data.fOverNeedUpdate := TRUE;
        Free_And_Nil(Data.fDownPatern);
        Data.fDownNeedUpdate := TRUE;
        Free_And_Nil(Data.fResultPatern);
        Data.fResultNeedUpdate := TRUE;
end;

procedure TGRushControl.DoPaint( Ctl_: PControl; DC:HDC );
var     Data: PGRushData;
        {$IFDEF ALLOW_CONTROLSTRANSPARANSY}
        TransColor: TColor;
        {$ENDIF ALLOW_CONTROLSTRANSPARANSY}
        _Rgn: HRGN;
        tH: DWORD;
        RG: HRGN;
        cx, cy: integer;
        ContentRect: TRect;
begin
    Data := PGRushData(CustomObj);
    {$IFDEF ALLOW_CONTROLSTRANSPARANSY}
    TransColor := Data.fPSDef.ColorOuter;
    {$ENDIF ALLOW_CONTROLSTRANSPARANSY}
    if not Enabled then begin
        {$IFDEF USE_MEMSAVEMODE}
        CleanMem(Data);
        Free_And_Nil(Data.fDefPatern);
        Data.fDefNeedUpdate := TRUE;
        {$ENDIF USE_MEMSAVEMODE}
        CheckNeedUpdate([tuDis], false);
        {$IFDEF ALLOW_CONTROLSTRANSPARANSY}
        if Transparent then
            {$IFDEF FIX_DRAWTRANSPARENT}
            myDrawTransparent(Data.fDisPatern, DC, 0, 0, TransColor)
            {$ELSE FIX_DRAWTRANSPARENT}
            Data.fDisPatern.DrawTransparent(DC, 0, 0, TransColor)
            {$ENDIF FIX_DRAWTRANSPARENT}
        else
        {$ENDIF ALLOW_CONTROLSTRANSPARANSY}
            Data.fDisPatern.Draw(DC, 0, 0);
    end else begin
        if Data.fResultNeedUpdate then begin
            {$IFDEF USE_MEMSAVEMODE}
            Free_And_Nil(Data.fDisPatern);
            Data.fDisNeedUpdate := TRUE;
            {$ENDIF USE_MEMSAVEMODE}
            CheckNeedUpdate([tuDef], Data.fNeedDib);
            {$IFDEF ALLOW_CONTROLSTRANSPARANSY}
            if Transparent then begin
                {$IFDEF FIX_DRAWTRANSPARENT}
                myDrawTransparent(Data.fDefPatern, DC, 0, 0, TransColor)
                {$ELSE FIX_DRAWTRANSPARENT}
                Data.fDefPatern.DrawTransparent(DC, 0, 0, TransColor)
                {$ENDIF FIX_DRAWTRANSPARENT}
            end else
            {$ENDIF ALLOW_CONTROLSTRANSPARANSY}
                Data.fDefPatern.Draw(DC, 0, 0);
        end else
            {$IFDEF ALLOW_CONTROLSTRANSPARANSY}
            if Transparent then
                {$IFDEF FIX_DRAWTRANSPARENT}
                myDrawTransparent(Data.fResultPatern, DC, 0, 0, TransColor)
                {$ELSE FIX_DRAWTRANSPARENT}
                Data.fResultPatern.DrawTransparent(DC, 0, 0, TransColor)
                {$ENDIF FIX_DRAWTRANSPARENT}
            else
            {$ENDIF ALLOW_CONTROLSTRANSPARANSY}
                Data.fResultPatern.Draw(DC, 0, 0);
    end;

    if Checked then begin
        tH := CreateSolidBrush(Data.fColorCheck);
        RG := CreateRectRgn(0, 0, 0, 0);
        if Data.fControlType = ctRadioBox then
            _Rgn := RadioRgn
        else
            _Rgn := CheckRgn;
        CombineRgn(RG, _Rgn, 0, RGN_COPY);
        with Data.fRects.DefBorderRect do begin
            cx := (Right + Left - 17) div 2;
            cy := (Bottom + Top - 11) div 2;
        end;
        OffsetRgn(RG, cx, cy);
        FillRgn(DC, RG, tH);
        DeleteObject(RG);
        DeleteObject(tH);
    end;

    if Data.fActive and Data.fDrawFocusRect then begin
        ContentRect := AddRects(ClientRect, Data.fContentOffsets);
        InflateRect(ContentRect, 1, 1);
        DrawFocusRect(DC, ContentRect);
    end;
end;

function WndProcGRush(Ctl_: PGRushControl; var Msg: TMsg; var Rslt: Integer): Boolean;
var     Data: PGRushData;
        tH: DWORD;
        TU: TGRushToUpdate;
        ChM: DWORD;
        H: DWORD;
begin
    result := FALSE;

    Data := PGRushData(Ctl_.CustomObj);
{
    if (Msg.message >= WM_MOUSEFIRST) and (Msg.Message <= WM_MOUSELAST)and not Data.fMouseEnter then
       begin
         Data.fMouseEnter := true;
         Ctl_.DoEnter(Ctl_);
        end;
}
    if (Msg.message > WM_MOUSEFIRST) and (Msg.Message < WM_MOUSELAST) and (not Data.fNeedDib) then
        exit; 

    case Msg.message of
        BM_GETCHECK:
            begin
                Rslt := Integer(Ctl_.fChecked);
                Result := TRUE;
            end;
        BM_SETCHECK:
            begin
                Ctl_.fChecked := Boolean(Msg.wParam);
                if Boolean(Msg.wParam) then
                    Ctl_.DeactivateSublings;
                Ctl_.Invalidate;
                Result := TRUE;
            end;
        PBM_GETPOS:
            begin
                Rslt := Data.fProgress;
                Result := TRUE;
            end;
        PBM_SETPOS:
            begin
                Rslt := Data.fProgress;
                if Msg.wParam > 0 then
                    Data.fProgress := Msg.wParam
                else
                    Data.fProgress := 0;
                if Data.fProgress > Data.fProgressRange then
                    Data.fProgress := Data.fProgressRange;
                PGrushControl(Ctl_).UpdateProgress;
                if Assigned(Data.fOnProgressChange) then
                    Data.fOnProgressChange(Ctl_);
                Result := TRUE;
            end;
        PBM_GETRANGE:
            begin
                Rslt := Data.fProgressRange;
                Result := TRUE;
            end;
        PBM_SETRANGE32:
            begin
                Data.fProgressRange := Msg.lParam;
                PGrushControl(Ctl_).UpdateProgress;
                Result := TRUE;
            end;
        WM_SETTEXT:
            PGRushControl(Ctl_).SetAllNeedUpdate;
        WM_SIZE:
            with Data{$ifndef F_P}^{$endif}  do begin
                Free_And_Nil(Data.fResultPatern);
                PGRushControl(Ctl_).SetAllNeedUpdate;
                if fControlType in [ctCheckBox, ctRadioBox] then begin
                    tH := Ctl_.Height;
                    ChM := fCheckMetric;
                    if ChM > tH then
                        ChM := tH;
                    H := (tH - ChM) div 2;
                    fRects.DefBorderRect := MakeRect(2, H, 2+ChM, H+ChM);
                end else
                    fRects.DefBorderRect := Ctl_.ClientRect;
                fRects.OverBorderRect := fRects.DefBorderRect;
                fRects.DownBorderRect := fRects.DefBorderRect;
                fRects.DisBorderRect := fRects.DefBorderRect;
                fRects.AlphaRect := Ctl_.ClientRect;
                if fControlType = ctProgressBar then
                    PGrushControl(Ctl_).UpdateProgress
                else if assigned(Data.fOnRecalcRects) then
                    Data.fOnRecalcRects(PGRushControl(Ctl_), Data.fRects); 
                Ctl_.Invalidate;
            end;
        WM_NCDESTROY:
            begin
                RemoveProp( Ctl_.fHandle, ID_GRUSHTYPE );
            end;
        WM_CREATE:
            begin
                SetProp(Ctl_.Handle, ID_GRUSHTYPE, DWORD(Data.fControlType));
            end;
        WM_SHOWWINDOW:
            begin
                if Ctl_.Enabled then
                    TU := [tuDef]
                else
                    TU := [tuDis];
                Ctl_.CheckNeedUpdate(TU, Data.fNeedDib); 
            end;
        {$IFDEF NOT_IMMIDIATLYONLY}
        WM_TIMER:
            if Msg.wParam = 8 then begin
                Rslt := 0;
                Result := true;
                inc(Data.fBlendPercent, AlphaIncrement[Data.fUpdateSpeed]);
                if Data.fBlendPercent >= 64 then begin
                    Data.fBlendPercent := 64;
                    KillTimer(Ctl_.Handle, 8);
                end;
                Ctl_.TimerEvent(Data);
                Ctl_.Invalidate;
            end;
        {$ENDIF NOT_IMMIDIATLYONLY}
        WM_RBUTTONDOWN:
            if not Ctl_.Focused then begin
                Ctl_.Focused:=true;
                Ctl_.Invalidate;
            end;
        WM_LBUTTONDOWN:
            if ((Data.fStateInit = siNone) or (Ctl_.Focused = false)) then begin
                Ctl_.Focused:=true;
                Data.fStateInit := siButton;
                PGRushControl(Ctl_).DoPush;
            end;
        WM_LBUTTONUP:
            if (Data.fStateInit = siButton) then begin
                PGRushControl(Ctl_).DoPop;
                Data.fStateInit := siNone;
            end;
        WM_KEYDOWN:
            if (Msg.wParam = 32) and (Data.fStateInit = siNone) then begin
                Data.fStateInit := siKey;
                PGRushControl(Ctl_).DoPush;
            end;
        WM_KEYUP:
            if (Msg.wParam = 32) and (Data.fStateInit = siKey) then begin
                PGRushControl(Ctl_).DoPop;
                Data.fStateInit := siNone;
            end;
        WM_SETFOCUS:
            begin
                Data.fActive := true;
                Ctl_.Invalidate;
            end;
        WM_KILLFOCUS:
            begin
                if (Data.fStateInit = siKey) then begin
                    Data.fStateInit := siButton;
                    PGRushControl(Ctl_).fOnMouseLeave(Ctl_);
                    Data.fStateInit := siNone;
                end;
                Data.fActive := false;
                Ctl_.Invalidate;
            end;
{        WM_MOUSELEAVE:
           begin
                Ctl_.DoExit(Ctl_);
                Data.fMouseEnter := false;
           end;
}    end;
end;

function TrackMouseEvent(var EventTrack: TTrackMouseEvent): BOOL; stdcall; external user32 name 'TrackMouseEvent';

function WndProcGRushMouse(Ctl_: PGRushControl; var Msg: TMsg; var Rslt: Integer): Boolean;
var     Data: PGRushData;
    Track: TTrackMouseEvent;
begin
    result := FALSE;

    Data := PGRushData(Ctl_.CustomObj);

    if (Msg.message >= WM_MOUSEFIRST) and (Msg.Message <= WM_MOUSELAST) and (Msg.Message <> WM_MOUSEWHEEL) and not Data.fMouseEnter then
       begin
          Data.fMouseEnter := true;
          Ctl_.DoEnter(Ctl_);
          Track.cbSize := Sizeof( Track );
          Track.dwFlags := TME_LEAVE;
          Track.hwndTrack := Ctl_.Handle;
          TrackMouseEvent( Track );
        end;

    if Msg.message = WM_MOUSELEAVE then
       begin
          Ctl_.DoExit(Ctl_);
          Data.fMouseEnter := false;
       end;
end;

function TGRushControl.GetDef_ColorFrom;
    begin Result := PGRushData(CustomObj).fPSDef.ColorFrom; end;
procedure TGRushControl.SetDef_ColorFrom;
    begin PGRushData(CustomObj).fDefNeedUpdate := true;
    PGRushData(CustomObj).fPSDef.ColorFrom := Val; end;
function TGRushControl.GetDef_ColorTo;
    begin Result := PGRushData(CustomObj).fPSDef.ColorTo; end;
procedure TGRushControl.SetDef_ColorTo;
    begin PGRushData(CustomObj).fDefNeedUpdate := true;
    PGRushData(CustomObj).fPSDef.ColorTo := Val; end;
function TGRushControl.GetDef_ColorOuter;
    begin Result := PGRushData(CustomObj).fPSDef.ColorOuter; end;
procedure TGRushControl.SetDef_ColorOuter;
    begin PGRushData(CustomObj).fDefNeedUpdate := true;
    PGRushData(CustomObj).fPSDef.ColorOuter := Val; end;
function TGRushControl.GetDef_ColorText;
    begin Result := PGRushData(CustomObj).fPSDef.ColorText; end;
procedure TGRushControl.SetDef_ColorText;
    begin PGRushData(CustomObj).fDefNeedUpdate := true;
    PGRushData(CustomObj).fPSDef.ColorText := Val; end;
function TGRushControl.GetDef_ColorShadow;
    begin Result := PGRushData(CustomObj).fPSDef.ColorShadow;end;
procedure TGRushControl.SetDef_ColorShadow;
    begin PGRushData(CustomObj).fDefNeedUpdate := true;
    PGRushData(CustomObj).fPSDef.ColorShadow := Val; end;
function TGRushControl.GetDef_BorderColor;
    begin Result := PGRushData(CustomObj).fPSDef.BorderColor;end;
procedure TGRushControl.SetDef_BorderColor;
    begin PGRushData(CustomObj).fDefNeedUpdate := true;
    PGRushData(CustomObj).fPSDef.BorderColor := Val; end;
function TGRushControl.GetDef_BorderWidth;
    begin Result := PGRushData(CustomObj).fPSDef.BorderWidth;end;
procedure TGRushControl.SetDef_BorderWidth;
    begin PGRushData(CustomObj).fDefNeedUpdate := true;
    PGRushData(CustomObj).fPSDef.BorderWidth := Val; end;
function TGRushControl.GetDef_BorderRoundWidth;
    begin Result := PGRushData(CustomObj).fPSDef.BorderRoundWidth;end;
procedure TGRushControl.SetDef_BorderRoundWidth;
    begin PGRushData(CustomObj).fDefNeedUpdate := true;
    PGRushData(CustomObj).fPSDef.BorderRoundWidth := Val; end;
function TGRushControl.GetDef_BorderRoundHeight;
    begin Result := PGRushData(CustomObj).fPSDef.BorderRoundHeight;end;
procedure TGRushControl.SetDef_BorderRoundHeight;
    begin PGRushData(CustomObj).fDefNeedUpdate := true;
    PGRushData(CustomObj).fPSDef.BorderRoundHeight := Val; end;
function TGRushControl.GetDef_ShadowOffset;
    begin Result := PGRushData(CustomObj).fPSDef.ShadowOffset; end;
procedure TGRushControl.SetDef_ShadowOffset;
    begin PGRushData(CustomObj).fDefNeedUpdate := true;
    PGRushData(CustomObj).fPSDef.ShadowOffset := Val; end;
function TGRushControl.GetDef_GradientStyle;
    begin Result := PGRushData(CustomObj).fPSDef.GradientStyle; end;
procedure TGRushControl.SetDef_GradientStyle;
    begin PGRushData(CustomObj).fDefNeedUpdate := true;
    PGRushData(CustomObj).fPSDef.GradientStyle := Val; end;
function TGRushControl.GetDef_GlyphItemX;
    begin Result := PGRushData(CustomObj).fPSDef.GlyphItemX; end;
procedure TGRushControl.SetDef_GlyphItemX;
    begin PGRushData(CustomObj).fDefNeedUpdate := true;
    PGRushData(CustomObj).fPSDef.GlyphItemX := Val; end;
function TGRushControl.GetDef_GlyphItemY;
    begin Result := PGRushData(CustomObj).fPSDef.GlyphItemY; end;
procedure TGRushControl.SetDef_GlyphItemY;
    begin PGRushData(CustomObj).fDefNeedUpdate := true;
    PGRushData(CustomObj).fPSDef.GlyphItemY := Val; end;

function TGRushControl.GetOver_ColorFrom;
    begin Result := PGRushData(CustomObj).fPSOver.ColorFrom;end;
procedure TGRushControl.SetOver_ColorFrom;
    begin PGRushData(CustomObj).fOverNeedUpdate := true;
    PGRushData(CustomObj).fPSOver.ColorFrom := Val; end;
function TGRushControl.GetOver_ColorTo;
    begin Result := PGRushData(CustomObj).fPSOver.ColorTo;end;
procedure TGRushControl.SetOver_ColorTo;
    begin PGRushData(CustomObj).fOverNeedUpdate := true;
    PGRushData(CustomObj).fPSOver.ColorTo := Val; end;
function TGRushControl.GetOver_ColorOuter;
    begin Result := PGRushData(CustomObj).fPSOver.ColorOuter;end;
procedure TGRushControl.SetOver_ColorOuter;
    begin PGRushData(CustomObj).fOverNeedUpdate := true;
    PGRushData(CustomObj).fPSOver.ColorOuter := Val; end;
function TGRushControl.GetOver_ColorText;
    begin Result := PGRushData(CustomObj).fPSOver.ColorText;end;
procedure TGRushControl.SetOver_ColorText;
    begin PGRushData(CustomObj).fOverNeedUpdate := true;
    PGRushData(CustomObj).fPSOver.ColorText := Val; end;
function TGRushControl.GetOver_ColorShadow;
    begin Result := PGRushData(CustomObj).fPSOver.ColorShadow;end;
procedure TGRushControl.SetOver_ColorShadow;
    begin PGRushData(CustomObj).fOverNeedUpdate := true;
    PGRushData(CustomObj).fPSOver.ColorShadow := Val; end;
function TGRushControl.GetOver_BorderColor;
    begin Result := PGRushData(CustomObj).fPSOver.BorderColor;end;
procedure TGRushControl.SetOver_BorderColor;
    begin PGRushData(CustomObj).fOverNeedUpdate := true;
    PGRushData(CustomObj).fPSOver.BorderColor := Val; end;
function TGRushControl.GetOver_BorderWidth;
    begin Result := PGRushData(CustomObj).fPSOver.BorderWidth;end;
    procedure TGRushControl.SetOver_BorderWidth;
begin PGRushData(CustomObj).fOverNeedUpdate := true;
    PGRushData(CustomObj).fPSOver.BorderWidth := Val; end;
function TGRushControl.GetOver_BorderRoundWidth;
    begin Result := PGRushData(CustomObj).fPSOver.BorderRoundWidth;end;
procedure TGRushControl.SetOver_BorderRoundWidth;
    begin PGRushData(CustomObj).fOverNeedUpdate := true;
    PGRushData(CustomObj).fPSOver.BorderRoundWidth := Val; end;
function TGRushControl.GetOver_BorderRoundHeight;
    begin Result := PGRushData(CustomObj).fPSOver.BorderRoundHeight;end;
procedure TGRushControl.SetOver_BorderRoundHeight;
    begin PGRushData(CustomObj).fOverNeedUpdate := true;
    PGRushData(CustomObj).fPSOver.BorderRoundHeight := Val; end;
function TGRushControl.GetOver_ShadowOffset;
    begin Result := PGRushData(CustomObj).fPSOver.ShadowOffset;end;
procedure TGRushControl.SetOver_ShadowOffset;
    begin PGRushData(CustomObj).fOverNeedUpdate := true;
    PGRushData(CustomObj).fPSOver.ShadowOffset := Val; end;
function TGRushControl.GetOver_GradientStyle;
    begin Result := PGRushData(CustomObj).fPSOver.GradientStyle;end;
procedure TGRushControl.SetOver_GradientStyle;
    begin PGRushData(CustomObj).fOverNeedUpdate := true;
    PGRushData(CustomObj).fPSOver.GradientStyle := Val; end;
function TGRushControl.GetOver_GlyphItemX;
    begin Result := PGRushData(CustomObj).fPSOver.GlyphItemX;end;
procedure TGRushControl.SetOver_GlyphItemX;
    begin PGRushData(CustomObj).fOverNeedUpdate := true;
    PGRushData(CustomObj).fPSOver.GlyphItemX := Val; end;
function TGRushControl.GetOver_GlyphItemY;
    begin Result := PGRushData(CustomObj).fPSOver.GlyphItemY;end;
procedure TGRushControl.SetOver_GlyphItemY;
    begin PGRushData(CustomObj).fOverNeedUpdate := true;
    PGRushData(CustomObj).fPSOver.GlyphItemY := Val; end;

function TGRushControl.GetDown_ColorFrom;
    begin Result := PGRushData(CustomObj).fPSDown.ColorFrom;end;
procedure TGRushControl.SetDown_ColorFrom;
    begin PGRushData(CustomObj).fDownNeedUpdate := true;
    PGRushData(CustomObj).fPSDown.ColorFrom := Val; end;
function TGRushControl.GetDown_ColorTo;
    begin Result := PGRushData(CustomObj).fPSDown.ColorTo;end;
procedure TGRushControl.SetDown_ColorTo;
    begin PGRushData(CustomObj).fDownNeedUpdate := true;
    PGRushData(CustomObj).fPSDown.ColorTo := Val; end;
function TGRushControl.GetDown_ColorOuter;
    begin Result := PGRushData(CustomObj).fPSDown.ColorOuter;end;
procedure TGRushControl.SetDown_ColorOuter;
    begin PGRushData(CustomObj).fDownNeedUpdate := true;
    PGRushData(CustomObj).fPSDown.ColorOuter := Val; end;
function TGRushControl.GetDown_ColorText;
    begin Result := PGRushData(CustomObj).fPSDown.ColorText;end;
procedure TGRushControl.SetDown_ColorText;
    begin PGRushData(CustomObj).fDownNeedUpdate := true;
    PGRushData(CustomObj).fPSDown.ColorText := Val; end;
function TGRushControl.GetDown_ColorShadow;
    begin Result := PGRushData(CustomObj).fPSDown.ColorShadow;end;
procedure TGRushControl.SetDown_ColorShadow;
    begin PGRushData(CustomObj).fDownNeedUpdate := true;
    PGRushData(CustomObj).fPSDown.ColorShadow := Val; end;
function TGRushControl.GetDown_BorderColor;
    begin Result := PGRushData(CustomObj).fPSDown.BorderColor;end;
procedure TGRushControl.SetDown_BorderColor;
    begin PGRushData(CustomObj).fDownNeedUpdate := true;
    PGRushData(CustomObj).fPSDown.BorderColor := Val; end;
function TGRushControl.GetDown_BorderWidth;
    begin Result := PGRushData(CustomObj).fPSDown.BorderWidth;end;
procedure TGRushControl.SetDown_BorderWidth;
    begin PGRushData(CustomObj).fDownNeedUpdate := true;
    PGRushData(CustomObj).fPSDown.BorderWidth := Val; end;
function TGRushControl.GetDown_BorderRoundWidth;
    begin Result := PGRushData(CustomObj).fPSDown.BorderRoundWidth;end;
procedure TGRushControl.SetDown_BorderRoundWidth;
    begin PGRushData(CustomObj).fDownNeedUpdate := true;
    PGRushData(CustomObj).fPSDown.BorderRoundWidth := Val; end;
function TGRushControl.GetDown_BorderRoundHeight;
    begin Result := PGRushData(CustomObj).fPSDown.BorderRoundHeight;end;
procedure TGRushControl.SetDown_BorderRoundHeight;
    begin PGRushData(CustomObj).fDownNeedUpdate := true;
    PGRushData(CustomObj).fPSDown.BorderRoundHeight := Val; end;
function TGRushControl.GetDown_ShadowOffset;
    begin Result := PGRushData(CustomObj).fPSDown.ShadowOffset;end;
procedure TGRushControl.SetDown_ShadowOffset;
    begin PGRushData(CustomObj).fDownNeedUpdate := true;
    PGRushData(CustomObj).fPSDown.ShadowOffset := Val; end;
function TGRushControl.GetDown_GradientStyle;
    begin Result := PGRushData(CustomObj).fPSDown.GradientStyle;end;
procedure TGRushControl.SetDown_GradientStyle;
    begin PGRushData(CustomObj).fDownNeedUpdate := true;
    PGRushData(CustomObj).fPSDown.GradientStyle := Val; end;
function TGRushControl.GetDown_GlyphItemX;
    begin Result := PGRushData(CustomObj).fPSDown.GlyphItemX;end;
procedure TGRushControl.SetDown_GlyphItemX;
    begin PGRushData(CustomObj).fDownNeedUpdate := true;
    PGRushData(CustomObj).fPSDown.GlyphItemX := Val; end;
function TGRushControl.GetDown_GlyphItemY;
    begin Result := PGRushData(CustomObj).fPSDown.GlyphItemY;end;
procedure TGRushControl.SetDown_GlyphItemY;
    begin PGRushData(CustomObj).fDownNeedUpdate := true;
    PGRushData(CustomObj).fPSDown.GlyphItemY := Val; end;

function TGRushControl.GetDis_ColorFrom;
    begin Result := PGRushData(CustomObj).fPSDis.ColorFrom;end;
procedure TGRushControl.SetDis_ColorFrom;
    begin PGRushData(CustomObj).fDisNeedUpdate := true;
    PGRushData(CustomObj).fPSDis.ColorFrom := Val; end;
function TGRushControl.GetDis_ColorTo;
    begin Result := PGRushData(CustomObj).fPSDis.ColorTo;end;
procedure TGRushControl.SetDis_ColorTo;
    begin PGRushData(CustomObj).fDisNeedUpdate := true;
    PGRushData(CustomObj).fPSDis.ColorTo := Val; end;
function TGRushControl.GetDis_ColorOuter;
    begin Result := PGRushData(CustomObj).fPSDis.ColorOuter;end;
procedure TGRushControl.SetDis_ColorOuter;
    begin PGRushData(CustomObj).fDisNeedUpdate := true;
    PGRushData(CustomObj).fPSDis.ColorOuter := Val; end;
function TGRushControl.GetDis_ColorText;
    begin Result := PGRushData(CustomObj).fPSDis.ColorText;end;
procedure TGRushControl.SetDis_ColorText;
    begin PGRushData(CustomObj).fDisNeedUpdate := true;
    PGRushData(CustomObj).fPSDis.ColorText := Val; end;
function TGRushControl.GetDis_ColorShadow;
    begin Result := PGRushData(CustomObj).fPSDis.ColorShadow;end;
procedure TGRushControl.SetDis_ColorShadow;
    begin PGRushData(CustomObj).fDisNeedUpdate := true;
    PGRushData(CustomObj).fPSDis.ColorShadow := Val; end;
function TGRushControl.GetDis_BorderColor;
    begin Result := PGRushData(CustomObj).fPSDis.BorderColor;end;
procedure TGRushControl.SetDis_BorderColor;
    begin PGRushData(CustomObj).fDisNeedUpdate := true;
    PGRushData(CustomObj).fPSDis.BorderColor := Val; end;
function TGRushControl.GetDis_BorderWidth;
    begin Result := PGRushData(CustomObj).fPSDis.BorderWidth;end;
procedure TGRushControl.SetDis_BorderWidth;
    begin PGRushData(CustomObj).fDisNeedUpdate := true;
    PGRushData(CustomObj).fPSDis.BorderWidth := Val; end;
function TGRushControl.GetDis_BorderRoundWidth;
    begin Result := PGRushData(CustomObj).fPSDis.BorderRoundWidth;end;
procedure TGRushControl.SetDis_BorderRoundWidth;
    begin PGRushData(CustomObj).fDisNeedUpdate := true;
    PGRushData(CustomObj).fPSDis.BorderRoundWidth := Val; end;
function TGRushControl.GetDis_BorderRoundHeight;
    begin Result := PGRushData(CustomObj).fPSDis.BorderRoundHeight;end;
procedure TGRushControl.SetDis_BorderRoundHeight;
    begin PGRushData(CustomObj).fDisNeedUpdate := true;
    PGRushData(CustomObj).fPSDis.BorderRoundHeight := Val; end;
function TGRushControl.GetDis_ShadowOffset;
    begin Result := PGRushData(CustomObj).fPSDis.ShadowOffset;end;
procedure TGRushControl.SetDis_ShadowOffset;
    begin PGRushData(CustomObj).fDisNeedUpdate := true;
    PGRushData(CustomObj).fPSDis.ShadowOffset := Val; end;
function TGRushControl.GetDis_GradientStyle;
    begin Result := PGRushData(CustomObj).fPSDis.GradientStyle;end;
procedure TGRushControl.SetDis_GradientStyle;
    begin PGRushData(CustomObj).fDisNeedUpdate := true;
    PGRushData(CustomObj).fPSDis.GradientStyle := Val; end;
function TGRushControl.GetDis_GlyphItemX;
    begin Result := PGRushData(CustomObj).fPSDis.GlyphItemX;end;
procedure TGRushControl.SetDis_GlyphItemX;
    begin PGRushData(CustomObj).fDisNeedUpdate := true;
    PGRushData(CustomObj).fPSDis.GlyphItemX := Val; end;
function TGRushControl.GetDis_GlyphItemY;
    begin Result := PGRushData(CustomObj).fPSDis.GlyphItemY;end;
procedure TGRushControl.SetDis_GlyphItemY;
    begin PGRushData(CustomObj).fDisNeedUpdate := true;
    PGRushData(CustomObj).fPSDis.GlyphItemY := Val; end;

function TGRushControl.GetAll_CheckMetric;
    begin Result := PGRushData(CustomObj).fCheckMetric end;
procedure TGRushControl.SetAll_CheckMetric;
var     Data: PGRushData;
begin
    Data := PGRushData(CustomObj);
    inc(Data.fContentOffsets.Left, Val-Data.fCheckMetric);
    Data.fCheckMetric := Val;
    Perform(WM_SIZE, 0, 0);
end;
procedure TGRushControl.SetAll_GlyphBitmap;
var     Data: PGRushData;
begin
    Data := PGRushData(CustomObj);
    SetAllNeedUpdate;
    if Data.fGlyphBitmap <> nil then
        Data.fGlyphBitmap.RefDec;
    Data.fGlyphBitmap := Val;
    if Val = nil then exit;
    Data.fGlyphWidth := Val.Width;
    Data.fGlyphHeight := Val.Height;
    Val.RefInc;
end;
function TGRushControl.GetAll_GlyphBitmap;
    begin Result := PGRushData(CustomObj).fGlyphBitmap; end;
procedure TGRushControl.SetAll_ContentOffsets;
    begin PGRushData(CustomObj).fContentOffsets := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_ContentOffsets;
    begin Result := PGRushData(CustomObj).fContentOffsets; end;
procedure TGRushControl.SetAll_AntiAliasing;
    begin PGRushData(CustomObj).fAntiAliasing := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_AntiAliasing;
    begin Result := PGRushData(CustomObj).fAntiAliasing; end;
procedure TGRushControl.SetAll_GlyphVAlign;
    begin PGRushData(CustomObj).fGlyphVAlign := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_GlyphVAlign;
    begin Result := PGRushData(CustomObj).fGlyphVAlign; end;
procedure TGRushControl.SetAll_GlyphHAlign;
    begin PGRushData(CustomObj).fGlyphHAlign := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_GlyphHAlign;
    begin Result := PGRushData(CustomObj).fGlyphHAlign; end;
procedure TGRushControl.SetAll_TextVAlign;
    begin PGRushData(CustomObj).fTextVAlign := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_TextVAlign;
    begin Result := PGRushData(CustomObj).fTextVAlign; end;
procedure TGRushControl.SetAll_TextHAlign;
    begin PGRushData(CustomObj).fTextHAlign := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_TextHAlign;
    begin Result := PGRushData(CustomObj).fTextHAlign; end;

procedure TGRushControl.SetAll_DrawText;
    begin PGRushData(CustomObj).fDrawText := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_DrawText;
    begin Result := PGRushData(CustomObj).fDrawText; end;
procedure TGRushControl.SetAll_DrawGlyph;
    begin PGRushData(CustomObj).fDrawGlyph := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_DrawGlyph;
    begin Result := PGRushData(CustomObj).fDrawGlyph; end;
procedure TGRushControl.SetAll_DrawFocusRect;
    begin PGRushData(CustomObj).fDrawFocusRect := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_DrawFocusRect;
    begin Result := PGRushData(CustomObj).fDrawFocusRect; end;
procedure TGRushControl.SetAll_DrawProgress;
    begin PGRushData(CustomObj).fDrawProgress := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_DrawProgress;
    begin Result := PGRushData(CustomObj).fDrawProgress; end;
procedure TGRushControl.SetAll_DrawProgressRect;
    begin PGRushData(CustomObj).fDrawProgressRect := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_DrawProgressRect;
    begin Result := PGRushData(CustomObj).fDrawProgressRect; end;
procedure TGRushControl.SetAll_ProgressVertical;
    begin
    if PGRushData(CustomObj).fControlType <> ctProgressBar then exit;
    PGRushData(CustomObj).fProgressVertical := Val;

    All_BorderWidth := 1;
    if Val then begin
        All_BorderRoundWidth := 25;
        All_BorderRoundHeight := 4;
        SetAll_GradientStyle(gsDoubleHorz)
    end else begin
        All_BorderRoundWidth := 4;
        All_BorderRoundHeight := 25;
        SetAll_GradientStyle(gsDoubleVert);
    end;end;
function  TGRushControl.GetAll_ProgressVertical;
    begin Result := PGRushData(CustomObj).fProgressVertical; end;
procedure TGRushControl.SetAll_UpdateSpeed;
    begin PGRushData(CustomObj).fUpdateSpeed := Val; end;
function  TGRushControl.GetAll_UpdateSpeed;
    begin Result := PGRushData(CustomObj).fUpdateSpeed; end;
procedure TGRushControl.SetAll_ColorCheck;
    begin PGRushData(CustomObj).fColorCheck := Val; end;
function  TGRushControl.GetAll_ColorCheck;
    begin Result := PGRushData(CustomObj).fColorCheck; end;
procedure TGRushControl.SetAll_GlyphWidth;
    begin PGRushData(CustomObj).fGlyphWidth := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_GlyphWidth;
    begin Result := PGRushData(CustomObj).fGlyphWidth; end;
procedure TGRushControl.SetAll_GlyphHeight;
    begin PGRushData(CustomObj).fGlyphHeight := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_GlyphHeight;
    begin Result := PGRushData(CustomObj).fGlyphHeight; end;
procedure TGRushControl.SetAll_Spacing;
    begin PGRushData(CustomObj).fSpacing := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_Spacing;
    begin Result := PGRushData(CustomObj).fSpacing; end;
procedure TGRushControl.SetAll_SplitterDotsCount;
    begin PGRushData(CustomObj).fSplitterDotsCount := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_SplitterDotsCount;
    begin Result := PGRushData(CustomObj).fSplitterDotsCount; end;
procedure TGRushControl.SetAll_CropTopFirst;
    begin PGRushData(CustomObj).fCropTopFirst := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_CropTopFirst;
    begin Result := PGRushData(CustomObj).fCropTopFirst; end;
procedure TGRushControl.SetAll_GlyphAttached;
    begin PGRushData(CustomObj).fGlyphAttached := Val;
    SetAllNeedUpdate; end;
function  TGRushControl.GetAll_GlyphAttached;
    begin Result := PGRushData(CustomObj).fGlyphAttached; end;

procedure TGRushControl.SetAllNeedUpdate;
    var Data: PGRushData;
    begin Data := PGRushData(CustomObj); Data.fDefNeedUpdate := true;
    Data.fOverNeedUpdate := true; Data.fDownNeedUpdate := true;
    Data.fResultNeedUpdate := true;
    Data.fDisNeedUpdate := true; end;
procedure TGRushControl.SetAll_ColorFrom;
    var Data: PGRushData;
    begin Data := PGRushData(CustomObj); Data.fPSDef.ColorFrom := Val;
    Data.fPSOver.ColorFrom := Val; Data.fPSDown.ColorFrom := Val;
    Data.fPSDis.ColorFrom := Val; SetAllNeedUpdate; end;
procedure TGRushControl.SetAll_ColorTo;
    var Data: PGRushData;
    begin Data := PGRushData(CustomObj); Data.fPSDef.ColorTo := Val;
    Data.fPSOver.ColorTo := Val; Data.fPSDown.ColorTo := Val;
    Data.fPSDis.ColorTo := Val; SetAllNeedUpdate; end;
procedure TGRushControl.SetAll_ColorOuter;
    var Data: PGRushData;
    begin Data := PGRushData(CustomObj);
    Data.fPSDef.ColorOuter := Val; Data.fPSOver.ColorOuter := Val;
    Data.fPSDown.ColorOuter := Val; Data.fPSDis.ColorOuter := Val;
    SetAllNeedUpdate; end;
procedure TGRushControl.SetAll_ColorText;
    var Data: PGRushData;
    begin Data := PGRushData(CustomObj); Data.fPSDef.ColorText := Val;
    Data.fPSOver.ColorText := Val; Data.fPSDown.ColorText := Val;
    Data.fPSDis.ColorText := Val; SetAllNeedUpdate; end;
procedure TGRushControl.SetAll_ColorShadow;
    var Data: PGRushData;
    begin Data := PGRushData(CustomObj); Data.fPSDef.ColorShadow := Val;
    Data.fPSOver.ColorShadow := Val; Data.fPSDown.ColorShadow := Val;
    Data.fPSDis.ColorShadow := Val; SetAllNeedUpdate; end;
procedure TGRushControl.SetAll_BorderColor;
    var Data: PGRushData;
    begin Data := PGRushData(CustomObj); Data.fPSDef.BorderColor := Val;
    Data.fPSOver.BorderColor := Val; Data.fPSDown.BorderColor := Val;
    Data.fPSDis.BorderColor := Val; SetAllNeedUpdate; end;
procedure TGRushControl.SetAll_BorderWidth;
    var Data: PGRushData;
    begin Data := PGRushData(CustomObj); Data.fPSDef.BorderWidth := Val;
    Data.fPSOver.BorderWidth := Val; Data.fPSDown.BorderWidth := Val;
    Data.fPSDis.BorderWidth := Val; SetAllNeedUpdate; end;
procedure TGRushControl.SetAll_BorderRoundWidth;
    var Data: PGRushData;
    begin Data := PGRushData(CustomObj); Data.fPSDef.BorderRoundWidth := Val;
    Data.fPSOver.BorderRoundWidth := Val; Data.fPSDown.BorderRoundWidth := Val;
    Data.fPSDis.BorderRoundWidth := Val; SetAllNeedUpdate; end;
procedure TGRushControl.SetAll_BorderRoundHeight;
    var Data: PGRushData;
    begin Data := PGRushData(CustomObj); Data.fPSDef.BorderRoundHeight := Val;
    Data.fPSOver.BorderRoundHeight := Val; Data.fPSDown.BorderRoundHeight := Val;
    Data.fPSDis.BorderRoundHeight := Val; SetAllNeedUpdate; end;
procedure TGRushControl.SetAll_GradientStyle;
    var Data: PGRushData;
    begin Data := PGRushData(CustomObj); Data.fPSDef.GradientStyle := Val;
    Data.fPSOver.GradientStyle := Val; Data.fPSDown.GradientStyle := Val;
    Data.fPSDis.GradientStyle := Val; SetAllNeedUpdate; end;
procedure TGRushControl.SetAll_ShadowOffset;
    var Data: PGRushData;
    begin Data := PGRushData(CustomObj); Data.fPSDef.ShadowOffset := Val;
    Data.fPSOver.ShadowOffset := Val; Data.fPSDown.ShadowOffset := Val;
    Data.fPSDis.ShadowOffset := Val; SetAllNeedUpdate; end;
procedure TGRushControl.SetAll_GlyphItemX;
    var Data: PGRushData;
    begin Data := PGRushData(CustomObj); Data.fPSDef.GlyphItemX := Val;
    Data.fPSOver.GlyphItemX := Val; Data.fPSDown.GlyphItemX := Val;
    Data.fPSDis.GlyphItemX := Val; SetAllNeedUpdate; end;
procedure TGRushControl.SetAll_GlyphItemY;
    var Data: PGRushData;
    begin Data := PGRushData(CustomObj); Data.fPSDef.GlyphItemY := Val;
    Data.fPSOver.GlyphItemY := Val; Data.fPSDown.GlyphItemY := Val;
    Data.fPSDis.GlyphItemY := Val; SetAllNeedUpdate; end;
function TGRushControl.GetOnRecalcRects;
    begin result := PGRushData(CustomObj).fOnRecalcRects; end;
procedure TGRushControl.SetOnRecalcRects;
    begin PGRushData(CustomObj).fOnRecalcRects := val;
    Perform(WM_SIZE, 0, 0); end;
function TGRushControl.GetOnProgressChange;
    begin result := PGRushData(CustomObj).fOnProgressChange; end;
procedure TGRushControl.SetOnProgressChange;
    begin PGRushData(CustomObj).fOnProgressChange := val;
    Perform(PBM_SETPOS, Progress, 0); end;

function TGRushControl.GetAlphaChannel;
    begin result := PGRushData(CustomObj).fAlphaChannel; end;
procedure TGRushControl.SetAlphaChannel;
    begin PGRushData(CustomObj).fAlphaChannel := val; end;

function TGRushControl.GetAlphaBlendValue;
    begin result := PGRushData(CustomObj).fAlphaBlendValue; end;
procedure TGRushControl.SetAlphaBlendValue;
    begin PGRushData(CustomObj).fAlphaBlendValue := val; end;

procedure TGRushControl.DoEnter;
begin
    with PGRushData(CustomObj){$ifndef F_P}^{$endif}  do begin
        if (fControlType in [ctSplitter]) and (gsDown in fState) then
            exit;   
        include(fState, gsOver);
        if fStateInit = siKey then
            exit;
        {$IFDEF NOT_IMMIDIATLYONLY}
        if fCurrentOperation = coOverToDef then
            fBlendPercent := 64 - fBlendPercent
        else
            fBlendPercent := 0;
        fCurrentOperation := coDefToOver;
        KillTimer(Handle, 8);
        SetTimer(Handle, 8, 40, nil);
        Perform(WM_TIMER, 8, 0);
        {$ELSE NOT_IMMIDIATLYONLY}
        fCurrentOperation := coDefToOver;
        TimerEvent(PGRushData(CustomObj));
        {$ENDIF NOT_IMMIDIATLYONLY}
    end;
end;

procedure TGRushControl.DoExit;
begin
    with PGRushData(CustomObj){$ifndef F_P}^{$endif}  do begin
        if (fControlType in [ctSplitter]) and (gsDown in fState) then
            exit;
        exclude(fState, gsOver);
        if fStateInit = siKey then
            exit;
        fStateInit := siNone;
        {$IFDEF NOT_IMMIDIATLYONLY}
        if fCurrentOperation = coDefToOver then
            fBlendPercent := 64 - fBlendPercent
        else
            fBlendPercent := 0;
        if gsDown in fState then
            fCurrentOperation := coDownToDef
        else
            fCurrentOperation := coOverToDef;
        exclude(fState, gsDown);
        KillTimer(Handle, 8);
        SetTimer(Handle, 8, 40, nil);
        Perform(WM_TIMER, 8, 0);
        {$ELSE NOT_IMMIDIATLYONLY}
        fCurrentOperation := coDownToDef;
        exclude(fState, gsDown);
        TimerEvent(PGRushData(CustomObj));
        {$ENDIF NOT_IMMIDIATLYONLY}
    end;
end;

procedure TGRushControl.DoPush;
begin
    with PGRushData(CustomObj){$ifndef F_P}^{$endif}  do begin
        include(fState, gsDown);
        {$IFDEF NOT_IMMIDIATLYONLY}
        if fCurrentOperation in [coDownToOver{, coDownToDef}] then
            fBlendPercent := 64 - fBlendPercent
        else
            fBlendPercent := 0;
        if gsOver in fState then
            fCurrentOperation := coOverToDown
        else
            fCurrentOperation := coDefToDown;
        KillTimer(Handle, 8);
        SetTimer(Handle, 8, 40, nil);
        Perform(WM_TIMER, 8, 0);
        {$ELSE NOT_IMMIDIATLYONLY}
        fCurrentOperation := coDefToDown;
        TimerEvent(PGRushData(CustomObj));
        {$ENDIF NOT_IMMIDIATLYONLY}
    end;
end;

procedure TGRushControl.DoPop;
begin
    with PGRushData(CustomObj){$ifndef F_P}^{$endif}  do begin
        if not (gsDown in fState) then
            exit;
        exclude(fState, gsDown);
        if fControlType = ctCheckBox then
            Checked := not Checked;
        if fControlType = ctRadioBox then
            Checked := true;
        {$IFDEF NOT_IMMIDIATLYONLY}
        if fCurrentOperation in [coOverToDown] then
            fBlendPercent := 64 - fBlendPercent
        else
            fBlendPercent := 0;
        {$ENDIF NOT_IMMIDIATLYONLY}
        if gsOver in fState then
            fCurrentOperation := coDownToOver
        else
            fCurrentOperation := coDownToDef;
        {$IFDEF NOT_IMMIDIATLYONLY}
        KillTimer(Handle, 8);
        SetTimer(Handle, 8, 40, nil);
        Perform(WM_TIMER, 8, 0);
        {$ELSE NOT_IMMIDIATLYONLY}
        TimerEvent(PGRushData(CustomObj));
        {$ENDIF NOT_IMMIDIATLYONLY}
        if assigned(fOnClick) then
            fOnClick({$ifndef F_P}@{$endif} Self);
    end;
end;

procedure TGRushControl.DeActivateSublings;
var     i: integer;
        Chl: PGrushControl;
        GT: DWORD;
begin
    with PGRushData(CustomObj){$ifndef F_P}^{$endif}  do begin
        GT := GetProp(Handle, ID_GRUSHTYPE);
        if (Parent <> nil) and (GT = GT_RADIOBOX) then
            for i := 0 to Parent.ChildCount-1 do begin
                Chl := PGrushControl(Parent.Children[i]);
                if (Chl <> nil) and (Chl.Handle <> 0) and (Chl <> {$ifndef F_P}@{$endif}Self) then
                    if GetProp(Chl.Handle, ID_GRUSHTYPE) = GT then
                        Chl.SetChecked(false);
            end;
    end;
end;

procedure TGRushControl.InitLast(MEnterExit: Boolean; CT: TGRushControlType);
var     Data: PGRushData;
begin
    {$ifndef F_P}
    New(Data, Create);
    {$else}
    Data := PGRushData.Create;
    {$endif}
    Move(DefGRushData, Data.fPSDef , Sizeof(TGRushFake));
    CustomObj := Data;

    Data.fControlType := CT;
    Data.fNeedDib := not (CT in [ctPanel, ctProgressBar]);
    if CT in [ctCheckBox, ctRadioBox] then begin
        Data.fTextHAlign := haLeft;
        Data.fContentOffsets := CheckContentRect;
        All_BorderColor := clGray;
        Data.fPSOver.BorderColor:= $404040;
        All_GradientStyle := gsFromTopLeft;
    end;
    if MEnterExit then begin
        //OnMouseEnter := DoEnter;
        //OnMouseLeave := DoExit;
        AttachProc(TWindowFunc(@WndProcGRushMouse));
    end;
    OnPaint := DoPaint;
    AttachProc(TWindowFunc(@WndProcGRush));
end;

function NewGRushButton;
begin
    Result := PGRushControl(_NewControl( AParent, 'GRUSH_BUTTON', WS_VISIBLE
        or WS_CHILD or WS_TABSTOP, False, @ButtonActions ));
    Result.Caption := Caption;
    Result.fCommandActions.aAutoSzX := 12;
    Result.fCommandActions.aAutoSzY := 11;
    Result.fClsStyle := Result.fClsStyle or CS_DBLCLKS;

    Result.InitLast(TRUE, ctButton);
    {$IFDEF ALL_BUTTONS_RESPOND_TO_ENTER}
    Result.AttachProc( WndProcBtnReturnClick );
    {$ENDIF}
end;

function NewGRushPanel;
begin
    Result := PGRushControl(_NewControl( AParent, 'GRUSH_PANEL'
        , WS_VISIBLE  or WS_CHILD, False, @LabelActions ));
    Result.fClsStyle := Result.fClsStyle or CS_DBLCLKS;
    Result.InitLast(FALSE, ctPanel);
    Result.All_TextVAlign := vaTop;
end;

function NewGRushCheckBox;
begin
    if CheckRgn = 0 then
        CheckRgn := RegionFromArray(_Check);
    Result := PGRushControl(_NewControl( AParent, 'GRUSH_CHECKBOX', WS_VISIBLE
        or WS_CHILD or WS_TABSTOP, False, @ButtonActions ));
    Result.Caption := Caption;
    Result.fIgnoreDefault := TRUE;
    Result.fCommandActions.aAutoSzX := 24;
    Result.fClsStyle := Result.fClsStyle or CS_DBLCLKS;

    Result.InitLast(TRUE, ctCheckBox);
    Result.All_BorderRoundWidth := 0;
    Result.All_BorderRoundHeight := 0;
end;

function NewGRushRadioBox;
begin
    if RadioRgn = 0 then
        RadioRgn := RegionFromArray(_Radio);
    Result := PGRushControl(_NewControl( AParent, 'GRUSH_RADIOBOX', WS_VISIBLE
        or WS_CHILD or WS_TABSTOP, False, @ButtonActions ));
    Result.fControlClick := ClickGRushRadio;
    Result.fCommandActions.aAutoSzX := 24;
    Result.Caption := Caption;
    Result.fIgnoreDefault := TRUE;
    Result.fClsStyle := Result.fClsStyle or CS_DBLCLKS;

    Result.InitLast(TRUE, ctRadioBox);
    Result.All_BorderRoundWidth := 50;
    Result.All_BorderRoundHeight := 50;
end;

function NewGRushSplitter;
var     Data: PGRushData;
begin
    Result := PGRushControl(NewSplitterEx(AParent, MinSizePrev, MinSizeNext, esNone));
    Result.fClsStyle := Result.fClsStyle or CS_DBLCLKS;
    Result.InitLast(TRUE, ctSplitter);
    Data := PGRushData(Result.CustomObj);
    Data.fPSOver.ColorTo := $D0AD95;
    Data.fPSDown.ColorTo := $C39475;
    {$IFDEF NOT_IMMIDIATLYONLY}
    Data.fUpdateSpeed := usVeryFast;
    {$ENDIF NOT_IMMIDIATLYONLY}
    Data.fSplitterDotsCount := 16;
    if (Result.Align in [caLeft, caRight]) then begin
        Result.All_GradientStyle := gsHorizontal;
        Result.Width := 5;
    end else begin
        Result.All_GradientStyle := gsVertical;
        Result.Height := 5;
    end;
    Data.fPSDef.GradientStyle := gsSolid;

    Result.All_ColorFrom := clWhite;
    Data.fPSDef.ColorFrom := clBtnFace;           
    Result.All_BorderWidth := 0;
    Result.All_BorderRoundWidth := 0;
    Result.All_BorderRoundHeight := 0;
    Result.Perform(WM_SIZE, 0, 0);
end;

function NewGRushProgressBar;
var     Data: PGRushData;
begin
    Result := PGRushControl(_NewControl( AParent, 'GRUSH_PROGRESSBAR'
        , WS_VISIBLE or WS_CHILD, False, @LabelActions ));
        
    Result.fClsStyle := Result.fClsStyle or CS_DBLCLKS;
    
    Result.InitLast(FALSE, ctProgressBar);
    Data := PGRushData(Result.CustomObj);
    Data.fDrawProgress := TRUE;
    Data.fDrawProgressRect := TRUE;
    Result.All_ContentOffsets := ProgressBarContentRect;
    Data.fPSDef.ColorTo := $B6977E;
    Data.fPSDef.ColorFrom := $E0D2C9;
    Result.All_ShadowOffset := 1;
    Result.SetAll_ProgressVertical(FALSE);
end;

function TGRushControl.GetAll_SplDotsOrient: TGRushOrientation;
begin
  Result := PGRushData(CustomObj).fSplDotsOrient;
end;

procedure TGRushControl.SetAll_SplDotsOrient(
  const Value: TGRushOrientation);
begin
  PGRushData(CustomObj).fSplDotsOrient := Value;
     SetAllNeedUpdate;
end;

initialization
    {$IFDEF USE_MMX}
    UseMMX := CPUisMMX;
    {$ENDIF USE_MMX}
    {$IFDEF SYSNEED}
    hinst_msimg32 := LoadLibrary( msimg32 );
    {$IFDEF FIX_16BITMODE}
    SysGradientFill := GetProcAddress(hinst_msimg32, 'GradientFill');
    {$ENDIF FIX_16BITMODE}
    {$IFDEF FIX_DRAWTRANSPARENT}
    SysTransparentBlt := GetProcAddress(hinst_msimg32, 'TransparentBlt');
    {$ENDIF FIX_DRAWTRANSPARENT}
    if {$IFDEF FIX_16BITMODE}(@SysGradientFill <> nil) and {$ENDIF}
        {$IFDEF FIX_DRAWTRANSPARENT}(@SysTransparentBlt <> nil) and {$ENDIF}(WinVer() > wv98) then
        UseSystemGradient := TRUE;
    {$ENDIF SYSNEED}

finalization
    if CheckRgn <> 0 then
        DeleteObject(CheckRgn);
    if RadioRgn <> 0 then
        DeleteObject(RadioRgn);
end.