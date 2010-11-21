unit hiSharedStream;

interface

uses Windows, Kol, Share, Debug;

type
 TStreamEx = {$ifndef F_P}object{$else}class{$endif}(TStream) end;
 PStreamEx = {$ifndef F_P}^{$endif}TStreamEx;
 
type
  ThiSharedStream = class(TDebug)
   private
     hMMF: THandle;
     hFile: THandle;
     CPage: Cardinal;     
     ST: PSTreamEx;
     Offset: int64;
     SzFile: int64;
     NewSize: int64;
     Size: Cardinal;
     Granularity: Cardinal;
     procedure Close;
     procedure _MapViewOfFile;
   public
     _prop_FileName: string;
     _prop_CoreName: string;
     _prop_Mode: byte;
     _prop_Offset: real;
     _prop_Size: cardinal;
     _prop_PageMem: integer;
     _data_Offset: THI_Event;
     _data_Size: THI_Event;
     _data_FileName: THI_Event;
     _data_CoreName: THI_Event;
     _data_PageMem: THI_Event;
     _event_onOpen: THI_Event;
     _event_onRemapping: THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doOpen(var _Data: TData; Index: Word);
    procedure _work_doClose(var _Data: TData; Index: Word);
    procedure _work_doRemapping(var _Data: TData; Index: Word);
    procedure _work_doPosition(var _Data: TData; Index: Word);    
    procedure _var_Memory(var _Data: TData; Index: Word);
    procedure _var_Stream(var _Data: TData; Index: Word);
    procedure _var_SizeMMF(var _Data: TData; Index: Word);
    procedure _var_PageMMF(var _Data: TData; Index: Word);    
    procedure _var_FileOffset(var _Data: TData; Index: Word);
    procedure _var_FileSize(var _Data: TData; Index: Word);
    procedure _var_Position(var _Data: TData; Index: Word);
    procedure _var_Granularity(var _Data: TData; Index: Word);
    procedure _var_CountFileBlock(var _Data: TData; Index: Word);
    procedure _var_CurOffsetBlock(var _Data: TData; Index: Word);                        
  end;

implementation

function GetFileSizeEx(hFile: THandle; var Size: int64): BOOL;
         stdcall; external 'kernel32.dll' name 'GetFileSizeEx';

//------------------------------------------------------------------------------
//  Addition By Galkov
//

function WriteExMemoryStream(Strm: PStream; var Buffer; Count: DWORD): DWORD;
asm
        PUSH     EBX
        XCHG     EBX, EAX
        MOV      EAX, [EBX].TStreamEx.fData.fSize
        SUB      EAX, [EBX].TStreamEx.fData.fPosition
        CMP      EAX, ECX
        JGE      @@1
        XCHG     ECX, EAX
@@1:
        MOV      EAX, [EBX].TStreamEx.fMemory
        ADD      EAX, [EBX].TStreamEx.fData.fPosition
        XCHG     EDX, EAX
        PUSH     ECX
        CALL     System.Move
        POP      EAX
        ADD      [EBX].TStreamEx.fData.fPosition, EAX
        POP      EBX
end;

function SeekExMemStream(Strm: PStream; MoveTo: Integer; MoveFrom: TMoveMethod): DWORD;
asm
        PUSH     EBX
        MOV      EBX, EAX
        MOV      EAX, EDX
        AND      ECX, $FF
        LOOP     @@1
        ADD      EAX, [EBX].TStreamEx.fData.fPosition
@@1:    LOOP     @@2
        ADD      EAX, [EBX].TStreamEx.fData.fSize
@@2:    CMP      EAX, [EBX].TStreamEx.fData.fSize
        JLE      @@3
        MOV      EAX, [EBX].TStreamEx.fData.fSize
@@3:    MOV      [EBX].TStreamEx.fData.fPosition, EAX
        POP      EBX
end;

