unit hiRadioButtonRush;

interface

uses Windows,Kol,Share,Win,Messages,KOLGRushControls;

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
  ThiRadioButtonRush = class(THIWin)
   private
     procedure _OnClick(Obj:PObj);
     procedure SetCaption(const Value:string);
     procedure SetSelected(Value:byte);
   public
    _event_onSelect:THI_Event;

    _prop_ColorTo:Integer;
    _prop_ColorText:Integer;
    _prop_ColorFrom:Integer;
    _prop_ColorShadow:Integer;
    _prop_BorderColor:Integer;
    _prop_ShadowOffset:Integer;
    _prop_GradientStyle:Byte;
    _prop_UpdateSpeed:Byte;
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
    _prop_BorderWidthdis:Byte;     

    _prop_CheckMetric:Integer;
    _prop_ColorCheck:Integer;
    _prop_Color:Integer;

    constructor Create(Parent:PControl);
    procedure Init;override;
    procedure _work_doColor(var _Data:TData; Index:word);
    procedure _work_doSelect(var _Data:TData; Index:word);
    procedure _work_doCaption(var _Data:TData; Index:word);
    procedure _work_doEnabled(var _Data:TData; Index:word);
    procedure _work_doSetTheme(var _Data:TData; Index:word);    
    procedure _var_Selected(var _Data:TData; Index:word);
    property _prop_Selected:byte write SetSelected;
    property _prop_Caption:string  write SetCaption;
  end;

implementation

constructor ThiRadioButtonRush.Create;
begin
   inherited Create(Parent);
   Control := NewGRushRadiobox(Parent,'RadioButtonRush');
end;

procedure ThiRadioButtonRush.Init;
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

    Def_BorderWidth    :=  _prop_BorderWidth;
    Over_BorderWidth   :=  _prop_BorderWidthOver;
    Down_BorderWidth   :=  _prop_BorderWidthDown;
    Dis_BorderWidth    :=  _prop_BorderWidthDis;

    All_UpdateSpeed    :=  TGRushSpeed(_prop_UpdateSpeed);
    All_CheckMetric    :=  _prop_CheckMetric;
    All_ColorCheck     :=  _prop_ColorCheck;
    All_DrawFocusRect  :=  false;
    Def_ColorOuter     :=  _prop_Color;
    Over_ColorOuter    :=  _prop_Color;
    Down_ColorOuter    :=  _prop_Color;
    Dis_ColorOuter     :=  _prop_Color;

    Def_GradientStyle  :=  arr[_prop_GradientStyle];
    Over_GradientStyle :=  arr[_prop_GradientStyleOver];
    Down_GradientStyle :=  arr[_prop_GradientStyleDown];
    Dis_GradientStyle  :=  arr[_prop_GradientStyleDis];
   end;
   Control.OnClick := _OnClick;   
end;

procedure ThiRadioButtonRush._work_doSelect;
begin
   SendMessage(Control.Handle, BM_SETCHECK,ord(ReadBool(_Data)), 0);
end;

procedure ThiRadioButtonRush._work_doCaption;
begin
   Control.Caption := ToString(_Data);
end;

procedure ThiRadioButtonRush._var_Selected;
begin
   dtInteger(_Data,integer(Control.Checked));
end;

procedure ThiRadioButtonRush.SetCaption;
begin
   Control.Caption := Value;
end;

procedure ThiRadioButtonRush.SetSelected;
begin
  Control.Checked := value = 0;
end;

procedure ThiRadioButtonRush._OnClick;
begin
  _hi_OnEvent(_event_onSelect); 
end;

procedure ThiRadioButtonRush._work_doEnabled;
begin
   Control.Enabled := ReadBool(_Data);
   InvalidateRect(Control.Handle, nil, true);
end;

procedure ThiRadioButtonRush._work_doColor;
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

procedure ThiRadioButtonRush._work_doSetTheme;
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

end.