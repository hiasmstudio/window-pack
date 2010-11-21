unit hiDeviceInfo;

interface

uses Windows, Kol, Share, Debug, hiIconsManager;

const
  SetupApiModuleName = 'SetupApi.dll';

const
  PINVALID_HANDLE_VALUE = Pointer(INVALID_HANDLE_VALUE);

const
  DIGCF_DEFAULT         = $00000001; // only valid with DIGCF_DEVICEINTERFACE
  DIGCF_PRESENT         = $00000002;
  DIGCF_ALLCLASSES      = $00000004;
  DIGCF_PROFILE         = $00000008;
  DIGCF_DEVICEINTERFACE = $00000010;

type
  PPWSTR    = ^PWideChar;
  PPASTR    = ^PAnsiChar;
  PPSTR     = ^PChar;
  PHICON    = ^HICON;
  ULONG_PTR = DWORD;
  DWORD_PTR = DWORD;
  UINT_PTR  = DWORD;

  TGUID     = system.TGUID;

  DI_FUNCTION = UINT;    // Function type for device installer

//
// Define type for reference to device information set
//
  HDEVINFO = Pointer;

const
  GUID_DEVCLASS_NET: TGUID       = '{4D36E972-E325-11CE-BFC1-08002BE10318}';

const
  DIF_SELECTDEVICE   = $00000001;
  DIF_PROPERTIES     = $00000004;  
  DIF_PROPERTYCHANGE = $00000012;

const
//
// Values specifying the scope of a device property change
//
  DICS_FLAG_GLOBAL         = $00000001;  // make change in all hardware profiles
  DICS_FLAG_CONFIGSPECIFIC = $00000002;  // make change in specified profile only
  DICS_FLAG_CONFIGGENERAL  = $00000004;  // 1 or more hardware profile-specific

const
  DICS_ENABLE        = $00000001;
  DICS_DISABLE       = $00000002;
  DICS_PROPCHANGE    = $00000003;
  DICS_START         = $00000004;
  DICS_STOP          = $00000005;

//
// Class installation parameters header.  This must be the first field of any
// class install parameter structure.  The InstallFunction field must be set to
// the function code corresponding to the structure, and the cbSize field must
// be set to the size of the header structure.  E.g.,
//
type
  PSPClassInstallHeader = ^TSPClassInstallHeader;
  SP_CLASSINSTALL_HEADER = packed record
    cbSize: DWORD;
    InstallFunction: DI_FUNCTION;
  end;
  TSPClassInstallHeader = SP_CLASSINSTALL_HEADER;

//
// Structure corresponding to a DIF_PROPERTYCHANGE install function.
//
type
  PSPPropChangeParams = ^TSPPropChangeParams;
  SP_PROPCHANGE_PARAMS = packed record
    ClassInstallHeader: TSPClassInstallHeader;
    StateChange: DWORD;
    Scope: DWORD;
    HwProfile: DWORD;
  end;
  TSPPropChangeParams = SP_PROPCHANGE_PARAMS;

type
//
// Device information structure (references a device instance
// that is a member of a device information set)
//
  PSPDevInfoData = ^TSPDevInfoData;
  SP_DEVINFO_DATA = packed record
    cbSize: DWORD;
    ClassGuid: TGUID;
    DevInst: DWORD; // DEVINST handle
    Reserved: ULONG_PTR;
  end;
  TSPDevInfoData = SP_DEVINFO_DATA;

//
// Structure containing class image list information.
//
  PSPClassImageListData = ^TSPClassImageListData;
  SP_CLASSIMAGELIST_DATA = packed record
    cbSize: DWORD;
    ImageList: HIMAGELIST;
    Reserved: ULONG_PTR;
  end;
  TSPClassImageListData = SP_CLASSIMAGELIST_DATA;

//------------------------------------------------------------------------------

const
  POWER_SYSTEM_MAXIMUM = 7;

type
  TRelationship = record
    Flag: DWORD;
    Desc: String;
  end;

  _DEVICE_POWER_STATE = (
    PowerDeviceUnspecified,
    PowerDeviceD0,
    PowerDeviceD1,
    PowerDeviceD2,
    PowerDeviceD3,
    PowerDeviceMaximum);
  DEVICE_POWER_STATE = _DEVICE_POWER_STATE;
  PDEVICE_POWER_STATE = ^DEVICE_POWER_STATE;
  TDevicePowerState = DEVICE_POWER_STATE;
  PDevicePowerState = PDEVICE_POWER_STATE;

  _SYSTEM_POWER_STATE = (
    PowerSystemUnspecified,
    PowerSystemWorking,
    PowerSystemSleeping1,
    PowerSystemSleeping2,
    PowerSystemSleeping3,
    PowerSystemHibernate,
    PowerSystemShutdown,
    PowerSystemMaximum);
  SYSTEM_POWER_STATE = _SYSTEM_POWER_STATE;
  PSYSTEM_POWER_STATE = ^SYSTEM_POWER_STATE;
  TSystemPowerState = SYSTEM_POWER_STATE;
  PSystemPowerState = PSYSTEM_POWER_STATE;

  TCM_Power_Data  = record
    PD_Size: DWORD;
    PD_MostRecentPowerState: DEVICE_POWER_STATE;
    PD_Capabilities,
    PD_D1Latency,
    PD_D2Latency,
    PD_D3Latency: ULONG;
    PD_PowerStateMapping: array [0..POWER_SYSTEM_MAXIMUM - 1] of DEVICE_POWER_STATE;
    PD_DeepestSystemWake: SYSTEM_POWER_STATE;
  end;

