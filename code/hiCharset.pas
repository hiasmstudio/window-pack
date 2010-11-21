unit hiCharset;

interface

uses Windows,Kol,Share,Debug;

const
   CP_THREAD_ACP =  3;           // current thread's ANSI code page
   CP_UTF8       =  65001;       // UTF-8 translation
   CP_KOI8       =  20866;       // KOI-8 translation
   CP_DOS        =  866;         // DOS   translation
   CP_WIN        =  1251;        // WIN   translation

type
  THICharset = class(TDebug)
   private
   public
    _prop_Type:byte;
    _prop_OutTypeUnicode:byte;
    _prop_InTypeUnicode:byte;
    
    _prop_CodePage1:integer;
    _prop_CodePage2:integer;    

    _data_Text:THI_Event;
    _data_CodePage1:THI_Event;
    _data_CodePage2:THI_Event;    
    _event_onCharset:THI_Event;

    procedure _work_doCharset0(var _Data:TData; Index:word);
    procedure _work_doCharset1(var _Data:TData; Index:word);
    procedure _work_doCharset2(var _Data:TData; Index:word);
    procedure _work_doCharset3(var _Data:TData; Index:word);
    procedure _work_doCharset4(var _Data:TData; Index:word);
    procedure _work_doCharset5(var _Data:TData; Index:word);
    procedure _work_doCharset6(var _Data:TData; Index:word);
    procedure _work_doCharset7(var _Data:TData; Index:word);    
    procedure _work_doCharset8(var _Data:TData; Index:word);
    procedure _work_doCharset9(var _Data:TData; Index:word);
    procedure _work_doCharset10(var _Data:TData; Index:word);    
    procedure _work_doCharset11(var _Data:TData; Index:word);
    procedure _work_doCharset12(var _Data:TData; Index:word);    
  end;

function Base64_Code(const s:string):string;
function Base64_Decode(const s:string):string;
function CodePage1ToCodePage2(const s: String; codePage1,codePage2: Word): String;
function URLEncode(const S: string): string;
function URLDecode(const S: string): string;
implementation

const base64ABC: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

function Base64_Code(const s:string):string; // standard MIME-Version: 1.0
var   rlen,len,i:cardinal;
      strIn:string;
begin
   Result := '';
   if s = '' then exit;
   rlen := Length(s);
   if rlen mod 3 = 1 then
      strIn := s + #0#0
   else if rlen mod 3 = 2 then
      strIn := s + #0
   else strIn := s;
   len := Length(strIn);
   i := 1;
   while i <= len-2 do begin
      Result := Result + base64ABC[byte(strIn[i]) shr 2 + 1] +
                         base64ABC[(byte(strIn[i]) and $03) shl 4 + byte(strIn[i+1]) shr 4 + 1] +
                         base64ABC[(byte(strIn[i+1]) and $0f) shl 2 + byte(strIn[i+2]) shr 6 + 1] +
                         base64ABC[(byte(strIn[i+2]) and $3f) + 1];
      inc(i,3);
   end;
   if rlen mod 3 = 1 then
      Result[length(result)-1] := '=';
   if rlen mod 3 > 0 then
      Result[length(result)] := '=';
end;

function Base64_DeCode(const s:string):string; // standard MIME-Version: 1.0
var   i,len:cardinal;
      strIn:string;

      function Index(c:char):byte;
      var   i:byte;
      begin
         Result := 0;
         if c = '=' then exit;
         for i := 1 to 64 do
            if base64ABC[i] = c then begin
               Result := i - 1;
               break;
            end;
      end;
      
begin
   Result := '';
   if (s = '') or (length(s) < 4) then exit;
   strIn := s;
   len := length(strIn);
   i := 1;
   while i <= len-3 do begin
      Result := Result + char(Index(strIn[i]) shl 2 + Index(strIn[i+1]) shr 4) +
                         char((Index(strIn[i+1]) and $0f) shl 4 + Index(strIn[i+2]) shr 2) +
                         char((Index(strIn[i+2]) and $03) shl 6 + Index(strIn[i+3]));
      inc(i,4);
   end;
   if strIn[len-1] = '=' then
      SetLength(Result,Length(Result)-2)
   else if strIn[len] = '=' then
      SetLength(Result,Length(Result)-1);
end;

function CodePage1ToCodePage2(const s: String; codePage1,codePage2: Word): String;
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

