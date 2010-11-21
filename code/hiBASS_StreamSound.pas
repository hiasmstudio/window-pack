unit hiBASS_StreamSound;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_StreamSound = class(TDebug)
   private
    st:HSTREAM;

    procedure Err;
   public
    _prop_Freq:integer;

    _data_Data:THI_Event;
    _event_onError:THI_Event;

    function ReadWord:word;
    procedure _work_doCreate(var _Data:TData; Index:word);
    procedure _work_doDestroy(var _Data:TData; Index:word);
    procedure _var_Handle(var _Data:TData; Index:word);
  end;

implementation

procedure THIBASS_StreamSound.Err;
begin
   if BASS_ErrorGetCode > 0 then
    _hi_OnEvent(_event_onError,integer(BASS_ErrorGetCode));
end;

function MakeSine(handle: HSTREAM; buffer: Pointer; length: DWORD; user: DWORD): DWORD; stdcall;
var
  buf: ^WORD;
  i, len: Integer;
begin
  buf := buffer;
  len := length div 2;
  // write the sine function to the output stream
  for i := 0 to len - 1 do begin
    buf^ := THIBASS_StreamSound(user).ReadWord;//Trunc(Amplitude*(i mod 10));//Trunc(Sin(SineCount * PI) * Amplitude);
    Inc(buf);
    //SineCount := SineCount + (Frequency / 44100);
  end;
  Result := length;
 
end;

function THIBASS_StreamSound.ReadWord;
begin
   Result := ToIntegerEvent(_data_Data);
end;

procedure THIBASS_StreamSound._work_doCreate;
begin
   st := BASS_StreamCreate(_prop_Freq, 2, 0, @MakeSine, integer(self));
   Err;   //_debug('ok');
end;

procedure THIBASS_StreamSound._work_doDestroy;
begin
  BASS_StreamFree(st);
  Err;
end;

procedure THIBASS_StreamSound._var_Handle;
begin
  dtInteger(_Data,st);
end;

end.
