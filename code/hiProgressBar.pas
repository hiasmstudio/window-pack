unit hiProgressBar;

interface

uses Kol,Share,Win,Windows;

type
  THIProgressBar = class(THIWin)
   private
   public
    _prop_Kind:byte;
    _prop_Smooth:boolean;
    _prop_Max:integer;
    _prop_ProgressColor:TColor;

    procedure Init; override;
    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _work_doMax(var _Data:TData; Index:word);
    procedure _var_Position(var _Data:TData; Index:word);
  end;

implementation

procedure THIProgressBar.Init;
var fl:TProgressbarOptions;
begin
   fl := [];
   if _prop_Kind = 1 then
    fl := [pboVertical];
   if _prop_Smooth then
    include(fl,pboSmooth);
   Control := NewProgressbarEx(FParent,Fl);
   Control.MaxProgress := _prop_Max;
   Control.ProgressColor := _prop_ProgressColor;
   Control.Transparent := false;
   if _prop_Ctl3D = 1 then
     Control.ExStyle := 0;
   inherited;
end;

procedure THIProgressBar._work_doPosition;
begin
   Control.Progress := ReadInteger(_data,null,0);
end;

procedure THIProgressBar._work_doMax;
begin
   Control.MaxProgress := ReadInteger(_data,null,0);
end;

procedure THIProgressBar._var_Position;
begin
  dtInteger(_Data,Control.Progress);
end;

end.
