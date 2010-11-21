unit hiCeRegistry;

interface

uses Windows,Kol,KolRapi,Share,Debug;

type
  TRegDataType = (rdUnknown, rdString, rdExpandString, rdInteger, rdBinary);
  TRegDataInfo = record
    RegData: TRegDataType;
    DataSize: Integer;
  end;
  THICeRegistry = class(TDebug)
   private
    FCurrentKey: HKEY;
    FRootKey: HKEY;
    FCurrentPath: string;
    FCloseRootKey: Boolean;
    st: PObj;

    procedure CloseKey;
    function OpenKey(const Key: string; CanCreate: Boolean): Boolean;
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
    //function CeRegKeyGetSubKeys( const Key: HKEY; List: PStrList) : Boolean;
    //function CeRegKeyGetValueNames(const Key: HKEY; List: PStrList): Boolean;
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
    procedure _var_RData(var _Data:TData; Index:word);
    procedure _var_DataType(var _Data:TData; Index:word);

    property RootKey: HKEY read FRootKey write SetRootKey;
    property CurrentKey: HKEY read FCurrentKey;
  end;

implementation

const
 _HKey:array[0..2] of HKEY = (HKEY_CLASSES_ROOT,HKEY_CURRENT_USER,HKEY_LOCAL_MACHINE);
 dtypes:array[0..3] of byte = (data_int,data_str,data_real,data_stream);

constructor THICeRegistry.Create;
begin
   inherited Create;
   RootKey := HKEY_CURRENT_USER;
end;

destructor THICeRegistry.Destroy;
begin
   st.free;
   CloseKey;
end;

procedure THICeRegistry._work_doRead;
var dt:TData;
    res:integer;
begin
   res := ReadValue(_Data,dt);
   if not _prop_NotEmpty or (res = 1) then _hi_OnEvent(_event_onRead,dt);
end;

function THICeRegistry.ReadValue;
var value:string;
begin
   dtNull(val);
   RootKey := _hkey[_prop_HKey];
   if not OpenKey(ReadString(_Data,_data_Key,_prop_Key),false) then
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

procedure THICeRegistry._work_doWrite;
var value:string;
begin
   RootKey := _hkey[_prop_HKey];
   OpenKey(ReadString(_Data,_data_Key,_prop_Key),true);
   value := ReadString(_Data,_data_Value,_prop_Value);
   case dtypes[_prop_DataType] of
    data_int :   WriteInteger(Value,ReadInteger(_Data,_data_Data,Str2Int(_prop_Data)));
    data_str :   WriteString(Value,ReadString(_Data,_data_Data,_prop_Data));
    data_real:   WriteFloat(Value,ReadReal(_Data,_data_Data,Str2Double(_prop_Data)));
    data_stream: WriteStream(Value,ReadStream(_Data,_data_Data,nil));
   end;
   CloseKey;
end;

procedure THICeRegistry._work_doDeleteValue;
var k,v:string;
    hk:HKEY;
begin
   RootKey := _hkey[_prop_HKey];
   k := ReadString(_Data,_data_Key,_prop_Key);
   v := ReadString(_Data,_data_Value,_prop_Value);
   if CeRegOpenKeyEx(RootKey,StringToOleStr(k),0,0,hk) = ERROR_SUCCESS then
   CeRegDeleteValue(hk,StringToOleStr(v));
   CloseKey;
end;

procedure THICeRegistry._work_doDeleteKey;
var k:string;
begin
   RootKey := _hkey[_prop_HKey];
   k := ReadString(_Data,_data_Key,_prop_Key);
   RemoveKeyEntryes(k);
   OpenKey(k,true);
   CeRegDeleteKey(RootKey,StringToOleStr(k));
   CloseKey;
end;

function CeRegKeyGetSubKeys( const Key: HKEY; List: PStrList) : Boolean;
var
  I, Size, NumSubKeys, MaxSubKeyLen : DWORD;
  KeyName: array[0..MAX_PATH - 1] of WideChar;
begin
  Result := False;
  List.Clear ;
  if CeRegQueryInfoKey(Key, nil, nil, nil, @NumSubKeys, @MaxSubKeyLen, nil, nil, nil, nil,
nil, nil) = ERROR_SUCCESS then
    begin
      if NumSubKeys > 0 then begin
        for I := 0 to NumSubKeys - 1 do
        begin
          Size := MaxSubKeyLen + 1;
          CeRegEnumKeyEx(Key, I, @KeyName, Size, nil, nil, nil, nil);
          List.Add(LStrFromPWCharLen(@KeyName,Size*2+1));
        end;
      end;
      Result:= True;
  end;
end;

