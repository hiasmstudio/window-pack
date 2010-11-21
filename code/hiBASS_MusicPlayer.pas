unit hiBASS_MusicPlayer;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_MusicPlayer = class(TDebug)
   private
    sh:HSYNC;
    Arr:PArray;
    procedure Err;

    procedure _Set(var Item:TData; var Val:TData);
    function _Get(Var Item:TData; var Val:TData):boolean;
    function Count:integer;
   public
    _data_Handle:THI_Event;
    _event_onEndPlay:THI_Event;
    _event_onError:THI_Event;

    procedure EndPlay;
    destructor Destroy; override;
    procedure _work_doPlay(var _Data:TData; Index:word);
    procedure _work_doAmplify(var _Data:TData; Index:word);
    procedure _work_doPanSep(var _Data:TData; Index:word);
    procedure _var_Length(var _Data:TData; Index:word);
    procedure _var_Name(var _Data:TData; Index:word);
    procedure _var_ChannelVol(var _Data:TData; Index:word);
  end;

implementation

destructor THIBASS_MusicPlayer.Destroy;
begin
   if Arr <> nil then dispose(Arr);
   inherited; 
end; 

procedure THIBASS_MusicPlayer.Err;
begin
   if BASS_ErrorGetCode > 0 then
    _hi_OnEvent(_event_onError,integer(BASS_ErrorGetCode));
end;

procedure Proc(handle: HSYNC; channel, data: DWORD; user: DWORD); stdcall;
begin
   THIBASS_MusicPlayer(User).EndPlay;
end;

procedure THIBASS_MusicPlayer.EndPlay;
begin
   _hi_OnEvent(_event_onEndPlay);
end;

procedure THIBASS_MusicPlayer._work_doPlay;
var h:cardinal;
begin
  h := ReadInteger(_Data,_data_Handle);
  BASS_ChannelPlay( h,true );
  if sh > 0 then
    BASS_ChannelRemoveSync(h,sh);
  sh := BASS_ChannelSetSync(h,BASS_SYNC_ONETIME or BASS_SYNC_END,0,Proc,cardinal(self));
  Err;
end;

procedure THIBASS_MusicPlayer._work_doAmplify;
begin
  BASS_MusicSetAttribute( ReadInteger(_Data,_data_Handle),BASS_MUSIC_ATTRIB_AMPLIFY,ToInteger(_Data) );
  Err;
end;

procedure THIBASS_MusicPlayer._work_doPanSep;
begin
  BASS_MusicSetAttribute( ReadInteger(_Data,_data_Handle),BASS_MUSIC_ATTRIB_PANSEP,ToInteger(_Data) );
  Err;
end;

procedure THIBASS_MusicPlayer._var_Length;
var h:cardinal;
begin
  h := ReadInteger(_Data,_data_Handle);
  dtInteger(_Data,Round(BASS_ChannelBytes2Seconds(h,BASS_MusicGetLength(h,true))));
  Err;
end;

procedure THIBASS_MusicPlayer._var_Name;
begin
  dtString(_Data,BASS_MusicGetName( ReadInteger(_Data,_data_Handle) ));
  Err;
end;

function THIBASS_MusicPlayer._Get;
var ind:integer;
begin
   ind := ToIntIndex(Item);
   Val.idata := BASS_MusicGetAttribute( ReadInteger(Item,_data_Handle), BASS_MUSIC_ATTRIB_VOL_CHAN + ind );
   if Val.idata = -1 then
    Val.Data_type := data_null
   else Val.Data_type := data_int;
   Result := Val.Data_type <> data_null;
   Err;
end;

procedure THIBASS_MusicPlayer._Set;
var ind:integer;
begin
   ind := ToIntIndex(Item);
   BASS_MusicSetAttribute( ReadInteger(Item,_data_Handle), BASS_MUSIC_ATTRIB_VOL_CHAN + ind,ToInteger(Val) );
   Err;
end;

function THIBASS_MusicPlayer.Count;
var hs:cardinal;
    dt:TData;
begin
   Result := 0;
   dt.Data_type := data_null;
   hs := ReadInteger(dt,_data_Handle);
   while BASS_MusicGetAttribute(hs,BASS_MUSIC_ATTRIB_VOL_CHAN + Result) <> -1 do
     inc(Result);
end;

procedure THIBASS_MusicPlayer._var_ChannelVol;
begin
  if Arr = nil then
     Arr := CreateArray(_Set,_Get,Count,nil);
  dtArray(_Data,Arr);
end;

end.
