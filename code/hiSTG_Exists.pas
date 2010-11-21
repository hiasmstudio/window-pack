unit hiSTG_Exists;

interface

uses
   Windows, Messages, ActiveX, KolComObj, Kol, Share, Debug, hiSStorage_DS;

type
  THISTG_Exists = class(TDebug)
   private
     FType: integer;
   public
    _prop_SStorage_DS: PISStorage_DS;

    _data_InPath,
    _event_onExists:THI_Event;

    procedure _work_doExists(var _Data:TData; Index:word);
    procedure _var_Type(var _Data:TData; Index:word);
  end;

implementation

//==============================================================================
//
//                          Проверка наличия элемента
//
//==============================================================================
procedure THISTG_Exists._work_doExists;
var
  FFileName: WideString;
  I: Integer;
  vPath: TSPath;
  FRootStorage: TSStorage;
  FStorage: IStorage;

  function DoFind(Stg: IStorage): integer;
  var
    TmpStg: IStorage;
    StatStg: TStatStg;
  begin
    Result := -1;
    FillChar(StatStg, SizeOf(StatStg), #0);     
    if (I = High(vPath)) then
    begin
      if _ElementExists(Stg, vPath[I], @StatStg) then
      case StatStg.dwType of
        STGTY_STORAGE: Result := 0;
      else
        Result := 1;
      end;
    end
    else if _ElementExists(Stg, vPath[I], @StatStg) and (StatStg.dwType = STGTY_STORAGE) and _OpenFolder(vPath[I], Stg, TmpStg) then
    begin
      Inc(I);
      Result := DoFind(TmpStg);
    end;
  end;

begin
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
    FType := -1;
    I := 0;
    GetSPath(FFileName, vPath);
    if (vPath <> nil) then
    begin
      if vPath[High(vPath)] = '' then
        FType := 3
      else
        FType := DoFind(FStorage);
      _hi_onEvent(_event_onExists, FType);
    end
    else
      _hi_onEvent(_event_onExists, FType);
  end
end;
//==============================================================================
//
//                           Доступ к типу элемента
//
//==============================================================================

procedure THISTG_Exists._var_Type;
begin
  dtInteger(_Data, FType);
end;

end.