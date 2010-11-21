unit hiSTG_GetSize;

interface

uses
   Windows, Messages, ActiveX, KolComObj, Kol, Share, Debug, hiSStorage_DS;

type
  THISTG_GetSize = class(TDebug)
   private
     FSizeElement: int64;
   public
    _prop_SStorage_DS: PISStorage_DS;
    _prop_GetSizeFolder: boolean;

    _data_InPath,
    _event_onGetSize:THI_Event;

    procedure _work_doGetSize(var _Data:TData; Index:word);
    procedure _var_Size(var _Data:TData; Index:word);
  end;

implementation

//==============================================================================
//
//                       Получение размера элемента
//
//==============================================================================

procedure THISTG_GetSize._work_doGetSize;
var
  FFileName: WideString;
  StatStg1: TStatStg;
  GSize: int64;
  TmpStg: IStorage;
  vPath: TSPath;
  TmpFolder: TSStgFolder;
  dt: TData;
  FRootStorage: TSStorage;
  FStorage: IStorage;  

  procedure EnumElementsNode(AName: WideString; ParentStg: IStorage);
  var
    CurrentStg: IStorage;
    Enum: IEnumStatStg;
    StatStg: TStatStg;
  begin
    if ParentStg = nil then exit;
    CurrentStg := nil;
    FillChar(StatStg, SizeOf(StatStg), #0);    
    if _ElementExists(ParentStg, AName, @StatStg) and (StatStg.dwType = STGTY_STORAGE) and _OpenFolder(AName, ParentStg, CurrentStg) then
      if CurrentStg <> nil then
      begin
        if CurrentStg.EnumElements(0, nil, 0, Enum) = S_OK then
        begin
        TRY
          while Enum.Next(1, StatStg, nil) = S_Ok do
          begin
            // если "папка"
            if (StatStg.dwType = STGTY_STORAGE) and _prop_GetSizeFolder then
              EnumElementsNode(StatStg.pwcsName, CurrentStg)
            // если "файл"
            else
              GSize := GSize + StatStg.cbSize;
          end;
        FINALLY
          Enum := nil;
        END;
        end;
      end;
  end;

begin
  if not Assigned(_prop_SStorage_DS) then exit;
  FFileName := StringToWideString(ReadString(_Data, _data_InPath));
  GSize := 0;
  FRootStorage := _prop_SStorage_DS.GetFRootStorage;
  FStorage := _prop_SStorage_DS.GetFRootFolder;
  if FRootStorage = nil then
    _prop_SStorage_DS.EventError(STG_ERROR_INACCESSIBLESTORAGE)
  else if FStorage = nil then
    _prop_SStorage_DS.EventError(STG_ERROR_INACCESSIBLEROOTFOLDER)
  else if FFileName = '' then
    _prop_SStorage_DS.EventError(STG_ERROR_INCORRECTFILENAME)
  else
    GetSPath(FFileName, vPath);
    if FRootStorage.GetWorkFolder(vPath, TmpFolder) then
    begin
      if TmpFolder <> nil then
        TmpStg := _prop_SStorage_DS.GetFStorage(TmpFolder)
      else
        TmpStg := FStorage;
      FillChar(StatStg1, SizeOf(StatStg1), #0);  
      if _ElementExists(TmpStg, vPath[High(vPath)], @StatStg1) and (StatStg1.dwType = STGTY_STORAGE)
         and _prop_GetSizeFolder then
        EnumElementsNode(vPath[High(vPath)], TmpStg)
      else
        GSize := StatStg1.cbSize;
      FSizeElement := GSize;
      dtReal(dt, GSize);
      _hi_onEvent_(_event_onGetSize, dt);
      if TmpFolder <> nil then TmpFolder.Free;
    end;
end;

//==============================================================================
//
//                           Доступ к размеру элемента
//
//==============================================================================

procedure THISTG_GetSize._var_Size;
begin
  dtReal(_Data, FSizeElement);
end;

end.