var
  SharedMethods: TStreamMethods =
  (
    fSeek: SeekExMemStream;
    fGetSiz: GetSizeMemStream;
    fSetSiz: DummySetSize;
    fRead: ReadMemStream;
    fWrite: WriteExMemoryStream;
    fClose: DummyStreamProc;
    fCustom: nil;
    fWait: nil;
  );

//------------------------------------------------------------------------------

constructor ThiSharedStream.Create;
var
  lpSystemInfo: _SYSTEM_INFO; 
begin
  inherited;
  hMMF := 0;
  St := nil;
  GetSystemInfo(lpSystemInfo);
  Granularity := lpSystemInfo.dwAllocationGranularity;  
end; 

destructor ThiSharedStream.Destroy;
begin
  Close;
  inherited;
end;

procedure ThiSharedStream._MapViewOfFile;
var
  P: Pointer;
begin
  if hMMF = 0 then exit;
  P := MapViewOfFile(hMMF, FILE_MAP_ALL_ACCESS, I64(Offset).Hi, I64(Offset).Lo, Size);
  if P = nil then exit;
  ST := PStreamEx(_NewStream(SharedMethods));
  ST.fMemory         := P;
  ST.fData.fCapacity := Size;
  ST.fData.fSize     := Size;
  ST.fData.fPosition := 0;
//  _debug('Offset = ' + double2str(Offset) + '; Size = ' + int2str(Size) + '; Offset + Size = ' + double2str(Offset + Size) + '; STMemory = ' + int2str(integer(ST.Memory)));
end;

procedure ThiSharedStream._work_doOpen;
var
  fn, crn: string;
  SzOff: int64;
begin
  Close;
 
  fn     := ReadString(_Data, _data_FileName, _prop_FileName);
  crn    := ReadString(_Data, _data_CoreName, _prop_CoreName);  
  Offset := Round(ReadReal(_Data, _data_Offset));
  Size   := ReadInteger(_Data, _data_Size);
  CPage  := ReadInteger(_Data, _data_PageMem, _prop_PageMem); 
  i64(Offset).Lo := i64(Offset).Lo and ($FFFFFFFF xor (Granularity - 1));

  if (fn <> '') then begin
    case _prop_Mode of
      0: begin
           hFile := CreateFile(PChar(fn), GENERIC_READ OR GENERIC_WRITE,
                               FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
                               OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, 0); 
           hMMF := CreateFileMapping(hFile, nil, PAGE_READWRITE, 0, 0, PChar(crn));

           GetFileSizeEx(hFile, SzFile);
           Size := Granularity * CPage;
           if SzFile < Size then Size := I64(SzFile).Lo;
           if Offset < 0 then
             Offset := 0  
           else if Offset >= SzFile then
           begin
             SzOff := SzFile mod Size; 
             Offset := SzFile - SzOff;
             Size := SzOff; 
           end
           else if Offset + Size > SzFile then 
             Size := SzFile - Offset;
         end;
      1: begin
           hFile := CreateFile(PChar(fn), GENERIC_READ OR GENERIC_WRITE,
                               FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
                               OPEN_ALWAYS, FILE_FLAG_SEQUENTIAL_SCAN, 0); 
           GetFileSizeEx(hFile, SzFile);
           NewSize := SzFile + Size; 
           hMMF := CreateFileMapping(hFile, nil, PAGE_READWRITE, I64(NewSize).Hi, I64(NewSize).Lo, PChar(crn));
         end;  
    end;  
  end
  else
  begin
    Offset := 0;
    Size := Granularity * CPage;
    hMMF := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0, Size, PChar(crn));
  end;
  CloseHandle(hFile);
  _MapViewOfFile;
  _hi_CreateEvent(_Data, @_event_onOpen, integer(Size));
end;

procedure ThiSharedStream._work_doRemapping;
var
  SzOff: int64;
