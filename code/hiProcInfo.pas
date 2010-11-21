unit HiProcInfo; { Компонент ProcInfo (компонент для определения параметров процессоров) ver 1.30 }

interface

uses Windows,KOL,KOLComObj,ActiveX,Share,Debug;

const STGM_default =STGM_READWRITE + STGM_SHARE_EXCLUSIVE;
      STGM_BASE    =STGM_READ + STGM_SHARE_EXCLUSIVE;

type
  TScriptLanguage = (slVBScript, slJScript);
  
type
 THiProcInfo = class(TDebug)
   private
      DeviceID          : string;
      Name              : string;
      Manufacturer      : string;
      Description       : string;
      SocketDesignation : string;
      MaxClockSpeed     : string;
      ExtClock          : string;
      Version           : string;
      L2CacheSize       : string;
      L2CacheSpeed      : string;
      Architecture      : string;
      Availability      : string;
      CurrentVoltage    : string;
      ProcessorId       : string;
      Status            : string;
      LoadPercentage    : string;
      IdArray           : PArray;
      FListId           : PStrList;
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
      procedure _work_doArrayID(var _Data:TData; Index:word);
      procedure _var_DeviceID(var _Data:TData; Index:word);
      procedure _var_Name(var _Data:TData; Index:word);
      procedure _var_Manufacturer(var _Data:TData; Index:word);
      procedure _var_Description(var _Data:TData; Index:word);
      procedure _var_SocketDesignation(var _Data:TData; Index:word);
      procedure _var_MaxClockSpeed(var _Data:TData; Index:word);
      procedure _var_ExtClock(var _Data:TData; Index:word);
      procedure _var_Version(var _Data:TData; Index:word);
      procedure _var_L2CacheSize(var _Data:TData; Index:word);
      procedure _var_L2CacheSpeed(var _Data:TData; Index:word);
      procedure _var_Architecture(var _Data:TData; Index:word);
      procedure _var_Availability(var _Data:TData; Index:word);
      procedure _var_CurrentVoltage(var _Data:TData; Index:word);
      procedure _var_ProcessorId(var _Data:TData; Index:word);
      procedure _var_Status(var _Data:TData; Index:word);
      procedure _var_LoadPercentage(var _Data:TData; Index:word);
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

constructor THiProcInfo.Create;
begin
   inherited;
   OleInit;
   InitCLSIDs;
   FListId := NewStrList;
end;

destructor THiProcInfo.Destroy;
begin
   FlistId.Free;
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

procedure THiProcInfo._work_doArrayId;
var   objService : Variant;
      objProcessor: Variant; 
      colProcessor: Variant;
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
   colProcessor := objService.ExecQuery('SELECT DeviceID FROM Win32_Processor');
   oEnum := IUnknown(colProcessor._NewEnum) as IEnumVariant;
   iValue := nil;
   while oEnum.Next(1,objProcessor,iValue) = 0 do begin
      FlistId.Add(Trim(VarToStr(objProcessor.DeviceID)));
      objProcessor := Unassigned;
   end;
end;

