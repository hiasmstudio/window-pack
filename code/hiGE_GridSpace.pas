unit hiGE_GridSpace;

interface

uses Windows,Kol,Share,Debug,hiGE_Scene,hiGE_SpriteCollection;

type
  TOnSpriteRequre = function(id:integer):PBitmap of object;
  TGE_GridItem = class(TGE_Object)
    public
      sprite:PBitmap;
  end; 
  TGSMatrix = array[0..0] of TGE_GridItem; 
  PGSMatrix = ^TGSMatrix;
  TGE_GridSpaceObject = class(TGE_Object)
    private
    public
      Matrix:PGSMatrix;
      onSpriteRequre:TOnSpriteRequre;
      SizeX,SizeY:integer;
      mw,mh:integer;
      
      destructor Destroy; override;
      procedure Draw(DC:HDC); override;
      function checkHit(obj:TGE_Object; _flt:PHitFilter; var rid:integer; var robj:TGE_Object):boolean; override;
      procedure Save(const FileName:string);
      procedure Load(const FileName:string);
      procedure SetCell(cx,cy,cid:integer);
      function GetCell(cx,cy:integer):integer;
  end;
  
  THIGE_GridSpace = class(THIGE_Object)
   private
    MObj:PMatrix;
    function OnSpriteRequre(id:integer):PBitmap;

    procedure _SetSize(x,y:integer);
    procedure _Set(x,y:integer; var Val:TData);
    function _Get(x,y:integer):TData;

    function _R:integer;
    function _C:integer;
   public
    _prop_FileName:string;
    _prop_Sprites:THIGE_SpriteCollection;
    _prop_SpriteList:PStrListEx;

    _data_FileName:THI_Event;
    _event_onLoad:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doSave(var _Data:TData; Index:word);
    procedure _work_doSetCell(var _Data:TData; Index:word);
    procedure _var_Cells(var _Data:TData; Index:word);
  end;

implementation

destructor TGE_GridSpaceObject.Destroy; 
begin
   if Matrix <> nil then FreeMem(Matrix);
   inherited;
end;

procedure TGE_GridSpaceObject.Draw(DC:HDC);
var i,j,_x,_y:integer;
    bmp:PBitmap;
begin
   _x := Round(x);
   _y := Round(y);
   for i := 0 to mh-1 do
     for j := 0 to mw-1 do
       begin
         bmp := Matrix^[i*mw + j].sprite; 
         if bmp <> nil then
           bmp.Draw(DC, _X + j*SizeX, _Y + i*SizeY);
       end;
end;

function TGE_GridSpaceObject.checkHit;
var i,j,_id,_x,_y:integer;
begin      
   for i := 0 to mh-1 do
     for j := 0 to mw-1 do
       begin
         _id := Matrix^[i*mw + j].id; 
         if _Flt^[_id] then
           begin
             _x := Round(X + j*SizeX);
             _y := Round(Y + i*SizeY);
             if not( (_x > Obj.x + Obj.Width - Obj.Right)or(_y > Obj.y + Obj.Height - Obj.Bottom)or(_x + SizeX < Obj.X + Obj.Left)or(_y + SizeY < Obj.Y + Obj.Top) ) then
               begin
                 Result := true;
                 rid := _id;
                 robj := Matrix^[i*mw + j]; 
                 exit;
               end;
           end;
       end;
   Result := false;
end;

procedure TGE_GridSpaceObject.Save(const FileName:string);
begin

end;

procedure TGE_GridSpaceObject.Load(const FileName:string); 
var //fs:PStream;
    lst:PStrList;
    i,j:integer;
    s:string;