begin
  if (hFile = INVALID_HANDLE_VALUE) or (hMMF = 0) or (ST = nil) or (_prop_Mode = 1) then exit;
  Offset := Round(ReadReal(_Data, _data_Offset));
  i64(Offset).Lo := i64(Offset).Lo and ($FFFFFFFF xor (Granularity - 1));

  Size := Granularity * CPage;
  if SzFile < Size then Size := I64(SzFile).Lo;
  SzOff := SzFile mod Size; 
  if Offset < 0 then
    Offset := 0  
  else if Offset >= SzFile then
  begin
    Offset := SzFile - SzOff;
    Size := SzOff; 
  end
  else if Offset + Size > SzFile then 
    Size := SzFile - Offset;

  UnmapViewOfFile(ST.fMemory);
  free_and_nil(ST);
  _MapViewOfFile;
  _hi_CreateEvent(_Data, @_event_onRemapping, integer(Size));  
end;

procedure ThiSharedStream._work_doClose;
begin
  Close;
end;

procedure ThiSharedStream._work_doPosition;
begin
  if St = nil then 
    dtNull(_Data)
  else
    ST.Position := ToInteger(_data);
end;

procedure ThiSharedStream._var_Position;
begin
  if St = nil then 
    dtNull(_Data)
  else
    dtInteger(_Data, ST.Position);
end;

procedure ThiSharedStream._var_Stream;
begin
  if St = nil then 
    dtNull(_Data)
  else
    dtStream(_Data, ST)
end;

procedure ThiSharedStream._var_SizeMMF;
begin
  if St = nil then 
    dtNull(_Data)
  else
    dtInteger(_Data, ST.Size);
end;

procedure ThiSharedStream._var_FileOffset;
begin
  if (I64(Offset).Hi = 0) and (I64(Offset).Lo <= $7FFFFFFF) then
    dtInteger(_Data, I64(Offset).Lo)
  else
    dtReal(_Data, Offset);
end;

procedure ThiSharedStream._var_FileSize;
begin
  if (I64(SzFile).Hi = 0) and (I64(SzFile).Lo <= $7FFFFFFF) then
    dtInteger(_Data, I64(SzFile).Lo)
  else
    dtReal(_Data, SzFile);
end;

procedure ThiSharedStream._var_Memory;
begin
  if St = nil then 
    dtNull(_Data)
  else 
    dtInteger(_Data, integer(ST.Memory));
end;

procedure ThiSharedStream._var_Granularity;
begin
  dtInteger(_Data, Granularity);
end;

procedure ThiSharedStream._var_PageMMF;
begin
  dtInteger(_Data, CPage);
end;

procedure ThiSharedStream._var_CountFileBlock;
var
  CountBlock: int64;
begin
  CountBlock := Trunc(SzFile/(Granularity * CPage));
  if Frac(SzFile/(Granularity * CPage)) > 0 then 
    CountBlock := CountBlock + 1;  
  if (I64(CountBlock).Hi = 0) and (I64(CountBlock).Lo <= $7FFFFFFF) then
    dtInteger(_Data, I64(CountBlock).Lo)
  else
    dtReal(_Data, CountBlock);;
end;

procedure ThiSharedStream._var_CurOffsetBlock;
var
  CurOffsetBlock: int64;
begin
  CurOffsetBlock := Trunc(Offset/(Granularity * CPage));
  if Frac(Offset/(Granularity * CPage)) > 0 then 
    CurOffsetBlock := CurOffsetBlock + 1;  
  if (I64(CurOffsetBlock).Hi = 0) and (I64(CurOffsetBlock).Lo <= $7FFFFFFF) then
    dtInteger(_Data, I64(CurOffsetBlock).Lo)
  else
    dtReal(_Data, CurOffsetBlock);;
end;

procedure ThiSharedStream.Close;
begin
  if hMMF <> 0 then
  begin
    CloseHandle(hMMF);
    hMMF := 0;
  end;
  if ST = nil then exit;
  UnmapViewOfFile(ST.fMemory);
  free_and_nil(ST);
end;

end.