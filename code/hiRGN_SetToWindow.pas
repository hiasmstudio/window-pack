unit hiRGN_SetToWindow;

interface

uses Windows,Kol,Share,Debug;

 function GetRandomRgn(DC: HDC; Rgn: HRGN; Num: Integer): Integer; stdcall;

type
  THIRGN_SetToWindow = class(TDebug)
   private
    FRegion: HRGN;
   public
    _prop_ReDraw:boolean;
    _data_Handle:THI_Event;
    _data_Region:THI_Event;
    _event_onSetRegion:THI_Event;
    _event_onGetRegion:THI_Event;
    _event_onReset:THI_Event;

    destructor Destroy; override;
    procedure _work_doSetRegion(var _Data:TData; Index:word);
    procedure _work_doGetRegion(var _Data:TData; Index:word);
    procedure _work_doReset(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

function GetRandomRgn; external gdi32 name 'GetRandomRgn';

destructor THIRGN_SetToWindow.Destroy;
begin
   DeleteObject(FRegion);
   inherited;
end;

procedure THIRGN_SetToWindow._work_doSetRegion;
var h: integer;
    rgn,r: HRGN;
begin
    h := ReadInteger(_Data, _data_Handle);
    rgn := CreateRectRgn(0, 0, 0, 0);
    r := ReadInteger(_Data, _data_Region);
    CombineRgn(rgn,  r, 0, RGN_COPY); 
    SetWindowRgn(h, rgn, _prop_ReDraw);
    DeleteObject(rgn);
    _hi_onEvent(_event_onSetRegion);
end;

procedure THIRGN_SetToWindow._work_doGetRegion;
var h: HDC;
    rgn: HRGN;
    r: TRect;
    p: TPoint;
begin
    h := ReadInteger(_Data, _data_Handle);
    GetWindowRect(h, r);
    p := MakePoint(r.Left, r.Top);
    //OffsetRect(r, p.X, p.Y);
    DeleteObject(FRegion);
    FRegion := CreateRectRgn(0, 0, 0, 0);
    rgn := CreateRectRgn(0, 0, 0, 0);
    if integer(GetWindowRgn(h, rgn)) < 2 then
     begin
      DeleteObject(rgn);
      rgn := CreateRectRgn(r.Left, r.Top, r.Right, r.Bottom);
     end
    else OffsetRgn(rgn, r.Left, r.Top); 
    CombineRgn(FRegion,  rgn, 0, RGN_COPY); 
    _hi_onEvent(_event_onGetRegion, integer(FRegion));
    DeleteObject(rgn);
end;

procedure THIRGN_SetToWindow._work_doReset;
begin
    SetWindowRgn(ReadInteger(_Data, _data_Handle), 0, _prop_ReDraw);
    _hi_onEvent(_event_onReset);
end;

procedure THIRGN_SetToWindow._var_Result;
begin
    dtInteger(_Data, FRegion);
end;

end.
