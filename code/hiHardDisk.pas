unit hiHardDisk;

interface

uses Kol,Share,Debug,Windows;

type
  THIHardDisk = class(TDebug)
   private
   public
    _data_Disk:THI_Event;
    _prop_Disk:string;
    _prop_Size:integer;
    _event_onEnum:THI_Event;

    procedure _work_doLabel(var _Data:TData; Index:word);
    procedure _work_doEject(var _Data:TData; Index:word);
    procedure _work_doEnum(var _Data:TData; Index:word);
    procedure _var_Size(var _Data:TData; Index:word);
    procedure _var_FreeSize(var _Data:TData; Index:word);
    procedure _var_LoadSize(var _Data:TData; Index:word);
  end;

implementation


procedure THIHardDisk._work_doLabel;
begin
     SetVolumeLabel(PChar(ReadString(_Data,_data_Disk,_prop_Disk) + '\'), PChar(ToString(_Data)));
end;

const
  IOCTL_STORAGE_BASE   =     $0000002d;
  FILE_READ_ACCESS     =     $0001;
  FILE_ANY_ACCESS      =     $0000;
  FILE_DEVICE_FILE_SYSTEM =  $00000009;
  METHOD_BUFFERED         =  $0;
  IOCTL_STORAGE_MEDIA_REMOVAL = ((IOCTL_STORAGE_BASE shl 16) or
                                     (FILE_READ_ACCESS shl 14) or
                                     ($0201 shl 2) or METHOD_BUFFERED);
  IOCTL_STORAGE_EJECT_MEDIA   = ((IOCTL_STORAGE_BASE shl 16) or
                                     (FILE_READ_ACCESS shl 14) or
                                     ($0202 shl 2) or METHOD_BUFFERED);

  FSCTL_LOCK_VOLUME = ((FILE_DEVICE_FILE_SYSTEM shl 16) or
                            (FILE_ANY_ACCESS shl 14) or
                            (6 shl 2) or METHOD_BUFFERED);
  FSCTL_DISMOUNT_VOLUME = ((FILE_DEVICE_FILE_SYSTEM shl 16) or
                                (FILE_ANY_ACCESS shl 14) or
                                (8 shl 2) or METHOD_BUFFERED);

procedure THIHardDisk._work_doEject;
var hVolume:cardinal;
    PMRBuffer:boolean;
    dwBytesReturned:DWORD;
begin
 hVolume := CreateFile(PChar('\\.\' + ReadString(_Data,_data_Disk,_prop_Disk) + ':'), GENERIC_READ or GENERIC_WRITE,
                              FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
 PMRBuffer := False;
 if( hVolume <> INVALID_HANDLE_VALUE )then
   if( (DeviceIoControl(hVolume, FSCTL_LOCK_VOLUME, nil, 0, nil, 0,
                              dwBytesReturned, nil)) and
      (DeviceIoControl(hVolume, FSCTL_DISMOUNT_VOLUME,
                              nil, 0, nil, 0,  dwBytesReturned, nil)) and
      (DeviceIoControl(hVolume, IOCTL_STORAGE_MEDIA_REMOVAL,
                          @PMRBuffer, sizeof(PMRBuffer), nil, 0,
                          dwBytesReturned, nil)) and
      (DeviceIoControl(hVolume, IOCTL_STORAGE_EJECT_MEDIA, nil, 0,
                                nil, 0, dwBytesReturned, nil)) )then
      //ShowMessage("Media has been ejected safely");
   else;
     //ShowMessage("error");
  CloseHandle(hVolume);
end;

procedure THIHardDisk._work_doEnum(var _Data:TData; Index:word);
var
  Drive: byte;
  dt,ndt,odt:TData;
  s:PData;
  dr:string;
  serial,mcl:DWORD;
  vol,fs:array[0..255] of char;
begin
  for Drive := 0 to 25 do
    if GetLogicalDrives and (1 shl Drive) > 0 then
     begin
       dr := Chr(Drive + $41) + ':\'; 
       dtString(dt, Chr(Drive + $41));       
       dtInteger(ndt,GetDriveType(PChar(dr))); 
       AddMTData(@dt,@ndt,s);
       mcl := 0;
       GetVolumeInformation(PChar(dr), vol, 256, @serial, mcl, mcl, fs, 256);
       dtString(ndt, string(vol));
       AddMTData(@dt,@ndt,s);
       dtInteger(ndt, serial);
       AddMTData(@dt,@ndt,s);
       dtString(ndt, string(fs));
       AddMTData(@dt,@ndt,s);
       odt := dt;
       _hi_onEvent(_event_onEnum, dt);
       FreeData(@odt);
     end;
end; 

const _sx:array[0..2] of cardinal = (1,1024,1024*1024);

procedure THIHardDisk._var_Size;
var X,Y,Z,S:DWord;
    d:string;
begin
  d := ReadString(_Data,_data_Disk,_prop_Disk);
  if length(d) = 1 then d := d + ':';
  getDiskFreeSpace(PChar(d),X,Y,Z,S);
  dtInteger(_Data,(S div 1024)*X*Y div _sx[_prop_Size]);
end;

procedure THIHardDisk._var_FreeSize;
var X,Y,Z,S:DWord;
    d:string;
begin
  d := ReadString(_Data,_data_Disk,_prop_Disk);
  if length(d) = 1 then d := d + ':';
  getDiskFreeSpace(PChar(d),X,Y,Z,S);
  dtInteger(_Data,(Z div 1024)*X*Y div _sx[_prop_Size]);
end;

procedure THIHardDisk._var_LoadSize;
var X,Y,Z,S:DWord;
    d:string;
begin
  d := ReadString(_Data,_data_Disk,_prop_Disk);
  if length(d) = 1 then d := d + ':';
  getDiskFreeSpace(PChar(d),X,Y,Z,S);
  dtInteger(_Data,((S-Z) div 1024)*X*Y div _sx[_prop_Size]);
end;

end.
