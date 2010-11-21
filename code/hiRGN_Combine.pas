unit hiRGN_Combine;

interface

uses Windows,Kol,Share,Debug;

type
  THIRGN_Combine = class(TDebug)
   private
    FRegion:HRGN;
   public
    _prop_Mode:byte;

    _data_Region2:THI_Event;
    _data_Region1:THI_Event;
    _event_onCombine:THI_Event;

    destructor Destroy; override;
    procedure _work_doCombine(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

destructor THIRGN_Combine.Destroy;
begin
   DeleteObject(FRegion);
   inherited;
end;

procedure THIRGN_Combine._work_doCombine;
var r1,r2:HRGN;
begin
   r1 := ReadInteger(_Data, _data_Region1);
   r2 := ReadInteger(_Data, _data_Region2);
   DeleteObject(FRegion);
   FRegion := CreateRectRgn(0, 0, 0, 0);
   CombineRgn(FRegion, r1, r2, _prop_Mode+1);
   _hi_onEvent(_event_onCombine, integer(FRegion));
end;

procedure THIRGN_Combine._var_Result;
begin
   dtInteger(_Data, FRegion);
end;

end.
