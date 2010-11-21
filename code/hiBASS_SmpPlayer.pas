unit hiBASS_SmpPlayer;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_SmpPlayer = class(TDebug)
   private
    Info:BASS_SAMPLE;
    procedure Err;
    procedure Read(var _Data:TData);
   public
    _event_onError:THI_Event;
    _data_Handle:THI_Event;

    //procedure EndPlay;
    procedure _work_doPlay(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _var_Freq(var _Data:TData; Index:word);
    procedure _var_Volume(var _Data:TData; Index:word);
    procedure _var_Pan(var _Data:TData; Index:word);
    procedure _var_Length(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_SmpPlayer.Err;
begin
   if BASS_ErrorGetCode > 0 then
    _hi_OnEvent(_event_onError,integer(BASS_ErrorGetCode));
end;

procedure THIBASS_SmpPlayer.Read;
begin
  BASS_SampleGetInfo(ReadInteger(_Data,_data_Handle),Info);
  Err;
end;
    {
procedure Proc(handle: HSYNC; channel, data: DWORD; user: DWORD); stdcall;
begin
   THIBASS_SmpPlayer(User).EndPlay;
end;

procedure THIBASS_SmpPlayer.EndPlay;
begin
  _debug('ok');
end; }

procedure THIBASS_SmpPlayer._work_doPlay;
var h:cardinal;
begin
  h := ReadInteger(_Data,_data_Handle);
  BASS_ChannelPlay(h,true);
  //BASS_ChannelSetSync(h,BASS_SYNC_ONETIME or BASS_SYNC_END,0,Proc,cardinal(self));
  Err;
end;

procedure THIBASS_SmpPlayer._work_doStop;
begin
  BASS_SampleStop(ReadInteger(_Data,_data_Handle));
  Err;
end;

procedure THIBASS_SmpPlayer._var_Freq;
begin
   Read(_Data);
   dtInteger(_Data,Info.freq);
end;

procedure THIBASS_SmpPlayer._var_Volume;
begin
   Read(_Data);
   dtInteger(_Data,Info.volume);
end;

procedure THIBASS_SmpPlayer._var_Pan;
begin
   Read(_Data);
   dtInteger(_Data,Info.pan);
end;

procedure THIBASS_SmpPlayer._var_Length;
begin
   Read(_Data);
   dtInteger(_Data,Info.length div Info.freq);
end;

end.
