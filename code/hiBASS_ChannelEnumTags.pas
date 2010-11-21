unit hiBASS_ChannelEnumTags;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_ChannelEnumTags = class(TDebug)
   private
   public
    _prop_Type:byte;
    _prop_Channel:^cardinal;

    _event_onEndEnum:THI_Event;
    _event_onEnumTags:THI_Event;

    procedure _work_doEnumTags(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_ChannelEnumTags._work_doEnumTags;
var t:PChar;
begin
   t := BASS_ChannelGetTags(_prop_Channel^, _prop_Type);
   if t <> nil then
     while t^ <> #0 do
      begin
         _hi_onEvent(_event_onEnumTags, string(t));
         t := t + length(t) + 1;
      end; 
   _hi_onEvent(_event_onEndEnum);   
end;

end.
