unit hiRGN_PointXY;

interface

uses Windows, Kol, Share, Debug;

type
  THIRGN_PointXY = class(TDebug)
   private
     InRegion: boolean;
   public
    _prop_X: integer;
    _prop_Y: integer;
    _prop_PackPoint: boolean;
    _prop_Point: integer;

    _data_Region: THI_Event;
    _data_Y: THI_Event;
    _data_X: THI_Event;
    _data_point: THI_Event;

    _event_onTrue: THI_Event;
    _event_onFalse: THI_Event;
    _event_onCheck: THI_Event;

    procedure _work_doCheck(var _Data: TData; Index: word);
    procedure _var_Result(var _Data: TData; Index: word);
  end;

implementation

type
  TSPoint = record
    xx: smallint;
    yy: smallint;
  end;
  PSPoint = ^TSPoint;

procedure THIRGN_PointXY._work_doCheck;
var
  rgn: HRGN;
  x, y, k: integer;
  
  function ToSPoint(i: integer): PSPoint;
  begin
    k := i;
    Result := @k;
  end;
  
begin
  rgn := ReadInteger(_Data, _data_Region);
  if _prop_PackPoint then
    with ToSPoint(ReadInteger(_Data, _data_Point))^ do
    begin
      y := yy;
      x := xx;
    end  
  else
  begin
    x := ReadInteger(_Data, _data_X, _prop_X);
    y := ReadInteger(_Data, _data_Y, _prop_Y);
  end;
  
  InRegion := PtInRegion (rgn, X, Y);
  if InRegion then
    _hi_onEvent(_event_onTrue, integer(rgn))
  else
    _hi_onEvent(_event_onFalse);
  _hi_onEvent(_event_onCheck, ord(InRegion));
end;

procedure THIRGN_PointXY._var_Result;
begin
  dtInteger(_Data, ord(InRegion));
end;

end.
