unit hiStatusBarEx; {Строка состояния c панелью прогресса ver 3.00}

interface

uses Windows,Kol,Share,Debug,Messages,hiHintManager;

type
  ThiStatusBarEx = class(TDebug)
   private
    FList:PStrList;
    Arr:PArray;
    Control:PControl;
    Progress:PControl;
    TempText:string;
    CurPanelPBar:integer;
    GSymbol:string;
    hid:pointer;
    procedure SetHint(const Text:string);
    procedure SetText(const Value:string);
    procedure _Set(var Item:TData; var Val:TData);
    function _Get(Var Item:TData; var Val:TData):boolean;
    function _Count:integer;
    procedure _Add(var Val:TData);
    procedure SetPanel(const col:string);
   public
    _prop_SizeGrip:boolean;
    _prop_Text:string;
    _prop_TextAlign:integer;
    _prop_Visible:boolean;
    _prop_EnablePBar:boolean;
    _prop_PanelPBar:integer;
    _prop_ColorPBar:TColor;
    _prop_Smooth:boolean;
    _prop_VisiblePBar:boolean;
    _prop_HintPBar:string;
    _prop_Max:integer;
    _prop_Ctl3DPBar:boolean;
    _prop_PanelHintPBar:boolean;
    _prop_HintManager:IHintManager;    

    _event_onText:THI_Event;
    _data_Width:THI_Event;
    _data_Panel:THI_Event;
    _data_Text:THI_Event;

    constructor Create(Parent:PControl);
    destructor Destroy; override;
    procedure _work_doText(var _Data:TData; Index:word);
    procedure _work_doWidth(var _Data:TData; Index:word);
    procedure _work_doVisible(var _Data:TData; Index:word);
    procedure _work_doIndexText(var _Data:TData; Index:word);
    procedure _work_doVisiblePBar(var _Data:TData; Index:word);
    procedure _work_doHintPBar(var _Data:TData; Index:word);
    procedure _work_doMax(var _Data:TData; Index:word);
    procedure _work_doPosPBar(var _Data:TData; Index:word);
    procedure _work_doPanelPBar(var _Data:TData; Index:word);

    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_Handle(var _Data:TData; Index:word);
    procedure _var_Array(var _Data:TData; Index:word);
    procedure _var_PosPBar(var _Data:TData; Index:word);

    property _prop_Panels:string write SetPanel;
    property _prop_Strings:string write SetText;

  end;

implementation

function WndProcResize( Sender: PControl; var Msg: TMsg; var Rslt: Integer ): Boolean;
begin
  Result := false;
  with ThiStatusBarEx(Sender.Tag) do
  begin
    case Msg.message of
      WM_SIZE: begin
                 if Assigned(Progress) then
                 begin
                   Progress.Height:= Control.StatusCtl.Height - 8;
                   Progress.Top:= Control.StatusCtl.Top + 5;
                 end;
                 Control.Invalidate;
               end;
    end;   
  end;
end;

constructor ThiStatusBarEx.Create;
begin
  inherited Create;
  Control := Parent;
  Control.Tag := LongInt(Self);
  Control.AttachProc(WndProcResize);
  FList := NewStrList;
end;

destructor THIStatusBarEx.Destroy;
begin
  if Arr <> nil then dispose (Arr);
  FList.free;
  inherited;   
end;

procedure ThiStatusBarEx.SetText;
begin
  Flist.Text := Value;
end;

procedure  ThiStatusBarEx.SetPanel;
var  lst: PStrList;
     i,x: integer;
     s: string;
     OldWidth,WidthPBar: integer;
