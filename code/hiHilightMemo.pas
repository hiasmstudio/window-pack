unit hiHiLightMemo; { компонент Memo c подсветкой синтаксиса ver 3.65}

interface

uses Windows, Kol, Share, Debug, EWinList, Messages, MMSystem, hiStr_Enum;

const
  MaxLineWidth = 4096; 
  msgCaret     = 1; 
  msgDblClk    = 2; 
  msgShow      = 3; 
  msgComplete  = 4; 

  { Здесь объявляем сопутствующий контрол, который необходим
    для прямого доступа к закрытым полям контрола - хозяина. }

type 
  {$ifdef F_P}
    TCtrlEx = class; 
    PCtrlEx = TCtrlEx; 
    TCtrlEx = class(TControl)
  {$else}
    PCtrlEx = ^TCtrlEx; 
    TCtrlEx = object(TControl)
  {$endif}
end; 

type
  TOptionEdit = (oeReadOnly, oeOverwrite, oeKeepTrailingSpaces, oeSmartTabs, 
                 oeHighlight, oeAutoCompletion); 
  TOptionsEdit = set of TOptionEdit; 

  TTokenAttrs = packed record
    fontstyle: TFontStyle; 
    fontcolor: TColor; 
end; 
  TOnScanToken = function(Sender: PControl; const FromPos: TPoint; 
                          var Attrs: TTokenAttrs): integer of object; 
  { Методика подцветки синтаксиса такова: устанавливается обработчик события
    OnScanToken, который по необходимости получает координату FromPos, берет
    строку Lines[FromPos.Y], и с позиции FromPos.X (считается с нуля)
    определяет атрибуты токены (записывае их в Attrs), и возвращает длину токена.
    ...Не надо делать никакого компонента, если без него можно обойтись. (Кладов) }

  TFindReplaceOption = (froBack, frocase, froSpaces, froReplace, froAll); 
  TFindReplaceOptions = set of TFindReplaceOption; 

  THIhilightMemo = class(THIEWinList)
  private
    HS:             PStrList; 
    HE:             PCtrlEx; 
    Arr:            PArray; 
    SearchRes:      TPoint; 

    procedure   ResetIndent;
    procedure   SetOption(OSet: boolean; Option: TOptionEdit); 
    procedure   SetStrings(const Value: string); override;
    procedure   Focused_CaretToView(NoCheck: boolean = false); 
    procedure   SetHilightstrings(Value: string); 
    procedure   _OnChange(Obj: PObj); 
    procedure   _Set(var Item: TData; var Val: TData); override; 
    procedure   _Add(var Val: TData); 
    function    _Get(var Item: TData; var Val: TData): boolean; 
    function    _Count:integer; 
    function    HiLight(Sender: PControl; const FromPos: TPoint; var Attrs: TTokenAttrs): integer;
    function    Add(const Text: string): integer; override; 
  public
    _prop_Overwrite, 
    _prop_AutoComplete, 
    _prop_Hilight, 
    _prop_FindBack, 
    _prop_Findcase, 
    _prop_FindSpaces, 
    _prop_FindReplace, 
    _prop_ReplaceAll, 
    _prop_SmartTabs, 
    _prop_SelectFound, 
    _prop_ReadOnly, 
    _prop_RightMargin, 
    _prop_AutoFocus,
    _prop_AutoSubSpace,
    _prop_HilightCaseSens, 
    _prop_AllowDelim: boolean;      

    _prop_strings, 
    _prop_AutoCompstrings, 
    _prop_FileNameComplete, 
    _prop_FileNameHiLight,             
    _prop_SearchStr, 
    _prop_ReplaceStr: string; 
 
    _prop_MinWordLen: integer; 
    _prop_SearFrom: integer; 
    _prop_Indent: integer; 
    _prop_WidthRightMargin: integer;
    
    _prop_ColorRightMargin: TColor; 
    _prop_ColorUnderLine: TColor;
    
    _prop_AddType: byte;
    _prop_HilightFont: TFontRec;

    _data_SearchStr, 
    _data_ReplaceStr, 
    _data_SearchFrom, 
    _data_WordPosition, 
    _data_FileNameComplete,      
    _data_FileNameHiLight: THI_Event; 

    _event_onBookMIdx,
    _event_onHScroll,
    _event_onVScroll,    
    _event_onGetBookMIdx, 
    _event_onClickUnderLineStr, 
    _event_onAutoComp, 
    _event_onAddAutoComp: THI_Event; 
 
    property _prop_Hilightstrings: string write SetHilightstrings; 

    destructor Destroy; override; 
    procedure Init; override; 
    procedure _work_doAdd                  (var _Data: TData; Index: Word); 
    procedure _work_doClear                (var _Data: TData; Index: Word); override; 
    procedure _work_doDelete               (var _Data: TData; Index: Word); 
    procedure _work_doInsert               (var _Data: TData; Index: Word); 
//    procedure _work_doText                 (var _Data: TData; Index: Word);
    procedure _work_doFind                 (var _Data: TData; Index: Word); 
//    procedure _work_doLoad                 (var _Data: TData; Index: Word);
    procedure _work_doSave                 (var _Data: TData; Index: Word); 
    procedure _work_doHilightstrings       (var _Data: TData; Index: Word); 
    procedure _work_doAddHilightstrings    (var _Data: TData; Index: Word); 
    procedure _work_doHilightFont          (var _Data: TData; Index: Word); 
    procedure _work_doWidthRightMargin     (var _Data: TData; Index: Word); 
    procedure _work_doSetCaret             (var _Data: TData; Index: Word); 
    procedure _work_doViewToCaret          (var _Data: TData; Index: Word); 
    procedure _work_doTopLine              (var _Data: TData; Index: Word); 
    procedure _work_doLeftCol              (var _Data: TData; Index: Word); 
    procedure _work_doReplaceSelect        (var _Data: TData; Index: Word); 
    procedure _work_doDeleteSelect         (var _Data: TData; Index: Word); 
    procedure _work_doSetSelBegin          (var _Data: TData; Index: Word); 
    procedure _work_doSetSelend            (var _Data: TData; Index: Word); 
    procedure _work_doSetSelFrom           (var _Data: TData; Index: Word); 
    procedure _work_doSelectWordUnderCursor(var _Data: TData; Index: Word); 
    procedure _work_doCut                  (var _Data: TData; Index: Word); 
    procedure _work_doCopy                 (var _Data: TData; Index: Word); 
    procedure _work_doPaste                (var _Data: TData; Index: Word); 
    procedure _work_doUndo                 (var _Data: TData; Index: Word); 
    procedure _work_doRedo                 (var _Data: TData; Index: Word); 
    procedure _work_doAutoCompstrings      (var _Data: TData; Index: Word); 
    procedure _work_doShowAutoComp         (var _Data: TData; Index: Word); 
    procedure _work_doHideAutoComp         (var _Data: TData; Index: Word); 
    procedure _work_doClearAutoComp        (var _Data: TData; Index: Word); 
    procedure _work_doFindReplace          (var _Data: TData; Index: Word); 
    procedure _work_doFindBack             (var _Data: TData; Index: Word); 
    procedure _work_doFindcase             (var _Data: TData; Index: Word); 
    procedure _work_doFindSpaces           (var _Data: TData; Index: Word); 
    procedure _work_doReplaceAll           (var _Data: TData; Index: Word);                
    procedure _work_doSelectFound          (var _Data: TData; Index: Word); 
    procedure _work_doGetBookMIdx          (var _Data: TData; Index: Word); 
    procedure _work_doSetBookMIdx          (var _Data: TData; Index: Word); 
    procedure _work_doColorUnderLine       (var _Data: TData; Index: Word); 
    procedure _work_doAddType              (var _Data: TData; Index: Word); 
    procedure _work_doReadOnly             (var _Data: TData; Index: Word); 
    procedure _work_doAutoComplete         (var _Data: TData; Index: Word); 
    procedure _work_doOverwrite            (var _Data: TData; Index: Word); 
    procedure _work_doHilight              (var _Data: TData; Index: Word); 
    procedure _work_doMinWordLen           (var _Data: TData; Index: Word); 
    procedure _work_doIndent               (var _Data: TData; Index: Word); 
    procedure _work_doIndentSelect         (var _Data: TData; Index: Word);
    procedure _work_doRightMargin          (var _Data: TData; Index: Word); 
    procedure _work_doColorRightMargin     (var _Data: TData; Index: Word); 
    procedure _work_doSmartTabs            (var _Data: TData; Index: Word); 
    procedure _work_doAutoFocus            (var _Data: TData; Index: Word); 
    procedure _work_doAllowDelim           (var _Data: TData; Index: Word); 
    procedure _work_doAutoSubSpace         (var _Data: TData; Index: Word);
    procedure _work_doLoadAutoCompl        (var _Data: TData; Index: Word); 
    procedure _work_doSaveAutoCompl        (var _Data: TData; Index: Word);      
    procedure _work_doLoadHiLight          (var _Data: TData; Index: Word); 
    procedure _work_doSaveHiLight          (var _Data: TData; Index: Word);
    procedure _work_doHilightCaseSens      (var _Data: TData; Index: Word);
    procedure _work_doEnsureVisible        (var _Data: TData; Index: Word);          

    procedure _var_Array                   (var _Data: TData; Index: Word); 
    procedure _var_Text                    (var _Data: TData; Index: Word); override; 
    procedure _var_Count                   (var _Data: TData; Index: Word); 
    procedure _var_TopLine                 (var _Data: TData; Index: Word); 
    procedure _var_LeftCol                 (var _Data: TData; Index: Word); 
    procedure _var_LinesPerPage            (var _Data: TData; Index: Word); 
    procedure _var_LinesVisiblePartial     (var _Data: TData; Index: Word); 
    procedure _var_ColumnsVisiblePartial   (var _Data: TData; Index: Word); 
    procedure _var_MaxLineWidthOnPage      (var _Data: TData; Index: Word); 
    procedure _var_MaxLineWidthInText      (var _Data: TData; Index: Word); 
    procedure _var_LineHeight              (var _Data: TData; Index: Word); 
    procedure _var_CharWidth               (var _Data: TData; Index: Word); 
    procedure _var_SelText                 (var _Data: TData; Index: Word); 
    procedure _var_CanUndo                 (var _Data: TData; Index: Word); 
    procedure _var_CanRedo                 (var _Data: TData; Index: Word); 
    procedure _var_WordAtPos               (var _Data: TData; Index: Word); 
    procedure _var_WordAtPosMouse          (var _Data: TData; Index: Word); 
    procedure _var_WordAtPosStartX         (var _Data: TData; Index: Word); 
    procedure _var_WordAtPosStartY         (var _Data: TData; Index: Word); 
    procedure _var_PositionX               (var _Data: TData; Index: Word); 
    procedure _var_PositionY               (var _Data: TData; Index: Word); 
    procedure _var_PositionMouseX          (var _Data: TData; Index: Word); 
    procedure _var_PositionMouseY          (var _Data: TData; Index: Word); 
    procedure _var_SelBeginX               (var _Data: TData; Index: Word); 
    procedure _var_SelBeginY               (var _Data: TData; Index: Word); 
    procedure _var_SelendX                 (var _Data: TData; Index: Word); 
    procedure _var_SelendY                 (var _Data: TData; Index: Word); 
    procedure _var_SelFromX                (var _Data: TData; Index: Word); 
    procedure _var_SelFromY                (var _Data: TData; Index: Word); 
    procedure _var_SearchResX              (var _Data: TData; Index: Word); 
    procedure _var_SearchResY              (var _Data: TData; Index: Word); 
    procedure _var_SelAvailable            (var _Data: TData; Index: Word); 
  private
    FCaret: TPoint; 
    FTopLine: integer; 
    FLeftCol: integer; 
    FRightMargin: boolean; 
    FCoordinatMouse: TPoint; 

    function GetCount: integer; 
    function GetText: string; 
    function GetSelection: string; 
    function GetDrawRightMargin: boolean; 
    function GetLines(Idx: integer): string; 
    procedure SetOnScanToken(const Value: TOnScanToken); 
    procedure SetLines(Idx: integer; const Value: string); 
    procedure SetSelection(const Value: string); 
    procedure SetSelBegin(const Value: TPoint); 
    procedure SetSelend(const Value: TPoint); 
    procedure SetCaret(const Value: TPoint); 
    procedure SetTopLine(const Value: integer); 
    procedure SetLeftCol(const Value: integer); 
    procedure SetText(const Value: string); 
    procedure SetDrawRightMargin(const Value: boolean); 
  public
    procedure Clear; 
    //-------------------------------------------------------------------------- 
    // Доступ к количеству строк и чтение - запись строк из программы
    property Count               : integer read GetCount; 
    property Lines[Idx : integer]: string read GetLines write SetLines; 
    property Text                : string read GetText write SetText; 
    property DrawRightMargin     : boolean read GetDrawRightMargin write SetDrawRightMargin; 
      { ! Не следует использовать свойства Text, Caption самого
        контрола THilightMemo - они не имеют отношения к отображаемому
        тексту. Следует использовать методы и свойства объекта
        Edit, в частности, это свойство Text ! (Кладов) }
    procedure InvalidateLine(y: integer); 
  public
    RightMarginchars: integer; // по умолчанию 80 при вкл. DrawRightMargin
    RightMargincolor: TColor;  // по умолчанию clBlue
  protected
    FLines: PStrList;   // текст
    FBufferBitmap: PBitmap; 
    procedure DoPaint(DC: HDC); 
  protected
    FChangeLevel: integer; 
    procedure Changing; // начало блока изменений
    procedure Changed;  // конец блока изменений
  protected
    FOnScanToken: TOnScanToken; 
  public
    //-------------------------------------------------------------------------- 
    // Раскраска синтаксиса
    property OnScanToken: TOnScanToken read FOnScanToken write SetOnScanToken; 
  public
    //-------------------------------------------------------------------------- 
    // Утилиты редактирования
    Options: TOptionsEdit; 
    procedure DeleteLine(y: integer; UseScroll: boolean); 
    procedure InsertLine(y: integer; const S: string; UseScroll: boolean; LFCR: boolean = false); 
    protected
    procedure DeleteLine1(y: integer); 
  public
    //-------------------------------------------------------------------------- 
    // Управление отступом
    procedure Indent(delta: integer); 
  public
    //-------------------------------------------------------------------------- 
    // Текущая позиция (каретка)
    property Caret: TPoint read FCaret write SetCaret; 
    function Client2Coord(const P: TPoint): TPoint; 
    procedure CaretToView; 
      { CaretToView обеспечивает скроллирование текста таким образом, 
        чтобы каретка ввода вмсте со следующим символом оказались в видимой
        части окна. }
  public
    //-------------------------------------------------------------------------- 
    // Выделенная область
  protected
    FSelBegin, FSelEnd, FSelFrom: TPoint; // начало, конец выделенной области
                                          // и позиция, от которой выделение стартовало (для продолжения)
    procedure SetSel(const Pos1, Pos2, PosFrom: TPoint); 
      { SetSel устанавливает новое выделение и позицию начального
        маркера выделения за один вызов. }
    procedure InvalidateSelection; // пометить видимую часть области выделения
                                   // как испорченную
  public
    property Selection: string read GetSelection write SetSelection; 
    property SelBegin : TPoint read FSelBegin write SetSelBegin; 
    property SelEnd   : TPoint read FSelEnd write SetSelEnd; 
    property SelFrom  : TPoint read FSelFrom write FSelFrom; 
    function SelectionAvailable: boolean; 
    procedure DeleteSelection; 
  public
    //-------------------------------------------------------------------------- 
    // Позиционирование и выделение мышью
  protected
    FMouseDown: boolean; // true, когда нажата левая клавиша мыши
    procedure DoMouseDown(X, Y, Shift: integer); 
    procedure DoMouseMove(X, Y: integer); 
    //-------------------------------------------------------------------------- 
    // Скроллирование и состояние скроллеров: 
    procedure AdjustHScroll; 
    procedure AdjustVScroll; 
    procedure DoScroll(Cmd, wParam: Cardinal); 
  public
    //-------------------------------------------------------------------------- 
    // Работа со словами (слово под курсором, под кареткой, движение
    // каретки по словам)
    procedure SelectWordUnderCursor;
    function WordAtPosStart(const AtPos: TPoint): TPoint; 
    function WordAtPos(const AtPos: TPoint): string; 
    function FindNextWord(const FromPos: TPoint; LookForLettersDigits: boolean): TPoint; 
    function FindPrevWord(const FromPos: TPoint; LookForLettersDigits: boolean): TPoint; 
    function FindNextTabPos(const FromPos: TPoint): integer; 
    function FindPrevTabPos(const FromPos: TPoint): integer; 
  public
    //-------------------------------------------------------------------------- 
    // Обслуживание клавиатуры
    procedure DoKeyDown(Key, Shift: integer); 
    procedure DoKeyChar(Key: Char); 
  public
    //-------------------------------------------------------------------------- 
    // Текущая верхняя строка и левая колонка
    property TopLine: integer read FTopLine write SetTopLine; 
    property LeftCol: integer read FLeftCol write SetLeftCol; 
    //-------------------------------------------------------------------------- 
    // Число полных и неполных строк на странице
    function LinesPerPage: integer; 
    function LinesVisiblePartial: integer; 
    //-------------------------------------------------------------------------- 
    // Ширина символа и число видимых колонок в странице и тексте
    function CharWidth: integer; 
    function ColumnsVisiblePartial: integer; 
    function MaxLineWidthOnPage: integer; 
    function MaxLineWidthInText: integer; 
    //-------------------------------------------------------------------------- 
    // Высота строки
    function LineHeight: integer; 
  protected
    FBitmap: PBitmap;     // используется для подсчета ширины и высоты символов
    FCharWidth: integer;  // запоминает однажды рассчитанную ширину 1 - го символа
    FLineHeight: integer; // запоминает однажды рассчитанную высоту строки
      { Шрифт предполагается моноширинный. } { Уже не обязательн (nesco) }
  public
    //-------------------------------------------------------------------------- 
    // Работа с откатом
    procedure Undo; 
    procedure Redo; 
    function CanUndo: boolean; 
    function CanRedo: boolean; 
  protected
    FUndoList, FRedoList: PStrList; 
    FUndoingRedoing: boolean; // Пока true, не наполнять стек отката
    procedure DoUndoRedo(List1, List2: PStrList); 
  public
    //-------------------------------------------------------------------------- 
    // Закладки
    procedure SetBookmark(Idx: integer; const Value: TPoint); 
    function GetBookMark(IDx: integer): TPoint; 
    property Bookmarks[Idx: integer]: TPoint read GetBookMark write SetBookmark;
  protected
    FBookmarks: array[0..9] of TPoint; 
    procedure FixBookmarks(const FromPos: TPoint; deltaX, deltaY: integer); 
  public
    //-------------------------------------------------------------------------- 
    // Поиск / замена
    function FindReplace(S: string; const ReplaceTo: string; 
                         const FromPos: TPoint; 
                         FindReplaceOptions: TFindReplaceOptions; 
                         SelectFound: boolean): TPoint; 
  public
    //-------------------------------------------------------------------------- 
    // Авто - завершение
      { Внимание! Во избежание проблем Applet должен использоваться как
        отдельный объект KOL.TApplet ! (Кладов) }
    // особой необходимости использовать методы ниже нет. Только если хочется
    // вызвать список принудительно или наполнить словарь своим кодом.
    AutoCompleteMinWordLength: integer;       // По умолчанию 2 символа, для более
    procedure AutoAdd2Dictionary(SC: string); // добавить все слова из строки
    procedure AutoCompletionShow;             // Показать список, если есть
    procedure AutoCompletionHide;             // Скрыть список слов
    procedure AutoCompletionClear;            // Очистить словарь
  protected                                   // коротких не вызывать авто - список
    FAutoCompletionForm: PControl;            // форма для показа авто - списка
    FAutoCompletionList: PControl;            // list view
    FDictionary: PStrListEx;                  // весь список слов, хранит номер последней вставки
    FAutoFirst, FAutoCount: integer;          // слова текущего показа в автосписке
    FAutoBestFirst: integer;                  // первое лучшее слово - вначале выделено
    FLastInsertIdx: integer;                  // счетчик вставок
    FAutoWord: string;                        // для какого начала слова вызван авто - список
    FAutoPos: TPoint;                         // в каком месте была каретка при вызове
    FnotAdd2Dictionary1time: boolean;         // устанавливается на 1 раз
    procedure AutoListData(Sender: PControl; Idx, SubItem: integer; 
                           var Txt: string; var ImgIdx: integer; var State: Cardinal; 
                           var Store: boolean);    // Обеспечить отображение списка слов
    procedure AutoCompleteWord(n: integer); // выполнить автозавершение!
    procedure AutoformCloseEvent(Sender: PObj; var Accept: boolean); 
    procedure AutoFormShowEvent(Sender: PObj); 
    procedure FastFillDictionary;   // только для Text := новое значение
    function AutoListMessage(var Msg: TMsg; var Rslt: integer): boolean; 
  end; 

