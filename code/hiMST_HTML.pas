unit hiMST_HTML;

interface
     
uses Windows, Kol, Share, Debug, hiMTStrTbl;

const
  LFCR = #13#10;
  ColorNames: array [0..15] of String = (
    'black','maroon','green','olive','navy','purple','teal','gray',
    'silver','red','lime','yellow','blue','fuchsia','aqua','white' );
  AlignText: array [0..2] of String = (
    'left','right','center' );    
  FontStyle: array [0..1] of String = (  
    'normal', 'italic' );
  FontWeight: array [0..1] of String = (
    'normal', 'bold' );
        
type
  THIMST_HTML = class(TDebug)
  private
    HTMLTab: string;

    FCodePage          : string;
    FTitleText         : string;
    FTitleBorderWeight : integer;
    FTitleBorderColor  : TColor;
    FTitleBackColor    : TColor;
    FTitleTextAlign    : byte;
    FTitleFont         : TFontRec;
    FTitlePadLeft      : integer;
    FTitlePadTop       : integer;
    FTitlePadRight     : integer;
    FTitlePadBottom    : integer;

    FTabBorderWeight   : integer;
    FTabBorderColor    : TColor;
    FHeadBorderWeight  : integer;
    FHeadBorderColor   : TColor;
    FHeadBackColor     : TColor;
    FHeadTextAlign     : byte;
    FHeadFont          : TFontRec;
    FHeadPadLeft      : integer;
    FHeadPadTop       : integer;
    FHeadPadRight     : integer;
    FHeadPadBottom    : integer;

    FCellsBorderWeight : integer;
    FCellsBorderColor  : TColor;
    FCellsColor        : boolean;

    FNoteText          : string;
    FNoteBorderWeight  : integer;
    FNoteBorderColor   : TColor;
    FNoteBackColor     : TColor;
    FNoteTextAlign     : byte;
    FNoteFont          : TFontRec;
    FNotePadLeft       : integer;
    FNotePadTop        : integer;
    FNotePadRight      : integer;
    FNotePadBottom     : integer;

    function TitleFormat: string;
    function NoteFormat: string;    
  public

    _prop_MSTControl: IMSTControl;

    _event_onTabToHTML: THI_Event;

    property _prop_TitleText         : string   write FTitleText;
    property _prop_TitleBorderWeight : integer  write FTitleBorderWeight; 
    property _prop_TitleBorderColor  : TColor   write FTitleBorderColor; 
    property _prop_TitleBackColor    : TColor   write FTitleBackColor;
    property _prop_TitleTextAlign    : byte     write FTitleTextAlign;
    property _prop_TitleFont         : TFontRec write FTitleFont;
    property _prop_TitlePadLeft      : integer  write FTitlePadLeft;
    property _prop_TitlePadTop       : integer  write FTitlePadTop;
    property _prop_TitlePadRight     : integer  write FTitlePadRight;
    property _prop_TitlePadBottom    : integer  write FTitlePadBottom;
    
    property _prop_TabBorderWeight   : integer  write FTabBorderWeight;
    property _prop_TabBorderColor    : TColor   write FTabBorderColor;
    property _prop_HeadBorderWeight  : integer  write FHeadBorderWeight;
    property _prop_HeadBorderColor   : TColor   write FHeadBorderColor;
    property _prop_HeadBackColor     : TColor   write FHeadBackColor;
    property _prop_HeadTextAlign     : byte     write FHeadTextAlign;
    property _prop_HeadFont          : TFontRec write FHeadFont;
    property _prop_HeadPadLeft       : integer  write FHeadPadLeft;
    property _prop_HeadPadTop        : integer  write FHeadPadTop;
    property _prop_HeadPadRight      : integer  write FHeadPadRight;
    property _prop_HeadPadBottom     : integer  write FHeadPadBottom;
        
    property _prop_CellsBorderWeight : integer  write FCellsBorderWeight;
    property _prop_CellsBorderColor  : TColor   write FCellsBorderColor;
    property _prop_CellsColor        : boolean  write FCellsColor;    

    property _prop_NoteText          : string   write FNoteText;
    property _prop_NoteBorderWeight  : integer  write FNoteBorderWeight; 
    property _prop_NoteBorderColor   : TColor   write FNoteBorderColor; 
    property _prop_NoteBackColor     : TColor   write FNoteBackColor;
    property _prop_NoteTextAlign     : byte     write FNoteTextAlign;
    property _prop_NoteFont          : TFontRec write FNoteFont;
    property _prop_NotePadLeft       : integer  write FNotePadLeft;
    property _prop_NotePadTop        : integer  write FNotePadTop;
    property _prop_NotePadRight      : integer  write FNotePadRight;
    property _prop_NotePadBottom     : integer  write FNotePadBottom;

    property _prop_CodePage          : string   write FCodePage;

    procedure _work_doTabToHTML(var _Data: TData; Index: word);
    procedure _var_HTMLTab(var _Data: TData; Index: word);


    procedure _work_doTitleText(var _Data: TData; Index: word);
    procedure _work_doTitleBorderWeight(var _Data: TData; Index: word);
    procedure _work_doTitleBorderColor(var _Data: TData; Index: word);
    procedure _work_doTitleBackColor(var _Data: TData; Index: word);
    procedure _work_doTitleTextAlign(var _Data: TData; Index: word);
    procedure _work_doTitleFont(var _Data: TData; Index: word);
    procedure _work_doTitlePadLeft(var _Data: TData; Index: word);
    procedure _work_doTitlePadTop(var _Data: TData; Index: word);
    procedure _work_doTitlePadRight(var _Data: TData; Index: word);
    procedure _work_doTitlePadBottom(var _Data: TData; Index: word);

    procedure _work_doTabBorderWeight(var _Data: TData; Index: word);
    procedure _work_doTabBorderColor(var _Data: TData; Index: word);
    procedure _work_doHeadBorderWeight(var _Data: TData; Index: word);
    procedure _work_doHeadBorderColor(var _Data: TData; Index: word);
    procedure _work_doHeadBackColor(var _Data: TData; Index: word);
    procedure _work_doHeadTextAlign(var _Data: TData; Index: word);
    procedure _work_doHeadFont(var _Data: TData; Index: word);
    procedure _work_doHeadPadLeft(var _Data: TData; Index: word);
    procedure _work_doHeadPadTop(var _Data: TData; Index: word);
    procedure _work_doHeadPadRight(var _Data: TData; Index: word);
    procedure _work_doHeadPadBottom(var _Data: TData; Index: word);

    procedure _work_doCellsBorderWeight(var _Data: TData; Index: word);
    procedure _work_doCellsBorderColor(var _Data: TData; Index: word);
    procedure _work_doCellsColor(var _Data: TData; Index: word);

    procedure _work_doNoteText(var _Data: TData; Index: word);
    procedure _work_doNoteBorderWeight(var _Data: TData; Index: word);
    procedure _work_doNoteBorderColor(var _Data: TData; Index: word);
    procedure _work_doNoteBackColor(var _Data: TData; Index: word);
    procedure _work_doNoteTextAlign(var _Data: TData; Index: word);
    procedure _work_doNoteFont(var _Data: TData; Index: word);
    procedure _work_doNotePadLeft(var _Data: TData; Index: word);
    procedure _work_doNotePadTop(var _Data: TData; Index: word);
    procedure _work_doNotePadRight(var _Data: TData; Index: word);
    procedure _work_doNotePadBottom(var _Data: TData; Index: word);

    procedure _work_doCodePage(var _Data: TData; Index: word);
  end;

