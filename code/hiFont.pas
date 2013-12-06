unit hiFont;

interface

uses Windows,Kol,Share,Debug;

const
  CF_SCREENFONTS = $00000001;
  CF_PRINTERFONTS = $00000002;
  CF_BOTH = CF_SCREENFONTS OR CF_PRINTERFONTS;
  CF_SHOWHELP = $00000004;
  CF_ENABLEHOOK = $00000008;
  CF_ENABLETEMPLATE = $00000010;
  CF_ENABLETEMPLATEHANDLE = $00000020;
  CF_INITTOLOGFONTSTRUCT = $00000040;
  CF_USESTYLE = $00000080;
  CF_EFFECTS = $00000100;
  CF_APPLY = $00000200;
  CF_ANSIONLY = $00000400;
  CF_SCRIPTSONLY = CF_ANSIONLY;
  CF_NOVECTORFONTS = $00000800;
  CF_NOOEMFONTS = CF_NOVECTORFONTS;
  CF_NOSIMULATIONS = $00001000;
  CF_LIMITSIZE = $00002000;
  CF_FIXEDPITCHONLY = $00004000;
  CF_WYSIWYG = $00008000;  // must also have CF_SCREENFONTS & CF_PRINTERFONTS 
  CF_FORCEFONTEXIST = $00010000;
  CF_SCALABLEONLY = $00020000;
  CF_TTONLY = $00040000;
  CF_NOFACESEL = $00080000;
  CF_NOSTYLESEL = $00100000;
  CF_NOSIZESEL = $00200000;
  CF_SELECTSCRIPT = $00400000;
  CF_NOSCRIPTSEL = $00800000;
  CF_NOVERTFONTS = $01000000;

type
  PChooseFontA = ^TChooseFontA;
  tagCHOOSEFONTA = packed record
    lStructSize: DWORD;
    hWndOwner: HWnd;            // caller's window handle
    hDC: HDC;                   // printer DC/IC or nil
    lpLogFont: PLogFontA;       // pointer to a LOGFONT struct
    iPointSize: Integer;        // 10 * size in points of selected font
    Flags: DWORD;               // dialog flags
    rgbColors: COLORREF;        // returned text color
    lCustData: LPARAM;          // data passed to hook function
    lpfnHook: function(Wnd: HWND; Message: UINT; wParam: Integer; lParam: Integer): UINT; stdcall;
                                // pointer to hook function
    lpTemplateName: PAnsiChar;  // custom template name
    hInstance: HINST;           // instance handle of EXE that contains
                                //  custom dialog template
    lpszStyle: PAnsiChar;       // return the style field here
                                // must be lf_FaceSize or bigger
    nFontType: Word;            // same value reported to the EnumFonts
                                // call back with the extra fonttype_
                                // bits added
    wReserved: Word;
    nSizeMin: Integer;          // minimum point size allowed and
    nSizeMax: Integer;          // maximum point size allowed if
                                // cf_LimitSize is used
  end;

  tagCHOOSEFONT = tagCHOOSEFONTA;
  TChooseFontA = tagCHOOSEFONTA;

function ChooseFontA(var ChooseFont: TChooseFontA): Bool; stdcall;

type
  THIFont = class(TDebug)
   private
    f:TFontRec;
   public
    _prop_Font:TFontRec;
    _prop_FontDialog:boolean;
    _data_Name:THI_Event;
    _data_Color:THI_Event;
    _data_Size:THI_Event;
    _data_Style:THI_Event;
    _data_CharSet:THI_Event;
    _event_onFont:THI_Event;

    procedure _work_doFont(var _Data:TData; Index:word);
    procedure _var_FontName(var _Data:TData; Index:word);    
    procedure _var_FontColor(var _Data:TData; Index:word);
    procedure _var_FontSize(var _Data:TData; Index:word);
    procedure _var_FontStyle(var _Data:TData; Index:word);        
    procedure _var_FontStrStyle(var _Data:TData; Index:word);
    procedure _var_FontCharSet(var _Data:TData; Index:word);    
  end;