const
  SPDRP_DEVICEDESC                  = $00000000; // DeviceDesc (R/W)
  SPDRP_HARDWAREID                  = $00000001; // HardwareID (R/W)
  SPDRP_COMPATIBLEIDS               = $00000002; // CompatibleIDs (R/W)
  SPDRP_UNUSED0                     = $00000003; // unused
  SPDRP_SERVICE                     = $00000004; // Service (R/W)
  SPDRP_UNUSED1                     = $00000005; // unused
  SPDRP_UNUSED2                     = $00000006; // unused
  SPDRP_CLASS                       = $00000007; // Class (R--tied to ClassGUID)
  SPDRP_CLASSGUID                   = $00000008; // ClassGUID (R/W)
  SPDRP_DRIVER                      = $00000009; // Driver (R/W)
  SPDRP_CONFIGFLAGS                 = $0000000A; // ConfigFlags (R/W)
  SPDRP_MFG                         = $0000000B; // Mfg (R/W)
  SPDRP_FRIENDLYNAME                = $0000000C; // FriendlyName (R/W)
  SPDRP_LOCATION_INFORMATION        = $0000000D; // LocationInformation (R/W)
  SPDRP_PHYSICAL_DEVICE_OBJECT_NAME = $0000000E; // PhysicalDeviceObjectName (R)
  SPDRP_CAPABILITIES                = $0000000F; // Capabilities (R)
  SPDRP_UI_NUMBER                   = $00000010; // UiNumber (R)
  SPDRP_UPPERFILTERS                = $00000011; // UpperFilters (R/W)
  SPDRP_LOWERFILTERS                = $00000012; // LowerFilters (R/W)
  SPDRP_BUSTYPEGUID                 = $00000013; // BusTypeGUID (R)
  SPDRP_LEGACYBUSTYPE               = $00000014; // LegacyBusType (R)
  SPDRP_BUSNUMBER                   = $00000015; // BusNumber (R)
  SPDRP_ENUMERATOR_NAME             = $00000016; // Enumerator Name (R)
  SPDRP_SECURITY                    = $00000017; // Security (R/W, binary form)
  SPDRP_SECURITY_SDS                = $00000018; // Security (W, SDS form)
  SPDRP_DEVTYPE                     = $00000019; // Device Type (R/W)
  SPDRP_EXCLUSIVE                   = $0000001A; // Device is exclusive-access (R/W)
  SPDRP_CHARACTERISTICS             = $0000001B; // Device Characteristics (R/W)
  SPDRP_ADDRESS                     = $0000001C; // Device Address (R)
  SPDRP_UI_NUMBER_DESC_FORMAT       = $0000001D; // UiNumberDescFormat (R/W)
  SPDRP_MAXIMUM_PROPERTY            = $0000001F; // Upper bound on ordinals

const
  SPDRP_REMOVAL_POLICY              = $0000001F;
  SPDRP_REMOVAL_POLICY_HW_DEFAULT   = $00000020;
  SPDRP_REMOVAL_POLICY_OVERRIDE     = $00000021;

const
  CM_DEVCAP_LOCKSUPPORTED     = $00000001;
  CM_DEVCAP_EJECTSUPPORTED    = $00000002;
  CM_DEVCAP_REMOVABLE         = $00000004;
  CM_DEVCAP_DOCKDEVICE        = $00000008;
  CM_DEVCAP_UNIQUEID          = $00000010;
  CM_DEVCAP_SILENTINSTALL     = $00000020;
  CM_DEVCAP_RAWDEVICEOK       = $00000040;
  CM_DEVCAP_SURPRISEREMOVALOK = $00000080;
  CM_DEVCAP_HARDWAREDISABLED  = $00000100;
  CM_DEVCAP_NONDYNAMIC        = $00000200;

  CapabilitiesRelationships: array [0..9] of TRelationship =
    (
      (Flag: CM_DEVCAP_LOCKSUPPORTED; Desc: 'CM_DEVCAP_LOCKSUPPORTED'),
      (Flag: CM_DEVCAP_EJECTSUPPORTED; Desc: 'CM_DEVCAP_EJECTSUPPORTED'),
      (Flag: CM_DEVCAP_REMOVABLE; Desc: 'CM_DEVCAP_REMOVABLE'),
      (Flag: CM_DEVCAP_DOCKDEVICE; Desc: 'CM_DEVCAP_DOCKDEVICE'),
      (Flag: CM_DEVCAP_UNIQUEID; Desc: 'CM_DEVCAP_UNIQUEID'),
      (Flag: CM_DEVCAP_SILENTINSTALL; Desc: 'CM_DEVCAP_SILENTINSTALL'),
      (Flag: CM_DEVCAP_RAWDEVICEOK; Desc: 'CM_DEVCAP_RAWDEVICEOK'),
      (Flag: CM_DEVCAP_SURPRISEREMOVALOK; Desc: 'CM_DEVCAP_SURPRISEREMOVALOK'),
      (Flag: CM_DEVCAP_HARDWAREDISABLED; Desc: 'CM_DEVCAP_HARDWAREDISABLED'),
      (Flag: CM_DEVCAP_NONDYNAMIC; Desc: 'CM_DEVCAP_NONDYNAMIC')
    );

