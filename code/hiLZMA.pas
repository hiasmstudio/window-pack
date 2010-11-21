unit hiLZMA;

interface

uses Kol,Share,KOLwlfLZMA,Debug;

type
  THILZMA = class(TDebug)
   private
    DSize: Integer;
    Position: Integer;
    Original: Integer;
    Encoder:TLZMAEncoder;
    Decoder:TLZMADecoder;
    function EncPrepare(Dict,FastBytes,FProgressInterval: Integer):Boolean;
    procedure _OnProgress(const Action:TLZMAProgressAction;const Value:int64);
    procedure _OnProgressEv(const Action:TLZMAProgressAction;const Value:int64);
   public
    _prop_DictionarySize:Integer;
    _prop_NumFastBytes:Integer;
    _prop_MatchFinder:Integer;
    _prop_Lc:Integer;
    _prop_Lp:Integer;
    _prop_Pb:Integer;
    _prop_EndMarker:Boolean;
    _prop_ProgressInterval:Integer;
    _data_DictionarySize:THI_Event;
    _data_ProgressInterval:THI_Event;
    _data_NumFastBytes:THI_Event;
    _data_Stream:THI_Event;
    _event_onStream:THI_Event;
    _event_onProgress:THI_Event;
    _event_onProgressMax:THI_Event;
    _event_onError:THI_Event;

    procedure _work_doCompress(var _Data:TData; Index:word);
    procedure _work_doDeCompress(var _Data:TData; Index:word);
    procedure _var_DestSize(var _Data:TData; Index:word);
    procedure _var_Position(var _Data:TData; Index:word);
    procedure _var_OriginalSize(var _Data:TData; Index:word);
  end;

implementation

function THILZMA.EncPrepare;
begin
  result := false;
  KOLwlfLZMA.CodeProgressInterval := FProgressInterval;
  Encoder := TLZMAEncoder.Create;
  if not (Encoder.SetAlgorithm(2)) or
     not (Encoder.SetDictionarySize(1 shl Dict)) or
     not (Encoder.SeNumFastBytes(FastBytes)) or
     not (Encoder.SetMatchFinder(_prop_MatchFinder)) or
     not (Encoder.SetLcLpPb(_prop_Lc, _prop_Lp, _prop_Pb)) then
      begin
        _hi_OnEvent(_event_onError,0); //Unable to set encoding properties
        Exit;
      end;
  Encoder.SetEndMarkerMode(_prop_EndMarker);
  if (Assigned(_event_onProgress.Event)) or (Assigned(_event_onProgressMax.Event)) then
    Encoder.OnProgress := _OnProgressEv else
      Encoder.OnProgress := _OnProgress;
  result := true;
end;

procedure THILZMA._OnProgress;
begin
  if Action = LPAMax then
    Original := Value
  else
    Position := Value;
end;

procedure THILZMA._OnProgressEv;
begin
  if Action = LPAMax then
     begin
       Original := Value;
       _hi_OnEvent(_event_onProgressMax,Integer(Value));
     end
   else
     begin
       Position := Value;
       _hi_OnEvent(_event_onProgress,Integer(Value));
     end;
end;

procedure THILZMA._work_doCompress;
var  st,dest: PStream;
     i,Dictionary,NumFastBytes: Integer;
     strmsize: int64;
begin
   DSize := 0;
   Position := 0;
   Original := 0;
   st := ReadStream(_data,_data_Stream,nil);
   if st <> nil then
    begin
     st.Position := 0;
     Dictionary := ReadInteger(_data,_data_DictionarySize,_prop_DictionarySize);
     if Dictionary < 0 then Dictionary := 0 else
     if Dictionary > 28 then Dictionary := 28;
     NumFastBytes := ReadInteger(_data,_data_NumFastBytes,_prop_NumFastBytes);
     if NumFastBytes < 5 then NumFastBytes := 5 else
     if NumFastBytes > 273 then NumFastBytes := 273;
     if EncPrepare(Dictionary, NumFastBytes, ReadInteger(_Data, _data_ProgressInterval, _prop_ProgressInterval)) then
      begin
       dest := NewMemoryStream;
       Encoder.WriteCoderProperties(dest);
       if _prop_EndMarker then strmsize := -1
          else strmsize := st.Size;
       for i := 0 to 7 do
         WriteByte(dest,(strmsize shr (8 * i)) and $FF);
       Encoder.Code(st, dest, -1, -1);
       dest.Position := 0;
       DSize := dest.Size;
       _hi_OnEvent(_event_onStream,dest);
       dest.Free;
      end;
     Encoder.free;
    end;
end;

procedure THILZMA._work_doDeCompress;
var   st,dest: PStream;
      properties: array[0..4] of byte;
      outSize: int64;
      v: Byte;
      i: Integer;
const propertiessize = 5; 
begin
  DSize := 0;
  Position := 0;
  Original := 0;
  st := ReadStream(_data,_data_Stream,nil);
  if st <> nil then
   begin
    st.Position := 0;
    if st.Read(properties, propertiesSize) <> propertiesSize then
     begin
      _hi_OnEvent(_event_onError, 1); //Input stream is too short
      Exit;
     end;
    KOLwlfLZMA.CodeProgressInterval := ReadInteger(_Data, _data_ProgressInterval, _prop_ProgressInterval);
    Decoder := TLZMADecoder.Create;
    if Decoder.SetDecoderProperties(properties) then
      begin
       if (Assigned(_event_onProgress.Event)) or (Assigned(_event_onProgressMax.Event)) then
         Decoder.OnProgress := _OnProgressEv else
           Decoder.OnProgress := _OnProgress;
       outSize := 0;
       for i := 0 to 7 do 
         begin
           v := ReadByte(st);
//           if v >= 0 then
            outSize := outSize or v shl (8 * i);
         end;
       dest := NewMemoryStream;
       if Decoder.Code(st, dest, outSize) then
        begin
         dest.Position := 0;
         DSize := dest.Size;
         _hi_OnEvent(_event_onStream,dest);
        end
         else
          _hi_OnEvent(_event_onError,2); //Error in data stream
       dest.Free;
      end
       else
        _hi_OnEvent(_event_onError,3); //Incorrect stream properties
    Decoder.free;
   end; 
end;

procedure THILZMA._var_DestSize;
begin
   dtInteger(_data,DSize);
end;

procedure THILZMA._var_Position;
begin
   dtInteger(_data,Position);
end;

procedure THILZMA._var_OriginalSize;
begin
   dtInteger(_data,Original);
end;

end.