implementation

function ChooseFontA; external 'comdlg32.dll'  name 'ChooseFontA';

procedure THIFont._work_doFont;
var   cf : TChooseFontA;
      lf : TLogFont;
      i :integer;
begin
   f.Size := ReadInteger(_Data,_data_Size,_prop_Font.Size);
   f.Color := ReadInteger(_Data,_data_Color,_prop_Font.Color);
   f.Name := ReadString(_Data,_data_Name,_prop_Font.Name);
   f.Style := ReadInteger(_Data,_data_Style,_prop_Font.Style);
   f.CharSet := ReadInteger(_Data,_data_CharSet,_prop_Font.CharSet);
   if _prop_FontDialog then begin
      FillChar(lf, sizeof(lf), #0);
      FillChar(cf, sizeof(cf), #0);
      cf.lStructSize := sizeof(cf);
      cf.lpLogFont := @lf;
      cf.hWndOwner := ReadHandle;
      cf.Flags := CF_SCREENFONTS or CF_EFFECTS or CF_INITTOLOGFONTSTRUCT;
   
      // init Font_Name   
      FillChar(lf.lfFaceName, sizeof(lf.lfFaceName), #0);
      for i:=1 to Length(f.Name) do lf.lfFaceName[i-1] := f.Name[i];
      // init Font_Size
      lf.lfheight := _hi_SizeFnt(f.Size);
      // init Font_CharSet
      lf.lfCharSet := byte(f.CharSet);
      // init Font_Color
      cf.rgbColors := f.Color;
      // init Font_Style   
      if f.Style and 1 > 0 then lf.lfWeight := 700 else lf.lfWeight := 0;
      if f.Style and 2 > 0 then lf.lfItalic := 1 else lf.lfItalic := 0;   
      if f.Style and 4 > 0 then lf.lfUnderline := 1 else lf.lfUnderline := 0;   
      if f.Style and 8 > 0 then lf.lfStrikeOut := 1 else lf.lfStrikeOut := 0;

      if ChooseFontA(cf) <> false then begin
         // assigned new Font_Name
         f.Name := string(lf.lfFaceName);
         // assigned new Font_Size
         f.Size := cf.iPointSize div 10;
         // assigned new Font_CharSet
         f.CharSet := lf.lfCharSet;
         // assigned new Font_Color
         f.Color := cf.rgbColors;
         // assigned new Font_Style
         f.Style := 0;
         if lf.lfWeight >= 700 then f.Style := 1;
         if lf.lfItalic    > 0 then f.Style := f.Style + 2;
         if lf.lfUnderline > 0 then f.Style := f.Style + 4;
         if lf.lfStrikeOut > 0 then f.Style := f.Style + 8;
         _hi_OnEvent(_event_onFont,f);
      end;
   end else   
      _hi_OnEvent(_event_onFont,f);
end;

procedure THIFont._var_FontName;    
begin
  dtString(_Data, f.Name);
end;

procedure THIFont._var_FontColor;
begin
  dtInteger(_Data, f.Color);
end;

procedure THIFont._var_FontSize;
begin
  dtInteger(_Data, f.Size);
end;

procedure THIFont._var_FontStyle;        
begin
  dtInteger(_Data, f.Style);
end;

procedure THIFont._var_FontStrStyle;
var
  sFontStyle: string;
begin
  sFontStyle := '';
  if f.Style and 1 > 0 then sFontStyle := sFontStyle + 'b';
  if f.Style and 2 > 0 then sFontStyle := sFontStyle + 'i';   
  if f.Style and 4 > 0 then sFontStyle := sFontStyle + 'u';   
  if f.Style and 8 > 0 then sFontStyle := sFontStyle + 's';
  dtString(_Data, sFontStyle);
end;

procedure THIFont._var_FontCharSet;
begin
  dtInteger(_Data, f.CharSet);
end;


end.
