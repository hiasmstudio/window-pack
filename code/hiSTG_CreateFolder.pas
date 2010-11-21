unit hiSTG_CreateFolder;

interface

uses
   Windows, Messages, ActiveX, KolComObj, Kol, Share, Debug, hiSStorage_DS;

type
  THISTG_CreateFolder = class(TDebug)
   private
   public
    _prop_SStorage_DS: PISStorage_DS;

    _data_InPath,
    _event_onCreateFolder:THI_Event;

    procedure _work_doCreateFolder(var _Data:TData; Index:word);
  end;

implementation

//==============================================================================
//
//                               Создание папки
//
//==============================================================================

procedure THISTG_CreateFolder._work_doCreateFolder;
var
  FFolderName: WideString;
  FRootStorage: TSStorage;
begin
  if not Assigned(_prop_SStorage_DS) then exit;
  FFolderName := StringToWideString(ReadString(_Data, _data_InPath));
  FRootStorage := _prop_SStorage_DS.GetFRootStorage;
  if FRootStorage = nil then
    _prop_SStorage_DS.EventError(STG_ERROR_INACCESSIBLESTORAGE)
  else if FFolderName = '' then
    _prop_SStorage_DS.EventError(STG_ERROR_INCORRECTFILENAME)
  else if FRootStorage.StgPathExists(FFolderName) then
    _prop_SStorage_DS.EventError(STG_ERROR_FOLDERISEXISTS)
  else if not FRootStorage.StgCreateFolder(FFolderName) then
    _prop_SStorage_DS.EventError(STG_ERROR_IMPOSSIBLECREATEFOLDER)
  else
    _hi_onEvent(_event_onCreateFolder);
end;


end.