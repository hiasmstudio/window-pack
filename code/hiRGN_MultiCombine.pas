unit hiRGN_MultiCombine;

interface

uses Windows, Kol, Share, Debug;

type
  THIRGN_MultiCombine = class(TDebug)
   private
    FRegion: HRGN;
    FCount: Word;
    procedure SetCount(Value: integer);
   public
    _prop_Mode: byte;
    _event_onCombine: THI_Event;

    Region: array of THI_Event;
    
    property _prop_Count: integer write SetCount;

    destructor Destroy; override;
    procedure _work_doCombine(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

procedure THIRGN_MultiCombine.SetCount;
begin
  FCount := Value;
  SetLength(Region, FCount);
end;

destructor THIRGN_MultiCombine.Destroy;
begin
  DeleteObject(FRegion);
  inherited;
end;

procedure THIRGN_MultiCombine._work_doCombine;
var
  i: integer;
begin
  DeleteObject(FRegion);
  FRegion := CreateRectRgn(0, 0, 0, 0);
  CombineRgn(FRegion, ReadInteger(_Data, Region[0]), 0, RGN_COPY);
  for i := 1 to High(Region) do 
    CombineRgn(FRegion, FRegion, ReadInteger(_Data, Region[i]), _prop_Mode + 1);
  _hi_onEvent(_event_onCombine, integer(FRegion));
end;

procedure THIRGN_MultiCombine._var_Result;
begin
  dtInteger(_Data, FRegion);
end;

end.
