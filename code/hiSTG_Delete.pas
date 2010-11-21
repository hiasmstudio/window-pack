unit hiSTG_Delete;

interface

uses
   Windows, Messages, ActiveX, KolComObj, Kol, Share, Debug, hiSStorage_DS;

type
  THISTG_Delete = class(TDebug)
   private
   public
    _prop_SStorage_DS: PISStorage_DS;

    _data_InPath,
    _event_onDelete:THI_Event;

    procedure _work_doDelete(var _Data:TData; Index:word);
  end;

implementation

//==============================================================================
//
//                             Удаление элемента
//
//==============================================================================

procedure THISTG_Delete._work_doDelete;
var
  FFileName: WideString;
  FRootStorage: TSStorage;
begin
  if not Assigned(_prop_SStorage_DS) then exit;
  FFileName := StringToWideString(ReadString(_Data, _data_InPath));
  FRootStorage := _prop_SStorage_DS.GetFRootStorage;
  if FRootStorage = nil then
    _prop_SStorage_DS.EventError(STG_ERROR_INACCESSIBLESTORAGE)
  else if FFileName = '' then
    _prop_SStorage_DS.EventError(STG_ERROR_INCORRECTFILENAME)
  else if not FRootStorage.InternalDeleteElement(FFileName) then
    _prop_SStorage_DS.EventError(STG_ERROR_IMPOSSIBLEDELETEELEMENT)
  else
    _hi_onEvent(_event_onDelete);
end;



end.