begin
  CurPanelPBar := _prop_PanelPBar;
  OldWidth := 0;
  WidthPBar := 0;     
  Control.SizeGrip := _prop_SizeGrip;
  lst := NewStrList;
  lst.text := col;
  GSymbol := Copy(#9#9,1,_prop_TextAlign);
  Control.SimpleStatusText := PChar(Gsymbol + _Prop_Text);
  if Lst.Count > 0 then
    Control.StatusText[lst.Count] := PChar(Gsymbol + _Prop_Text);
  x := 0;
  for i := 0 to lst.Count - 1 do
  begin
    s := Lst.Items[i] + '=';
    if (i = _prop_PanelPBar) and _prop_EnablePBar then
    begin
      Control.StatusText[i] := PChar(Gsymbol + GetTok(s,'='));
      TempText := Control.StatusText[i];
      Control.StatusText[i] := '';
    end
    else
      Control.StatusText[i] := PChar(Gsymbol + GetTok(s,'=')); 
    if (i = _prop_PanelPBar) and _prop_EnablePBar then
      OldWidth := x;
    if s <> '' then
      inc(x, Str2Int(s));
    Control.StatusPanelRightX[i] := x;
    if (i = _prop_PanelPBar) and _prop_EnablePBar then
      WidthPBar:= Str2Int(s);
  end;
  Control.StatusCtl.Align := caNone;
  Control.StatusCtl.Visible := _prop_Visible;
  if _prop_EnablePBar and (Lst.Count > 0) then
  begin
    if _prop_Smooth then
       Progress := NewProgressbarEx(Control,[pboSmooth])
    else
       Progress := NewProgressbarEx(Control,[]);
    Progress.Visible       := false;
    Progress.MaxProgress   := _prop_Max;
    Progress.ProgressColor := _prop_ColorPBar;
    Progress.Ctl3D         := _prop_Ctl3DPBar;
    Progress.Height        := Control.StatusCtl.Height - 8;
    Progress.Top           := Control.StatusCtl.Top + 5;
    Progress.Width         := WidthPBar - 10;
    Progress.Left          := OldWidth + 4;
    if (_prop_HintPBar <> '')  and  not (_prop_PanelHintPBar) then
      SetHint(_prop_HintPBar);
    SetWindowPos(Progress.GetWindowHandle, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE or
                 SWP_NOACTIVATE or SWP_NOOWNERZORDER or SWP_HIDEWINDOW);  
    if not _prop_VisiblePBar then
      Control.StatusText[_prop_PanelPBar] := PChar(TempText);
    if _prop_VisiblePBar and Control.StatusCtl.Visible then
      Progress.Visible := true;
  end;
  lst.Free;
end;

procedure ThiStatusBarEx._work_doText;
var  Text: string;
     Panel: integer;
begin
  Text := ReadString(_Data,_data_Text,_prop_Text);
  Panel := ReadInteger(_Data,_data_Panel,0);
  if (Panel = _prop_PanelPBar) and Assigned(Progress) then
    TempText := Text;
  if (Panel = Control.StatusPanelCount) and not ((Panel = _prop_PanelPBar) and Assigned(Progress) and _prop_VisiblePBar) then
    Control.SimpleStatusText:=PChar(Gsymbol + Text)
  else if (Panel = Control.StatusPanelCount) and (Panel = _prop_PanelPBar) and Assigned(Progress) and _prop_VisiblePBar then
    Control.SimpleStatusText := ''
  else if (Panel = _prop_PanelPBar) and Assigned(Progress) and _prop_VisiblePBar then
    Control.StatusText[Panel] := ''
  else 
    Control.StatusText[Panel] := PChar(Gsymbol + Text);
  _hi_onEvent(_event_onText);
end;

procedure ThiStatusBarEx._work_doWidth;
var  Panel,Width,x: integer;
begin
  if not Assigned(Progress) then exit;
  Panel := ReadInteger(_Data,_data_Panel,0);
  Width := ReadInteger(_Data,_data_Width,0);
  if Panel >= Control.StatusPanelCount then exit;
  x:=0;
  if Panel > 0 then
    x := Control.StatusPanelRightX[Panel-1];
  Control.StatusPanelRightX[Panel] := Width+x;
  if Assigned(Progress) and (Panel = _prop_PanelPBar) then
  begin
    Progress.Width := Width - 10;
    Progress.Left := x + 4; 
  end;
end;

procedure ThiStatusBarEx._work_doVisible;
begin
  if not Assigned(Progress) then exit;
  Control.StatusCtl.Visible := ReadBool(_Data);
  if _prop_VisiblePBar and Control.StatusCtl.Visible then
    Progress.Visible := true
  else  
    Progress.Visible := false;
end;

procedure ThiStatusBarEx._work_doIndexText;
var  Panel,Ind: integer;
begin
  Ind := ReadInteger(_Data,null,0);
  Panel := ReadInteger(_Data,_data_Panel,0);
  if (Panel = _prop_PanelPBar) and Assigned(Progress) then
    TempText := FList.Items[Ind];
  if (Panel = Control.StatusPanelCount) and not ((Panel = _prop_PanelPBar) and Assigned(Progress) and _prop_VisiblePBar) then
    Control.SimpleStatusText := PChar(Gsymbol+FList.Items[Ind])
  else if (Panel = Control.StatusPanelCount) and (Panel = _prop_PanelPBar) and Assigned(Progress) and _prop_VisiblePBar then
    Control.SimpleStatusText := ''
  else if (Panel = _prop_PanelPBar) and Assigned(Progress) and _prop_VisiblePBar then
    Control.StatusText[Panel] := ''
  else
    Control.StatusText[Panel] := PChar(Gsymbol+FList.Items[Ind]);
  _hi_onEvent(_event_onText);
end;

procedure ThiStatusBarEx._var_Count;
begin
  dtInteger(_Data, Control.StatusPanelCount);
end;

procedure ThiStatusBarEx._var_Handle;
begin
  dtInteger(_Data, Integer(Control.StatusWindow));
end;

procedure ThiStatusBarEx._Set;
var  ind: integer;
begin
  ind := ToIntIndex(Item);
  if(ind >= 0)and(ind < FList.Count)then
    FList.Items[ind] := ToString(Val);
end;

procedure ThiStatusBarEx._Add;
begin
  FList.Add(ToString(Val));
end;

function ThiStatusBarEx._Get;
var  ind: integer;
begin
  ind := ToIntIndex(Item);
  if(ind >= 0)and(ind < FList.Count)then
  begin
    Result := true;
    dtString(Val,FList.Items[ind]);
  end
  else
    Result := false;
end;

function ThiStatusBarEx._Count;
begin
  Result := FList.Count;
end;

procedure ThiStatusBarEx._var_Array;
begin
  if Arr = nil then
    Arr := CreateArray(_Set,_Get,_Count,_Add);
  dtArray(_Data,Arr);
end;

procedure ThiStatusBarEx._work_doVisiblePBar;
begin
  if not Assigned(Progress) then exit;
  _prop_VisiblePBar:= boolean(ToInteger(_Data));
  Progress.Visible := false;
  if not _prop_VisiblePBar then
    Control.StatusText[_prop_PanelPBar]:= PChar(TempText)
  else 
    Control.StatusText[_prop_PanelPBar]:= '';
  if _prop_VisiblePBar and Control.StatusCtl.Visible then
    Progress.Visible := true
end;

procedure ThiStatusBarEx._work_doHintPBar;
var  s: string;
begin
  if not Assigned(Progress) then exit; 
  _prop_HintPBar:= ToString(_Data);
  s := TempText;
  Replace(s, GSymbol, '');
  if (_prop_HintPBar <> '') and  not (_prop_PanelHintPBar) then
    SetHint(_prop_HintPBar)
  else if _prop_PanelHintPBar then
    SetHint(s);
end;

procedure ThiStatusBarEx._work_doMax;
begin
  if not Assigned(Progress) then exit;
  Progress.MaxProgress := ToInteger(_Data);
end;

procedure ThiStatusBarEx._work_doPosPBar;
begin
  if not Assigned(Progress) then exit;
  Progress.Progress := ToInteger(_Data);
end;

procedure ThiStatusBarEx._work_doPanelPBar;
var  OldPanel,Width,x: integer;
begin
  if not Assigned(Progress) then exit;
  OldPanel := CurPanelPBar;
  _prop_PanelPBar := ToInteger(_Data);
  CurPanelPBar := _prop_PanelPBar; 
  Progress.Visible := false;
  Control.StatusText[OldPanel] := PChar(TempText);
  x := 0;
  if _prop_PanelPBar > 0 then
    x := Control.StatusPanelRightX[_prop_PanelPBar - 1];
  Width := Control.StatusPanelRightX[_prop_PanelPBar] - x;
  Progress.Width := Width - 10;
  Progress.Left := x + 4; 
  TempText := Control.StatusText[_prop_PanelPBar];
  if _prop_VisiblePBar then
    Control.StatusText[_prop_PanelPBar] := '';   
  if _prop_VisiblePBar and Control.StatusCtl.Visible then
    Progress.Visible := true
end;

procedure ThiStatusBarEx._var_PosPBar;
begin
  dtInteger(_Data,Progress.Progress);
end;

procedure ThiStatusBarEx.SetHint;
begin
  if Assigned(_prop_HintManager) then
  begin
    if not Assigned(hid) then
      hid := _prop_HintManager.init(Progress.GetWindowHandle);
    _prop_HintManager.hint(hid, Text);
  end;  
end;

end.
