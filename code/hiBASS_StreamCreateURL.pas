unit hiBASS_StreamCreateURL;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_StreamCreateURL = class(TDebug)
   private
    FHandle:HSTREAM;
    FSync:HSYNC;
   public
    _prop_URL:string;
    _prop_Flags:integer;
    _prop_Name:string;
    _prop_ParsePlayList:boolean;

    _data_URL:THI_Event;
    _event_onError:THI_Event;
    _event_onMeta:THI_Event;
    _event_onStatus:THI_Event;
    _event_onCreate:THI_Event;

    procedure _work_doCreate(var _Data:TData; Index:word);
    procedure _work_doDestroy(var _Data:TData; Index:word);
    function getInterfaceBassHandle:pointer;
  end;

implementation

function THIBASS_StreamCreateURL.getInterfaceBassHandle:pointer;
begin
   Result := @FHandle;
end;

procedure SyncProc(handle:HSYNC; channel:DWORD; data:DWORD; user:pointer); stdcall;
begin
   _hi_onEvent(THIBASS_StreamCreateURL(user)._event_onMeta);
end;

procedure _dproc(buffer: Pointer; len: DWORD; user: Pointer); stdcall;
begin
  if (buffer <> nil) and (len = 0) then 
   _hi_onEvent(THIBASS_StreamCreateURL(user)._event_onStatus, string(pchar(buffer)));
end;

procedure THIBASS_StreamCreateURL._work_doCreate;
var f:PChar;
begin         
   f := PChar(ReadString(_Data, _data_URL, _prop_URL));
   if FHandle <> 0 then
     begin
       BASS_ChannelRemoveSync(FHandle, FSync);
       BASS_StreamFree(FHandle);
     end;
   
   if _prop_ParsePlayList then
     BASS_SetConfig(BASS_CONFIG_NET_PLAYLIST, 1);
   FHandle := BASS_StreamCreateURL(f, 0, _prop_Flags or BASS_STREAM_STATUS, _dproc, self);
   if FHandle = 0 then
     _hi_onEvent(_event_onError, BASS_ErrorGetCode())
   else 
    begin
      FSync := BASS_ChannelSetSync(FHandle, BASS_SYNC_MIXTIME or BASS_SYNC_META, 0, SyncProc, self);
      _hi_onEvent(_event_onCreate);
    end;  
end;

procedure THIBASS_StreamCreateURL._work_doDestroy;
begin
  BASS_StreamFree(FHandle);
  FHandle := 0;
end;

end.