procedure Beep; // Стандартный звук
function CheckKeyMask(State: byte; Code: byte): boolean; 

var Upper: array[Char] of Char; 

procedure InitUpper; 

implementation

// Вспомогательные функции
function IsLetterDigit(C: Char): boolean; 
begin
  Result := C in ['A'..'Z', 'a'..'z', 'А'..'Я', 'а'..'я', 'Ё', 'ё', '_', '~', '0'..'9']; 
end; 

function IsLetter(C: Char): boolean; 
begin
  Result := C in ['A'..'Z', 'a'..'z', 'А'..'Я', 'а'..'я', 'Ё', 'ё', '_', '~']; 
end; 

procedure Beep; 
begin
  PlaySound('Default', 0, SND_ALIAS); 
end; 

procedure InitUpper; 
var
  c: Char; 
begin
  for c := #0 to #255 do Upper[c] := AnsiUppercase(c)[1]; 
end; 

function AnsiStrLComp(S1, S2: PChar; L: integer): integer; 
begin
  Result := 0; 
  while L > 0 do
  begin
    Result := ord(Upper[S1^]) - ord(Upper[S2^]); 
    if Result <> 0 then exit; 
    dec(L); 
    inc(S1); 
    inc(S2); 
  end; 
end; 

{ Обработчик сообщений контрола.
  Цель - обработать WM_PAINT и WM_PRINT.
  Так же - обработать установку и сняте фокуса для отображения каретки.
  Так же - обработать клавиши - WM_KEYDOWN, WM_CHAR.
  Так же - обработать сообщения мыши.
  И прочее. }
function HilightWndFunc(Sender: PControl; var Msg: TMsg; var Rslt: integer): boolean; 
var
  PaintStruct: TPaintStruct; 
  OldPaintDC:  HDC; 
  HilightEdit: PCtrlEx; 
  HEdit:       THIhilightMemo; 
  Cplxity:     integer; 
  CR:          TRect; 
  i:           integer; 
  Shift:       integer;     // для WM_KEYDOWN: 
  C:           Char;        // для WM_CHAR: 
  S:           string;      // для WM_PASTE: 

  function GetShiftState: Cardinal; 
  begin
    Result := 0; 
    if GetKeyState(VK_SHifT) < 0   then Result := Result or MK_SHifT; 
    if GetKeyState(VK_CONTROL) < 0 then Result := Result or MK_CONTROL; 
  end; 
      
begin
  Result := false; // по умолчанию - продолжать обработку по цепочке
  HilightEdit := PCtrlEx(Sender); 
  if HilightEdit = nil then exit; 
  HEdit := THIhilightMemo(Sender.Tag); 
  case Msg.message of
    WM_PAINT, WM_PRINT:
      begin
        HilightEdit.fUpdRgn := CreateRectRgn(0, 0, 0, 0); 
        Cplxity := integer(GetUpdateRgn(HilightEdit.fHandle, HilightEdit.fUpdRgn, false)); 
        if (Cplxity = NULLREGION) or (Cplxity = ERROR) then
        begin
          DeleteObject(HilightEdit.fUpdRgn); 
          HilightEdit.fUpdRgn := 0; 
        end; 
        if (HilightEdit.fCollectUpdRgn <> 0) and (HilightEdit.fUpdRgn <> 0) then
        begin
          if CombineRgn(HilightEdit.fCollectUpdRgn, HilightEdit.fCollectUpdRgn, 
                        HilightEdit.fUpdRgn, RGN_OR) = COMPLEXREGION then
           begin
             Windows.GetClientRect(HilightEdit.fHandle, CR); 
             DeleteObject(HilightEdit.fCollectUpdRgn); 
             HilightEdit.fCollectUpdRgn := CreateRectRgnIndirect(CR); 
           end; 
           InvalidateRgn(HilightEdit.fHandle, HilightEdit.fCollectUpdRgn, false{fEraseUpdRgn}); 
        end; 
        OldPaintDC := HilightEdit.fPaintDC; 
        HilightEdit.fPaintDC := Msg.wParam; 
        if HilightEdit.fPaintDC = 0 then
          HilightEdit.fPaintDC := BeginPaint(HilightEdit.fHandle, PaintStruct); 
        if HilightEdit.fCollectUpdRgn <> 0 then
          SelectClipRgn(HilightEdit.fPaintDC, HilightEdit.fCollectUpdRgn); 
        HEdit.DoPaint(HilightEdit.fPaintDC); 
        if assigned(HilightEdit.fCanvas) then
          HilightEdit.fCanvas.Handle := 0; 
        if Msg.wParam = 0 then
          endPaint(HilightEdit.fHandle, PaintStruct); 
        HilightEdit.fPaintDC := OldPaintDC; 
        if HilightEdit.fUpdRgn <> 0 then
          DeleteObject(HilightEdit.fUpdRgn); 
        HilightEdit.fUpdRgn := 0; 
        Rslt := 0; 
        Result := true; 
      end; 
    WM_SETFOCUS, WM_KILLFOCUS:
      HilightEdit.Perform(WM_USER + msgCaret, 0, 0); 
    WM_USER + msgCaret:
      HEdit.Caret := HEdit.Caret; 
    WM_KEYDOWN:
      begin
        Shift := GetShiftState; 
        if Assigned(HilightEdit.OnKeyDown) then
          HilightEdit.OnKeyDown(HilightEdit, Msg.wParam, Shift); 
        if Msg.wParam <> 0 then
          HEdit.DoKeyDown(Msg.wParam, Shift); 
      end; 
    WM_LBUTTONDOWN:
      begin
        HilightEdit.Focused := true; 
        HEdit.DoMouseDown(SmallInt(LoWord(Msg.lParam)), SmallInt(hiWord(Msg.lParam)), 
        integer(CheckKeyMask(1, VK_SHifT))); 
      end; 
    WM_RBUTTONDOWN, WM_MBUTTONDOWN:
      HilightEdit.Focused := true; 
    WM_LBUTTONUP:
      begin
        HEdit.DoMouseMove(SmallInt(LoWord(Msg.lParam)), SmallInt(hiWord(Msg.lParam))); 
        HEdit.FMouseDown := false;
        ReleaseCapture; 
      end; 
    WM_MOUSEMOVE:
      begin
        HEdit.DoMouseMove(
        SmallInt(LoWord(Msg.lParam)), 
        SmallInt(hiWord(Msg.lParam))); 
      end; 
    WM_MOUSEWHEEL:
      begin
        i := SmallInt(HiWord(Msg.wParam)); 
        if i div 120 <> 0 then
          HEdit.TopLine := HEdit.TopLine - i div 120; 
       end; 
    WM_LBUTTONDBLCLK:
      begin
        Shift := integer(CheckKeyMask(1, VK_SHifT)); 
        HEdit.DoMouseDown(SmallInt(LoWord(Msg.lParam)), SmallInt(hiWord(Msg.lParam)), Shift); 
        HEdit.FMouseDown := false; 
        ReleaseCapture; 
        HilightEdit.Perform(WM_USER + msgDblClk, 0, 0); 
      end; 
    WM_USER + msgDblClk:
      begin
        Shift := Msg.wParam; 
        if Shift and MK_SHifT = 0 then
          HEdit.SelectWordUnderCursor; 
      end; 
    WM_CHAR:
      begin
        C := Char(Msg.wParam); 
        if Assigned(HilightEdit.OnChar) then
          HilightEdit.OnChar(HilightEdit, C, integer(CheckKeyMask(1, VK_SHifT))); 
        if C <> #0 then
          HEdit.DoKeyChar(C); 
      end; 
    WM_SIZE:
      begin
        HEdit.AdjustHScroll; 
        HEdit.AdjustVScroll; 
      end; 
    WM_HScroll: 
      HEdit.DoScroll(SC_HSCROLL, Msg.wParam); 
    WM_VScroll: 
      HEdit.DoScroll(SC_VSCROLL, Msg.wParam); 
    WM_SETFONT:
      begin
        HEdit.FCharWidth := 0; 
        HEdit.FLineHeight := 0; 
        HEdit.Caret := HEdit.Caret; 
      end; 
    WM_COPY: 
      if HEdit.SelectionAvailable then Text2Clipboard(HEdit.Selection); 
    WM_CUT: 
      if HEdit.SelectionAvailable then
      begin
        Text2Clipboard(HEdit.Selection); 
        HEdit.DeleteSelection; 
      end; 
    WM_PASTE:
      begin
        S := Clipboard2Text; 
        if S = '' then Beep
        else HEdit.Selection := S; 
      end; 
  end; 
end; 

procedure THIHiLightMemo.Init; 
begin
  Control := _NewControl(FParent, 'HILIGHTEDIT', 
             WS_CHILD or WS_VISIBLE
             or WS_TABSTOP // WS_TABSTOP нужен для ловли фокуса ввода
             or WS_HSCROLL or WS_VSCROLL or WS_BordER, 
             true, nil); 
  HE := PCtrlEx(Control); 
  Control.ExStyle := Control.ExStyle or WS_EX_CLIENTEDGE; 
  Control.ClsStyle := (Control.ClsStyle or CS_DBLCLKS) and not (CS_HREDRAW or CS_VREDRAW); 
  Control.Cursor := LoadCursor(0, IDC_IBEAM); 
  { Присоединим обработчик сообщений }
  Control.Tag := LongInt(Self); 
  Control.AttachProc(HilightWndFunc); 
  { Начальные установки }
  HE.fLookTabKeys := []; 
  FLines := NewStrList; 
  FBitmap := NewDIBBitmap(1, 1, pf32bit); 
  FUndoList := NewStrList; 
  FRedoList := NewStrList; 
  FDictionary := NewStrListEx; 
  AutoCompleteMinWordLength := 2;
inherited; 
  Text := _prop_Strings;
  Options := [oeKeepTrailingSpaces]; 
  if _prop_SmartTabs    then Options := Options + [oeSmartTabs]; 
  if _prop_Overwrite    then Options := Options + [oeOverwrite]; 
  if _prop_Hilight      then Options := Options + [oeHighLight]; 
  if _prop_ReadOnly     then Options := Options + [oeReadOnly]; 
  if _prop_AutoComplete then
  begin 
    Options := Options + [oeAutoCompletion]; 
    AutoCompleteMinWordLength := _prop_MinWordLen; 
    AutoAdd2Dictionary(_prop_AutoCompstrings); 
  end; 
  DrawRightMargin := _prop_RightMargin; 
  RightMarginchars := _prop_WidthRightMargin; 
  RightMargincolor := _prop_ColorRightMargin; 
  OnScanToken := Hilight; 
  Control.OnChange := _OnChange; 
  if Text = '' then exit; 
  ResetIndent;
  Indent(_prop_Indent);
  FSelEnd := FSelBegin;
  Caret := MakePoint(_prop_Indent, 0);
end; 

