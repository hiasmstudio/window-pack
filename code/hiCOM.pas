unit hiCOM;

interface

uses Kol,Share,Windows,Debug;

type
  THICOM = class(TDebug)
   private
    hFile: THandle;
    procedure CloseCom;
    function InitCom(BaudRate, PortNo: Integer; Parity: Char;
      CommTimeOuts: TCommTimeouts): Boolean;
   public
    _prop_Port:byte;
    _prop_BaudRate:integer;
    _prop_Parity:integer;
    _prop_TimeOut:integer;

    _event_onWrite:THI_Event;
    _event_onRead:THI_Event;
    _data_BaudRate:THI_Event;
    _data_Port:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doOpen(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _work_doRXClear(var _Data:TData; Index:word);
    procedure _work_doWrite(var _Data:TData; Index:word);
    procedure _work_doRead(var _Data:TData; Index:word);
    procedure _work_doDTR(var _Data:TData; Index:word);
    procedure _work_doRTS(var _Data:TData; Index:word);
  end;

implementation
    //function ReceiveCom(var Buffer; Size: DWORD): Integer;
    //function SendCom(var Buffer; Size: DWORD): Integer;

constructor THICOM.Create;
begin
  inherited; 
  CloseCom;
end;

destructor THICOM.Destroy;
begin
  CloseCom; 
  inherited; 
end;

function THICOM.InitCom(BaudRate, PortNo: Integer; Parity: Char;
  CommTimeOuts: TCommTimeouts): Boolean;
var 
  FileName: string; 
  DCB: TDCB;
  PortParam: string; 
begin 
  result := FALSE;
  FileName := '\\.\Com' + Int2Str(PortNo); {имя файла}
  hFile := CreateFile(PChar(FileName),
    GENERIC_READ or GENERIC_WRITE, 0, nil,
    OPEN_EXISTING, 0, 0);
  if hFile = INVALID_HANDLE_VALUE then 
    exit;

  //установка требуемых параметров
  GetCommState(hFile, DCB); //чтение текущих параметров порта
  PortParam := 'baud=' + Int2Str(BaudRate) + ' parity=' + Parity +
    ' data=8 stop=1 ' +
    'octs=off';
  if BuildCommDCB(PChar(PortParam), DCB) then
  begin
    result := SetCommState(hFile, DCB) and
      SetCommTimeouts(hFile, CommTimeOuts);
  end;
  if not result then
    CloseCom;
end;

procedure THICOM.CloseCom;
begin
  if hFile <> INVALID_HANDLE_VALUE then
    CloseHandle(hFile);
  hFile := INVALID_HANDLE_VALUE;
end;

procedure THICOM._work_doOpen;
const _nm:string = 'NOEMS';
var cto:_COMMTIMEOUTS;
begin
   CloseCom;
   //FillChar(cto,sizeof(cto),cardinal(_prop_TimeOut));
   cto.ReadIntervalTimeout         := _prop_TimeOut;
   cto.ReadTotalTimeoutMultiplier  := _prop_TimeOut;
   cto.ReadTotalTimeoutConstant    := _prop_TimeOut;
   cto.WriteTotalTimeoutMultiplier := _prop_TimeOut;
   cto.WriteTotalTimeoutConstant   := _prop_TimeOut;
   InitCom(
      ReadInteger(_Data,_data_BaudRate,_prop_BaudRate),
      ReadInteger(_Data,_data_Port,_prop_Port+1),
      _nm[_prop_Parity+1],cto);
end;

procedure THICOM._work_doClose;
begin
  CloseCom;
end;

procedure THICOM._work_doRXClear;
begin
  if hFile <> INVALID_HANDLE_VALUE then
     PurgeComm(hFile, PURGE_RXCLEAR);
end;

procedure THICOM._work_doWrite;
var
  Sended: DWORD;
  s:string;
begin
  s := ToString(_Data);
  if hFile <> INVALID_HANDLE_VALUE then
   if WriteFile(hFile, s[1], Length(s), Sended, nil) then
     _hi_OnEvent(_event_onWrite,integer(Sended))
   else _hi_OnEvent(_event_onWrite,0);
end;

procedure THICOM._work_doRead;
var
  Received: DWORD;
  Len:cardinal;
  Buffer:string;
begin
  len := ToInteger(_Data);
  if len > 4096 then len := 4096;
  SetLength(Buffer, 4096);
  if hFile <> INVALID_HANDLE_VALUE then
   if ReadFile(hFile, Buffer[1], Len, Received, nil) then
    begin
      SetLength(Buffer,Received);
      _hi_OnEvent(_event_onRead,Buffer)
    end
   else _hi_OnEvent(_event_onRead,string(''));
end;

procedure THICOM._work_doDTR;
begin
  if hFile = INVALID_HANDLE_VALUE then exit;
  if ReadBool(_Data) then
    EscapeCommFunction(hFile, SETDTR)
  else
    EscapeCommFunction(hFile, CLRDTR);
end;

procedure THICOM._work_doRTS;
begin
  if hFile = INVALID_HANDLE_VALUE then exit;
  if ReadBool(_Data) then
    EscapeCommFunction(hFile, SETRTS)
  else
    EscapeCommFunction(hFile, CLRRTS);
end;

end.