const
  CONFIGFLAG_DISABLED            = $00000001; // Set if disabled
  CONFIGFLAG_REMOVED             = $00000002; // Set if a present hardware enum device deleted
  CONFIGFLAG_MANUAL_INSTALL      = $00000004; // Set if the devnode was manually installed
  CONFIGFLAG_IGNORE_BOOT_LC      = $00000008; // Set if skip the boot config
  CONFIGFLAG_NET_BOOT            = $00000010; // Load this devnode when in net boot
  CONFIGFLAG_REINSTALL           = $00000020; // Redo install
  CONFIGFLAG_FAILEDINSTALL       = $00000040; // Failed the install
  CONFIGFLAG_CANTSTOPACHILD      = $00000080; // Can't stop/remove a single child
  CONFIGFLAG_OKREMOVEROM         = $00000100; // Can remove even if rom.
  CONFIGFLAG_NOREMOVEEXIT        = $00000200; // Don't remove at exit.
  CONFIGFLAG_FINISH_INSTALL      = $00000400; // Complete install for devnode running 'raw'
  CONFIGFLAG_NEEDS_FORCED_CONFIG = $00000800; // This devnode requires a forced config
  CONFIGFLAG_NETBOOT_CARD        = $00001000; // This is the remote boot network card
  CONFIGFLAG_PARTIAL_LOG_CONF    = $00002000; // This device has a partial logconfig
  CONFIGFLAG_SUPPRESS_SURPRISE   = $00004000; // Set if unsafe removals should be ignored
  CONFIGFLAG_VERIFY_HARDWARE     = $00008000; // Set if hardware should be tested for logo failures

  ConfigFlagRelationships: array [0..15] of TRelationship =
    (
      (Flag: CONFIGFLAG_DISABLED; Desc: 'CONFIGFLAG_DISABLED'),
      (Flag: CONFIGFLAG_REMOVED; Desc: 'CONFIGFLAG_REMOVED'),
      (Flag: CONFIGFLAG_MANUAL_INSTALL; Desc: 'CONFIGFLAG_MANUAL_INSTALL'),
      (Flag: CONFIGFLAG_IGNORE_BOOT_LC; Desc: 'CONFIGFLAG_IGNORE_BOOT_LC'),
      (Flag: CONFIGFLAG_NET_BOOT; Desc: 'CONFIGFLAG_NET_BOOT'),
      (Flag: CONFIGFLAG_REINSTALL; Desc: 'CONFIGFLAG_REINSTALL'),
      (Flag: CONFIGFLAG_FAILEDINSTALL; Desc: 'CONFIGFLAG_FAILEDINSTALL'),
      (Flag: CONFIGFLAG_CANTSTOPACHILD; Desc: 'CONFIGFLAG_CANTSTOPACHILD'),
      (Flag: CONFIGFLAG_OKREMOVEROM; Desc: 'CONFIGFLAG_OKREMOVEROM'),
      (Flag: CONFIGFLAG_NOREMOVEEXIT; Desc: 'CONFIGFLAG_NOREMOVEEXIT'),
      (Flag: CONFIGFLAG_FINISH_INSTALL; Desc: 'CONFIGFLAG_FINISH_INSTALL'),
      (Flag: CONFIGFLAG_NEEDS_FORCED_CONFIG; Desc: 'CONFIGFLAG_NEEDS_FORCED_CONFIG'),
      (Flag: CONFIGFLAG_NETBOOT_CARD; Desc: 'CONFIGFLAG_NETBOOT_CARD'),
      (Flag: CONFIGFLAG_PARTIAL_LOG_CONF; Desc: 'CONFIGFLAG_PARTIAL_LOG_CONF'),
      (Flag: CONFIGFLAG_SUPPRESS_SURPRISE; Desc: 'CONFIGFLAG_SUPPRESS_SURPRISE'),
      (Flag: CONFIGFLAG_VERIFY_HARDWARE; Desc: 'CONFIGFLAG_VERIFY_HARDWARE')
    );

const
  CM_REMOVAL_POLICY_EXPECT_NO_REMOVAL        = 1;
  CM_REMOVAL_POLICY_EXPECT_ORDERLY_REMOVAL   = 2;
  CM_REMOVAL_POLICY_EXPECT_SURPRISE_REMOVAL  = 3;

const
  CM_INSTALL_STATE_INSTALLED                 = 0;
  CM_INSTALL_STATE_NEEDS_REINSTALL           = 1;
  CM_INSTALL_STATE_FAILED_INSTALL            = 2;
  CM_INSTALL_STATE_FINISH_INSTALL            = 3;

const
  SPDRP_DEVICE_POWER_DATA      = $0000001E;
  SDRP_INSTALL_STATE           = $00000022;

const
  PDCAP_D0_SUPPORTED           = $00000001;
  PDCAP_D1_SUPPORTED           = $00000002;
  PDCAP_D2_SUPPORTED           = $00000004;
  PDCAP_D3_SUPPORTED           = $00000008;
  PDCAP_WAKE_FROM_D0_SUPPORTED = $00000010;
  PDCAP_WAKE_FROM_D1_SUPPORTED = $00000020;
  PDCAP_WAKE_FROM_D2_SUPPORTED = $00000040;
  PDCAP_WAKE_FROM_D3_SUPPORTED = $00000080;
  PDCAP_WARM_EJECT_SUPPORTED   = $00000100;

  PDCAPRelationships: array [0..8] of TRelationship =
    (
      (Flag: PDCAP_D0_SUPPORTED; Desc: 'PDCAP_D0_SUPPORTED'),
      (Flag: PDCAP_D1_SUPPORTED; Desc: 'PDCAP_D1_SUPPORTED'),
      (Flag: PDCAP_D2_SUPPORTED; Desc: 'PDCAP_D2_SUPPORTED'),
      (Flag: PDCAP_D3_SUPPORTED; Desc: 'PDCAP_D3_SUPPORTED'),
      (Flag: PDCAP_WAKE_FROM_D0_SUPPORTED; Desc: 'PDCAP_WAKE_FROM_D0_SUPPORTED'),
      (Flag: PDCAP_WAKE_FROM_D1_SUPPORTED; Desc: 'PDCAP_WAKE_FROM_D1_SUPPORTED'),
      (Flag: PDCAP_WAKE_FROM_D2_SUPPORTED; Desc: 'PDCAP_WAKE_FROM_D2_SUPPORTED'),
      (Flag: PDCAP_WAKE_FROM_D3_SUPPORTED; Desc: 'PDCAP_WAKE_FROM_D3_SUPPORTED'),
      (Flag: PDCAP_WARM_EJECT_SUPPORTED; Desc: 'PDCAP_WARM_EJECT_SUPPORTED')
    );

type
  TDeviceHelper = class
  private
    FDeviceInfoData: SP_DEVINFO_DATA;
    FDeviceListHandle: HDEVINFO;
  protected
    function GetBinary(PropertyCode: Integer;
      pData: Pointer; dwSize: DWORD): Boolean; virtual;
    function GetDWORD(PropertyCode: Integer): DWORD; virtual;
    function GetGuid(PropertyCode: Integer): TGUID; virtual;
    function GetString(PropertyCode: Integer): String; virtual;
    function GetPolicy(PropertyCode: Integer): String; virtual;
  public
    function Capabilities: String;
