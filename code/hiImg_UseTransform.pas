unit hiImg_UseTransform;

interface

uses Windows,Kol,Share,Img_Draw;

type
  THIImg_UseTransform = class(THIImg)
   private
    mTransform: PTransform;
    e11,e12,e21,e22,eX,eY:real;

    function _Set(pDC:HDC;x1,y1,x2,y2:integer):boolean;
    procedure _Reset(pDC:HDC);
    function _GetRect(rect:TRect):TRect;
   public
    _prop_eM11:real;
    _prop_eM12:real;
    _prop_eM21:real;
    _prop_eM22:real;
    _prop_eDx:real;
    _prop_eDy:real;                
    
    _data_eM11:THI_Event;
    _data_eM12:THI_Event;
    _data_eM21:THI_Event;
    _data_eM22:THI_Event;
    _data_eDx:THI_Event;
    _data_eDy:THI_Event; 

    destructor Destroy; override;   
    procedure _var_Transform(var _Data:TData; Index:word);
  end;

implementation

destructor THIImg_UseTransform.Destroy;
begin
   if mTransform <> nil then dispose(mTransform);
   inherited Destroy;
end;

function THIImg_UseTransform._Set;
var mXFORM,nXFORM: XFORM;
begin
    FillChar(mXFORM, SizeOf(mXFORM), #0);
    mXFORM.eM11 := e11;
    mXFORM.eM12 := e12;
    mXFORM.eM21 := e21;
    mXFORM.eM22 := e22;
    mXFORM.eDx := eX;
    mXFORM.eDy := eY;

    SetGraphicsMode(pDC, GM_ADVANCED);
    SetWorldTransform(pDC, mXFORM);
    Result := False;                            //не измен€ютс€ кооднинаты
end;

function THIImg_UseTransform._Reset;
var mXFORM: XFORM;
begin
    FillChar(mXFORM, SizeOf(mXFORM), #0);
    mXFORM.eM11 := 1;
    mXFORM.eM22 := 1;
    SetWorldTransform(pDC, mXFORM);
    SetGraphicsMode(pDC, GM_COMPATIBLE);
end;

function THIImg_UseTransform._GetRect;
begin
    OffsetRect(rect,0,0);
    Result := (rect);
end;

procedure THIImg_UseTransform._var_Transform;
begin
   e11 := ReadReal(_Data, _data_eM11,_prop_eM11);
   e12 := ReadReal(_Data, _data_eM12,_prop_eM12);
   e21 := ReadReal(_Data, _data_eM21,_prop_eM21);
   e22 := ReadReal(_Data, _data_eM22,_prop_eM22);
   eX := ReadReal(_Data, _data_eDx,_prop_eDx);
   eY := ReadReal(_Data, _data_eDy,_prop_eDy);
   if mTransform = nil then
    mTransform := CreateTransform(_Set, _Reset, _GetRect);
   dtObject(_Data, TRANSFORM_GUID, mTransform);
end;

end.