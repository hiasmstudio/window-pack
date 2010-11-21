unit hiGroupBox;

interface

uses Kol,Share,Win,Windows;

type
  THIGroupBox = class(THIWin)
   private
    procedure SetCaption(const Value:string);
   public

    constructor Create(Parent:PControl);
    procedure _work_doVisible(var _Data:TData; Index:word);
    property _prop_Caption:string write SetCaption;
    procedure _work_doCaption(var _Data:TData; Index:word);    
  end;

implementation

constructor THIGroupBox.Create(Parent:PControl);
begin
   inherited Create(Parent);
   Control := NewGroupbox(Parent,'GroupBox');
   Control.Font.Create;
      //Style := Style and not WS_CLIPSIBLINGS;
   Control.ExStyle := 0;
end;

procedure THIGroupBox.SetCaption;
begin
   Control.Caption := Value;
end;

procedure THIGroupBox._work_doVisible;
begin
   Control.Visible := ReadBool(_Data);
end;

procedure THIGroupBox._work_doCaption;
begin
   Control.Caption := ToString(_Data);
end;

end.
