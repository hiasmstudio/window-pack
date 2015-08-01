unit hiProgressBarRush;

interface

uses Kol,Share,Win,Windows,KOLGRushControls;

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

type
  ThiProgressBarRush = class(THIWin)
   private
     procedure SetCaption(const Value:string);   
   public
    _prop_RoundWidth:Byte;
    _prop_RoundHeight:Byte;
    _prop_Max:integer;
    _prop_Color:Integer;
    _prop_Kind:Byte;
    _prop_Frame:Boolean;
    _prop_DrawProgress:Boolean;

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

    constructor Create(Parent:PControl);
    procedure Init; override;
    procedure _work_doColor(var _Data:TData; Index:word);
    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _work_doCaption(var _Data:TData; Index:word);
    procedure _work_doMax(var _Data:TData; Index:word);
    procedure _work_doSetTheme(var _Data:TData; Index:word);
    procedure _work_doUpdate(var _Data:TData; Index:word);        
    procedure _work_doEnabled(var _Data:TData; Index:word);    
    procedure _var_Position(var _Data:TData; Index:word);
    procedure _work_doRoundWidth(var _Data:TData; Index:word);
    procedure _work_doRoundHeight(var _Data:TData; Index:word);
    property _prop_Caption:string write SetCaption;          
  end;

implementation

constructor ThiProgressBarRush.Create;
begin
   inherited Create(Parent);
   Control := NewGRushProgressBar(FParent);
end;

procedure ThiProgressBarRush.Init;
begin
  inherited;
  with PGRushControl(Control){$ifndef F_P}^{$endif} do
   begin
    Def_ColorText          :=  _prop_ColorText;
    Def_ColorFrom          :=  _prop_ColorFrom;
    Def_ColorShadow        :=  _prop_ColorShadow;
    Def_BorderColor        :=  _prop_BorderColor;
    Def_ColorTo            :=  _prop_ColorTo;
    Def_ShadowOffset       :=  _prop_ShadowOffset;
    Def_ColorOuter         :=  _prop_Color;

    Dis_ColorText          :=  _prop_ColorTextDis;
    Dis_ColorFrom          :=  _prop_ColorFromDis;
    Dis_ColorShadow        :=  _prop_ColorShadowDis;
    Dis_BorderColor        :=  _prop_BorderColorDis;
    Dis_ColorTo            :=  _prop_ColorToDis;
    Dis_ShadowOffset       :=  _prop_ShadowOffsetDis;
    Dis_ColorOuter         :=  _prop_Color;

    All_DrawProgress       := _prop_DrawProgress;
    All_DrawProgressRect   := _prop_Frame;
    case _prop_Kind of
      0: All_ProgressVertical   := false;
      1: All_ProgressVertical   := true;
    end;  

    Def_BorderWidth        :=  _prop_BorderWidth;
    Dis_BorderWidth        :=  _prop_BorderWidthDis;

    Def_BorderRoundWidth   :=  _prop_RoundWidth;
    Def_BorderRoundHeight  :=  _prop_RoundHeight;
    Dis_BorderRoundWidth   :=  _prop_RoundWidth;
    Dis_BorderRoundHeight  :=  _prop_RoundHeight;    

    Def_GradientStyle  :=  arr[_prop_GradientStyle];
    Dis_GradientStyle  :=  arr[_prop_GradientStyleDis];
   end;
   Control.MaxProgress := _prop_Max;
   Control.Progress := 0;      
end;

procedure ThiProgressBarRush._work_doCaption;
begin
   Control.Caption := ToString(_Data);
end;

procedure ThiProgressBarRush._work_doPosition;
begin
   Control.Progress := ReadInteger(_data,null,0);
end;

procedure ThiProgressBarRush._work_doMax;
begin
   Control.MaxProgress := ReadInteger(_data,null,0);
end;

procedure ThiProgressBarRush._var_Position;
begin
  dtInteger(_Data,Control.Progress);
end;

procedure ThiProgressBarRush._work_doEnabled;
begin
   Control.Enabled := ReadBool(_Data);
   InvalidateRect(Control.Handle, nil, true);
end;

procedure ThiProgressBarRush._work_doColor;
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

procedure ThiProgressBarRush._work_doSetTheme;
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

procedure ThiProgressBarRush._work_doRoundWidth;
begin
  _prop_RoundWidth := ToInteger(_Data);
  with PGRushControl(Control){$ifndef F_P}^{$endif} do
  begin
    Def_BorderRoundWidth   :=  _prop_RoundWidth;
    Dis_BorderRoundWidth   :=  _prop_RoundWidth;
  end;  
  InvalidateRect(Control.Handle, nil, true);
end;

procedure ThiProgressBarRush._work_doRoundHeight;     
begin
  _prop_RoundHeight := ToInteger(_Data);
  with PGRushControl(Control){$ifndef F_P}^{$endif} do
  begin
    Def_BorderRoundHeight  :=  _prop_RoundHeight;
    Dis_BorderRoundHeight  :=  _prop_RoundHeight;
  end;  
  InvalidateRect(Control.Handle, nil, true);
end;

procedure ThiProgressBarRush.SetCaption;
begin
  Control.Caption := Value;
end;

procedure ThiProgressBarRush._work_doUpdate;
begin
  PGRushControl(Control).SetAllNeedUpdate;
end;

end.