unit hiConvertorEx;

interface

uses Windows, Kol, Share, Debug;

type
  ThiConvertorEx = class(TDebug)
   private
     st:string;
     i: integer;
     r: real;
   public
    _prop_Mode:byte;
    _prop_Digits:integer;
    _prop_Width:integer;
    _prop_Decimals:integer;        
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
    procedure _work_doConvert11(var _Data:TData; Index:word);//IntToRom
    procedure _work_doConvert12(var _Data:TData; Index:word);//RomToInt
    procedure _work_doConvert13(var _Data:TData; Index:word);//StrToTri
    procedure _work_doConvert14(var _Data:TData; Index:word);//StrToWrd
    procedure _work_doConvert15(var _Data:TData; Index:word);//NumToFStr    
    procedure _work_doConvert16(var _Data:TData; Index:word);//VKeyToChar    
    procedure _var_Var(var _Data: TData; Index: word);
  end;
  
implementation

procedure ThiConvertorEx.Forward;
begin
  st := _prop_SymbolFill[1] + st;
end;

procedure ThiConvertorEx.Reverse;
begin
  st := st + _prop_SymbolFill[1];
end;

procedure ThiConvertorEx._work_doConvert0;//IntToStr
begin
   st:= int2str(ReadInteger(_Data,_data_Data,0));
   if _prop_SymbolFill <> '' then
      while Length( st ) < _prop_Digits do _prop_DirectFill(st);
   _hi_CreateEvent(_Data,@_event_onResult, st);
end;

procedure ThiConvertorEx._work_doConvert1;  //StrToInt
begin
  i:= str2int(ReadString(_Data,_data_Data));
  _hi_CreateEvent(_Data,@_event_onResult,i);
end;

procedure ThiConvertorEx._work_doConvert2;  //RealToInt
begin
  i:=integer(Round(ReadReal(_Data,_data_Data)));
  _hi_CreateEvent(_Data,@_event_onResult,i);
end;

procedure ThiConvertorEx._work_doConvert3;  //CharToInt
begin
  st:= ReadString(_Data,_data_Data);
  If st = '' then i := 0 else i := ord(st[1]);
  _hi_CreateEvent(_Data,@_event_onResult,i);
end;

procedure ThiConvertorEx._work_doConvert4;  //IntToChar
begin
  st:= chr(ReadInteger(_Data,_data_Data));
  _hi_CreateEvent(_Data,@_event_onResult,st);
end;

procedure ThiConvertorEx._work_doConvert5;  //HexToInt
begin
  i := Hex2Int(ReadString(_Data,_data_Data));
  _hi_CreateEvent(_Data,@_event_onResult,i);
end;

procedure ThiConvertorEx._work_doConvert6;  //IntToHex
begin
    st := Int2Hex(ReadInteger(_Data,_data_Data),_prop_Digits);
    _hi_CreateEvent(_Data,@_event_onResult,st);
end;

procedure ThiConvertorEx._work_doConvert7;  //BinToInt
 var ln:integer;
begin
  st := ReadString(_Data,_data_Data);
  i := 0;
  for ln := 1 to Length(st) do
    if not (st[ln] in ['0','1']) then break
    else i := i shl 1 + ord(st[ln]) - 48;
  _hi_CreateEvent(_Data,@_event_onResult,i);
end;

procedure ThiConvertorEx._work_doConvert8;  //IntToBin
var Value:cardinal;
    dig:integer;
begin
  st := '';
  dig := _prop_Digits;
  Value := ReadInteger(_Data,_data_Data);
  repeat 
    st := chr(Value and 1 + 48) + st;
    Value := Value shr 1;
    dec(dig);
  until (Value=0)and(dig<=0);
  _hi_CreateEvent(_Data,@_event_onResult,st);
end;

procedure ThiConvertorEx._work_doConvert9;  //RealToStr
begin
  st := Double2str(ReadReal(_Data,_data_Data));
  _hi_CreateEvent(_Data,@_event_onResult,st);
end;

procedure ThiConvertorEx._work_doConvert10; //StrToReal
begin
   r:= str2Double(ReadString(_Data,_data_Data));
   _hi_CreateEvent(_Data,@_event_onResult,r);
end;

procedure ThiConvertorEx._work_doConvert11; //IntToRom
const Romans: Array[1..13] of String =   ( 'I', 'IV', 'V', 'IX', 'X', 'XL', 'L', 'XC', 'C', 'CD', 'D', 'CM', 'M' );
      Arabics: Array[1..13] of Integer = ( 1, 4, 5, 9, 10, 40, 50, 90, 100, 400, 500, 900, 1000);
var i: Integer;
    Decimal: integer;
begin
    Decimal := ReadInteger(_Data,_data_Data);
    st := '';
    if Decimal <= 3999 then
       for i := 13 downto 1 do
          while ( Decimal >= Arabics[i] ) do begin
             Decimal := Decimal - Arabics[i];
             st := st + Romans[i];
          end;
    _hi_CreateEvent(_Data,@_event_onResult, st);
end;


procedure ThiConvertorEx._work_doConvert12; //RomToInt
const Romans: Array[1..25] of String =   ( 'I', 'IV', 'V', 'IX', 'X', 'XL', 'VL' ,'IL' ,'L', 'XC', 'VC', 'IC', 'C', 'CD', 'LD', 'XD', 'VD', 'ID', 'D', 'CM', 'LM', 'XM', 'VM', 'IM', 'M' );
      Arabics: Array[1..25] of Integer = ( 1, 4, 5, 9, 10, 40, 45, 49, 50, 90, 95, 99, 100, 400, 450, 490, 495, 499, 500, 900, 950, 990, 995, 999, 1000);
var l,p: Integer;
 begin
    st := ReadString(_Data,_data_Data);
    i := 0;
    l := 25;
    p := 1;
    while p <= Length(st) do begin
       while Copy(st, p, Length(Romans[l])) <> Romans[l] do begin
          Dec(l);
          if l = 0 then exit;
       end;
       i := i + Arabics[l];
       p := p + Length(Romans[l]);
    end; 
     _hi_CreateEvent(_Data,@_event_onResult,i);
end;

procedure ThiConvertorEx._work_doConvert13; //StrToTri
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
  st:=  m + str + f;
   _hi_CreateEvent(_Data,@_event_onResult,st);
END;
end;


procedure ThiConvertorEx._work_doConvert14; //StrToWrd
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
   st := str + s;
   _hi_CreateEvent(_Data, @_event_onResult,st);
END;
end;

procedure ThiConvertorEx._work_doConvert15; //NumToFStr
begin
  Str(ReadReal(_Data,_data_Data):_prop_Width:_prop_Decimals,st);
  _hi_CreateEvent(_Data, @_event_onResult,st);
end;

procedure ThiConvertorEx._work_doConvert16;//VKeyToChar
var
  Key: Word;
  keyboardState: TKeyboardState;
  asciiResult: Integer;
begin
  key := ReadInteger(_Data,_data_Data);
  GetKeyboardState(keyboardState) ;

  SetLength(st, 2);
  asciiResult := ToAscii(key, MapVirtualKey(key, 0), keyboardState, @st[1], 0);
  case asciiResult of
    1: SetLength(st, 1);
    2: ;
    else
      st := '';
  end;
  _hi_CreateEvent(_Data, @_event_onResult,st);
end;
   
procedure ThiConvertorEx._var_Var;
begin
  case _prop_Mode of
    0,4,6,8,9,11,13,14,15,16: dtString(_Data, st);
    1,2,3,5,7,12 : dtInteger(_Data, i);
    10: dtReal(_Data, r);
  end;  
end;
end.
