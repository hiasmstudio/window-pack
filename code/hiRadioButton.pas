unit hiRadioButton;

interface

uses Windows,Kol,Share,Win,Messages;


{$I share.inc}
type
  THIRadioButton = class(THIWin)
   private
     procedure _OnClick(Obj:PObj);
     procedure SetCaption(const Value:string);
     procedure SetSelected(Value:byte);
   public
    _event_onSelect:THI_Event;

    constructor Create(Parent:PControl);
    procedure _work_doSelect(var _Data:TData; Index:word);
    procedure _work_doCaption(var _Data:TData; Index:word);
    procedure _var_Selected(var _Data:TData; Index:word);
    property _prop_Selected:byte write SetSelected;
    property _prop_Caption:string  write SetCaption;
  end;

implementation

constructor THIRadioButton.Create;
begin
   inherited Create(Parent);
   Control := NewRadioBox(Parent,'RadioButton');
   Control.OnClick := _OnClick;
end;

procedure THIRadioButton._work_doSelect;
begin
   if ReadBool(_Data) then 
      SendMessage(Control.Handle,BM_CLICK,0,0)
   else
      Control.Checked := false;

end;

procedure THIRadioButton._work_doCaption;
begin
   Control.Caption := ToString(_Data);
end;

procedure THIRadioButton._var_Selected;
begin
   dtInteger(_Data,integer(Control.Checked));
end;

procedure THIRadioButton.SetCaption;
begin
   Control.Caption := Value;
end;

procedure THIRadioButton.SetSelected;
begin
  Control.Checked := value = 0;
end;

procedure THIRadioButton._OnClick;
//var i:integer;
begin
  {
  for i := 0 to Control.Parent.ChildCount-1 do
   if Control.Parent.Children[i].Style and BS_RADIOBUTTON > 0 then
     SendMessage(Control.GetWindowHandle, BM_SETCHECK, BST_UNCHECKED, 0);

  Control.SetChecked(true);
  }
  _hi_OnEvent(_event_onSelect); 
end;

end.
