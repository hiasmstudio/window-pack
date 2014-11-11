unit hiRGN_Path;

interface

uses Windows,Kol,Share,Debug;

type
  THIRGN_Path = class(TDebug)
   private
    FRegion: HRGN;
    pDC: HDC;
   public
    _event_onStartCreate:THI_Event;
    _event_onFinishCreate:THI_Event;    

    procedure _work_doCreateRegion(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

procedure THIRGN_Path._work_doCreateRegion;
begin
  DeleteObject(FRegion);
  FRegion := 0;
  pDC := CreateCompatibleDC(0);
  BeginPath(pDC);
   _hi_onEvent(_event_onStartCreate, integer(pDC));
  EndPath(pDC);
  FRegion := PathToRegion(pDC);
  DeleteDC(pDC);
   _hi_onEvent(_event_onFinishCreate, integer(FRegion));
end;

procedure THIRGN_Path._work_doClear;
begin
  DeleteObject(FRegion);
  FRegion := 0;
end;

procedure THIRGN_Path._var_Result;
begin
   dtInteger(_Data, FRegion);
end;

end.
