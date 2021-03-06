unit hiImg_UseSkew;

interface

uses Windows,Kol,Share,Debug, Img_Draw;

type
  THIImg_UseSkew = class(TDebug)
   private
    mTransform,nTransform: PTransform;
    vx,vy: real;

    function _Set(pDC:HDC;x1,y1,x2,y2: integer):boolean;
    procedure _Reset(pDC:HDC);
    function _GetRect(rect:TRect):TRect;
   public
    _prop_X:real;
    _prop_Y:real;     
    _prop_Mode:integer;
    
    _data_X:THI_Event;
    _data_Y:THI_Event;    
    _data_AddTransform:THI_Event;
    
    destructor Destroy; override;
    procedure _work_doMode(var _Data: TData; Index: Word);
    procedure _var_Transform(var _Data:TData; Index:word);
  end;

implementation

destructor THIImg_UseSkew.Destroy;
begin
   if mTransform <> nil then dispose(mTransform);
   inherited Destroy;
end;

function THIImg_UseSkew._Set;
var mXFORM,nXFORM: XFORM;
begin
    FillChar(mXFORM, SizeOf(mXFORM), #0);
    mXFORM.eM12 := vy;
    mXFORM.eM21 := vx;
    mXFORM.eM11 := 1;
    mXFORM.eM22 := 1;
    case _prop_Mode of
     0: begin
         mXFORM.eDx := vx * (-y1 + (y1 - y2) / 2);
         mXFORM.eDy := vy * (-x1 + (x1 - x2) / 2);
        end;
     1: begin
         mXFORM.eDx := vx * -y1;
         mXFORM.eDy := vy * -x1;
        end;  
     2: begin
         mXFORM.eDx := vx * -y1;
         mXFORM.eDy := vy * -x2;
        end;  
     3: begin
         mXFORM.eDx := vx * -y2;
         mXFORM.eDy := vy * -x2;
        end;  
     4: begin
         mXFORM.eDx := vx * -y2;
         mXFORM.eDy := vy * -x1;
        end;  
    end;    
    if nTransform = nil then
     begin
      SetGraphicsMode(pDC, GM_ADVANCED);
      SetWorldTransform(pDC, mXFORM);
      Result := False;                            //�� �������� ����������
     end
    else 
     begin
      Result := nTransform._Set(pDC,x1,y1,x2,y2); //��������� �������������
      GetWorldTransform(pDC,nXFORM);              //�������� ������������� �������������
      CombineTransform(mXFORM,nXFORM,mXFORM);     //����������� ���������� ������������� � �������
      SetWorldTransform(pDC, mXFORM);             //������������� ��������������� �������������
     end;
end;

procedure THIImg_UseSkew._Reset;
var mXFORM: XFORM;
begin
    FillChar(mXFORM, SizeOf(mXFORM), #0);
    mXFORM.eM11 := 1;
    mXFORM.eM22 := 1;
    SetWorldTransform(pDC, mXFORM);
    SetViewportOrgEx(pDC, 0, 0, nil);
    SetGraphicsMode(pDC, GM_COMPATIBLE);
end;

function THIImg_UseSkew._GetRect;
begin
    Result := (nTransform._GetRect(rect));
end;

procedure  THIImg_UseSkew._work_doMode;
begin
    _prop_Mode := ToInteger(_Data);
    if (_prop_Mode < 0) or (_prop_Mode > 4) then
     _prop_Mode := 0;
end;

procedure THIImg_UseSkew._var_Transform;
begin
   nTransform := ReadObject(_Data, _data_AddTransform, TRANSFORM_GUID);
   vx := ReadReal(_Data, _data_X,_prop_X);
   vy := ReadReal(_Data, _data_Y,_prop_Y);
   if mTransform = nil then
    mTransform := CreateTransform(_Set, _Reset, _GetRect);
   dtObject(_Data, TRANSFORM_GUID, mTransform);
end;

end.