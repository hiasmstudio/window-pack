unit hiImg_UseOffset;

interface

uses Windows,Kol,Share,Debug, Img_Draw;

type
  THIImg_UseOffset = class(TDebug)
   private
    mTransform,nTransform: PTransform;
    vx, vy: real;

    function _Set(pDC:HDC;x1,y1,x2,y2: integer):boolean;
    procedure _Reset(pDC:HDC);
    function _GetRect(rect:TRect):TRect;
   public
    _prop_X:real;
    _prop_Y:real;     
    
    _data_X:THI_Event;
    _data_Y:THI_Event;    
    _data_AddTransform:THI_Event;

    destructor Destroy; override;   
    procedure _var_Transform(var _Data:TData; Index:word);
  end;

implementation

destructor THIImg_UseOffset.Destroy;
begin
   if mTransform <> nil then dispose(mTransform);
   inherited Destroy;
end;

function THIImg_UseOffset._Set;
var mXFORM,nXFORM: XFORM;
begin
    FillChar(mXFORM, SizeOf(mXFORM), #0);
    mXFORM.eM11 := 1;
    mXFORM.eM22 := 1;
    mXFORM.eDx := vx;
    mXFORM.eDy := vy;
    if nTransform = nil then
     begin
      SetGraphicsMode(pDC, GM_ADVANCED);
      SetWorldTransform(pDC, mXFORM);
      Result := False;                            //не измен€ть координаты
     end
    else 
     begin
      Result := nTransform._Set(pDC,x1,y1,x2,y2); //измен€ютс€ координаты дл€ следующей трансформации
      GetWorldTransform(pDC,nXFORM);              //получает установленнцю трансформацию
      SetGraphicsMode(pDC, GM_ADVANCED);
      CombineTransform(mXFORM,nXFORM,mXFORM);     //комбинирует полученную трансформацию с текущей
      SetWorldTransform(pDC, mXFORM);             //устанавливает скомбинированую трансформацию
     end;
end;

procedure THIImg_UseOffset._Reset;
var mXFORM: XFORM;
begin
    FillChar(mXFORM, SizeOf(mXFORM), #0);
    mXFORM.eM11 := 1;
    mXFORM.eM22 := 1;
    SetWorldTransform(pDC, mXFORM);
    SetViewportOrgEx(pDC, 0, 0, nil);
    SetGraphicsMode(pDC, GM_COMPATIBLE);
end;

function THIImg_UseOffset._GetRect;
begin
    Result := (nTransform._GetRect(rect));
end;

procedure THIImg_UseOffset._var_Transform;
begin
   nTransform := ReadObject(_Data, _data_AddTransform, TRANSFORM_GUID);
   vx := ReadReal(_Data, _data_X,_prop_X);
   vy := ReadReal(_Data, _data_Y,_prop_Y);
   if mTransform = nil then
    mTransform := CreateTransform(_Set, _Reset, _GetRect);
   dtObject(_Data, TRANSFORM_GUID, mTransform);
end;

end.