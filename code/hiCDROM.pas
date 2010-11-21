unit hiCDROM;

interface

uses Kol,Share,mmsystem,Debug,Windows{,Media};

{$I share.inc}

type
  THICDROM = class(TDebug)
   private
    FID:cardinal;
    function search_cd:string;
    procedure lock_cd(var _Data:TData;  lock:boolean);
   public
    _data_Disk:THI_Event;
    _prop_Disk:string;

    procedure _work_doOpen(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _work_doLock(var _Data:TData; Index:word);
    procedure _work_doUnlock(var _Data:TData; Index:word);
    procedure _var_getDisk(var _Data:TData; Index:word);
    procedure _var_Label(var _Data:TData; Index:word);
    procedure _var_isCDInside(var _Data:TData; Index:word);
    procedure _work_doAudioCDPlay(var _Data:TData; Index:word);
    procedure _work_doAudioCDStop(var _Data:TData; Index:word);
  end;

implementation

procedure THICDROM._work_doOpen;
var
  OpenParm: TMCI_Open_Parms;
  FCDROM:string;
begin
  FCDROM := ReadString(_Data,_data_Disk,_prop_Disk);
  if FCDROM = '*' then
    mciSendString('Set cdaudio door open wait', nil, 0, 0)
  else
  with OpenParm do
   begin
    dwCallback := 0;
    lpstrDeviceType := 'CDAudio';
    lpstrElementName := PChar(FCDROM);
    if mciSendCommand(0, MCI_OPEN, MCI_OPEN_TYPE or MCI_OPEN_ELEMENT, Longint(@OpenParm)) = 0 then
       mciSendCommand(OpenParm.wDeviceID, MCI_SET, MCI_SET_DOOR_OPEN, 0);
    mciSendCommand(OpenParm.wDeviceID, mci_Close, mci_Open_Type or mci_Open_Element, Longint(@OpenParm));
   end;
end;

procedure THICDROM._work_doClose;
var
  OpenParm: TMCI_Open_Parms;
  FCDROM:string;
begin
  FCDROM := ReadString(_Data,_data_Disk,_prop_Disk);
  if FCDROM = '*' then
    mciSendString('Set cdaudio door closed wait', nil, 0, 0)
  else
  with OpenParm do
   begin
    dwCallback := 0;
    lpstrDeviceType := 'CDAudio';
    lpstrElementName := PChar(FCDROM);
    if mciSendCommand(0, MCI_OPEN, MCI_OPEN_TYPE or MCI_OPEN_ELEMENT, Longint(@OpenParm)) = 0 then
       mciSendCommand(OpenParm.wDeviceID, MCI_SET, MCI_SET_DOOR_CLOSED, 0);
    mciSendCommand(OpenParm.wDeviceID, mci_Close, mci_Open_Type or mci_Open_Element, Longint(@OpenParm));
   end;
end;

function THICDROM.search_cd;
var 
   path: string;
   i: integer;
begin
   Result:='*';
   for i:=ord('A') to ord('Z') do begin
      path:=chr(i)+':\';
      if GetDriveType(PChar(path))=DRIVE_CDROM then begin Result:=chr(i); break; end;
   end;
end;

procedure THICDROM.lock_cd;
const
   IOCTL_STORAGE_MEDIA_REMOVAL = $002D4804;
var
   hDrive : THandle;
   Returned : DWORD;
   DisableEject : boolean;
   FCDROM:string;
begin
   FCDROM := ReadString(_Data,_data_Disk,_prop_Disk);
   if FCDROM = '*' then
    FCDROM := search_cd;
   if FCDROM <> '*' then
    begin
      hDrive := CreateFile(PChar('\\.\' + FCDROM + ':'),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
      DisableEject := lock;
      try
         DeviceIoControl(hDrive,IOCTL_STORAGE_MEDIA_REMOVAL,@DisableEject,sizeof(DisableEject),nil,0,Returned,nil);
      finally
         CloseHandle(hDrive);
      end;
    end;
end;

procedure THICDROM._work_doLock;
begin
   lock_cd(_data,true);
end;

procedure THICDROM._work_doUnlock;
begin
   lock_cd(_data,false);
end;

procedure THICDROM._var_getDisk;
begin
   dtString(_Data,search_cd);
end;

procedure THICDROM._var_Label;
var
   MaximumComponentLength : DWORD;
   FileSystemFlags : DWORD;
   FCDROM,s:string;
begin
   FCDROM := ReadString(_Data,_data_Disk,_prop_Disk);
   if FCDROM = '*' then
    FCDROM := search_cd;

   SetLength(s, 64);
   GetVolumeInformation(PChar(FCDROM + ':'),PChar(s),
     Length(s),nil,MaximumComponentLength,FileSystemFlags,nil,0);
   SetLength(s, pos(#0,s));
   dtString(_Data,s);
end;

procedure THICDROM._var_isCDInside;
var s:array[0..256] of char;
{var
   
   OldErrorMode: Word;   }
  FCDROM:string;
  ErrorMode: Word;
  {$ifdef F_P}
  p1,p2,p3,p4:cardinal;
  {$endif}
begin
   FCDROM := ReadString(_Data,_data_Disk,_prop_Disk);
   if FCDROM = '*' then
    FCDROM := search_cd;

   (*
   OldErrorMode := SetErrorMode(SEM_NOOPENFILEERRORBOX);
   {$I-}
   ChDir(FCDROM + ':\');
   {$I+}
   Data.idata := integer(IoResult > 0);
   SetErrorMode(OldErrorMode);
   *)
   ErrorMode := SetErrorMode(SEM_FailCriticalErrors);
   {$ifdef F_P}
   // убарть если работает !!!!!!!!!!!
   GetDiskFreeSpace(PChar(FCDROM + ':'),p1,p2,p3,p4);
   dtInteger(_Data, integer(not((p3 > 0)or(p4 > 0))) );
   {$else}
   with DiskFreeSpace( FCDROM + ':' ) do
     dtInteger(_Data,integer( not((Lo > 0)or(Hi > 0))) );
   {$endif}
   SetErrorMode(ErrorMode);

   if (search_cd <> '*') then
    begin
      mciSendString('Open cdaudio alias dlma', nil, 0, 0);
      mciSendString('status dlma mode', @s, 255, 0);
      mciSendString('close dlma', nil, 0, 0);
    end;
end;

procedure THICDROM._work_doAudioCDPlay;
var
  OpenParm: TMCI_Open_Parms;
  FCDROM:string;
  pp:TMCI_Play_Parms;
begin
  FCDROM := ReadString(_Data,_data_Disk,_prop_Disk);
  if FCDROM = '*' then
   FCDROM := search_cd;
  with OpenParm do
   begin
    dwCallback := 0;
    lpstrDeviceType := 'CDAudio';
    lpstrElementName := PChar(FCDROM);
    if mciSendCommand(0, MCI_OPEN, MCI_OPEN_TYPE or MCI_OPEN_ELEMENT, Longint(@OpenParm)) = 0 then
      begin
        pp.dwCallback := 0;
        pp.dwFrom := 0;
        pp.dwTo := 0;
        FID := OpenParm.wDeviceID;
        mciSendCommand(FID, MCI_PLAY,0, Longint(@pp));
      end;
   end;
end;

procedure THICDROM._work_doAudioCDStop;
var
  OpenParm: TMCI_Open_Parms;
  FCDROM:string;
  //pp:TMCI_Play_Parms;
begin
  FCDROM := ReadString(_Data,_data_Disk,_prop_Disk);
  if FCDROM = '*' then
   FCDROM := search_cd;

  with OpenParm do
   begin
    dwCallback := 0;
    lpstrDeviceType := 'CDAudio';
    lpstrElementName := PChar(FCDROM);
    mciSendCommand(FID, MCI_STOP, 0,0);
    mciSendCommand(FID, MCI_CLOSE, mci_Open_Type or mci_Open_Element, Longint(@OpenParm));
    {
    dwCallback := 0;
    lpstrDeviceType := 'CDAudio';
    lpstrElementName := PChar(FCDROM);
    if mciSendCommand(0, MCI_OPEN, MCI_OPEN_TYPE or MCI_OPEN_ELEMENT, Longint(@OpenParm)) = 0 then
      begin
        pp.dwCallback := 0;
        pp.dwFrom := 0;
        pp.dwTo := 0;
        mciSendCommand(OpenParm.wDeviceID, MCI_PLAY,0, Longint(@pp));
      end;
    mciSendCommand(OpenParm.wDeviceID, mci_Close, mci_Open_Type or mci_Open_Element, Longint(@OpenParm));
    }
   end;
end;

end.
