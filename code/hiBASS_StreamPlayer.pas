unit hiBASS_StreamPlayer;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_StreamPlayer = class(TDebug)
   private
    sh:HSYNC;
    
    procedure Err;
   public
    _data_Handle:THI_Event;    
    _event_onEndPlay:THI_Event;
    _event_onError:THI_Event;

    procedure EndPlay;
    procedure _work_doPlay(var _Data:TData; Index:word);
    procedure _var_Length(var _Data:TData; Index:word);
    procedure _var_Decode(var _Data:TData; Index:word);
    procedure _var_Download(var _Data:TData; Index:word);
    procedure _var_End(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_StreamPlayer.Err;
begin
   if BASS_ErrorGetCode > 0 then
    _hi_OnEvent(_event_onError,integer(BASS_ErrorGetCode));
end;

procedure Proc(handle: HSYNC; channel, data: DWORD; user: DWORD); stdcall;
begin
   THIBASS_StreamPlayer(User).EndPlay;
end;

procedure THIBASS_StreamPlayer.EndPlay;
begin
   _hi_OnEvent(_event_onEndPlay);
end;

procedure THIBASS_StreamPlayer._work_doPlay;
var h:cardinal;
begin
   h := ReadInteger(_Data,_data_Handle);
   BASS_ChannelPlay( h,true );
   if sh > 0 then
    BASS_ChannelRemoveSync(h,sh);
   sh := BASS_ChannelSetSync(h,BASS_SYNC_ONETIME or BASS_SYNC_END,0,Proc,cardinal(self));
   Err;
end;

procedure THIBASS_StreamPlayer._var_Length;
begin
   dtInteger(_data,BASS_StreamGetLength( ReadInteger(_Data,_data_Handle) ));
end;

procedure THIBASS_StreamPlayer._var_Decode;
begin
   dtInteger(_data,BASS_StreamGetFilePosition( ReadInteger(_Data,_data_Handle),BASS_FILEPOS_DECODE ));
end;

procedure THIBASS_StreamPlayer._var_Download;
begin
   dtInteger(_data,BASS_StreamGetFilePosition( ReadInteger(_Data,_data_Handle),BASS_FILEPOS_DOWNLOAD ));
end;

procedure THIBASS_StreamPlayer._var_End;
begin
   dtInteger(_data,BASS_StreamGetFilePosition( ReadInteger(_Data,_data_Handle),BASS_FILEPOS_END ));
end;

end.