implementation

function RGB2HTML(Color: TColor): string;
var  fFrom: TRGB;
begin
  PColor(@fFrom)^:= Color2RGB(Color);
  Result:= '#' + Int2Hex(fFrom.R, 2) + Int2Hex(fFrom.G, 2) + Int2Hex(fFrom.B, 2);
end;

function IDX2HTML(Index: integer): string;
begin
  Result := ColorNames[Index]; 
end;

function CTRLFontString(sControl: PControl; MSTControl: IMSTControl): string;
var
  fs: TFontStyle;

  function FontSizeString: string;
  var
    r: real;
    sFontSize: integer;    
  begin
    r := ((sControl.Font.FontHeight * -72) - 36) / ScreenDPI;
    sFontSize := Trunc(r);
    if Frac(r) > 0 then
      Inc(sFontSize);
    Result := int2str(sFontSize) + 'pt ';
  end;
    
  function FontStyle: string;
  begin
    if fsItalic in fs then
      Result  := 'italic'
    else
      Result  := 'normal';
  end;

  function FontWeight: string;
  begin
    if fsBold in fs then  
      Result := 'bold'
    else   
      Result := 'normal';
  end;
  
begin
  fs := sControl.Font.FontStyle;
  Result := ' font: ' + FontSizeString + '''' + sControl.Font.FontName + ''', ' + '''MS Sans Serif'';' + LFCR +
            ' color: ' + RGB2HTML({sControl.LVTextColor}MSTControl.textcolor) + ';' + LFCR +
            ' font-style: ' + FontStyle + ';' + LFCR +
            ' font-weight: ' + FontWeight + ';' + LFCR;
