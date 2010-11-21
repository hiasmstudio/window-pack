unit hiButtonRush;

interface

uses Windows,Kol,Share,Win,KOLGRushControls;

const
  arr : array[0..6] of TGRushGradientStyle =(
   gsSolid,
   gsVertical,
   gsHorizontal,
   gsDoubleVert,
   gsDoubleHorz,
   gsFromTopLeft,
   gsFromTopRight);

const
  P_SKIP = -1;
  
{$I share.inc}

type
 ThiButtonRush = class(THIWin)
   private
     BitMap: PBitMap;
     procedure _OnClick(Obj:PObj);
     procedure SetCaption(const Value:string);
     procedure SetGlyphs(Value: PStrListEx);
   public
    _event_onClick:THI_Event;
    _prop_Data:TData;
    _prop_RoundWidth:Integer;
    _prop_RoundHeight:Integer;
    _prop_GlyphVAlign:Byte;
    _prop_GlyphHAlign:Byte;
    _prop_Spacing:Integer;
    _prop_UpdateSpeed:Byte;
    _prop_VAlign:Byte;
    _prop_HAlign:Byte;
    _prop_Color:Integer;
    _prop_DotsCount:Integer;
    _prop_DotsOrient:Byte;

    _prop_ColorTo:Integer;
    _prop_ColorText:Integer;
    _prop_ColorFrom:Integer;
    _prop_ColorShadow:Integer;
    _prop_BorderColor:Integer;
    _prop_ShadowOffset:Integer;
    _prop_GradientStyle:Byte;
    _prop_BorderWidth:Byte;    

    _prop_ColorToOver:Integer;
    _prop_ColorTextOver:Integer;
    _prop_ColorFromOver:Integer;
    _prop_ColorShadowOver:Integer;
    _prop_BorderColorOver:Integer;
    _prop_ShadowOffsetOver:Integer;
    _prop_GradientStyleOver:Byte;
    _prop_BorderWidthOver:Byte;

    _prop_ColorToDown:Integer;
    _prop_ColorTextDown:Integer;
    _prop_ColorFromDown:Integer;
    _prop_ColorShadowDown:Integer;
    _prop_BorderColorDown:Integer;
    _prop_ShadowOffsetDown:Integer;
    _prop_GradientStyleDown:Byte;
    _prop_BorderWidthDown:Byte;    

    _prop_ColorToDis:Integer;
    _prop_ColorTextDis:Integer;
    _prop_ColorFromDis:Integer;
    _prop_ColorShadowDis:Integer;
    _prop_BorderColorDis:Integer;
    _prop_ShadowOffsetDis:Integer;
    _prop_GradientStyleDis:Byte;
    _prop_BorderWidthDis:Byte;

    _prop_OnlyGlyphDef:boolean;
    
    _prop_Alpha:boolean;
    _prop_AlphaBlendValue:integer;

     constructor Create(Parent:PControl);
     destructor Destroy; override;
     procedure Init;override;
     procedure _work_doColor(var _Data:TData; Index:word);
     procedure _work_doCaption(var _Data:TData; Index:word);
     procedure _work_doEnabled(var _Data:TData; Index:word);
     procedure _work_doSetTheme(var _Data:TData; Index:word);     
     property _prop_Caption:string write SetCaption;              
     property _prop_Glyphs: PStrListEx write SetGlyphs;     
     procedure _work_doRoundWidth(var _Data:TData; Index:word);
     procedure _work_doRoundHeight(var _Data:TData; Index:word);     
 end;

implementation

constructor ThiButtonRush.Create;
begin
   inherited Create(Parent);
   Control := NewGRushButton(Parent,'ButtonRush');
   BitMap := NewBitmap(0,0);  
end;

destructor ThiButtonRush.Destroy;
begin
  BitMap.free;
  inherited;
end;

