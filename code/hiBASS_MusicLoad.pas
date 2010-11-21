unit hiBASS_MusicLoad;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_MusicLoad = class(TDebug)
   private
    FHandle:HMUSIC;
    FSync:HSYNC;
   public
    _prop_FileName:string;
    _prop_Flags:cardinal;
    _prop_Name:string;

    _data_FileName:THI_Event;
    _event_onError:THI_Event;
    _event_onEndPlay:THI_Event;
    _event_onCreate:THI_Event;

    procedure _work_doCreate(var _Data:TData; Index:word); 
    function getInterfaceBassHandle:pointer;
  end;

implementation

function THIBASS_MusicLoad.getInterfaceBassHandle:pointer;
begin
   Result := @FHandle;
end;

procedure SyncProc(handle:HSYNC; channel:DWORD; data:DWORD; user:pointer); stdcall;
begin
   _hi_onEvent(THIBASS_MusicLoad(user)._event_onEndPlay);
end;

procedure THIBASS_MusicLoad._work_doCreate;
var f:PChar;
begin         
   f := PChar(ReadString(_Data, _data_FileName, _prop_FileName));
   if FHandle <> 0 then
     begin
       BASS_ChannelRemoveSync(FHandle, FSync);
       BASS_StreamFree(FHandle);
     end;
   
   FHandle := BASS_MusicLoad(false, f, 0, 0, _prop_Flags, 0);
   if FHandle = 0 then
     _hi_onEvent(_event_onError, BASS_ErrorGetCode())
   else 
    begin
      FSync := BASS_ChannelSetSync(FHandle, BASS_SYNC_MIXTIME or BASS_SYNC_END, 0, SyncProc, self);
      _hi_onEvent(_event_onCreate);
    end; 
end;

end.
