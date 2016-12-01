unit hiCharset;

interface

uses Windows,Kol,Share,Debug;

const
   CP_UTF8       =  65001;       // UTF-8 translation
   CP_KOI8       =  20866;       // KOI-8 translation
   CP_DOS        =  866;         // DOS   translation
   CP_WIN        =  1251;        // WIN   translation

type
  THICharset = class(TDebug)
    private
    
    public
      _prop_Type: Byte;
      _prop_OutTypeUnicode: Byte;
      _prop_InTypeUnicode: Byte;
      _prop_URLMode: Byte;
      
      _prop_CodePage1: Integer;
      _prop_CodePage2: Integer;    

      _data_Text: THI_Event;
      _data_CodePage1: THI_Event;
      _data_CodePage2: THI_Event;    
      
      _event_onCharset: THI_Event;
      _event_onError: THI_Event;

      procedure _work_doCharset0(var _Data: TData; Index: Word); // DOS_WIN
      procedure _work_doCharset1(var _Data: TData; Index: Word); // WIN_DOS
      procedure _work_doCharset2(var _Data: TData; Index: Word); // EN_RU
      procedure _work_doCharset3(var _Data: TData; Index: Word); // KOI8_WIN
      procedure _work_doCharset4(var _Data: TData; Index: Word); // BASE64_WIN
      procedure _work_doCharset5(var _Data: TData; Index: Word); // WIN_BASE64
      procedure _work_doCharset6(var _Data: TData; Index: Word); // ANSI_UTF8
      procedure _work_doCharset7(var _Data: TData; Index: Word); // UTF8_ANSI
      procedure _work_doCharset8(var _Data: TData; Index: Word); // CP1_CP2
      procedure _work_doCharset9(var _Data: TData; Index: Word); // UNICODE_ANSI
      procedure _work_doCharset10(var _Data: TData; Index: Word); // ANSI_UNICODE
      procedure _work_doCharset11(var _Data: TData; Index: Word); // URL_ANSI
      procedure _work_doCharset12(var _Data: TData; Index: Word); // ANSI_URL
  end;

// Преобразовывает строку в Base64
function Base64_Code(const S: string): string;

// Преобразовывает строку из Base64 в оригинальный вид
// Если исходная строка непустая, а результат - пустая,
// значит, ошибка декодирования 
function Base64_Decode(const S: string): string;

// Функция возвращает размер выходного буфера
// для заданного размера входного буфера при кодировании в Base64 
function TextSizeForBase64Enc(const DataSize: Integer): Integer;

// Функция возвращает размер выходного буфера
// для заданного размера входного буфера при декодировании в Base64
// Возвращает 0, если размер входного буфера некратный 4 или равен 0
function BufSizeForBase64Dec(const TextSize: Integer): Integer;

// Преобразование в Base64 данных в буфере Buffer
// и занесение результата в буфер Text.
// Возвращает количество данных, записанных в Text.
// Размер Text должен быть не меньше (BufSize * 4) div 3 
function BinToBase64(Buffer, Text: PChar; BufSize: Integer): Integer;

// Преобразование в оригинальный вид из Base64 
// данных в буфере Text и занесение результата в буфер Buffer.
// Возвращает количество данных, записанных в Buffer, или 0,
// если TextSize некратный 4 или недопустимый символ в Text.
// Размер Buffer не меньше (TextSize div 4) * 3 
// TextSize должно быть кратно 4
function Base64ToBin(Text, Buffer: PChar; TextSize: Integer): Integer;



function CodePage1ToCodePage2(const S: string; codePage1, codePage2: Word): string;
function URLEncode(const S: string; URLMode: Byte): string;
function URLDecode(const S: string): string;



implementation



// ====================================================== //
//  Реализация кодирования/декодирования данных в Base64  //
//                 Автор: Netspirit                       //
//             Редакция от 01.12.2016                     //
// ====================================================== //
  
const  
  // Алфавит Base64
  Base64Chars: array [0..63] of Char = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';  

var
  // Таблица индексов для декодирования Base64
  Base64Indexes: array [0..255] of Byte;

