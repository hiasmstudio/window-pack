unit hiBASS_CD;

interface

uses Kol,Share,Debug,BASSCD;

type
  THIBASS_CD = class(TDebug)
   private
    FLTrack:integer;
    Drive:byte;
   public
    _prop_Drive:integer;

    _data_Track:THI_Event;
    _data_Drive:THI_Event;
    _event_onError:THI_Event;

    procedure _work_doInit(var _Data:TData; Index:word);
    procedure _work_doPlay(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _work_doFree(var _Data:TData; Index:word);
    procedure _work_doDoor(var _Data:TData; Index:word);
    procedure _var_Handle(var _Data:TData; Index:word);
    procedure _var_TracksCount(var _Data:TData; Index:word);
    procedure _var_TrackLength(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_CD._work_doInit;
begin
   Drive := ReadInteger(_Data,_data_Drive,_prop_Drive);
end;

procedure THIBASS_CD._work_doPlay;
begin
  FLTrack := ReadInteger(_Data,_data_Track);
  BASS_CD_Analog_Play(Drive,FLTrack,0);
end;

procedure THIBASS_CD._work_doStop;
begin
  BASS_CD_Analog_Stop(Drive);
end;

procedure THIBASS_CD._work_doFree;
begin
  BASS_CD_Release(Drive);
end;

procedure THIBASS_CD._work_doDoor;
begin
  BASS_CD_Door(Drive,ToInteger(_Data));
end;

procedure THIBASS_CD._var_TracksCount;
begin
  dtInteger(_Data, BASS_CD_GetTracks(Drive));
end;

procedure THIBASS_CD._var_TrackLength;
begin
  dtInteger(_Data,BASS_CD_GetTrackLength(Drive,FLTrack));
end;

procedure THIBASS_CD._var_Handle;
begin
  dtInteger(_Data,0);
end;

end.
