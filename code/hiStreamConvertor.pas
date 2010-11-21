unit hiStreamConvertor;

interface

uses Kol,Share,Debug;

type
  THIStreamConvertor = class(TDebug)
   private
    FPos,Check:Integer;
    function Str2Hex  (const S:String): String;
    function Hex2Str  (const S:String): String;
    function Str2ASCII(const S:String; const Repl:Char): String;
   public
    _prop_Mode:Byte;
    _prop_Symbol:String;
    _data_Data:THI_Event;
    _event_onResult:THI_Event;

    procedure _work_doConvert0(var _Data:TData; Index:word);//StreamToHex
    procedure _work_doConvert1(var _Data:TData; Index:word);//HexToStream
    procedure _work_doConvert2(var _Data:TData; Index:word);//StringToHex
    procedure _work_doConvert3(var _Data:TData; Index:word);//HexToString
    procedure _work_doConvert4(var _Data:TData; Index:word);//StreamToASCII
    procedure _work_doConvert5(var _Data:TData; Index:word);//StrToASCII
    procedure _work_doConvert6(var _Data:TData; Index:word);//StreamToStr
    procedure _work_doConvert7(var _Data:TData; Index:word);//StrToStream
    procedure _var_Position(var _Data:TData; Index:word);   //Current coding position
    procedure _var_CheckSum(var _Data:TData; Index:word);   //Sum of all bytes 
  end;

implementation

function Byte2hex(D:char):word;
asm
  mov  AH,AL
  and  AL,0Fh
  add  AL,90h
  daa
  adc  AL,40h
  daa
  xchg AL,AH
  shr  AL,4
  add  AL,90h
  daa
  adc  AL,40h
  daa
end;

function THIStreamConvertor.Str2Hex;
var len: Integer;
begin
  FPos := 0;
  Check := 0;
  len := Length(S);
  SetLength(Result,len*2);
  while FPos<len do begin
    inc(FPos);
    Check := Check + ord(S[FPos]);
    word(pointer(@Result[2*FPos - 1])^) := Byte2hex(S[FPos]);
  end;
end;

function THIStreamConvertor.Hex2Str;
const Convert: array['0'..'f'] of byte =
   (0, 1, 2, 3, 4, 5, 6, 7, 8, 9,16,16,16,16,16,16,
   16,10,11,12,13,14,15,16,16,16,16,16,16,16,16,16,
   16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
   16,10,11,12,13,14,15);
var len: Integer; ch:char;
begin
  FPos := 0;
  Check := 0;
  len := Length(S);
  SetLength(Result, len div 2);
  if len < 2 then Exit; {Too small}
  repeat
    ch := S[2*FPos+1];
    if (not(ch in['0'..'f']))or(Convert[ch]>15) then break;
    Result[FPos+1] := Chr((Convert[ch] shl 4));
    ch := S[2*FPos+2];
    if (not(ch in['0'..'f']))or(Convert[ch]>15) then break;
    inc(FPos);
    Result[FPos] := Chr(ord(Result[FPos])+Convert[ch]);
    Check := Check + ord(Result[FPos]);
  until false;
  SetLength(Result, FPos);
end;

function THIStreamConvertor.Str2ASCII;
var i,len: Integer;
begin
  i := 0;
  FPos := 0;
  len := Length(S);
  SetLength(Result,len);
  while FPos<len do begin
    inc(FPos);
    inc(i);
    if S[FPos]>=' ' then Result[i] := S[FPos]
    else if Repl>#0 then Result[i] := Repl
    else dec(i)
  end;
  SetLength(Result,i);
end;

procedure THIStreamConvertor._work_doConvert0(var _Data:TData; Index:word);//StreamToHex
var S: String;
    St: PStream;
    len: integer;
begin
  St := ReadStream(_data,_data_Data);
  if St = nil then Exit;
  St.Position := 0;
  len := St.Size;
  SetLength(S,len);
  if len > 0 then St.Read(S[1],len);
  _hi_CreateEvent(_Data,@_event_onResult,Str2Hex(S));
end;

procedure THIStreamConvertor._work_doConvert1(var _Data:TData; Index:word);//HexToStream
var S: String;
    St: PStream;
begin
  S := Hex2Str(ReadString(_Data,_data_Data));
  St := NewMemoryStream;
  St.Write(S[1],Length(S));
  St.Position := 0;
  _hi_OnEvent(_event_onResult,St);
  St.free;
end;

procedure THIStreamConvertor._work_doConvert2(var _Data:TData; Index:word);//StringToHex
begin
  _hi_CreateEvent(_Data,@_event_onResult,Str2Hex(ReadString(_Data,_data_Data)));
end;

procedure THIStreamConvertor._work_doConvert3(var _Data:TData; Index:word);//HexToString
begin
  _hi_OnEvent(_event_onResult,Hex2Str(ReadString(_Data,_data_Data)));
end;

procedure THIStreamConvertor._work_doConvert4(var _Data:TData; Index:word);//StreamToASCII
var S: String;
    St: PStream;
    len: integer;
begin
  St := ReadStream(_data,_data_Data);
  if St = nil then Exit;
  len := St.Size;
  St.Position := 0;
  SetLength(S,len);
  if len > 0 then St.Read(S[1],len);
  _hi_CreateEvent(_Data,@_event_onResult,Str2ASCII(S,(_prop_Symbol+#0)[1]));
end;

procedure THIStreamConvertor._work_doConvert5(var _Data:TData; Index:word);//StrToASCII
begin
  _hi_CreateEvent(_Data,@_event_onResult,Str2ASCII(ReadString(_Data,_data_Data),(_prop_Symbol+#0)[1]));
end;

procedure THIStreamConvertor._work_doConvert6(var _Data:TData; Index:word);//StreamToStr
var S:string;
    St:PStream;
    len:cardinal;
begin
  St := ReadStream(_data,_data_Data);
  if St = nil then Exit;
  St.Position := 0;
  len := St.Size;
  SetLength(S,len);
  if len > 0 then St.Read(S[1],len);
  _hi_CreateEvent(_Data,@_event_onResult,S);
end;

procedure THIStreamConvertor._work_doConvert7(var _Data:TData; Index:word);//StrToStream
var S:string;
    St:PStream;
    len:cardinal;
begin
  S := ReadString(_Data,_data_Data);
  St := NewMemoryStream;
  len := Length(S);
  if len > 0 then St.Write(s[1],len);
  St.Position := 0;
  _hi_OnEvent(_event_onResult,St);
  St.free;
end;

procedure THIStreamConvertor._var_Position;
begin
   dtInteger(_data,FPos);
end;

procedure THIStreamConvertor._var_CheckSum;
begin
   dtInteger(_data,Check);
end;

end.
