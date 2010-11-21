unit hiRegistry;

interface

uses Windows,Kol,Share,Debug;

type
  TRegDataType = (rdUnknown, rdString, rdExpandString, rdInteger, rdBinary);
  TRegDataInfo = record
    RegData: TRegDataType;
    DataSize: Integer;
  end;
  THIRegistry = class(TDebug)
   private
    FCurrentKey: HKEY;
    FRootKey: HKEY;
    FLazyWrite: Boolean;
    FCurrentPath: string;
    FCloseRootKey: Boolean;
    FAccess: LongWord;
    st: PObj;
    FStopEnum: boolean;

    procedure CloseKey;
    function OpenKey(const Key: string; CanCreate: Boolean; Access:LongWord): Boolean;
    procedure SetRootKey(Value: HKEY);
    function GetBaseKey(Relative: Boolean): HKey;
    procedure ChangeKey(Value: HKey; const Path: string);

    function ReadValue(var _Data,val:TData):integer;

    function GetData(const Name: string; Buffer: Pointer;
      BufSize: Integer; var RegData: TRegDataType): Integer;
    procedure PutData(const Name: string; Buffer: Pointer; BufSize: Integer; RegData: TRegDataType);
    function GetDataInfo(const ValueName: string; var Value: TRegDataInfo): Boolean;
    function GetDataSize(const ValueName: string): Integer;
    function ReadStr(const Name: string; var Res:integer): string;
    function ReadFloat(const Name: string; var Res:integer): Double;
    function ReadInt(const Name: string; var Res:integer): Integer;
    function _ReadStream(const Name: string; var Res:integer): PStream;
    procedure WriteFloat(const Name: string; Value: Double);
    procedure WriteInteger(const Name: string; Value: Integer);
    procedure WriteString(const Name, Value: string);
    procedure WriteStream(const Name:string; Value: PStream);
    
    procedure RemoveKeyEntryes(const Name:string);
   public
    _prop_HKey:byte;
    _prop_Key:string;
    _prop_Value:string;
    _prop_DataType:byte;
    _prop_NotEmpty:boolean;
    _prop_Data:string;

    _data_Data:THI_Event;
    _data_Key:THI_Event;
    _data_Value:THI_Event;
    _event_onRead:THI_Event;
    _event_onEnumKey:THI_Event;
    _event_onEnumValue:THI_Event;
    _event_onExistsKey:THI_Event;
    _event_onExistsValue:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doRead(var _Data:TData; Index:word);
    procedure _work_doWrite(var _Data:TData; Index:word);
    procedure _work_doDeleteValue(var _Data:TData; Index:word);
    procedure _work_doDeleteKey(var _Data:TData; Index:word);
    procedure _work_doEraseKey(var _Data:TData; Index:word);
    procedure _work_doEnumKeys(var _Data:TData; Index:word);
    procedure _work_doEnumValues(var _Data:TData; Index:word);
    procedure _work_doExistsKey(var _Data:TData; Index:word);
    procedure _work_doExistsValue(var _Data:TData; Index:word);
    procedure _work_doHKey(var _Data:TData; Index:word);
    procedure _work_doStopEnum(var _Data:TData; Index:word);        
    procedure _var_RData(var _Data:TData; Index:word);

    property RootKey: HKEY read FRootKey write SetRootKey;
    property LazyWrite: Boolean read FLazyWrite write FLazyWrite;
    property CurrentKey: HKEY read FCurrentKey;
  end;

implementation

const
 _HKey:array[0..4] of HKEY = (HKEY_CLASSES_ROOT,HKEY_CURRENT_USER,HKEY_LOCAL_MACHINE,HKEY_USERS,HKEY_CURRENT_CONFIG);
 dtypes:array[0..3] of byte = (data_int,data_str,data_real,data_stream);

constructor THIRegistry.Create;
begin
   inherited Create;
   RootKey := HKEY_CURRENT_USER;
   FAccess := KEY_ALL_ACCESS;
   LazyWrite := True;
end;

destructor THIRegistry.Destroy;
begin
   st.free;
   CloseKey;
