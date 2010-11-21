unit HiDiskInfo;  { Компонент DiskInfo (компонент для определения параметров логических дисков) ver 1.30 }

interface

uses Windows,KOL,KOLComObj,ActiveX,Share,Debug;

const STGM_default =STGM_READWRITE + STGM_SHARE_EXCLUSIVE;
      STGM_BASE    =STGM_READ + STGM_SHARE_EXCLUSIVE;

type
  TScriptLanguage = (slVBScript, slJScript);
  
type
  THiDiskInfo = class(TDebug)
   private
      Description        : string;
      FileSystem         : string;
      DeviceID           : string;
      DriveType          : string;
      ClusterSize        : string;
      FullSize           : string;
      OccupiedSpace      : string;
      FreeSpace          : string;
      VolumeName         : string;
      VolumeSerialNumber : string;            
      OldErrorMode       : Word;
            
      IdArray : PArray;
      FListId : PStrList;
      function _GetId(Var Item:TData; var Val:TData):boolean;
      function _CountId:integer;    

   public
      _prop_Computer: string;
      _prop_Query: string; 
      _data_Computer: THI_Event;
      _data_Query: THI_Event;
      _event_onInfo: THI_Event;
      _data_ID: THI_Event;
      _event_onErr: THI_Event;      
      constructor Create;
      destructor Destroy; override;      
      procedure _work_doInfo(var _Data:TData; Index:word);
      procedure _work_doArrayId(var _Data:TData; Index:word);

      procedure _var_Description(var _Data:TData; Index:word);
      procedure _var_FileSystem(var _Data:TData; Index:word);
      procedure _var_DeviceID(var _Data:TData; Index:word);
      procedure _var_DriveType(var _Data:TData; Index:word);
      procedure _var_ClusterSize(var _Data:TData; Index:word);
      procedure _var_FullSize(var _Data:TData; Index:word);
      procedure _var_OccupiedSpace(var _Data:TData; Index:word);
      procedure _var_FreeSpace(var _Data:TData; Index:word);
      procedure _var_VolumeName(var _Data:TData; Index:word);
      procedure _var_SerialNumber(var _Data:TData; Index:word);
      procedure _var_IdArray(var _Data:TData; Index:word);

 end;

implementation

function Trim(s:string; d:string = ' '): string;
var   st :integer;
begin
   if Length(s) > 0 then begin
      st := 1;
      while (st <= Length(s))and(s[st] = d[1]) do inc(st);
      delete(s,1,st-1);
      st := Length(s);
      while (st > 0)and(s[st] = d[1]) do dec(st);
      delete(s,st+1,Length(s) - st);
   end;
   Result := s;
end;

const
  NULL_GUID: TGUID = '{00000000-0000-0000-0000-000000000000}';

var
  ScriptCLSIDs: array[TScriptLanguage] of TGUID;

const
  ScriptProgIDs: array[TScriptLanguage] of PWideChar = (
    'VBScript',
    'JScript'
  );

procedure InitCLSIDs;
var
  L: TScriptLanguage;
begin
  for L := Low(TScriptLanguage) to High(TScriptLanguage) do
    if CLSIDFromProgID(ScriptProgIDs[L], ScriptCLSIDs[L]) <> S_OK
      then ScriptCLSIDs[L] := NULL_GUID;
end;

constructor THiDiskInfo.Create;
begin
   inherited;
   OleInit;
   InitCLSIDs;
   FListId := NewStrList;
end;

destructor THiDiskInfo.Destroy;
begin
   if IdArray <> nil then Dispose(IdArray);
   OleUnInit;
   inherited;
end;

function GetObject(const name:string; accs:dword=STGM_default): Variant;
var   err:HResult;
      bo:tBINDOPTS;
      res:IDispatch;
      nm:widestring;
begin
   nm := name;
   fillchar(bo,sizeof(bo),0);
   with bo do begin cbStruct := sizeof(bo);
      grfFlags := BIND_MAYBOTHERUSER;
      grfMode := accs;
   end;
   err := CoGetObject(  @nm[1] , @bo , IDispatch , @res );
   OleCheck(err);
   Result := res;
end;

procedure THiDiskInfo._work_doArrayId;
var   objService : Variant;
      objLogicalDisk : Variant;
      colLogicalDisk : Variant;
      oEnum : IEnumvariant;
      iValue : PLongint;
      sComputer : string;
begin
   sComputer := ReadString(_Data,_data_Computer,_prop_Computer);
   if sComputer = '' then sComputer := '.'; 
   FListId.Clear;
   objService := GetObject('winmgmts:{impersonationLevel=impersonate}!\\' + sComputer + '\root\CIMV2');
   if VarIsEmpty(objService) then begin
      _hi_CreateEvent(_Data, @_event_onErr);
      exit; 
   end;
   colLogicalDisk := objService.ExecQuery('SELECT DeviceID FROM Win32_LogicalDisk');   
   oEnum := IUnknown(colLogicalDisk._NewEnum) as IEnumVariant;
   iValue := nil;
   while oEnum.Next(1,objLogicalDisk,iValue) = 0 do begin
      FlistId.Add(Trim(VarToStr(objLogicalDisk.DeviceID)));
      objLogicalDisk := Unassigned;
   end;
