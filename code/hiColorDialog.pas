unit hiColorDialog;

interface

uses Kol,Share,Debug;

type
  THIColorDialog = class(TDebug)
   private
   public
    _data_Color:THI_Event;
    _event_onSelect:THI_Event;

    procedure _work_doOpen(var _Data:TData; Index:word);
  end;

implementation

procedure THIColorDialog._work_doOpen;
var cd:PColorDialog;
begin
   cd := NewColorDialog(ccoShortOpen);
   cd.OwnerWindow := ReadHandle;
   cd.Color := ReadInteger(_Data,_data_Color,0);
   if cd.Execute then
     _hi_CreateEvent(_Data,@_event_onSelect,cd.Color);
end;

end.
