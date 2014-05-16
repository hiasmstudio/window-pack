unit hiImg_Point;

interface

uses Windows,Kol,Share,Img_Draw;

type
  THIImg_Point = class(THIDraw2P)
   private
    FMatr:PMatrix;
    procedure _Set(x,y:integer; var Val:TData);
    function _Get(x,y:integer):TData;
    function _Rows:integer;
    function _Cols:integer;
   public
    _prop_Size: integer;
    _data_Size: THI_Event;
    procedure _var_Pixels(var _Data:TData; Index:word);
    procedure _work_doDraw(var _Data:TData; Index:word);
  end;

implementation

procedure THIImg_Point._work_doDraw;
var   dt: TData;
      pen: HPEN;
      mTransform: PTransform;
begin
   dt := _Data;
TRY
   if not ImgGetDC(_Data) then exit;
   ReadXY(_Data);
   ImgNewSizeDC;
   pen := CreatePen(PS_SOLID, Round((fScale.x + fScale.y) * ReadInteger(_Data,_data_Size,_prop_Size)/2), Color2RGB(ReadInteger(_Data,_data_Color,_prop_Color)));
   SelectObject(pDC,Pen);
   mTransform := ReadObject(_Data, _data_Transform, TRANSFORM_GUID);
   if mTransform <> nil then
    if mTransform._Set(pDC,x1,y1,x1,y1) then  //если необходимо изменить координаты (rotate, flip)
     PRect(@x1)^ := mTransform._GetRect(MakeRect(x1,y1,x1,y1));
   MoveToEx(pDC, x1, y1, nil);
   LineTo(pDC, x1, y1);
   DeleteObject(Pen);
   if mTransform <> nil then mTransform._Reset(pDC);
FINALLY
   ImgReleaseDC;
   _hi_CreateEvent(_Data,@_event_onDraw,dt);
END;
end;

procedure THIImg_Point._Set;
var   pen: HPEN;
begin
TRY
   if not ImgGetDC(Val) then exit;
   x := Round(x * fScale.x);
   y := Round(y * fScale.y);   
   pen := CreatePen(PS_SOLID, Round((fScale.x + fScale.y)/2), Color2RGB(ReadInteger(Val,_data_Color,_prop_Color)));
   SelectObject(pDC,Pen);
   MoveToEx(pDC, x, y, nil);
   LineTo(pDC, x, y);
   DeleteObject(Pen);
FINALLY
   ImgReleaseDC;
END;
end;

function THIImg_Point._Get;
var   dt: TData;
begin
   dtNull(dt);
   dtInteger(Result,0);
TRY
   if not ImgGetDC(dt) then exit;
   x := Round(x * fScale.x);
   y := Round(y * fScale.y);
   dtInteger(Result, GetPixel(pDC, x, y));
FINALLY
   ImgReleaseDC;
END;
end;

function THIImg_Point._Rows;
var   ARect:trect;
      dt: TData;
begin
   dtNull(dt);
   Result := 0;
TRY
   if not ImgGetDC(dt) then exit;
   GetClientRect(pDC, ARect);
   Result := ARect.Bottom - ARect.Top;
FINALLY
   ImgReleaseDC;
END;
end;

function THIImg_Point._Cols;
var   ARect:trect;
      dt: TData;
begin
   dtNull(dt);
   Result := 0;
TRY
   if not ImgGetDC(dt) then exit;
   GetClientRect(pDC, ARect);
   Result :=  ARect.Right - ARect.Left;
FINALLY
   ImgReleaseDC;
END;
end;

procedure THIImg_Point._var_Pixels(var _Data:TData; Index:word);
begin
    if FMatr = nil then
      FMatr := CreateMatrix(_Set,_Get,_Cols,_Rows);
    dtMatrix(_data,FMatr);
end;

end.
