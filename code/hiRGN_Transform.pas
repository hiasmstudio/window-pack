unit hiRGN_Transform;

interface

uses Windows,Kol,Share,Debug;

type
  THIRGN_Transform = class(TDebug)
   private
    FRegion:HRGN;
   public
    _prop_Type:integer;
    _prop_X:real;
    _prop_Y:real;    
    _prop_Mode:byte;
    
    _data_X:THI_Event;
    _data_Y:THI_Event;
    _data_Region:THI_Event;
    _event_onTransform:THI_Event;

    destructor Destroy; override;
    procedure _work_doTransform(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doSetTransform(var _Data:TData; Index:word);
    procedure _work_doType(var _Data:TData; Index:word);
    procedure _work_doMode(var _Data: TData; Index: Word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

destructor THIRGN_Transform.Destroy;
begin
    DeleteObject(FRegion);
    inherited;
end;

procedure THIRGN_Transform._work_doTransform;
var r: TRect;
    rgn: HRGN;
    sx, sy: real;
    wXFORM: XFORM;
    RgnDword: DWORD;
    RgnData: PRgnData;
 
    procedure OffsetCentre;
    begin
     r.Left := r.Left+(r.Right -r.Left) div 2;
     r.Top := r.Top +(r.Bottom-r.Top) div 2;
    end;

begin
    rgn := ReadInteger(_Data, _data_Region);
    sx := ReadReal(_Data, _data_X,_prop_X);
    sy := ReadReal(_Data, _data_Y,_prop_Y);
    if rgn = 0 then Exit;
    DeleteObject(FRegion); 
    GetRgnBox(rgn, r);
    FillChar(wXFORM, SizeOf(wXFORM), #0);
    case _prop_Type of
     0,1: begin                 // маштаб
           wXFORM.eM11 := sx;
           wXFORM.eM22 := sy;
           if _prop_Type = 1 then // скос
            begin
             wXFORM.eM12 := 1;
             wXFORM.eM21 := 1;
            end;
           case _prop_Mode of
            0: OffsetCentre;                               //центр
            2: r.Left := r.Left+(r.Right -r.Left);         //правый верхний угол
            3: begin                                       //правый нижний угол
                r.Left := r.Left+(r.Right -r.Left);
                r.Top := r.Top +(r.Bottom-r.Top);
               end;
            4: r.Top := r.Top +(r.Bottom-r.Top);           //левый нижний угол
           end;
          end;
     2: begin     // горизонтальное отражение
         OffsetCentre;
         wXFORM.eM11 := -1;
         wXFORM.eM22 := 1;
        end;
     3: begin    // вертикальное отражение
         OffsetCentre;
         wXFORM.eM11 := 1;
         wXFORM.eM22 := -1;
        end;
     4: begin    // горизонтальное и вертикальное отражение
         OffsetCentre;
         wXFORM.eM11 := -1;
         wXFORM.eM22 := -1;
        end;
    end;
    OffsetRgn(rgn, -r.Left, -r.Top);
    RgnDword := GetRegionData(rgn, 0, nil);
    GetMem(RgnData, SizeOf(RGNDATA) * RgnDword);
    GetRegionData(rgn, RgnDword, RgnData); 
    FRegion := ExtCreateRegion(@wXFORM, RgnDword, RgnData^);
    OffsetRgn(rgn, r.Left, r.Top);
    OffsetRgn(FRegion, r.Left, r.Top);
    FreeMem(RgnData);
    _hi_onEvent(_event_onTransform, integer(FRegion));
end;

procedure THIRGN_Transform._work_doSetTransform;
var r: TRect;
    rgn: HRGN;
    wXFORM: XFORM;
    RgnDword: DWORD;
    RgnData: PRgnData;
begin
    rgn := ReadInteger(_Data, _data_Region);
    if rgn = 0 then Exit;
    DeleteObject(FRegion); 
    GetRgnBox(rgn, r);
    r.Left := r.Left+(r.Right -r.Left) div 2;
    r.Top := r.Top +(r.Bottom-r.Top) div 2;
    OffsetRgn(rgn, -r.Left, -r.Top);
    FillChar(wXFORM, SizeOf(wXFORM), #0);
    wXFORM.eM11 := ReadReal(_Data, null);
    wXFORM.eM12 := ReadReal(_Data, null);
    wXFORM.eM22 := ReadReal(_Data, null);
    wXFORM.eM21 := ReadReal(_Data, null);
    wXFORM.eDx  := ReadReal(_Data, null);
    wXFORM.eDy  := ReadReal(_Data, null);
    RgnDword := GetRegionData(rgn, 0, nil);
    GetMem(RgnData, SizeOf(RGNDATA) * RgnDword);
    GetRegionData(rgn, RgnDword, RgnData); 
    FRegion := ExtCreateRegion(@wXFORM, RgnDword, RgnData^);
    OffsetRgn(rgn, r.Left, r.Top);
    OffsetRgn(FRegion, r.Left, r.Top);
    FreeMem(RgnData);
    _hi_onEvent(_event_onTransform, integer(FRegion));
end;

procedure THIRGN_Transform._work_doType(var _Data:TData; Index:word);
begin
    _prop_Type := ToInteger(_Data);
end;

procedure THIRGN_Transform._work_doMode(var _Data:TData; Index:word);
begin
    _prop_Mode := ToInteger(_Data);
end;

procedure THIRGN_Transform._work_doClear;
begin
    DeleteObject(FRegion);
    FRegion := 0;
end;

procedure THIRGN_Transform._var_Result;
begin
    dtInteger(_Data, FRegion);
end;

end.