function TextSizeForBase64Enc(const DataSize: Integer): Integer;
begin
  Result := DataSize div 3;
  if Result * 3 <> DataSize then Inc(Result);
  Result := Result * 4;
end;

function BufSizeForBase64Dec(const TextSize: Integer): Integer;
begin
  if TextSize mod 4 <> 0 then
    Result := 0
  else
    Result := TextSize div 4 * 3;
end;

// Процедура заполняет таблицу индексов для декодера Base64
// В Base64Indexes по смещению (Буква) содержится индекс
// этой (Буквы) в алфавите Base64Chars.
// Символы, не входящие в алфавит Base64 при заполнении будут иметь индекс 255.
// Ищется индекс входящего символа по таблице, символ не входящий в алфавит
// имеет индекс 255 и считается ошибочным

procedure FillBase64DecodeTable;
var
  I: Integer;
begin
  FillChar(Base64Indexes[0], Length(Base64Indexes), 255);
  for I := 0 to High(Base64Chars) do
    Base64Indexes[Byte(Base64Chars[I])] := I;
end;

function BinToBase64(Buffer, Text: PChar; BufSize: Integer): Integer;
var
  I: Integer;
  B: Integer;
  L: Integer;
begin
  Result := 0;
  I := 0;
  L := (BufSize div 3) * 3;
  while I < L do
  begin
    B := (Byte(Buffer[0]) shl 16) or (Byte(Buffer[1]) shl 8) or (Byte(Buffer[2]));
    
    Text[Result] := Base64Chars[(B shr 18) and 63];
    Text[Result + 1] := Base64Chars[(B shr 12) and 63];
    Text[Result + 2] := Base64Chars[(B shr 6) and 63];
    Text[Result + 3] := Base64Chars[B and 63];
    
    Inc(Result, 4);
    Inc(Buffer, 3);
    Inc(I, 3);
  end;
  
  //=====================================================================//
  // Исходные данные нужно дополнить 0-ми до кратных 3-ом                //
  // Результирующие данные нужно дополнить символом "=" до кратных 4-ом  //
  //=====================================================================//

  I := BufSize mod 3;
  if I <> 0 then
  begin
    B := Byte(Buffer[0]) shl 16; // I = 1 или 2. B = $00xx0000
    if I = 2 then B := B or (Byte(Buffer[1]) shl 8); // I = 2 - так должно быть! B = $00xxyy00
    
    // I = 1 или 2:
    Text[Result] := Base64Chars[(B shr 18) and 63];
    Text[Result + 1] := Base64Chars[(B shr 12) and 63];
    
    if I = 2 then
    begin   
      Text[Result + 2] := Base64Chars[(B shr 6) and 63];
    end
    else
      Text[Result + 2] := '=';
      
    Text[Result + 3] := '=';
    
    // При I = 1 Text[0..3] = 'AB=='
    // При I = 2 Text[0..3] = 'ABC='
    
    
    Inc(Result, 4);
  end;
end;

function Base64ToBin(Text, Buffer: PChar; TextSize: Integer): Integer;
var
  I: Integer;
  B0, B1, B2, B3: Byte;
  L: Integer;
