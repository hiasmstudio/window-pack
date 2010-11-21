unit hiSTG_Rename;

interface

uses
   Windows, Messages, ActiveX, KolComObj, Kol, Share, Debug, hiSStorage_DS;

type
  THISTG_Rename = class(TDebug)
   private
   public
    _prop_SStorage_DS: PISStorage_DS;

    _data_InPath,
    _data_NewName,
    _event_onRename:THI_Event;

    procedure _work_doRename(var _Data:TData; Index:word);
  end;

implementation

//==============================================================================
//
//                          Переименование элемента
//
//==============================================================================

procedure THISTG_Rename._work_doRename;
var
  FInPath, FFileName, FNewFileName: WideString;
  FRootStorage: TSStorage;
  fpath, fn: string;
begin
  if not Assigned(_prop_SStorage_DS) then exit;
  fpath := ReadString(_Data, _data_InPath);
  FInPath := StringToWideString(fpath);
  fn := ExtractFileName(fpath);
  FFileName := StringToWideString(fn);  
  FNewFileName := StringToWideString(ReadString(_Data, _data_NewName));

  FRootStorage := _prop_SStorage_DS.GetFRootStorage;
  if FRootStorage = nil then
    _prop_SStorage_DS.EventError(STG_ERROR_INACCESSIBLESTORAGE)
  else if (FInPath = '') or (FNewFileName = '') then
    _prop_SStorage_DS.EventError(STG_ERROR_INCORRECTFILENAME)
  else if AnsiCompareTextW(FFileName, FNewFileName) = 0 then
    _prop_SStorage_DS.EventError(STG_ERROR_IMPOSSIBLEREANAMEFILEMOSTITSELF)
  else if not FRootStorage.InternalRenameElement(FInPath, FNewFileName) then
    _prop_SStorage_DS.EventError(STG_ERROR_IMPOSSIBLERENAMEELEMENT)
  else
    _hi_onEvent(_event_onRename);
end;

end.