procedure ThiButtonRush.Init;
begin
  inherited;
  with PGRushControl(Control){$ifndef F_P}^{$endif} do
   begin
    Def_ColorText      :=  _prop_ColorText;
    Def_ColorFrom      :=  _prop_ColorFrom;
    Def_ColorShadow    :=  _prop_ColorShadow;
    Def_BorderColor    :=  _prop_BorderColor;
    Def_ColorTo        :=  _prop_ColorTo;
    Def_ShadowOffset   :=  _prop_ShadowOffset;

    Over_ColorText     :=  _prop_ColorTextOver;
    Over_ColorFrom     :=  _prop_ColorFromOver;
    Over_ColorShadow   :=  _prop_ColorShadowOver;
    Over_BorderColor   :=  _prop_BorderColorOver;
    Over_ColorTo       :=  _prop_ColorToOver;
    Over_ShadowOffset  :=  _prop_ShadowOffsetOver;

    Down_ColorText     :=  _prop_ColorTextDown;
    Down_ColorFrom     :=  _prop_ColorFromDown;
    Down_ColorShadow   :=  _prop_ColorShadowDown;
    Down_BorderColor   :=  _prop_BorderColorDown;
    Down_ColorTo       :=  _prop_ColorToDown;
    Down_ShadowOffset  :=  _prop_ShadowOffsetDown;

    Dis_ColorText      :=  _prop_ColorTextDis;
    Dis_ColorFrom      :=  _prop_ColorFromDis;
    Dis_ColorShadow    :=  _prop_ColorShadowDis;
    Dis_BorderColor    :=  _prop_BorderColorDis;
    Dis_ColorTo        :=  _prop_ColorToDis;
    Dis_ShadowOffset   :=  _prop_ShadowOffsetDis;

    Def_BorderRoundWidth   :=  _prop_RoundWidth;
    Def_BorderRoundHeight  :=  _prop_RoundHeight;
    Over_BorderRoundWidth  :=  _prop_RoundWidth;
    Over_BorderRoundHeight :=  _prop_RoundHeight;
    Down_BorderRoundWidth  :=  _prop_RoundWidth;
    Down_BorderRoundHeight :=  _prop_RoundHeight;
    Dis_BorderRoundWidth   :=  _prop_RoundWidth;
    Dis_BorderRoundHeight  :=  _prop_RoundHeight;

    Def_BorderWidth        :=  _prop_BorderWidth;
    Over_BorderWidth       :=  _prop_BorderWidthOver;
    Down_BorderWidth       :=  _prop_BorderWidthDown;
    Dis_BorderWidth        :=  _prop_BorderWidthDis;

    All_UpdateSpeed    :=  TGRushSpeed(_prop_UpdateSpeed);
    All_DrawFocusRect  :=  false;
    Def_ColorOuter     :=  _prop_Color;
    Over_ColorOuter    :=  _prop_Color;
    Down_ColorOuter    :=  _prop_Color;
    Dis_ColorOuter     :=  _prop_Color;
    
    All_TextVAlign :=  TGRushVAlign(_prop_VAlign); 
    All_TextHAlign :=  TGRushHAlign(_prop_HAlign);

    Def_GradientStyle  :=  arr[_prop_GradientStyle];
    Over_GradientStyle :=  arr[_prop_GradientStyleOver];
    Down_GradientStyle :=  arr[_prop_GradientStyleDown];
    Dis_GradientStyle  :=  arr[_prop_GradientStyleDis];
    
    All_SplitterDotsCount := _prop_DotsCount;
    All_SplDotsOrient     := TGRushOrientation(_prop_DotsOrient);

    AlphaChannel          := _prop_Alpha;
    AlphaBlendValue       := _prop_AlphaBlendValue; 
   end;
   Control.OnClick := _OnClick;
end;

procedure ThiButtonRush._work_doCaption;
begin
   Control.Caption := ToString(_Data);
end;

procedure ThiButtonRush._OnClick;
begin
  _hi_OnEvent_(_event_onClick,_prop_Data);
end;

procedure ThiButtonRush.SetCaption;
begin
  Control.Caption := Value;
end;

procedure ThiButtonRush._work_doEnabled;
begin
   Control.Enabled := ReadBool(_Data);
   InvalidateRect(Control.Handle, nil, true);
end;

procedure ThiButtonRush.SetGlyphs;
var
  i: integer;
  tmp: PBitmap;
  r: TRect;
