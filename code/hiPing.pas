unit hiPing;

interface

{$I share.inc}

uses Kol,Share,WinSock,Windows,Debug;

type
  THIPing = class(TDebug)
   private
    Tm:word;
    Count:word;
   public
    _prop_Name:string;
    _prop_ByteCount:integer;
    _prop_TimeOut:integer;
   _data_Name:THI_Event;
   _event_onFailed:THI_Event;
   _event_onFind:THI_Event;

   constructor Create;
   destructor Destroy; override;
   procedure _work_doPing(var _Data:TData; Index:word);
   procedure _var_Time(var _Data:TData; Index:word);
   procedure _var_ByteCount(var _Data:TData; Index:word);
  end;

implementation

type
  ip_option_information = record // Информация заголовка IP (Наполнение
                            // этой структуры и формат полей описан в RFC791.
     Ttl : u_char;          // Время жизни (используется traceroute-ом)
     Tos : u_char;          // Тип обслуживания, обычно 0
     Flags : u_char;        // Флаги заголовка IP, обычно 0
     OptionsSize : u_char;  // Размер данных в заголовке, обычно 0, максимум 40
     OptionsData : PChar;   // Указатель на данные
 end;
 icmp_echo_reply = record
     Address : DWORD;       // Адрес отвечающего
     Status : u_long;       // IP_STATUS (см. ниже)
     RTTime : u_long;       // Время между эхо-запросом и эхо-ответом
				            // в миллисекундах
     DataSize : u_short;    // Размер возвращенных данных
     Reserved : u_short;    // Зарезервировано
     Data : Pointer;        // Указатель на возвращенные данные
     Options : ip_option_information; // Информация из заголовка IP
 end;
 PIPINFO = ^ip_option_information;
 PVOID = Pointer;
 function IcmpCreateFile() : THandle; stdcall; external 'ICMP.DLL' name
                           'IcmpCreateFile';
 function IcmpCloseHandle(IcmpHandle : THandle) : BOOL; stdcall;
                            external 'ICMP.DLL' name 'IcmpCloseHandle';
 function IcmpSendEcho(
   IcmpHandle : THandle;    // handle, возвращенный IcmpCreateFile()
   DestAddress : u_long;    // Адрес получателя (в сетевом порядке)
   RequestData : PVOID;     // Указатель на посылаемые данные
   RequestSize : Word;      // Размер посылаемых данных
   RequestOptns : PIPINFO;  // Указатель на посылаемую структуру
                            // ip_option_information (может быть nil)
   ReplyBuffer : PVOID;     // Указатель на буфер, содержащий ответы.
   ReplySize : DWORD;       // Размер буфера ответов
   Timeout : DWORD          // Время ожидания ответа в миллисекундах
  ) : DWORD; stdcall; external 'ICMP.DLL' name 'IcmpSendEcho';

constructor THIPing.Create;
begin
   inherited Create;
   if not UPD_Init then
     _hi_OnEvent(_event_onFailed,1);
end;

destructor THIPing.Destroy;
begin
   UPD_Clear;
   inherited Destroy;
end;

procedure THIPing._work_doPing;
label error;
var
    hIP : THandle;
    pingBuffer: pointer;
    pIpe : ^icmp_echo_reply;
    pHostEn : PHostEnt;
    destAddress : In_Addr;
begin
    hIP := IcmpCreateFile();
    GetMem( pIpe, sizeof(icmp_echo_reply) + _prop_ByteCount);
    GetMem( pingBuffer,_prop_ByteCount );
    pIpe.Data := pingBuffer;
    pIpe.DataSize := sizeof(pingBuffer);
    pHostEn := gethostbyname(pchar(ReadString(_Data,_data_Name,_prop_Name)));
    if (GetLastError <> 0) then
     begin
        _hi_OnEvent(_event_onFailed,2);
        goto error;
     end;
    destAddress := PInAddr(pHostEn^.h_addr_list^)^;
    IcmpSendEcho(hIP,destAddress.S_addr,pingBuffer,_prop_ByteCount,
                 Nil,pIpe, sizeof(icmp_echo_reply) + _prop_ByteCount, _prop_TimeOut);
    if (GetLastError <> 0) then
     begin
        _hi_OnEvent(_event_onFailed,3);
        goto error;
     end;
    Tm := pipe.RTTime;
    Count := pipe.DataSize;
    {$ifdef F_P}
    _hi_OnEvent(_event_onFind,Int2str(LoByte(LoWord(pIpe^.Address))) + '.' +
                              Int2str(HiByte(LoWord(pIpe^.Address))) + '.' +
                              Int2str(LoByte(HiWord(pIpe^.Address))) + '.' +
                              Int2str(HiByte(HiWord(pIpe^.Address))));
    {$else}
    _hi_OnEvent(_event_onFind,Format('%d.%d.%d.%d',
        [LoByte(LoWord(pIpe^.Address)),HiByte(LoWord(pIpe^.Address)),
         LoByte(HiWord(pIpe^.Address)),HiByte(HiWord(pIpe^.Address))]));
    {$endif}
    //Memo1.Lines.Add('Reply time: '+IntToStr(pIpe.RTTime)+' ms');
    IcmpCloseHandle(hIP);
    Exit;
error:
    FreeMem(pIpe);
    Freemem(pingBuffer);
end;

procedure THIPing._var_Time;
begin
   dtInteger(_Data,Tm);
end;

procedure THIPing._var_ByteCount;
begin
   dtInteger(_Data,Count);
end;

end.
