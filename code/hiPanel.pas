unit hiPanel;

interface

{$I share.inc}

uses Kol,Share,Win,Windows,Messages,KOLmdvPanel;

type
  THIPanel = class(THIWin)
   private
    function _OnMessage( var Msg: TMsg; var Rslt: Integer ): Boolean; override;
    procedure _OnClick(Obj:PObj);
    procedure SetOnPaint(Ev:THI_Event);
   public
    _prop_Caption:string;
    _prop_BevelInner:byte;
    _prop_BevelOuter:byte;
    _prop_BevelWidth:integer;
    _prop_BorderStyle:byte;
    _prop_BorderWidth:integer;
    _prop_Alignment:byte;
    _event_onClick:THI_Event;

    procedure Init; override;
    procedure _work_doCaption(var _Data:TData; Index:word);
    procedure _work_doEnabled(var Data:TData; Index:word);
    property  _event_onPaint:THI_Event write SetOnPaint;
  end;

implementation

procedure THIPanel._OnClick;
begin
   _hi_OnEvent(_event_onClick);
end;

function THIPanel._OnMessage;
begin
  case Msg.message of
   WM_ENABLE,WM_SIZE: Control.Invalidate;
  end;
  Result := Inherited _OnMessage(Msg,Rslt);
end;

procedure THIPanel._work_doCaption;
begin
   Control.Caption := ToString(_Data);
end;

procedure THIPanel._work_doEnabled(var Data:TData; Index:word);
begin
   Control.EnableChildren(ReadBool(Data), true);
end;

procedure THIPanel.SetOnPaint;
begin
   fOnPaint := Ev;
   PmdvPanel(Control).onPaint := _onPaint;
end;

procedure THIPanel.Init;
begin
   Control := NewmdvPanel(FParent,TBevelCut(_prop_BevelOuter),TBevelCut(_prop_BevelInner),
      _prop_BevelWidth,TBorderStyle(_prop_BorderStyle),_prop_BorderWidth);
   inherited;
   with Control {$ifndef F_P}^{$endif} do
    begin
       Caption := _prop_Caption;
       VerticalAlign := vaCenter;
       TextAlign := TTextAlign(_prop_Alignment);
       OnClick := _OnClick;
    end;
end;

end.
