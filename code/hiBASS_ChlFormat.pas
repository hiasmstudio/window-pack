unit hiBASS_ChlFormat;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_ChlFormat = class(TDebug)
   private
    procedure Err;
   public
    _prop_Mode:function(var _Data:TData):int64 of object;

    _data_Handle:THI_Event;
    _data_Data:THI_Event;
    _event_onFormat:THI_Event;
    _event_onError:THI_Event;

    procedure _work_doFormat(var _Data:TData; Index:word);
    function BytesToSecond(var _Data:TData):int64;
    function SecondToBytes(var _Data:TData):int64;
    function MusicToSecond(var _Data:TData):int64;
    function SecondToMusic(var _Data:TData):int64;
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_ChlFormat.Err;
begin
   if BASS_ErrorGetCode > 0 then
    _hi_OnEvent(_event_onError,integer(BASS_ErrorGetCode));
end;

function THIBASS_ChlFormat.BytesToSecond;
var  h:cardinal;
begin
   h := ReadInteger(_Data,_data_Handle);
   Result := Round(BASS_ChannelBytes2Seconds(h,ReadInteger(_Data,_data_Data)));
end;

function THIBASS_ChlFormat.SecondToBytes;
var  h:cardinal;
begin
   h := ReadInteger(_Data,_data_Handle);
   Result := BASS_ChannelSeconds2Bytes(h,ReadInteger(_Data,_data_Data))
end;

function THIBASS_ChlFormat.MusicToSecond;
var
  Val:int64;
  p1,p2:integer;
begin
   Val := ReadInteger(_Data,_data_Data);
   p1 := val shr 16;
   p2 := (val and $FFFF) shl 6;
   Result := (p2 + p1) shr 3;
end;

function THIBASS_ChlFormat.SecondToMusic;
begin
   Result := ReadInteger(_Data,_data_Data) or $FFFF0000;
end;

procedure THIBASS_ChlFormat._work_doFormat;
begin
   _hi_OnEvent(_event_onFormat,_prop_Mode(_Data));
   Err;
end;

procedure THIBASS_ChlFormat._var_Result;
begin
   dtNull(_Data);
   dtInteger(_Data,_prop_Mode(_Data));
end;

end.
