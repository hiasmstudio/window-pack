unit hiGE_SpriteArray;

interface

uses Kol,Share,Debug,hiPolymorphMulti,hiGE_Scene;

type
 THIGE_SpriteArray = class(THIPolymorphMulti)
   private
     FScene:THIGE_Scene;
     
     procedure SetScene(value:THIGE_Scene);
     procedure _OnSpriteDead(param:pointer);
   public
     destructor Destroy; override;
     property _prop_GameScene:THIGE_Scene write SetScene;
 end;

implementation

uses hiEditPolyMulti,hiPolyBase;

destructor THIGE_SpriteArray.Destroy;
begin
   FScene.OnSpriteDead.Remove(_OnSpriteDead);
   inherited;
end;

procedure THIGE_SpriteArray._OnSpriteDead(param:pointer);
var i:integer;
    dt:TData;
begin
   for i := 0 to FChilds.Count-1 do
     if THIGE_Object(TClassPolyBase(THIEditPolyMulti(pointer(FChilds.Objects[i])).MainClass).ParentElement).GE_Object = param then
       begin
         dtInteger(dt, i);
         Delete(dt, 0);
         exit;
       end;
end;

procedure THIGE_SpriteArray.SetScene(value:THIGE_Scene);
begin
   FScene := value;
   FScene.OnSpriteDead.Add(_OnSpriteDead);
end;

end.
