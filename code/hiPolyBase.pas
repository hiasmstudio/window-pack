unit hiPolyBase;

interface

uses kol,hiEditPolyMulti;

type
 TClassPolyBase = class
   public
    Child,Base:THIEditPolyMulti;
//    ParentClass:TObject;
    ParentElement:TObject;
    
    constructor Create(_parent:pointer; _Control:PControl; _ParentClass:TObject);
 end; 

implementation

constructor TClassPolyBase.Create(_parent:pointer; _Control:PControl; _ParentClass:TObject);
begin
   inherited Create;
end;

end.