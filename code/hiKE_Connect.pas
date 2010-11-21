unit hiKE_Connect;

interface

uses Windows,Kol,Share,Debug;

type
  TOnAnswer = procedure(const snum:string) of object;
  
  TKE_USB = record
    GetSerialNumber:procedure of object;
    onSerialNumber:TOnAnswer;
    
    WriteLine:procedure(Line:byte; value:byte) of object;
    onWriteLine:TOnAnswer;
    
    SetLineDirection:procedure(Line:byte; direction:byte; toMem:boolean) of object;
    onLineDirection:TOnAnswer;
    
    GetADCValue:procedure of object;
    SetADCFreq:procedure(freq:integer) of object;
    onADCValue:TOnAnswer;
    
    ResetDevice:procedure of object;
    onResetDevice:TOnAnswer;
    
    GetLineDirection:procedure(Line:byte; Mem:boolean) of object;
    onLineState:TOnAnswer;
    
    ReadLine:procedure(Line:byte) of object;
    onReadLine:TOnAnswer;
  end;
  IKE_USB = ^TKE_USB; 
  THIKE_Connect = class(TDebug)
   private
    hFile:THandle;
    FStop:boolean;
    th:PThread;
    fKEU:TKE_USB;
    
    procedure StartThread;
    procedure StopThread;
    function Execute(Sender:PThread): Integer;
    
    procedure SendCommand(const cmd:string);
    
    procedure GetSerialNumber;
    procedure thread_SerialNumber( Sender: PThread; Param: Pointer);
    
    procedure WriteLine(Line:byte; value:byte);
    procedure thread_WriteLine( Sender: PThread; Param: Pointer);
    
    procedure SetLineDirection(Line:byte; direction:byte; toMem:boolean);
    procedure thread_LineDirection( Sender: PThread; Param: Pointer);
    
    procedure GetADCValue;
    procedure SetADCFreq(freq:integer);
    procedure thread_ADCValue( Sender: PThread; Param: Pointer);
    
    procedure ResetDevice;
    procedure thread_ResetDevice( Sender: PThread; Param: Pointer);
    
    procedure GetLineDirection(Line:byte; Mem:boolean);
    procedure thread_LineState( Sender: PThread; Param: Pointer); 

    procedure ReadLine(Line:byte);
    procedure thread_ReadLine(Sender: PThread; Param: Pointer);
   public
    _prop_ComPort:integer;
    _prop_Name:string;

    _data_ComPort:THI_Event;
    _event_onError:THI_Event;
    _event_onConnect:THI_Event;

    destructor Destroy; override;
    procedure _work_doConnect(var _Data:TData; Index:word);
    procedure _work_doDisConnect(var _Data:TData; Index:word);
    procedure _work_doSendCommnad(var _Data:TData; Index:word);
    function getInterfaceKE_USB:IKE_USB;
  end;

implementation

destructor THIKE_Connect.Destroy;
var dt:TData;
begin
   _work_doDisConnect(dt, 0);
   inherited;
end;

function THIKE_Connect.getInterfaceKE_USB:IKE_USB;
begin
   fKEU.GetSerialNumber := GetSerialNumber;
   fKEU.WriteLine := WriteLine;
   fKEU.SetLineDirection := SetLineDirection;
   fKEU.GetADCValue := GetADCValue;
   fKEU.SetADCFreq := SetADCFreq;
   fKEU.ResetDevice := ResetDevice;
   fKEU.GetLineDirection := GetLineDirection;
   fKEU.ReadLine := ReadLine; 
   Result := @fKEU;
end;

procedure THIKE_Connect._work_doConnect;
var DCB: TDCB;
    cto:_COMMTIMEOUTS;
begin
  // параметры настройки порта взяты из KeTermDlg.cpp с сайта производителя
  hFile := CreateFile(PChar('\\.\Com' + int2str(ReadInteger(_Data, _data_ComPort, _prop_ComPort))),
                      GENERIC_READ or GENERIC_WRITE, 0, nil,OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);   
  if hFile = INVALID_HANDLE_VALUE then
    _hi_onEvent(_event_onError, 1)
  else                           
   begin
     GetCommState(hFile, DCB);
     DCB.BaudRate  := CBR_9600; 
     DCB.Parity    := NOPARITY;
     DCB.ByteSize  := 8;
     DCB.StopBits  := OneStopBit;
     cto.ReadIntervalTimeout          := MAXDWORD;
     cto.ReadTotalTimeoutMultiplier   := 0;
     cto.ReadTotalTimeoutConstant     := 0;
     cto.WriteTotalTimeoutMultiplier  := 0;
     cto.WriteTotalTimeoutConstant    := 1000;
     if not SetCommTimeouts(hFile, cto) then
       _hi_onEvent(_event_onError, 2)
     else if not SetCommState(hFile, dcb) then
       _hi_onEvent(_event_onError, 3)
     else
      begin
//        PurgeComm(hFile, PURGE_TXCLEAR or PURGE_RXCLEAR );
        StartThread;
        _hi_onEvent(_event_onConnect);
      end;
   end;
end;

procedure THIKE_Connect._work_doDisConnect;
begin
   if hFile = 0 then exit;
    
   StopThread;
   CloseHandle(hFile);
   hFile := 0;
end;

