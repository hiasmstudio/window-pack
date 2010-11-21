unit hiGl_Text;

interface

{$I share.inc}

uses Windows,Kol,Share,Debug,OpenGL;

const
  vsFontPoligons = WGL_FONT_POLYGONS;
  vsFontLines = WGL_FONT_LINES;

type
  THIGl_Text = class(TDebug)
   private
   public
    _prop_Font:TFontRec;
    _prop_Text:string;
    _prop_ListStart:integer;
    _prop_ViewStyle:cardinal;
    _prop_Depth:real;
    _prop_Details:real;

    _event_onDraw:THI_Event;
    _event_onInit:THI_Event;
    _data_Text:THI_Event;
    _data_GLHandle:THI_Event;

    procedure _work_doInit(var _Data:TData; Index:word);
    procedure _work_doDraw(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);
  end;

implementation

uses hiGL_Main;

{$ifdef F_P}
function wglUseFontOutlines(p1: HDC; p2, p3, p4: DWORD;
  p5, p6: Single; p7: Integer; p8: PGlyphMetricsFloat): BOOL; stdcall; external opengl32 name 'wglUseFontOutlinesA';
{$endif}

procedure THIGl_Text._work_doInit;
var hFontNew, hOldFont : HFONT;
    lf : TLOGFONT;
    DC:HDC;
begin
    DC := ReadInteger(_Data,_data_GLHandle,0);  
    FillChar(lf, SizeOf(lf), 0);
    lf.lfHeight               :=   _prop_Font.Size;
    lf.lfWeight               :=   _prop_Font.Size; //FW_NORMAL;
    lf.lfCharSet              :=   RUSSIAN_CHARSET; //ANSI_CHARSET;
    lf.lfOutPrecision         :=   OUT_DEFAULT_PRECIS ;
    lf.lfClipPrecision        :=   CLIP_DEFAULT_PRECIS ;
    lf.lfQuality              :=   DEFAULT_QUALITY ;
    lf.lfPitchAndFamily       :=   FF_DONTCARE OR DEFAULT_PITCH;
    lstrcpy(lf.lfFaceName,PChar(_prop_Font.Name));
    //lstrcpy (lf.lfFaceName, 'Arial Cyr');

    hFontNew := CreateFontIndirect(lf);
    hOldFont := SelectObject(DC,hFontNew);
   // glColor(_prop_Font.Color);

    wglUseFontOutlines(DC, 0, 256, _prop_ListStart,_prop_Details, _prop_Depth,_prop_ViewStyle, nil);

    DeleteObject(SelectObject(DC,hOldFont));
    DeleteObject(SelectObject(DC,hFontNew));

    _hi_CreateEvent(_Data,@_event_onInit);
end;

procedure THIGl_Text._work_doDraw;
var Litera:PChar;
begin
  glPushAttrib(GL_ALL_ATTRIB_BITS);
   glNormal3f(-1.0,-1.0,-1.0);
   //glColor(_prop_Font.Color);
   Litera := PChar(readstring(_data,_data_Text,_prop_Text));
   glListBase(_prop_ListStart);
   glCallLists(Length (Litera), GL_UNSIGNED_BYTE, Litera);
   //glListBase(0);
  glPopAttrib;
  _hi_CreateEvent(_Data,@_event_onDraw);
end;

procedure THIGl_Text._work_doDelete;
begin
  glDeleteLists(_prop_ListStart, 256);
end;

end.
