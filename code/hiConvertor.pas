unit hiConvertor;  { компонент Convertor ver 1.20 }

interface

uses Kol,Share,Debug;

type
  THIConvertor = class(TDebug)
   private
   public
    _prop_Mode:byte;
    _prop_Digits:integer;
    _prop_SymbolFill:string;
    _prop_DirectFill: procedure (var st: string) of object;
    _prop_Word_1:string;
    _prop_Word_2:string;
    _prop_Word_5:string;        
    _data_Data:THI_Event;
    _event_onResult:THI_Event;
    
    procedure Forward(var st: string);
    procedure Reverse(var st: string);
    
    procedure _work_doConvert0(var _Data:TData; Index:word);//IntToStr
    procedure _work_doConvert1(var _Data:TData; Index:word);//StrToInt
    procedure _work_doConvert2(var _Data:TData; Index:word);//RealToInt
    procedure _work_doConvert3(var _Data:TData; Index:word);//CharToInt
    procedure _work_doConvert4(var _Data:TData; Index:word);//IntToChar
    procedure _work_doConvert5(var _Data:TData; Index:word);//HexToInt
    procedure _work_doConvert6(var _Data:TData; Index:word);//IntToHex
    procedure _work_doConvert7(var _Data:TData; Index:word);//BinToInt
    procedure _work_doConvert8(var _Data:TData; Index:word);//IntToBin
    procedure _work_doConvert9(var _Data:TData; Index:word);//RealToStr
    procedure _work_doConvert10(var _Data:TData; Index:word);//StrToReal
    procedure _work_doConvert11(var _Data:TData; Index:word);//StreamToStr
    procedure _work_doConvert12(var _Data:TData; Index:word);//StrToStream
    procedure _work_doConvert13(var _Data:TData; Index:word);//IntToRom
    procedure _work_doConvert14(var _Data:TData; Index:word);//RomToInt
    procedure _work_doConvert15(var _Data:TData; Index:word);//StrToTri
    procedure _work_doConvert16(var _Data:TData; Index:word);//StrToWrd
  end;

function Hex2Int(st:string):integer;

implementation

procedure THIConvertor._work_doConvert0(var _Data:TData; Index:word);//IntToStr
var st : string;
begin
   st:= int2str(ReadInteger(_Data,_data_Data,0));
   if _prop_SymbolFill <> '' then
      while Length( st ) < _prop_Digits do _prop_DirectFill(st);
  _hi_CreateEvent(_Data,@_event_onResult, st);
end;

procedure THIConvertor.Forward;
begin
  st := _prop_SymbolFill[1] + st;
end;

procedure THIConvertor.Reverse;
begin
  st := st + _prop_SymbolFill[1];
end;

procedure THIConvertor._work_doConvert1(var _Data:TData; Index:word);//StrToInt
begin
  _hi_CreateEvent(_Data,@_event_onResult,str2int(ReadString(_Data,_data_Data)));
end;

procedure THIConvertor._work_doConvert2(var _Data:TData; Index:word);//RealToInt
begin
  _hi_CreateEvent(_Data,@_event_onResult,integer(Round(ReadReal(_Data,_data_Data))));
end;

procedure THIConvertor._work_doConvert3(var _Data:TData; Index:word);//CharToInt
var s:string;
    b:integer;
begin
  s := ReadString(_Data,_data_Data);
  if s = '' then b := 0
  else b := ord(s[1]);
  _hi_CreateEvent(_Data,@_event_onResult,b);
end;

procedure THIConvertor._work_doConvert4(var _Data:TData; Index:word);//IntToChar
begin
  _hi_CreateEvent(_Data,@_event_onResult,chr(ReadInteger(_Data,_data_Data)));
end;

function Hex2Int(st:string):integer;
var i,ln:integer;
begin
   st := LowerCase(st);
   Result := 0;
   ln := Length(st);
   for i := 1 to ln do
     case st[i] of
      '0'..'9': Result := Result shl 4 + ord(st[i]) - 48;
      'a'..'f': Result := Result shl 4 + ord(st[i]) - 87;
      else break;
     end;
end;

procedure THIConvertor._work_doConvert5(var _Data:TData; Index:word);//HexToInt
begin
  _hi_CreateEvent(_Data,@_event_onResult,Hex2Int(ReadString(_Data,_data_Data)));
end;

procedure THIConvertor._work_doConvert6(var _Data:TData; Index:word);//IntToHex
begin
  _hi_CreateEvent(_Data,@_event_onResult,Int2Hex(ReadInteger(_Data,_data_Data),_prop_Digits));
end;

procedure THIConvertor._work_doConvert7(var _Data:TData; Index:word);//BinToInt
var i,bin,ln:integer;
    st:string;
begin
  st := ReadString(_Data,_data_Data);
  bin := 0;
  ln := Length(st);
  for i := 1 to ln do
    if not (st[i] in ['0','1']) then break
    else bin := bin shl 1 + ord(st[i]) - 48;
  _hi_CreateEvent(_Data,@_event_onResult,bin);
end;

procedure THIConvertor._work_doConvert8(var _Data:TData; Index:word);//IntToBin
var Value:cardinal;
    dig:integer;
    s:string;
