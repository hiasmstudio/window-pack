unit hiGE_Scene;

interface

uses Windows,Kol,Share,Debug;

type
  THitFilter = array of boolean;
  PHitFilter = ^THitFilter;
  THIGE_Scene = class;
  TGE_Object = class
    public
      Scene:THIGE_Scene;
      X,Y,Z:real;
      kX,kY:real;
      Width,Height:integer;
      ID:integer;

      // padding
      Left:integer;
      Right:integer;
      Top:integer;
      Bottom:integer;
      
      HitMode:byte;
      flt:array of boolean;
      CFlt:integer;
      
      Dead:boolean;
      
      onHit:procedure(ID:integer; obj:TGE_Object; mx,my:boolean) of object;
      
      procedure Draw(DC:HDC); virtual;
      procedure Process; virtual;
      procedure Move(nX,nY:real; hit:boolean = false); virtual;
      function checkHit(obj:TGE_Object; _flt:PHitFilter; var rid:integer; var robj:TGE_Object):boolean; virtual;
  end;
  THIGE_Object = class(TDebug)
   protected
    FObj:TGE_Object;  
    FScene:THIGE_Scene;
    
    procedure SetScene(scene:THIGE_Scene); virtual;
   public
    _prop_Name:string;
    _prop_X:real;
    _prop_Y:real;
    _prop_Width:integer;
    _prop_Height:integer;
    _prop_kX:real;
    _prop_kY:real;
    _prop_Mode:byte;
    _prop_Filter:string;
    _prop_ID:integer;
    _prop_Left:integer;
    _prop_Right:integer;
    _prop_Top:integer;
    _prop_Bottom:integer;
    
    _event_onHitX:THI_Event; 
    _event_onHitY:THI_Event;
    
    destructor Destroy; override;
    function getInterfaceGESprite:TGE_Object;
    procedure _work_doKX(var _Data:TData; index:word);
    procedure _work_doKY(var _Data:TData; index:word);
    procedure _work_doDestroy(var _Data:TData; index:word);
    procedure _var_Handle(var _Data:TData; index:word);
    property _prop_GameScene:THIGE_Scene write SetScene;
    property GE_Object:TGE_Object read FObj;
  end; 
  THIGE_Scene = class(TDebug)
   private
   public
    Items:array of TGE_Object;
    Count:integer;
    
    OnSpriteDead:TEvents;
    
    _prop_Name:string;

    _data_Bitmap:THI_Event;
    _event_onDraw:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doDraw(var _Data:TData; Index:word);
    procedure _work_doProcess(var _Data:TData; Index:word);
    function getInterfaceGEScene:THIGE_Scene;
    
    procedure AddObject(obj:TGE_Object);
    function checkHit(flt:PHitFilter; obj:TGE_Object; var id:integer):TGE_Object;
  end;

var Sprite_GUID:integer;

implementation

procedure TGE_Object.Draw(DC:HDC);
begin

end;

procedure TGE_Object.Process;
begin
  Move(X + kX, Y + kY, true);
end;

procedure TGE_Object.Move;
var id:integer;
    obj:TGE_Object;
begin
  if not hit then
    begin
        X := nX;
        Y := nY;
        exit;
    end;
    
  case HitMode of
    0,1: 
      begin
        X := nX;
        Y := nY;
        if HitMode = 1 then
          begin
            obj := Scene.checkHit(@flt, self, id);
            if (obj <> nil)and Assigned(onHit) then
              begin
                onHit(id, obj, true, true);
                if Assigned(obj.onHit) and (self.id <= High(obj.flt)) and obj.flt[self.id] then
                  obj.onHit(self.id, self, true, true);
              end;
          end; 
      end;
    2:
      begin
        X := nX;
        obj := Scene.checkHit(@flt, self, id);
        if (obj <> nil)and Assigned(onHit) then
          onHit(id, obj, true, false);
        Y := nY;
        obj := Scene.checkHit(@flt, self, id);
        if (obj <> nil)and Assigned(onHit) then
          onHit(id, obj, false, true);
      end;    
   end; 
