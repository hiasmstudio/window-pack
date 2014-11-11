unit hiRGN_Offset;

interface

uses Windows,Kol,Share,Debug;

type
  THIRGN_Offset = class(TDebug)
   private
    FRegion:HRGN;
    
    function GetValue (var _Data:TData):TPoint;
   public
    _prop_X:integer;
    _prop_Y:integer;
    _prop_PackPoint:boolean;
    _prop_Point:integer;
    
    _data_X:THI_Event;
    _data_Y:THI_Event;
    _data_Region:THI_Event;
    _data_Point: THI_Event;    
    _event_onOffset:THI_Event;
    _event_onPosition:THI_Event;
    
    destructor Destroy; override;
    procedure _work_doOffset(var _Data:TData; Index:word);
    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
    procedure _var_Left(var _Data:TData; Index:word);
    procedure _var_Top(var _Data:TData; Index:word);
  end;

implementation

type
  TSPoint = record
    xx: smallint;
    yy: smallint;
  end;
  PSPoint = ^TSPoint;

destructor THIRGN_Offset.Destroy;
begin
   DeleteObject(FRegion);
   inherited;
end;

function THIRGN_Offset.GetValue;
var x, y, k: integer;
    rgn: HRGN;
  
  function ToSPoint(i: integer): PSPoint;
  begin
    k := i;
    Result := @k;
  end;

begin
   rgn := ReadInteger(_Data, _data_Region);
   if rgn = 0 then exit;
   DeleteObject(FRegion);
   FRegion := CreateRectRgn(0, 0, 0, 0);
   CombineRgn(FRegion, rgn, 0, RGN_COPY);
   if _prop_PackPoint then
    with ToSPoint(ReadInteger(_Data, _data_Point))^ do
    begin
      y := yy;
      x := xx;
    end  
   else begin
    x := ReadInteger(_Data, _data_X,_prop_X);
    y := ReadInteger(_Data, _data_Y,_prop_Y);   
   end;
   Result := MakePoint(x,y);
end;

procedure THIRGN_Offset._work_doOffset;
var pnt: TPoint;
begin
    pnt := GetValue(_data);
    OffsetRgn(FRegion, pnt.x, pnt.y);
    _hi_onEvent(_event_onOffset, integer(FRegion));
end;

procedure THIRGN_Offset._work_doPosition(var _Data:TData; Index:word);
var pnt: TPoint;
    RgnDword: DWORD;
    RgnData:  PRgnData;
begin
    pnt := GetValue(_data);
    RgnDword := GetRegionData(FRegion, 0, nil);
    if RgnDword > 0 then
     begin
      GetMem(RgnData, SizeOf(RgnData) * RgnDword);
      GetRegionData(FRegion, RgnDword, RgnData);
      pnt.X := pnt.X - RgnData.rdh.rcBound.Left;
      pnt.Y := pnt.Y - RgnData.rdh.rcBound.Top;
      FreeMem(RgnData);
     end;
    OffsetRgn(FRegion, pnt.x, pnt.y);
    _hi_onEvent(_event_onPosition, integer(FRegion));
end;

procedure THIRGN_Offset._work_doClear;
begin
    DeleteObject(FRegion);
    FRegion := 0;
end;

procedure THIRGN_Offset._var_Result;
begin
    dtInteger(_Data, FRegion);
end;

procedure THIRGN_Offset._var_Left;
var rgn:      HRGN; 
    RgnDword: DWORD;
    RgnData:  PRgnData;
begin
   rgn := ReadInteger(_Data, _data_Region);
   if rgn = 0 then exit;
   RgnDword := GetRegionData(rgn, 0, nil);
   if RgnDword > 0 then
    begin
     GetMem(RgnData, SizeOf(RgnData) * RgnDword);
     GetRegionData(rgn, RgnDword, RgnData);
     dtInteger(_Data, RgnData.rdh.rcBound.Left);
     FreeMem(RgnData);
    end;
end;

procedure THIRGN_Offset._var_Top;
var rgn:      HRGN; 
    RgnDword: DWORD;
    RgnData:  PRgnData;
begin
   rgn := ReadInteger(_Data, _data_Region);
   if rgn = 0 then exit;
   RgnDword := GetRegionData(rgn, 0, nil);
   if RgnDword > 0 then
    begin
     GetMem(RgnData, SizeOf(RgnData) * RgnDword);
     GetRegionData(rgn, RgnDword, RgnData);
     dtInteger(_Data, RgnData.rdh.rcBound.Top);
     FreeMem(RgnData);
    end;
end;

end.