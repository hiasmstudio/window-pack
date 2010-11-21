unit hiBASS_MusicFile;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_MusicFile = class(TDebug)
   private
    hs:HMUSIC;
    procedure Err;
   public
    _data_FileName:THI_Event;
    _event_onError:THI_Event;

    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doFree(var _Data:TData; Index:word);
    procedure _var_HMUSIC(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_MusicFile.Err;
begin
   if BASS_ErrorGetCode > 0 then
    _hi_OnEvent(_event_onError,integer(BASS_ErrorGetCode));
end;

procedure THIBASS_MusicFile._work_doLoad;
begin
   _work_doFree(_Data,0);
   hs := BASS_MusicLoad(false,PChar(ReadString(_Data,_data_FileName)),0,0,BASS_MUSIC_CALCLEN,0);

   //BASS_MusicSetPositionScaler(hs,10);
   //_debug(int2str(channels));
   Err;
end;

procedure THIBASS_MusicFile._work_doFree;
begin
   if hs > 0 then
    begin
      BASS_ChannelStop(hs);
      BASS_SampleFree(hs);
    end;
   hs := 0;
   //Err;
end;

procedure THIBASS_MusicFile._var_HMUSIC;
begin
  dtInteger(_Data,hs);
end;

end.
