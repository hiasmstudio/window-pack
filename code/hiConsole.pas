unit hiConsole;

interface

uses Windows,Kol,Share,Debug;

type
  THIConsole = class(TDebug)
   private
    FStdOut:cardinal;
    FStdIn:cardinal;
   public
    _prop_Icon:HICON;
    _prop_Title:string;
    _prop_Method: byte;

    _event_onStart:THI_Event;
    _event_onParam:THI_Event;
    _data_Point:THI_Event;
    _data_CtrlC:THI_Event;
    _data_Close:THI_Event;
    _data_Break:THI_Event;

    constructor Create;
    procedure Start;
    procedure InitParams;
    function ConsoleEvent(code:dword):bool;
    function ParamByName(Name: string): string;
    function Decode(Value: string): string;
    function HexToInt(CH: char): integer;

    procedure _work_doWrite(var _Data:TData; Index:word);
    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _work_doTextAttribute(var _Data:TData; Index:word);
    procedure _work_doParamByName(var _Data:TData; Index:word);
    procedure _var_Read(var _Data:TData; Index:word);
    procedure _var_InHandle(var _Data:TData; Index:word);
    procedure _var_InParams(var _Data:TData; Index:word);
  end;

implementation

var cn:THIConsole;
var InParams: string;

function CtrlHandler(fdwCtrlType:dword):bool; stdcall;
begin
    Result := cn.ConsoleEvent(fdwCtrlType);
end;

constructor THIConsole.Create;
begin
   inherited;
end;

procedure THIConsole.Start;
begin
   cn := self;
   SetConsoleTitle(PChar(_prop_Title));
   FStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
   FStdIn := GetStdHandle(STD_INPUT_HANDLE);
   SetConsoleCtrlHandler(@CtrlHandler,true);
   InitParams;
   EventOn;
   InitDo;
   _hi_OnEvent(_event_onStart);
end;

procedure THIConsole.InitParams;
  var 
      ss:string;
      StdIn, Size, Actual: cardinal;
  begin
    if _prop_Method = 0 then begin
      // Читаем переданные параметры из переменной окружения
      SetLength( SS, 10000 );
      GetEnvironmentVariable( 'QUERY_STRING', @SS[1], 2000 );
      InParams := PChar( @SS[1] )
    end else begin
      // Читаем переданные параметры из STDIN
      StdIn := GetStdHandle( STD_INPUT_HANDLE );
      Size := SetFilePointer( StdIn, 0, nil, FILE_END );
      SetFilePointer( StdIn, 0, nil, FILE_BEGIN );
      if (Size <= 0) then Exit;
      SetLength(InParams, Size);
      ReadFile( StdIn, InParams[1], Size, Actual, nil );
    end;
  end;

//////////////////////////////////////////////////////////
//        HexToInt
//////////////////////////////////////////////////////////
// Функция переводит шестнадчитиричный символ в число
function THIConsole.HexToInt(CH: char): integer;
  begin
    Result:=0;
    case CH of
      '0'..'9': Result:=Ord(CH)-Ord('0');
      'A'..'F': Result:=Ord(CH)-Ord('A')+10;
      'a'..'f': Result:=Ord(CH)-Ord('a')+10;
    end;
  end;

// Преобразует символы, записанные в виде %2B к правильному виду
function THIConsole.Decode(Value: string): string;
  var I, L: integer;
  begin
    Result := '';
    L := 0;
    for I:=1 to Length(Value) do begin
      if(Value[I]<>'%') and (Value[I]<>'+') and (L<1) then
        Result := Result + Value[I]
      else
        if(Value[I]='+') then
          Result := Result + ' '
        else
          if(Value[I]='%') then begin
            L := 2;
            if (I<Length(Value)-1) then Result := Result + Chr(HexToInt(Value[I+1])*16+HexToInt(Value[I+2]));
          end else Dec(L);
    end; { For }
  end;

// Возвращает значение параметра, заданного в Name
function THIConsole.ParamByName(Name: string): string;
  var SS, ST: string;
    K: integer;
  begin
    Result := '';
    SS := InParams;
    while Length(SS)<>0 do begin
      K := Pos('&',SS);
      if (K<>0) then begin
        ST := Copy(SS,1,K-1);
        SS := Copy(SS,K+1,10000);
      end else begin
        ST := SS;
        SS := '';
      end;
      K := Pos('=',ST);
      if (K<>0) then begin
        if(Name=Copy(ST,1,K-1)) then begin
          Result := Decode(Copy(ST,K+1,6000));
        end;
      end;
    end;
  end;

procedure THIConsole._work_doParamByName;
begin
   _hi_OnEvent( _event_onParam, ParamByName( ToString( _Data ) ) );
end;

function THIConsole.ConsoleEvent;
begin
    result := false;
    case Code of
      CTRL_C_EVENT: Result := ToIntegerEvent(_data_CtrlC) <> 0;
      CTRL_CLOSE_EVENT: Result := ToIntegerEvent(_data_Close) <> 0;
      CTRL_BREAK_EVENT: Result := ToIntegerEvent(_data_Break) <> 0;
    end;
end;

procedure THIConsole._work_doWrite;
begin
   Write(ToString(_Data));
end;

procedure THIConsole._work_doPosition;
var
  p:cardinal;
begin
   p := ReadInteger(_Data,_data_Point,0);
   SetConsoleCursorPosition(FStdOut,coord(p));
end;

procedure THIConsole._work_doTextAttribute;
begin
   SetConsoleTextAttribute(FStdOut,ToInteger(_Data));
end;

procedure THIConsole._var_Read;
var s:string;
begin
   ReadLn(s);
   dtString(_Data,s);
end;

procedure THIConsole._var_InHandle;
begin
   dtInteger(_Data,FStdIn);
end;

procedure THIConsole._var_InParams;
begin
   dtString(_Data,Decode(InParams));
end;

end.
