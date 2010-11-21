unit hiFontManager;

interface

uses Windows,kol,Share,Debug,Win;

type
 THiFontManager = class(TDebug)
   private
     sControl: PControl;
   public
     _prop_Font:TFontRec;
     _prop_ControlManager:IControlManager;
     procedure _work_doFont(var Data:TData; Index:word);
     procedure _work_doSetFont(var Data:TData; Index:word);     
     procedure _var_FontSize(var _Data:TData; Index:word);
     procedure _var_FontColor(var _Data:TData; Index:word);
     procedure _var_FontName(var _Data:TData; Index:word);
     procedure _var_FontStyle(var _Data:TData; Index:word);
     procedure _var_FontCharset(var _Data:TData; Index:word);
end;

implementation

procedure THiFontManager._var_FontSize;
var r: real;
    sFontSize: integer;    
begin
  if not Assigned(_prop_ControlManager) then exit;
  sControl := _prop_ControlManager.ctrlpoint; 
  r := ((sControl.Font.FontHeight * -72) - 36) / ScreenDPI;
  sFontSize := Trunc(r);
  if Frac(r) > 0 then
    Inc(sFontSize);
  dtInteger(_Data, sFontSize);
end;

procedure THiFontManager._var_FontColor;
begin
  if not Assigned(_prop_ControlManager) then exit;
  sControl := _prop_ControlManager.ctrlpoint; 
  dtInteger(_Data, Color2RGB(sControl.Font.Color));
end;

procedure THiFontManager._var_FontName;
begin
  if not Assigned(_prop_ControlManager) then exit;
  sControl := _prop_ControlManager.ctrlpoint; 
  dtString(_Data, sControl.Font.FontName);
end;

procedure THiFontManager._var_FontStyle;
var fs: TFontStyle;
    sFontStyle: integer;
begin
  if not Assigned(_prop_ControlManager) then exit;
  sControl := _prop_ControlManager.ctrlpoint; 
  fs := sControl.Font.FontStyle;
  sFontStyle := 0;
  if fsBold in fs then  
    sFontStyle := sFontStyle + 1;
  if fsItalic in fs then
    sFontStyle := sFontStyle + 2;     
  if fsUnderline in fs then
    sFontStyle := sFontStyle + 4;     
  if fsStrikeOut in fs then
    sFontStyle := sFontStyle + 8;     
  dtInteger(_Data, sFontStyle);
end;

procedure THiFontManager._var_FontCharset;
begin
  if not Assigned(_prop_ControlManager) then exit;
  sControl := _prop_ControlManager.ctrlpoint; 
  dtInteger(_Data, sControl.Font.FontCharset);
end;

procedure THiFontManager._work_doFont;
begin
  if not Assigned(_prop_ControlManager) then exit;
  sControl := _prop_ControlManager.ctrlpoint; 
  sControl.Font.Color := _prop_Font.Color;
  SetFont(sControl.Font,_prop_Font.Style);
  sControl.Font.FontName :=  _prop_Font.Name;
  sControl.Font.FontHeight := _hi_SizeFnt(_prop_Font.Size);
  sControl.Font.FontCharset := _prop_Font.CharSet;      
end;

procedure THiFontManager._work_doSetFont;
begin
  if not Assigned(_prop_ControlManager) then exit;
  sControl := _prop_ControlManager.ctrlpoint; 
  if _IsFont(Data) then
    with pfontrec(Data.idata)^ do
      begin
        sControl.Font.Color := Color;
        SetFont(sControl.Font,Style);
        sControl.Font.FontName :=  Name;
        sControl.Font.FontHeight := _hi_SizeFnt(Size);
        sControl.Font.FontCharset := CharSet;
      end;
end;

end.