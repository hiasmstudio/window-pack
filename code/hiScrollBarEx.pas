unit hiScrollBarEx;

interface

uses Kol,Share,Win,Windows,Messages,EHI_ScrollBar;

type
  THIScrollBarEx = class(THIWin)
   private
    procedure SetMax(Value:integer);
    procedure SetMin(Value:integer);
    procedure SetPosition(Value:integer);
    procedure SetKind(Value:byte);
    procedure SetSM(Value:byte);
    procedure _OnhiScroll(Pos:integer);
   public
    _prop_LightColor:TColor;
    _prop_FaceColor:TColor;
    _prop_DarkColor:TColor;
    _prop_ArrowColor:TColor;
    _event_onPosition:THI_Event;

    constructor Create(Parent:PControl);
    procedure Init; override;
    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _work_doMax(var _Data:TData; Index:word);
    procedure _work_doMin(var _Data:TData; Index:word);
    procedure _var_Position(var _Data:TData; Index:word);
    property _prop_Max:integer write SetMax;
    property _prop_Min:integer write SetMin;
    property _prop_Position:integer write SetPosition;
    property _prop_Kind:byte write SetKind;
    property _prop_ScrollMode:byte write SetSM;
  end;

implementation

constructor THIScrollBarEx.Create;
begin
   inherited Create(Parent);

   Control := NewHiScrollBar(Parent);
   TKOLScrollBar(Control).OnCScroll := _OnhiScroll;
   SetClassLong(Control.Handle,GCL_STYLE,GetClassLong(Control.GetWindowHandle,GCL_STYLE) and not CS_DBLCLKS);
end;

procedure  THIScrollBarEx.Init;
begin
   inherited;

   TKOLScrollBar(Control).LightColor := _prop_LightColor;
   TKOLScrollBar(Control).FaceColor := _prop_FaceColor;
   TKOLScrollBar(Control).DarkColor := _prop_DarkColor;
   TKOLScrollBar(Control).ArrowColor := _prop_ArrowColor;
end;

procedure THIScrollBarEx._work_doPosition;
begin
    TKOLScrollBar(Control).Position := ToInteger(_Data);
end;

procedure THIScrollBarEx._work_doMax;
begin
    TKOLScrollBar(Control).Max := ToInteger(_Data);
end;

procedure THIScrollBarEx._work_doMin;
begin
    TKOLScrollBar(Control).Min := ToInteger(_Data);
end;

procedure THIScrollBarEx._var_Position;
begin
   dtInteger(_Data,TKOLScrollBar(Control).Position);
end;

procedure THIScrollBarEx._OnhiScroll;
begin
  _hi_OnEvent(_event_onPosition,pos);
end;

procedure THIScrollBarEx.SetKind;
begin
   TKOLScrollBar(Control).Kind := Value;
end;

procedure THIScrollBarEx.SetSM;
begin
   TKOLScrollBar(Control).ScrollMode := Value;
end;

procedure THIScrollBarEx.SetMax;
begin
   TKOLScrollBar(Control).Max := Value;
end;

procedure THIScrollBarEx.SetMin;
begin
   TKOLScrollBar(Control).Min := Value;
end;

procedure THIScrollBarEx.SetPosition;
begin
   TKOLScrollBar(Control).Position  := Value;
end;

end.