begin
  with PGRushControl(Control){$ifndef F_P}^{$endif} do
  begin
    Bitmap.Clear;
    tmp := NewBitmap(0,0);
    if Value.Objects[0] <> 0 then
      tmp.Handle := Value.Objects[0];

    BitMap.Width  := tmp.height * Value.Count;
    BitMap.Height := tmp.height;      

    for i := 0 to Value.Count - 1 do
    begin
      if i <> 0 then
        tmp.Handle := Value.Objects[i];
      tmp.PixelFormat := pf32bit;
      with tmp{$ifndef F_P}^{$endif} do
        if height > 0 then
        begin
          r.left := i * height;
          r.right := r.left + height;
          r.top := 0;
          r.bottom := height;
          if not _prop_Alpha then
            BmpTransparent(tmp);
          BitMap.CopyRect(r, tmp, BoundsRect);
        end;
    end;

    if not BitMap.Empty then
    begin 
      All_GlyphVAlign    := TGRushVAlign(_prop_GlyphVAlign);
      All_GlyphHAlign    := TGRushHAlign(_prop_GlyphHAlign);
      All_Spacing        := _prop_Spacing;
      All_CropTopFirst   := false;      

      All_GlyphBitmap    := BitMap;
      All_GlyphWidth     := BitMap.Height;
      All_GlyphHeight    := BitMap.Height;       
      Def_GlyphItemX     := 0;
      Def_GlyphItemY     := 0;
      if _prop_OnlyGlyphDef then
        Over_GlyphItemX    := 0
      else        
        Over_GlyphItemX    := 1; 
      Over_GlyphItemY      := 0;
      if _prop_OnlyGlyphDef then
        Down_GlyphItemX    := 0
      else        
        Down_GlyphItemX    := 2;      
      Down_GlyphItemY      := 0;
      if _prop_OnlyGlyphDef then
        Dis_GlyphItemX     := 0
      else        
        Dis_GlyphItemX     := 3;
      Dis_GlyphItemY       := 0;
    end
    else 
      All_GlyphBitmap  := nil;
    tmp.free;
  end;
end;

procedure ThiButtonRush._work_doColor;
var
  par: integer;
begin
  with PGRushControl(Control){$ifndef F_P}^{$endif} do
  begin
    par := ToInteger(_Data);
    if par <> P_SKIP then
    begin
      Control.Color   := par;
      Def_ColorOuter  := par;
      Dis_ColorOuter  := par;
      Over_ColorOuter := par;
      Down_ColorOuter := par;
    end;
  end;    
end;

procedure ThiButtonRush._work_doSetTheme;
var
  par: integer;
begin

  with PGRushControl(Control){$ifndef F_P}^{$endif} do
  begin
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then
    begin
      Control.Color   := par;
      Def_ColorOuter  := par;
      Dis_ColorOuter  := par;
      Over_ColorOuter := par;
      Down_ColorOuter := par;
    end;  

    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then Def_ColorFrom := par;
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then Def_ColorTo := par;
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Def_ColorText := par;
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Def_BorderColor := par;
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Def_ColorShadow := par;

    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Dis_ColorFrom := par;
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Dis_ColorTo := par;
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Dis_ColorText := par;
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Dis_BorderColor := par;
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Dis_ColorShadow := par;

    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Over_ColorFrom := par;
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Over_ColorTo := par;
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Over_ColorText := par;
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Over_BorderColor := par;
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Over_ColorShadow := par;

    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Down_ColorFrom := par;
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Down_ColorTo := par;
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Down_ColorText := par;
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Down_BorderColor := par;
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then  Down_ColorShadow := par;
  end;

  InvalidateRect(Control.Handle, nil, true);
end;

procedure ThiButtonRush._work_doRoundWidth;
begin
  _prop_RoundWidth := ToInteger(_Data);
  with PGRushControl(Control){$ifndef F_P}^{$endif} do
  begin
    Def_BorderRoundWidth   :=  _prop_RoundWidth;
    Over_BorderRoundWidth  :=  _prop_RoundWidth;
    Down_BorderRoundWidth  :=  _prop_RoundWidth;
    Dis_BorderRoundWidth   :=  _prop_RoundWidth;
  end;  
  InvalidateRect(Control.Handle, nil, true);
end;

procedure ThiButtonRush._work_doRoundHeight;     
begin
  _prop_RoundHeight := ToInteger(_Data);
  with PGRushControl(Control){$ifndef F_P}^{$endif} do
  begin
    Def_BorderRoundHeight  :=  _prop_RoundHeight;
    Over_BorderRoundHeight :=  _prop_RoundHeight;
    Down_BorderRoundHeight :=  _prop_RoundHeight;
    Dis_BorderRoundHeight  :=  _prop_RoundHeight;
  end;  
  InvalidateRect(Control.Handle, nil, true);
end;

end.