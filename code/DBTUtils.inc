const
  WM_DEVICECHANGE = $0219;

type
  _DEV_BROADCAST_HDR = record // Device broadcast header
    dbch_size: DWORD;
    dbch_devicetype: DWORD;
    dbch_reserved: DWORD;
  end;
  DEV_BROADCAST_HDR = _DEV_BROADCAST_HDR;
  PDEV_BROADCAST_HDR = ^DEV_BROADCAST_HDR;

// The following messages are for WM_DEVICECHANGE. The immediate list
// is for the wParam. ALL THESE MESSAGES PASS A POINTER TO A STRUCT
// STARTING WITH A DWORD SIZE AND HAVING NO POINTER IN THE STRUCT.

const
  DBT_DEVICEARRIVAL        = $8000; // system detected a new device
  DBT_DEVICEREMOVECOMPLETE = $8004; // device is gone

  DBT_DEVTYP_VOLUME = $00000002; // logical volume

  DBTF_MEDIA = $0001; // media comings and goings
  DBTF_NET   = $0002; // network volume

type
  _DEV_BROADCAST_VOLUME = record
    dbcv_size: DWORD;
    dbcv_devicetype: DWORD;
    dbcv_reserved: DWORD;
    dbcv_unitmask: DWORD;
    dbcv_flags: WORD;
  end;
  DEV_BROADCAST_VOLUME  = _DEV_BROADCAST_VOLUME;
  PDEV_BROADCAST_VOLUME = ^DEV_BROADCAST_VOLUME;

(* Finds the first valid drive letter from a mask of drive letters *)

function FirstDriveFromMask(unitmask: Longint): Char;
var
  DriveLetter: Shortint;
begin
  DriveLetter := Byte('a');
  while (unitmask and 1) = 0 do
  begin
    unitmask := unitmask shr 1;
    Inc(DriveLetter);
  end;
  Result := Char(DriveLetter);
end;

(* NOT REMOVABLE AND NOT CD/DVD *)

function FixedDrive(Drv: Char): Boolean;
begin
  case GetDriveType(PChar(Drv + ':\')) of
    DRIVE_REMOVABLE, DRIVE_CDROM: Result := FALSE;
  else
    Result := TRUE;
  end;
end;

(* ГОТОВНОСТЬ ДРАЙВА *)

function DriveReady(Drv: Char): Boolean;
var
  NotUsed: DWORD;
begin
  Result := GetVolumeInformation(PChar(Drv + ':\'), nil, 0, nil, NotUsed, NotUsed, nil, 0);
end;

(* ПОЛУЧИТЬ МЕТКУ ДИСКА *)

function GetLabelDisk(Drv: Char; VolReal: Boolean): string;
var
  WinVer: Byte;
  DriveType, NotUsed: DWORD;
  Buf: array [0..MAX_PATH - 1] of Char;

function DisplayName(Drv: Char): string;
var
  SFI: TSHFileInfo;
begin
  FillChar(SFI, SizeOf(SFI), 0);
  SHGetFileInfo(PChar(Drv + ':\'), 0, SFI, SizeOf(SFI), SHGFI_DISPLAYNAME);
  Result := SFI.szDisplayName;
  // В Win9x, Me - нет метки диска -> #32 + (x:)
  // В WinNT 5.x - нет метки диска -> Название устройства + #32 + (x:)
  if Pos('(', Result) <> 0 then
    SetLength(Result, Pos('(', Result) - 2);
end;

begin
  Result := '';
  WinVer := LOBYTE(LOWORD(GetVersion));
  DriveType := GetDriveType(PChar(Drv + ':\'));

  if (WinVer <= 4) and (DriveType <> DRIVE_REMOVABLE) or VolReal then
  begin // Win9x, Me, NT <= 4.0
    Buf[0] := #0;
    GetVolumeInformation(PChar(Drv + ':\'), Buf, DWORD(SizeOf(Buf)), nil,
      NotUsed, NotUsed, nil, 0);
    Result := Buf;

    if VolReal and (WinVer >= 5) and (Result <> '') and
       (DriveType <> DRIVE_REMOVABLE) then // Win2k, XP и выше
      Result := DisplayName(Drv)
    else if (Result = '') and (not VolReal) then
      Result := '<none>';
  end
  else
    Result := DisplayName(Drv);
end;

(* ОЖИДАНИЕ ИЗМЕНЕНИЯ МЕТКИ ДИСКА *)

procedure WaitLabelChange(Drv: Char; Str: string);
var
  st1, st2: string;
begin
  st1 := TrimLeft(Str);
  st2 := st1;
  while st1 = st2 do
    st2 := GetLabelDisk(Drv, FALSE);
end;