function CeRegKeyGetValueNames(const Key: HKEY; List: PStrList): Boolean;
var
  I, Size, NumSubKeys, NumValueNames, MaxValueNameLen: DWORD;
  ValueName: array[0..MAX_PATH - 1] of WideChar;
begin
  List.Clear ;
  Result := False;
  if CeRegQueryInfoKey(Key, nil, nil, nil, @NumSubKeys, nil, nil, @NumValueNames,
@MaxValueNameLen, nil, nil, nil) = ERROR_SUCCESS then
  begin
     if NumValueNames > 0 then
        for I := 0 to NumValueNames - 1 do begin
          Size := MaxValueNameLen + 1;
          CeRegEnumValue(Key, I, @ValueName, Size, nil, nil, nil, nil);
          List.Add(LStrFromPWCharLen(ValueName,Size*2+1));
        end;
     Result := True;
  end ;
end;

procedure THICeRegistry.RemoveKeyEntryes;
var
    List:PStrList;
    i:smallint;
    hk:HKEY;
begin
  if CeRegOpenKeyEx(RootKey,StringToOleStr(Name),0,0,hk) = ERROR_SUCCESS
  then begin
    List := NewStrList;
    CeRegKeyGetSubKeys(hk,List);
    for i := 0 to List.Count-1 do
     begin
       RemoveKeyEntryes(Name + '\' + List.Items[i]);
       CeRegDeleteKey(hk,StringToOleStr(List.Items[i]));
     end;
    List.Free;
    CeRegDeleteKey(hk,StringToOleStr(Name));
    CeRegCloseKey(hk);
  end;
end;

procedure THICeRegistry._work_doEraseKey;
var k:string;
begin
   RootKey := _hkey[_prop_HKey];
   k := ReadString(_Data,_data_Key,_prop_Key);
   RemoveKeyEntryes(k);
end;

procedure THICeRegistry._work_doEnumKeys;
var
    hk:HKEY;
    List:PStrList;
    i:smallint;
begin
   if CeRegOpenKeyEx(_hkey[_prop_HKey], StringToOleStr(ReadString(_Data,_data_Key,_prop_Key)), 0, 0, hk) = ERROR_SUCCESS
   then begin
    List := NewStrList;
    CeRegKeyGetSubKeys(hk,List);
    for i := 0 to List.Count-1 do
     _hi_OnEvent(_event_onEnumKey,List.Items[i]);
    List.Free;
    CeRegCloseKey(hk);
   end;
end;

procedure THICeRegistry._work_doEnumValues;
var hk:HKEY;
    List:PStrList;
    i:smallint;
begin
   if CeRegOpenKeyEx(_hkey[_prop_HKey], StringToOleStr(ReadString(_Data,_data_Key,_prop_Key)), 0, 0, hk) = ERROR_SUCCESS
   then begin
    List := NewStrList;
    CeRegKeyGetValueNames(hk,List);
    for i := 0 to List.Count-1 do
     _hi_OnEvent(_event_onEnumValue,List.Items[i]);
    List.Free;
    CeRegCloseKey(hk);
   end;
end;

procedure THICeRegistry._work_doExistsValue;
var hk:HKEY;
    k,v:string;
    boolres:boolean;
    dwType, dwSize: DWORD;
begin
   k := ReadString(_Data,_data_Key,_prop_Key);
   v := ReadString(_Data,_data_Value,_prop_Value);
   boolres := false;
   if CeRegOpenKeyEx(_hkey[_prop_HKey], StringToOleStr(k), 0, 0, hk) = ERROR_SUCCESS
    then begin
     if CeRegQueryValueEx(hk, StringToOleStr(v), nil, @dwType, nil, @dwSize) = ERROR_SUCCESS
      then boolres := true;
     CeRegCloseKey(hk);
    end;
   _hi_CreateEvent(_Data,@_event_onExistsValue,byte(boolres));
end;

procedure THICeRegistry._work_doExistsKey;
var hk:HKEY;
    k:string;
    boolres:boolean;
begin
   k := ReadString(_Data,_data_Key,_prop_Key);
   boolres := false;
   if CeRegOpenKeyEx(_hkey[_prop_HKey], StringToOleStr(k), 0, 0, hk) = ERROR_SUCCESS
    then begin
     boolres := true;
     CeRegCloseKey(hk);
    end;
   _hi_CreateEvent(_Data,@_event_onExistsKey,byte(boolres));
end;

procedure THICeRegistry._var_RData;
begin
   ReadValue(_Data,_Data);
end;

procedure THICeRegistry._var_DataType;
var hk:HKEY;
    vDataType,vDataSize,rType: Integer;
begin
  if CeRegOpenKeyEx(_hkey[_prop_HKey],StringToOleStr(ReadString(_Data,_data_Key,_prop_Key)),
    0,0,hk) = ERROR_SUCCESS then
  begin
  if CeRegQueryValueEx(hk, StringToOleStr(ReadString(_Data,_data_Value,_prop_Value)),
   nil, @vDataType, nil, @vDataSize) = ERROR_SUCCESS then
    begin
      case vDataType of
        REG_DWORD:     rType := 0;
        REG_SZ:        rType := 1;
        REG_EXPAND_SZ: rType := 1;
        REG_BINARY:    rType := 2;
      end;
      dtInteger(_Data,rType);
    end else dtNull(_Data);
  CeRegCloseKey(hk);
  end else dtNull(_Data);
end;

procedure THICeRegistry.SetRootKey(Value: HKEY);
begin
  if RootKey <> Value then
  begin
    if FCloseRootKey then
    begin
      CeRegCloseKey(RootKey);
      FCloseRootKey := False;
    end;
    FRootKey := Value;
    CloseKey;
  end;
end;

procedure THICeRegistry.CloseKey;
begin
  if CurrentKey <> 0 then
  begin
    CeRegCloseKey(CurrentKey);
    FCurrentKey := 0;
    FCurrentPath := '';
  end;
end;

function IsRelative(const Value: string): Boolean;
begin
  Result := not ((Value <> '') and (Value[1] = '\'));
end;

function THICeRegistry.OpenKey;
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
  if not CanCreate or (S = '') then
    Result := CeRegOpenKeyEx(GetBaseKey(Relative), StringToOleStr(S), 0,
      0, TempKey) = ERROR_SUCCESS
  else
    Result := CeRegCreateKeyEx(GetBaseKey(Relative), StringToOleStr(S), 0, nil,
      0, 0, nil, TempKey, @Disposition) = ERROR_SUCCESS;
  if Result then begin
    if (CurrentKey <> 0) and Relative then S := FCurrentPath + '\' + S;
    ChangeKey(TempKey, S);
  end;
end;

function THICeRegistry.GetBaseKey(Relative: Boolean): HKey;
begin
  if (CurrentKey = 0) or not Relative then
    Result := RootKey
  else
    Result := CurrentKey;
end;

procedure THICeRegistry.ChangeKey(Value: HKey; const Path: string);
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

function THICeRegistry.GetData(const Name: string; Buffer: Pointer;
  BufSize: Integer; var RegData: TRegDataType): Integer;
var
  DataType: Integer;
begin
  DataType := REG_NONE;
  if CeRegQueryValueEx(CurrentKey, StringToOleStr(Name), nil, @DataType,
    PByte(Buffer), @BufSize) <> ERROR_SUCCESS then begin result := -1; exit; end;
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

procedure THICeRegistry.PutData(const Name: string; Buffer: Pointer;
  BufSize: Integer; RegData: TRegDataType);
var
  DataType: Integer;
begin
  DataType := RegDataToDataType(RegData);
  if CeRegSetValueEx(CurrentKey, StringToOleStr(Name), 0, DataType, Buffer,
    BufSize) <> ERROR_SUCCESS then
     _debug('Ќе удалось произвести запись в реестр') ;
end;

function THICeRegistry.GetDataInfo(const ValueName: string; var Value: TRegDataInfo): Boolean;
var
  DataType: Integer;
begin
  FillChar(Value, SizeOf(TRegDataInfo), 0);
  Result := CeRegQueryValueEx(CurrentKey, StringToOleStr(ValueName), nil, @DataType, nil,
    @Value.DataSize) = ERROR_SUCCESS;
  Value.RegData := DataTypeToRegData(DataType);
end;

function THICeRegistry.GetDataSize(const ValueName: string): Integer;
var
  Info: TRegDataInfo;
begin
  if GetDataInfo(ValueName, Info) then
    Result := Info.DataSize else
    Result := -1;
end;

function THICeRegistry.ReadStr;
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

function THICeRegistry.ReadFloat;
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

function THICeRegistry.ReadInt;
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

function THICeRegistry._ReadStream;
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

procedure THICeRegistry.WriteFloat(const Name: string; Value: Double);
begin
  PutData(Name, @Value, SizeOf(Double), rdBinary);
end;

procedure THICeRegistry.WriteInteger(const Name: string; Value: Integer);
begin
  PutData(Name, @Value, SizeOf(Integer), rdInteger);
end;

procedure THICeRegistry.WriteString(const Name, Value: string);
begin
  PutData(Name, PChar(Value), Length(Value)+1, rdString);
end;

procedure THICeRegistry.WriteStream;
begin
  if Value <> nil then
   PutData(Name, Value.Memory, Value.Size, rdBinary);
end;

end.
