{
  BASSCD 2.1 Delphi API, copyright (c) 2003-2004 Ian Luck.
  Requires BASS 2.1 - available from www.un4seen.com

  See the BASSCD.CHM file for more complete documentation
}

unit BassCD;

interface

uses Windows, Bass;

const
  // Additional error codes returned by BASS_ErrorGetCode
  BASS_ERROR_NOCD       = 12; // no CD in drive
  BASS_ERROR_CDTRACK    = 13; // invalid track number
  BASS_ERROR_NOTAUDIO   = 17; // not an audio track

  // "rwflag" read capability flags
  BASS_CD_RWFLAG_READCDR        = 1;
  BASS_CD_RWFLAG_READCDRW       = 2;
  BASS_CD_RWFLAG_READCDRW2      = 4;
  BASS_CD_RWFLAG_READDVD        = 8;
  BASS_CD_RWFLAG_READDVDR       = 16;
  BASS_CD_RWFLAG_READDVDRAM     = 32;
  BASS_CD_RWFLAG_READANALOG     = $10000;
  BASS_CD_RWFLAG_READM2F1       = $100000;
  BASS_CD_RWFLAG_READM2F2       = $200000;
  BASS_CD_RWFLAG_READMULTI      = $400000;
  BASS_CD_RWFLAG_READCDDA       = $1000000;
  BASS_CD_RWFLAG_READCDDASIA    = $2000000;
  BASS_CD_RWFLAG_READSUBCHAN    = $4000000;
  BASS_CD_RWFLAG_READSUBCHANDI  = $8000000;
  BASS_CD_RWFLAG_READUPC        = $40000000;

  BASS_CD_FREEOLD               = $10000;
  BASS_CD_SUBCHANNEL            = $20000;
  BASS_CD_SUBCHANNEL_NOHW       = $80000;

  // additional CD sync type
  BASS_SYNC_CD_ERROR            = 1000;

  // BASS_CD_Door actions
  BASS_CD_DOOR_CLOSE            = 0;
  BASS_CD_DOOR_OPEN             = 1;
  BASS_CD_DOOR_LOCK             = 2;
  BASS_CD_DOOR_UNLOCK           = 3;

  // BASS_CD_GetID flags
  BASS_CDID_UPC                 = 1;
  BASS_CDID_CDDB                = 2;
  BASS_CDID_CDDB2               = 3;
  BASS_CDID_TEXT                = 4;
  BASS_CDID_CDPLAYER            = 5;

  // BASS_CHANNELINFO type
  BASS_CTYPE_STREAM_CD          = $10200;


type
  BASS_CD_INFO = record
    size: DWORD;        // size of this struct (set this before calling the function)
	rwflags: DWORD;     // read/write capability flags
	canopen: BOOL;      // BASS_CD_DOOR_OPEN/CLOSE is supported?
	canlock: BOOL;      // BASS_CD_DOOR_LOCK/UNLOCK is supported?
	maxspeed: DWORD;    // max read speed (KB/s)
	cache: DWORD;       // cache size (KB)
	cdtext: BOOL;       // can read CD-TEXT
  end;


const
  basscddll = 'basscd.dll';

function BASS_CD_GetDriveDescription(drive:DWORD): PChar; stdcall; external basscddll;
function BASS_CD_GetDriveLetter(drive:DWORD): DWORD; stdcall; external basscddll;
function BASS_CD_GetInfo(drive:DWORD; var info:BASS_CD_INFO): BOOL; stdcall; external basscddll;
function BASS_CD_Door(drive,action:DWORD): BOOL; stdcall; external basscddll;
function BASS_CD_DoorIsOpen(drive:DWORD): BOOL; stdcall; external basscddll;
function BASS_CD_DoorIsLocked(drive:DWORD): BOOL; stdcall; external basscddll;
function BASS_CD_IsReady(drive:DWORD): BOOL; stdcall; external basscddll;
function BASS_CD_GetTracks(drive:DWORD): DWORD; stdcall; external basscddll;
function BASS_CD_GetTrackLength(drive,track:DWORD): DWORD; stdcall; external basscddll;
function BASS_CD_GetID(drive,id:DWORD): PChar; stdcall; external basscddll;
function BASS_CD_Release(drive:DWORD): BOOL; stdcall; external basscddll;

function BASS_CD_StreamCreate(drive,track,flags:DWORD): HSTREAM; stdcall; external basscddll;
function BASS_CD_StreamCreateFile(f:pchar; flags:DWORD): HSTREAM; stdcall; external basscddll;
function BASS_CD_StreamGetTrack(handle:HSTREAM): DWORD; stdcall; external basscddll;

function BASS_CD_Analog_Play(drive,track,pos:DWORD): BOOL; stdcall; external basscddll;
function BASS_CD_Analog_PlayFile(f:pchar; pos:DWORD): DWORD; stdcall; external basscddll;
function BASS_CD_Analog_Stop(drive:DWORD): BOOL; stdcall; external basscddll;
function BASS_CD_Analog_IsActive(drive:DWORD): DWORD; stdcall; external basscddll;
function BASS_CD_Analog_GetPosition(drive:DWORD): DWORD; stdcall; external basscddll;

implementation

end.
