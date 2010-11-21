unit hiColorShade;

interface

uses Windows,Kol,Share,Debug;

type
  TModeShade = (csLight, csShade);

const
  xMaxRGB  = 25500;

type
  ThiColorShade = class(TDebug)
   private
    FShade: TColor;
   public
    _prop_Depth: integer;
    _prop_Color: TColor;    
    _prop_Mode: TModeShade;

    _data_Depth:THI_Event;
    _data_Color:THI_Event;
    _event_onResult:THI_Event;

    procedure _work_doShade(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

function GetLightColor(Color: TColor; Light: Byte) : TColor;
var   fFrom: TRGB;
begin
  PColor(@fFrom)^:= Color2RGB(Color);
  Result := RGB(
    (Min(xMaxRGB, FFrom.R*100 + (255 - FFrom.R) * Light)) div 100,
    (Min(xMaxRGB, FFrom.G*100 + (255 - FFrom.G) * Light)) div 100,
    (Min(xMaxRGB, FFrom.B*100 + (255 - FFrom.B) * Light)) div 100
  );
end;

function GetShadeColor(Color: TColor; Shade: Byte) : TColor;
var   fFrom: TRGB;
begin
  PColor(@fFrom)^:= Color2RGB(Color);
  Result := RGB(
    Max(0, FFrom.R - Shade),
    Max(0, FFrom.G - Shade),
    Max(0, FFrom.B - Shade)
  );
end;

procedure ThiColorShade._work_doShade;
var   Color: TColor;
      Depth: Byte;
begin
   Color := ReadInteger(_Data, _data_Color, _prop_Color);
   Depth := Byte(ReadInteger(_Data, _data_Depth, _prop_Depth));
   if _prop_Mode = csLight then
      FShade := GetLightColor(Color, Depth)
   else
      FShade := GetShadeColor(Color, Depth);      
   _hi_CreateEvent(_Data, @_event_onResult, integer(FShade));
end;

procedure ThiColorShade._var_Result;
begin
   dtInteger(_Data, FShade);
end;

end.
