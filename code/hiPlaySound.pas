unit hiPlaySound;

interface

uses Kol,Share,mmsystem,Windows,Debug;

type
  THIPlaySound = class(TDebug)
   private
   public
    _prop_PlayType:byte;
    _prop_FileName:string;
    _prop_Sound:string;

    _data_FileName:THI_Event;
    _event_onEndPlay:THI_Event;

    procedure _work_doPlay(var _Data:TData; Index:word);
  end;
  
const
  PlaySound_value:array[0..2] of byte = (SND_SYNC,SND_ASYNC,SND_ASYNC or SND_LOOP);

procedure Play(const SName:string; Flag:cardinal);

implementation

procedure Play(const SName:string; Flag:cardinal);
var
  pData: Pointer;
begin
  if FileExists(SName) then
    sndPlaySound(PChar(sname),Flag)
  else
   begin
    pData := LoadResData(pchar(sname));
    if pData <> nil then
      PlaySound(PChar(pData), 0, SND_MEMORY or Flag)
    else PlaySound(nil, 0, SND_ASYNC);
   end;
end;

procedure THIPlaySound._work_doPlay;
var FFileName:string;
begin
   if _prop_Sound <> '' then
    FFileName := _prop_Sound
   else FFileName := ReadString(_Data,_data_FileName,_prop_FileName);
   
   Play(FFileName,PlaySound_value[_prop_PlayType]);
   _hi_OnEvent(_event_onEndPlay);
end;

end.