procedure THIHiLightMemo.ResetIndent;
begin
  FSelBegin := MakePoint(0, 0);
  if Count <> 0 then
    FSelBegin := MakePoint(0, Count)
  else
    FSelEnd := FSelBegin;
  Indent(- _prop_Indent);
end;

procedure THIHiLightMemo.SetOption; 
var
  l: TOptionsEdit; 
begin
  l := Options; 
  if OSet then
    include(l, Option)
  else
    exclude(l, Option); 
  Options := l; 
  Focused_CaretToView; 
end; 

destructor THIHiLightMemo.Destroy; 
begin
  FLines.free; // разрушаем текст
  FBitmap.free; 
  free_and_nil(FBufferBitmap); 
  FUndoList.free; 
  FRedoList.free; 
  if Assigned(FAutoCompletionForm) then
  begin
    FAutoCompletionForm.Close; 
    FAutoCompletionForm := nil; 
  end; 
  free_and_nil(FDictionary); 
  HS.free; 
  if Arr <> nil then Dispose(Arr); 
  inherited; 
end; 

procedure THIHiLightMemo.SetHilightstrings; 
begin
  HS := NewStrList; 
  HS.Text := Value; 
end; 

function THIHiLightMemo.HiLight; 
var
  S, str, CS, U: string; 
  i, j, k:       integer; 
  _Color:        TColor; 
  block:         boolean; 
  comment:       boolean; 
  StrtComm:      string; 
  EndComm:       string; 
     
  function AnsiComp1: integer;
  begin
    case ord(_prop_HilightCaseSens) of
      0: Result := AnsiCompareStrNoCase(Copy(S, i + 1, Length(StrtComm)), StrtComm);
      1: Result := AnsiCompareStr(Copy(S, i + 1, Length(StrtComm)), StrtComm)
    else
      Result := 1;
    end;  
  end;
 
  function AnsiComp2: integer;
  begin
    case ord(_prop_HilightCaseSens) of
      0: Result := AnsiCompareStrNoCase(Copy(S, i + 1, Length(str)), str);
      1: Result := AnsiCompareStr(Copy(S, i + 1, Length(str)), str)
    else
      Result := 1;
    end;  
  end;

  procedure SetColorStr; 
  var
    UG: string;
  begin
    if (CS <> '') then
    begin
      CS := Uppercase(CS); 
      if (CS[1] in ['0'..'9']) then _Color := str2int(CS)
      else if CS = 'BLACK'     then _Color := clBlack
      else if CS = 'MAROON'    then _Color := clMaroon
      else if CS = 'GREEN'     then _Color := clGreen
      else if CS = 'OLIVE'     then _Color := clOlive
      else if CS = 'NAVY'      then _Color := clNavy
      else if CS = 'PURPLE'    then _Color := clPurple
      else if CS = 'TEAL'      then _Color := clTeal
      else if CS = 'GRAY'      then _Color := clGray
      else if CS = 'SILVER'    then _Color := clSilver
      else if CS = 'RED'       then _Color := clRed
      else if CS = 'LIME'      then _Color := clLime
      else if CS = 'YELLOW'    then _Color := clYellow
      else if CS = 'BLUE'      then _Color := clBlue
      else if CS = 'FUCHSIA'   then _Color := clFuchsia
      else if CS = 'AQUA'      then _Color := clAqua
      else if CS = 'WHITE'     then _Color := clWhite
    end; 
    Attrs.fontcolor := _Color; 
    Attrs.fontstyle := TFontStyle({$ifdef F_P}integer(_prop_HilightFont.Style)
                                  {$else}_prop_HilightFont.Style{$endif}); 
    UG := FParse(U, '=');
    while UG <> '' do
    begin 
      UG := Uppercase(UG); 
      if (UG = 'U') and (oeReadOnly in Options) then
        include(Attrs.fontstyle, fsUnderline)
      else if (UG = 'B') then
        include(Attrs.fontstyle, fsBold)
      else if (UG = 'C') or (UG = 'I') then
        include(Attrs.fontstyle, fsItalic)
      else if (UG = 'S') then
        include(Attrs.fontstyle, fsStrikeOut);
      UG := FParse(U, '=');
    end; 
  end;
           
begin
  if HS.Count <> 0 then
    for i := HS.Count - 1 downto 0 do
      if HS.Items[i] = '' then HS.Delete(i); 
  S := Lines[FromPos.Y]; 
  Result := 0; 
  if S = '' then exit;
  i := FromPos.X; 
  Attrs.fontcolor := Sender.Font.Color; 
  Attrs.FontStyle := Sender.Font.FontStyle;

  StrtComm := ''; 
  EndComm  := ''; 
  comment := false; 
  block := false; 

  for j := 0 to HS.Count - 1 do
  begin
    U := HS.Items[j]; 
    str := FParse(U, '='); 
    if U <> '' then CS := FParse(U, '=') else CS := ''; 
    _Color := _prop_HilightFont.Color; 

    // ведем поиск конкретного блока засветки
    if (str[1] = '{') and (str[Length(str)] = '}') then
    begin
      Delete(str, 1, 1); 
      if str = '' then exit; 
      deleteTail(str, 1); 
      if str = '' then exit;       
      block := true; 
    end; 

    // ведем поиск блока комментария
    k := PosEx('*', str, 1);     
    if  k > 0 then
    begin
      StrtComm := Copy(str, 1, k - 1); 
      EndComm  := Copy(str, k + 1, Length(str));
      comment := true; 
    end; 

    if (AnsiComp1 = 0) and comment then
    begin
      SetColorStr;
      Result := PosEx(EndComm, S, Length(StrtComm) + 1 + i) + Length(EndComm) - FromPos.x;
      exit; 
    end
    else if (AnsiComp2 = 0) and not comment then
    begin
      SetColorStr; 
      if block then
      begin
        inc(i, Length(str)); 
        break; 
      end;                                   
    end
    else
      block := false; 
  end; 
  if (S[i + 1] <= ' ') and not block then
    while (i < Length(S)) and (S[i + 1] <= ' ') do inc(i)
  else if (S[i + 1] > ' ') and not block then  
    while (i < Length(S)) and (S[i + 1] > ' ') do inc(i); 

  Result := i - FromPos.x; 
end; 

procedure THIHiLightMemo._work_doEnsureVisible;
var
  pos: integer;
begin
  pos := ToIntIndex(_Data);
  if pos < 0 then pos := Count;
  TopLine := max(0, pos - LinesPerPage);
  if _prop_AutoFocus then
    Control.Focused := true; 
  InvalidateRect(Control.Handle, nil, false); 
end;

procedure THIHiLightMemo.Focused_CaretToView; 
begin
  AdjustVScroll; 
  AdjustHScroll; 
  if _prop_AutoFocus or NoCheck then
  begin
    Control.Focused := true; 
    CaretToView; 
  end;  
  InvalidateRect(Control.Handle, nil, false); 
end; 