begin
  Result := 0;
  if (TextSize = 0) or (TextSize mod 4 <> 0) then exit;
  I := 0;
  L := TextSize - 4;
  while I < L do
  begin
    B0 := Base64Indexes[Byte(Text[I])];
    B1 := Base64Indexes[Byte(Text[I + 1])];
    B2 := Base64Indexes[Byte(Text[I + 2])]; 
    B3 := Base64Indexes[Byte(Text[I + 3])];
    
    if (B0 = 255) or (B1 = 255) or (B2 = 255) or (B3 = 255) // Недопустимый символ
    then 
    begin
      Result := 0;
      exit;
    end;
    
    Buffer[0] := Char((B0 shl 2) or (B1 shr 4));
    Buffer[1] := Char((B1 shl 4) or (B2 shr 2));
    Buffer[2] := Char((B2 shl 6) or (B3));
    
    Inc(Buffer, 3);
    Inc(Result, 3);
    Inc(I, 4);
  end;
  
  //=============================================================//
  // Если исходные данные оканчиваются на 1-2 символа "=",       //
  // в результирующие данные не добавляется последние 1-2 байта  //
  //=============================================================//
  
  B0 := Base64Indexes[Byte(Text[I])];
  B1 := Base64Indexes[Byte(Text[I + 1])];
  
  if (B0 = 255) or (B1 = 255) // Недопустимый символ
  then 
  begin
    Result := 0;
    exit;
  end;
  
  Buffer[0] := Char((B0 shl 2) or (B1 shr 4));
  Inc(Result);
  
  if Text[I + 2] <> '=' then
  begin 
    B2 := Base64Indexes[Byte(Text[I + 2])];
    if (B2 = 255) // Недопустимый символ
    then 
    begin
      Result := 0;
      exit;
    end;
    Buffer[1] := Char((B1 shl 4) or (B2 shr 2));
    Inc(Result);
    
    if Text[I + 3] <> '=' then
    begin
      B3 := Base64Indexes[Byte(Text[I + 3])];
      if (B3 = 255) // Недопустимый символ
      then 
      begin
        Result := 0;
        exit;
      end;
      Buffer[2] := Char((B2 shl 6) or (B3));
      Inc(Result);
    end;
  end;
end;

// Преобразовывает строку в Base64
function Base64_Code(const S: string): string;
var
  L: Integer;
begin
  L := Length(S);
  if L = 0 then exit;
  
  SetLength(Result, TextSizeForBase64Enc(L));
  BinToBase64(Pointer(S), Pointer(Result), L);
end;

// Преобразовывает строку из Base64 в оригинальный вид
// Если исходная строка непустая, а результат - пустая,
// значит, ошибка декодирования 
function Base64_Decode(const S: string): string;
var
  L, C: Integer;
begin
  L := Length(S);
  C := BufSizeForBase64Dec(L); // Исходная строка должна быть кратной 4
  if C = 0 then exit;
  
  // Чтобы избежать лишней подгонки размера строки,
  // заранее определяем точный размер результата
  if S[L-1] = '=' then Dec(C, 2)
  else if S[L] = '=' then Dec(C);
  
  SetLength(Result, C);
  L := Base64ToBin(Pointer(S), Pointer(Result), L);
  if L <> C then SetLength(Result, L); // После предыдущей подгонки L <> C только в случае ошибки (L = 0)
end;

// ====================================================== //

function CodePage1ToCodePage2(const S: string; codePage1, codePage2: Word): string;
var   buffer: PWideChar;
      BufLen: integer;
begin
   Result := '';
   BufLen := MultiByteToWideChar(CodePage1, 0, @s[1], -1, nil, 0);
   if BufLen < 1 then exit;
   GetMem(buffer, 2*BufLen);
   MultiByteToWideChar(CodePage1, 0, @s[1], -1, buffer, BufLen);
   BufLen := WideCharToMultiByte(CodePage2,0,buffer,-1,nil,0,nil,nil);
   if BufLen > 1 then begin
      SetLength(Result,BufLen-1);
      WideCharToMultiByte(CodePage2,0,buffer,-1,@Result[1],BufLen,nil,nil);
   end;
   FreeMem(buffer);
end;

function URLEncode(const S: string; URLMode: byte): string;
var
  i, idx, len: Integer;

  function DigitToHex(Digit: Integer): Char;
  begin
    case Digit of
      0..9: Result := Chr(Digit + Ord('0'));
      10..15: Result := Chr(Digit - 10 + Ord('A'));
    else
      Result := '0';
    end;
  end; // DigitToHex

