unit hiSTG_Merge;

interface

uses
   Windows, Messages, ActiveX, KolComObj, Kol, Share, Debug, hiSStorage_DS;

type
  THISTG_Merge = class(TDebug)
   private
   public
    _prop_SStorage_DS: PISStorage_DS;

    _prop_MergeSrcStgPath,
    _prop_MergeDstStgPath: string;

    _data_IsCurrentStgMerge,
    _data_MergeSrcStgPath,
    _data_MergeDstStgPath,
    _event_onEndMerge:THI_Event;

    procedure _work_doMerge(var _Data:TData; Index:word);
  end;

implementation

//==============================================================================
//
//                            Упаковка Хранилища
//
//==============================================================================

procedure THISTG_Merge._work_doMerge;
var
  FSrcStgName, FDstStgName: WideString;
  Res: HResult;
  Bool: boolean;
  len: dword;
  src, dst: WideString;
  fp: PWChar;
  FRootStorage: TSStorage;
begin
  if not Assigned(_prop_SStorage_DS) then exit;
  src := StringToWideString(ReadString(_Data, _data_MergeSrcStgPath, _prop_MergeSrcStgPath));
  dst := StringToWideString(ReadString(_Data, _data_MergeDstStgPath, _prop_MergeDstStgPath));  
  if (src = '') or (dst = '') then
  begin
    _prop_SStorage_DS.EventError(STG_ERROR_INCORRECTFILENAME);
    exit;
  end;

  FRootStorage := _prop_SStorage_DS.GetFRootStorage;
   
  len := GetFullPathNameW(PWChar(src), 0, nil, fp);
  SetLength(FSrcStgName, len - 1);
  GetFullPathNameW(PWChar(src), len, PWChar(FSrcStgName), fp);

  len := GetFullPathNameW(PWChar(dst), 0, nil, fp);
  SetLength(FDstStgName, len - 1);
  GetFullPathNameW(PWChar(dst), len, PWChar(FDstStgName), fp);

  if FRootStorage <> nil then
    if (AnsiCompareTextW(FRootStorage.GetStgName, FDstStgName)) = 0 then
      if  ReadInteger(_Data, _data_IsCurrentStgMerge) = 0 then
        _prop_SStorage_DS.CloseRootStorage
      else
      begin
        _prop_SStorage_DS.EventError(STG_ERROR_IMPOSSIBLEMERGEOPENSTG);
        exit;
      end;

  Bool := false;
  Res := StgIsStorageFile(PWChar(FSrcStgName)) + StgIsStorageFile(PWChar(FDstStgName));

  case Res of
    S_OK:  Bool := StorageMerge(FSrcStgName, FDstStgName);
  end;

  if Bool and (Res = S_OK) then
    _hi_onEvent(_event_onEndMerge)
  else
    _prop_SStorage_DS.EventError(STG_ERROR_IMPOSSIBLEMERGESTORAGES);
end;

end.