end; 

function FontString(Font: TFontRec): string;
begin
  Result := ' font: ' + int2str(Font.Size) + 'pt ''' + Font.Name + ''', ' + '''MS Sans Serif'';' + LFCR +
            ' color: ' + RGB2HTML(Font.Color) + ';' + LFCR + ' font-weight: ';
  if Font.Style and 1 > 0 then
    Result := Result + 'bold'
  else  
    Result := Result + 'normal';
  Result := Result + ';' + LFCR + ' font-style: ';
  if Font.Style and 2 > 0 then
    Result := Result + 'italic'
  else  
    Result := Result + 'normal';
  Result := Result + ';'
end;

function ItemHeight(sControl: PControl): string;
var
 ARect: TRect;
begin
  ARect:= sControl.LVItemRect(0, lvipLabel);
  Result := ' height: ' + int2str(ARect.Bottom - ARect.Top) + 'px;';
end;

function CodePage(sCodePage: string): string;
begin
  if sCodePage <> '' then
    Result := '<meta http-equiv="Content-Type" content="text/html; charset=' + sCodePage + '">' + LFCR
  else
    Result := '';    
end;

function ColorRowString(MSTControl: IMSTControl; sControl: PControl; Row: integer): string;
var
  FData: TData;
  Color, idxcolor, bkcolor: cardinal;  
begin
  Result := '';
  if PData(sControl.LVItemData[Row]) = nil then exit;

  CopyData(@FData, PData(sControl.LVItemData[Row]));

  Color := ToInteger(FData);
  idxcolor:= ($0F000000 and Color) shr 24;
  if $FFFFFF and Color = 0 then
    bkcolor := Color2RGB(MSTControl.textbkcolor)
  else
    bkcolor := $FFFFFF and Color;
  Result := ' style="color: ' + ColorNames[idxcolor] + '; background: ' + RGB2HTML(bkcolor) + '"';
end;

function THIMST_HTML.TitleFormat;
begin
  Result := '';
  if FTitleText = '' then exit;
  Result := Result + '/* style of title */' + LFCR + 
            '.title {' + LFCR +
            ' background: ' + RGB2HTML(FTitleBackColor) + ';' + LFCR +
            ' padding: 4px;' + LFCR +
            ' text-align: ' + AlignText[FTitleTextAlign] + ';' + LFCR +
            FontString(FTitleFont) + LFCR +
            ' border: ' + int2str(FTitleBorderWeight) + 'px solid ' + RGB2HTML(FTitleBorderColor) + ';' + LFCR + 
            ' padding-left: ' + int2str(FTitlePadLeft) + ';' + LFCR +
            ' padding-top: ' + int2str(FTitlePadTop) + ';' + LFCR +
            ' padding-right: ' + int2str(FTitlePadRight) + ';' + LFCR +
            ' padding-bottom: ' + int2str(FTitlePadBottom) + ';' + LFCR + 
            '}' + LFCR + LFCR;
end;

function THIMST_HTML.NoteFormat;
begin
  Result := '';
  if FNoteText = '' then exit;
  Result := Result + '/* style of note */' + LFCR + 
            '.note {' + LFCR +
            ' background: ' + RGB2HTML(FNoteBackColor) + ';' + LFCR +
            ' padding: 4px;' + LFCR +
            ' text-align: ' + AlignText[FNoteTextAlign] + ';' + LFCR +
            FontString(FNoteFont) + LFCR +
            ' border: ' + int2str(FNoteBorderWeight) + 'px solid ' + RGB2HTML(FNoteBorderColor) + ';' + LFCR + 
            ' padding-left: ' + int2str(FNotePadLeft) + ';' + LFCR +
            ' padding-top: ' + int2str(FNotePadTop) + ';' + LFCR +
            ' padding-right: ' + int2str(FNotePadRight) + ';' + LFCR +
            ' padding-bottom: ' + int2str(FNotePadBottom) + ';' + LFCR + 
            '}' + LFCR + LFCR;
