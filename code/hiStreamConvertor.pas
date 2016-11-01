unit hiStreamConvertor;

interface

uses
  Kol, Share, Debug;

type
  THIStreamConvertor = class(TDebug)
    private
      
    public
      _prop_Mode: Byte;
      _prop_Symbol: string;
      _data_Data: THI_Event;
      _event_onResult: THI_Event;

      function Str2ASCII(const S: string; const Repl: Char): string;
      procedure _work_doConvert0(var _Data: TData; Index: Word); //StreamToHex
      procedure _work_doConvert1(var _Data: TData; Index: Word); //HexToStream
      procedure _work_doConvert2(var _Data: TData; Index: Word); //StringToHex
      procedure _work_doConvert3(var _Data: TData; Index: Word); //HexToString
      procedure _work_doConvert4(var _Data: TData; Index: Word); //StreamToASCII
      procedure _work_doConvert5(var _Data: TData; Index: Word); //StrToASCII
      procedure _work_doConvert6(var _Data: TData; Index: Word); //StreamToStr
      procedure _work_doConvert7(var _Data: TData; Index: Word); //StrToStream
  end;
  
  
  
  
  function Str2Hex(const S: string): string;
  function Hex2Str(const S: string): string; // До первого не-HEX символа
  function Hex2Str2(const S: string): string; // Любые не-HEX символы пропускаются

  
  // Преобразовывает байты из Buffer в их двухсимвольное HEX-представление
  // и помещает результат в буфер Text. Размер буфера Text должен быть BufSize*2
  procedure Bin2Hex(Buffer, Text: PChar; BufSize: Integer);
  
  // Преобразовывает двухсимвольное HEX-представление байтов из Text
  // в их двоичное значение и помещает результат в Buffer.
  // BufSize должен быть не меньше Length(Text) div 2
  // Преобразование останавливается при обнаружении первого не-HEX символа в Text
  // Возвращает количество записанных в Buffer байт  
  function Hex2Bin(Text, Buffer: PChar; BufSize: Integer): Integer;
  
  
  // Аналогично Hex2Bin, но допускается наличие любых символов в Text
  //  - не-HEX символы будут пропущены.
  // Параметр TextSize указывает количество символов в Text
  // Размер Buffer должен быть не меньше TextSize div 2
  // Возвращает количество записанных в Buffer байт
  function Hex2Bin2(Text, Buffer: PChar; TextSize: Integer): Integer;
  
  

implementation

const
  HexChars: array[0..15] of Char = '0123456789ABCDEF';
  
  Convert: array['0'..'f'] of SmallInt =
    ( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,-1,-1,-1,-1,-1,-1,
     -1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     -1,10,11,12,13,14,15);

procedure Bin2Hex(Buffer, Text: PChar; BufSize: Integer);
var
  I: Integer;
begin
  for I := 0 to BufSize - 1 do
  begin
    Text[0] := HexChars[Byte(Buffer[I]) shr 4];
    Text[1] := HexChars[Byte(Buffer[I]) and $F];
    Inc(Text, 2);
  end;
end;

function Hex2Bin(Text, Buffer: PChar; BufSize: Integer): Integer;
var
  I: Integer;
begin
  I := BufSize;
  while I > 0 do
  begin
    // Быстрее, но символы между '9' и 'A', и 'F' и 'a' не считаются ошибочными
    //if not (Text[0] in ['0'..'f']) or not (Text[1] in ['0'..'f']) then Break;
    
    if not (Text[0] in ['0'..'9','A'..'F','a'..'f']) or
       not (Text[1] in ['0'..'9','A'..'F','a'..'f'])
    then
      Break;
      
    Buffer[0] := Char((Convert[Text[0]] shl 4) + Convert[Text[1]]);
    Inc(Buffer);
    Inc(Text, 2);
    Dec(I);
  end;
  Result := BufSize - I;
end;

function Hex2Bin2(Text, Buffer: PChar; TextSize: Integer): Integer;
var
  B: SmallInt;
  C: Char;
  FirstHalf: Boolean;
begin
  Result := 0;
  B := 0;
  FirstHalf := True;
  while TextSize > 0 do
  begin
    C := Text[0];
    if (C in ['0'..'9','a'..'f','A'..'F']) then
    begin
      if FirstHalf then
      begin
        B := Convert[C] shl 4;
        FirstHalf := False;
      end
      else
      begin
        B := B or Convert[C];
        FirstHalf := True;
        Buffer[0] := Char(B);
        Inc(Buffer);
        Inc(Result);
      end;
    end;
    Inc(Text);
    Dec(TextSize);
  end;
  // Последний непарный HEX-символ не будет учтен
