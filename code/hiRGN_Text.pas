unit hiRGN_Text;

interface

uses Windows,Kol,Share,Debug;

type
  THIRGN_Text = class(TDebug)
   private
    FRegion : HRGN;
    GFont   : PGraphicTool;
    procedure SetNewFont(Value:TFontRec);
    
   public
    _prop_Str : string;
    _prop_X:integer;
    _prop_Y:integer;
    _prop_Stencil: boolean;

    _data_Str : THI_Event;
    _data_X:THI_Event;
    _data_Y:THI_Event; 
    _event_onCreateRegion : THI_Event;
    
    property _prop_Font:TFontRec write SetNewFont;
    
    destructor Destroy; override;
    procedure _work_doCreateRegion(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doFont(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
    procedure _var_TextWidth(var _Data:TData; Index:word);
    procedure _var_TextHeight(var _Data:TData; Index:word);
  end;

implementation

destructor THIRGN_Text.Destroy;
begin
   GFont.free;
   DeleteObject(FRegion);
   inherited;
end;

procedure THIRGN_Text._work_doCreateRegion;
var pDC : HDC;
    s   : string;
    x,y : integer;
begin
  s := ReadString(_Data,_data_Str,_prop_Str);
  x := ReadInteger(_Data, _data_X,_prop_X);
  y := ReadInteger(_Data, _data_Y,_prop_Y); 
  pDC := CreateCompatibleDC(0);
  SelectObject(pDC, GFont.Handle);
  if not _prop_Stencil then SetBkMode(pDC, TRANSPARENT);
  BeginPath(pDC);
  TextOut(pDC, x, y, PChar(s), length(s));
  EndPath(pDC);
  FRegion := PathToRegion(pDC);
  DeleteDC(pDC);

   _hi_onEvent(_event_onCreateRegion, integer(FRegion));
end;

procedure THIRGN_Text._work_doClear;
begin
  DeleteObject(FRegion);
  FRegion := 0;
end;


procedure THIRGN_Text._work_doFont;
begin
   if _IsFont(_Data) then SetNewFont(pfontrec(_Data.idata)^);
end;

procedure THIRGN_Text.SetNewFont;
begin
   if Assigned(GFont) then GFont.free;
   GFont := NewFont;
   GFont.Color:= Value.Color;
   Share.SetFont(GFont,Value.Style);
   GFont.FontName:= Value.Name;
   GFont.FontHeight:= _hi_SizeFnt(Value.Size);
   GFont.FontCharset:= Value.CharSet;
end;

procedure THIRGN_Text._var_Result;
begin
   dtInteger(_Data, FRegion);
end;

procedure THIRGN_Text._var_TextWidth;
var   SizeFont: TSize;
      DC: HDC;
      s: string;
begin
   s := ReadString(_Data,_data_Str,_prop_Str);
   DC := CreateCompatibleDC(0);
   SelectObject(DC, GFont.Handle);
   GetTextExtentPoint32(DC, PChar(s), Length(s), SizeFont);
   DeleteDC(DC);
   dtInteger(_Data, SizeFont.cx);
end;

procedure THIRGN_Text._var_TextHeight;
var   SizeFont: TSize;
      DC: HDC;
      s: string;
begin
   s := ReadString(_Data,_data_Str,_prop_Str);
   DC := CreateCompatibleDC(0);
   SelectObject(DC, GFont.Handle);
   GetTextExtentPoint32(DC, PChar(s), Length(s), SizeFont);
   DeleteDC(DC);
   dtInteger(_Data, SizeFont.cy);
end;

end.