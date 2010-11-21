unit hiSTG_CopyTo;

interface

uses
   Windows, Messages, ActiveX, KolComObj, Kol, Share, Debug, hiSStorage_DS;

type
  THISTG_CopyTo = class(TDebug)
   private
   public
    _prop_SStorage_DS: PISStorage_DS;

    _data_InPath,
    _data_InCopyToPath,
    _event_onCopyTo:THI_Event;

    procedure _work_doCopyTo(var _Data:TData; Index:word);
  end;

implementation

//==============================================================================
//
//                            Копирование элемента
//
//==============================================================================

procedure THISTG_CopyTo._work_doCopyTo;
var
  tmpPath, FFileName, FNewFileName: WideString;
  SystemTime: TSystemTime;
  DateTime:TDateTime;
  FRootStorage: TSStorage;
begin
  if not Assigned(_prop_SStorage_DS) then exit;
  FFileName := StringToWideString(ReadString(_Data, _data_InPath));
  FNewFileName := StringToWideString(ReadString(_Data, _data_InCopyToPath));
  FRootStorage := _prop_SStorage_DS.GetFRootStorage;
  if FRootStorage = nil then
    _prop_SStorage_DS.EventError(STG_ERROR_INACCESSIBLESTORAGE)
  else if (FFileName = '') or (FNewFileName = '') then
    _prop_SStorage_DS.EventError(STG_ERROR_INCORRECTFILENAME)
  else if AnsiCompareTextW(FFileName, FNewFileName) = 0 then
    _prop_SStorage_DS.EventError(STG_ERROR_IMPOSSIBLECOPYFILEMOSTITSELF)
  else
  begin
    GetLocalTime(SystemTime);
    SystemTime2DateTime(SystemTime, DateTime);
    tmpPath := StringToWideString(Time2StrFmt(Date2StrFmt(TMPFILEFORMAT, DateTime), DateTime));

    if FRootStorage.InternalMoveElementTo(FFileName, tmpPath, STGMOVE_COPY) then  
      if FRootStorage.InternalMoveElementTo(tmpPath, FNewFileName, STGMOVE_MOVE) then
      begin
        _hi_onEvent(_event_onCopyTo);
        exit;
      end  
      else
        FRootStorage.InternalDeleteElement(tmpPath);
    _prop_SStorage_DS.EventError(STG_ERROR_IMPOSSIBLECOPYELEMENT);
  end;  
end;

end.