begin
  len := 0;
  for i := 1 to Length(S) do
    if (((S[i] >= '0') and (S[i] <= '9')) or
       ((S[i] >= 'A') and (S[i] <= 'Z')) or
       ((S[i] >= 'a') and (S[i] <= 'z')) or (S[i] = ' ') or
       (S[i] = '_') or (S[i] = '*') or (S[i] = '-') or (S[i] = '.')) and
       (URLMode = 0) then
      len := len + 1
    else
      len := len + 3;
  SetLength(Result, len);
  idx := 1;
  for i := 1 to Length(S) do
    if (S[i] = ' ') and (URLMode = 0) then
    begin
      Result[idx] := '+';
      idx := idx + 1;
    end
    else
      if (((S[i] >= '0') and (S[i] <= '9')) or
         ((S[i] >= 'A') and (S[i] <= 'Z')) or
         ((S[i] >= 'a') and (S[i] <= 'z')) or
         (S[i] = '_') or (S[i] = '*') or (S[i] = '-') or (S[i] = '.')) and
         (URLMode = 0) then
      begin
        Result[idx] := S[i];
        idx := idx + 1;
      end
      else
      begin
        Result[idx] := '%';
        Result[idx + 1] := DigitToHex(Ord(S[i]) div 16);
        Result[idx + 2] := DigitToHex(Ord(S[i]) mod 16);
        idx := idx + 3;
      end;
end; // URLEncode

function URLDecode(const S: string): string;
var
  i, idx, len, n_coded: Integer;

  function WebHexToInt(HexChar: Char): Integer;
  begin
    if HexChar < '0' then
      Result := Ord(HexChar) + 256 - Ord('0')
    else
      if HexChar <= Chr(Ord('A') - 1) then
        Result := Ord(HexChar) - Ord('0')
      else
        if HexChar <= Chr(Ord('a') - 1) then
          Result := Ord(HexChar) - Ord('A') + 10
        else
          Result := Ord(HexChar) - Ord('a') + 10;
  end;

begin
  len := 0;
  n_coded := 0;
  for i := 1 to Length(S) do
  if n_coded >= 1 then
  begin
    n_coded := n_coded + 1;
    if n_coded >= 3 then
    n_coded := 0;
  end
  else
  begin
    len := len + 1;
    if S[i] = '%' then
      n_coded := 1;
  end;
  SetLength(Result, len);
  idx := 0;
  n_coded := 0;
  for i := 1 to Length(S) do
  if n_coded >= 1 then
  begin
    n_coded := n_coded + 1;
    if n_coded >= 3 then
    begin
      Result[idx] := Chr((WebHexToInt(S[i - 1]) * 16 +
      WebHexToInt(S[i])) mod 256);
      n_coded := 0;
    end;
  end
  else
  begin
    idx := idx + 1;
    if S[i] = '%' then
      n_coded := 1;
    if S[i] = '+' then
      Result[idx] := ' '
    else
      Result[idx] := S[i];
  end;
end; // URLDecode

procedure THICharset._work_doCharset0; // DOS_WIN
begin
   _hi_OnEvent(_event_onCharset,CodePage1ToCodePage2(ReadString(_Data,_data_Text,''),
               CP_DOS, CP_WIN));
end;

procedure THICharset._work_doCharset1; // WIN_DOS
begin
   _hi_OnEvent(_event_onCharset,CodePage1ToCodePage2(ReadString(_Data,_data_Text,''),
               CP_WIN, CP_DOS));
end;

procedure THICharset._work_doCharset2; // EN_RU
const en:string = 'qwertyuiop[]asdfghjkl;''zxcvbnm,./QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?';
      ru:string = 'йцукенгшщзхъфывапролджэячсмитьбю.ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,';
var i,p:cardinal;
    Result:string;
begin
   Result := ReadString(_Data,_data_Text,'');
   if Result <> '' then
    for i := 1 to Length(Result) do
     begin
        p := pos(Result[i],en);
        if p > 0 then
         Result[i] := ru[p];
     end;
   _hi_OnEvent(_event_onCharset,Result);
end;

procedure THICharset._work_doCharset3; // KOI8_WIN
begin
   _hi_OnEvent(_event_onCharset,CodePage1ToCodePage2(ReadString(_Data,_data_Text,''),
               CP_KOI8, CP_WIN));
end;

procedure THICharset._work_doCharset4; // BASE64_WIN
var
  S1, S2: string;