begin
  if copy(FileName, length(FileName)-2, 3) = 'txt' then
    begin
      lst := NewStrList;
      lst.LoadFromFile(GetStartDir + FileName);
      mw := length(lst.Items[0]);
      mh := lst.Count;
      GetMem(Matrix, mh*mw*sizeof(TGE_Object));
      FillChar(Matrix^, mh*mw*sizeof(TGE_Object), 0);
      for i := 0 to lst.Count-1 do
        begin
          s := lst.Items[i];
          for j := 1 to mw do
            SetCell(j - 1, i, ord(s[j]) - ord('0'));
        end;
      lst.free;  
    end
  else
    begin 
      //fs := NewReadFileStream(FileName);
      //GetMem(Matrix, fs.Size);
      //fs.read(Matrix^, fs.Size);
      //fs.Free;
    end;
end;

procedure TGE_GridSpaceObject.SetCell;
var obj:TGE_GridItem;
    m:^TGE_GridItem;
begin
   m := @Matrix[cy*mw + cx];
   if m^ <> nil then
     m^.Destroy; 
   obj := TGE_GridItem.Create;
   obj.scene := scene;
   obj.X := cx;
   obj.Y := cy;
   obj.id := cid;
   obj.sprite := onSpriteRequre(cid); 
   m^ := obj; 
   if(SizeX = 0)and(obj.sprite <> nil)then
      begin
         SizeX := obj.sprite.Width;
         SizeY := obj.sprite.Height; 
      end;
end;

function TGE_GridSpaceObject.GetCell;
begin          
   if(cy >= 0)and(cy < mh)and(cx >= 0)and(cx < mw)then    
      Result := Matrix[cy*mw + cx].id
   else Result := 0;
end;

//------------------------------------------------------------------------------

constructor THIGE_GridSpace.Create;
begin
  inherited;
  FObj := TGE_GridSpaceObject.Create;
  TGE_GridSpaceObject(FObj).OnSpriteRequre := OnSpriteRequre;
end;

destructor THIGE_GridSpace.Destroy;
begin         
   if MObj <> nil then Dispose(MObj);
   inherited;
end;

function THIGE_GridSpace.OnSpriteRequre(id:integer):PBitmap;
var i:integer;
begin
  i := _prop_SpriteList.indexOfObj(pointer(id));
  if i = -1 then
    Result := nil
  else
    Result := _prop_Sprites.BMPbyName[_prop_SpriteList.Items[i]]; 
end;

procedure THIGE_GridSpace._work_doLoad;
begin
   TGE_GridSpaceObject(FObj).Load(ReadString(_Data, _data_FileName, _prop_FileName));
   _hi_onEvent(_event_onLoad);
end;

procedure THIGE_GridSpace._work_doSave;
begin
   TGE_GridSpaceObject(FObj).Save(ReadString(_Data, _data_FileName, _prop_FileName));
end;

procedure THIGE_GridSpace._work_doSetCell;
var x,y,id:integer;
    e:THI_Event;
begin
   e.event := nil;
   x := ReadInteger(_Data, e);
   y := ReadInteger(_Data, e);
   id := ReadInteger(_Data, e);
   TGE_GridSpaceObject(FObj).SetCell(x,y,id);
end;

procedure THIGE_GridSpace._SetSize(x,y:integer);
begin
  // do nothing
end;

procedure THIGE_GridSpace._Set(x,y:integer; var Val:TData);
begin
   TGE_GridSpaceObject(FObj).SetCell(x,y,ToInteger(val));
end;

function THIGE_GridSpace._Get(x,y:integer):TData;
begin
   dtInteger(Result, TGE_GridSpaceObject(FObj).GetCell(x,y));
end;

function THIGE_GridSpace._R:integer;
begin
   Result := TGE_GridSpaceObject(FObj).mh;
end;                                     

function THIGE_GridSpace._C:integer;
begin
   Result := TGE_GridSpaceObject(FObj).mw;
end;

procedure THIGE_GridSpace._var_Cells;
begin
   if MObj = nil then
     begin
       new(MObj);
       MObj._SetSize := _SetSize;
       MObj._Set := _Set;
       MObj._Get := _Get;
       MObj._Rows := _R;
       MObj._Cols := _C;
     end;
   dtMatrix(_Data,MObj);
end;

end.
