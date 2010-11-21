unit hiVolume;

interface

uses Kol,Share,mmsystem,Debug;

type
  THIVolume = class(TDebug)
   private
   public
    _prop_Device:byte;
    _data_Right:THI_Event;
    _data_Left:THI_Event;
    _event_onLVolume:THI_Event;
    _event_onRVolume:THI_Event;

    procedure _work_doVolume(var _Data:TData; Index:word);
    procedure _work_doGetVolume(var _Data:TData; Index:word);
    procedure _work_doDevide(var _Data:TData; Index:word);
  end;

implementation

procedure THIVolume._work_doVolume;
var l,r:integer;
begin
  //debug(int2str(auxGetNumDevs));
  r := ReadInteger(_Data,_data_Left,0);
  l := ReadInteger(_Data,_data_Right,0);
  case _prop_Device of
   0: waveOutSetVolume(0, l shl 16 + r);
   1: midiOutSetVolume(0, l shl 16 + r);
  end;
end;

procedure THIVolume._work_doGetVolume;
var c:cardinal;
begin
  case _prop_Device of
   0: waveOutGetVolume(0,@c);
   1: midiOutGetVolume(0,@c);
  end;
  _hi_OnEvent(_event_onLVolume,integer(c shr 16));
  _hi_OnEvent(_event_onRVolume,integer(c and $FFFF));
end;

procedure THIVolume._work_doDevide;
begin
  _prop_Device := ToInteger(_Data);
end;

end.
