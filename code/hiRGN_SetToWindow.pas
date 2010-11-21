unit hiRGN_SetToWindow;

interface

uses Windows,Kol,Share,Debug;

type
  THIRGN_SetToWindow = class(TDebug)
   private
   public
    _prop_ReDraw:boolean;

    _data_Handle:THI_Event;
    _data_Region:THI_Event;
    _event_onSetRegion:THI_Event;

    procedure _work_doSetRegion(var _Data:TData; Index:word);
  end;

implementation

procedure THIRGN_SetToWindow._work_doSetRegion;
var h,r:integer;
begin
  h := ReadInteger(_Data, _data_Handle);
  r := ReadInteger(_Data, _data_Region);
  SetWindowRgn(h, r, _prop_ReDraw);
  _hi_onevent(_event_onSetRegion);
end;

end.
