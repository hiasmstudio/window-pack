unit hiBASS_ChlAttributes;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_ChlAttributes = class(TDebug)
   private
    procedure Err;
   public
    _prop_Volume:integer;
    _prop_Freq:integer;
    _prop_Pan:integer;
    _data__Volume:THI_Event;
    _data__Freq:THI_Event;
    _data__Pan:THI_Event;
    _data_Handle:THI_Event;
    _event_onError:THI_Event;

    procedure _work_doAttributes(var _Data:TData; Index:word);
    procedure _var_Volume(var _Data:TData; Index:word);
    procedure _var_Freq(var _Data:TData; Index:word);
    procedure _var_Pan(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_ChlAttributes.Err;
begin
   if BASS_ErrorGetCode > 0 then
    _hi_OnEvent(_event_onError,integer(BASS_ErrorGetCode));
end;

procedure THIBASS_ChlAttributes._work_doAttributes;
begin
   BASS_ChannelSetAttributes(ReadInteger(_Data,_data_Handle),
     ReadInteger(_Data,_data__Freq,_prop_Freq),
     ReadInteger(_Data,_data__Volume,_prop_Volume),
     ReadInteger(_Data,_data__Pan,_prop_Pan));
   Err;
end;

procedure THIBASS_ChlAttributes._var_Volume;
var f,v:cardinal; p:integer;
begin
   BASS_ChannelGetAttributes(ReadInteger(_Data,_data_Handle),f,v,p);
   dtInteger(_Data,v);
   Err;
end;

procedure THIBASS_ChlAttributes._var_Freq;
var f,v:cardinal; p:integer;
begin
   BASS_ChannelGetAttributes(ReadInteger(_Data,_data_Handle),f,v,p);
   dtInteger(_Data,f);
   Err;
end;

procedure THIBASS_ChlAttributes._var_Pan;
var f,v:cardinal; p:integer;
begin
   BASS_ChannelGetAttributes(ReadInteger(_Data,_data_Handle),f,v,p);
   dtInteger(_Data,p);
   Err;
end;

end.
