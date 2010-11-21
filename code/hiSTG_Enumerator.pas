unit hiSTG_Enumerator;

interface

uses
   Windows, Messages, ActiveX, KolComObj, Kol, Share, Debug, hiSStorage_DS;

type
  THISTG_Enumerator = class(TDebug)
   private
     fstop: boolean;
   public
    _prop_SStorage_DS: PISStorage_DS;
    _prop_onBreakEnable: boolean;    
    
    _data_InPath,
    _event_onEndEnumAll,
    _event_onEndInPathEnum,    
    _event_onEnumAllElements,
    _event_onBreak,    
    _event_onInPathEnum: THI_Event;

    procedure _work_doEnumAllElements(var _Data:TData; Index:word);
    procedure _work_doInPathEnum(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);        
  end;

implementation

//==============================================================================
//
//               Перечисление всех элементов дерева Хранилища
//
//==============================================================================

procedure THISTG_Enumerator._work_doEnumAllElements;
var
  StatStg: TStatStg;
  Enum: IEnumStatStg;
  ID: integer;
  FStorage: IStorage;
  FRootStorage: TSStorage;
  PPath: WideString;
   
  procedure OutData(outPID, outID, outType: integer; outCapt: WideString; outSize: int64 = 0; fullPath: WideString = '');
  var
    dtpid, dtid, dtcapt, dttype, dtsize, dtpath: TData;  
  begin
    dtInteger(dtpid, outPID);
    dtInteger(dtid, outID);
    dtInteger(dttype, outType);
    dtString(dtcapt, WideStringToString(outCapt));
    dtString(dtpath, WideStringToString(fullPath));    
    dtReal(dtsize, outSize);
    dtpid.ldata := @dtid;
    dtid.ldata := @dttype;
    dttype.ldata := @dtcapt;
    dtcapt.ldata := @dtsize;
    dtsize.ldata := @dtpath;
    _hi_onEvent_(_event_onEnumAllElements, dtpid);
  end;

  procedure EnumElementsNode(AName: WideString; ParentStg: IStorage; const PID: integer);
  var
    CurrentStg: IStorage;
    Enum: IEnumStatStg;
    StatStg: TStatStg;
    ePID: integer;
    ePath: WideString;
  begin
    if ParentStg = nil then exit;  
    CurrentStg := nil;
    ePID := ID;
    ePath := PPath;
    FillChar(StatStg, SizeOf(StatStg), #0);     
    if _ElementExists(ParentStg, AName, @StatStg) and (StatStg.dwType = STGTY_STORAGE) and _OpenFolder(AName, ParentStg, CurrentStg) then
      if CurrentStg <> nil then
      begin 
        if CurrentStg.EnumElements(0, nil, 0, Enum) = S_OK then
        begin
        TRY
          while Enum.Next(1, StatStg, nil) = S_Ok do
          begin
            ID := ID + 1;
            // если "папка"
            if (StatStg.dwType = STGTY_STORAGE) then
            begin
              PPath := ePath + StatStg.pwcsName + '\'; 
              OutData(ePID, ID, 0, StatStg.pwcsName, 0, PPath);
              EnumElementsNode(StatStg.pwcsName, CurrentStg, ePID);
            end  
            // если "файл"
            else                
              OutData(ePID, ID, 1, StatStg.pwcsName, StatStg.cbSize, ePath + StatStg.pwcsName);
          end;  
        FINALLY
          Enum := nil;
        END;
        end;
      end;
  end;  

begin
  fstop := false;
  if not Assigned(_prop_SStorage_DS) then exit;
  FStorage := _prop_SStorage_DS.GetFRootFolder; 
  FRootStorage := _prop_SStorage_DS.GetFRootStorage;
  if FRootStorage = nil then
    _prop_SStorage_DS.EventError(STG_ERROR_INACCESSIBLESTORAGE)
  else if FStorage = nil then
    _prop_SStorage_DS.EventError(STG_ERROR_INACCESSIBLEROOTFOLDER)
  else if FStorage.EnumElements(0, nil, 0, Enum) = S_OK then
  begin
  TRY
    ID := 1;
    OutData(0, ID, 0, '\', 0, '\');
    while Enum.Next(1, StatStg, nil) = S_Ok do
    begin
      ID := ID + 1;
      // если "папка"
      if StatStg.dwType = STGTY_STORAGE then
      begin
        PPath := StatStg.pwcsName + WideString('\');
        OutData(1, ID, 0, StatStg.pwcsName, 0, PPath);
        EnumElementsNode(StatStg.pwcsName, FStorage, ID);
      end  
      // если "файл"
      else
        OutData(1, ID, 1, StatStg.pwcsName, StatStg.cbSize, StatStg.pwcsName);
      if fstop then break;                        
    end;  
    if fstop and _prop_onBreakEnable then
      _hi_onEvent(_event_onBreak)
    else
      _hi_onEvent(_event_onEndEnumAll);
  FINALLY
    Enum := nil;
  END;
  end
  else
    _prop_SStorage_DS.EventError(STG_ERROR_IMPOSSIBLEENUMELEMENTS);
end;

//==============================================================================
//
//               Перечисление элементов указанного пути Хранилища
//
//==============================================================================

procedure THISTG_Enumerator._work_doInPathEnum;
var
  StatStg: TStatStg;
  Enum: IEnumStatStg;
  FRootStorage: TSStorage;
  FStorage: IStorage;   
  FFileName: WideString;
  TmpFolder: TSStgFolder;
  TmpStg: IStorage;  
  vPath: TSPath;    
  PPath: WideString;
  SPPath: string;
  I: integer;
  res: boolean;
   
  procedure OutData(outPPath: string; outType: integer; outCapt: WideString; outSize: int64 = 0);
  var
    dtppath, dtcapt, dttype, dtsize: TData;  
  begin
    dtString(dtppath, outPPath);
    dtInteger(dttype, outType);
    dtString(dtcapt, WideStringToString(outCapt));
    dtReal(dtsize, outSize);
    dttype.ldata := @dtcapt;
    dtcapt.ldata := @dtsize;
    dtsize.ldata := @dtppath;
    _hi_onEvent_(_event_onInPathEnum, dttype);
  end;

begin
  fstop := false;
  if not Assigned(_prop_SStorage_DS) then exit;
  FFileName := StringToWideString(ReadString(_Data, _data_InPath));

  FRootStorage := _prop_SStorage_DS.GetFRootStorage;
  FStorage := _prop_SStorage_DS.GetFRootFolder;
  if FRootStorage = nil then
    _prop_SStorage_DS.EventError(STG_ERROR_INACCESSIBLESTORAGE)
  else if FStorage = nil then
    _prop_SStorage_DS.EventError(STG_ERROR_INACCESSIBLEROOTFOLDER)
  else if FFileName = '' then
    _prop_SStorage_DS.EventError(STG_ERROR_INCORRECTFILENAME)
  else
  begin
    GetSPath(FFileName, vPath);
    
    if (High(vPath) = 0) and (vPath[High(vPath)] = '') then
      res := FRootStorage.GetWorkFolder(vPath, TmpFolder)
    else
      res := FRootStorage.GetWorkFolder(vPath, TmpFolder, GWF_CURRENT);   
    if res then
    begin
      if TmpFolder <> nil then
        TmpStg := _prop_SStorage_DS.GetFStorage(TmpFolder)
      else
        TmpStg := FStorage;

      PPath := '\';
      for I := 0 to High(vPath) do
        PPath := PPath + vPath[I] + '\'; 
      SPPath := WideStringToString(PPath);
      
      if TmpStg.EnumElements(0, nil, 0, Enum) = S_OK then
      begin
      TRY
        while Enum.Next(1, StatStg, nil) = S_Ok do
        begin
          // если "папка"
          if StatStg.dwType = STGTY_STORAGE then
            OutData(SPPath, 0, StatStg.pwcsName)
          // если "файл"
          else
            OutData(WideStringToString(PPath), 1, StatStg.pwcsName, StatStg.cbSize);
          if fstop then break;                        
        end;  
        if fstop and _prop_onBreakEnable then
          _hi_onEvent(_event_onBreak)
        else
          _hi_onEvent(_event_onEndInPathEnum);
      FINALLY
        Enum := nil;
      END;
      end
      else
        _prop_SStorage_DS.EventError(STG_ERROR_IMPOSSIBLEENUMELEMENTS);
      if TmpFolder <> nil then TmpFolder.Free;  
    end;  
  end;
end;

procedure THISTG_Enumerator._work_doStop;
begin
  fstop := true;
end;

end.
