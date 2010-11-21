unit hiBASS_RecordStart;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_RecordStart = class(TDebug)
   private          
    FHandle:HRECORD;
    WaveStream:PStream;
    procedure _Write(buf:pointer; len:dword);
   public
    _prop_FileName:string;
    _prop_Freq:integer;
    _prop_Channels:integer;
    _prop_Mode:byte;
    _prop_Name:string;

    _data_Channels:THI_Event;
    _data_Freq:THI_Event;
    _data_FileName:THI_Event;
    _event_onData:THI_Event;
    _event_onStart:THI_Event;

    procedure _work_doStart(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    function getInterfaceBassHandle:pointer;
  end;

implementation

type
  WAVHDR = packed record
    riff: array[0..3] of Char;
    len: DWord;
    cWavFmt: array[0..7] of Char;
    dwHdrLen: DWord;
    wFormat: Word;
    wNumChannels: Word;
    dwSampleRate: DWord;
    dwBytesPerSec: DWord;
    wBlockAlign: Word;
    wBitsPerSample: Word;
    cData: array[0..3] of Char;
    dwDataLen: DWord;
  end;
  
function THIBASS_RecordStart.getInterfaceBassHandle:pointer;
begin
  Result := @FHandle;
end;

function RecCallback(Handle: HRECORD; buffer: Pointer; length, user: DWord): boolean; stdcall;
begin
  THIBASS_RecordStart(User)._Write(Buffer,Length);
  Result := True;
end;

procedure THIBASS_RecordStart._Write;
begin
   if _prop_Mode = 1 then
    begin
      WaveStream.Size := 0;
      WaveStream.Write(Buf^, Len);
      WaveStream.Position := 0;
      _hi_OnEvent(_event_onData,WaveStream);
    end
   else WaveStream.Write(Buf^, Len);
end;

procedure THIBASS_RecordStart._work_doStart;
var fname:string;
    ch,f:integer;
    WaveHdr: WAVHDR;
begin
  fname := ReadString(_Data, _data_FileName, _prop_FileName);
  ch := ReadInteger(_Data, _data_Channels, _prop_Channels);
  f := ReadInteger(_Data, _data_Freq, _prop_Freq);  

  WaveHdr.riff := 'RIFF';
  WaveHdr.len := 36;
  WaveHdr.cWavFmt := 'WAVEfmt ';
  WaveHdr.dwHdrLen := 16;
  WaveHdr.wFormat := 1;
  WaveHdr.wNumChannels := ch;
  WaveHdr.dwSampleRate := f;
  WaveHdr.wBlockAlign := 2*ch;
  WaveHdr.dwBytesPerSec := 16*ch*f div 8;
  WaveHdr.wBitsPerSample := 16;
  WaveHdr.cData := 'data';
  WaveHdr.dwDataLen := 0;
  if _prop_Mode = 1 then
    WaveStream := NewMemoryStream
  else
   begin
    WaveStream := NewReadWriteFileStream(fname);
    WaveStream.Write(WaveHdr, SizeOf(WAVHDR));
   end;

  FHandle := BASS_RecordStart(f, ch, 0, @RecCallback, self);
  _hi_OnEvent(_event_onStart);
end;

procedure THIBASS_RecordStart._work_doStop;
var i:integer;
begin
   if BASS_ChannelIsActive(FHandle) = 1 then
    begin
     BASS_ChannelStop(FHandle);

     if _prop_Mode = 0 then
      begin
       WaveStream.Position := 4;
       i := WaveStream.Size - 8;
       WaveStream.Write(i, 4);
       dec(i,$24);
       WaveStream.Position := 40;
       WaveStream.Write(i, 4);
      end;

     WaveStream.Free;
    end;
end;

end.