//    function Characteristics: String;
    function ConfigFlags: String;
    function DeviceClassDescription: String; overload;
    function DeviceClassDescription(DeviceTypeGUID: TGUID): String; overload;
    function InstallState: String;
    function PowerData: String;
    function LegacyBusType: String;
  public
    property Address: DWORD index SPDRP_ADDRESS read GetDWORD;
    property BusTypeGUID: TGUID index SPDRP_BUSTYPEGUID read GetGuid;
    property BusNumber: DWORD index SPDRP_BUSNUMBER read GetDWORD;
    property ClassGUID: TGUID index SPDRP_CLASSGUID read GetGuid;
    property CompatibleIDS: String index SPDRP_COMPATIBLEIDS read GetString;

    property DeviceClassName: String index SPDRP_CLASS read GetString;
    //property DeviceType: xxx index SPDRP_DEVTYPE read xxx;
    property DriverName: String index SPDRP_DRIVER read GetString;
    property Description: String index SPDRP_DEVICEDESC read GetString;

    property Enumerator: String index SPDRP_ENUMERATOR_NAME read GetString;
    //property Exclusive: xxx index SPDRP_EXCLUSIVE read xxx;

    property FriendlyName: String index SPDRP_FRIENDLYNAME read GetString;
    property HardwareID: String index SPDRP_HARDWAREID read GetString;

    property Service: String index SPDRP_SERVICE read GetString;
    //property Security: xxx index SPDRP_SECURITY read xxx;
    //property SecuritySDS: xxx index SPDRP_SECURITY_SDS read xxx;

    property Location: String index SPDRP_LOCATION_INFORMATION read GetString;
    property LowerFilters: String index SPDRP_LOWERFILTERS read GetString;
    property Manufacturer: String index SPDRP_MFG read GetString;
    property PhisicalDriverName: String
      index SPDRP_PHYSICAL_DEVICE_OBJECT_NAME read GetString;

    property RemovalPolicy: String index SPDRP_REMOVAL_POLICY
      read GetPolicy;
    property RemovalPolicyHWDefault: String
      index SPDRP_REMOVAL_POLICY_HW_DEFAULT read GetPolicy;
    property RemovalPolicyOverride: String index SPDRP_REMOVAL_POLICY_OVERRIDE
      read GetPolicy;

    property UINumber: DWORD index SPDRP_UI_NUMBER read GetDWORD;
    property UINumberDecription: String index SPDRP_UI_NUMBER_DESC_FORMAT
      read GetString;
    property UpperFilters: String index SPDRP_UPPERFILTERS read GetString;
  public
    property DeviceInfoData: SP_DEVINFO_DATA read FDeviceInfoData
      write FDeviceInfoData;
    property DeviceListHandle: HDEVINFO read FDeviceListHandle
      write FDeviceListHandle;
  end;

//------------------------------------------------------------------------------

type
 THiDeviceInfo = class(TDebug)
   private
     Icon: PIcon;
     fstop: boolean;
     ICArray: PArray;          
     hAllDevices: HDEVINFO;
     ClassImageListData: TSPClassImageListData;
     DeviceHelper: TDeviceHelper;
     ilDevices: PImageList;
     ClassesCount, DevicesCount: integer;

     procedure InitImageList;
     function GetDeviceImageIndex(DeviceGUID: TGUID): Integer;

     function _GetIcon(Var Item: TData; var Val: TData):boolean;
     function  _CountIcons: integer;

     procedure EnableDevice(Index: integer; aState: boolean);

   public
     _prop_ShowHidden: boolean;
     _prop_NotEmptyInfo: boolean;
     _prop_onBreakEnable: boolean;

     _event_onEnumDevice: THI_Event;
     _event_onEndEnum: THI_Event;
     _event_onBreak: THI_Event;           
     _event_onDeviceInfo: THI_Event;
     _event_onDeviceOnOff: THI_Event;     
     _data_DeviceIdx: THI_Event;

     constructor Create;
     destructor Destroy; override;

     procedure _work_doEnumDevice(var _Data: TData; Index: Word);
     procedure _work_doStop(var _Data: TData; Index: Word);     
     procedure _work_doDeviceInfo(var _Data: TData; Index: Word);
     procedure _work_doDeviceOnOff(var _Data: TData; Index: Word);     
     procedure _work_doShowHidden(var _Data: TData; Index: Word);
     procedure _var_CountClasses(var _Data: TData; Index: Word);          
     procedure _var_CountDevices(var _Data: TData; Index: Word);
     procedure _var_IconArray(var _Data: TData; Index: Word);     

 end;

implementation

function SetupDiEnumDeviceInfo(DeviceInfoSet: HDEVINFO; MemberIndex: DWORD;
                               var DeviceInfoData: TSPDevInfoData): LongBool;
                               stdcall; external SetupApiModuleName name 'SetupDiEnumDeviceInfo';

function SetupDiGetDeviceRegistryPropertyA(DeviceInfoSet: HDEVINFO; const DeviceInfoData: TSPDevInfoData;
                                           Property_: DWORD; var PropertyRegDataType: DWORD; PropertyBuffer:
                                           PBYTE; PropertyBufferSize: DWORD; var RequiredSize: DWORD): LongBool;
                                           stdcall; external SetupApiModuleName name 'SetupDiGetDeviceRegistryPropertyA';

function SetupDiGetClassDescriptionA(var ClassGuid: TGUID; ClassDescription: PAnsiChar;
                                     ClassDescriptionSize: DWORD; RequiredSize: PDWORD): LongBool;
                                     stdcall; external SetupApiModuleName name 'SetupDiGetClassDescriptionA';

function SetupDiGetClassImageList(var ClassImageListData: TSPClassImageListData): LongBool;
                                  stdcall; external SetupApiModuleName name 'SetupDiGetClassImageList';

function SetupDiDestroyClassImageList(var ClassImageListData: TSPClassImageListData): LongBool;
                                      stdcall; external SetupApiModuleName name 'SetupDiDestroyClassImageList';

function SetupDiGetClassDevsExA(ClassGuid: PGUID; const Enumerator: PAnsiChar;
                                hwndParent: HWND; Flags: DWORD; DeviceInfoSet: HDEVINFO;
                                const MachineName: PAnsiChar; Reserved: Pointer): HDEVINFO;
                                stdcall; external SetupApiModuleName name 'SetupDiGetClassDevsExA';

function SetupDiDestroyDeviceInfoList(DeviceInfoSet: HDEVINFO): LongBool;
                                      stdcall; external SetupApiModuleName name 'SetupDiDestroyDeviceInfoList';

function SetupDiCreateDeviceInfoList(ClassGuid: PGUID; hwndParent: HWND): HDEVINFO;
                                     stdcall;  external SetupApiModuleName name 'SetupDiCreateDeviceInfoList';

function SetupDiGetClassImageIndex(var ClassImageListData: TSPClassImageListData; var ClassGuid: TGUID;
                                   var ImageIndex: Integer): LongBool;
                                   stdcall; external SetupApiModuleName name 'SetupDiGetClassImageIndex';

