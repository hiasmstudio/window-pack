unit hiRGN_Rect;

interface

uses Windows,Kol,Share,Debug;

type
  THIRGN_Rect = class(TDebug)
   private
    FRegion: HRGN;
   public
    _prop_Point1:integer;
    _prop_Point2:integer;
    _prop_Point2AsOffset:boolean;

    _data_Point1:THI_Event;
    _data_Point2:THI_Event;
    
    _event_onCreateRect:THI_Event;

    destructor Destroy; override;
    procedure _work_doCreateRect(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

destructor THIRGN_Rect.Destroy;
begin
   DeleteObject(FRegion);
   inherited;
end;

procedure THIRGN_Rect._work_doCreateRect;
var
   p1,p2:integer;
   x1,y1,x2,y2:integer;
begin
   p1 := ReadInteger(_Data, _data_Point1, _prop_Point1);
   p2 := ReadInteger(_Data, _data_Point2, _prop_Point2);
   x1 := smallint(p1 and $FFFF);
   y1 := smallint(p1 shr 16);
   if _prop_Point2AsOffset then
     begin
       x2 := x1;
       y2 := y1;
     end
   else
     begin
       x2 := 0;
       y2 := 0;
     end;
   inc(x2, smallint(p2 and $FFFF));
   inc(y2, smallint(p2 shr 16));
   DeleteObject(FRegion);
   FRegion := CreateRectRgn(x1, y1, x2, y2);
   _hi_onEvent(_event_onCreateRect, integer(FRegion));
end;

procedure THIRGN_Rect._work_doClear;
begin
  DeleteObject(FRegion);
  FRegion := 0;
end;

procedure THIRGN_Rect._var_Result;
begin
   dtInteger(_Data, FRegion);
end;

end.
