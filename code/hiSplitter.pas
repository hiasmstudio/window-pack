unit hiSplitter;

interface

uses Kol,Share,Win,Windows;

type
  THISplitter = class(THIWin)
   private
   public
    _prop_ResizeStyle:byte;
    _prop_Beveled:byte;

    procedure Init; override;
  end;

implementation

procedure THISplitter.Init;
begin
   Control := NewSplitter(FParent,0,0);
   inherited;

   if _prop_Beveled = 1 then
    //Control.Style := Control.Style and not SS_SUNKEN and not WS_BORDER
    Control.ExStyle := 0;
   //else Control.Style := Control.Style or SS_SUNKEN;

   if _prop_Align in [caTop,caBottom] then
     Control.Cursor :=  crSizeNS
   else Control.Cursor :=  crSizeWE;
end;

end.
