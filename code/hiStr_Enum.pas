unit hiStr_Enum;
 
interface

uses Kol, Share, Debug;

type
  THIStr_Enum = class(TDebug)
  private
    FStop: boolean;
    eIndex: integer;
    FFrom: integer;
    FTo:   integer;
    FStep: integer;
    FNum: integer;
    FDivG: boolean;
    Dlm: string;
    st: string;
  public
    _prop_onBreakEnable: boolean;
    _prop_Direct: byte;
       
    _data_String: THI_Event;
    _event_onEnum: THI_Event;
    _event_onEndEnum: THI_Event;
    _event_onBreak: THI_Event;

    property _prop_From: integer write FFrom;
    property _prop_To: integer write FTo;
    property _prop_Step: integer write FStep;
    property _prop_Delimiter: string write Dlm;
    property _prop_OnlyDivGroup: boolean write FDivG;
    procedure _work_doEnum0(var _Data: TData; Index: Word); //Forward
    procedure _work_doEnum1(var _Data: TData; Index: Word); //Reverse
    procedure _work_doStop(var _Data: TData; Index: Word);
    procedure _work_doFrom(var _Data: TData; Index: Word);
    procedure _work_doTo(var _Data: TData; Index: Word);
    procedure _work_doDelimiter(var _Data: TData; Index: Word);
    procedure _work_doStep(var _Data: TData; Index: Word);
    procedure _work_doOnlyDivGroup(var _Data: TData; Index: Word);         
                    
    procedure _var_NumSubStr(var _Data: TData; Index: Word);
    procedure _var_Part(var _Data: TData; Index: Word);    
  end;

function FParse(var S: string; const Delimiters: char): string;
function RParse(var S: string; const Delimiters: char): string;

implementation

//[function StrScan]
function StrScan(Str: PChar; Chr: Char): PChar; assembler;
asm
        PUSH    EDI
        PUSH    EAX
        MOV     EDI,Str
        OR      ECX, -1
        XOR     AL,AL
        REPNE   SCASB
        NOT     ECX
        POP     EDI
        XCHG    EAX, EDX
        REPNE   SCASB

        XCHG    EAX, EDI
        POP     EDI

        JE      @@1
        MOV     EAX,1
@@1:    DEC     EAX
end {$IFDEF F_P} [ 'EAX', 'EDX', 'ECX' ] {$ENDIF};

//[function StrRScan]
function StrRScan(const Str: PChar; Chr: Char): PChar; assembler;
asm
        PUSH    EDI
        MOV     EDI,Str
        MOV     ECX,0FFFFFFFFH
        XOR     AL,AL
        REPNE   SCASB
        NOT     ECX
        STD
        DEC     EDI
        MOV     AL,Chr
        REPNE   SCASB
        MOV     EAX,0
        JNE     @@1
        MOV     EAX,EDI
        INC     EAX
@@1:    CLD
        POP     EDI
end {$IFDEF F_P} [ 'EAX', 'EDX', 'ECX' ] {$ENDIF};

//---------------- Функция обратного парсирования строки ----------------------- 

function RParse(var S: string; const Delimiters: char): string;
var
  Pos: integer;
  P, F: PChar;
begin
  P := PChar(S);
  F := StrRScan(P, Delimiters);
  if F <> nil then
    Pos := Integer(F) - Integer(P)
  else
    Pos := -1;    
  Result := S;
  S := Copy(Result, 1, Pos);
  Result := CopyEnd(Result, Pos + 2);
end;

//------------------------------------------------------------------------------
//
//------------ Исправленная функция прямого парсирования строки ----------------
function FParse(var S: string; const Delimiters: char): string;
var
  Pos: Integer;
  P, F: PChar;
begin
  P := PChar(S);
  F := StrScan(P, Delimiters);
  if F <> nil then
    Pos := Integer(F) - Integer(P) + 1
  else
    Pos := Length(S) + 1;    
  Result := S;
  S := CopyEnd(Result, Pos + 1);
  Result := Copy(Result, 1, Pos - 1);
end;

//------------------------------------------------------------------------------

procedure THIStr_Enum._work_doEnum0;
var
  s, ss: string;
  i: integer;
