unit hiPanelRush;

interface

uses Windows,Messages,Kol,Share,Win,KOLGRushControls;

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
  THIPanelRush = class(THIWin)
   private
    BitMap: PBitMap;   
    function _OnMessage( var Msg: TMsg; var Rslt: Integer ): Boolean; override;
   public
    _prop_Caption:string;
    _event_onClick:THI_Event;
    _prop_RoundWidth:Integer;
    _prop_RoundHeight:Integer;
    _prop_GlyphVAlign:Byte;
    _prop_GlyphHAlign:Byte;
    _prop_Spacing:Integer;
    _prop_HAlign:Byte;
    _prop_VAlign:Byte;
    _prop_UpdateSpeed:Byte;          
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

    _prop_ColorToDis:Integer;
    _prop_ColorTextDis:Integer;
    _prop_ColorFromDis:Integer;
    _prop_ColorShadowDis:Integer;
    _prop_BorderColorDis:Integer;
    _prop_ShadowOffsetDis:Integer;
    _prop_GradientStyleDis:Byte;
    _prop_BorderWidthDis:Byte;    

    _prop_OnlyGlyphDef:boolean;
    _prop_Glyphs: PStrListEx;

    _prop_Alpha:boolean;
    _prop_AlphaBlendValue:integer;

    constructor Create(Parent:PControl);
    destructor Destroy; override;
    procedure Init; override;
    procedure _work_doColor(var _Data:TData; Index:word);
    procedure _work_doCaption(var _Data:TData; Index:word);
    procedure _work_doEnabled(var Data:TData; Index:word);
    procedure _work_doSetTheme(var _Data:TData; Index:word);
    procedure _work_doUpdate(var _Data:TData; Index:word);    
    procedure _work_doRoundWidth(var _Data:TData; Index:word);
    procedure _work_doRoundHeight(var _Data:TData; Index:word);          
  end;

implementation

constructor THIPanelRush.Create;
begin
   inherited Create(Parent);
   BitMap := NewBitmap(0,0);   
end;

destructor THIPanelRush.Destroy;
begin
  BitMap.free;
  inherited;
end;

procedure THIPanelRush.Init;
var
  i: integer;
  tmp: PBitmap;
  r: TRect;
begin
  Control := NewGRushPanel(FParent);
  inherited;
  with PGRushControl(Control){$ifndef F_P}^{$endif} do
   begin
    Def_ColorText      :=  _prop_ColorText;
    Def_ColorFrom      :=  _prop_ColorFrom;
    Def_ColorShadow    :=  _prop_ColorShadow;
    Def_BorderColor    :=  _prop_BorderColor;
    Def_ColorTo        :=  _prop_ColorTo;
    Def_ShadowOffset   :=  _prop_ShadowOffset;

    Dis_ColorText      :=  _prop_ColorTextDis;
    Dis_ColorFrom      :=  _prop_ColorFromDis;
    Dis_ColorShadow    :=  _prop_ColorShadowDis;
    Dis_BorderColor    :=  _prop_BorderColorDis;
    Dis_ColorTo        :=  _prop_ColorToDis;
    Dis_ShadowOffset   :=  _prop_ShadowOffsetDis;

    Def_BorderRoundWidth   :=  _prop_RoundWidth;
    Def_BorderRoundHeight  :=  _prop_RoundHeight;
    Dis_BorderRoundWidth   :=  _prop_RoundWidth;
    Dis_BorderRoundHeight  :=  _prop_RoundHeight;

    Def_BorderWidth        :=  _prop_BorderWidth;
    Dis_BorderWidth        :=  _prop_BorderWidthDis;

    All_UpdateSpeed    :=  TGRushSpeed(_prop_UpdateSpeed);
    All_DrawFocusRect  :=  false;
    Def_ColorOuter :=  _prop_Color;
    Dis_ColorOuter :=  _prop_Color;
    
    case _prop_HAlign of
      0: All_TextHAlign :=  TGRushHAlign(0);
      1: All_TextHAlign :=  TGRushHAlign(2);
      2: All_TextHAlign :=  TGRushHAlign(1);
    end;  
    All_TextVAlign :=  TGRushVAlign(_prop_VAlign);    

    Def_GradientStyle  :=  arr[_prop_GradientStyle];
    Dis_GradientStyle  :=  arr[_prop_GradientStyleDis];

    All_SplitterDotsCount := _prop_DotsCount;  
    All_SplDotsOrient     := TGRushOrientation(_prop_DotsOrient);
        
    AlphaChannel          := _prop_Alpha;
    AlphaBlendValue       := _prop_AlphaBlendValue; 

    Bitmap.Clear;

    if Assigned(_prop_Glyphs) then
    begin 
      tmp := NewBitmap(0,0);
      if _prop_Glyphs.Objects[0] <> 0 then
        tmp.Handle := _prop_Glyphs.Objects[0];

      BitMap.Width  := tmp.height * _prop_Glyphs.Count;
      BitMap.Height := tmp.height;      

      for i := 0 to _prop_Glyphs.Count - 1 do
      begin
        if i <> 0 then
          tmp.Handle := _prop_Glyphs.Objects[i];
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
      tmp.free;
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
        Dis_GlyphItemX     := 0
      else  
        Dis_GlyphItemX     := 1;
      Dis_GlyphItemY     := 0;
    end
    else 
      All_GlyphBitmap  := nil;

    Caption := _prop_Caption;
   end;
end;

function THIPanelRush._OnMessage;
begin
  case Msg.message of
   WM_ENABLE,WM_SIZE: InvalidateRect(Control.Handle, nil, false);
   WM_LBUTTONDOWN: _hi_OnEvent(_event_onClick);
  end;
  Result := Inherited _OnMessage(Msg,Rslt);
end;

procedure THIPanelRush._work_doCaption;
begin
   Control.Caption := ToString(_Data);
end;

procedure THIPanelRush._work_doEnabled(var Data:TData; Index:word);
begin
   Control.EnableChildren(ReadBool(Data), true);
   Control.Enabled := ReadBool(Data);
   InvalidateRect(Control.Handle, nil, true);
end;

procedure THIPanelRush._work_doColor;
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
    end;  
  end;    
end;

procedure THIPanelRush._work_doSetTheme;
var
  par: integer;
begin

  with PGRushControl(Control){$ifndef F_P}^{$endif} do
  begin
    par := ReadInteger(_Data, Null);
    if par <> P_SKIP then
    begin
      Control.Color   := par;
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
  end;

  InvalidateRect(Control.Handle, nil, true);
end;

procedure THIPanelRush._work_doRoundWidth;
begin
  _prop_RoundWidth := ToInteger(_Data);
  with PGRushControl(Control){$ifndef F_P}^{$endif} do
  begin
    Def_BorderRoundWidth   :=  _prop_RoundWidth;
    Dis_BorderRoundWidth   :=  _prop_RoundWidth;
  end;  
  InvalidateRect(Control.Handle, nil, true);
end;

procedure THIPanelRush._work_doRoundHeight;     
begin
  _prop_RoundHeight := ToInteger(_Data);
  with PGRushControl(Control){$ifndef F_P}^{$endif} do
  begin
    Def_BorderRoundHeight  :=  _prop_RoundHeight;
    Dis_BorderRoundHeight  :=  _prop_RoundHeight;
  end;  
  InvalidateRect(Control.Handle, nil, true);
end;

procedure THIPanelRush._work_doUpdate;
begin
  PGRushControl(Control).SetAllNeedUpdate;
end;

end.