begin
  S1 := ReadString(_Data, _data_Text, '');
  S2 := Base64_Decode(S1);
  if (S1 <> '') and (S2 = '') then
    _hi_CreateEvent(_Data, @_event_onError)
  else
    _hi_CreateEvent(_Data, @_event_onCharset, S2);
end;

procedure THICharset._work_doCharset5; // WIN_BASE64
begin
  _hi_CreateEvent(_Data, @_event_onCharset, Base64_Code(ReadString(_Data, _data_Text, '')));
end;

procedure THICharset._work_doCharset6; // ANSI_UTF8
begin
   _hi_OnEvent(_event_onCharset,CodePage1ToCodePage2(ReadString(_Data,_data_Text,''),
               CP_ACP, CP_UTF8));
end;

procedure THICharset._work_doCharset7; // UTF8_ANSI
begin
   _hi_OnEvent(_event_onCharset,CodePage1ToCodePage2(ReadString(_Data,_data_Text,''),
               CP_UTF8, CP_ACP));
end;

procedure THICharset._work_doCharset8; // CP1_CP2
begin
   _hi_OnEvent(_event_onCharset,CodePage1ToCodePage2(ReadString(_Data,_data_Text,''),
                ReadInteger(_Data, _data_CodePage1, _prop_CodePage1),
                ReadInteger(_Data, _data_CodePage2, _prop_CodePage2)));
end;

procedure THICharset._work_doCharset9; // UNICODE_ANSI
var 
  BufLen: integer;
  res, s:string;
  i, j: integer;
  chr: Char;
  TypeUNICODE: byte;
begin
  s := ReadString(_Data,_data_Text,'') + #0#0;
  res := '';

  TypeUNICODE := _prop_InTypeUNICODE;
  j := 1;
  if length(s) > 1 then 
    if ((s[1] = #255) and (s[2] = #254)) or ((s[1] = #254) and (s[2] = #255)) then  
    begin
      TypeUNICODE := ord(s[2]) and 1;
      j := 3;
    end;
  Res := '';

  BufLen := WideCharToMultiByte(CP_ACP, WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR, @s[j], -1, nil, 0, nil, nil);
  if BufLen > 1 then
  begin
    case TypeUNICODE of
      1: begin
           i := 1;
           while i < Length(s) do
           begin
             chr := s[i];
             s[i] := s[i + 1];
             s[i + 1] := chr;
             i := i + 2;
           end;  
         end;
    end;
    Setlength(Res, BufLen);
    BufLen := WideCharToMultiByte(CP_ACP, WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR, @s[j], -1, @Res[1], BufLen, nil, nil);
    Setlength(Res, BufLen - 1);
  end;
  _hi_OnEvent(_event_onCharset, res);
end;

procedure THICharset._work_doCharset10; // ANSI_UNICODE
var
  BufLen: integer;
  s, res: string;
  i: integer;
  chr: Char;
begin
  s := ReadString(_Data,_data_Text,'');
  res := '';              
  BufLen := MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, @s[1], -1, nil, 0);
  if BufLen > 1 then
  begin
    SetLength(res, 2 * (BufLen - 1)); 
    MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, @s[1], -1, @res[1], BufLen);
    case _prop_OutTypeUnicode of
      1,3: begin
             i := 1;
             while i < Length(res) do
             begin
               chr := res[i];
               res[i] := res[i + 1];
               res[i + 1] := chr;
               i := i + 2;
             end;  
           end;
    end;
    case _prop_OutTypeUnicode of
      2: res := #255#254 + res; 
      3: res := #254#255 + res;
    end;
  end;       
  _hi_OnEvent(_event_onCharset, res); 
end;

procedure THICharset._work_doCharset11; // URL_ANSI
begin
  _hi_OnEvent(_event_onCharset, URLDecode(ReadString(_Data,_data_Text,'')));
end;

procedure THICharset._work_doCharset12; // ANSI_URL
begin
  _hi_OnEvent(_event_onCharset, URLEncode(ReadString(_Data,_data_Text,''), _prop_URLMode));
end;

initialization
  FillBase64DecodeTable;

end.
