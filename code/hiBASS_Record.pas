unit hiBASS_Record;

interface

uses Kol,Share,Debug,BASS;

type
  THIBASS_Record = class(TDebug)
   private
    ChArr:PArray;
    DevArr:PArray;
    rh:HRECORD;

    procedure Err;

    procedure _ChSet(var Item:TData; var Val:TData);
    function _ChGet(Var Item:TData; var Val:TData):boolean;
    function _ChCount:integer;

    function _DevGet(Var Item:TData; var Val:TData):boolean;
   protected
    WaveStream:PStream;
   public
    _prop_Device:integer;
    _prop_Freg:integer;
    _prop_Channels:integer;
    _prop_FileName:string;
    _prop_Stream:boolean;

    _data_Channels:THI_Event;
    _data_Freg:THI_Event;
    _data_Device:THI_Event;
    _data_FileName:THI_Event;

    _event_onError:THI_Event;
    _event_onStream:THI_Event;

    destructor Destroy; override;

    procedure _Write(buf:pointer; len:dword);

    procedure _work_doInit(var _Data:TData; Index:word);
    procedure _work_doFree(var _Data:TData; Index:word);
    procedure _work_doStart(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _var_Enabled(var _Data:TData; Index:word);
    procedure _var_Devices(var _Data:TData; Index:word);
  end;

implementation

destructor THIBASS_Record.Destroy;
begin
   if ChArr <> nil then dispose(ChArr);
   if DevArr <> nil then dispose(DevArr);   
   inherited; 
end;

procedure THIBASS_Record.Err;
begin
   if BASS_ErrorGetCode > 0 then
    _hi_OnEvent(_event_onError,integer(BASS_ErrorGetCode));
end;

procedure THIBASS_Record._work_doInit;
begin
  if not BASS_RecordInit(ReadInteger(_Data,_data_Device,_prop_Device)) then
   begin
     BASS_RecordFree;
     Err;
   end;
end;

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

procedure THIBASS_Record._work_doFree;
begin
   BASS_RecordFree;
  // _debug(int2str(sizeof(WAVHDR)));
end;

function RecordCallback(handle:HRECORD; Buffer: Pointer; Length, User: DWord): longBool; stdcall;
begin
  THIBASS_Record(User)._Write(Buffer,Length);
  Result := True;
end;

procedure THIBASS_Record._Write;
begin
   if _prop_Stream then
    begin
      WaveStream.Position := 0;
      WaveStream.Write(Buf^, Len);
      WaveStream.Position := 0;
      _hi_OnEvent(_event_onStream,WaveStream);
    end
   else WaveStream.Write(Buf^, Len);
end;

procedure THIBASS_Record._work_doStart;
var WaveHdr: WAVHDR;
    f,c:word;
    fn:string;
//    fl:cardinal;
begin
  //d := ReadInteger(_Data,_data_Device);
  f := ReadInteger(_Data,_data_Freg,_prop_Freg);
  c := ReadInteger(_Data,_data_Channels,_prop_Channels);
  fn := ReadString(_Data,_data_FileName,_prop_FileName);

    WaveHdr.riff := 'RIFF';
    WaveHdr.len := 36;
    WaveHdr.cWavFmt := 'WAVEfmt ';
    WaveHdr.dwHdrLen := 16;
    WaveHdr.wFormat := 1;
    WaveHdr.wNumChannels := c;
    WaveHdr.dwSampleRate := f;
    WaveHdr.wBlockAlign := 4;
    WaveHdr.dwBytesPerSec := 16*c*f div 8;
    WaveHdr.wBitsPerSample := 16;
    WaveHdr.cData := 'data';
    WaveHdr.dwDataLen := 0;
    if _prop_Stream then
      WaveStream := NewMemoryStream
    else
     begin
      WaveStream := NewReadWriteFileStream(fn);
      WaveStream.Write(WaveHdr, SizeOf(WAVHDR));
     end;
    {
    if c = 1 then
     fl := BASS_SAMPLE_MONO
    else fl := 0;
    }
    rh := BASS_RecordStart(f,c,0,@RecordCallback, cardinal(self));
    Err;

end;

procedure THIBASS_Record._work_doStop;
var i:integer;
begin
   //_debug(int2str(WaveStream.Size));
   if BASS_ChannelIsActive(rh) = 1 then
    begin
     BASS_ChannelStop(rh);

     if not _prop_Stream then
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

procedure THIBASS_Record._ChSet(var Item:TData; var Val:TData);
begin
  if ReadBool(Val) then
    BASS_RecordSetInput(ToIntIndex(Item), BASS_INPUT_ON)
    //_debug('ok')
  else BASS_RecordSetInput(ToIntIndex(Item), BASS_INPUT_OFF);
end;

function THIBASS_Record._ChGet(Var Item:TData; var Val:TData):boolean;
var n:integer;
begin
  n := ToIntIndex(Item);
  dtInteger(Val,integer(BASS_RecordGetInput(n) and BASS_INPUT_OFF = 0));
  Result := BASS_RecordGetInputName(n) <> nil;
end;

function THIBASS_Record._ChCount:integer;
begin
  Result := 0;
  while BASS_RecordGetInputName(Result) <> nil do
   inc(Result);
end;

function THIBASS_Record._DevGet(Var Item:TData; var Val:TData):boolean;
var n:PChar;
begin
  n := BASS_RecordGetInputName(ToIntIndex(Item));
  dtString(Val,n);
  Result := n <> nil;
end;

procedure THIBASS_Record._var_Enabled(var _Data:TData; Index:word);
begin
  if ChArr = nil then
   ChArr := CreateArray(_ChSet,_chGet,_ChCount,nil);
  dtArray(_data,ChArr);
end;

procedure THIBASS_Record._var_Devices(var _Data:TData; Index:word);
begin
  if DevArr = nil then
    DevArr := CreateArray(nil,_DevGet,_ChCount,nil);
  dtArray(_data,DevArr);
end;

end.
