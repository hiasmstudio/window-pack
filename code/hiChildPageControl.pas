unit hiChildPageControl;

interface

uses Kol,Share,hiMultiElement,Windows;

type
 THIChildPageControl = class(THIMultiElement)
   private
   public
     constructor Create(Control:PControl);
 end;

implementation

constructor THIChildPageControl.Create;
begin
   inherited Create;
   FControl := Control;
end;

end.