unit CryptoAPI{v 1.02};
{(C) Coban (alex@ritlabs.com)}
{Checkout http://soho.net.md for updates}

{!!should be defined at least one algorithm}
{$DEFINE INCLUDE_SHA}           //Include SHA1, SHA256, SHA384, SHA512
{$DEFINE INCLUDE_FUTILS}

{-------------------------------------------------------------------------------}

interface

uses
  {$IFDEF INCLUDE_SHA}    SHA,    {$ENDIF}
  Windows,
  CryptoUtils;

const
  HASH_INITIAL     = $100;              //Initial constant

  {Hash types}
  {$IFDEF INCLUDE_MD}
  HASH_MD2         = HASH_INITIAL + $1;
  HASH_MD4         = HASH_INITIAL + $2;
  HASH_MD5         = HASH_INITIAL + $3;
  {$ENDIF}
  {$IFDEF INCLUDE_CRC}
  HASH_CRC32       = HASH_INITIAL + $4;
  HASH_CRC32B      = HASH_INITIAL + $5;
  {$ENDIF}
  {$IFDEF INCLUDE_ADLER}
  HASH_ADLER32     = HASH_INITIAL + $6;
  {$ENDIF}
  {$IFDEF INCLUDE_GOST}
  HASH_GOST        = HASH_INITIAL + $7;
  {$ENDIF}
  {$IFDEF INCLUDE_HAVAL}
  HASH_HAVAL128     = HASH_INITIAL + $8;
  HASH_HAVAL160     = HASH_INITIAL + $9;
  HASH_HAVAL192     = HASH_INITIAL + $A;
  HASH_HAVAL224     = HASH_INITIAL + $B;
  HASH_HAVAL256     = HASH_INITIAL + $C;
  {$ENDIF}
  {$IFDEF INCLUDE_SHA}
  HASH_SHA1         = HASH_INITIAL + $D;
  HASH_SHA256       = HASH_INITIAL + $E;
  HASH_SHA384       = HASH_INITIAL + $F;
  HASH_SHA512       = HASH_INITIAL + $10;
  {$ENDIF}
  {$IFDEF INCLUDE_TIGER}
  HASH_TIGER128     = HASH_INITIAL + $11;
  HASH_TIGER160     = HASH_INITIAL + $12;
  HASH_TIGER192     = HASH_INITIAL + $13;
  {$ENDIF}
  {$IFDEF INCLUDE_RMD}
  HASH_RIPEMD128    = HASH_INITIAL + $14;
  HASH_RIPEMD160    = HASH_INITIAL + $15;
  {$ENDIF}


  {Errors}
  HASH_NOERROR     = 0;
  HASH_UNK_TYPE    = HASH_NOERROR + $1;  //Unknown hash type
  HASH_NIL_CONTEXT = HASH_NOERROR + $2;  //Context unallocated
  HASH_INV_CONTEXT = HASH_NOERROR + $3;  //Invalid hash context
  HASH_FR_ERROR    = HASH_NOERROR + $4;  //File read error
  HASH_FO_ERROR    = HASH_NOERROR + $5;  //File open error
  HASH_TEST_FAILED = HASH_NOERROR + $6;  //Hash test error

  

  {Current ammount of hash algorithms}
  HASH_MAX_TYPES   =
  {$IFDEF INCLUDE_MD}           3 + {$ENDIF}
  {$IFDEF INCLUDE_CRC}          2 + {$ENDIF}
  {$IFDEF INCLUDE_ADLER}        1 + {$ENDIF}
  {$IFDEF INCLUDE_GOST}         1 + {$ENDIF}
  {$IFDEF INCLUDE_HAVAL}        5 + {$ENDIF}
  {$IFDEF INCLUDE_SHA}          4 + {$ENDIF}
  {$IFDEF INCLUDE_TIGER}        3 + {$ENDIF}
  {$IFDEF INCLUDE_RMD}          2 + {$ENDIF}
  0;




type
  {Hash context}
  PHashContext = ^THashContext;
  THashContext = record
    IntData: Pointer;      {Reserved for internal use}
    HashType: LongWord;    {Hash type}
    lParam: LongWord;      {First Param}
    wParam: LongWord;      {Second Param}
  end;

  {Low-level hash functions}
  function HashInit(Context: PHashContext; HashType: LongWord): LongWord;
  function HashUpdate(Context: PHashContext; SrcBuf: Pointer; BufLen: LongWord): LongWord;
  function HashFinal(Context: PHashContext; var DestHash: String): LongWord;

  {High-level hash functions}
  function HashStr(HashType: LongWord; SrcStr: String; var DestHash: String): LongWord;
  function HashBuf(HashType: LongWord; SrcBuf: Pointer; BufLen: LongWord; var DestHash: String): LongWord;

  {$IFDEF INCLUDE_FUTILS}
  {File functions}
  function HashFile(HashType: LongWord; FileName: String; var DestHash: String): LongWord;
  function HashFilePartial(HashType: LongWord; FileName: String; FlOffsetLow, FlOffsetHigh: LongWord; var DestHash: String): LongWord;
  {$ENDIF}

  {Misc. functions}
  function HashErrorToStr(Error: LongWord): String;
  function EnumHashTypes(StoreToArr: Pointer; MaxItems: LongWord): LongWord;

implementation

function HashInit(Context: PHashContext; HashType: LongWord): LongWord;
begin
  if Context = nil then
  begin
    Result := HASH_NIL_CONTEXT;
    Exit;
  end;
  Context^.HashType := HashType;
  Result := HASH_NOERROR;
  case HashType of
    {$IFDEF INCLUDE_SHA}
    HASH_SHA1, HASH_SHA256:
    begin
      GetMem(Context^.IntData, SizeOf(TSHA256Ctx));
      if HashType = HASH_SHA1 then
        SHA1Init(PSHA256Ctx(Context^.IntData)^)
      else
        SHA256Init(PSHA256Ctx(Context^.IntData)^);
    end;
    HASH_SHA384, HASH_SHA512:
    begin
      GetMem(Context^.IntData, SizeOf(TSHA512Ctx));
      if HashType = HASH_SHA384 then
        SHA384Init(PSHA512Ctx(Context^.IntData)^)
      else
        SHA512Init(PSHA512Ctx(Context^.IntData)^);
    end;
    {$ENDIF}
    else
      Result := HASH_UNK_TYPE;
  end;
end;

function HashUpdate(Context: PHashContext; SrcBuf: Pointer; BufLen: LongWord): LongWord;
begin
  Result := HASH_NOERROR;
  if Context = nil then
  begin
    Result := HASH_NIL_CONTEXT;
    Exit;
  end;
  if Context^.IntData = nil then
  begin
    Result := HASH_INV_CONTEXT;
    Exit;
  end;
  case Context^.HashType of
    {$IFDEF INCLUDE_SHA}
    HASH_SHA1: SHA256Update(PSHA256Ctx(Context^.IntData)^, SrcBuf, BufLen, 1);
    HASH_SHA256: SHA256Update(PSHA256Ctx(Context^.IntData)^, SrcBuf, BufLen, 256);
    HASH_SHA384, HASH_SHA512: SHA512Update(PSHA512Ctx(Context^.IntData)^, SrcBuf, BufLen);
    {$ENDIF}
    else
      Result := HASH_UNK_TYPE;
  end;
end;

function HashFinal(Context: PHashContext; var DestHash: String): LongWord;
begin
  if Context = nil then
  begin
    Result := HASH_NIL_CONTEXT;
    Exit;
  end;
  Result := HASH_NOERROR;
  case Context^.HashType of
    {$IFDEF INCLUDE_CRC}
    HASH_CRC32, HASH_CRC32B:
    begin
      DestHash := CRC32Final(PLongWord(Context^.IntData)^);
      FreeMem(Context^.IntData, SizeOf(LongWord));
      Context^.IntData := nil;
    end;
    {$ENDIF}
    {$IFDEF INCLUDE_ADLER}
    HASH_ADLER32:
    begin
      DestHash := Adler32Final(PLongWord(Context^.IntData)^);
      FreeMem(Context^.IntData, SizeOf(LongWord));
      Context^.IntData := nil;
    end;
    {$ENDIF}
    {$IFDEF INCLUDE_GOST}
    HASH_GOST:
    begin
      DestHash := GostFinal(PGostCtx(Context^.IntData)^);
      FreeMem(Context^.IntData, SizeOf(TGostCtx));
      Context^.IntData := nil;
    end;
    {$ENDIF}
    {$IFDEF INCLUDE_HAVAL}
    HASH_HAVAL128, HASH_HAVAL160, HASH_HAVAL192, HASH_HAVAL224, HASH_HAVAL256:
    begin
      case Context^.HashType of
        HASH_HAVAL128: DestHash := HavalFinal(PHavalCtx(Context^.IntData)^, Context^.lParam, 128);
        HASH_HAVAL160: DestHash := HavalFinal(PHavalCtx(Context^.IntData)^, Context^.lParam, 160);
        HASH_HAVAL192: DestHash := HavalFinal(PHavalCtx(Context^.IntData)^, Context^.lParam, 192);
        HASH_HAVAL224: DestHash := HavalFinal(PHavalCtx(Context^.IntData)^, Context^.lParam, 224);
        HASH_HAVAL256: DestHash := HavalFinal(PHavalCtx(Context^.IntData)^, Context^.lParam, 256);
      end;
      FreeMem(Context^.IntData, SizeOf(THavalCtx));
      Context^.IntData := nil;
    end;
    {$ENDIF}
    {$IFDEF INCLUDE_SHA}
    HASH_SHA1, HASH_SHA256:
    begin
      if Context^.HashType = HASH_SHA1 then
        DestHash := SHA256Final(PSHA256Ctx(Context^.IntData)^, 1)
      else
        DestHash := SHA256Final(PSHA256Ctx(Context^.IntData)^, 256);
      FreeMem(Context^.IntData, SizeOf(TSHA256Ctx));
      Context^.IntData := nil;
    end;
    HASH_SHA384, HASH_SHA512:
    begin
      if Context^.HashType = HASH_SHA384 then
        DestHash := SHA512Final(PSHA512Ctx(Context^.IntData)^, 384)
      else
        DestHash := SHA512Final(PSHA512Ctx(Context^.IntData)^, 512);
      FreeMem(Context^.IntData, SizeOf(TSHA512Ctx));
      Context^.IntData := nil;
    end;
    {$ENDIF}
    {$IFDEF INCLUDE_TIGER}
    HASH_TIGER128, HASH_TIGER160, HASH_TIGER192:
    begin
      case Context^.HashType of
        HASH_TIGER128: DestHash := TigerFinal(PTigerCtx(Context^.IntData)^, 128, Context^.lParam);
        HASH_TIGER160: DestHash := TigerFinal(PTigerCtx(Context^.IntData)^, 160, Context^.lParam);
        HASH_TIGER192: DestHash := TigerFinal(PTigerCtx(Context^.IntData)^, 192, Context^.lParam);
      end;
      FreeMem(Context^.IntData, SizeOf(TTigerCtx));
      Context^.IntData := nil;
    end;
    {$ENDIF}
    {$IFDEF INCLUDE_RMD}
    HASH_RIPEMD128, HASH_RIPEMD160:
    begin
      if Context^.HashType = HASH_RIPEMD128 then
        DestHash := RMDFinal(PRMDCtx(Context^.IntData)^, 128)
      else
        DestHash := RMDFinal(PRMDCtx(Context^.IntData)^, 160);
      FreeMem(Context^.IntData, SizeOf(TRMDCtx));        
    end;
    {$ENDIF}    
    else
      Result := HASH_UNK_TYPE;
  end;
end;

function HashStr(HashType: LongWord; SrcStr: String; var DestHash: String): LongWord;
var
  ctx: THashContext;
begin
  Result := HashInit(@ctx, HashType);
  if Result = HASH_NOERROR then
    Result := HashUpdate(@ctx, PChar(SrcStr), Length(SrcStr));
  if Result = HASH_NOERROR then
    Result := HashFinal(@ctx, DestHash);
end;

function HashBuf(HashType: LongWord; SrcBuf: Pointer; BufLen: LongWord; var DestHash: String): LongWord;
var
  ctx: THashContext;
begin
  Result := HashInit(@ctx, HashType);
  if Result = HASH_NOERROR then
    Result := HashUpdate(@ctx, SrcBuf, BufLen);
  if Result = HASH_NOERROR then
    Result := HashFinal(@ctx, DestHash);
end;

{$IFDEF INCLUDE_FUTILS}
function _GetFileSize(const FName: String): LongWord;
var
  FileHandle: THandle;
begin
  Result := INVALID_FILE_SIZE;
  FileHandle := CreateFile(PChar(FName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if FileHandle = INVALID_HANDLE_VALUE then Exit;
  Result := GetFileSize(FileHandle, nil);
  CloseHandle(FileHandle);
end;

{Thanks to Dr. Jurgen B. Kehrel for fixing the bugs}
function _HashFilePartial(ctx: PHashContext; FileName: String; offset1, offset2: LongWord): Boolean;
var
  FileHandle: THandle;
  buf: array[0..4095] of Char;  //Read buffer, could be modified
  read, fread: LongWord;
begin
  Result := False;
  FileHandle := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if FileHandle = INVALID_HANDLE_VALUE then Exit;
  if SetFilePointer(FileHandle, offset1, nil, 0) = LongWord(-1) then 
  begin
    CloseHandle(FileHandle);
    Exit;
  end;
  ReadFile(FileHandle, buf, SizeOf(buf), read, nil);
  fread := offset1 + read; if read < 1 then
  begin
    CloseHandle(FileHandle);
    Exit;
  end;
  if read + offset1 >= offset2 then
    HashUpdate(ctx, @buf, offset2 - offset1)
  else
    while ReadFile(FileHandle, buf, SizeOf(buf), read, nil) do
    begin
      Inc(fread, read);
      if read < 1 then
        Break
      else
      begin
        if fread > offset2 then
        begin
          HashUpdate(ctx, @buf, read + offset2 - fread);
          Break;
        end
        else
          HashUpdate(ctx, @buf, read)
      end;
  end;
  CloseHandle(FileHandle);
  Result := True;
end;

function HashFile(HashType: LongWord; FileName: String; var DestHash: String): LongWord;
var
  ctx: THashContext;
  fsz: LongWord;
begin
  FillChar(ctx, SizeOf(ctx), 0);
  fsz := _GetFileSize(FileName);
  if fsz = INVALID_FILE_SIZE then
  begin
    Result := HASH_FO_ERROR;
    Exit;
  end;
  Result := HashInit(@ctx, HashType);
  if Result = NO_ERROR then
    if not _HashFilePartial(@ctx, FileName, 0, _GetFileSize(FileName)) then
       Result := HASH_FR_ERROR;
  if Result = NO_ERROR then
    Result := HashFinal(@ctx, DestHash);
end;

function HashFilePartial(HashType: LongWord; FileName: String; FlOffsetLow, FlOffsetHigh: LongWord; var DestHash: String): LongWord;
var
  ctx: THashContext;
  fsz: LongWord;
begin
  FillChar(ctx, SizeOf(ctx), 0);
  fsz := _GetFileSize(FileName);
  if fsz = INVALID_FILE_SIZE then
  begin
    Result := HASH_FO_ERROR;
    Exit;
  end;
  Result := HashInit(@ctx, HashType);
  if FlOffsetHigh >= fsz then
    FlOffsetHigh := fsz - 1;
  if Result = NO_ERROR then
    if not _HashFilePartial(@ctx, FileName, FlOffsetLow, FlOffsetHigh + 1) then
       Result := HASH_FR_ERROR;
  if Result = NO_ERROR then
    Result := HashFinal(@ctx, DestHash);
end;
{$ENDIF}

function EnumHashTypes(StoreToArr: Pointer; MaxItems: LongWord): LongWord;
  procedure AddToEnum(Value: LongWord; var Count: LongWord);
  begin
    if Count >= MaxItems then Exit;
    PDWordArray(StoreToArr)^[Count] := Value;
    Inc(Count);
  end;
begin
  Result := 0;
  if MaxItems = 0 then
    Exit;
  if MaxItems > HASH_MAX_TYPES then
    MaxItems := HASH_MAX_TYPES;
  {$IFDEF INCLUDE_MD}
  AddToEnum(HASH_MD2, Result);
  AddToEnum(HASH_MD4, Result);
  AddToEnum(HASH_MD5, Result);
  {$ENDIF}
  {$IFDEF INCLUDE_CRC}
  AddToEnum(HASH_CRC32, Result);
  AddToEnum(HASH_CRC32B, Result);
  {$ENDIF}
  {$IFDEF INCLUDE_ADLER}
  AddToEnum(HASH_ADLER32, Result);
  {$ENDIF}
  {$IFDEF INCLUDE_GOST}
  AddToEnum(HASH_GOST, Result);
  {$ENDIF}
  {$IFDEF INCLUDE_HAVAL}
  AddToEnum(HASH_HAVAL128, Result);
  AddToEnum(HASH_HAVAL160, Result);
  AddToEnum(HASH_HAVAL192, Result);
  AddToEnum(HASH_HAVAL224, Result);
  AddToEnum(HASH_HAVAL256, Result);
  {$ENDIF}
  {$IFDEF INCLUDE_SHA}
  AddToEnum(HASH_SHA1, Result);
  AddToEnum(HASH_SHA256, Result);
  AddToEnum(HASH_SHA384, Result);
  AddToEnum(HASH_SHA512, Result);
  {$ENDIF}
  {$IFDEF INCLUDE_TIGER}
  AddToEnum(HASH_TIGER128, Result);
  AddToEnum(HASH_TIGER160, Result);
  AddToEnum(HASH_TIGER192, Result);
  {$ENDIF}
  {$IFDEF INCLUDE_RMD}
  AddToEnum(HASH_RIPEMD128, Result);
  AddToEnum(HASH_RIPEMD160, Result);
  {$ENDIF}
end;

function HashErrorToStr(Error: LongWord): String;
begin
  case Error of
    HASH_NOERROR: Result := 'No error';
    HASH_UNK_TYPE: Result := 'Unknown hash type';
    HASH_NIL_CONTEXT: Result := 'Hash context is null';
    HASH_INV_CONTEXT: Result := 'Invalid hash context';
    HASH_FR_ERROR: Result := 'Could not read file';
    HASH_FO_ERROR: Result := 'Could not open file';
    HASH_TEST_FAILED: Result := 'Hash test failed';    
  else
    Result := 'Unknown error';
  end;
end;

end.