begin
  s := ReadString(_Data, _data_String, '');
  FStop := false;
  eIndex := FFrom;

  if (Dlm = '') and (s <> '') and (eIndex > 0) then // выдаем группами символов,
  begin
    if FStep = 1 then
    repeat
      st := s[eIndex];
      _hi_onEvent(_event_onEnum, st);
      if (FStop) or (eIndex = FTo) then break;
      inc(eIndex);
    until eIndex > Length(s)
    else
    begin
      if FTo = -1 then
        ss := Copy(s, (FFrom - 1) * FStep + 1, Length(s) - (FFrom - 1) * FStep)
      else      
        ss := Copy(s, (FFrom - 1) * FStep + 1, (FTo - FFrom + 1) * FStep); 
      eIndex := 1;
      FNum := FFrom;
      repeat
        st := Copy(ss, eIndex, FStep);
        if FDivG and (Length(st) <> FStep) then
        begin
          st := '';
          break;
        end 
        else
          _hi_onEvent(_event_onEnum, st);
        if FStop then break;
        inc(eIndex, FStep);
        inc(FNum);
      until eIndex > Length(ss);
    end;
  end  
  else if (Dlm <> '') and (s <> '') then            // иначе, разбиваем по разделителю
  begin
    i := 1;
    while (s <> '') and (i < eIndex) do
    begin
      fparse(s, Dlm[1]);
      inc(i);
    end;
    if s <> '' then 
      repeat
        st := fparse(s, Dlm[1]); 
        _hi_onEvent(_event_onEnum, st);
        if (FStop) or (eIndex = FTo) then break;
        inc(eIndex);
      until s = '';
  end;  
  if FStop and _prop_onBreakEnable then
    _hi_CreateEvent(_Data,@_event_onBreak, st)
  else
    _hi_CreateEvent(_Data,@_event_onEndEnum);
end;

procedure THIStr_Enum._work_doEnum1;
var
  s: string;
  i: integer;
begin
  s := ReadString(_Data, _data_String, '');
  FStop := false;
  eIndex := FFrom;

  if (Dlm = '') and (s <> '') and (eIndex > 0)then // выдаем группами символов,
  begin
    if FStep = 1 then
    repeat
      st := s[Length(s) + 1 - eIndex];
      _hi_onEvent(_event_onEnum, st);
      if (FStop) or (eIndex = FTo) then break;
      inc(eIndex);
    until eIndex  > Length(s) 
    else
    begin
      if FTo = -1 then
        DeleteTail(s, (FFrom - 1) * FStep)
      else      
      begin
        DeleteTail(s, (FFrom - 1) * FStep);
        s := Copy(s, Length(s) - (FTo - FFrom + 1) * FStep + 1, (FTo - FFrom + 1) * FStep);
      end;  
      eIndex := 1;
      FNum := FFrom;        
    repeat      
      if (Length(s) + 2 - eIndex - FStep) < 1 then
        st := Copy(s, 1, Length(s) - eIndex + 1)
      else         
        st := Copy(s, Length(s) + 2 - eIndex - FStep, FStep);
      if FDivG and (Length(st) <> FStep) then
      begin
        st := '';
        break;
      end 
      else
        _hi_onEvent(_event_onEnum, st);
      if FStop then break;
      inc(eIndex, FStep);
      inc(FNum);
    until eIndex  > Length(s);
    end;
  end
  else if (Dlm <> '') and (s <> '') then           // иначе, разбиваем по разделителю
  begin
    i := 1;
    while (s <> '') and (i < eIndex) do
    begin
      rparse(s, Dlm[1]);
      inc(i);
    end; ; 
    repeat
      st := rparse(s, Dlm[1]);
      _hi_onEvent(_event_onEnum, st);
      if (FStop) or (eIndex = FTo) then break;
      inc(eIndex);
    until s = '';
  end;  
  if FStop and _prop_onBreakEnable then
    _hi_CreateEvent(_Data,@_event_onBreak, st)
  else
    _hi_CreateEvent(_Data,@_event_onEndEnum);
end;

procedure THIStr_Enum._work_doStop;
begin
  FStop := true;
end;

procedure THIStr_Enum._work_doFrom;
begin
  FFrom := ToInteger(_Data);
end;

procedure THIStr_Enum._work_doTo;
begin
  FTo := ToInteger(_Data);
end;

procedure THIStr_Enum._work_doDelimiter;
begin
  Dlm := ToString(_Data);
end;

procedure THIStr_Enum._work_doStep;
begin
  FStep := ToInteger(_Data);
end;

procedure  THIStr_Enum._work_doOnlyDivGroup;
begin
  FDivG := ReadBool(_Data);
end;

procedure THIStr_Enum._var_NumSubStr;
begin
  if (FStep = 1) or (Dlm <> '') then
    dtInteger(_Data, eIndex)
  else
    dtInteger(_Data, FNum);
end;

procedure THIStr_Enum._var_Part;
begin
  dtString(_Data, st);
end;

end.