begin
  s := '';
  dig := _prop_Digits;
  Value := ReadInteger(_Data,_data_Data);
  repeat 
    s := chr(Value and 1 + 48) + s;
    Value := Value shr 1;
    dec(dig);
  until (Value=0)and(dig<=0);
  _hi_CreateEvent(_Data,@_event_onResult,s);
end;

procedure THIConvertor._work_doConvert9(var _Data:TData; Index:word);//RealToStr
begin
  _hi_CreateEvent(_Data,@_event_onResult,Double2str(ReadReal(_Data,_data_Data)));
end;

procedure THIConvertor._work_doConvert10(var _Data:TData; Index:word);//StrToReal
begin
  _hi_CreateEvent(_Data,@_event_onResult,str2Double(ReadString(_Data,_data_Data)));
end;

procedure THIConvertor._work_doConvert11(var _Data:TData; Index:word);//StreamToStr
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

procedure THIConvertor._work_doConvert12(var _Data:TData; Index:word);//StrToStream
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

procedure THIConvertor._work_doConvert13(var _Data:TData; Index:word);//IntToRom (Standard Algorithm -- Input <= 3999)
const Romans: Array[1..13] of String =   ( 'I', 'IV', 'V', 'IX', 'X', 'XL', 'L', 'XC', 'C', 'CD', 'D', 'CM', 'M' );
      Arabics: Array[1..13] of Integer = ( 1, 4, 5, 9, 10, 40, 50, 90, 100, 400, 500, 900, 1000);
var i: Integer;
    str: String;
    Decimal: integer;
begin
    Decimal := ReadInteger(_Data,_data_Data);
    str := '';
    if Decimal <= 3999 then
       for i := 13 downto 1 do
          while ( Decimal >= Arabics[i] ) do begin
             Decimal := Decimal - Arabics[i];
             str := str + Romans[i];
          end;
    _hi_CreateEvent(_Data,@_event_onResult, str);
end;

procedure THIConvertor._work_doConvert14(var _Data:TData; Index:word);//RomToInt (Extended Algorithm)
const Romans: Array[1..25] of String =   ( 'I', 'IV', 'V', 'IX', 'X', 'XL', 'VL' ,'IL' ,'L', 'XC', 'VC', 'IC', 'C', 'CD', 'LD', 'XD', 'VD', 'ID', 'D', 'CM', 'LM', 'XM', 'VM', 'IM', 'M' );
      Arabics: Array[1..25] of Integer = ( 1, 4, 5, 9, 10, 40, 45, 49, 50, 90, 95, 99, 100, 400, 450, 490, 495, 499, 500, 900, 950, 990, 995, 999, 1000);
var i,p: Integer;
    str: String;
    Decimal: integer;
begin
    str := ReadString(_Data,_data_Data);
    Decimal := 0;
    i := 25;
    p := 1;
    while p <= Length(str) do begin
       while Copy(str, p, Length(Romans[i])) <> Romans[i] do begin
          Dec(i);
          if i = 0 then exit;
       end;
       Decimal := Decimal + Arabics[i];
       p := p + Length(Romans[i]);
    end;
    _hi_CreateEvent(_Data,@_event_onResult, Decimal);
end;

procedure THIConvertor._work_doConvert15(var _Data:TData; Index:word);//StrToTri
var   i: Integer;
      m,f,s,str:string;
begin
   str := ReadString(_Data,_data_Data);
   Replace(str, ' ','');
   m := '';
   f := '';
TRY
   if str = '' then exit;
   if (str[1] = '-') then begin
      Delete(str,1,1);
      if (str = '') then exit
      else m := '- ';
   end; 
   s := str;
   for i:=1 to Length(s) do
      if s[i] = '.' then begin
         str := GetTok(s,'.');
         f := '.' + s;
         break;
      end;
   i := Length(str) - 2;
   while i >= 2 do begin
      if (str[1] = '-') and (i < 3) then break; 
      Insert(' ', str, i);
      Dec(i,3);
   end;
FINALLY
   _hi_CreateEvent(_Data,@_event_onResult, m + str + f);
END;
end;

procedure THIConvertor._work_doConvert16(var _Data:TData; Index:word);//StrToWrd
var   j,l:integer;
      f,s,str:string;
begin
   str := ReadString(_Data,_data_Data);
TRY
   if str = '' then exit;
   if (str[1] = '-') then begin
      if (str[2] <> ' ') then Insert(' ',str,2);
   end; 
   s := str;
   f := ' ';
   for j:=0 to Length(s) do 
      if s[j] = '.' then begin
         str := GetTok(s,'.');
         f := '.' + s + ' ';
         break;
      end;   

   l:=Length(str);
   if f <> ' ' then
      s := f + _prop_Word_2      
   else if (str[l-1] = '1') then // for 10..19
      s := f + _prop_Word_5
   else
     case str[l] of
          '1': s := f + _prop_Word_1;
     '2'..'4': s := f + _prop_Word_2
         else  s := f + _prop_Word_5; 
     end;
FINALLY
   _hi_CreateEvent(_Data, @_event_onResult, str + s);
END;
end;

end.