end;

procedure THIRegistry._work_doHKey;
begin
   _prop_HKey := ToInteger(_Data);
end;

procedure THIRegistry._work_doRead;
var dt:TData;
    res:integer;
begin
   res := ReadValue(_Data,dt);
   if not _prop_NotEmpty or (res=1) then _hi_OnEvent(_event_onRead,dt);
end;

function THIRegistry.ReadValue;
var value:string;
begin
   dtNull(val);
   RootKey := _hkey[_prop_HKey];
   if not OpenKey(ReadString(_Data,_data_Key,_prop_Key),false,KEY_READ) then
    begin
     Result := 0;
     exit;
    end
   else Result := 1;
   value := ReadString(_Data,_data_Value,_prop_Value);

   case dtypes[_prop_DataType] of
    data_int :   dtInteger(val,ReadInt(Value,Result));
    data_str :   dtString(val,ReadStr(Value,Result));
    data_real:   dtReal(val,ReadFloat(Value,Result));
    data_stream: dtStream(val,_ReadStream(Value,Result));
   end;

   CloseKey;
end;

procedure THIRegistry._work_doWrite;
var value:string;
begin
   RootKey := _hkey[_prop_HKey];
   OpenKey(ReadString(_Data,_data_Key,_prop_Key),true,KEY_WRITE);
   value := ReadString(_Data,_data_Value,_prop_Value);
   case dtypes[_prop_DataType] of
    data_int :   WriteInteger(Value,ReadInteger(_Data,_data_Data,Str2Int(_prop_Data)));
    data_str :   WriteString(Value,ReadString(_Data,_data_Data,_prop_Data));
    data_real:   WriteFloat(Value,ReadReal(_Data,_data_Data,Str2Double(_prop_Data)));
    data_stream: WriteStream(Value,ReadStream(_Data,_data_Data,nil));
   end;
   CloseKey;
end;

procedure THIRegistry._work_doDeleteValue;
var k,v:string;
    hk:HKEY;
begin
   RootKey := _hkey[_prop_HKey];
   k := ReadString(_Data,_data_Key,_prop_Key);
   v := ReadString(_Data,_data_Value,_prop_Value);
   hk := kol.RegKeyOpenWrite(RootKey,k);
   kol.RegKeyDeleteValue(hk,v);
   CloseKey;
end;

procedure THIRegistry._work_doDeleteKey;
var k:string;
begin
   RootKey := _hkey[_prop_HKey];
   k := ReadString(_Data,_data_Key,_prop_Key);
   RemoveKeyEntryes(k);
   OpenKey(k,true,KEY_ALL_ACCESS);
   kol.RegKeyDelete(RootKey,k);
   CloseKey;
end;

procedure THIRegistry.RemoveKeyEntryes;
var
    List:PStrList;
    i:smallint;
    hk:HKEY;
