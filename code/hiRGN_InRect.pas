unit hiRGN_InRect;

interface

uses Windows, Kol, Share, Debug;

type
  THIRGN_InRect = class(TDebug)
   private
     InRegion: boolean;
   public
    _prop_Point1: integer;
    _prop_Point2: integer;    
    _prop_PackPoint: boolean;
    _prop_Point2AsOffset:boolean;
    _prop_Width: integer;
    _prop_Height: integer;
        
    _data_Region: THI_Event;
    _data_Point1: THI_Event;
    _data_Point2: THI_Event;
    _data_Width: THI_Event;
    _data_Height: THI_Event;

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

procedure THIRGN_InRect._work_doCheck;
var
  rgn: HRGN;
  x, y, w, h, k: integer;
  rect: TRect;

  function ToSPoint(i: integer): PSPoint;
  begin
    k := i;
    Result := @k;
  end;

begin
  rgn := ReadInteger(_Data, _data_Region);
  if _prop_PackPoint then
   begin
    with ToSPoint(ReadInteger(_Data, _data_Point1, _prop_Point1))^ do
    begin
      y := yy;
      x := xx;
    end;  
    with ToSPoint(ReadInteger(_Data, _data_Point2, _prop_Point2))^ do
    begin
      h := yy;
      w := xx;
    end; 
   end
  else
   begin
    x := ReadInteger(_Data, _data_Point1, _prop_Point1);
    y := ReadInteger(_Data, _data_Point2, _prop_Point2);
    w := ReadInteger(_Data, _data_Width, _prop_Width);
    h := ReadInteger(_Data, _data_Height, _prop_Height);  
   end;
  if _prop_Point2AsOffset then
   begin
    w := w + x;
    h := h + y;
   end;
  SetRect(rect, x, y, w, h);
  InRegion := RectInRegion (rgn, rect);
  if InRegion then
   _hi_onEvent(_event_onTrue)
  else
   _hi_onEvent(_event_onFalse);
  _hi_onEvent(_event_onCheck, ord(InRegion));
end;

procedure THIRGN_InRect._var_Result;
begin
  dtInteger(_Data, ord(InRegion));
end;

end.
