unit hiRGN_Combine;

interface

uses Windows, Kol, Share, Debug;

type
  THIRGN_Combine = class(TDebug)
   private
    FRegion: HRGN;
    rIndex: integer;
   public
    _prop_Mode:byte;

    _data_Region2:THI_Event;
    _data_Region1:THI_Event;
    _event_onCombine:THI_Event;

    destructor Destroy; override;
    procedure _work_doCombine(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doMode(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
    procedure _var_ResultIndex(var _Data:TData; Index:word);
  end;

implementation

destructor THIRGN_Combine.Destroy;
begin
   DeleteObject(FRegion);
   inherited;
end;

procedure THIRGN_Combine._work_doCombine;
var rgn1,rgn2:HRGN;
begin
   if FRegion = 0 then FRegion := CreateRectRgn(0, 0, 0, 0);
   rgn1 := ReadInteger(_Data, _data_Region1);
   rgn2 := ReadInteger(_Data, _data_Region2);
   rIndex := CombineRgn(FRegion, rgn1, rgn2, _prop_Mode + 1);
   _hi_onEvent(_event_onCombine, integer(FRegion));
end;

procedure THIRGN_Combine._work_doClear;
begin
  DeleteObject(FRegion);
  FRegion := 0;
end;

procedure THIRGN_Combine._work_doMode;
begin
   _prop_Mode := ToInteger(_Data);
end;

procedure THIRGN_Combine._var_Result;
begin
   dtInteger(_Data, FRegion);
end;

procedure THIRGN_Combine._var_ResultIndex;
begin
   dtInteger(_Data, rIndex);
end;

end.