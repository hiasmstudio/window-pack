unit hiImg_SetTransform;

interface

uses Windows,Kol,Share,Img_Draw;

{$I share.inc}

type
  THIImg_SetTransform = class(THIDraw2PR)
   private

   public
    _prop_Reset: boolean;
    
    _event_onSetTransform:THI_Event;
    _event_onResetTransform:THI_Event;

    procedure _work_doSetTransform(var _Data:TData; Index:word);
    procedure _work_doResetTransform(var _Data:TData; Index:word);    
  end;

implementation

procedure THIImg_SetTransform._work_doSetTransform;
var dt: TData;
    mTransform: PTransform;
begin
    dt := _Data;
TRY
    if not ImgGetDC(_Data) then exit;
    ReadXY(_Data);
    ImgNewSizeDC;
    mTransform := ReadObject(_Data, _data_Transform, TRANSFORM_GUID);
    if mTransform <> nil then mTransform._Set(pDC,x1,y1,x2,y2);
FINALLY
   ImgReleaseDC;
   _hi_CreateEvent(_Data,@_event_onSetTransform, dt);
END;
end;

procedure THIImg_SetTransform._work_doResetTransform;
var dt: TData;
    mTransform: PTransform;
begin
   dt := _Data;
TRY
    if not ImgGetDC(_Data) then exit;
    ReadXY(_Data);
    ImgNewSizeDC;
    mTransform := ReadObject(_Data, _data_Transform, TRANSFORM_GUID);
    if mTransform <> nil then mTransform._Reset(pDC);
FINALLY
   ImgReleaseDC;
   _hi_CreateEvent(_Data,@_event_onResetTransform, dt);
END;
end;

end.