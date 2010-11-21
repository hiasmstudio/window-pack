unit hiMST_EditEnd;

interface
     
uses  Messages, Windows, Kol, Share, Debug, hiMTStrTbl;

const
  WM_JUSTFREE = WM_USER + 1;
   
type
  THIMST_EditEnd = class(TDebug)
  private

  public
     _data_EditEnd: THI_Event;
    _prop_MSTControl: IMSTControl;

    procedure _work_doEditEnd(var _Data:TData; Index:word);
  end;

implementation

//---------------   «авершение редактировани€ таблицы   ---------------

// «авершает режим редактирование таблицы при Redaction=True
// ARG(EditEndMode(0 - Cancel Editing, 1 - Use Editing))
//
procedure THIMST_EditEnd._work_doEditEnd;
var
  sControl: PControl;
  FRedaction: boolean;
begin
  if not Assigned(_prop_MSTControl) then exit;
  FRedaction := _prop_MSTControl.getfredaction; 
  if FRedaction then
  begin
    sControl := _prop_MSTControl.ctrlpoint;
    if  ReadInteger(_Data, _data_EditEnd, 0) = 0 then
      sControl.Perform(WM_KEYDOWN, 27, 0)
    else
      sControl.Perform(WM_JUSTFREE, 0, 0);
  end;    
end;

end.