function THIHiLightMemo.Add; 
begin
  if not (oeReadOnly in Options) then
  begin 
    if (Control.Count > 0) and (Control.Items[Control.Count - 1] <> '') then
      Control.Add(#13#10); 
    Result := Control.Add(Text);
  end
  else   
    Result := Control.Count - 1;
end; 

//procedure THIHiLightMemo.Setstrings;
//begin
//  Control.Perform(WM_SETTEXT, 0, Longint(@Value[1]));
//end;

procedure THIHiLightMemo._OnChange;
begin
  _hi_OnEvent(_event_onChange, Text); 
end; 

procedure THIHiLightMemo._work_doAdd; 
begin
  if not (oeReadOnly in Options) then
  begin 
    if _prop_AddType = 0 then
      InsertLine(Count, ReadString(_Data, _data_Str, ''), true)
    else
      InsertLine(0, ReadString(_Data, _data_Str, ''), true); 
    Focused_CaretToView;
  end;   
end; 

procedure THIHiLightMemo._work_doInsert; 
var
  dt: TData;
begin
  if not (oeReadOnly in Options) then
  begin
    dt := ReadData(_Data, Null);  
    InsertLine(ToIntIndex(dt), ReadString(_Data, _data_Str), true); 
    Focused_CaretToView;
  end;   
end; 

procedure THIHiLightMemo._work_doClear; 
begin
  Text := ''; 
  FLines.Clear;
  FUndoList.Clear;
  FRedoList.Clear;  
  Caret := MakePoint(0, 0); 
  _hi_OnEvent(_event_onChange, Text);
  Focused_CaretToView; 
end; 

procedure THIHiLightMemo._work_doDelete; 
begin
  if not (oeReadOnly in Options) then
  begin 
    DeleteLine(ToIntIndex(_Data), true); 
    Focused_CaretToView;
  end;   
end; 

procedure THIHiLightMemo.SetStrings;
begin
  SetStringsBefore(Length(Value));
  Text := Value;
  SetStringsAfter;
  Focused_CaretToView;
end;

{
procedure THIHiLightMemo._work_doText; 
begin
  Text := ToString(_Data);
  _hi_OnEvent(_event_onChange); 
  Focused_CaretToView; 
end; 

procedure THIHiLightMemo._work_doLoad; 
var
  fn: string; 
  Strm: PStream; 
  SL: PStrList; 
begin
  fn := ReadString(_Data, _data_FileName, _prop_FileName); 
  if not FileExists(fn) then exit; 
  SL := NewStrList; 
  Strm := NewReadFileStream(fn); 
  Strm.Position := 0; 
  SL.LoadFromStream(Strm, false); 
  Text := SL.Text; 
  free_and_nil(Strm); 
  SL.free;
  Focused_CaretToView;   
  _hi_OnEvent(_event_onChange);   
end; 
}

procedure THIHiLightMemo._work_doSave; 
var
  fn: string; 
  Strm: PStream; 
  SL: PStrList;
begin
  SL := NewStrList; 
  SL.Text := Text;
  fn := ReadString(_Data, _data_FileName, _prop_FileName); 
  Strm := NewWriteFileStream(fn); 
  Strm.Position := 0; 
  SL.SaveToStream(Strm); 
  free_and_nil(Strm); 
  Sl.free; 
  Focused_CaretToView;  
end; 

procedure THIHiLightMemo._work_doCut; 
begin
  if not (oeReadOnly in Options) then
  begin 
    Control.Perform(WM_CUT, 0, 0); 
    Focused_CaretToView;
  end;  
end; 

procedure THIHiLightMemo._work_doCopy; 
begin
  Control.Perform(WM_COPY, 0, 0); 
  Focused_CaretToView; 
end; 

procedure THIHiLightMemo._work_doPaste; 
begin
  if not (oeReadOnly in Options) then
  begin 
    Control.Perform(WM_PASTE, 0, 0); 
    Focused_CaretToView;
  end;   
end; 

procedure THIHiLightMemo._work_doFind; 
var
  FROptions: TFindReplaceOptions; 
  SearchStr: string; 
  ReplaceStr: string; 
  FromPos: TPoint; 
begin
  FROptions := []; 
  if _prop_ReplaceAll  then FROptions := FROptions + [froAll]; 
  if _prop_FindBack    then FROptions := FROptions + [froBack]; 
  if _prop_Findcase    then FROptions := FROptions + [frocase]; 
  if _prop_FindSpaces  then FROptions := FROptions + [froSpaces]; 
  if _prop_FindReplace then FROptions := FROptions + [froReplace]; 
  SearchStr  := ReadString(_Data, _data_SearchStr, _prop_SearchStr); 
  ReplaceStr := ReadString(_Data, _data_ReplaceStr, _prop_ReplaceStr); 
  FromPos := MakePoint(ReadInteger(_Data, _data_SearchFrom) and $ffff, ReadInteger(_Data, _data_SearchFrom) shr 16); 
  SearchRes := FindReplace(SearchStr, ReplaceStr, FromPos, FROptions, _prop_SelectFound); 
  Focused_CaretToView; 
end; 

procedure THIHiLightMemo._work_doHilightstrings; 
begin
  _prop_HiLightstrings := ToString(_Data); 
  Focused_CaretToView;   
end; 

procedure THIHiLightMemo._work_doAddHilightstrings; 
begin
  if not Assigned(HS) then
    HS := NewStrList; 
  HS.text := HS.text + #13#10 + ToString(_Data); 
  Focused_CaretToView; 
end; 

procedure THIHiLightMemo._work_doHilightFont; 
begin
  if _IsFont(_Data) then
  with pfontrec(_data.idata)^ do
  begin
    _prop_HilightFont.Style := Style; 
    _prop_HilightFont.Color := Color; 
  end; 
  Focused_CaretToView;   
end; 

procedure THIHiLightMemo._work_doWidthRightMargin; 
begin
  RightMarginchars := ToInteger(_Data); 
  Focused_CaretToView;  
end; 

procedure THIHiLightMemo._work_doSetCaret; 
var
  pos: Cardinal; 
  pnt: TPoint; 
begin
  pos := Cardinal(ToInteger(_Data)); 
  pnt.X := pos and $ffff; 
  pnt.Y := pos shr 16; 
  Caret := pnt; 
  Focused_CaretToView;   
end; 

procedure THIHiLightMemo._work_doReplaceSelect; 
begin
  Selection := ToString(_Data); 
  Focused_CaretToView;   
end; 

procedure THIHiLightMemo._work_doDeleteSelect; 
begin
  DeleteSelection; 
  Focused_CaretToView;   
end; 

procedure THIHiLightMemo._work_doSelectWordUnderCursor; 
begin
  SelectWordUnderCursor; 
  Focused_CaretToView; 
end;   

procedure THIHiLightMemo._work_doSetSelBegin; 
var
  pos: Cardinal; 
  pnt: TPoint; 
begin
  pos := Cardinal(ToInteger(_Data)); 
  pnt.X := pos and $ffff; 
  pnt.Y := pos shr 16; 
  SelBegin := pnt; 
  Focused_CaretToView; 
end; 

procedure THIHiLightMemo._work_doSetSelend; 
var
  pos: Cardinal; 
  pnt: TPoint; 
begin
  pos := Cardinal(ToInteger(_Data)); 
  pnt.X := pos and $ffff; 
  pnt.Y := pos shr 16; 
  Selend := pnt; 
  Focused_CaretToView; 
end; 

procedure THIHiLightMemo._work_doSetSelFrom; 
var
  pos: Cardinal; 
  pnt: TPoint; 
begin
  pos := Cardinal(ToInteger(_Data)); 
  pnt.X := pos and $ffff; 
  pnt.Y := pos shr 16; 
  SelFrom := pnt; 
  Focused_CaretToView; 
end; 

procedure THIHiLightMemo._work_doGetBookMIdx; 
var
  idx: integer; 
begin
  idx := ToIntIndex(_Data); 
  if (idx < 0) or (idx > 9) then exit; 
  _hi_onEvent(_event_onGetBookMIdx, Bookmarks[idx].Y shl 16 + Bookmarks[idx].X); 
  Focused_CaretToView; 
end; 

procedure THIHiLightMemo._work_doSetBookMIdx; 
var
  idx: integer; 
begin
  idx := ToIntIndex(_Data); 
  if (idx < 0) or (idx > 9) then exit; 
  Bookmarks[idx] := Caret; 
  Focused_CaretToView; 
end; 

procedure THIHiLightMemo._Set; 
var
  ind: integer; 
begin
  ind := ToIntIndex(Item); 
  if (ind >= 0) and (ind < Count) and not (oeReadOnly in Options) then
    Lines[ind] := ToString(Val); 
  inherited; 
end; 

function THIHiLightMemo._Get; 
var
  ind: integer; 
begin
  ind := ToIntIndex(Item); 
  if (ind >= 0) and (ind < Count) then
  begin
    Result := true; 
    dtString(Val, Lines[ind]); 
  end
  else
    Result := false; 
end; 

procedure THIHiLightMemo._Add; 
begin
  if oeReadOnly in Options then exit; 
  InsertLine(Count, ToString(Val), false); 
end; 

function  THIHiLightMemo._Count; 
begin
  Result := Count; 
end; 

procedure THIHiLightMemo._var_Array; 
begin
  if Arr = nil then
    Arr := CreateArray(_Set, _Get, _Count, _Add); 
  dtArray(_Data, Arr); 
end; 

procedure THIHiLightMemo._work_doUndo; 
begin
  if not (oeReadOnly in Options) then
  begin 
    Undo; 
    Focused_CaretToView;
  end;   
end; 

procedure THIHiLightMemo._work_doRedo; 
begin
  if not (oeReadOnly in Options) then
  begin 
    Redo; 
    Focused_CaretToView;
  end;   
end; 

procedure THIHiLightMemo._work_doViewToCaret;        begin Focused_CaretToView;                        end; 
procedure THIHiLightMemo._work_doTopLine;            begin TopLine := ToInteger(_Data);                end; 
procedure THIHiLightMemo._work_doLeftCol;            begin LeftCol := ToInteger(_Data);                end; 
procedure THIHiLightMemo._work_doAutoCompstrings;    begin AutoAdd2Dictionary(ToString(_Data)); end; 
procedure THIHiLightMemo._work_doShowAutoComp;       begin AutoCompletionShow;                         end; 
procedure THIHiLightMemo._work_doHideAutoComp;       begin AutoCompletionHide;                         end; 
procedure THIHiLightMemo._work_doClearAutoComp;      begin AutoCompletionClear;                        end; 
procedure THIHiLightMemo._var_Text;                  begin dtString(_Data, Text);                      end; 
procedure THIHiLightMemo._var_Count;                 begin dtInteger(_Data, Count);                    end; 
procedure THIHiLightMemo._var_SelText;               begin dtString(_Data, Selection);                 end; 
procedure THIHiLightMemo._var_TopLine;               begin dtInteger(_Data, TopLine);                  end; 
procedure THIHiLightMemo._var_LeftCol;               begin dtInteger(_Data, LeftCol);                  end; 
procedure THIHiLightMemo._var_LinesPerPage;          begin dtInteger(_Data, LinesPerPage);             end; 
procedure THIHiLightMemo._var_LineHeight;            begin dtInteger(_Data, LineHeight);               end; 
procedure THIHiLightMemo._var_CharWidth;             begin dtInteger(_Data, CharWidth);                end; 
procedure THIHiLightMemo._var_SelAvailable;          begin dtInteger(_Data, Byte(SelectionAvailable)); end; 
procedure THIHiLightMemo._var_CanUndo;               begin dtInteger(_Data, Byte(CanUndo));            end; 
procedure THIHiLightMemo._var_CanRedo;               begin dtInteger(_Data, Byte(CanRedo));            end; 
procedure THIHiLightMemo._var_PositionX;             begin dtInteger(_Data, Caret.X);                  end; 
procedure THIHiLightMemo._var_PositionY;             begin dtInteger(_Data, Caret.Y);                  end; 
procedure THIHiLightMemo._var_PositionMouseX;        begin dtInteger(_Data, FCoordinatMouse.X);        end; 
procedure THIHiLightMemo._var_PositionMouseY;        begin dtInteger(_Data, FCoordinatMouse.Y);        end; 
procedure THIHiLightMemo._var_SelBeginX;             begin dtInteger(_Data, SelBegin.X);               end; 
procedure THIHiLightMemo._var_SelBeginY;             begin dtInteger(_Data, SelBegin.Y);               end; 
procedure THIHiLightMemo._var_SelendX;               begin dtInteger(_Data, Selend.X);                 end; 
procedure THIHiLightMemo._var_SelendY;               begin dtInteger(_Data, Selend.Y);                 end; 
procedure THIHiLightMemo._var_SelFromX;              begin dtInteger(_Data, SelFrom.X);                end; 
procedure THIHiLightMemo._var_SelFromY;              begin dtInteger(_Data, SelFrom.Y);                end; 
procedure THIHiLightMemo._var_SearchResX;            begin dtInteger(_Data, SearchRes.X);              end; 
procedure THIHiLightMemo._var_SearchResY;            begin dtInteger(_Data, SearchRes.Y);              end; 
procedure THIHiLightMemo._var_LinesVisiblePartial;   begin dtInteger(_Data, LinesVisiblePartial);      end; 
procedure THIHiLightMemo._var_ColumnsVisiblePartial; begin dtInteger(_Data, ColumnsVisiblePartial);    end; 
procedure THIHiLightMemo._var_MaxLineWidthOnPage;    begin dtInteger(_Data, MaxLineWidthOnPage);       end; 
procedure THIHiLightMemo._var_MaxLineWidthInText;    begin dtInteger(_Data, MaxLineWidthInText);       end; 
procedure THIHiLightMemo._work_doFindReplace;        begin _prop_FindReplace := ReadBool(_Data);       end; 
procedure THIHiLightMemo._work_doFindBack;           begin _prop_FindBack := ReadBool(_Data);          end; 
procedure THIHiLightMemo._work_doFindcase;           begin _prop_Findcase := ReadBool(_Data);          end; 
procedure THIHiLightMemo._work_doFindSpaces;         begin _prop_FindSpaces := ReadBool(_Data);        end; 
procedure THIHiLightMemo._work_doReplaceAll;         begin _prop_ReplaceAll := ReadBool(_Data);        end;    
procedure THIHiLightMemo._work_doSelectFound;        begin _prop_SelectFound := ReadBool(_Data);       end; 
procedure THIHiLightMemo._work_doAddType;            begin _prop_AddType := ToInteger(_Data);          end; 
procedure THIHiLightMemo._work_doAutoFocus;          begin _prop_AutoFocus := ReadBool(_Data);         end; 
procedure THIHiLightMemo._work_doAllowDelim;         begin _prop_AllowDelim := ReadBool(_Data);        end; 
procedure THIHiLightMemo._work_doAutoSubSpace;       begin _prop_AutoSubSpace := ReadBool(_Data);      end;
procedure THIHiLightMemo._work_doHilightCaseSens;    begin _prop_HilightCaseSens := ReadBool(_Data);   end;

procedure THIHiLightMemo._work_doColorUnderLine; 
begin
  _prop_ColorUnderLine := ToInteger(_Data); 
  Focused_CaretToView;   
end; 

procedure THIHiLightMemo._work_doReadOnly; 
begin
  _prop_ReadOnly := ReadBool(_Data); 
  SetOption(_prop_ReadOnly, oeReadOnly); 
end; 

procedure THIHiLightMemo._work_doSmartTabs; 
begin
  _prop_SmartTabs := ReadBool(_Data); 
  SetOption(_prop_SmartTabs, oeSmartTabs); 
end; 

procedure THIHiLightMemo._work_doAutoComplete; 
begin
  _prop_AutoComplete := ReadBool(_Data); 
  SetOption(_prop_AutoComplete, oeAutoCompletion); 
end; 

procedure THIHiLightMemo._work_doOverwrite; 
begin
  _prop_Overwrite := ReadBool(_Data); 
  SetOption(_prop_Overwrite, oeOverwrite); 
end; 

procedure THIHiLightMemo._work_doHilight; 
begin
  _prop_Hilight := ReadBool(_Data); 
  SetOption(_prop_Hilight, oeHighLight); 
end; 

procedure THIHiLightMemo._work_doMinWordLen; 
begin
  _prop_MinWordLen := ToInteger(_Data); 
  AutoCompleteMinWordLength := _prop_MinWordLen; 
  Focused_CaretToView; 
end; 

procedure THIHiLightMemo._work_doIndent; 
begin
  ResetIndent; 
  _prop_Indent := ToInteger(_Data); 
  Indent(_prop_Indent); 
  FSelEnd := FSelBegin;
  Focused_CaretToView; 
end;

procedure THIHiLightMemo._work_doIndentSelect; 
var
  idt: integer;
begin
  idt := ToInteger(_Data); 
  Indent( - max(_prop_Indent, idt)); 
  Indent(idt);
  FSelEnd := FSelBegin;
  Caret := MakePoint(Caret.X + _prop_Indent + 1, Caret.Y); 
  Focused_CaretToView;
end;  

procedure THIHiLightMemo._work_doRightMargin; 
begin
  _prop_RightMargin := ReadBool(_Data); 
  DrawRightMargin := _prop_RightMargin; 
  Focused_CaretToView; 
end; 

procedure THIHiLightMemo._work_doColorRightMargin; 
begin
  _prop_ColorRightMargin := ToInteger(_Data); 
  RightMargincolor := _prop_ColorRightMargin; 
  Focused_CaretToView; 
end; 

procedure THIHiLightMemo._var_WordAtPos; 
begin
  dtString(_Data, WordAtPos(MakePoint(ToIntegerEvent(_data_WordPosition) and
           $ffff, ToIntegerEvent(_data_WordPosition) shr 16))); 
end; 

procedure THIHiLightMemo._var_WordAtPosMouse; 
begin
  dtString(_Data, WordAtPos(FCoordinatMouse)); 
end; 

procedure THIHiLightMemo._var_WordAtPosStartY; 
begin
  dtInteger(_Data, WordAtPosStart(MakePoint(ToIntegerEvent(_data_WordPosition) and
            $ffff, ToIntegerEvent(_data_WordPosition) shr 16)).Y); 
end; 

procedure THIHiLightMemo._var_WordAtPosStartX; 
begin
  dtInteger(_Data, WordAtPosStart(MakePoint(ToIntegerEvent(_data_WordPosition) and
            $ffff, ToIntegerEvent(_data_WordPosition) shr 16)).X); 
end; 

procedure THIHiLightMemo.AdjustHScroll; 
var
  SBInfo: TScrollInfo; 
begin
  SBInfo.cbSize := Sizeof(SBInfo); 
  SBInfo.fMask := Sif_PAGE or Sif_POS or Sif_RANGE; 
  SBInfo.nMin := 0; 
  SBInfo.nMax := Max(MaxLineWidthInText, Caret.X + 1); 
  SBInfo.nPage := ColumnsVisiblePartial; 
  SBInfo.nPos := FLeftCol; 
  SBInfo.nTrackPos := FLeftCol; 
  SetScrollInfo(Control.Handle, SB_HORZ, SBInfo, true); 
end; 

procedure THIHiLightMemo.AdjustVScroll; 
var
  SBInfo: TScrollInfo; 
begin
  SBInfo.cbSize := Sizeof(SBInfo); 
  SBInfo.fMask := Sif_PAGE or Sif_POS or Sif_RANGE; 
  SBInfo.nMin := 0; 
  SBInfo.nMax := Count - 1; 
  SBInfo.nPage := LinesPerPage; 
  SBInfo.nPos := TopLine; 
  SBInfo.nTrackPos := TopLine; 
  SetScrollInfo(Control.Handle, SB_VERT, SBInfo, true); 
end; 

procedure THIHiLightMemo.AutoAdd2Dictionary; 
var
  S, From: PChar;
  str: string;
  i, c, L, LItem: integer; 
  W: string; 
  handled: boolean; 
begin
  str := SC + #0;
  S := @str[1];
  while S^ <> #0 do
  begin
    if S^ in ['A'..'Z', 'a'..'z', 'А'..'Я', 'а'..'я', 'Ё', 'ё', '_', '~'] then
    begin
      From := S; inc(S); 
      while S^ in ['A'..'Z', 'a'..'z', 'А'..'Я', 'а'..'я', 'Ё', 'ё', '_', '~'] do
      begin
        if (S^ = '_') and _prop_AutoSubSpace then S^ := ' ';
        inc(S);
      end;
      L := Cardinal(S) - Cardinal(From); 
      if L > AutoCompleteMinWordLength then
      begin
        handled := false; 
        for i := 0 to FDictionary.Count - 1 do
        begin
          c := AnsiStrLComp(From, FDictionary.ItemPtrs[i], L); 
          if c = 0 then
          begin
            if L < Length(FDictionary.Items[i]) then
            begin
              Setstring(W, From, L); 
              FDictionary.Insert(i, W); 
              _hi_onEvent(_event_onAddAutoComp, W); 
            end; // иначе эта строка уже есть в словаре
            handled := true; 
            break; 
          end
          else
            if c > 0 then // такого слова еще нет?
            begin
              LItem := Length(FDictionary.Items[i]); 
              if (LItem < L) and (AnsiStrLComp(From, FDictionary.ItemPtrs[i], LItem) = 0) then
                continue; // еще не нашлось, двигаем дальше
              SetString(W, From, L); 
              FDictionary.Insert(i, W); 
              _hi_onEvent(_event_onAddAutoComp, W); 
              handled := true; 
              break; 
            end; 
            // если c < 0, продолжаем искать место для вставки
            // в итоге словарь автоматически отсортирован по алфавиту
        end; 
        if not handled then // добавить слово в конец
        begin
          Setstring(W, From, L); 
          FDictionary.Add(W); 
          _hi_onEvent(_event_onAddAutoComp, W); 
        end; 
      end; 
    end
      else inc(S); 
  end;
end; 

procedure THIHiLightMemo.AutoCompleteWord; 
var
  W: string; 
  M: TMsg; 
begin
  // подавить WM_CHAR, который может прийти по ENTER: 
  PeekMessage(M, FAutoCompletionList.Handle, WM_CHAR, WM_CHAR, pm_Remove); 
  AutoCompletionHide; 
  if n < 0 then exit; // кликнули мимо - не заменять
  W := FDictionary.Items[FAutoFirst + n]; 
  if _prop_AllowDelim then
  begin
    W := W + '~'; 
    W := FParse(W, '~'); 
  end; 
  inc(FAutoCount); 
  FDictionary.Objects[FAutoFirst + n] := FAutoCount; 
  SelectWordUnderCursor; 
  Selection := W; 
  _hi_onEvent(_event_onAutoComp, W); 
end; 

procedure THIHiLightMemo.AutoCompletionClear; 
begin
  FDictionary.Clear; 
end; 

procedure THIHiLightMemo.AutoCompletionHide; 
begin
  if Assigned(FAutoCompletionForm) and FAutoCompletionForm.Visible then
    FAutoCompletionForm.Hide; 
end; 

procedure THIHiLightMemo.AutoCompletionShow; 
var
  W, W1:         string; 
  FromPos, Pt:   TPoint; 
  DR:            TRect; 
  i, j, BestIdx: integer; 
  BestCounter:   Cardinal; 
  DicW:          PChar; 
begin
  W := WordAtPos(Caret); 
  W1 := W; 
  if (W = '') or not(oeAutoCompletion in Options) then
  begin
    AutoCompletionHide; 
    exit; 
  end; 
  if Assigned(FAutoCompletionForm) and FAutoCompletionForm.Visible and (FAutoWord = W) and
             (FAutoPos.X = FCaret.X) and (FAutoPos.Y = FCaret.Y) then
    exit; // для этого слова уже показана
  FAutoPos := Caret; 
  FAutoWord := W; 
  AutoCompletionHide; 
  FromPos := WordAtPosStart(Caret); 
  W := Copy(W, 1, Caret.X - FromPos.X); 
  if Length(W) < AutoCompleteMinWordLength then exit; 

  for i := 0 to FDictionary.Count - 1 do
  begin
    DicW := FDictionary.ItemPtrs[i]; 
    if AnsiStrLComp(PChar(W), DicW, Length(W)) = 0 then
    begin
      FAutoFirst := i; 
      FAutoCount := 0; 
      BestIdx := i; 
      BestCounter := 0; 
      for j := i + 1 to FDictionary.Count do
      begin
        DicW := FDictionary.ItemPtrs[j]; 
        if (j >= FDictionary.Count) or
           (AnsiStrLComp(PChar(W), DicW, Length(W)) <> 0) then
        begin
          FAutoCount := j - i; 
          break; 
        end
        else
          if FDictionary.Objects[j] > BestCounter then
          begin
            BestCounter := FDictionary.Objects[j]; 
            BestIdx := j; 
          end; 
      end; 
      if FAutoCount > 0 then
      begin
        if (FAutoCount = 1) and
           (AnsiCompareStrNocase(FDictionary.Items[FAutoFirst], W1) = 0) then
          exit; // есть только 1 слово и оно совпадает с тем что под кареткой
        if FAutoCompletionForm = nil then
        begin
          FAutoCompletionForm := NewForm(Applet, '').SetSize(200, 200); 
            { Внимание! Во избежание проблем Applet должен использоваться как
              отдельный объект KOL.TApplet ! }
          FAutoCompletionForm.Visible := false; 
          FAutoCompletionForm.Style := WS_POPUP or WS_TABSTOP or WS_CLIPCHILDREN or
                                       WS_THICKFRAME or WS_CLIPSIBLINGS; 
          FAutoCompletionForm.MinHeight := 100; 
          FAutoCompletionForm.OnShow := AutoFormShowEvent; 
          FAutoCompletionList := NewListView(FAutoCompletionForm, lvsDetailNoHeader, 
                                             [lvoRowSelect, lvoOwnerData], nil, nil, nil).SetAlign(caClient); 
          FAutoCompletionList.LVColAdd('', taLeft, 20); 
          FAutoCompletionList.OnMessage := AutoListMessage; 
          FAutoCompletionList.OnLVData := AutoListData; 
        end; 
        FAutoCompletionForm.Font.Assign(Control.Font); 
        FAutoCompletionList.LVCount := 0; // сброс - на всякий случай
        Pt := MakePoint((Caret.X - LeftCol)*CharWidth, (Caret.Y + 1 - TopLine)*LineHeight); 
        Pt := Control.Client2Screen(Pt); 
        DR := GetDesktopRect; 
        if Pt.x + FAutoCompletionForm.Width > DR.Right then
          Pt.x := Pt.x - FAutoCompletionForm.Width; 
        if Pt.x < DR.Left then Pt.x := DR.Left; 
        if Pt.y + FAutoCompletionForm.Height > DR.Bottom then
          Pt.y := Pt.y - LineHeight - FAutoCompletionForm.Height; 
        FAutoCompletionForm.Position := Pt; 
        FAutoCompletionForm.Show; 
        FAutoCompletionForm.BringToFront; 
        FAutoCompletionList.LVCount := FAutoCount; 
        FAutoCompletionList.Focused := true; 
        FAutoBestFirst := BestIdx - FAutoFirst; 
      end; 
      exit; 
    end; 
  end; 
end; 

  { Обработчик сообщений для list view формы, в котором показан список слов для
    автоматического завершения по ENTER или клику мыши. }

procedure THIHiLightMemo.AutoformCloseEvent; 
begin
  Accept := false; 
  FAutoCompletionForm.Hide; 
end; 

procedure THIHiLightMemo.AutoFormShowEvent; 
begin
  SendMessage(FAutoCompletionList.Handle, WM_USER + msgShow, 0, 0); 
end; 

procedure THIHiLightMemo.AutoListData; 
begin
  Txt := FDictionary.Items[FAutoFirst + Idx]; 
end; 

function THIHiLightMemo.AutoListMessage; 
begin
  Result := false; 
  case Msg.message of
    WM_KILLFOCUS: { Так, мы не нужны - скроемся с глаз }
      begin
        FnotAdd2Dictionary1time := true; 
        AutoCompletionHide; 
        FnotAdd2Dictionary1time := false; 
        Focused_CaretToView(true); // обязательный возврат фокуса родителю  
      end; 
    WM_KEYUP, WM_SYSKEYUP, WM_SYSKEYDOWN, WM_SYSCHAR, 
    WM_CHAR: { Это не к нам, отдать в HilightMemo }
      Control.Perform(Msg.message, Msg.wParam, Msg.lParam); 
    WM_KEYDOWN: { К нам относится только UP, DOWN, ENTER - все остальное отдать
                  хозяину на обработку }
      case Msg.wParam of
        VK_UP, VK_DOWN:; // Пусть list view позаботится
        VK_RETURN: AutoCompleteWord(FAutoCompletionList.LVCurItem);
        VK_ESCAPE: AutoCompletionHide; 
      else
        Control.Perform(Msg.message, Msg.wParam, Msg.lParam); 
      end; 
    WM_LBUTTONDOWN: // Авто - завершить по клику на слове, закрыть по клику вне списка
      begin
        FAutoCompletionList.LVCurItem  := FAutoCompletionList.LVItemAtPos(loWord(Msg.lParam), hiWord(Msg.lParam)); 
        SendMessage(FAutoCompletionList.Handle, WM_USER + msgComplete, 0, 0); 
      end;   
    WM_USER + msgComplete: AutoCompleteWord(FAutoCompletionList.LVCurItem);
    WM_SIZE: // выровнять ширину колонки: 
      FAutoCompletionList.LVColWidth[0] := FAutoCompletionList.ClientWidth - 2; 
    WM_USER + msgShow:
      begin
        FAutoCompletionList.LVCurItem := FAutoBestFirst; 
        FAutoCompletionList.LVMakeVisible(FAutoBestFirst, false); 
      end; 
   end; 
end; 

function THIHiLightMemo.CanRedo; 
begin
  Result := FRedoList.Count > 0; 
end; 

function THIHiLightMemo.CanUndo; 
begin
  Result := FUndoList.Count > 0; 
end; 

procedure THIHiLightMemo.CaretToView; 
begin
  if Caret.X < LeftCol then
    LeftCol := Caret.X
  else
    if LeftCol + Control.ClientWidth div CharWidth < Caret.X + 1 then
      LeftCol := Caret.X + 1 - Control.ClientWidth div CharWidth; 
  if Caret.Y < TopLine then
    TopLine := Caret.Y
  else
    if TopLine + LinesPerPage <= Caret.Y then
  TopLine := Caret.Y - LinesPerPage + 1; 
  Caret := Caret; 
end; 

procedure THIHiLightMemo.Changed; 
var
  y, k: integer; 
  L:    string; 
begin
  if FChangeLevel <= 0 then exit; 
  dec(FChangeLevel); 
  if FChangeLevel = 0 then
  begin
    if not FUndoingRedoing then
    begin
      if FUndoList.Last[1] = 'B' then // не было изменений
      begin
        FUndoList.Delete(FUndoList.Count - 1);
        exit; 
      end
      else // завершается цепочка изменений
      begin
        FRedoList.Clear; 
        FUndoList.Add('E' + Int2Str(Caret.X) + ':' + Int2Str(Caret.Y)); 
        // Сделаем оптимизацию для случая последовательных изменений
        // в пределах одной строки: 
        k := FUndoList.Count; 
        if (k >= 6) and
           (FUndoList.Items[k - 2][1] = 'R') and
           (FUndoList.Items[k - 3][1] = 'B') and
           (FUndoList.Items[k - 4][1] = 'E') and
           (FUndoList.Items[k - 5][1] = 'R') and
           (FUndoList.Items[k - 6][1] = 'B') then
         begin
           L := FUndoList.Items[k - 5]; 
           Delete(L, 1, 1); 
           y := Str2Int(L); 
           if y = Caret.Y then // Да, изменения в той же строке:
           begin 
             FUndoList.Delete(k - 2); 
             FUndoList.Delete(k - 3); 
             FUndoList.Delete(k - 4); 
               { Из новой порции сохраняется только последняя строка, 
                 в которой запоминаются новые координаты курсора }
           end; 
         end; 
       end; 
    end; 
    if Assigned(Control.OnChange) then Control.OnChange(Control); 
  end; 
end; 

procedure THIHiLightMemo.Changing; 
begin
  inc(FChangeLevel); 
  if FUndoingRedoing then exit; 
  if FChangeLevel = 1 then
    FUndoList.Add('B' + Int2Str(Caret.X) + ':' + Int2Str(Caret.Y)); 
end; 

function THIHiLightMemo.CharWidth; 
begin
  if FCharWidth = 0 then
  begin
    FBitmap.Canvas.Font.Assign(Control.Font); 
    FCharWidth := Control.Canvas.TextWidth('W'); 
  end; 
  Result := FCharWidth; 
end; 

procedure THIHiLightMemo.Clear; 
var
  i: integer; 
begin
  Text := ''; 
  FUndoList.Clear; 
  FRedoList.Clear; 
  for i := 0 to 9 do
    Bookmarks[i] := MakePoint(0, 0); 
end; 

function THIHiLightMemo.Client2Coord; 
begin
  Result := MakePoint(P.X div CharWidth + LeftCol, P.Y div LineHeight + TopLine); 
end; 

function THIHiLightMemo.ColumnsVisiblePartial; 
begin
  Result := Control.ClientWidth div CharWidth; 
  if Result * CharWidth < Control.ClientWidth then
    inc(Result); 
end; 

procedure THIHiLightMemo.DeleteLine; 
var
  R: TRect; 
begin
  if y >= Count then exit; 
  Changing; 
  DeleteLine1(y); 
  if (y >= TopLine) and (y < TopLine + LinesVisiblePartial) then
  begin
    if UseScroll and (y < TopLine + LinesPerPage) then
    begin
      R := MakeRect(0, (y + 1 - TopLine)*LineHeight, Control.ClientWidth, Control.ClientHeight); 
      ScrollWindowEx(Control.Handle, 0, - LineHeight, @ R, nil, 0, nil, SW_INVALIDATE); 
    end
    else
    begin
      R := MakeRect(0, (y - TopLine)*LineHeight, Control.ClientWidth, Control.ClientHeight); 
      InvalidateRect(Control.Handle, @ R, true); 
    end; 
  end; 
  Changed; 
  FixBookmarks(MakePoint(0, y), 0, - 1); 
  TopLine := TopLine; 
end; 

procedure THIHiLightMemo.DeleteLine1; 
begin
  if y >= Count then exit; 
  if not FUndoingRedoing then
    FUndoList.Add('D' + Int2Str(y) + '=' +  FLines.Items[y]); 
  FLines.Delete(y); 
end; 

procedure THIHiLightMemo.DeleteSelection; 
var
  i, n: integer; 
  L:    string; 
begin
  Changing; 
  Caret := SelBegin; 
  i := SelBegin.Y + 1; 
  n := 0; 
  while i < Selend.Y do // удаляется строка целиком
  begin
    DeleteLine1(i); 
    dec(FSelEnd.Y); 
    inc(n); 
  end; 

  L := Copy(Lines[SelBegin.Y], 1, SelBegin.x); 
  if Length(L) < SelBegin.x then
    L := L + StrRepeat(' ', SelBegin.x - Length(L)); 
  L := L + Copyend(Lines[Selend.y], Selend.x + 1); 
  if SelBegin.y < Selend.y then // склеиваются две строки
    DeleteLine(Selend.y, n = 0); 
  Lines[SelBegin.y] := L; 

  if n > 0 then
  begin
    FixBookmarks(SelBegin, 0, - n); 
    TopLine := TopLine; 
    InvalidateRect(Control.Handle, nil, false); 
  end; 

  SetSel(SelBegin, SelBegin, SelBegin); 
  Changed; 
  CaretToView; 
end; 

procedure THIHiLightMemo.DoKeyChar; 
var
  S, S1:  string; 
  t:      integer;

  procedure InsertChar(C: Char); 
  begin
    S := Lines[Caret.Y]; 
    while Length(S) < Caret.X do S := S + ' '; 
    S := Copy(S, 1, Caret.X) + Key + Copyend(S, Caret.X + 1); 
    Lines[Caret.Y] := S; 
  end; 

var
  NeedAdd2Dictionary: integer; 
  CanShowAutoCompletion: boolean; 

begin
  if oeReadOnly in Options then exit; 
  Changing;
  NeedAdd2Dictionary := - 1; 
  CanShowAutoCompletion := false; 
TRY
  S := Lines[Caret.Y];
  if S = '' then 
  S1 := S; 
  case Key of
    #27:; // escape - игнорируем (или закрываем окно Autocompletion)
    #13:  // enter
      begin
        if SelectionAvailable then
        begin
          Caret := SelBegin; 
          DeleteSelection; 
          if oeOverwrite in Options then
          begin
            CaretToView; 
            Changed; 
            exit; 
          end; 
        end; 
        if oeOverwrite in Options then
        begin
          // просто переход в начало следующей строки при Overwrite
          if Caret.Y = Count - 1 then
            Lines[Caret.Y + 1] := ''; 
            NeedAdd2Dictionary := Caret.Y; 
            Caret := MakePoint(_prop_Indent, Caret.Y + 1); 
        end
        else // разбиение строки на 2 и переход в начало следующей строки
        begin
          S := Lines[Caret.Y]; 
          Lines[Caret.Y] := Copy(S, 1, Caret.X); 
          S := Copyend(S, Caret.X + 1); 
          NeedAdd2Dictionary := Caret.Y; 
          Caret := MakePoint(_prop_Indent, Caret.Y + 1);

          // предварить необходимым количеством пробелов для SmartTab
          t := 0;
          if oeSmartTabs in Options then
            t := FindNextTabPos(Caret);
          if t > 0 then
          begin
            S := StrRepeat(' ', t) + S; 
            Caret := MakePoint(t - _prop_Indent, Caret.Y); 
          end; 
          InsertLine(Caret.Y, S, true, true); 
        end; 
        CaretToView;
      end; 
    #9: // tab
      begin
        if not SelectionAvailable and (oeOverwrite in Options) then
          SetSel(Caret, MakePoint(Caret.X + 1, Caret.Y), Caret); 
        if SelectionAvailable then
        begin
          Caret := SelBegin; 
          DeleteSelection; 
          CaretToView; 
        end; 
        S := Lines[Caret.Y]; 
        t := Caret.X; 
        if oeSmartTabs in Options then
          t := FindNextTabPos(Caret); 
        NeedAdd2Dictionary := Caret.Y; 
        if t > Caret.X then
        begin
          S := Copy(S, 1, Caret.X) + StrRepeat(' ', t - Caret.X) + Copyend(S, Caret.X + 1); 
          Lines[Caret.Y] := S; 
          Caret := MakePoint(t, Caret.Y); 
          SetSel(Caret, Caret, Caret); 
        end
        else
        begin
          InsertChar(#9); 
          Caret := MakePoint(((Caret.X + 8) div 8) * 8, Caret.Y); 
        end; 
      end; 
    #8: // backspace
      begin
        if SelectionAvailable then
        begin
          Caret := SelBegin; 
          DeleteSelection; 
          CaretToView; 
          exit; 
        end; 
        if Caret.X > 0 then // удаление символа
        begin
          NeedAdd2Dictionary := Caret.Y; 
          t := Caret.X; 
          if (oeSmartTabs in Options) and (t > 0) and (Trim(Copy(S, 1, t)) = '') then
            t := FindPrevTabPos(Caret); 
          if t < Caret.X then
          begin
            Delete(S, t + 1, Caret.X - t); 
            Lines[Caret.Y] := S; 
            Caret := MakePoint(t, Caret.Y); 
          end
          else
          begin
            Delete(S, Caret.X, 1); 
            Lines[Caret.Y] := S; 
            Caret := MakePoint(Caret.X - 1, Caret.Y); 
          end; 
        end
        else // слияние строки с предыдущей
        begin
          if Caret.Y = 0 then exit; // не с чем сливать
          S1 := Lines[Caret.Y - 1]; 
          Caret := MakePoint(Length(S1), Caret.Y - 1); 
          NeedAdd2Dictionary := Caret.Y; 
          S1 := S1 + S; 
          Lines[Caret.Y] := S1; 
          DeleteLine(Caret.Y + 1, true); 
        end; 
      end; 
      else // any char (edit)
        if Key < ' ' then exit; // прочие управляющие коды игнорируем
      if not SelectionAvailable and (oeOverwrite in Options) then
        SetSel(Caret, MakePoint(Caret.X + 1, Caret.Y), Caret); 
      if SelectionAvailable then
      begin
        Caret := SelBegin; 
        DeleteSelection; 
        CaretToView; 
      end; 
      if Key in ['A'..'Z', 'a'..'z', 'А'..'Я', 'а'..'я', 'Ё', 'ё', '_', '~', '0'..'9'] then
        CanShowAutocompletion := true
      else
        NeedAdd2Dictionary := Caret.Y; 
      InsertChar(Key); 
      if (Length(Lines[Caret.Y]) = 1) and (Caret.Y = 0) then
      begin
        Indent(_prop_Indent);
        Caret := MakePoint(_prop_Indent + 1, 0);
      end
      else
        Caret := MakePoint(Caret.X + 1, Caret.Y);
  end; 
  SetSel(Caret, Caret, Caret);
FINALLY
  Changed; 
  CaretToView; 
END; 
  if (NeedAdd2Dictionary >= 0) and (NeedAdd2Dictionary < Count) then
    AutoAdd2Dictionary(FLines.ItemPtrs[NeedAdd2Dictionary]); 
  if CanShowAutocompletion then
    AutoCompletionShow
  else
    AutoCompletionHide; 
end; 

procedure THIHiLightMemo.DoKeyDown; 

  procedure MoveLeftUp(NewCaretX, NewCaretY: integer); 
  begin
    if (NewCaretX < 0) and (NewCaretY > 0) then
    begin
      dec(NewCaretY); 
      NewCaretX := Length(Lines[NewCaretY]); 
    end; 
    Caret := MakePoint(NewCaretX, Min(Count - 1, Max(0, NewCaretY))); 
    CaretToView; 
    if Shift and MK_SHifT <> 0 then
      SetSel(Caret, SelFrom, SelFrom)
    else
    SetSel(Caret, Caret, Caret); 
  end; 

  procedure MoveRightDown(NewCaretX, NewCaretY: integer); 
  begin
    Caret := MakePoint(Max(0, NewCaretX), Min(Count - 1, Max(0, NewCaretY))); 
    CaretToView; 
    if Shift and MK_SHifT <> 0 then
      SetSel(SelFrom, Caret, SelFrom)
    else
      SetSel(Caret, Caret, Caret); 
  end; 
   
var
  NewCaret: TPoint; 
  S:        string; 
begin
  Changing; 
TRY
  case Key of
  VK_LEFT:
    if Shift and MK_CONTROL <> 0 then
    begin
      NewCaret := WordAtPosStart(Caret); 
      NewCaret := FindPrevWord(NewCaret, true); 
      MoveLeftUp(NewCaret.X, NewCaret.Y); 
    end
    else
      MoveLeftUp (Caret.X - 1, Caret.Y); 
  VK_RIGHT: 
    if Shift and MK_CONTROL <> 0 then
    begin
      NewCaret := WordAtPosStart(Caret); 
      inc(NewCaret.X, Length(WordAtPos(Caret))); 
      NewCaret := FindNextWord(NewCaret, true); 
      MoveRightDown(NewCaret.X, NewCaret.Y); 
    end
    else
      MoveRightDown(Caret.X + 1, Caret.Y); 
  VK_HOME:
    if Shift and MK_CONTROL <> 0 then
      MoveLeftUp (0, 0)
    else
      MoveLeftUp (0, Caret.Y); 
  VK_END:
    if Shift and MK_CONTROL <> 0 then
      MoveRightDown(Length(TrimRight(Lines[Caret.Y])), Count - 1)
    else
      MoveRightDown(Length(TrimRight(Lines[Caret.Y])), Caret.Y); 
  VK_UP:
    MoveLeftUp   (Caret.X, Caret.Y - 1); 
  VK_DOWN:
    MoveRightDown(Caret.X, Caret.Y + 1); 
  VK_PAGE_UP:
    MoveLeftUp   (Caret.X, Caret.Y - LinesPerPage); 
  VK_PAGE_DOWN:
    MoveRightDown(Caret.X, Caret.Y + LinesPerPage); 
  VK_DELETE:
    if oeReadOnly in Options then
    begin
      Changed;
      exit; 
    end
    else if SelectionAvailable then
    begin
      if Shift and MK_SHifT <> 0 then
        Control.Perform(WM_CUT, 0, 0)
      else
      begin
        Caret := SelBegin; 
        DeleteSelection; 
      end; 
    end
    else if Caret.X >= Length(Lines[Caret.Y]) then // слияние строк
    begin
      if Caret.Y = Count - 1 then exit; 
      S := Lines[Caret.Y]; 
      while Length(S) < Caret.X do
        S := S + ' ';
      Lines[Caret.Y] := S + Copy(Lines[Caret.Y + 1], _prop_Indent + 1, Length(Lines[Caret.Y + 1])); 
      DeleteLine(Caret.Y + 1, true); 
      SetSel(Caret, Caret, Caret); 
    end
    else // удаление одного символа
    begin
      S := Lines[Caret.Y]; 
      Delete(S, Caret.X + 1, 1); 
      Lines[Caret.Y] := S; 
    end; 
  VK_INSERT:
    if oeReadOnly in Options then
      exit
    else if Shift and MK_SHifT <> 0 then
      Control.Perform(WM_PASTE, 0, 0)
    else if Shift = 0 then
    begin
      if oeOverwrite in Options then
        Options := Options - [oeOverwrite]
      else
        Options := Options + [oeOverwrite]; 
      Caret := Caret; 
    end; 
  Word('V'):
    if oeReadOnly in Options then
      exit
    else if Shift and MK_CONTROL <> 0 then
      Control.Perform(WM_PASTE, 0, 0); 
  Word('Y'):
    if oeReadOnly in Options then
      exit
    else if Shift and MK_CONTROL <> 0 then
    begin
      DeleteLine(Caret.Y, true); 
      Caret := Caret; 
    end; 
  Word('X'):
    if oeReadOnly in Options then
      exit
    else if Shift and MK_CONTROL <> 0 then
      Control.Perform(WM_CUT, 0, 0); 
  Word('C'):
    if Shift and MK_CONTROL <> 0 then
      Control.Perform(WM_COPY, 0, 0); 
  Word('A'):
    if Shift and MK_CONTROL <> 0 then
      SetSel(MakePoint(0, 0), MakePoint(0, FLines.Count), MakePoint(0, 0)); 
  Word('Z'):
    begin
      if oeReadOnly in Options then exit; 
      while FChangeLevel > 0 do Changed; 
        { устраняем строку B < x > : < y > , добавленную вызовом Changing }
      if Shift and MK_CONTROL <> 0 then
      begin
        if Shift and MK_SHifT <> 0 then // ctrl + shift + Z - redo
          Redo
        else
          Undo; 
      end; 
      exit; { предотвращаем вызов Changed }
    end; 
  end; 
FINALLY
  Changed; 
END; 
  if (Key in [Word('0')..Word('9')]) and (GetKeyState(VK_CONTROL) < 0) then
    if GetKeyState(VK_SHIFT) < 0 then
    begin
      Bookmarks[ord(Key) - ord('0')] := Caret;
      _hi_onEvent(_event_onBookMIdx, ord(Key) - ord('0')); 
    end  
    else
    begin
      if (Bookmarks[ord(Key) - ord('0')].X and Bookmarks[ord(Key) - ord('0')].Y) = 0 then exit;  
      Caret := Bookmarks[ord(Key) - ord('0')]; 
      CaretToView;
      Control.Perform(WM_PAINT, 0, 0);
    end; 
end; 

procedure THIHiLightMemo.DoMouseDown; 
var
  Pt:    TPoint; 
  Attrs: TTokenAttrs; 
  S:     string; 
  i, j:  integer; 
begin
  Pt := MakePoint(X div CharWidth + LeftCol, Y div LineHeight + TopLine); 
  if Shift and MK_SHifT <> 0 then
    SetSel(SelFrom, Pt, SelFrom)
  else
    SetSel(Pt, Pt, Pt); 
  Caret := Pt;
  FMouseDown := true; 
  SetCapture(Control.Handle); 
  if not ((oeReadOnly in Options) and (oeHighLight in Options)) then exit; 
  S := Lines[SelFrom.Y]; 
  if S = '' then exit; 
  i := 0; 
  while (i < Length(S)) do
  begin
    onScanToken(Control, MakePoint(i, SelFrom.Y), Attrs);     
    if fsUnderline in Attrs.fontstyle then
    begin 
      j := i; 
      if (S[j + 1] <= ' ') then
        while (j < Length(S)) and (S[j + 1] <= ' ') do inc(j)
      else
        while (j < Length(S))  and (S[j + 1] > ' ') do inc(j); 
      if (SelFrom.X >= i) and (SelFrom.X < j) then
      begin
        S := Copy(S, i, j - i + 1);        
        while (S[Length(S)] in ['!'..'/', ':'..'?', '['..'`']) do deleteTail(S, 1); 
        _hi_OnEvent(_event_onClickUnderLineStr, S); 
        exit; 
      end; 
      i := j + 1; 
      Continue; 
    end
    else
      inc(i); 
  end; 
end; 

procedure THIHiLightMemo.DoMouseMove; 
var
  Pt: TPoint;
begin
  Pt := MakePoint(Round(X / CharWidth) + LeftCol, Y div LineHeight + TopLine);
  FCoordinatMouse := Pt; 
  if not FMouseDown then
  begin
    if not ((oeReadOnly in Options) and (oeHighLight in Options)) then exit; 
    InvalidateRect(Control.Handle, nil, false); 
    exit; // todo: возможна активная реакция на движение мыши?
  end;
  SetSel(SelFrom, Pt, SelFrom); 
  Caret := Pt; 
  CaretToView; 
end; 

procedure THIHiLightMemo.DoPaint; 
var
  x, y, i, L:        integer; 
  R, R0, Rsel, CR:   TRect; 
  OldClip, NewClip:  HRgn; 
  P, MPSTART, MPend: TPoint; 
  Attrs:             TTokenAttrs; 
  Canvas:            PCanvas; 
begin
  CR := Control.ClientRect;
  NewClip := CreateRectRgnIndirect(CR);
  CombineRgn(NewClip, NewClip, Control.UpdateRgn, RGN_AND); 
  SelectClipRgn(DC, NewClip); 
  DeleteObject(NewClip); 
  y := 0; 
  if (FBufferBitmap <> nil) and ((FBufferBitmap.Width < Control.ClientWidth) or (FBufferBitmap.Height < LineHeight)) then
    Free_And_Nil(FBufferBitmap); 
  if FBufferBitmap = nil then
    FBufferBitmap := NewDIBBitmap(Control.ClientWidth, LineHeight, pf32bit); 
  Canvas := FBufferBitmap.Canvas; 
  Canvas.Font.Assign(Control.Font);

  for i := TopLine to TopLine + LinesPerPage + 1 do
  begin
    if y >= CR.Bottom then break; 
    if i >= Count then break; 
    R := MakeRect(0, y, CR.Right, y + LineHeight); 
    R0 := R; 
    offsetRect(R0, - R0.Left, - R0.Top); 
    if SelectionAvailable and (FSelBegin.Y <= i) and (FSelEnd.Y >= i) then // по крайней мере часть строки попадает в выделение:
    begin 
      Control.Canvas.Brush.Color := clHighlight; 
      Control.Canvas.Font.Color := clHighlightText; 
      Rsel := R; 
      if i = SelBegin.Y then
        Rsel.Left := Max(0, (FSelBegin.X - FLeftCol)*CharWidth); 
      if i = Selend.Y then
        Rsel.Right := Max(0, (FSelEnd.X - FLeftCol)*CharWidth); 
      if Rsel.Right > Rsel.Left then
      begin
        OldClip := CreateRectRgn(0, 0, 0, 0); 
        GetClipRgn(DC, OldClip); 
        NewClip := CreateRectRgnIndirect(Rsel); 
        SelectClipRgn(DC, NewClip); 
        Control.Canvas.FillRect(R); 
        P := MakePoint(0, i); 
        while P.X < LeftCol + ColumnsVisiblePartial do
        begin
          Control.Canvas.TextOut(R0.Left + (P.X - LeftCol)*CharWidth, R.Top, Copy(Lines[i], P.X + 1, 1)); 
          inc(P.X); 
        end; 
        SelectClipRgn(DC, OldClip); 
        ExtSelectClipRgn(DC, NewClip, RGN_DifF); 
        DeleteObject(NewClip); 
        DeleteObject(OldClip); 
      end; 
      Control.Canvas.Font.Color := _prop_Font.Color;
    end; 
    if RectInRegion(Control.UpdateRgn, R) then
    begin
      Canvas.Brush.Color := Control.Color; 
      if Assigned(FOnScanToken) and (oeHighlight in Options) then
      begin
        Canvas.FillRect(R0); 
        Canvas.Brush.BrushStyle := bsClear; 
        P := MakePoint(0, i); 
        while P.X < LeftCol + ColumnsVisiblePartial do
        begin
          L := OnScanToken(Control, P, Attrs); 
          MPSTART := P; 
          MPend := P; 
          MPend.X := P.X + L; 
          if L <= 0 then L := Length(Lines[i]) - P.X; 
          if L <= 0 then break; 
          if P.X + L >= LeftCol then
          begin
            Canvas.Font.FontStyle := Attrs.fontstyle;

            while L > 0 do
            begin
              if (FCoordinatMouse.Y = MPSTART.Y) and (FCoordinatMouse.X >= MPSTART.X) and
                 (FCoordinatMouse.X < MPend.X) and (fsUnderline in Attrs.fontstyle) then 
                Canvas.Font.Color := _prop_ColorUnderLine
              else   
                Canvas.Font.Color := Attrs.fontcolor; 
              Canvas.TextOut(R0.Left + (P.X - LeftCol)*CharWidth, R0.Top, Copy(Lines[i], P.X + 1, 1)); 
              inc(P.X); 
              dec(L); 
            end; 
          end
          else
            P.X := P.X + L; 
        end; 
        Canvas.Brush.BrushStyle := bsSolid; 
        if FRightMargin then
        begin
          x := (RightMarginchars - LeftCol)*CharWidth; 
          if Length(TrimRight(Lines[i])) > RightMarginchars then
          begin
            Canvas.Pen.Color := RightMargincolor; 
            Canvas.MoveTo(x, R0.Top); 
            Canvas.LineTo(x - 2, R0.Top + LineHeight div 3); 
            Canvas.LineTo(x + 2, R0.Top + LineHeight * 2 div 3); 
            Canvas.LineTo(x, R0.Bottom); 
          end
          else
          begin
            Canvas.Brush.Color := RightMargincolor; 
            Canvas.FillRect(MakeRect(x, R0.Top, x + 1, R0.Bottom)); 
            Canvas.Brush.Color := Control.Color; 
          end; 
        end; 
        BitBlt(DC, R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top, Canvas.Handle, 0, 0, SRCCOPY); 
      end
      else
      begin
        Control.Canvas.Brush.Color := Control.Color; 
        Control.Canvas.TextRect(R, 0, R.Top, Copyend(Lines[i], LeftCol + 1)); 
        if FRightMargin then
        begin
          x := (RightMarginchars - LeftCol)*CharWidth; 
          if Length(TrimRight(Lines[i])) > RightMarginchars then
          begin
            Control.Canvas.Pen.Color := RightMargincolor; 
            Control.Canvas.MoveTo(x, R.Top); 
            Control.Canvas.LineTo(x - 2, R.Top + LineHeight div 3); 
            Control.Canvas.LineTo(x + 2, R.Top + LineHeight * 2 div 3); 
            Control.Canvas.LineTo(x, R.Bottom); 
          end
          else
            Control.Canvas.Brush.Color := RightMargincolor; 
          Control.Canvas.FillRect(MakeRect(x, R.Top, x + 1, R.Bottom)); 
          Control.Canvas.Brush.Color := Control.Color; 
        end; 
      end; 
//      Gdiflush; 
    end; 
    y := y + LineHeight;
  end; 

  if y < CR.Bottom then // стереть остаток не занятый строками
  begin
    Control.Canvas.Brush.Color := Control.Color; 
    if FRightMargin then
    begin
      x := (RightMarginchars - LeftCol)*CharWidth; 
      if x < CR.Right then
      begin
        R := MakeRect(0, y, x, CR.Bottom); 
        Control.Canvas.FillRect(R); 
        Control.Canvas.Brush.Color := RightMargincolor; 
        R.Left := x; 
        R.Right := x + 1; 
        Control.Canvas.FillRect(R); 
        Control.Canvas.Brush.Color := Control.Color; 
        R.Left := x + 1; 
        R.Right := CR.Right; 
        Control.Canvas.FillRect(R); 
      end
      else 
        Control.Canvas.FillRect(MakeRect(0, y, CR.Right, CR.Bottom)); 
    end
    else 
      Control.Canvas.FillRect(MakeRect(0, y, CR.Right, CR.Bottom)); 
  end; 
end; 

procedure THIHiLightMemo.DoScroll; 
begin
  case Cmd of
    SC_HSCROLL:
      begin 
        case loWord(wParam) of
          SB_LEFT, SB_LINELEFT:
            LeftCol := LeftCol - 1; 
          SB_RIGHT, SB_LINERIGHT:
            LeftCol := LeftCol + 1; 
          SB_PAGELEFT:
            LeftCol := LeftCol - Control.ClientWidth div CharWidth; 
          SB_PAGERIGHT:
            LeftCol := LeftCol + Control.ClientWidth div CharWidth; 
          SB_THUMBTRACK:
            LeftCol := HiWord(wParam);
        end;
        _hi_onEvent(_event_onHScroll);
      end; 
    SC_VSCROLL:
      begin 
        case loWord(wParam) of
          SB_LEFT, SB_LINELEFT:
            TopLine := TopLine - 1; 
          SB_RIGHT, SB_LINERIGHT:
            TopLine := TopLine + 1; 
          SB_PAGELEFT:
            TopLine := TopLine - LinesPerPage; 
          SB_PAGERIGHT:
            TopLine := TopLine + LinesPerPage; 
          SB_THUMBTRACK:
            TopLine := HiWord(wParam); 
        end;
        _hi_onEvent(_event_onVScroll);
      end;   
  end; 
end; 

procedure THIHiLightMemo.DoUndoRedo; 
var
  L1, L2: string; 
  x, y:   integer; 
begin
  // Задача: инвертировать изменения из списка List1, 
  // сохранить обратные изменения в списке List2
//_debug(List1.text);
  FUndoingRedoing := true; 
  Assert(List1.Last[1] = 'E'); 
  List2.Add('B' + Copyend(List1.Last, 2)); 
  List1.Delete(List1.Count - 1); 
  while true do
  begin
    L1 := List1.Last; 
    List1.Delete(List1.Count - 1); 
    case L1[1] of
      'A': // было: добавление строки в конец, обратная: удаление последней строки
        begin
          L2 := 'D' + Int2Str(Count - 1) + '=' + FLines.Last; 
          FLines.Delete(Count - 1); 
        end; 
      'D': // было: удаление строки, обратная: вставка строки
        begin
          Delete(L1, 1, 1); 
          y := Str2Int(L1); 
          FParse(L1, '='); 
          L2 := 'I' + Int2Str(y); 
          InsertLine(y, L1, false); 
        end; 
      'I': // было: вставка строки, обратная: удаление строки
        begin
          Delete(L1, 1, 1); 
          y := Str2Int(L1); 
          L2 := 'D' + Int2Str(y) + '=' + Lines[y]; 
          DeleteLine(y, false); 
        end; 
      'R': // было: изменение строки
        begin
          Delete(L1, 1, 1); 
          y := Str2Int(L1); 
          FParse(L1, '='); 
          L2 := 'R' + Int2Str(y) + '=' + Lines[y]; 
          Lines[y] := L1; 
        end; 
      'B': // дошли до начала группы изменений
        begin
          L2 := 'E' + Copyend(L1, 2); 
          Delete(L1, 1, 1); 
          x := Str2Int(L1);
          FParse(L1, ':');
          y := Str2Int(L1); 
          // вернём каретку в позицию до начала блока изменений
          Caret := MakePoint(x, y); 
          SetSel(Caret, Caret, Caret); 
          CaretToView; 
        end; 
    end; 
    List2.Add(L2);
    if L2[1] = 'E' then break; 
  end; 
  FUndoingRedoing := false; 
  AdjustHScroll; 
  AdjustVScroll; 
  // По окончании, вызвать OnChange: 
  if Assigned(Control.OnChange) then
    Control.OnChange(Control); 
end; 

procedure THIHiLightMemo.FastFillDictionary; 
type
  TByteArray = array[0..100000] of Byte; 
  PByteArray = ^TByteArray; 
var
  i:             integer; 
  HashTable:     PByteArray; 
  S, From:       PChar; 
  TempMemStream: PStream; 
  ChkSum:        Cardinal; 
  EOL:           Char; 
  DicAsTxt:      string; 
begin
  FDictionary.Clear; 
  HashTable := AllocMem(65536); // место для 512К 1 - битных флажков "присутствия"
  TempMemStream := NewMemoryStream; // сюда пишем добавляемые слова
  EOL := #13; 
TRY
  for i := 0 to FLines.Count - 1 do
  begin
    S := FLines.ItemPtrs[i]; 
    while S^ <> #0 do
    begin
      if S^ in ['A'..'Z', 'a'..'z', 'А'..'Я', 'а'..'я', 'Ё', 'ё', '_', '0'..'9'] then
      begin
        From := S; 
        ChkSum := Byte(From^); 
        inc(S); 
        while S^ in ['A'..'Z', 'a'..'z', 'А'..'Я', 'а'..'я', 'Ё', 'ё', '_', '0'..'9'] do
        begin
          ChkSum := ((ChkSum shl 1) or (ChkSum shr 18) and 1) xor Byte(Upper[S^]); 
          inc(S); 
        end; 
        if Cardinal(S) - Cardinal(From) > Cardinal(AutoCompleteMinWordLength) then
        begin
          ChkSum := ChkSum and $7FFFF; 
          if HashTable[ChkSum shr 3] and (1 shl (ChkSum and 7)) = 0 then
          begin
            HashTable[ChkSum shr 3] := HashTable[ChkSum shr 3] or (1 shl (ChkSum and 7)); 
            TempMemStream.Write(From^, Cardinal(S) - Cardinal(From)); 
            TempMemStream.Write(EOL, 1); 
          end; 
        end; 
      end
      else
        inc(S); 
    end; 
  end; 
  if TempMemStream.Position > 0 then
  begin
    Setstring(DicAsTxt, PChar(TempMemStream.Memory), TempMemStream.Position); 
    FDictionary.Text := DicAsTxt; 
    FDictionary.Sort(false); 
  end; 
FINALLY
  TempMemStream.Free; 
  FreeMem(HashTable); 
END; 
end; 

function THIHiLightMemo.FindNextTabPos; 
var
  P, P1, P2: TPoint; 
begin
  P := FromPos; 
  P1 := P; 
  Result := P.X; 
  while (P.Y > 0) or (P.X > 0) do
  begin
    P2 := P; 
    P := FindPrevWord(P2, false); 
    if (P.X = P2.X) and (P.Y = P2.Y) then
    begin
      Result := P.X; 
      break; 
    end
    else if (P.X >= FromPos.X) and ((Result = FromPos.X) or (P.Y = P1.Y)) then
    begin
      Result := P.X; 
      P1 := P; 
    end
    else if (P.Y < P1.Y) or (P.X <= FromPos.X) then break; 
  end; 
end; 

function THIHiLightMemo.FindNextWord; 
var
  S:    string; 
  i, y: integer; 
begin
  y := FromPos.Y; 
  i := FromPos.X; 
  while true do
  begin
    S := Lines[y]; 
    while i < Length(S) - 1 do
    begin
      inc(i); 
      if LookForLettersDigits and IsLetterDigit(S[i + 1]) or
         not LookForLettersDigits and (S[i + 1] > ' ') then // найдено следующее слово
      begin
        Result := MakePoint(i, y); 
        exit; 
      end; 
    end; 
    // дошли до конца строки, слово еще не найдено
    if y = Count - 1 then // это последняя строка
      break; 
    i := - 1; 
    inc(y); 
  end; 
  Result := MakePoint(i, y); 
end; 

function THIHiLightMemo.FindPrevTabPos; 
var
  P, P2: TPoint; 
begin
  P := FromPos; 
  Result := P.X; 
  while (P.Y > 0) or (P.X > 0) do
  begin
    P2 := P; 
    P := FindPrevWord(P, false); 
    if (P.X = P2.X) and (P.Y = P2.Y) or (P.X < FromPos.X) then
    begin
      Result := P.X; 
      break; 
     end; 
  end; 
end; 

function THIHiLightMemo.FindPrevWord; 
var
  S:    string; 
  i, y: integer; 
begin
  Result := FromPos; 
  y := FromPos.Y; 
  i := FromPos.X; 
  while true do
  begin
    S := Lines[y]; 
    if i = - 1 then
      i := Length(S) + 1
    else
      dec(i); 
    while i > 0 do
    begin
      dec(i); 
      if (LookForLettersDigits and
          not IsLetterDigit((Copy(S, i + 1, 1) + ' ')[1]) or
          not LookForLettersDigits and (Copy(S, i + 1, 1) <= ' '))
          and (i + 2 <= Length(S)) and (LookForLettersDigits and
          IsLetterDigit((Copy(S, i + 2, 1) + ' ')[1]) or
          not LookForLettersDigits and (Copy(S, i + 2, 1) > ' ')) then // найдено предыдующее слово
      begin
        Result := MakePoint(i + 1, y); 
        exit; 
      end
      else if (i = 0) and (Length(S) > 0) and IsLetterDigit(S[1]) then
      begin
        Result := MakePoint(0, y); 
        exit; 
      end; 
    end; 
    // дошли до начала строки, слово еще не найдено
    if y = 0 then // это первая строка
      exit; 
    i := - 1; 
    dec(y); 
  end; 
  Result := MakePoint(i, y); 
end; 

function THIHiLightMemo.FindReplace; 
var
  P: TPoint; 
  L: string; 
  i: integer; 

  function CompareSubstr(var i: integer): boolean; 
  var
    j: integer; 
  begin
    Result := false; 
    i := 1; 
    j := 1; 
    while j <= Length(S) do
    begin
      if P.X + i > Length(L) then exit; 
      if not(froSpaces in FindReplaceOptions) and (S[j] = ' ') then
      begin
        inc(j); 
        if not(L[P.X + i] in [#9, ' ']) then exit; 
        while (P.X + i <= Length(L)) and (L[P.X + i] in [#9, ' ']) do inc(i); 
      end
      else if frocase in FindReplaceOptions then
      begin
        if L[P.X + i] <> S[j] then exit; 
        inc(i); 
        inc(j); 
      end
      else
      begin
        if Upper[L[P.X + i]] <> Upper[S[j]] then exit; 
        inc(i); 
        inc(j); 
      end; 
    end; 
    Result := true; 
  end; 

begin
  Result := FromPos; 
  if not(froSpaces in FindReplaceOptions) then
  begin
    while StrReplace(S, #9, ' ') do; 
    while StrReplace(S, '  ', ' ') do; 
  end; 
  P := FromPos; 
  L := Lines[P.Y]; 
  while true do
  begin
    if froBack in FindReplaceOptions then
    begin
      dec(P.X); 
      if P.X < 0 then
      begin
        dec(P.Y); 
        L := Lines[P.Y]; 
        if P.Y < 0 then exit; 
        P.X := Length(L); 
        continue; 
      end; 
    end
    else
    begin
      inc(P.X); 
      if P.X >= Length(L) then
      begin
        P.X := 0; 
        inc(P.Y); 
        if P.Y >= Count then exit; 
        L := Lines[P.Y]; 
      end; 
    end; 
    if CompareSubstr(i) then
    begin
      if froReplace in FindReplaceOptions then
      begin
        SelBegin := P; 
        Selend := MakePoint(P.X + i - 1, P.Y); 
        Selection := ReplaceTo; 
        Selend := Caret; 
      end
      else if SelectFound then
      begin
        SelBegin := P; 
        Selend := MakePoint(P.X + i - 1, P.Y); 
        Caret := Selend; 
      end; 
      if not(froReplace in FindReplaceOptions) or not(froAll in FindReplaceOptions) then break; 
    end; 
  end; 
  CaretToView; 
  Result := P; 
end; 

procedure THIHiLightMemo.FixBookmarks; 
var
  i: integer; 
begin
  for i := 0 to 9 do
    if (FBookmarks[i].X <> 0) or (FBookmarks[i].Y <> 0) then
    begin
      if (FBookmarks[i].Y = FromPos.Y) and (FBookmarks[i].X >= FromPos.X) then
        inc(FBookmarks[i].X, deltaX); 
      if (FBookmarks[i].Y > FromPos.Y) then
        inc(FBookmarks[i].Y, deltaY); 
    end; 
end; 

function THIHiLightMemo.GetBookMark; 
begin
  Result := FBookmarks[Idx]; 
end; 

function THIHiLightMemo.GetCount; 
begin
  Result := FLines.Count; 
end; 

function THIHiLightMemo.GetLines; 
var
  i, j: integer; 
begin
  Result := FLines.Items[Idx]; 
  // все символы табуляции превращаются в необходимое количество пробелов: 
  i := 0; 
  while i < Length(Result) do
  begin
    if Result[i + 1] = #9 then
    begin
      j := ((i + 8) div 8) * 8; 
      Result := Copy(Result, 1, i) + StrRepeat(' ', j - i) + Copyend(Result, i + 2); 
    end; 
    inc(i); 
  end; 
  if not(oeKeepTrailingSpaces in Options) then
     Result := TrimRight(Result); 
end; 

function THIHiLightMemo.GetSelection; 
var   i: integer; 
      S: string; 
begin
  Result := ''; 
  // Собрать все строки и фрагменты строк выделенной области
  for i := SelBegin.Y to Selend.Y do
  begin
    S := Lines[i]; 
    if i = Selend.Y then
      S := Copy(S, 1, Selend.X); 
    if i = SelBegin.Y then
      S := Copyend(S, SelBegin.X + 1); 
    if i > SelBegin.Y then
      Result := Result + #13#10; 
    Result := Result + S; 
  end; 
end; 

function THIHiLightMemo.GetText; 
begin
  Result := FLines.Text; 
end; 

function THIHiLightMemo.GetDrawRightMargin; 
begin
  Result := FRightMargin; 
end; 

procedure THIHiLightMemo.Indent; 
var
  y, i, k: integer; 
  S:       string; 
begin
  Changing; 
  for y := FSelBegin.y to FSelEnd.y do
  begin
    if (FSelEnd.y > FSelBegin.y) and (FSelEnd.y = y) and (FSelEnd.x = 0) then break; 
    S := Lines[y]; 
    if delta > 0 then
    begin
      S := StrRepeat(' ', delta) + S; 
      FixBookmarks(MakePoint(0, y), delta, 0); 
    end
    else if delta < 0 then
    begin
      k := 0; 
      for i := 1 to Length(S) do
        if S[i] > ' ' then
          break
        else
          inc(k); 
      if - delta < k then k := - delta; 
      if k > 0 then
      begin
        Delete(S, 1, k); 
        FixBookmarks(MakePoint(0, y), - k, 0); 
      end; 
    end
    else
      break; 
    Lines[y] := S; 
  end; 
  if (FSelEnd.x = 0) and (FSelEnd.y > FSelBegin.y) then
    SetSel(MakePoint(FSelBegin.x + delta, FSelBegin.y), 
           FSelEnd,
           MakePoint(FSelBegin.x + delta, FSelBegin.y))
  else
    SetSel(MakePoint(FSelBegin.x + delta, FSelBegin.y), 
           MakePoint(FSelEnd.x + delta, FSelEnd.y), 
           MakePoint(FSelFrom.x + delta, FSelBegin.y)); 
  Changed; 
  CaretToView; 
end; 

procedure THIHiLightMemo.InsertLine; 
var
  R: TRect;
  ss, st: string; 
begin
  Changing; 
  while Count < y do
  begin
    FLines.Add(''); 
    if not FUndoingRedoing then
      FUndoList.Add('A'); 
     UseScroll := false; 
  end;
  ss := s;
  If LFCR then ss := ss + #13#10;;
  FSelBegin := MakePoint(0, y); 
   
  Replace(ss, #10, '');
  while ss <> '' do
  begin
    st := FParse(ss, #13);

    FLines.Insert(y, st);
    FixBookmarks(MakePoint(0, y), 0, 1); 
    if not FUndoingRedoing then
      FUndoList.Add('I' + Int2Str(y)); 
    if UseScroll and (y >= TopLine) and (y < TopLine + LinesPerPage) then
    begin
      R := MakeRect(0, (y - TopLine)*LineHeight, Control.ClientWidth, Control.ClientHeight); 
      ScrollWindowEx(Control.Handle, 0, LineHeight, @ R, nil, 0, nil, SW_INVALIDATE); 
    end
    else
    begin
      R := MakeRect(0, (y - TopLine)*LineHeight, Control.ClientWidth, Control.ClientHeight); 
      InvalidateRect(Control.Handle, @ R, true); 
    end;
    inc(y);
  end; 
  FSelEnd := MakePoint(0, y);
  Indent(- _prop_Indent);
  Indent(_prop_Indent);
  FSelEnd := FSelBegin;
  if LFCR then
    Caret := MakePoint(Caret.X + _prop_Indent, FSelBegin.Y)
  else    
    Caret := MakePoint(_prop_Indent, FSelBegin.Y);
  Changed;   
end; 

procedure THIHiLightMemo.InvalidateLine; 
var
  R: TRect; 
begin
  if y < TopLine then exit; 
  if y > TopLine + LinesVisiblePartial then exit; 
  R := MakeRect(0, (y - TopLine) * LineHeight, Control.ClientWidth, (y + 1 - TopLine)*LineHeight); 
  InvalidateRect(Control.Handle, @ R, true); 
end; 

procedure THIHiLightMemo.InvalidateSelection; 
var
  y: integer; 
  R: TRect; 
begin
  // просмотреть все видимые строки, и те, из них, которые содержат
  // части выделения, пометить как испорченные - для перерисовки.
  for y := Max(TopLine, SelBegin.Y) to Min(TopLine + LinesVisiblePartial - 1, Selend.Y) do
  begin
    R := MakeRect(0, (y - TopLine) * LineHeight, Control.ClientWidth, Control.ClientHeight); 
    InvalidateRect(Control.Handle, @ R, true); 
  end; 
end; 

function THIHiLightMemo.LineHeight; 
begin
  if FLineHeight = 0 then
  begin
    FBitmap.Canvas.Font.Assign(Control.Font); 
    FLineHeight := FBitmap.Canvas.TextHeight('A/_'); 
  end; 
  Result := FLineHeight; 
  if Result = 0 then
    Result := 16; 
end; 

function THIHiLightMemo.LinesPerPage; 
begin
  Result := Control.ClientHeight div LineHeight; 
end; 

function THIHiLightMemo.LinesVisiblePartial; 
begin
  Result := Control.ClientHeight div LineHeight; 
  if Result * LineHeight < Control.ClientHeight then
    inc(Result); 
end; 

function THIHiLightMemo.MaxLineWidthOnPage; 
var
  i: integer; 
begin
  Result := 0; 
  for i := TopLine to TopLine + (Control.Height + LineHeight - 1) div LineHeight - 1 do
  begin
    if i >= Count then break; 
    Result := Max(Result, Length(Lines[i])); 
  end; 
end; 

function THIHiLightMemo.MaxLineWidthInText; 
var
  i: integer; 
begin
  Result := 0; 
  for i := 0 to TopLine + (Control.Height + LineHeight - 1) div LineHeight - 1 do
  begin
    if i >= Count then break; 
    Result := Max(Result, Length(Lines[i])); 
  end; 
end; 

procedure THIHiLightMemo.Redo; 
begin
  if not CanRedo then exit; 
  DoUndoRedo(FRedoList, FUndoList); 
end; 

function THIHiLightMemo.SelectionAvailable; 
begin
  Result := ((SelBegin.X <> Selend.X) or (SelBegin.Y <> Selend.Y)) and
            ((SelBegin.Y < Count - 1) or
            (SelBegin.Y = Count - 1) and
            (SelBegin.X < Length(FLines.Last))); 
end; 

procedure THIHiLightMemo.SelectWordUnderCursor; 
var
  WordStart, Wordend: TPoint; 
  W:                  string; 
begin
  W := WordAtPos(Caret); 
  if W = '' then exit; 
  WordStart := WordAtPosStart(Caret); 
  Wordend := WordStart; 
  inc(Wordend.X, Length(W)); 
  SetSel(WordStart, Wordend, WordStart); 
  Caret := Wordend; 
  CaretToView; 
end; 

procedure THIHiLightMemo.SetBookmark; 
begin
  FBookmarks[Idx] := Value; 
end; 

procedure THIHiLightMemo.SetCaret; 
begin
  if (FCaret.Y < Count) and (FCaret.Y >= 0) and (FCaret.Y <> Value.Y) and
      not FnotAdd2Dictionary1time then
    AutoAdd2Dictionary(FLines.ItemPtrs[FCaret.Y]); 
  if (FCaret.x <> Value.x) or (FCaret.y <> Value.y) then
    AutoCompletionHide; 
  FCaret := Value; 
  if FCaret.Y < 0 then FCaret.Y := 0; 
  if FCaret.X < 0 then FCaret.X := 0;      
  if (FCaret.Y >= TopLine) and
     (FCaret.Y < TopLine + LinesVisiblePartial) and
     (FCaret.X >= LeftCol) and
     (FCaret.X <= LeftCol + ColumnsVisiblePartial) and
     (GetFocus = Control.Handle) then begin
     if oeOverwrite in Options then
        CreateCaret(Control.Handle, 0, CharWidth, LineHeight)
     else
        CreateCaret(Control.Handle, 0, 1, LineHeight); 
     SetCaretPos((FCaret.X - LeftCol) * CharWidth, (FCaret.Y - TopLine) * LineHeight); 
     ShowCaret(Control.Handle); 
  end
  else
    Hidecaret(Control.Handle); 
  AdjustHScroll; 
end; 

procedure THIHiLightMemo.SetLeftCol; 
var
  WasLeftCol: integer; 
begin
  WasLeftCol := FLeftCol; 
  if WasLeftCol <> Value then
  begin
    FLeftCol := Value; 
    if FLeftCol < 0 then
      FLeftCol := 0; 
    if FLeftCol >= MaxLineWidth then
      FLeftCol := MaxLineWidth; 
    if FLeftCol < 0 then
      FLeftCol := 0; 
    ScrollWindowEx(Control.Handle, ( - FLeftCol + WasLeftCol)*CharWidth, 0, nil, nil, 0, nil, SW_INVALIDATE); 
    Caret := Caret; 
  end; 
  // установить горизонтальный скроллер в правильное положение: 
  AdjustHScroll; 
end; 

procedure THIHiLightMemo.SetLines; 
var
  U: string; 
begin
  Changing; 
  while FLines.Count <= Idx do
  begin
    FLines.Add(''); 
    if not FUndoingRedoing then
      FUndoList.Add('A'); 
  end; 
  if FLines.Items[Idx] <> Value then
  begin
    if not FUndoingRedoing then
    begin
      U := 'R' + Int2Str(Idx) + '='; 
      if Copy(FUndoList.Last, 1, Length(U)) <> U then
        FUndoList.Add(U + FLines.Items[Idx]); 
    end; 
    FLines.Items[Idx] := Value; 
  end; 
  InvalidateLine(Idx); 
  Changed; 
end; 

procedure THIHiLightMemo.SetOnScanToken; 
begin
  FOnScanToken := Value; 
  InvalidateRect(Control.Handle, nil, false); 
end; 

procedure THIHiLightMemo.SetSel; 
begin
  if (Pos1.Y > Pos2.Y) or (Pos1.Y = Pos2.Y) and (Pos1.X > Pos2.X) then
  begin
    SelBegin := Pos2; 
    Selend := Pos1; 
  end
  else
  begin
    SelBegin := Pos1; 
    Selend := Pos2; 
  end; 
  SelFrom := PosFrom; 
end; 

procedure THIHiLightMemo.SetSelBegin; 
begin
  if (FSelBegin.X = Value.X) and (FSelBegin.Y = Value.Y) then exit; 
  InvalidateSelection; // выделение могло измениться, все выделение обновится
  FSelBegin := Value; 
  if FSelBegin.Y < 0 then FSelBegin.Y := 0; 
  if FSelBegin.X < 0 then FSelBegin.X := 0; 
  if (FSelEnd.Y < FSelBegin.Y) or (FSelEnd.Y = FSelBegin.Y) and (FSelEnd.X < FSelBegin.X) then
    FSelEnd := FSelBegin; 
  InvalidateSelection; // обновить новое выделение
  if Assigned(Control.OnSelChange) then
    Control.OnSelChange(Control); 
end; 

procedure THIHiLightMemo.SetSelection; 
var
  S1, L: string; 
  SL: PStrList; 
  y: integer; 
begin
  // удалить выделение, вставить новое значение взамен, все записать в откат
  Changing; 
  DeleteSelection; 
  if Value <> '' then
  begin
    SL := NewStrList; 
  TRY
    SL.Text := Value; 
    if (Value <> '') and (Value[Length(Value)] in [#13, #10]) then
      SL.Add(''); 
    L := Lines[Caret.Y]; 
    if Length(L) < Caret.X then
      L := L + StrRepeat(' ', Caret.X - Length(L)); 
    S1 := ''; // будем вставлять в последнюю строку
    if SL.Count = 1 then
    begin
      L := Copy(L, 1, Caret.X) + SL.Items[0] + Copyend(L, Caret.X + 1); 
      FCaret.x := FCaret.x + Length(SL.Items[0]); 
      Lines[Caret.Y] := L; 
    end
    else
    begin
      S1 := Copyend(L, Caret.X + 1);
      L := Copy(L, 1, Caret.X) + SL.Items[0]; 
      //S1 := SL.Items[Count - 1]; 
      Lines[Caret.Y] := L;
      FixBookmarks(Caret, Length(SL.Items[0]) - Length(S1), SL.Count - 1); 
      for y := 1 to SL.Count - 2 do
      begin
        L := SL.Items[y]; 
        //InsertLine(Caret.Y + y, L, false); 
        InsertLine(Caret.Y + 1, L, false);
      end; 
      //y := SL.Count - 1; 
      L := S1; 
      //InsertLine(Caret.Y + y, SL.Last + L, false); 
      InsertLine(Caret.Y + 1, SL.Last + L, false);
      //Caret := MakePoint(Length(SL.Last), Caret.y + y);
      Caret := MakePoint(Length(SL.Last), Caret.y); 
    end; 
  FINALLY
    SL.Free; 
  END; 
  end; 
  AdjustHScroll; 
  AdjustVScroll; 
  SetSel(Caret, Caret, Caret); 
  CaretToView; 
  Changed; 
end; 

procedure THIHiLightMemo.SetSelEnd; 
begin
  if (FSelEnd.X = Value.X) and (FSelEnd.Y = Value.Y) then exit; 
  InvalidateSelection; // выделение могло измениться, все выделение обновится
  FSelEnd := Value; 
  if FSelEnd.Y < 0 then FSelEnd.Y := 0; 
  if FSelEnd.X < 0 then FSelEnd.X := 0;   
  if (FSelBegin.Y > FSelEnd.Y) or (FSelBegin.Y = FSelEnd.Y) and (FSelBegin.X > FSelEnd.X) then
    FSelBegin := FSelEnd; 
  InvalidateSelection; // обновить новое выделение
  if Assigned(Control.OnSelChange) then
    Control.OnSelChange(Control); 
end; 

procedure THIHiLightMemo.SetText; 
begin
  FLines.Text := Value; 
  TopLine := TopLine; 
  InvalidateRect(Control.Handle, nil, false); 
  AutoCompletionHide; 
  FastFillDictionary; 
end; 

procedure THIHiLightMemo.SetDrawRightMargin; 
begin
  FRightMargin := Value; 
end; 

procedure THIHiLightMemo.SetTopLine; 
var
  WasTopLine: integer; 
begin
  WasTopLine := FTopLine; 
  FTopLine := Value; 
  if FTopLine < 0 then
    FTopLine := 0; 
  if FTopLine >= Count then 
    FTopLine := Count; 
  if Count = 0 then exit; 
  if FTopLine + LinesPerPage >= Count then
    FTopLine := Count - LinesPerPage; 
  if FTopLine < 0 then
    FTopLine := 0; 
  if WasTopLine <> FTopLine then
  begin
    ScrollWindowEx(Control.Handle, 0, (WasTopLine - FTopLine)*LineHeight, nil, nil, 0, nil, SW_INVALIDATE); 
    Caret := Caret; 
  end; 
  // установить вертикальный скроллер в правильное положение: 
  AdjustVScroll; 
end; 

procedure THIHiLightMemo.Undo; 
begin
  if not CanUndo then exit; 
  DoUndoRedo(FUndoList, FRedoList); 
end; 

function THIHiLightMemo.WordAtPos; 
var
  FromPos: TPoint; 
  S:       string; 
  i:       integer; 
begin
  Result := ''; 
  if (AtPos.Y < 0) or (AtPos.X < 0) then exit;  
  if AtPos.Y >= Count then exit; 
  FromPos := WordAtPosStart(AtPos); 
  S := Lines[FromPos.Y]; 
  i := FromPos.X; 
  while true do
  begin
    inc(i); 
    if i >= Length(S) then break; 
    if not IsLetterDigit(S[i + 1]) then break; 
  end; 
  Result := Trim(Copy(S, FromPos.X + 1, i - FromPos.X)); 
end; 

function THIHiLightMemo.WordAtPosStart; 
var
  S: string; 
  i: integer; 
begin
  Result := AtPos; 
  if (AtPos.Y < 0) or (AtPos.X < 0) then exit; 
  if AtPos.Y >= Count then exit; 
  S := Lines[AtPos.Y]; 
  if (AtPos.X < Length(S)) and IsLetterDigit(S[AtPos.X + 1]) then
    i := AtPos.X
  else if (AtPos.X - 1 > 0) and (AtPos.X - 1 < Length(S)) and IsLetterDigit(S[AtPos.X]) then
    i := AtPos.X - 1
  else
    exit; 
  while i > - 1 do
  begin
    dec(i); 
    if (i < 0) or not IsLetterDigit(S[i + 1]) then
    begin
      Result.X := i + 1; 
      break; 
    end; 
  end; 
end; 

procedure THIHiLightMemo._work_doLoadAutoCompl; 
var
  fn: string; 
begin
  if not _prop_AutoComplete then exit; 
  fn := ReadString(_Data, _data_FileNameComplete, _prop_FileNameComplete); 
  if FileExists(fn) then
    FDictionary.LoadFromFile(fn); 
  Focused_CaretToView; 
end; 

procedure THIHiLightMemo._work_doSaveAutoCompl; 
var
  fn: string; 
begin
  if not _prop_AutoComplete then exit; 
  fn := ReadString(_Data, _data_FileNameComplete, _prop_FileNameComplete); 
  FDictionary.SaveToFile(fn); 
  Focused_CaretToView; 
end;      

procedure THIHiLightMemo._work_doLoadHiLight; 
var
  fn: string; 
begin
  if not _prop_Hilight then exit; 
  fn := ReadString(_Data, _data_FileNameHiLight, _prop_FileNameHiLight); 
  if FileExists(fn) then
    HS.LoadFromFile(fn); 
  Focused_CaretToView; 
end; 

procedure THIHiLightMemo._work_doSaveHiLight; 
var
  fn: string; 
begin
  if not _prop_Hilight then exit; 
  fn := ReadString(_Data, _data_FileNameHiLight, _prop_FileNameHiLight); 
  HS.SaveToFile(fn); 
  Focused_CaretToView;  
end;      


function CheckKeyMask(State: byte; Code: byte): boolean; 
begin
  case State of
    1: Result := GetKeyState(Code) < 0; 
  else
    Result := true; 
  end; 
end; 

initialization
  InitUpper; 

end.