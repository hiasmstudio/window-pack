unit hiMultiBlockFind;

interface

uses Kol, Share, Debug;

const
  _ENTER    = #13#10; 

type
 THiMultiBlockFind = class(TDebug)
  private
    FListTag: PStrList;
    FCount: integer;    
    procedure SetTagList(Value: string);
    procedure SetCount(Value: integer);    
  public
    _data_Text,
    _event_onEnd: THI_Event;

    onResult: array of THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doMultiBlockFind(var _Data:TData; index:word);
    procedure _work_doTagList(var _Data:TData; index:word);    

    property _prop_TagList: string write SetTagList; 
    property _prop_Count: integer write SetCount; 
 end;

implementation

//--------------------------------------------------------------------------------

function PosABM(const SubStr, S: string; Offset: Integer = 1): Integer;
var
  lp, ls, i : integer;
  chr: Char;
  BMT: array[Char] of integer; 
begin
  ls := Length(S);
  lp := Length(SubStr);
  Result := Offset + lp - 1;
  chr := SubStr[1];
        
  if Length(SubStr) > 1 then
  begin
    for i := 0 to 255 do
      BMT[char(i)] := lp;    
    for i := 1 to (lp - 1) do
      BMT[SubStr[i]] := lp - i;

    while Result <= ls do
    begin
      if (SubStr[lp] = S[Result]) then
        for i := lp - 1 downto 1 do
          if (SubStr[i] <> S[Result - lp + i]) then
            Break
          else if i = 1 then
          begin
            Result := Result - lp + 1;
            Exit;
          end;
      Result := Result + BMT[S[Result]];
    end;              
  end  
  else
    while Result <= ls do
      if (chr <> S[Result]) then
        Result := Result + 1
      else 
        Exit;
  Result := 0;
end;

function Trim(Str: string): string;
var
  L: integer;
begin
  Result := Str;
  L := Length(Result);
  if Result[L] <> '\' then 
    while (L > 0) and (Result[L] <= ' ') do Dec(L)
  else
    Dec(L);
  SetLength(Result, L);
  L := 1;
  if Result[L] <> '\' then
    while (L <= Length(Result)) and (Str[L] <= ' ') do Inc(L)
  else
    Inc(L);
  Delete(Result, 1, L - 1);
end;

procedure Replace(var str: string; const substr, dest: string);
var
  p, r: integer;
  sb: string;
begin
  p := PosABM(substr, str);
  r := length(substr);
  while p > 0 do
  begin
    sb := CopyEnd(str, p + r);  
    SetLength(str, p - 1);
    str := str + dest + sb;
    p := p + Length(dest);
    p := PosABM(substr, str, p);
  end;
end;

procedure CutStr(var str: string; const substr: string);
var
  p, r: integer;
  sb: string;
begin
  p := PosABM(substr, str);
  r := length(substr);
  while p > 0 do
  begin
    sb := CopyEnd(str, p + r);  
    SetLength(str, p - 1);
    str := str + sb;
    p := PosABM(substr, str, p);
  end;
end;

//--------------------------------------------------------------------------------

procedure THiMultiBlockFind.SetCount;
begin
  SetLength(onResult, Value);
  FCount := Value;
end;

procedure THiMultiBlockFind.SetTagList;
var
  s: string;
  p, r: integer;
  sb: string;
begin
  s := Trim(Value);
  p := PosABM('{**c', s);
  r := PosABM('c**}', s, p + 4);
  while (p > 0) and (r > 0) do
  begin
    sb := CopyEnd(s, r + 4);  
    SetLength(s, p - 1);
    s := s + sb;
    p := PosABM('{**c', s, r + 4);
    r := PosABM('c**}', s, p + 4);
  end;
  CutStr(s, '{**s}');
  CutStr(s, _ENTER);
  Replace(s, '{**e}', _ENTER);
  FListTag.Text := s;
end;

constructor THiMultiBlockFind.Create;
begin
  inherited;
  FListTag := NewStrList;
end;

destructor THiMultiBlockFind.Destroy;
begin
  FListTag.free;
  inherited;
end;  

procedure THiMultiBlockFind._work_doMultiBlockFind;
var
  i: integer;

  Text: string;
  dt: TData;
  mt: PMT;
  initmt: boolean;  
  
  function findblock(text, tgch: string): boolean;
  var
    i, j: integer;
    res, startbl, endbl: string;
    include: boolean;
  begin
      i := PosABM('{**n}', tgch);
      if i <> 0 then
      begin
        endbl := Copy(tgch, 1, i - 1);
        Delete(tgch, 1, i + 4);
      end
      else
      begin
        endbl := tgch;
        tgch := '';
      end;  

      i := PosABM('{**x}', endbl);
      if i <> 0 then
      begin
        startbl := Copy(endbl, 1, i - 1);
        Delete(endbl, 1, i + 4);
      end
      else
      begin
        startbl := endbl;
        endbl := '';
      end;

      if endbl = '' then
      begin
        endbl := startbl;
        i := PosABM('{**i}', endbl);
        if i <> 0 then
        begin
          startbl := Copy(endbl, 1, i - 1);
          Delete(endbl, 1, i + 4);
        end
        else
        begin
          startbl := endbl;
          endbl := '';
        end;  
        include := true;        
      end
      else
        include := false;        

      startbl := trim(startbl);
      endbl := trim(endbl);

      i := PosABM(startbl, Text);
      j := 0;
      while i > 0 do
      begin
        j := PosABM(endbl, Text, i + Length(startbl));
        if j = 0 then break;
        
        res := Copy(Text, i + Length(startbl), j - i - Length(startbl));
        if include then
          res := startbl + res + endbl;

        if (tgch = '') and initmt then
        begin
          dtString(dt, res);
          mt := mt_make(dt);
          initmt := false;
        end
        else if (tgch = '') and not initmt then  
          mt_string(mt, res)
        else
          findblock(res, tgch);

        inc(j, Length(endbl));
        i := PosABM(startbl, Text, j);
      end;

      if j = 0 then
        Result := false
      else
        Result := true;        
  end;
  
begin
  if (FListTag.Count = 0) then exit;
  text := ReadString(_Data, _data_Text);
  if (text = '') then exit;
  dtNull(dt);
  
  for i := 0 to FListTag.Count - 1 do
  begin
    mt := nil;
    initmt := true;
    findblock(text, FListTag.Items[i]);
    if(i >= 0) and (i < FCount) then
      _hi_onEvent(onResult[i], dt);
    if Assigned(mt) then mt_free(mt);      
  end  
end;

procedure THiMultiBlockFind._work_doTagList;
begin
  _prop_TagList := ToString(_Data);
end;

end.