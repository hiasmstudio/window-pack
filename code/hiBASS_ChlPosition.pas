unit hiBASS_ChlPosition;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_ChlPosition = class(TDebug)
   private
    procedure Err;
   public
    _data_Handle:THI_Event;
    _data__Position:THI_Event;
    _event_onError:THI_Event;

    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _var_Position(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_ChlPosition.Err;
begin
   if BASS_ErrorGetCode > 0 then
    _hi_OnEvent(_event_onError,integer(BASS_ErrorGetCode));
end;

procedure THIBASS_ChlPosition._work_doPosition;
var h:cardinal;
begin
  h := ReadInteger(_Data,_data_Handle);
  BASS_ChannelSetPosition(h,ReadInteger(_Data,_data__Position));
  Err;
end;

procedure THIBASS_ChlPosition._var_Position;
var h:cardinal;
begin
  h := ReadInteger(_Data,_data_Handle);
  dtInteger(_Data,BASS_ChannelGetPosition(h));
  Err;
end;

end.
