unit hiSTG_ExtractFileFrom;

interface

uses
   Windows, Messages, ActiveX, KolComObj, Kol, Share, Debug, hiSStorage_DS;

type
  THISTG_ExtractFileFrom = class(TDebug)
   private
     FStrm: PStream;
   public
    _prop_SStorage_DS: PISStorage_DS;

    _data_InPath,
    _event_onExtractFileFrom:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doExtractFileFrom(var _Data:TData; Index:word);
    procedure _work_doPosExtractStream(var _Data:TData; Index:word);
    procedure _var_ExtractStream(var _Data:TData; Index:word);
    procedure _var_ExtractStreamSize(var _Data:TData; Index:word);
    procedure _var_PosExtractStream(var _Data:TData; Index:word);
  end;

implementation

constructor THISTG_ExtractFileFrom.Create;
begin
  inherited;
  FStrm := NewMemoryStream;
end;

destructor THISTG_ExtractFileFrom.Destroy;
begin
  FStrm.free; 
  inherited;
end;

//==============================================================================
//
//                                Извлечение файла
//
//==============================================================================

procedure THISTG_ExtractFileFrom._work_doExtractFileFrom;
var
  FFileName: WideString;
  Strm: TOLEStream;
  Buffer: Pointer;
  FRootStorage: TSStorage;
begin
  if not Assigned(_prop_SStorage_DS) then exit;
  FFileName := StringToWideString(ReadString(_Data, _data_InPath));
  FRootStorage := _prop_SStorage_DS.GetFRootStorage;
 
  if FRootStorage = nil then
    _prop_SStorage_DS.EventError(STG_ERROR_INACCESSIBLESTORAGE)
  else if FFileName = '' then
    _prop_SStorage_DS.EventError(STG_ERROR_INCORRECTFILENAME)
  else
  begin
    Strm := FRootStorage.StgOpenFile(FFileName);
    if Strm <> nil then
    begin;
      FStrm.Size := Strm.Size;
      Buffer := FStrm.Memory;
      FStrm.Size := Strm.Read(Pointer(Buffer), Strm.Size);
      FStrm.Position := 0;
      _hi_onEvent(_event_onExtractFileFrom, FStrm);
      Strm.free;
    end;
  end;
end;

//==============================================================================
//
//          Позиционирование указателя извлеченного файлового потока
//
//==============================================================================

procedure THISTG_ExtractFileFrom._work_doPosExtractStream;
begin
  if FStrm = nil then exit;
  FStrm.Position := ToInteger(_Data);
end;

//==============================================================================
//
//                   Доступ к файловому потоку извлеченных данных
//
//==============================================================================

procedure THISTG_ExtractFileFrom._var_ExtractStream;
begin
  if FStrm <> nil then
    dtStream(_Data, FStrm)
  else
    dtNull(_Data);
end;

//==============================================================================
//
//                Доступ к размеру извлеченного файлового потока
//
//==============================================================================

procedure THISTG_ExtractFileFrom._var_ExtractStreamSize;
begin
  if FStrm <> nil then
    dtInteger(_Data, FStrm.Size)
  else
    dtNull(_Data);
end;

//==============================================================================
//
//          Доступ к позиции указателя извлеченного файлового потока
//
//==============================================================================

procedure THISTG_ExtractFileFrom._var_PosExtractStream;
begin
  if FStrm <> nil then
    dtInteger(_Data, FStrm.Position)
  else
    dtNull(_Data);
end;

end.