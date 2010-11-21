unit hiSTG_MoveTo;

interface

uses
   Windows, Messages, ActiveX, KolComObj, Kol, Share, Debug, hiSStorage_DS;

type
  THISTG_MoveTo = class(TDebug)
   private
   public
    _prop_SStorage_DS: PISStorage_DS;

    _data_InPath,
    _data_InMoveToPath,
    _event_onMoveTo:THI_Event;

    procedure _work_doMoveTo(var _Data:TData; Index:word);
  end;

implementation

//==============================================================================
//
//                             Перемещение элемента
//
//==============================================================================

procedure THISTG_MoveTo._work_doMoveTo;
var
  tmpPath, FFileName, FNewFileName: WideString;
  SystemTime: TSystemTime;
  DateTime:TDateTime;
  FRootStorage: TSStorage;
begin
  if not Assigned(_prop_SStorage_DS) then exit;
  FFileName := StringToWideString(ReadString(_Data, _data_InPath));
  FNewFileName := StringToWideString(ReadString(_Data, _data_InMoveToPath));
  FRootStorage := _prop_SStorage_DS.GetFRootStorage;
  if FRootStorage = nil then
    _prop_SStorage_DS.EventError(STG_ERROR_INACCESSIBLESTORAGE)
  else if (FFileName = '') or (FNewFileName = '') then
    _prop_SStorage_DS.EventError(STG_ERROR_INCORRECTFILENAME)
  else if AnsiCompareTextW(FFileName, FNewFileName) = 0 then
    _prop_SStorage_DS.EventError(STG_ERROR_IMPOSSIBLEMOVEFILEMOSTITSELF)
  else
  begin
    GetLocalTime(SystemTime);
    SystemTime2DateTime(SystemTime, DateTime);
    tmpPath := StringToWideString(Time2StrFmt(Date2StrFmt(TMPFILEFORMAT, DateTime), DateTime));

    if FRootStorage.InternalMoveElementTo(FFileName, tmpPath, STGMOVE_MOVE) then
      if FRootStorage.InternalMoveElementTo(tmpPath, FNewFileName, STGMOVE_MOVE) then
      begin
        _hi_onEvent(_event_onMoveTo);
        exit;
      end
      else
        FRootStorage.InternalMoveElementTo(tmpPath, FFileName, STGMOVE_MOVE);
    _prop_SStorage_DS.EventError(STG_ERROR_IMPOSSIBLEMOVEELEMENT);
  end;
end;

end.