function SetupDiSetClassInstallParams(DeviceInfoSet: HDEVINFO; DeviceInfoData: PSPDevInfoData;
                                      ClassInstallParams: PSPClassInstallHeader;
                                      ClassInstallParamsSize: DWORD): LongBool;
                                      stdcall; external SetupApiModuleName name 'SetupDiSetClassInstallParamsA';

function SetupDiChangeState(DeviceInfoSet: HDEVINFO; var DeviceInfoData: TSPDevInfoData): LongBool;
                            stdcall; external SetupApiModuleName name 'SetupDiChangeState';                              

//------------------------------------------------------------------------------

function StringToGUID(const S: string): TGUID;
begin
  if (Length(S) <> 38) or (S[1] <> '{') or (S[10] <> '-') or (S[15] <> '-') or
     (S[20] <> '-') or (S[25] <> '-') or (S[38] <> '}') then exit;
  Result.D1    := Hex2Int(Copy(S, 2, 8));
  Result.D2    := Hex2Int(Copy(S, 11, 4));
  Result.D3    := Hex2Int(Copy(S, 16, 4));
  Result.D4[0] := Hex2Int(Copy(S, 21, 2));
  Result.D4[1] := Hex2Int(Copy(S, 23, 2));
  Result.D4[2] := Hex2Int(Copy(S, 26, 2));
  Result.D4[3] := Hex2Int(Copy(S, 28, 2));
  Result.D4[4] := Hex2Int(Copy(S, 30, 2));
  Result.D4[5] := Hex2Int(Copy(S, 32, 2));
  Result.D4[6] := Hex2Int(Copy(S, 34, 2));
  Result.D4[7] := Hex2Int(Copy(S, 36, 2));
end;

function GUIDToString(const GUID: TGUID): string;
begin
  Result := '{' + Int2Hex(GUID.D1, 8)    + '-' + Int2Hex(GUID.D2, 4)    + '-' +
                  Int2Hex(GUID.D3, 4)    + '-' + Int2Hex(GUID.D4[0], 2) +
                  Int2Hex(GUID.D4[1], 2) + '-' + Int2Hex(GUID.D4[2], 2) +
                  Int2Hex(GUID.D4[3], 2)       + Int2Hex(GUID.D4[4], 2) +
                  Int2Hex(GUID.D4[5], 2)       + Int2Hex(GUID.D4[6], 2) +
                  Int2Hex(GUID.D4[7], 2)       + '}';
end;

{ TDeviceHelper }

function HasFlag(const Value, dwFlag: DWORD): Boolean;
begin
  Result := (Value and dwFlag) = dwFlag;
end;

procedure AddToResult(var AResult: String; const Value: String);
begin
  if AResult = '' then
    AResult := Value
  else
    AResult := AResult + ', ' + Value;
end;

function ExtractMultiString(const Value: String): String;
var
  P: PChar;
begin
  P := @Value[1];
  while P^ <> #0 do
  begin
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + P;
    Inc(P, lstrlen(P) + 1);
  end;
end;

function TDeviceHelper.Capabilities: String;
var
  I: Integer;
  dwCapabilities: DWORD;
begin
  Result := '';
  dwCapabilities := GetDWORD(SPDRP_CAPABILITIES);
  for I := 0 to 9 do
    if HasFlag(dwCapabilities, CapabilitiesRelationships[I].Flag) then
      AddToResult(Result, CapabilitiesRelationships[I].Desc);
end;

(*
function TDeviceHelper.Characteristics: String;
var
  dwCharacteristics: DWORD;
begin
  dwCharacteristics := GetDWORD(SPDRP_CHARACTERISTICS);
//  Result := GetString(dwCharacteristics);
//  if dwCharacteristics <> 0 then
//    Beep(900, 50);
end;
*)

function TDeviceHelper.ConfigFlags: String;
var
  I: Integer;
  dwConfigFlags: DWORD;
begin
  Result := '';
  dwConfigFlags := GetDWORD(SPDRP_CONFIGFLAGS);
  for I := 0 to 15 do
    if HasFlag(dwConfigFlags, ConfigFlagRelationships[I].Flag) then
      AddToResult(Result, ConfigFlagRelationships[I].Desc);
end;

function TDeviceHelper.DeviceClassDescription(DeviceTypeGUID: TGUID): String;
var
  dwRequiredSize: DWORD;
begin
  Result := '';
  dwRequiredSize := 0;
  SetupDiGetClassDescriptionA(DeviceTypeGUID,
    nil, 0, @dwRequiredSize);
  if GetLastError = ERROR_INSUFFICIENT_BUFFER then
  begin
    SetLength(Result, dwRequiredSize);
    SetupDiGetClassDescriptionA(DeviceTypeGUID,
      @Result[1], dwRequiredSize, @dwRequiredSize);
  end;
  Result := PChar(Result);
end;

function TDeviceHelper.DeviceClassDescription: String;
var
  AGUID: TGUID;
begin
  AGUID := ClassGUID;
  Result := DeviceClassDescription(AGUID);
end;

function TDeviceHelper.GetBinary(PropertyCode: Integer; pData: Pointer;
  dwSize: DWORD): Boolean;
var
  dwPropertyRegDataType, dwRequiredSize: DWORD;
begin
  dwRequiredSize := 0;
  dwPropertyRegDataType := REG_BINARY;
  Result := SetupDiGetDeviceRegistryPropertyA(DeviceListHandle, DeviceInfoData,
    PropertyCode, dwPropertyRegDataType, pData,
    dwSize, dwRequiredSize);
end;

function TDeviceHelper.GetDWORD(PropertyCode: Integer): DWORD;
var
  dwPropertyRegDataType, dwRequiredSize: DWORD;
begin
  Result := 0;
  dwRequiredSize := 4;
  dwPropertyRegDataType := REG_DWORD;
  SetupDiGetDeviceRegistryPropertyA(DeviceListHandle, DeviceInfoData,
    PropertyCode, dwPropertyRegDataType, @Result,
    dwRequiredSize, dwRequiredSize);
end;

function TDeviceHelper.GetGuid(PropertyCode: Integer): TGUID;
var
  dwPropertyRegDataType, dwRequiredSize: DWORD;
  StringGUID: String;