begin
    hk := kol.RegKeyOpenWrite(RootKey,Name);
    List := NewStrList;
    kol.RegKeyGetSubKeys(hk,List);
    for i := 0 to List.Count-1 do
     begin
       RemoveKeyEntryes(Name + '\' + List.Items[i]);
       kol.RegKeyDelete(hk,List.Items[i]);
     end;
    List.Free;

    kol.RegKeyDelete(hk,Name);
    kol.RegKeyClose(hk);
end;

procedure THIRegistry._work_doEraseKey;
var k:string;
begin
   RootKey := _hkey[_prop_HKey];
   k := ReadString(_Data,_data_Key,_prop_Key);
   RemoveKeyEntryes(k);
end;

procedure THIRegistry._work_doStopEnum;
begin
  FStopEnum := true;
end;

procedure THIRegistry._work_doEnumKeys;
var
    hk:HKEY;
    List:PStrList;
    i:smallint;
begin
   FStopEnum := false;
   hk := kol.RegKeyOpenRead(_hkey[_prop_HKey],ReadString(_Data,_data_Key,_prop_Key));
   List := NewStrList;
   kol.RegKeyGetSubKeys(hk,List);
   for i := 0 to List.Count-1 do
   begin
    _hi_OnEvent(_event_onEnumKey, List.Items[i]);
    if FStopEnum then break;
   end;
   List.Free;
   kol.RegKeyClose(hk);
end;

procedure THIRegistry._work_doEnumValues;
var hk:HKEY;
    List:PStrList;
    i:smallint;
begin
   FStopEnum := false;
   hk := kol.RegKeyOpenRead(_hkey[_prop_HKey],ReadString(_Data,_data_Key,_prop_Key));
   List := NewStrList;
   kol.RegKeyGetValueNames(hk,List);
   for i := 0 to List.Count-1 do
   begin
    _hi_OnEvent(_event_onEnumValue, List.Items[i]);
    if FStopEnum then break;
   end;
   List.Free;
   kol.RegKeyClose(hk);
end;


procedure THIRegistry._work_doExistsValue;
var hk:HKEY;
    k,v:string;
begin
   k := ReadString(_Data,_data_Key,_prop_Key);
   v := ReadString(_Data,_data_Value,_prop_Value);
   hk := kol.RegKeyOpenRead(_hkey[_prop_HKey],k);
   _hi_CreateEvent(_Data,@_event_onExistsValue,byte(kol.RegKeyValExists(hk,v)));
   kol.RegKeyClose(hk);
end;

procedure THIRegistry._work_doExistsKey;
var hk:HKEY;
    k:string;
begin
   k := ReadString(_Data,_data_Key,_prop_Key);
   hk := kol.RegKeyOpenRead(_hkey[_prop_HKey],k);
   _hi_CreateEvent(_Data,@_event_onExistsKey,byte(hk > 0));
   kol.RegKeyClose(hk);
end;

procedure THIRegistry._var_RData;
begin
   ReadValue(_Data,_Data);
end;

procedure THIRegistry.SetRootKey(Value: HKEY);
begin
  if RootKey <> Value then
  begin
    if FCloseRootKey then
    begin
      RegCloseKey(RootKey);
      FCloseRootKey := False;
    end;
    FRootKey := Value;
    CloseKey;
  end;
end;

procedure THIRegistry.CloseKey;
begin
  if CurrentKey <> 0 then
  begin
    if LazyWrite then
      RegCloseKey(CurrentKey) else
      RegFlushKey(CurrentKey);
    FCurrentKey := 0;
    FCurrentPath := '';
  end;
end;

function IsRelative(const Value: string): Boolean;
begin
  Result := not ((Value <> '') and (Value[1] = '\'));
end;

function THIRegistry.OpenKey;
var
  TempKey: HKey;
  S: string;
  Disposition: Integer;
  Relative: Boolean;
begin
  S := Key;
  Relative := IsRelative(S);

  if not Relative then Delete(S, 1, 1);
  TempKey := 0;
  if not CanCreate or (S = '') then begin
    Result := RegOpenKeyEx(GetBaseKey(Relative), PChar(S), 0,
      Access, TempKey) = ERROR_SUCCESS;
  end else
    Result := RegCreateKeyEx(GetBaseKey(Relative), PChar(S), 0, nil,
      REG_OPTION_NON_VOLATILE, Access, nil, TempKey, @Disposition) = ERROR_SUCCESS;
  if Result then begin
    if (CurrentKey <> 0) and Relative then S := FCurrentPath + '\' + S;
    ChangeKey(TempKey, S);
  end;
end;

function THIRegistry.GetBaseKey(Relative: Boolean): HKey;
begin
  if (CurrentKey = 0) or not Relative then
    Result := RootKey
  else
    Result := CurrentKey;
end;

procedure THIRegistry.ChangeKey(Value: HKey; const Path: string);
begin
  CloseKey;
  FCurrentKey := Value;
  FCurrentPath := Path;
end;

function DataTypeToRegData(Value: Integer): TRegDataType;
begin
  if Value = REG_SZ then Result := rdString
  else if Value = REG_EXPAND_SZ then Result := rdExpandString
  else if Value = REG_DWORD then Result := rdInteger
  else if Value = REG_BINARY then Result := rdBinary
  else Result := rdUnknown;
end;

function THIRegistry.GetData(const Name: string; Buffer: Pointer;
  BufSize: Integer; var RegData: TRegDataType): Integer;
var
  DataType: Integer;
begin
  DataType := REG_NONE;
  if RegQueryValueEx(CurrentKey, PChar(Name), nil, @DataType, PByte(Buffer),
    @BufSize) <> ERROR_SUCCESS then begin result := -1; exit; end;
  Result := BufSize;
  RegData := DataTypeToRegData(DataType);
end;

function RegDataToDataType(Value: TRegDataType): Integer;
begin
  case Value of
    rdString: Result := REG_SZ;
    rdExpandString: Result := REG_EXPAND_SZ;
    rdInteger: Result := REG_DWORD;
    rdBinary: Result := REG_BINARY;
  else
    Result := REG_NONE;
  end;
end;

procedure THIRegistry.PutData(const Name: string; Buffer: Pointer;
  BufSize: Integer; RegData: TRegDataType);
var
  DataType: Integer;
begin
  DataType := RegDataToDataType(RegData);
  if RegSetValueEx(CurrentKey, PChar(Name), 0, DataType, Buffer,
    BufSize) <> ERROR_SUCCESS then
     _debug('Ќе удалось произвести запись в реестр') ;
end;

function THIRegistry.GetDataInfo(const ValueName: string; var Value: TRegDataInfo): Boolean;
var
  DataType: Integer;
begin
  FillChar(Value, SizeOf(TRegDataInfo), 0);
  Result := RegQueryValueEx(CurrentKey, PChar(ValueName), nil, @DataType, nil,
    @Value.DataSize) = ERROR_SUCCESS;
  Value.RegData := DataTypeToRegData(DataType);
end;

function THIRegistry.GetDataSize(const ValueName: string): Integer;
var
  Info: TRegDataInfo;
begin
  if GetDataInfo(ValueName, Info) then
    Result := Info.DataSize else
    Result := -1;
end;

function THIRegistry.ReadStr;
var
  Len: Integer;
  RegData: TRegDataType;
begin
  Len := GetDataSize(Name);
  if Len > 0 then
  begin
    SetString(Result, nil, Len);
    GetData(Name, PChar(Result), Len, RegData);
    if (RegData = rdString) or (RegData = rdExpandString) then
      SetLength(Result, StrLen(PChar(Result)));
    Res := 1;
  end
  else begin Result := ''; res := 0; end;
end;

function THIRegistry.ReadFloat;
var
  RegData: TRegDataType;
begin
  if GetData(Name, @Result, SizeOf(Double), RegData) = -1 then
    begin
      Result := 0;
      res := 0;
    end
  else res := 1;
end;

function THIRegistry.ReadInt;
var
  RegData: TRegDataType;
begin
  if GetData(Name, @Result, SizeOf(Integer), RegData) = -1 then
    begin
      Result := 0;
      res := 0;
    end
  else res := 1;
end;

function THIRegistry._ReadStream;
var
  Len: Integer;
  RegData: TRegDataType;
  _Res:string;
begin
  Len := GetDataSize(Name);
  if Len > 0 then
  begin
    st.free; Result := NewMemoryStream; st := Result;
    SetString(_Res, nil, Len);
    GetData(Name, PChar(_Res), Len, RegData);
    Result.Write(_Res[1],Len);
    Result.Position := 0;
    Res := 1;
  end
  else begin Result := nil; res := 0; end;
end;

procedure THIRegistry.WriteFloat(const Name: string; Value: Double);
begin
  PutData(Name, @Value, SizeOf(Double), rdBinary);
end;

procedure THIRegistry.WriteInteger(const Name: string; Value: Integer);
begin
  PutData(Name, @Value, SizeOf(Integer), rdInteger);
end;

procedure THIRegistry.WriteString(const Name, Value: string);
begin
  PutData(Name, PChar(Value), Length(Value)+1, rdString);
end;

procedure THIRegistry.WriteStream;
begin
  if Value <> nil then
   PutData(Name, Value.Memory, Value.Size, rdBinary);
end;

end.
