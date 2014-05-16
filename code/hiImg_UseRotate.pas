unit hiImg_UseRotate;

interface

uses Windows,Kol,Share,Img_Draw;

type
  THIImg_UseRotate = class(THIImg)
   private
    mTransform,nTransform: PTransform;
    a,x,y: integer;
    function _Set(pDC:HDC;x1,y1,x2,y2:integer):boolean;
    procedure _Reset(pDC:HDC);
    function _GetRect(rect:TRect):TRect;
   public
    _prop_Angle:integer;
    _prop_Mode:byte;
    
    _data_Angle:THI_Event;
    _data_AddTransform:THI_Event;
    
    destructor Destroy; override;
    procedure _work_doMode(var _Data: TData; Index: Word);
    procedure _var_Transform(var _Data:TData; Index:word);
  end;

implementation

destructor THIImg_UseRotate.Destroy;
begin
   if mTransform <> nil then dispose(mTransform);
   inherited Destroy;
end;

function THIImg_UseRotate._Set;
var mXFORM,nXFORM: XFORM;
begin
    FillChar(mXFORM, SizeOf(mXFORM), #0);
    mXFORM.eM11 := Cos(-a/180*pi);
    mXFORM.eM12 := -Sin(-a/180*pi);
    mXFORM.eM21 := -mXFORM.eM12;
    mXFORM.eM22 := mXFORM.eM11;
    case _prop_Mode of
     0: begin //центр
         x := x1 + (x2 - x1) div 2;
         y := y1 + (y2 - y1) div 2;
        end; 
     1: begin  //левый верхний угол
         x := x1;
         y := y1;
        end;
     2: begin //правый верхний угол
         x := x1 + (x2 - x1);
         y := y1;
        end;  
     3: begin //правый нижний угол
         x := x1 + (x2 - x1);
         y := y1 + (y2 - y1);
        end;  
     4: begin //левый нижний угол
         x := x1;
         y := y1 + (y2 - y1);
        end;  
    end;
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
    Result := True;                             //необходимо изменить кооднинаты
end;

procedure THIImg_UseRotate._Reset;
var mXFORM: XFORM;
begin
    FillChar(mXFORM, SizeOf(mXFORM), #0);
    mXFORM.eM11 := 1;
    mXFORM.eM22 := 1;
    SetWorldTransform(pDC, mXFORM);
    SetViewportOrgEx(pDC, 0, 0, nil);
    SetGraphicsMode(pDC, GM_COMPATIBLE);
end;

function THIImg_UseRotate._GetRect;
begin
    OffsetRect(rect,-x,-y);
    Result := (rect);
end;

procedure  THIImg_UseRotate._work_doMode;
begin
    _prop_Mode := ToInteger(_Data);
    if (_prop_Mode < 0) or (_prop_Mode > 4) then
     _prop_Mode := 0;
end;

procedure THIImg_UseRotate._var_Transform;
begin
   nTransform := ReadObject(_Data, _data_AddTransform, TRANSFORM_GUID);
   a := ReadInteger(_Data, _data_Angle,_prop_Angle);
   if mTransform = nil then
    mTransform := CreateTransform(_Set, _Reset, _GetRect);
   dtObject(_Data, TRANSFORM_GUID, mTransform);
end;

end.