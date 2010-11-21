unit hiPointInRect;

interface

uses Kol,Share,Debug;

type
  THIPointInRect = class(TDebug)
   private
   public
    _prop_Point2AsOffset:boolean;

    _data_RPoint2:THI_Event;
    _data_RPoint1:THI_Event;
    _data_Point:THI_Event;
    _event_onFalse:THI_Event;
    _event_onTrue:THI_Event;

    procedure _work_doCheck(var _Data:TData; Index:word);
  end;

implementation

type
 TSPoint = record x,y:smallint; end;
 PSPoint = ^TSPoint;

procedure THIPointInRect._work_doCheck;
var px,py:smallint;
    p:TSPoint;
    Result:boolean;
    k:integer;
    function ToSPoint(i:integer):PSPoint;
    begin
       k := i;
       Result := @k;
    end;
begin      
   with ToSPoint(ReadInteger(_Data,_data_Point))^ do
    begin
     py := y;
     px := x;
    end;
   with ToSPoint(ReadInteger(_Data,_data_RPoint1))^ do
    begin
      p.x := x;
      p.y := y;
    end;      
   if _prop_Point2AsOffset then
     with ToSPoint(ReadInteger(_Data,_data_RPoint2))^ do
      Result := (px >= p.x)and(px <= p.x + x)and(py >= p.y)and(py <= p.y + y)
   else
     with ToSPoint(ReadInteger(_Data,_data_RPoint2))^ do
      Result := (px >= p.x)and(px <= x)and(py >= p.y)and(py <= y);

   if Result then
     _hi_CreateEvent(_Data,@_event_onTrue)
   else _hi_CreateEvent(_Data,@_event_onFalse);
end;

end.
