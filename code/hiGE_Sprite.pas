unit hiGE_Sprite;

interface

uses Windows,Kol,Share,Debug,hiGE_Scene,hiGE_SpriteCollection;

type
  TGE_SpriteObject = class(TGE_Object)
    private 
      FCurFrame:integer;
      FTicks:integer;
    public
      Sprite:PBitmap;      
      Mask:PBitmap;
      Frames:integer;
      StartFrame:integer;
      Speed:integer;
      TimeLive:integer;
      
      procedure Draw(DC:HDC); override;
      procedure Process; override;
      procedure Init;
  end;
  THIGE_Sprite = class(THIGE_Object)
   private
    FSprites:THIGE_SpriteCollection;
    
    procedure SetSprites(sp:THIGE_SpriteCollection);
    procedure _onHit(ID:integer; obj:TGE_Object; mx,my:boolean);
   public
    _prop_SpriteName:string;
    _prop_Frames:integer;
    _prop_StartFrame:integer;
    _prop_Speed:integer;
    _prop_TimeLive:integer;
    
    constructor Create; overload;
    constructor Create(Parent:PControl); overload; 
    property _prop_Sprites:THIGE_SpriteCollection write SetSprites;
  end;

implementation

procedure TGE_SpriteObject.Draw(DC:HDC);
var f,_x,_y:integer;
begin
   if Speed > 0 then
     f := FCurFrame*Width  
   else
     f := StartFrame*Width;
   
   _x := Round(X);  
   _y := Round(Y); 
   BitBlt(DC, _x, _y, Width, Height, Mask.Canvas.Handle, f, 0, SRCAND);  
   BitBlt(DC, _x, _y, Width, Height, Sprite.Canvas.Handle, f, 0, SRCPAINT);  
end;

procedure TGE_SpriteObject.Process;
begin
   inherited;
   if (Speed > 0)or(TimeLive > 0) then
     inc(FTicks);
     
   if (Speed > 0) and (FTicks mod Speed = 0) then 
     begin
       inc(FCurFrame);
       if FCurFrame - StartFrame = Frames then
         FCurFrame := StartFrame;
     end;
     
   if (TimeLive > 0) and (TimeLive = FTicks)then
     Dead := true;  
end;

procedure TGE_SpriteObject.Init;
begin
   FCurFrame := StartFrame;
end;

//------------------------------------------------------------------------------

constructor THIGE_Sprite.Create;
begin
  inherited;
  FObj := TGE_SpriteObject.Create;
  FObj.onHit := _onHit; 
end;

constructor THIGE_Sprite.Create(Parent:PControl);
begin
   Create;
end;

procedure THIGE_Sprite._onHit;
var
    dt,dto:TData;
    ff:PData;
begin
  dtInteger(dt, id);
  dtObject(dto, Sprite_GUID, obj);
  AddMTData(@dt, @dto, ff);

  if mx then
    _hi_onEvent(_event_onHitX, dt);
  if my then
    _hi_onEvent(_event_onHitY, dt);
end;

procedure THIGE_Sprite.SetSprites;
begin
   if sp = nil then exit;
   
   FSprites := sp;
   with TGE_SpriteObject(FObj) do
     begin
       Sprite := sp.BMPbyName[_prop_SpriteName];
       Mask := sp.MaskbyName[_prop_SpriteName];
       Frames := _prop_Frames;
       StartFrame := _prop_StartFrame;
       Speed := _prop_Speed;
       TimeLive := _prop_TimeLive;
       Init;
     end;
end;

end.
