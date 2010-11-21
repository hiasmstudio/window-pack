unit hiSTG_AddFileTo;

interface

uses
   Windows, Messages, ActiveX, KolComObj, Kol, Share, Debug, hiSStorage_DS;

type
  THISTG_AddFileTo = class(TDebug)
   private
   public
    _prop_SStorage_DS: PISStorage_DS;

    _data_InPath,
    _data_IsFileExists,
    _data_SrcStream,
    _event_onAddFileTo:THI_Event;

    procedure _work_doAddFileTo(var _Data:TData; Index:word);
  end;

implementation

//==============================================================================
//
//                               Добавление файла
//
//==============================================================================

procedure THISTG_AddFileTo._work_doAddFileTo;
var
  FFileName: WideString;
  FStrm: PStream;
  Strm: TOLEStream;
  Buffer: Pointer;
  vPath: TSPath;
  WriteSize: integer;
  FRootStorage: TSStorage;
begin
  if not Assigned(_prop_SStorage_DS) then exit;
  FFileName := StringToWideString(ReadString(_Data, _data_InPath));
  FStrm := ReadStream(_Data, _data_SrcStream);
  FRootStorage := _prop_SStorage_DS.GetFRootStorage;
  if FRootStorage = nil then
    _prop_SStorage_DS.EventError(STG_ERROR_INACCESSIBLESTORAGE)
  else if FFileName = '' then
    _prop_SStorage_DS.EventError(STG_ERROR_INCORRECTFILENAME)
  else if FStrm = nil then
    _prop_SStorage_DS.EventError(STG_ERROR_INACCESSIBLESRCSTREAM)
  else
  begin
    GetSPath(FFileName, vPath);
    if FRootStorage.StgPathExists(FFileName) then
      if  ReadInteger(_Data, _data_IsFileExists) = 0 then
      begin
        Strm := FRootStorage.StgOpenFile(FFileName);
        Strm.Size := FStrm.Size;
      end  
      else
      begin
        _prop_SStorage_DS.EventError(STG_ERROR_IMPOSSIBLEADDFILE);
        exit;
      end
    else
      Strm := FRootStorage.StgCreateFile(FFileName);

    if Strm <> nil then
    begin
      GetMem(Buffer, FStrm.Size);
      TRY
        FStrm.Position := 0;
        FStrm.Read(Buffer^, FStrm.Size);
        Strm.Size := FStrm.Size;
        WriteSize := Strm.Write(Pointer(Buffer), FStrm.Size);
      FINALLY
        FreeMem(Buffer);
      END;
      Strm.free;
      _hi_onEvent(_event_onAddFileTo, WriteSize);
    end;
  end;
end;

end.