procedure THIKE_Connect.StartThread;
begin
   th := {$ifdef F_P}NewThreadforFPC{$else}NewThread{$endif};
   th.OnExecute := Execute;
   th.Resume;
end;

procedure THIKE_Connect.StopThread;
begin
   FStop := true;
   th.Free;
end;

function THIKE_Connect.Execute(Sender:PThread): Integer;
var 
  Buffer:array[0..1023] of char;
  Received: DWORD;
begin
   FStop := false;
   repeat
//         _debug('ok');          
     if ReadFile(hFile, Buffer[0], 1024, Received, nil) then
       if Received > 0 then
        begin
         if copy(Buffer, 1, 4) = '#SER' then
           begin
             if assigned(fKEU.onSerialNumber) then 
               Sender.SynchronizeEx(thread_SerialNumber, PChar(copy(Buffer, 6, Received - 7)));
           end
         else if copy(Buffer, 1, 3) = '#WR' then
           begin
             if assigned(fKEU.onWriteLine) then 
               Sender.SynchronizeEx(thread_WriteLine, PChar(copy(Buffer, 5, Received - 6)));
           end
         else if copy(Buffer, 1, 7) = '#IO,SET' then
           begin
             if assigned(fKEU.onLineDirection) then 
               Sender.SynchronizeEx(thread_LineDirection, PChar(copy(Buffer, 9, Received - 10)));
           end  
         else if copy(Buffer, 1, 4) = '#ADC' then
           begin
             if assigned(fKEU.onADCValue) then 
               Sender.SynchronizeEx(thread_ADCValue, PChar(copy(Buffer, 6, Received - 7)));
           end
         else if copy(Buffer, 1, 4) = '#RST' then
           begin
             if assigned(fKEU.onResetDevice) then 
               Sender.SynchronizeEx(thread_ResetDevice, PChar(copy(Buffer, 6, Received - 7)));
           end
         else if copy(Buffer, 1, 3) = '#IO' then
           begin
             if assigned(fKEU.onLineState) then 
               Sender.SynchronizeEx(thread_LineState, PChar(copy(Buffer, 5, Received - 6)));
           end
         else if copy(Buffer, 1, 3) = '#RD' then
           begin
             if assigned(fKEU.onReadLine) then 
               Sender.SynchronizeEx(thread_ReadLine, PChar(copy(Buffer, 5, Received - 6)));
           end
         else if copy(Buffer, 1, 4) = '#ERR' then
           _hi_onEvent(_event_onError, 4) 
        end
       else sleep(10);
   until Sender.Terminated or FStop;
   Result := 0;
end;

procedure THIKE_Connect._work_doSendCommnad(var _Data:TData; Index:word);
begin
   SendCommand(ToString(_Data));
end;

procedure THIKE_Connect.SendCommand(const cmd:string);
var
  Sended: DWORD;
  s:string;
begin
  s := '$KE,' + cmd + #13#10;
  Sended := 0;
  if WriteFile(hFile, PChar(s)^, Length(s), Sended, nil) then
     ;
end;

procedure THIKE_Connect.GetSerialNumber;
begin
  SendCommand('SER');
end;

procedure THIKE_Connect.WriteLine;
begin
  SendCommand('WR,' + int2str(Line) + ',' + int2str(value));
end;

procedure THIKE_Connect.SetLineDirection;
var s:string;
begin
  s := 'IO,SET,' + int2str(Line) + ',' + int2str(direction);
  if toMem then
    s := s + ',S'; 
  SendCommand(s);
end;

procedure THIKE_Connect.GetADCValue;
begin
  SendCommand('ADC');
end;

procedure THIKE_Connect.SetADCFreq;
begin
  SendCommand('ADC,' + int2str(freq));
end;

procedure THIKE_Connect.ResetDevice;
begin
  SendCommand('RST');
end;

procedure THIKE_Connect.GetLineDirection;
var s:string;
begin
  s := 'IO,GET,';
  if Mem then
    s := s + 'MEM'
  else
    s := s + 'CUR';
  if line > 0 then
    s := s + ',' + int2str(Line);  
  SendCommand(s);
end;

procedure THIKE_Connect.ReadLine;
begin
  if Line = 0 then
    SendCommand('RD,ALL')
  else
    SendCommand('RD,' + int2str(Line));
end;

procedure THIKE_Connect.thread_SerialNumber( Sender: PThread; Param: Pointer);
begin
  fKEU.onSerialNumber(PChar(Param));
end;

procedure THIKE_Connect.thread_WriteLine( Sender: PThread; Param: Pointer);
begin
  fKEU.onWriteLine(PChar(Param));
end;

procedure THIKE_Connect.thread_LineDirection( Sender: PThread; Param: Pointer);
begin
  fKEU.onLineDirection(PChar(Param));
end;

procedure THIKE_Connect.thread_ADCValue( Sender: PThread; Param: Pointer);
begin
  fKEU.onADCValue(PChar(Param));
end;

procedure THIKE_Connect.thread_ResetDevice( Sender: PThread; Param: Pointer);
begin
  fKEU.onResetDevice(PChar(Param));
end;

procedure THIKE_Connect.thread_LineState( Sender: PThread; Param: Pointer);
begin
  fKEU.onLineState(PChar(Param));
end;

procedure THIKE_Connect.thread_ReadLine( Sender: PThread; Param: Pointer);
begin
  fKEU.onReadLine(PChar(Param));
end;

end.