begin
  ZeroMemory(@Result, SizeOf(TGUID));
  StringGUID := GetString(PropertyCode);
  if StringGUID = '' then
  begin
    dwRequiredSize := 0;
    dwPropertyRegDataType := REG_BINARY;
    SetupDiGetDeviceRegistryPropertyA(DeviceListHandle, DeviceInfoData,
      PropertyCode, dwPropertyRegDataType, nil, 0, dwRequiredSize);
    if GetLastError = ERROR_INSUFFICIENT_BUFFER then
    begin
      SetupDiGetDeviceRegistryPropertyA(DeviceListHandle, DeviceInfoData,
        PropertyCode, dwPropertyRegDataType, @Result,
        dwRequiredSize, dwRequiredSize);
    end;
  end
  else
    Result := StringToGUID(StringGUID);
end;

function TDeviceHelper.GetPolicy(PropertyCode: Integer): String;
var
  dwPolicy: DWORD;
begin
  dwPolicy := GetDWORD(PropertyCode);
  if dwPolicy > 0 then
    case dwPolicy of
      CM_REMOVAL_POLICY_EXPECT_NO_REMOVAL:
        Result := 'CM_REMOVAL_POLICY_EXPECT_NO_REMOVAL';
      CM_REMOVAL_POLICY_EXPECT_ORDERLY_REMOVAL:
        Result := 'CM_REMOVAL_POLICY_EXPECT_ORDERLY_REMOVAL';
      CM_REMOVAL_POLICY_EXPECT_SURPRISE_REMOVAL:
        Result := 'CM_REMOVAL_POLICY_EXPECT_SURPRISE_REMOVAL';
    else
      Result := 'unknown 0x' + Int2Hex(dwPolicy, 8);
    end;
end;

function TDeviceHelper.GetString(PropertyCode: Integer): String;
var
  dwPropertyRegDataType, dwRequiredSize: DWORD;
begin
  Result := '';
  dwRequiredSize := 0;
  dwPropertyRegDataType := REG_SZ;
  SetupDiGetDeviceRegistryPropertyA(DeviceListHandle, DeviceInfoData,
    PropertyCode, dwPropertyRegDataType, nil, 0, dwRequiredSize);
  if not (dwPropertyRegDataType in [REG_SZ, REG_MULTI_SZ]) then Exit;
  if GetLastError = ERROR_INSUFFICIENT_BUFFER then
  begin
    SetLength(Result, dwRequiredSize);
    SetupDiGetDeviceRegistryPropertyA(DeviceListHandle, DeviceInfoData,
      PropertyCode, dwPropertyRegDataType, @Result[1],
      dwRequiredSize, dwRequiredSize);
  end;
  case dwPropertyRegDataType of
    REG_SZ: Result := PChar(Result);
    REG_MULTI_SZ: Result := ExtractMultiString(Result);
  end;
end;

function TDeviceHelper.InstallState: String;
var
  dwInstallState: DWORD;
begin
  dwInstallState := GetDWORD(SDRP_INSTALL_STATE);
  case dwInstallState of
    CM_INSTALL_STATE_INSTALLED:
      Result := 'CM_INSTALL_STATE_INSTALLED';
    CM_INSTALL_STATE_NEEDS_REINSTALL:
      Result := 'CM_INSTALL_STATE_NEEDS_REINSTALL';
    CM_INSTALL_STATE_FAILED_INSTALL:
      Result := 'CM_INSTALL_STATE_FAILED_INSTALL';
    CM_INSTALL_STATE_FINISH_INSTALL:
      Result := 'CM_INSTALL_STATE_FINISH_INSTALL';
  else
    Result := 'unknown 0x' + Int2Hex(dwInstallState, 8);
  end;
end;

function TDeviceHelper.LegacyBusType: String;
var
  BusType: Integer;
begin
  BusType := Integer(GetDWORD(SPDRP_LEGACYBUSTYPE));
  case BusType of
    -1: Result := 'InterfaceTypeUndefined';
    00: Result := 'Internal';
    01: Result := 'Isa';
    02: Result := 'Eisa';
    03: Result := 'MicroChannel';
    04: Result := 'TurboChannel';
    05: Result := 'PCIBus';
    06: Result := 'VMEBus';
    07: Result := 'NuBus';
    08: Result := 'PCMCIABus';
    09: Result := 'CBus';
    10: Result := 'MPIBus';
    11: Result := 'MPSABus';
    12: Result := 'ProcessorInternal';
    13: Result := 'InternalPowerBus';
    14: Result := 'PNPISABus';
    15: Result := 'PNPBus';
    16: Result := 'MaximumInterfaceType';
  else
    Result := 'unknown 0x' + Int2Hex(BusType, 8);
  end;
end;

function TDeviceHelper.PowerData: String;
var
  I: Integer;
  pPowerData: TCM_Power_Data;
begin
  Result := '';
  if GetBinary(SPDRP_DEVICE_POWER_DATA, @pPowerData,
    SizeOf(TCM_Power_Data)) then
  begin
    for I := 0 to 8 do
      if HasFlag(pPowerData.PD_Capabilities, PDCAPRelationships[I].Flag) then
        AddToResult(Result, PDCAPRelationships[I].Desc);
  end;
end;

//------------------------------------------------------------------------------

procedure THiDeviceInfo.InitImageList;
begin
  // Получаем хэндл ImageList-а в котором находятся
  // изображения наших устройств и назначаем этот хэндл
  // нашему ImageList-у связанному с деревом устройств
  ZeroMemory(@ClassImageListData, SizeOf(TSPClassImageListData));
  ClassImageListData.cbSize := SizeOf(TSPClassImageListData);
  if SetupDiGetClassImageList(ClassImageListData) then
    ilDevices.Handle := ClassImageListData.ImageList;
end;

constructor THiDeviceInfo.Create;
begin
  inherited;
  Icon := NewIcon;
  DeviceHelper := TDeviceHelper.Create;
  ilDevices := NewImageList(nil);
  InitImageList;
end;

destructor THiDeviceInfo.Destroy;
begin
  SetupDiDestroyClassImageList(ClassImageListData);
  DeviceHelper.Free;
  if hAllDevices <> PINVALID_HANDLE_VALUE then
    SetupDiDestroyDeviceInfoList(hAllDevices);
  ilDevices.free;
  Icon.free;
  inherited;
end;