end;

function TGE_Object.checkHit;
begin
  if (id <= High(_flt^)) and _flt^[id] then
    if (X + Left > Obj.x + Obj.Width - Obj.Right)or(Y + Top > Obj.y + Obj.Height - Obj.Bottom)or(X + Width - Right < Obj.X + Obj.Left)or(Y + Height - Bottom < Obj.Y + Obj.Top) then
      Result := false
    else
      begin
        Result := true;
        rid := id;
        robj := self;
      end 
  else Result := false;
end;

//------------------------------------------------------------------------------

destructor THIGE_Object.Destroy; 
begin
  FObj.Destroy;
  inherited;
end;

function THIGE_Object.getInterfaceGESprite:TGE_Object;
begin
  Result := FObj;
end;

procedure THIGE_Object._work_doKX;
begin
  FObj.kx := ToReal(_Data);
end;

procedure THIGE_Object._work_doKY;
begin
  FObj.ky := ToReal(_Data);
end;

procedure THIGE_Object._work_doDestroy;
begin
  FObj.Dead := true;
end;

procedure THIGE_Object._var_Handle;
begin
  dtObject(_Data,Sprite_GUID,FObj);
end;

procedure THIGE_Object.SetScene(scene:THIGE_Scene);
var s:string;
    _id:integer;
begin
   if scene = nil then exit;
   
   FScene := scene;
   scene.AddObject(FObj);
   with FObj do
     begin
       X := _prop_X;
       Y := _prop_Y;
       Width := _prop_Width;
       Height := _prop_Height;
       kX := _prop_kX;
       kY := _prop_kY;
       HitMode := _prop_Mode;
       ID := _prop_ID;
       Left := _prop_Left;
       Right := _prop_Right;
       Top := _prop_Top;
       Bottom := _prop_Bottom;

       s := _prop_Filter + ',';
       CFlt := 0;
       while pos(',', s) > 0 do
         begin
           _id := str2int(GetTok(s, ',')); 
           if _id >= CFlt then 
             begin
               CFlt := _id+1;
               SetLength(Flt, CFlt);
             end;
           Flt[_id] := true;
         end;
     end; 
end;

//------------------------------------------------------------------------------

constructor THIGE_Scene.Create;
begin
   inherited;
   OnSpriteDead := TEvents.Create;
end;

destructor THIGE_Scene.Destroy;
begin
   OnSpriteDead.Destroy;
   inherited;
end;

function THIGE_Scene.getInterfaceGEScene:THIGE_Scene;
begin
   Result := self;
end;

procedure THIGE_Scene._work_doDraw;
var i:integer;
    dc:HDC;
    bmp:PBitmap;
begin
   bmp := ReadBitmap(_Data, _data_Bitmap);
   dc := bmp.Canvas.Handle;  
   for i := 0 to Count-1 do
     Items[i].Draw(DC);
   _hi_onEvent(_event_onDraw);
end;

procedure THIGE_Scene._work_doProcess;
var i,j:integer;
begin
   for i := 0 to Count-1 do
     if not Items[i].Dead then
       Items[i].Process; 

   for i := Count-1 downto 0 do
     if Items[i].Dead then
       begin
         OnSpriteDead.Event(Items[i]);
         for j := i to Count-2 do
           Items[j] := Items[j+1];
         dec(Count);
       end;    
end;

procedure THIGE_Scene.AddObject(obj:TGE_Object);
begin
  inc(Count);
  SetLength(Items, Count);
  Items[Count-1] := obj;
  obj.scene := self;
end;

function THIGE_Scene.checkHit;
var i:integer;
begin
   for i := 0 to Count-1 do
     if Items[i] <> obj then
        if Items[i].checkHit(obj, flt, id, result) then  
          exit;
   Result := nil;
end;

initialization
  GenGUID(Sprite_GUID);

end.
