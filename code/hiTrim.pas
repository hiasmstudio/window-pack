unit hiTrim;

interface

uses Kol,Share,Debug;

type
  THITrim = class(TDebug)
   private
    FRes: string;
   public
    _prop_Char: string;
    _prop_Mode: byte;

    _data_Text: THI_Event;
    _event_onTrim: THI_Event;

    procedure _work_doTrim0(var _Data:TData; Index:word);  // TrimBoth
    procedure _work_doTrim1(var _Data:TData; Index:word);  // TrimLeft
    procedure _work_doTrim2(var _Data:TData; Index:word);  // TrimRight
    procedure _work_doTrim3(var _Data:TData; Index:word);  // TrimStrBoth
    procedure _work_doTrim4(var _Data:TData; Index:word);  // TrimStrLeft
    procedure _work_doTrim5(var _Data:TData; Index:word);  // TrimStrRight
    procedure _work_doTrim6(var _Data:TData; Index:word);  // NormalCenter
    procedure _work_doTrim7(var _Data:TData; Index:word);  // NormalText            
    
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

procedure THITrim._work_doTrim0; // TrimBoth
var
  L: Integer;
  ch: char;
begin
  FRes := ReadString(_Data,_data_Text,'');
  if _prop_Char = '' then ch := ' ' else ch := _prop_Char[1];
  L := Length(FRes);
  while (L > 0) and (FRes[L] = ch) do Dec(L);
  SetLength(Fres, L);
  L := 1;
  while (L <= Length(FRes)) and (FRes[L] = ch) do Inc(L);
  FRes := string(PChar(integer(@FRes[1]) + L - 1)); 
  _hi_CreateEvent(_Data, @_event_onTrim, Fres);  
end;


procedure THITrim._work_doTrim1;  // TrimLeft
var
  ch: char;
  L: integer;
begin
  FRes := ReadString(_Data, _data_Text, '');
  if _prop_Char = '' then ch := ' ' else ch := _prop_Char[1];
  L := 1;
  while (L <= Length(FRes)) and (FRes[L] = ch) do Inc(L);
  FRes := string(PChar(integer(@FRes[1]) + L - 1)); 
  _hi_CreateEvent(_Data, @_event_onTrim, Fres);
end;

procedure THITrim._work_doTrim2; // TrimRight
var
  L: Integer;
  ch: char;
begin
  FRes := ReadString(_Data,_data_Text,'');
  if _prop_Char = '' then ch := ' ' else ch := _prop_Char[1];
  L := Length(FRes);
  while (L > 0) and (FRes[L] = ch) do Dec(L);
  SetLength(Fres, L);
  _hi_CreateEvent(_Data, @_event_onTrim, Fres);
end;

procedure THITrim._work_doTrim3; // TrimStrBoth
var
  L, LS: Integer;
begin
  FRes := ReadString(_Data,_data_Text,'');
  if _prop_Char <> '' then
  begin
    L := Length(FRes);
    LS := Length(_prop_Char);
    while (L >= LS) do
     if CopyTail(FRes, LS) = _prop_Char then
     begin
       Dec(L, LS);
       SetLength(Fres, L);
     end
     else
       break;

    L := 1;
    while (L <= Length(FRes) - LS + 1) do
     if Copy(FRes, 1, LS) = _prop_Char then
     begin    
       Delete(FRes, 1, LS);
       Inc(L, LS);
     end
     else
       break;
  end;
  _hi_CreateEvent(_Data, @_event_onTrim, Fres);  
end;


procedure THITrim._work_doTrim4;  // TrimStrLeft
var
  L, LS: integer;
begin
  FRes := ReadString(_Data, _data_Text, '');
  if _prop_Char <> '' then
  begin
    LS := Length(_prop_Char);
    L := 1;
    while (L <= Length(FRes) - LS + 1) do
     if Copy(FRes, 1, LS) = _prop_Char then
     begin    
       Delete(FRes, 1, LS);
       Inc(L, LS);
     end
     else
       break;
  end;
  _hi_CreateEvent(_Data, @_event_onTrim, Fres);
end;

procedure THITrim._work_doTrim5; // TrimStrRight
var
  L, LS: Integer;
begin
  FRes := ReadString(_Data,_data_Text,'');
  if _prop_Char <> '' then
  begin
    L := Length(FRes);
    LS := Length(_prop_Char);
    while (L >= LS) do
     if CopyTail(FRes, LS) = _prop_Char then
     begin
       Dec(L, LS);
       SetLength(Fres, L);
     end
     else
       break;    
  end;
  _hi_CreateEvent(_Data, @_event_onTrim, Fres);
end;

procedure THITrim._work_doTrim6; // NormalCenter
var
  I, L, K: Integer;
  ch: char;
begin
  FRes := ReadString(_Data,_data_Text,'');
  if _prop_Char = '' then ch := ' ' else ch := _prop_Char[1];
  L := Length(FRes);
  K := 0;

  for I := L downto 1 do
  begin
    if FRes[I] = ch then
      K := K + 1 
    else 
      if K > 0 then 
      begin 
        Delete(FRes, I + 1, K - 1);  
        K := 0;                  
      end; 
  end;     
  _hi_CreateEvent(_Data, @_event_onTrim, Fres);  
end;

procedure THITrim._work_doTrim7; // NormalText
var
  I, L, K: Integer;
begin
  FRes := ReadString(_Data,_data_Text,'');
  FRes := Trim(FRes);
  L := Length(FRes);
  K := 0;

  for I := L downto 1 do
  begin
    if FRes[I] = ' ' then
      K := K + 1 
    else 
      if K > 0 then 
      begin 
        Delete(FRes, I + 1, K - 1);  
        K := 0;                  
      end; 
  end;     
  _hi_CreateEvent(_Data, @_event_onTrim, Fres);  
end;

procedure THITrim._var_Result;
begin
  dtString(_Data, FRes);
end;

end.