end;

procedure THiDiskInfo._work_doInfo;
var   objService: Variant;
      objLogicalDisk: Variant; 
      colLogicalDisk: Variant;
      oEnum : IEnumvariant;
      iValue : PLongint;
      sDevice : string;
      sComputer :string;
      sQuery : string;
      SectorsPerCluster:Dword;
      BytesPerSector:Dword;
      NumberOfFreeClusters:Dword;
      TotalNumberOfClusters:Dword;
      dt: TData;
begin
   dtNull(dt);
   sComputer := ReadString(dt,_data_Computer,_prop_Computer);
   if sComputer = '' then sComputer := '.'; 
   sQuery := Trim(ReadString(dt,_data_Query,_prop_Query),',');
   sDevice := ReadString(_Data, _data_Id,'');
   if sQuery = '' then sQuery := '*';

   objService := GetObject('winmgmts:{impersonationLevel=impersonate}!\\' + sComputer + '\root\CIMV2');
   if VarIsEmpty(objService) then begin
      _hi_CreateEvent(_Data, @_event_onErr);
      exit; 
   end;
   if length(sDevice) > 0 then sDevice := ' WHERE DeviceID = "' + Copy(sDevice,1,1) + ':"';
   colLogicalDisk := objService.ExecQuery('Select ' + sQuery + ' from Win32_LogicalDisk' + sDevice);   
   oEnum := IUnknown(colLogicalDisk._NewEnum) as IEnumVariant;
   iValue := nil;
   while oEnum.Next(1,objLogicalDisk,iValue) = 0 do begin
      DeviceID           := Trim(VarToStr(objLogicalDisk.DeviceID));
      Description        := Trim(VarToStr(objLogicalDisk.Description));
      FileSystem         := Trim(VarToStr(objLogicalDisk.FileSystem));
      DriveType          := Trim(VarToStr(objLogicalDisk.DriveType));
      FullSize           := Trim(VarToStr(objLogicalDisk.Size));
      FreeSpace          := Trim(VarToStr(objLogicalDisk.FreeSpace));
      if (FullSize <> '') and (FreeSpace <> '') then
         OccupiedSpace   := Trim(VarToStr(objLogicalDisk.Size - objLogicalDisk.FreeSpace))
      else 
         OccupiedSpace   := ''; 
      VolumeName         := Trim(VarToStr(objLogicalDisk.VolumeName));
      VolumeSerialNumber := Trim(VarToStr(objLogicalDisk.VolumeSerialNumber));

      SectorsPerCluster  := 0;
      BytesPerSector     := 0;   
      OldErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
      if sComputer = '.' then
         GetDiskFreeSpace(PChar(DeviceID), SectorsPerCluster, BytesPerSector, NumberOfFreeClusters, TotalNumberOfClusters);
      ClusterSize := int2str(SectorsPerCluster * BytesPerSector);
      if ClusterSize = '0' then ClusterSize := ''; 
      SetErrorMode(OldErrorMode);
      _hi_onEvent(_event_onInfo);
      objLogicalDisk := Unassigned;
   end;
end;

procedure THiDiskInfo._var_Description;begin dtString(_Data,Description);end;
procedure THiDiskInfo._var_FileSystem;begin dtString(_Data,FileSystem);end;
procedure THiDiskInfo._var_DeviceID;begin dtString(_Data,DeviceID);end;
procedure THiDiskInfo._var_DriveType;begin dtString(_Data,DriveType);end;
procedure THiDiskInfo._var_ClusterSize;begin dtString(_Data,ClusterSize);end;
procedure THiDiskInfo._var_FullSize;begin dtString(_Data,FullSize);end;
procedure THiDiskInfo._var_OccupiedSpace;begin dtString(_Data,OccupiedSpace);end;
procedure THiDiskInfo._var_FreeSpace;begin dtString(_Data,FreeSpace);end;
procedure THiDiskInfo._var_VolumeName;begin dtString(_Data,VolumeName);end;
procedure THiDiskInfo._var_SerialNumber;begin dtString(_Data,VolumeSerialNumber);end;

procedure THiDiskInfo._var_IdArray;
begin
   if IdArray = nil then
      IdArray:= CreateArray(nil, _GetId, _CountId, nil);
   dtArray(_Data,IdArray);
end;

function THiDiskInfo._GetId;
var   ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < FListId.Count)then begin
      Result:= true;
      dtString(Val,FListId.Items[ind]);
   end
   else Result:= false;
end;

function THiDiskInfo._CountId;begin Result:= FListId.Count;end;

end.