procedure THiProcInfo._work_doInfo;
var   objService: Variant;
      objProcessor: Variant; 
      colProcessor: Variant;
      oEnum : IEnumvariant;
      iValue : PLongint;
      Num: integer;
      sDevice : string;
      sComputer :string;
      sQuery : string;
      dt : TData;
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
   if length(sDevice) > 0 then sDevice := ' WHERE DeviceID = "' + sDevice + '"';
   colProcessor := objService.ExecQuery('SELECT ' + sQuery + ' FROM Win32_Processor' + sDevice);
   oEnum := IUnknown(colProcessor._NewEnum) as IEnumVariant;
   iValue := nil;
   while oEnum.Next(1,objProcessor,iValue) = 0 do begin
      DeviceID          := Trim(VarToStr(objProcessor.DeviceID));
      Name              := Trim(VarToStr(objProcessor.Name));
      Manufacturer      := Trim(VarToStr(objProcessor.Manufacturer));
      Description       := Trim(VarToStr(objProcessor.Description));
      SocketDesignation := Trim(VarToStr(objProcessor.SocketDesignation));
      MaxClockSpeed     := Trim(VarToStr(objProcessor.MaxClockSpeed));
      ExtClock          := Trim(VarToStr(objProcessor.ExtClock));
      Version           := Trim(VarToStr(objProcessor.Version));
      L2CacheSize       := Trim(VarToStr(objProcessor.L2CacheSize));
      L2CacheSpeed      := Trim(VarToStr(objProcessor.L2CacheSpeed));
      if not VarIsEmpty(objProcessor.Architecture) then begin
         Num               := str2int(Trim(VarToStr(objProcessor.Architecture)));
         case Num of
            0: Architecture := 'x86';
            1: Architecture := 'MIPS';
            2: Architecture := 'Alpha';
            3: Architecture := 'PowerPC';
         end;
      end else Architecture := '';
      if not VarIsEmpty(objProcessor.Availability) then begin
         Num               := str2int(Trim(VarToStr(objProcessor.Availability)));
         case Num of
            1 : Availability := 'Other';
            2 : Availability := 'Unknown';
            3 : Availability := 'Running - Full Power';
            4 : Availability := 'Warning';
            13: Availability := 'Power Save - Unknown';
            14: Availability := 'Power Save - Low Power Mode';
            15: Availability := 'Power Save - Standby';
            18: Availability := 'Paused';
         end;
      end else Availability := '';
      if not VarIsEmpty(objProcessor.CurrentVoltage) then
         CurrentVoltage := double2str(str2int(Trim(VarToStr(objProcessor.CurrentVoltage)))/10)
      else CurrentVoltage := '';
      ProcessorId       := Trim(VarToStr(objProcessor.ProcessorId));
      Status            := Trim(VarToStr(objProcessor.Status));
      LoadPercentage    := Trim(VarToStr(objProcessor.LoadPercentage));
      _hi_onEvent(_event_onInfo);
      objProcessor := Unassigned;
   end;
end;

procedure THiProcInfo._var_DeviceID;begin dtString(_Data,DeviceID);end;
procedure THiProcInfo._var_Name;begin dtString(_Data,Name);end;
procedure THiProcInfo._var_Manufacturer;begin dtString(_Data,Manufacturer);end;
procedure THiProcInfo._var_Description;begin dtString(_Data,Description);end;
procedure THiProcInfo._var_SocketDesignation;begin dtString(_Data,SocketDesignation);end;
procedure THiProcInfo._var_MaxClockSpeed;begin dtString(_Data,MaxClockSpeed);end;
procedure THiProcInfo._var_ExtClock;begin dtString(_Data,ExtClock);end;
procedure THiProcInfo._var_Version;begin dtString(_Data,Version);end;
procedure THiProcInfo._var_L2CacheSize;begin dtString(_Data,L2CacheSize);end;
procedure THiProcInfo._var_L2CacheSpeed;begin dtString(_Data,L2CacheSpeed);end;
procedure THiProcInfo._var_Architecture;begin dtString(_Data,Architecture);end;
procedure THiProcInfo._var_Availability;begin dtString(_Data,Availability);end;
procedure THiProcInfo._var_CurrentVoltage;begin dtString(_Data,CurrentVoltage);end;
procedure THiProcInfo._var_ProcessorId;begin dtString(_Data,ProcessorId);end;
procedure THiProcInfo._var_Status;begin dtString(_Data,Status);end;
procedure THiProcInfo._var_LoadPercentage;begin dtString(_Data,LoadPercentage);end;

procedure THiProcInfo._var_IdArray;
begin
   if IdArray = nil then
      IdArray:= CreateArray(nil, _GetId, _CountId, nil);
   dtArray(_Data,IdArray);
end;

function THiProcInfo._GetId;
var   ind:integer;
begin
   ind := ToIntIndex(Item);
   if(ind >= 0)and(ind < FListId.Count)then begin
      Result:= true;
      dtString(Val,FListId.Items[ind]);
   end
   else Result:= false;
end;

function THiProcInfo._CountId;begin Result:= FListId.Count;end;

end.