end;

procedure THIMST_HTML._work_doTabToHTML;
var
  sControl: PControl;
  l: TListViewOptions;
  Col, Row: integer;
  FColorItems: boolean; 
begin
  if not Assigned(_prop_MSTControl) then exit;
  sControl := _prop_MSTControl.ctrlpoint;
  HTMLTab := '';
  if not ((sControl.LVStyle = lvsDetail) or (sControl.LVStyle = lvsDetailNoHeader)) then exit;
  FColorItems := _prop_MSTControl.coloritems;
  l := sControl.LVOptions;
  HTMLTab := '<!-- HTML table generator -->' + LFCR + LFCR +
             '<head>' + LFCR +
             CodePage(FCodePage) +
             '<style type="text/css">' + LFCR + LFCR +
             '/* generic style of table */' + LFCR +
             'TABLE {' + LFCR +
             ' border-collapse: collapse;' + LFCR +
             ' border: ' + int2str(FTabBorderWeight) + 'px solid ' + RGB2HTML(FTabBorderColor) + ';' + LFCR +
             CTRLFontString(sControl, _prop_MSTControl) +
             '}' + LFCR + LFCR +
             '/* generic style of header */' + LFCR +
             'TH {' + LFCR +
             ' border: ' + int2str(FHeadBorderWeight) + 'px solid ' + RGB2HTML(FHeadBorderColor) + ';' + LFCR +
             ' background: ' + RGB2HTML(FHeadBackColor) + ';' + LFCR +
             ' text-align: ' + AlignText[FHeadTextAlign] + ';' + LFCR +
             FontString(FHeadFont) + LFCR +
             ' padding-left: ' + int2str(FHeadPadLeft) + ';' + LFCR +
             ' padding-top: ' + int2str(FHeadPadTop) + ';' + LFCR +
             ' padding-right: ' + int2str(FHeadPadRight) + ';' + LFCR +
             ' padding-bottom: ' + int2str(FHeadPadBottom) + ';' + LFCR + 
             '}' + LFCR + LFCR +
             '/* generic style of cells */' + LFCR +
             'TD {' + LFCR +
             ItemHeight(sControl) + LFCR +
             ' padding-top: 0px;' + LFCR + 
             ' padding-bottom: 0px;' + LFCR;
  if not FColorItems then
    HTMLTab := HTMLTab + ' background: ' + RGB2HTML({sControl.LVTextBkColor}_prop_MSTControl.textbkcolor) + ';' + LFCR;
  if (lvoGridLines in l) then
    HTMLTab := HTMLTab + ' border: ' + int2str(FCellsBorderWeight) + 'px solid ' + RGB2HTML(FCellsBorderColor) + ';' + LFCR;
  HTMLTab := HTMLTab + '}' + LFCR + LFCR +
             '/* generic style of columns */' + LFCR +
             'COL {' + LFCR +
             ' padding-left: 4px;' + LFCR +
             ' padding-right: 4px;' + LFCR +
             '}' + LFCR + LFCR +  
             TitleFormat +
             NoteFormat +
             '</style>' + LFCR +
             '</head>' + LFCR + LFCR +
             '<!* building of table *>' + LFCR +
             '<body>' + LFCR +
             ' <table cols="' + int2str(sControl.LVColCount) + '">' + LFCR + LFCR;
  for Col := 0 to sControl.LVColCount - 1 do
    HTMLTab := HTMLTab + '  <col width=' + int2str(sControl.LVColWidth[Col] - 7) + 
               ' align=' + AlignText[ord(sControl.LVColAlign[Col])] + '>' + LFCR;                   
  HTMLTab := HTMLTab + LFCR;
  if FTitleText <> '' then
    HTMLTab := HTMLTab +  
               '  <caption class="title"; valign="top">' + FTitleText + '</caption>' + LFCR + LFCR;
  if sControl.LVStyle = lvsDetail then
  begin
    HTMLTab := HTMLTab + '  <tr>' + LFCR;    
    for Col:= 0 to sControl.LVColCount - 1 do
      HTMLTab := HTMLTab + '   <th>' + sControl.LVColText[Col] + '</th>' + LFCR;
    HTMLTab := HTMLTab + '  </tr>' + LFCR + LFCR;
  end;      
  if sControl.Count <> 0 then 
    for Row := 0 to sControl.Count - 1 do
    begin
      HTMLTab := HTMLTab + '  <tr';
      if FColorItems and FCellsColor then
        HTMLTab := HTMLTab + ColorRowString(_prop_MSTControl, sControl, Row);
      HTMLTab := HTMLTab + '>' + LFCR;    
      for Col := 0 to sControl.LVColCount - 1 do 
        HTMLTab := HTMLTab + '   <td>' + sControl.LVItems[Row, Col] + '</td>' + LFCR;
      HTMLTab := HTMLTab + '  </tr>' + LFCR + LFCR;
    end;
  if FNoteText <> '' then
    HTMLTab := HTMLTab +  
               '  <caption class="note"; valign="bottom">' + FNoteText + '</caption>' + LFCR + LFCR;
  HTMLTab := HTMLTab + ' </table>' + LFCR +
  '</body>' + LFCR;
  _hi_onEvent(_event_onTabToHTML, HTMLTab); 
