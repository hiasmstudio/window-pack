unit hiBASS_ChannelAttribute;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_ChannelAttribute = class(TDebug)
   private
   public
    _prop_Channel:^cardinal;
    _prop_Attrib:byte;

    _data_Value:THI_Event;
    _event_onAttribute:THI_Event;

    procedure _work_doAttribute(var _Data:TData; Index:word);
    procedure _var_CurValue(var _Data:TData; Index:word);
  end;

implementation


procedure THIBASS_ChannelAttribute._work_doAttribute;
begin
   BASS_ChannelSetAttribute(_prop_Channel^, _prop_Attrib + 1, ReadReal(_Data, _data_Value, 0));
   _hi_onEvent(_event_onAttribute);
end;

procedure THIBASS_ChannelAttribute._var_CurValue;
var f:FLOAT;
begin
   BASS_ChannelGetAttribute(_prop_Channel^, _prop_Attrib + 1, f);
   dtReal(_Data, f);
end;

end.
