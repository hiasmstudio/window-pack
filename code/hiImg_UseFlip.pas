unit hiImg_UseFlip;

interface

uses Windows,Kol,Share,Debug, Img_Draw;

type
  THIImg_UseFlip = class(TDebug)
   private
    mTransform,nTransform: PTransform;
    x,y: integer;
    
    function _Set(pDC:HDC;x1,y1,x2,y2: integer):boolean;
    procedure _Reset(pDC:HDC);
    function _GetRect(rect:TRect):TRect;
   public
    _prop_Mode:integer;
    _data_AddTransform:THI_Event;
   
    destructor Destroy; override;
    procedure _work_doMode(var _Data: TData; Index: Word);
    procedure _var_Transform(var _Data:TData; Index:word);
  end;

implementation

destructor THIImg_UseFlip.Destroy;
begin
   if mTransform <> nil then dispose(mTransform);
   inherited Destroy;
end;

function THIImg_UseFlip._Set;
var mXFORM,nXFORM: XFORM;
begin
    FillChar(mXFORM, SizeOf(mXFORM), #0);
    case _prop_Mode of
     0: begin     // горизонтальное отражение
         mXFORM.eM11 := -1;
         mXFORM.eM22 := 1;
         end;
     1: begin    // вертикальное отражение
         mXFORM.eM11 := 1;
         mXFORM.eM22 := -1;
        end;
     2: begin    // горизонтальное и вертикальное отражение
         mXFORM.eM11 := -1;
         mXFORM.eM22 := -1;
        end;
    end;
    x := x1 + (x2 - x1) div 2;
    y := y1 + (y2 - y1) div 2;
    if nTransform = nil then
     begin
      SetViewportOrgEx(pDC, x, y, nil);
      SetGraphicsMode(pDC, GM_ADVANCED);
      SetWorldTransform(pDC, mXFORM);
     end
    else 
     begin
      nTransform._Set(pDC,x1-x,y1-y,x2-x,y2-y); //измен€ютс€ координаты дл€ следующей трансформации
      GetWorldTransform(pDC,nXFORM);            //получает установленнцю трансформацию
      SetViewportOrgEx(pDC, x, y, nil);
      CombineTransform(mXFORM,nXFORM,mXFORM);   //комбинирует полученную трансформацию с текущей
      SetWorldTransform(pDC, mXFORM);           //устанавливает скомбинированую трансформацию
     end;
    Result := True;                             //необходимо изменить координаты
end;

procedure THIImg_UseFlip._Reset;
var mXFORM: XFORM;
begin
    FillChar(mXFORM, SizeOf(mXFORM), #0);
    mXFORM.eM11 := 1;
    mXFORM.eM22 := 1;
    SetWorldTransform(pDC, mXFORM);
    SetViewportOrgEx(pDC, 0, 0, nil);
    SetGraphicsMode(pDC, GM_COMPATIBLE);
end;

function THIImg_UseFlip._GetRect;
begin
    OffsetRect(rect,-x,-y);
    Result := (rect);
end;

procedure  THIImg_UseFlip._work_doMode;
begin
    _prop_Mode := ToInteger(_Data);
    if (_prop_Mode < 0) or (_prop_Mode > 2) then
     _prop_Mode := 0;
end;

procedure THIImg_UseFlip._var_Transform;
begin
   nTransform := ReadObject(_Data, _data_AddTransform, TRANSFORM_GUID);
   if mTransform = nil then
    mTransform := CreateTransform(_Set, _Reset, _GetRect);
   dtObject(_Data, TRANSFORM_GUID, mTransform);
end;

end.