end;

function Str2Hex(const S: string): string;
var
  Len: Integer;
begin
  Len := Length(S);
  SetLength(Result, Len*2);
  Bin2Hex(Pointer(S), Pointer(Result), Len);
end;

function Hex2Str(const S: string): string;
var
  L, LBuf: Integer;
begin
  L := Length(S);
  LBuf := L div 2;
  SetLength(Result, LBuf);
  L := Hex2Bin(Pointer(S), Pointer(Result), LBuf);
  if L <> LBuf then SetLength(Result, L);
end;

function Hex2Str2(const S: string): string;
var
  L, LBuf: Integer;
begin
  L := Length(S);
  LBuf := L div 2;
  SetLength(Result, LBuf);
  L := Hex2Bin2(Pointer(S), Pointer(Result), L);
  if L <> LBuf then SetLength(Result, L);
end;

function THIStreamConvertor.Str2ASCII(const S: string; const Repl: Char): string;
var
  I, Len, P: Integer;
begin
  I := 0;
  P := 0;
  Len := Length(S);
  SetLength(Result, Len);
  
  while P < len do
  begin
    Inc(P);
    Inc(I);
    if S[P] >= ' ' then Result[I] := S[P]
    else
      if Repl > #0 then Result[I] := Repl
      else Dec(I);
  end;
  
  SetLength(Result, I);
end;

procedure THIStreamConvertor._work_doConvert0(var _Data: TData; Index: Word); //StreamToHex
var
  S: string;
  St: PStream;
  Len: Integer;
begin
  St := ReadStream(_data, _data_Data);
  if St = nil then Exit;
  St.Position := 0;
  Len := St.Size;
  SetLength(S, Len);
  if Len > 0 then St.Read(S[1], Len);
  _hi_CreateEvent(_Data, @_event_onResult, Str2Hex(S));
end;

procedure THIStreamConvertor._work_doConvert1(var _Data: TData; Index: Word); //HexToStream
var
  S: string;
  St: PStream;
begin
  S := Hex2Str(ReadString(_Data, _data_Data));
  St := NewMemoryStream;
  St.Write(S[1], Length(S));
  St.Position := 0;
  _hi_OnEvent(_event_onResult, St);
  St.free;
end;

procedure THIStreamConvertor._work_doConvert2(var _Data: TData; Index: Word); //StringToHex
begin
  _hi_CreateEvent(_Data, @_event_onResult, Str2Hex(ReadString(_Data, _data_Data)));
end;

procedure THIStreamConvertor._work_doConvert3(var _Data: TData; Index: Word); //HexToString
begin
  _hi_OnEvent(_event_onResult, Hex2Str(ReadString(_Data, _data_Data)));
end;

procedure THIStreamConvertor._work_doConvert4(var _Data: TData; Index: Word); //StreamToASCII
var
  S: string;
  St: PStream;
  len: integer;
begin
  St := ReadStream(_data,_data_Data);
  if St = nil then Exit;
  len := St.Size;
  St.Position := 0;
  SetLength(S, len);
  if len > 0 then St.Read(S[1], len);
  _hi_CreateEvent(_Data, @_event_onResult, Str2ASCII(S, (_prop_Symbol+#0)[1]));
end;

procedure THIStreamConvertor._work_doConvert5(var _Data: TData; Index: Word); //StrToASCII
begin
  _hi_CreateEvent(_Data, @_event_onResult, Str2ASCII(ReadString(_Data, _data_Data), (_prop_Symbol+#0)[1]));
end;

procedure THIStreamConvertor._work_doConvert6(var _Data: TData; Index: Word); //StreamToStr
var
  S: string;
  St:PStream;
  len: cardinal;
begin
  St := ReadStream(_data, _data_Data);
  if St = nil then Exit;
  St.Position := 0;
  len := St.Size;
  SetLength(S, len);
  if len > 0 then St.Read(S[1], len);
  _hi_CreateEvent(_Data, @_event_onResult, S);
end;

procedure THIStreamConvertor._work_doConvert7(var _Data: TData; Index: Word); //StrToStream
var
  S: string;
  St: PStream;
  len: cardinal;
begin
  S := ReadString(_Data, _data_Data);
  St := NewMemoryStream;
  len := Length(S);
  if len > 0 then St.Write(s[1], len);
  St.Position := 0;
  _hi_OnEvent(_event_onResult, St);
  St.free;
end;

end.
