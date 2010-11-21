unit hiBASS_ChannelPosition;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_ChannelPosition = class(TDebug)
   private
   public
    _prop_Channel:^cardinal;
    _prop_Mode:byte;

    _data_Position:THI_Event;
    _event_onPosition:THI_Event;

    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _var_CurPosition(var _Data:TData; Index:word);
    procedure _var_Length(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_ChannelPosition._work_doPosition;
var md:integer;
    pos:int64;
begin
  if _prop_Mode = 2 then
   begin 
     md := 0;
     pos := BASS_ChannelSeconds2Bytes(_prop_Channel^, ReadReal(_Data, _data_Position, 0));
   end
  else
   begin  
     md := _prop_Mode;
     pos := ReadInteger(_Data, _data_Position, 0); 
   end;
  BASS_ChannelSetPosition(_prop_Channel^, pos, md);
end;

procedure THIBASS_ChannelPosition._var_CurPosition;
var pos:int64;
    md:integer;
begin
   if _prop_Mode = 2 then
     md := 0
   else md := _prop_Mode;
   pos := BASS_ChannelGetPosition(_prop_Channel^, md);
   if _prop_Mode = 2 then
     dtReal(_Data, BASS_ChannelBytes2Seconds(_prop_Channel^, pos))
   else dtInteger(_Data, pos);
end;

procedure THIBASS_ChannelPosition._var_Length;
var pos:int64;
    md:integer;
begin
   if _prop_Mode = 2 then
     md := 0
   else md := _prop_Mode;
   pos := BASS_ChannelGetLength(_prop_Channel^, md);
   if _prop_Mode = 2 then
     dtReal(_Data, BASS_ChannelBytes2Seconds(_prop_Channel^, pos))
   else dtInteger(_Data, pos);
end;

end.
