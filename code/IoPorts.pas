unit IoPorts;

interface
uses windows;

type
  TReadIO  = function(I:dword):dword of object; // Чтение из порта
  TWriteIO = procedure(I,D:dword) of object;    // Запись в порт

  TDataIO  = object
   private
    Prt,Idx,Data,Res,Refs:dword;
    function ReadIO(I:dword):dword;
    function NoRead(I:dword):dword;
    function ReOpenRd(I:dword):dword;
    function ReadByte(I:dword):dword;
    function ReadWord(I:dword):dword;
    function ReadDWord(I:dword):dword;
    procedure WriteIO(I,D:dword);
    procedure NoWrite(I,D:dword);
    procedure ReOpenWr(I,D:dword);
    procedure WriteByte(I,D:dword);
    procedure WriteWord(I,D:dword);
    procedure WriteDWord(I,D:dword);
    procedure OpenPort(P:dword);
   public
    Read:TReadIO;
    Write:TWriteIO;
    procedure OpenByte(P,Cnt:dword);
    procedure OpenWord(P,Cnt:dword);
    procedure OpenDWord(P,Cnt:dword);
    procedure ClosePort;
    procedure Clear;
  end;
  PDataIO =^TDataIO;

var Driver:bool=true;

implementation

const
  CmdOpen  = $222000;
  CmdRead  = $222004;
  CmdWrite = $222008;
  CmdClose = $22200C;

var CntIO:dword;
    hdl:dword=INVALID_HANDLE_VALUE;
    tmp:bool;

procedure Init;
begin
  If (GetVersion() and $80000000)<>0 then exit;
  hdl := CreateFile('\\.\VICX',GENERIC_READ+GENERIC_WRITE,FILE_SHARE_READ,nil,OPEN_EXISTING,0,0);
  tmp := hdl<>INVALID_HANDLE_VALUE;
  if (not tmp) and Driver then
    MessageBox(0,'Драйвер не работает !!!','VICX-Error',MB_OK+MB_ICONERROR);
  if tmp and (not Driver) then
    MessageBox(0,'А теперь заработал ...','VICX-Info',MB_OK+MB_ICONASTERISK);
  Driver := tmp;
end;

procedure TDataIO.NoWrite;
begin
end;

function TDataIO.NoRead;
begin
  result := dword(-1);
end;

procedure TDataIO.WriteByte;
asm
  add edx,[eax].Prt
  mov eax,ecx
  out dx,al
end;

function TDataIO.ReadByte;
asm
  add edx,[eax].Prt
  xor eax,eax
  in  al,dx
end;

procedure TDataIO.WriteWord;
asm
  add edx,[eax].Prt
  mov eax,ecx
  out dx,ax
end;

function TDataIO.ReadWord;
asm
  add edx,[eax].Prt
  xor eax,eax
  in  ax,dx
end;

procedure TDataIO.WriteDWord;
asm
  add edx,[eax].Prt
  mov eax,ecx
  out dx,eax
end;

function TDataIO.ReadDWord;
asm
  add edx,[eax].Prt
  in  eax,dx
end;

procedure TDataIO.WriteIO;
begin
  Idx  := I;
  Data := D;
  DeviceIoControl(hdl,CmdWrite,@Prt,12,nil,0,CntIO,nil);
end;

function TDataIO.ReadIO;
begin
  result := dword(-1);
  Idx := I;
  if DeviceIoControl(hdl,CmdRead,@Prt,8,@Res,4,CntIO,nil)and(CntIO=4) then
    result := Res;
end;

procedure TDataIO.ReOpenWr;
begin
  if DeviceIoControl(hdl,CmdOpen,@Prt,12,@Res,4,CntIO,nil)and(CntIO=4) then
   begin
    Write := WriteIO;
    Read  := ReadIO;
    Prt   := Res;
    inc(Refs);
    WriteIO(I,D);
   end;
end;

function TDataIO.ReOpenRd;
begin
  result := dword(-1);
  if DeviceIoControl(hdl,CmdOpen,@Prt,12,@Res,4,CntIO,nil)and(CntIO=4) then
   begin
    Write := WriteIO;
    Read  := ReadIO;
    Prt   := Res;
    inc(Refs);
    result := ReadIO(I);
   end;
end;

procedure TDataIO.OpenByte;
begin
  If (GetVersion() and $80000000)<>0 then
   begin
    Prt   := P;
    Write := WriteByte;
    Read  := ReadByte;
    exit;
   end;
  Idx   := 1;
  Data  := Cnt;
  OpenPort(P);
end;

procedure TDataIO.OpenWord;
begin
  If (GetVersion() and $80000000)<>0 then
   begin
    Prt   := P;
    Write := WriteWord;
    Read  := ReadWord;
    exit;
   end;
  Idx   := 2;
  Data  := Cnt;
  OpenPort(P);
end;

procedure TDataIO.OpenDWord;
begin
  If (GetVersion() and $80000000)<>0 then
   begin
    Prt   := P;
    Write := WriteDWord;
    Read  := ReadDWord;
    exit;
   end;
  Idx   := 3;
  Data  := Cnt;
  OpenPort(P);
end;

procedure TDataIO.OpenPort;
begin
  if hdl=INVALID_HANDLE_VALUE then
   begin
    Init;
    if hdl=INVALID_HANDLE_VALUE then exit;
   end;
  if Refs=0 then
   begin
    Prt   := P;
    Write := ReOpenWr;
    Read  := ReOpenRd;
    if DeviceIoControl(hdl,CmdOpen,@Prt,12,@Res,4,CntIO,nil)and(CntIO=4) then
     begin
      Write := WriteIO;
      Read  := ReadIO;
      Prt   := Res;
      inc(Refs);
     end;
   end
  else inc(Refs);
end;

procedure TDataIO.ClosePort;
begin
  if Refs<1 then exit;
  dec(Refs);
  if Refs>0 then exit;
  DeviceIoControl(hdl,CmdClose,@Prt,4,nil,0,CntIO,nil);
  Clear;
end;

procedure TDataIO.Clear;
begin
  Write := NoWrite;
  Read  := NoRead;
  Refs  := 0;
end;

initialization Init;

finalization
  if hdl<>INVALID_HANDLE_VALUE then
    CloseHandle(hdl);
end.
