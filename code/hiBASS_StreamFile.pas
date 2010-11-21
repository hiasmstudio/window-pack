unit hiBASS_StreamFile;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_StreamFile = class(TDebug)
   private
    st:HSTREAM;
    procedure Err;
   public
    _data_FileName:THI_Event;
    _event_onError:THI_Event;
    _event_onStatus:THI_Event;

    procedure onStatus(const Text:string);

    procedure _work_doLoadFromFile(var _Data:TData; Index:word);
    procedure _work_doLoadFromURL(var _Data:TData; Index:word);
    procedure _work_doFree(var _Data:TData; Index:word);
    procedure _var_Handle(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_StreamFile.Err;
begin
   if BASS_ErrorGetCode > 0 then
    _hi_OnEvent(_event_onError,integer(BASS_ErrorGetCode));
end;

procedure THIBASS_StreamFile._work_doLoadFromFile;
begin
   _work_doFree(_Data,0);
   st := BASS_StreamCreateFile(false,PChar(ReadString(_Data,_data_FileName)),0,0,0);
   Err;
end;

procedure StatusProc(buffer: Pointer; len, user: DWORD); stdcall;
begin
  if (buffer <> nil) and (len = 0) then
    THIBASS_StreamFile(user).onStatus(PChar(buffer));
end;

procedure THIBASS_StreamFile.onStatus;
begin
   _hi_onEvent(_event_onStatus,Text);
end;

procedure THIBASS_StreamFile._work_doLoadFromURL;
begin
   _work_doFree(_Data,0);

   st := BASS_StreamCreateURL(PChar(ReadString(_Data,_data_FileName)),0,BASS_STREAM_META or BASS_STREAM_STATUS, @StatusProc,integer(self));
   //st := BASS_StreamCreateURL( 'http://64.236.34.97/stream/1003',0,0,nil,0);
   //if st = 0  then
   //   _debug('error');
   Err;
end;

procedure THIBASS_StreamFile._work_doFree;
begin
   if st <> 0 then
     BASS_StreamFree(st);
   St := 0;
end;

procedure THIBASS_StreamFile._var_Handle;
begin
   dtInteger(_Data,st);
end;

end.
