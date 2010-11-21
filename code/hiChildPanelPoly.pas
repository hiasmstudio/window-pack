unit hiChildPanelPoly;

interface

uses hiPolyMorphMulti;

type
 THIChildPanelPoly = class(THIPolyMorphMulti)
   public
     _prop_Name:string;
     
     function getInterfacePolyPanel:THIPolyMorphMulti;
 end;

implementation

function THIChildPanelPoly.getInterfacePolyPanel:THIPolyMorphMulti;
begin
   Result := self;
end;

end.