unit hiCOMEX;

interface

uses Windows, Kol, Share, Debug;

const
  _nm: string = 'NOEMS';
  dtrrts: string = 'offon ';

type
  _COMSTAT1 = record
    Flags: DWORD;
    cbInQue: DWORD;
    cbOutQue: DWORD;
  end;
  TComStat1 = _COMSTAT1;

type

  THICOMEX = class(TDebug)
   private
    hFile: THandle;
    thrd, thwr: PThread;
    OvrWr, OvrRd: TOverlapped;
    ReadStr: string;
    MaskRd: DWORD;
    SendedWr: Integer;
    procedure CloseCom;
    function SetCom(BaudRate: Integer; Parity, DataBits, StopBits: Char; DTR, RTS: string): boolean;
    function InitCom(BaudRate, PortNo: Integer; Parity, DataBits, StopBits: Char; DTR, RTS: string): boolean;
    function ExecuteRd(Sender: PThread): Integer;
    function ExecuteWr(Sender: PThread): Integer;
    procedure SyncExecRd;
    procedure SyncExecWr;
    procedure SyncExecSt;    
   public
    _prop_Port:byte;
    _prop_BaudRate:integer;
    _prop_Parity:integer;
    _prop_DataBits:integer;
    _prop_StopBits:integer;    
    _prop_DTR: byte;
    _prop_RTS: byte;    

    _event_onSyncWrite:THI_Event;
    _event_onRead:THI_Event;
    _event_onSyncRead:THI_Event;    
    _event_onDSR:THI_Event;
    _event_onCTS:THI_Event;
    _event_onDCD:THI_Event;    
    _event_onRING:THI_Event;
    _event_onSetComState:THI_Event;    
    _data_BaudRate:THI_Event;
    _data_Port:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doOpen(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _work_doRXClear(var _Data:TData; Index:word);
    procedure _work_doWrite(var _Data:TData; Index:word);
    procedure _work_doDTR(var _Data:TData; Index:word);
    procedure _work_doRTS(var _Data:TData; Index:word);
    procedure _work_doSetComState(var _Data:TData; Index:word);
    procedure _work_doDataBits(var _Data:TData; Index:word);    
    procedure _work_doParity(var _Data:TData; Index:word);    
    procedure _work_doStopBits(var _Data:TData; Index:word);
  end;

implementation

constructor THICOMEX.Create;
begin
  inherited; 
  hFile := INVALID_HANDLE_VALUE;
  FillChar(OvrWr, SizeOf(TOverlapped), #0);
  OvrWr.hEvent := CreateEvent(nil, True, True, #0);
  FillChar(OvrRd, SizeOf(TOverlapped), #0);
  OvrRd.hEvent := CreateEvent(nil, false, false, #0);
end;

destructor THICOMEX.Destroy;
begin
// Этот костыль связан с некорректностью уничтожения класса в FPC
{$ifndef F_P}
  CloseCom;
  CloseHandle(OvrWr.hEvent);
  CloseHandle(OvrRd.hEvent);
{$endif}  
  inherited Destroy; 
end;

function THICOMEX.SetCom(BaudRate: Integer; Parity, DataBits, StopBits: Char; DTR, RTS: string): Boolean;
var 
  PortParam: string;
  dcb: TDCB;
  cto: _COMMTIMEOUTS;
begin 
  result := false;
  if hFile = INVALID_HANDLE_VALUE then exit;

  //установка требуемых параметров
  GetCommState(hFile, dcb); //чтение текущих параметров порта
  PortParam := 'baud='    + Int2Str(BaudRate) +
               ' data='   + DataBits +
               ' parity=' + Parity +
               ' stop='   + StopBits +
               ' dtr='    + DTR +
               ' rts='    + RTS +
               ' xon=off odsr=off octs=off idsr=off';

  FillChar(cto, sizeof(cto), #0);   // убираем все TimeOut-ы, так как будем работать с перекрытыми методами

  if BuildCommDCB(PChar(PortParam), DCB) then
    result := SetCommState(hFile, DCB) and SetCommTimeouts(hFile, cto);
end;

function THICOMEX.InitCom(BaudRate, PortNo: Integer; Parity, DataBits, StopBits: Char; DTR, RTS: string): Boolean;
var 
  FileName: string; 
  PortParam: string;
  dcb: TDCB;
  cto: _COMMTIMEOUTS;
  FModems: DWORD;  
begin 
  result := false;
  CloseCom;
  FileName := '\\.\Com' + Int2Str(PortNo); // имя файла
  hFile := CreateFile(PChar(FileName),
           GENERIC_READ or GENERIC_WRITE,
           0,
           nil,
           OPEN_EXISTING,
           FILE_FLAG_OVERLAPPED,
           0);
  if hFile = INVALID_HANDLE_VALUE then exit;

  //установка требуемых параметров
  GetCommState(hFile, dcb); //чтение текущих параметров порта
  PortParam := 'baud='    + Int2Str(BaudRate) +
               ' data='   + DataBits +
               ' parity=' + Parity +
               ' stop='   + StopBits +
               ' dtr='    + DTR +
               ' rts='    + RTS +
               ' xon=off odsr=off octs=off idsr=off';

  FillChar(cto, sizeof(cto), #0);   // убираем все TimeOut-ы, так как будем работать с перекрытыми методами

  if BuildCommDCB(PChar(PortParam), DCB) then
    result := SetCommState(hFile, DCB) and SetCommTimeouts(hFile, cto);
  if not result then
    CloseCom
  else
  begin
    thrd := {$ifdef F_P}NewThreadforFPC{$else}NewThread{$endif};
    thrd.ThreadPriority := THREAD_PRIORITY_HIGHEST;
    thrd.OnExecute := ExecuteRd;
    thwr := {$ifdef F_P}NewThreadforFPC{$else}NewThread{$endif};
    thwr.ThreadPriority := THREAD_PRIORITY_HIGHEST;
    thwr.OnExecute := ExecuteWr;
    PurgeComm(hFile, PURGE_TXCLEAR or PURGE_RXCLEAR);
    SetCommMask(hFile, EV_RXCHAR or EV_DSR or EV_CTS or EV_RLSD or EV_RING);
    if GetCommModemStatus(hFile, FModems) then
    begin
      _hi_onEvent(_event_onDSR, integer((FModems and MS_DSR_ON) = MS_DSR_ON));
      _hi_onEvent(_event_onCTS, integer((FModems and MS_CTS_ON) = MS_CTS_ON));
      _hi_onEvent(_event_onDCD, integer((FModems and MS_RLSD_ON) = MS_RLSD_ON));            
      _hi_onEvent(_event_onRING, integer((FModems and MS_RING_ON) = MS_RING_ON));
    end;      
    thrd.Resume;
  end;  
end;

procedure THICOMEX.CloseCom;
begin
  if Assigned(thrd) then
  begin
    thrd.Terminate;
    thrd.WaitFor;
    free_and_nil(thrd);    
  end;
  if Assigned(thwr) then
  begin
    thwr.Terminate;
    thwr.WaitFor;
    free_and_nil(thwr);    
  end;
  if hFile = INVALID_HANDLE_VALUE then exit;
  PurgeComm(hFile, PURGE_TXCLEAR or PURGE_RXCLEAR);
  CloseHandle(hFile);
  hFile := INVALID_HANDLE_VALUE;
end;

procedure THICOMEX._work_doOpen;
begin
   CloseCom;
   InitCom(ReadInteger(_Data,_data_BaudRate,_prop_BaudRate),
           ReadInteger(_Data,_data_Port,_prop_Port + 1),
           _nm[_prop_Parity + 1],
           Int2Str(_prop_DataBits + 7)[1],
           Int2Str(_prop_StopBits + 1)[1],
           Copy(dtrrts, _prop_DTR * 3 + 1, 3),
           Copy(dtrrts, _prop_RTS * 3 + 1, 3));
end;

procedure THICOMEX._work_doClose;
begin
  CloseCom;
end;

procedure THICOMEX._work_doRXClear;
begin
  if hFile <> INVALID_HANDLE_VALUE then
     PurgeComm(hFile, PURGE_RXCLEAR);
end;

procedure THICOMEX._work_doWrite;
var
  BufferWr: string;
  Sended: DWORD;  
begin
  if hFile = INVALID_HANDLE_VALUE then exit;
//  if (not thwr.Suspended) then exit;
  BufferWr := ToString(_Data);
  WriteFile(hFile, BufferWr[1], Length(BufferWr), Sended, @OvrWr);
  thwr.Resume;
end;

function THICOMEX.ExecuteRd;
var
  Signaled, BytesTrans, Err: DWORD;
  BufferRd: string;   
  FStat: TComStat1;
begin
  while not Sender.Terminated do
  begin
    WaitCommEvent(hFile, MaskRd, @OvrRd);
    Signaled := WaitForSingleObject(OvrRd.hEvent, INFINITE);
    if (Signaled = WAIT_OBJECT_0) then
    begin 
      if GetOverlappedResult(hFile, OvrRd, BytesTrans, True) then
      begin
        if ((MaskRd and EV_RXCHAR) <> 0) then
        begin
          if ClearCommError(hFile, Err, @FStat) then
          begin
            if (FStat.cbInQue <> 0) then
            begin
              SetLength(BufferRd, FStat.cbInQue);
              ReadFile(hFile, BufferRd[1], FStat.cbInQue, BytesTrans, @OvrRd);
              if GetOverlappedResult(hFile, OvrRd, BytesTrans, True) then
              begin
                ReadStr := BufferRd + #0;
                SetLength(ReadStr, BytesTrans);
                _hi_onEvent(_event_onRead, ReadStr);
                if Assigned(_event_onSyncRead.Event) then Sender.Synchronize(SyncExecRd); 
              end;
            end;
          end;  
        end
        else
          if Assigned(_event_onDSR.Event) or
             Assigned(_event_onCTS.Event) or
             Assigned(_event_onDCD.Event) or
             Assigned(_event_onRING.Event) then
            Sender.Synchronize(SyncExecSt);
      end;
    end;        
  end;
  PurgeComm(hFile, PURGE_RXCLEAR);
  Result := 0; 
end;

procedure THICOMEX.SyncExecRd;
begin
  _hi_onEvent(_event_onSyncRead, ReadStr);
end;

procedure THICOMEX.SyncExecSt;
var
  FModems: DWORD;
begin
  if GetCommModemStatus(hFile, FModems) then
    if ((MaskRd and EV_DSR) <> 0) then
      _hi_onEvent(_event_onDSR, integer((FModems and MS_DSR_ON) = MS_DSR_ON));
    if ((MaskRd and EV_CTS) <> 0) then
      _hi_onEvent(_event_onCTS, integer((FModems and MS_CTS_ON) = MS_CTS_ON));
    if ((MaskRd and EV_RLSD) <> 0) then
      _hi_onEvent(_event_onDCD, integer((FModems and MS_RLSD_ON) = MS_RLSD_ON));            
    if ((MaskRd and EV_RING) <> 0) then
      _hi_onEvent(_event_onRING, integer((FModems and MS_RING_ON) = MS_RING_ON));
end;

function THICOMEX.ExecuteWr(Sender: PThread): Integer;
var
  Sended, Signaled: DWORD;
begin
  while not Sender.Terminated do
  begin
    SendedWr := 0;
    Signaled := WaitForSingleObject(OvrWr.hEvent, 500);
    if (Signaled = WAIT_OBJECT_0) then
      if GetOverlappedResult(hFile, OvrWr, Sended, True) then
        SendedWr := integer(Sended);
    if Assigned(_event_onSyncWrite.Event) then Sender.Synchronize(SyncExecWr);     
    Sender.Suspend;
  end;
  PurgeComm(hFile, PURGE_TXCLEAR);
  Result := 0;
end;

procedure THICOMEX.SyncExecWr;
begin
  _hi_onEvent(_event_onSyncWrite, SendedWr);
end;

procedure THICOMEX._work_doDTR;
begin
  if hFile = INVALID_HANDLE_VALUE then exit;
  if ReadBool(_Data) then
    EscapeCommFunction(hFile, SETDTR)
  else
    EscapeCommFunction(hFile, CLRDTR);
end;

procedure THICOMEX._work_doRTS;
begin
  if hFile = INVALID_HANDLE_VALUE then exit;
  if ReadBool(_Data) then
    EscapeCommFunction(hFile, SETRTS)
  else
    EscapeCommFunction(hFile, CLRRTS);
end;

procedure THICOMEX._work_doSetComState;
begin
  if not SetCom(ReadInteger(_Data,_data_BaudRate,_prop_BaudRate),
                _nm[_prop_Parity + 1],
                Int2Str(_prop_DataBits + 7)[1],
                Int2Str(_prop_StopBits + 1)[1],
                Copy(dtrrts, _prop_DTR * 3 + 1, 3),
                Copy(dtrrts, _prop_RTS * 3 + 1, 3)) then
    _hi_onEvent(_event_onSetComState, 0)
  else
    _hi_onEvent(_event_onSetComState, 1);
end;

procedure THICOMEX._work_doDataBits;    
begin
  _prop_DataBits := ToInteger(_Data);
end;

procedure THICOMEX._work_doParity;    
begin
  _prop_Parity := ToInteger(_Data);
end;

procedure THICOMEX._work_doStopBits;
begin
  _prop_StopBits := ToInteger(_Data);
end;

end.