function THiDeviceInfo.GetDeviceImageIndex(DeviceGUID: TGUID): Integer;
begin
  Result := -1;
  // Получаем индекс иконки для конкретного устройства
  SetupDiGetClassImageIndex(ClassImageListData, DeviceGUID, Result);
end;

procedure THiDeviceInfo._work_doEnumDevice;
var
  dwIndex: DWORD;
  dwFlags: DWORD;
  DeviceInfoData: SP_DEVINFO_DATA;
  DeviceName, DeviceClassName: String;
  ClassGUID: TGUID;
//  DeviceClassesCount, DevicesCount: Integer;
  FList: PStrList;

  procedure OutData(outPID, outID, IconIdx: integer; Name: String; DeviceIdx: integer; GUID: string; ConfigFlags: string = '');
  var
    dtpid, dtid, dtname, dticonidx, dtdeviceidx, dtguid, dtconfig: TData;
  begin
    dtInteger(dtpid, outPID);
    dtInteger(dtid, outID);
    dtInteger(dticonidx, IconIdx);
    dtString(dtname, Name);
    dtInteger(dtdeviceidx, DeviceIdx);
    dtString(dtguid, GUID);    
    dtString(dtconfig, ConfigFlags);
    dtpid.ldata       := @dtid;
    dtid.ldata        := @dticonidx;
    dticonidx.ldata   := @dtname;
    dtname.ldata      := @dtdeviceidx;
    dtdeviceidx.ldata := @dtguid;
    dtguid.ldata      := @dtconfig;    
    _hi_onEvent_(_event_onEnumDevice, dtpid);
  end;

begin

  if hAllDevices <> PINVALID_HANDLE_VALUE then
    SetupDiDestroyDeviceInfoList(hAllDevices);

  // Устанавливаем необходимые флаги перед вызовом функции
  dwFlags := DIGCF_ALLCLASSES;// or DIGCF_DEVICEINTERFACE;
  if not _prop_ShowHidden then
  dwFlags := dwFlags or DIGCF_PRESENT; // отображаем только установленные устройства

  // Создаем и заполняем DIS (Device Information Sets)
  // информацией по всем установленным устройствам
  hAllDevices := SetupDiGetClassDevsExA(nil, nil, 0, dwFlags, nil, nil, nil);
  if hAllDevices = PINVALID_HANDLE_VALUE then exit;
  DeviceHelper.DeviceListHandle := hAllDevices;

  FList := NewStrList;
  try
    dwIndex := 0;
    ClassesCount := 0;
    DevicesCount := 0;

    // Подготавливаем структуру для получения информации
    ZeroMemory(@DeviceInfoData, SizeOf(SP_DEVINFO_DATA));
    DeviceInfoData.cbSize := SizeOf(SP_DEVINFO_DATA);

    // Получаем данные по каждому устройству в DIS
    // Номер устройства содержится в dwIndex
    while SetupDiEnumDeviceInfo(hAllDevices, dwIndex, DeviceInfoData) do
    begin

      // Инизиализируем наш DeviceHelper,
      // дальнейшая работа с SP_DEVINFO_DATA будет происходить
      // при помощи методов данного класса
      DeviceHelper.DeviceInfoData := DeviceInfoData;

      // Получаем расширенное имя устройства
      DeviceName := DeviceHelper.FriendlyName;
      // Если расширенного имени нет -
      // получаем имя устройства по умолчанию
      if DeviceName = '' then
        DeviceName := DeviceHelper.Description;

      if DeviceName = '' then
        DeviceName := 'Unknown Device'; 

      // Получаем GUID класса, к которому относится устройство
      ClassGUID := DeviceHelper.ClassGUID;
      // Получаем имя класса, к которому относится устройство
      DeviceClassName := DeviceHelper.DeviceClassDescription(ClassGUID);

      if DeviceClassName = '' then DeviceClassName := 'Unknown Class';
      
      if FList.IndexOf(DeviceClassName) < 0 then
      begin
        FList.Add(DeviceClassName);
        Inc(ClassesCount);
        OutData(-1, FList.IndexOf(DeviceClassName), GetDeviceImageIndex(ClassGUID), DeviceClassName, -1, GUIDToString(ClassGUID));
        OutData(FList.IndexOf(DeviceClassName), DevicesCount + 50, GetDeviceImageIndex(DeviceInfoData.ClassGuid), DeviceName, Integer(dwIndex), GUIDToString(ClassGUID), DeviceHelper.ConfigFlags);
        Inc(DevicesCount);
      end
      else
      begin
        OutData(FList.IndexOf(DeviceClassName), DevicesCount + 50, GetDeviceImageIndex(DeviceInfoData.ClassGuid), DeviceName, Integer(dwIndex), GUIDToString(ClassGUID), DeviceHelper.ConfigFlags);
        Inc(DevicesCount);
      end;
      // Переходим к следующему устроству
      if fStop then break;
      Inc(dwIndex);
    end;
    if fStop and _prop_onBreakEnable then
      _hi_CreateEvent(_Data,@_event_onBreak)
    else
      _hi_CreateEvent(_Data,@_event_onEndEnum);

  finally
    FList.free;
  end;
end;

procedure THiDeviceInfo._work_doDeviceInfo;
var
  DeviceInfoData: SP_DEVINFO_DATA;
  EmptyGUID, AGUID: TGUID;
  dwData: DWORD;
  DevIdx: Integer;

  procedure AddRow(ACaption, AData: String);
  var
    dtcap, dtdata: TData;
  begin
    if (AData = '') and _prop_NotEmptyInfo then exit;
    dtString(dtcap, ACaption);
    dtString(dtdata, AData);
    dtcap.ldata := @dtdata;
    _hi_onEvent(_event_onDeviceInfo, dtcap);
   end;

begin
  DevIdx := Readinteger(_Data, _data_DeviceIdx);

  if hAllDevices = PINVALID_HANDLE_VALUE then exit;
  ZeroMemory(@EmptyGUID, SizeOf(TGUID));
  // Подготавливаем структуру для получения информации
  ZeroMemory(@DeviceInfoData, SizeOf(SP_DEVINFO_DATA));
  DeviceInfoData.cbSize := SizeOf(SP_DEVINFO_DATA);

  // Получаем данные по истройству
  if not SetupDiEnumDeviceInfo(hAllDevices, DevIdx, DeviceInfoData) then Exit;

  // Инизиализируем наш DeviceHelper,
  // дальнейшая работа с SP_DEVINFO_DATA будет происходить
  // при помощи методов данного класса
  DeviceHelper.DeviceInfoData := DeviceInfoData;