function URLEncode(const S: string): string;
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
    if ((S[i] >= '0') and (S[i] <= '9')) or
       ((S[i] >= 'A') and (S[i] <= 'Z')) or
       ((S[i] >= 'a') and (S[i] <= 'z')) or (S[i] = ' ') or
       (S[i] = '_') or (S[i] = '*') or (S[i] = '-') or (S[i] = '.') then
      len := len + 1
    else
      len := len + 3;
  SetLength(Result, len);
  idx := 1;
  for i := 1 to Length(S) do
    if S[i] = ' ' then
    begin
      Result[idx] := '+';
      idx := idx + 1;
    end
    else
      if ((S[i] >= '0') and (S[i] <= '9')) or
         ((S[i] >= 'A') and (S[i] <= 'Z')) or
         ((S[i] >= 'a') and (S[i] <= 'z')) or
         (S[i] = '_') or (S[i] = '*') or (S[i] = '-') or (S[i] = '.') then
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

procedure THICharset._work_doCharset0;
begin
   _hi_OnEvent(_event_onCharset,CodePage1ToCodePage2(ReadString(_Data,_data_Text,''),
               CP_DOS, CP_WIN));
end;

procedure THICharset._work_doCharset1;
begin
   _hi_OnEvent(_event_onCharset,CodePage1ToCodePage2(ReadString(_Data,_data_Text,''),
               CP_WIN, CP_DOS));
end;

procedure THICharset._work_doCharset2;
const en:string = 'qwertyuiop[]asdfghjkl;''zxcvbnm,./QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?';
      ru:string = 'ÈˆÛÍÂÌ„¯˘Áı˙Ù˚‚‡ÔÓÎ‰Ê˝ˇ˜ÒÏËÚ¸·˛.…÷” ≈Õ√ÿŸ«’⁄‘€¬¿œ–ŒÀƒ∆›ﬂ◊—Ã»“‹¡ﬁ,';
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

procedure THICharset._work_doCharset3;
begin
   _hi_OnEvent(_event_onCharset,CodePage1ToCodePage2(ReadString(_Data,_data_Text,''),
               CP_KOI8, CP_WIN));
end;

procedure THICharset._work_doCharset4;
begin
   _hi_OnEvent(_event_onCharset,Base64_DeCode(ReadString(_Data,_data_Text,'')));
end;

procedure THICharset._work_doCharset5;
begin
   _hi_OnEvent(_event_onCharset,Base64_Code(ReadString(_Data,_data_Text,'')));
end;

procedure THICharset._work_doCharset6;
begin
   _hi_OnEvent(_event_onCharset,CodePage1ToCodePage2(ReadString(_Data,_data_Text,''),
               CP_THREAD_ACP, CP_UTF8));
end;

procedure THICharset._work_doCharset7;
begin
   _hi_OnEvent(_event_onCharset,CodePage1ToCodePage2(ReadString(_Data,_data_Text,''),
               CP_UTF8, CP_THREAD_ACP));
end;

procedure THICharset._work_doCharset8;
begin
   _hi_OnEvent(_event_onCharset,CodePage1ToCodePage2(ReadString(_Data,_data_Text,''),
                ReadInteger(_Data, _data_CodePage1, _prop_CodePage1),
                ReadInteger(_Data, _data_CodePage2, _prop_CodePage2)));
end;

procedure THICharset._work_doCharset9;
var 
  BufLen: integer;
  res, s:string;
  i, j: integer;
  chr: Char;
  TypeUNICODE: byte;  
begin
  s := ReadString(_Data,_data_Text,'');
  TypeUNICODE := _prop_InTypeUNICODE;
  j := 1;
  if length(s) > 1 then 
    if ((s[1] = #255) and (s[2] = #254)) or ((s[1] = #254) and (s[2] = #255)) then  
    begin
      TypeUNICODE := ord(s[2]) and 1;
      j := 3;
    end;
  Res := '';
  BufLen := WideCharToMultiByte(CP_THREAD_ACP,WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR, @s[j], -1, nil, 0, nil, nil);;
  if BufLen > 1 then begin
    SetLength(Res, BufLen - 1);
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
    WideCharToMultiByte(CP_THREAD_ACP,WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR, @s[j], -1, @Res[1], BufLen, nil, nil);
  end;
  _hi_OnEvent(_event_onCharset, res);
end;

procedure THICharset._work_doCharset10;
var
  BufLen: integer;
  s, res: string;
  i: integer;
  chr: Char;
begin
  s := ReadString(_Data,_data_Text,'');
  res := '';              
  BufLen := MultiByteToWideChar(CP_THREAD_ACP, MB_PRECOMPOSED, @s[1], -1, nil, 0);
  if BufLen > 1 then
  begin
    SetLength(res, 2 * (BufLen - 1)); 
    MultiByteToWideChar(CP_THREAD_ACP, MB_PRECOMPOSED, @s[1], -1, @res[1], BufLen);
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

procedure THICharset._work_doCharset11;
begin
  _hi_OnEvent(_event_onCharset, URLDecode(ReadString(_Data,_data_Text,'')));
end;

procedure THICharset._work_doCharset12;
begin
  _hi_OnEvent(_event_onCharset, URLEncode(ReadString(_Data,_data_Text,'')));
end;

end.
