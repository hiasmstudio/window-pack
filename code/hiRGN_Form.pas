unit HIRGN_Form;

interface

uses Messages, Windows, Kol, Share, Debug, Win;

const
  RGN_ERROR         = 0;
  RGN_NULLREGION    = 1;
  RGN_SIMPLEREGION  = 2;
  RGN_COMPLEXREGION = 3;
  
type
 THiRGN_Form = class(TDebug)
   private
    FRegion: HRGN;
   public
    _prop_ControlManager: IControlManager;
    
    _prop_OnlyVisible: Boolean;
    _prop_ApplyNow: Boolean;
    
    _event_onCreateRgn: THI_Event;
    _data_PHandle: THI_Event;
    
    destructor Destroy; override;
    procedure _work_doCreateRgn(var _Data: TData; Index: Word);
    procedure _var_Result(var _Data: TData; Index: Word);

 end;

implementation

procedure THiRGN_Form._work_doCreateRgn;
var
  y, shx, shy: Integer;
  tRGN: HRGN;
  sControl: PControl;
begin
  if not Assigned(_prop_ControlManager) then exit;
  sControl := _prop_ControlManager.ctrlpoint;

  if sControl.ChildCount < 1 then exit;

  DeleteObject(FRegion);
  FRegion := CreateRectRgn(0, 0, 0, 0);
  with sControl{$ifndef F_P}^{$endif} do
  begin
    shx := width - clientrect.right - integer(IsForm) * 2 - integer(hasBorder) * 2 - border - integer(ctl3d) * 2;  // о ужас :)
    shy := height - clientrect.bottom - integer(IsForm) * 2 - integer(hasBorder) * 2 - border - integer(ctl3d) * 2;
  
    for y := 0 to ChildCount - 1 do 
      with Children[y]{$ifndef F_P}^{$endif} do 
        if Visible or not _prop_OnlyVisible then
        begin
          tRGN := CreateRectRgn(0, 0, 0, 0);
          if integer(GetWindowRgn(Handle, tRGN)) < RGN_SIMPLEREGION then  // регион не найден
          begin 
            DeleteObject(tRgn);
            tRGN := CreateRectRgn(shx + left, shy + top, shx + left + width, shy + top + height);
          end
          else 
            OffsetRgn(tRGN, shx + left, shy + top); 
          CombineRgn(FRegion, FRegion, tRGN, RGN_OR);
          DeleteObject(tRGN);
        end;
    
    if _prop_ApplyNow then SetWindowRgn(Handle, FRegion, true);
    _hi_onEvent(_event_onCreateRgn, integer(FRegion));
  end;
end;

procedure THiRGN_Form._var_Result;
begin
  dtInteger(_Data, FRegion);
end;

destructor THiRGN_Form.Destroy;
begin
  DeleteObject(FRegion);
  inherited;
end;

end.