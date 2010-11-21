unit hiBASS_SmpFile;

interface

uses Kol,Share,Debug,Bass;

type
  THIBASS_SmpFile = class(TDebug)
   private
    hs:HSAMPLE;
    procedure Err;
   public
    _data_FileName:THI_Event;
    _event_onError:THI_Event;
    _event_onEndPlay:THI_Event;

    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doFree(var _Data:TData; Index:word);
    procedure _var_HSAMPLE(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_SmpFile.Err;
begin
   if BASS_ErrorGetCode > 0 then
    _hi_OnEvent(_event_onError,integer(BASS_ErrorGetCode));
end;

procedure THIBASS_SmpFile._work_doLoad;
begin
   _work_doFree(_Data,0);
   hs := BASS_SampleLoad(false,PChar(ReadString(_Data,_data_FileName)),0,0,1,0);
   Err;
end;

procedure THIBASS_SmpFile._work_doFree;
begin
   if hs <> 0 then
    BASS_SampleFree(hs);
   hs := 0;
end;

procedure THIBASS_SmpFile._var_HSAMPLE;
begin
  dtInteger(_Data,hs);
end;

end.