end;

procedure THIMST_HTML._var_HTMLTab;
begin
  dtString(_Data, HTMLTab);
end;

procedure THIMST_HTML._work_doTitleText;
begin
  FTitleText := ToString(_Data);
end;

procedure THIMST_HTML._work_doTitleBorderWeight;
begin
  FTitleBorderWeight := ToInteger(_Data);
end;  

procedure THIMST_HTML._work_doTitleBorderColor;
begin
  FTitleBorderColor := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doTitleBackColor;
begin
  FTitleBackColor := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doTitleTextAlign;
begin
  FTitleTextAlign := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doTitleFont;
begin
  if _IsFont(_Data) then
    FTitleFont := PFontRec(_Data.idata)^;
end;

procedure THIMST_HTML._work_doTitlePadLeft;
begin
  FTitlePadLeft := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doTitlePadTop;
begin
  FTitlePadTop := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doTitlePadRight;
begin
  FTitlePadRight := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doTitlePadBottom;
begin
  FTitlePadBottom := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doTabBorderWeight;
begin
  FTabBorderWeight := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doTabBorderColor;
begin
  FTabBorderColor := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doHeadBorderWeight;
begin
  FHeadBorderWeight := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doHeadBorderColor;
begin
  FHeadBorderColor := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doHeadBackColor;
begin
  FHeadBackColor := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doHeadTextAlign;
begin
  FHeadTextAlign := Byte(ToInteger(_Data));
end;

procedure  THIMST_HTML._work_doHeadFont;
begin
  if _IsFont(_Data) then
    FHeadFont := PFontRec(_Data.idata)^;
end;

procedure THIMST_HTML._work_doHeadPadLeft;
begin
  FHeadPadLeft := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doHeadPadTop;
begin
  FHeadPadTop := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doHeadPadRight;
begin
  FHeadPadRight := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doHeadPadBottom;
begin
  FHeadPadBottom := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doCellsBorderWeight;
begin
  FCellsBorderWeight := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doCellsBorderColor;
begin
  FCellsBorderColor := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doCellsColor;
begin
  FCellsColor := ReadBool(_Data);
end;

procedure THIMST_HTML._work_doNoteText;
begin
  FNoteText := ToString(_Data);
end;

procedure THIMST_HTML._work_doNoteBorderWeight;
begin
  FNoteBorderWeight := ToInteger(_Data);
end;  

procedure THIMST_HTML._work_doNoteBorderColor;
begin
  FNoteBorderColor := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doNoteBackColor;
begin
  FNoteBackColor := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doNoteTextAlign;
begin
  FNoteTextAlign := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doNoteFont;
begin
  if _IsFont(_Data) then
    FNoteFont := PFontRec(_Data.idata)^;
end;

procedure THIMST_HTML._work_doNotePadLeft;
begin
  FNotePadLeft := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doNotePadTop;
begin
  FNotePadTop := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doNotePadRight;
begin
  FNotePadRight := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doNotePadBottom;
begin
  FNotePadBottom := ToInteger(_Data);
end;

procedure THIMST_HTML._work_doCodePage;
begin
  FCodePage := ToString(_Data);
end;

end.