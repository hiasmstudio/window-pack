unit hiGE_Background;

interface

uses Windows,Kol,Share,Debug,hiGE_Scene,hiGE_SpriteCollection;

type
  TGE_BackgroundObject = class(TGE_Object)
    public
      Back:PBitmap;
      procedure Draw(DC:HDC); override;
  end;

  THIGE_Background = class(THIGE_Object)
   private
    FSprites:THIGE_SpriteCollection;
    
    procedure SetSprites(sp:THIGE_SpriteCollection);
   public
    _prop_SpriteName:string;
    
    constructor Create;
    property _prop_Sprites:THIGE_SpriteCollection write SetSprites;
  end;

implementation

procedure TGE_BackgroundObject.Draw(DC:HDC);
var i,j:integer;
begin
   i := 0;
   while i < Width do
     begin
       j := 0;
       while j < Height do
         begin
           Back.Draw(DC, Round(x + i), Round(y + j));
           inc(j, Back.Height);
          end;
       inc(i, Back.Width);
     end; 
end; 

//------------------------------------------------------------------------------

constructor THIGE_Background.Create;
begin
  inherited;
  FObj := TGE_BackgroundObject.Create;
end;

procedure THIGE_Background.SetSprites;
begin
   if sp = nil then exit;
   
   FSprites := sp;
   TGE_BackgroundObject(FObj).Back := sp.BMPbyName[_prop_SpriteName];
end;

end.