//  ListView_EnableGroupView(lvAdvancedInfo.Handle, True);
//  ListView_InsertGroup(lvAdvancedInfo.Handle, 'SP_DEVINFO_DATA', 0);

  // Выводим все данные которые можно получить
  AddRow('Device Descriptiion', DeviceHelper.Description);
  AddRow('Hardware IDs', DeviceHelper.HardwareID);
  AddRow('Compatible IDs', DeviceHelper.CompatibleIDS);
  AddRow('Driver', DeviceHelper.DriverName);
  AddRow('Class name', DeviceHelper.DeviceClassName);
  AddRow('Manufacturer', DeviceHelper.Manufacturer);
  AddRow('Friendly Description', DeviceHelper.FriendlyName);
  AddRow('Location Information', DeviceHelper.Location);
  AddRow('Device CreateFile Name', DeviceHelper.PhisicalDriverName);
  AddRow('Capabilities', DeviceHelper.Capabilities);
  AddRow('Service', DeviceHelper.Service);
  AddRow('ConfigFlags', DeviceHelper.ConfigFlags);
  AddRow('UpperFilters', DeviceHelper.UpperFilters);
  AddRow('LowerFilters', DeviceHelper.LowerFilters);
  AddRow('LegacyBusType', DeviceHelper.LegacyBusType);
  AddRow('Enumerator', DeviceHelper.Enumerator);
//  AddRow('Characteristics', DeviceHelper.Characteristics);
  AddRow('UINumberDecription', DeviceHelper.UINumberDecription);
  AddRow('PowerData', DeviceHelper.PowerData);
  AddRow('RemovalPolicy', DeviceHelper.RemovalPolicy);
  AddRow('RemovalPolicyHWDefault', DeviceHelper.RemovalPolicyHWDefault);
  AddRow('RemovalPolicyOverride', DeviceHelper.RemovalPolicyOverride);
  AddRow('InstallState', DeviceHelper.InstallState);

  if not CompareMem(@EmptyGUID, @DeviceInfoData.ClassGUID,
    SizeOf(TGUID)) then
    AddRow('Device GUID', GUIDToString(DeviceInfoData.ClassGUID));

  AGUID := DeviceHelper.BusTypeGUID;
  if not CompareMem(@EmptyGUID, @AGUID, SizeOf(TGUID)) then
    AddRow('Bus Type GUID', GUIDToString(AGUID))
  else  
    AddRow('Bus Type GUID', '');
    
  dwData := DeviceHelper.UINumber;
  if dwData <> 0 then
    AddRow('UI Number', Int2Str(dwData))
  else  
    AddRow('UI Number', '');
    
  dwData := DeviceHelper.BusNumber;
  if dwData <> 0 then
    AddRow('Bus Number', Int2Str(dwData))
  else
    AddRow('Bus Number', '');    

  dwData := DeviceHelper.Address;
  if dwData <> 0 then
    AddRow('Device Address', Int2Str(dwData))
  else  
    AddRow('Device Address', '');

end;

procedure THIDeviceInfo._work_doDeviceOnOff;
begin
  EnableDevice(ReadInteger(_Data, _data_DeviceIdx), boolean(ReadInteger(_Data, Null)));
end;

procedure THIDeviceInfo.EnableDevice;
var
  PCHP: SP_PROPCHANGE_PARAMS;
  DeviceInfoData: SP_DEVINFO_DATA;
begin

  if hAllDevices = PINVALID_HANDLE_VALUE then exit;

  ZeroMemory(@DeviceInfoData, SizeOf(SP_DEVINFO_DATA));
  DeviceInfoData.cbSize := SizeOf(SP_DEVINFO_DATA);

  if not SetupDiEnumDeviceInfo(hAllDevices, Index, DeviceInfoData) then exit;

  ZeroMemory(@PCHP.ClassInstallHeader, sizeof(SP_CLASSINSTALL_HEADER));

  PCHP.ClassInstallHeader.cbSize := sizeof(SP_CLASSINSTALL_HEADER);
  PCHP.ClassInstallHeader.InstallFunction := DIF_PROPERTYCHANGE;
  PCHP.Scope := DICS_FLAG_GLOBAL;
  PCHP.HwProfile := 0;

  if aState then
    PCHP.StateChange := DICS_ENABLE
  else
    PCHP.StateChange := DICS_DISABLE;
  if not SetupDiSetClassInstallParams(hAllDevices, @DeviceInfoData, @PCHP, sizeof(SP_PROPCHANGE_PARAMS)) then exit;
  if SetupDiChangeState(hAllDevices, DeviceInfoData) then
    _hi_onEvent(_event_onDeviceOnOff, Integer(PCHP.StateChange))
  else  
    _hi_onEvent(_event_onDeviceOnOff, -1);
end;

procedure THIDeviceInfo._work_doStop;
begin
  fstop := true;
end;

procedure THIDeviceInfo._work_doShowHidden;
begin
  _prop_ShowHidden := ReadBool(_Data);
end;

procedure THIDeviceInfo._var_CountClasses;
begin
  dtInteger(_Data, ClassesCount);
end;

procedure THIDeviceInfo._var_CountDevices;
begin
  dtInteger(_Data, DevicesCount);
end;

//IconArray - Массив иконок
//
procedure THIDeviceInfo._var_IconArray;
begin
  if not Assigned(ICArray) then
    ICArray := CreateArray(nil, _GetIcon, _CountIcons, nil);
  dtArray(_Data, ICArray);
end;

function THIDeviceInfo._GetIcon;
var
  ind: integer;
begin
  Result := false;
  ind := ToIntIndex(Item);
  if (ind >= 0) and (ind < ilDevices.Count) then
  begin
    Icon.Clear;
    Icon.Handle:= ilDevices.ExtractIcon(ind);
    dtIcon(Val, Icon);
    Result := true;
  end;
end;

function THIDeviceInfo._CountIcons:integer;
begin
  Result := 0;
  if not Assigned(ilDevices) then exit;
  Result := ilDevices.Count;
end;

end.