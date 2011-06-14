unit hiMultiReplace;

interface

uses Windows, Kol, Share, Debug;

type
 THiMultiReplace = class(TDebug)
  private
    FMultiReplace: string;
    _Dlm, _End: Char;
    procedure SetDelimiter(Value: string);
    procedure SetEndSymbol(Value: string);
  public
    _prop_ReplaceList: string;    
    _prop_EnterTag: string;

    _data_Text,
    _data_ReplaceList,
    _event_onResult: THI_Event;

    property _prop_Delimiter: string write SetDelimiter;
    property _prop_EndSymbol: string write SetEndSymbol;
        
    procedure _work_doMultiReplace(var _Data:TData; index:word);
    procedure _work_doDelimiter(var _Data:TData; index:word);
    procedure _work_doEndSymbol(var _Data:TData; index:word);
    procedure _work_doEnterTag(var _Data:TData; index:word);             
    procedure _var_Result(var _Data:TData; index:word);
 end;

implementation

uses hiStr_Enum;

function Trim(const Str : string): string;
var
  L: integer;
begin
  Result := Str;
  L := Length(Result);
  while (L > 0) and (Result[L] = ' ') do Dec(L);
  SetLength(Result, L);
  L := 1;
  while (L <= Length(Result)) and (Result[L] = ' ') do Inc(L);
  Result := string(PChar(integer(@Result[1]) + L - 1)); 
end;

procedure Replace(var str: string; const substr, dest: string);
var
  p, r: integer;
  sb: string;
begin
  p := PosEx(substr, str);
  r := length(substr);
  while p > 0 do
  begin
    sb := CopyEnd(str, p + r);  
    SetLength(str, p - 1);
    str := str + dest + sb;
    p := p + Length(dest);
    p := PosEx(substr, str, p);
  end;
end;

procedure THiMultiReplace._work_doMultiReplace;
var
  i: integer;
  s: string;
  FListFrom: PStrList;
  FListTo: PStrList;    
begin
  FMultiReplace := ReadString(_Data, _data_Text);
  s := ReadString(_Data, _data_ReplaceList, _prop_ReplaceList);

  Replace(s, _End + #13#10, _End);
  Replace(s, #13#10, _prop_EnterTag);  
  
  FListFrom := NewStrList;
  FListTo := NewStrList;
    
  while s <> '' do
  begin
    FListFrom.Add(trim(fparse(s, _Dlm)));
    FListTo.Add(trim(fparse(s, _End)));
  end;

  for i := 0 to FListFrom.count - 1 do
    Replace(FMultiReplace, FListFrom.Items[i], FListTo.Items[i]);
  Replace(FMultiReplace, _prop_EnterTag, #13#10); 
  
  FListFrom.free;
  FListTo.free;

  _hi_onEvent(_event_onResult, FMultiReplace);
 
end;

procedure THiMultiReplace._var_Result;
begin
  dtString(_Data, FMultiReplace);
end;

procedure THiMultiReplace._work_doEnterTag;
begin
  _prop_EnterTag := ToString(_Data);
end;

procedure THiMultiReplace._work_doDelimiter;
begin
  SetDelimiter(ToString(_Data));
end;

procedure THiMultiReplace._work_doEndSymbol;
begin
  SetEndSymbol(ToString(_Data));
end;

procedure THiMultiReplace.SetDelimiter;
begin
  _Dlm := (Value + #0)[1];
end;

procedure THiMultiReplace.SetEndSymbol;
begin
  _End := (Value + #0)[1];
end;

end.