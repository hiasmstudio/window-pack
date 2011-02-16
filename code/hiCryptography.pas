unit hiCryptography;

interface

uses Windows,Kol,Share,Debug;

type
  HCRYPTPROV  = Cardinal;
  HCRYPTKEY   = Cardinal;
  ALG_ID      = Cardinal;
  PHCRYPTPROV = ^HCRYPTPROV;
  PHCRYPTKEY  = ^HCRYPTKEY;
  HCRYPTHASH  = Cardinal;
  PHCRYPTHASH = ^HCRYPTHASH;
  PLongWord   = ^LongWord;

type
 TThreadRec = record
   handle:cardinal;
   ss:cardinal;
   size:cardinal;     
   key:PChar;
   key_len:integer;
 end;
 PThreadRec = ^TThreadRec;
 
  THICryptography = class(TDebug)
   private
    FResult: string;
    FEvents: array of cardinal;
    procedure InitPass(var hProv: HCRYPTPROV; var hSKey: HCRYPTKEY; pass: string; alg: LongWord);
    procedure Crypt_Block_MS_Enhanced_Prov(var _Data:TData; alg: LongWord);     
    procedure DeCrypt_Block_MS_Enhanced_Prov(var _Data:TData; alg: LongWord);
   public
    _prop_Mode:byte;
    _prop_HashMode:byte;
    _prop_Key:string;

    _data_Key:THI_Event;
    _data_Data:THI_Event;
    _data_DataCrypt:THI_Event;    
    _event_onCrypt:THI_Event;
    _event_onDeCrypt:THI_Event;    

    procedure _work_doCrypt0(var _Data:TData; Index:word);
    procedure _work_doCrypt1(var _Data:TData; Index:word);
    procedure _work_doCrypt2(var _Data:TData; Index:word);
    procedure _work_doCrypt3(var _Data:TData; Index:word);
    procedure _work_doCrypt4(var _Data:TData; Index:word);
    procedure _work_doCrypt5(var _Data:TData; Index:word);                    

    procedure _work_doDeCrypt0(var _Data:TData; Index:word);
    procedure _work_doDeCrypt1(var _Data:TData; Index:word);
    procedure _work_doDeCrypt2(var _Data:TData; Index:word);
    procedure _work_doDeCrypt3(var _Data:TData; Index:word);
    procedure _work_doDeCrypt4(var _Data:TData; Index:word);
    procedure _work_doDeCrypt5(var _Data:TData; Index:word);                    

    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

function xor_proc(l:pointer):Integer; stdcall;
var mx:cardinal;
    str,ps,len:cardinal; 
begin
  Result := 0;
  mx := PThreadRec(l).size shr 2; 
  str := PThreadRec(l).ss;
  ps := cardinal(PThreadRec(l).key);
  len := PThreadRec(l).key_len;
  asm
    push ecx
    push edx
    push eax
    push esi
    push edi
    
    mov ecx, [mx]
    mov esi, [str]
    mov edx, [ps]
    xor edi, edi    
   @1:
    mov eax, [edx + edi]
    xor [esi], eax
    add esi, 4
    add edi, 4
    cmp edi, [len]
    jnz @2
    xor edi, edi
   @2: 
    loop @1
    
    pop edi 
    pop esi 
    pop eax    
    pop edx
    pop ecx
  end;
  ExitThread(0);
end;

procedure THICryptography._work_doCrypt0;
var rc:PThreadRec;
    i,c,a:integer;
    id:LongWord;
    key:string;
    lpSystemInfo:_SYSTEM_INFO;
    lst:PList;
begin
   FResult := ReadString(_Data, _data_Data);
   key := ReadString(_Data, _data_Key, _prop_Key);
   while length(key) mod 4 > 0 do
     key := key + ' ';
   a := 0;
   while length(FResult) mod 4 > 0 do
     begin
       FResult := FResult + ' ';
       inc(a);
     end;
   if length(FResult) > 64*1024 then
     begin
       GetSystemInfo(lpSystemInfo);
       c := lpSystemInfo.dwNumberOfProcessors;
     end
   else c := 1;
   lst := NewList;
   SetLength(FEvents, c);
   for i := 1 to c do
     begin
       new(rc);
       rc.ss := cardinal(@FResult[1 + (i - 1)*(length(FResult) div c)]);
       rc.size := length(FResult) div c;
       rc.key := @key[1];
       rc.key_len := length(key);
       //rc.handle := BeginThread(nil, 0, xor_proc, rc, 0, id);
       rc.handle := CreateThread(nil, 0, @xor_proc, rc, 0, id);
       FEvents[i-1] := rc.handle;
       lst.Add(rc); 
       SetThreadPriority(rc.handle, THREAD_PRIORITY_HIGHEST);
     end;
   WaitForMultipleObjects(c, PWOHandleArray(@FEvents[0]), true, cardinal(-1));
   if a > 0 then
     delete(FResult, Length(FResult) - a + 1, a);
   
   _hi_onEvent(_event_onCrypt, FResult);
   
   for i := 0 to c-1 do
     begin
       CloseHandle(FEvents[i]);
       dispose(PThreadRec(lst.Items[i]));
     end;
   lst.Free;   
end;

procedure THICryptography._work_doDeCrypt0;
begin
end;

// -------------------------------- MS CryptoAPI -------------------------------

const
  ADVAPI32            = 'advapi32.dll';
  PROV_RSA_FULL       = 1;
  CRYPT_VERIFYCONTEXT = $F0000000;
  CALG_MD2            = 32769;
  CALG_MD4            = 32770;
  CALG_MD5            = 32771;
  CALG_SHA            = 32772;
  CALG_RC2            = 26114;
  CALG_RC4            = 26625;
  CALG_RC5            = 26125;
  CALG_DES            = 26113;
  CALG_3DES_112       = 26121;
  CALG_3DES           = 26115;
  CALG_DESX           = 26116;

  MS_DEF_DH_SCHANNEL_PROV   = 'Microsoft DH Schannel Cryptographic Provider'; 
  MS_DEF_DSS_DH_PROV        = 'Microsoft Base DSS and Diffie-Hellman Cryptographic Provider'; 
  MS_DEF_DSS_PROV           = 'Microsoft Base DSS Cryptographic Provider'; 
  MS_DEF_PROV               = 'Microsoft Base Cryptographic Provider v1.0'; 
  MS_DEF_RSA_SCHANNEL_PROV  = 'Microsoft RSA Schannel Cryptographic Provider'; 
  MS_DEF_RSA_SIG_PROV       = 'Microsoft RSA Signature Cryptographic Provider'; 
  MS_ENH_DSS_DH_PROV        = 'Microsoft Enhanced DSS and Diffie-Hellman Cryptographic Provider'; 
  MS_ENH_RSA_AES_PROV       = 'Microsoft Enhanced RSA and AES Cryptographic Provider'; 
  MS_ENHANCED_PROV          = 'Microsoft Enhanced Cryptographic Provider v1.0'; 
  MS_SCARD_PROV             = 'Microsoft Base Smart Card Crypto Provider'; 
  MS_STRONG_PROV            = 'Microsoft Strong Cryptographic Provider';
 
  BufferLength        = 64;
 
function CryptReleaseContext(hProv: HCRYPTPROV; dwFlags: LongWord): LongBool; stdcall; external ADVAPI32 name 'CryptReleaseContext';
function CryptAcquireContext(Prov: PHCRYPTPROV; Container: PChar; Provider: PChar; ProvType: LongWord; Flags: LongWord): LongBool; stdcall; external ADVAPI32 name 'CryptAcquireContextA';
function CryptEncrypt(Key: HCRYPTKEY; Hash: HCRYPTHASH; Final: LongBool; Flags: LongWord; Data: PChar; Len: PLongWord; BufLen: LongWord): LongBool;stdcall;external ADVAPI32 name 'CryptEncrypt';
function CryptDecrypt(Key: HCRYPTKEY; Hash: HCRYPTHASH; Final: LongBool; Flags: LongWord; Data: PChar; Len: PLongWord): LongBool; stdcall; external ADVAPI32 name 'CryptDecrypt';
function CryptCreateHash(Prov: HCRYPTPROV; Algid: ALG_ID; Key:HCRYPTKEY; Flags: LongInt; Hash: PHCRYPTHASH): LongBool; stdcall; external ADVAPI32 name 'CryptCreateHash';
function CryptHashData(Hash: HCRYPTHASH; Data: PChar; DataLen: LongInt; Flags: LongInt): LongBool; stdcall; external ADVAPI32 name 'CryptHashData';
function CryptDeriveKey(Prov: HCRYPTPROV; Algid: ALG_ID; BaseData: HCRYPTHASH; Flags: LongInt; Key: PHCRYPTKEY): LongBool; stdcall; external ADVAPI32 name 'CryptDeriveKey';
function CryptDestroyHash(hHash: HCRYPTHASH): LongBool; stdcall; external ADVAPI32 name 'CryptDestroyHash';
function CryptDestroyKey(hKey: HCRYPTKEY): LongBool; stdcall; external ADVAPI32 name 'CryptDestroyKey';

procedure THICryptography.InitPass;
var
  hash: HCRYPTHASH;
  hashalg: LongWord;  
begin
  Case _prop_HashMode of
    0: hashalg := CALG_MD2;
    1: hashalg := CALG_MD4;
    2: hashalg := CALG_MD5;
    3: hashalg := CALG_SHA;        
  end;
  CryptAcquireContext(@hProv, nil, MS_ENHANCED_PROV, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT);
  CryptCreateHash(hProv, hashalg, 0, 0, @hash);
  CryptHashData(hash, @pass[1], length(pass), 0);
  CryptDeriveKey(hProv, alg, hash, 0, @hSKey);
  CryptDestroyHash(hash);
end;

procedure THICryptography.Crypt_Block_MS_Enhanced_Prov; // Block Algorithm
var
  CountBlock, i, l, sz: LongWord;
  s, pass: string; 
  hProv: HCRYPTPROV;
  hSKey: HCRYPTKEY;
begin
  s := ReadString(_Data, _data_Data) + #0;
  SetLength(s, Length(s) - 1);
  pass := ReadString(_Data, _data_Key, _prop_Key);
  
  InitPass(hProv, hSKey, pass, alg);
    
  sz := Length(s);
  CountBlock := (sz + 8) div BufferLength;
  if (sz + 8) mod BufferLength > 0 then CountBlock := CountBlock + 1;
  
  SetLength(s, CountBlock * BufferLength);
  SetLength(FResult, CountBlock * BufferLength);
  l := BufferLength;

  for i := 1 to CountBlock do
  begin
    CryptEncrypt(hSKey, 0, false, 0, @s[(i - 1) * BufferLength + 1], @l, BufferLength);
    move(s[(i - 1) * BufferLength + 1], FResult[(i - 1) * BufferLength + 1], BufferLength);
  end;  
  CryptDestroyKey(hSKey);
  CryptReleaseContext(hProv, 0);
  
  SetLength(FResult, (sz + 8));
  _hi_CreateEvent(_Data, @_event_onCrypt, FResult);
end;

procedure THICryptography.DeCrypt_Block_MS_Enhanced_Prov; // Block Algorithm
var
  CountBlock, i, l, sz: LongWord;
  s, pass: string; 
  hProv: HCRYPTPROV;
  hSKey: HCRYPTKEY;
begin
  s := ReadString(_Data, _data_DataCrypt) + #0;
  SetLength(s, Length(s) - 1);
  pass := ReadString(_Data, _data_Key, _prop_Key);

  InitPass(hProv, hSKey, pass, alg);

  sz := Length(s);
  CountBlock := sz div BufferLength;
  if sz mod BufferLength > 0 then CountBlock := CountBlock + 1;

  SetLength(s, CountBlock * BufferLength);
  SetLength(FResult, CountBlock * BufferLength);
  l := BufferLength;

  for i := 1 to CountBlock do
  begin
    CryptDecrypt(hSKey, 0, false, 0, @s[(i - 1) * BufferLength + 1], @l);
    move(s[(i - 1) * BufferLength + 1], FResult[(i - 1) * BufferLength + 1], BufferLength);
  end;  
  CryptDestroyKey(hSKey);
  CryptReleaseContext(hProv, 0);
  
  SetLength(FResult, sz);
  _hi_CreateEvent(_Data, @_event_onDeCrypt, FResult);

end;

procedure THICryptography._work_doCrypt1; // RC2
begin
  Crypt_Block_MS_Enhanced_Prov(_Data, CALG_RC2);
end;

procedure THICryptography._work_doCrypt2; // RC4 (Stream Algorithm)
var
  sz: LongWord;
  s, pass: string; 
  hProv: HCRYPTPROV;
  hSKey: HCRYPTKEY;
begin
  s := ReadString(_Data, _data_Data) + #0;
  SetLength(s, Length(s) - 1);
  pass := ReadString(_Data, _data_Key, _prop_Key);

  InitPass(hProv, hSKey, pass, CALG_RC4);

  sz := Length(s);
  SetLength(FResult, sz);
  CryptEncrypt(hSKey, 0, true, 0, @s[1], @sz, sz);
  move(s[1], FResult[1], sz);

  CryptDestroyKey(hSKey);
  CryptReleaseContext(hProv, 0);

  _hi_CreateEvent(_Data, @_event_onCrypt, FResult);
end;

procedure THICryptography._work_doCrypt3; // DES_56
begin
  Crypt_Block_MS_Enhanced_Prov(_Data, CALG_DES);
end;

procedure THICryptography._work_doCrypt4; // 3DES_112
begin
  Crypt_Block_MS_Enhanced_Prov(_Data, CALG_3DES_112);
end;

procedure THICryptography._work_doCrypt5; // 3DES_168
begin
  Crypt_Block_MS_Enhanced_Prov(_Data, CALG_3DES);
end;

procedure THICryptography._work_doDeCrypt1; // RC2
begin
  DeCrypt_Block_MS_Enhanced_Prov(_Data, CALG_RC2);
end;

procedure THICryptography._work_doDeCrypt2; // RC4 (Stream Algorithm)
var
  sz: LongWord;
  s, pass: string; 
  hProv: HCRYPTPROV;
  hSKey: HCRYPTKEY;
begin
  s := ReadString(_Data, _data_DataCrypt) + #0;
  SetLength(s, Length(s) - 1);
  pass := ReadString(_Data, _data_Key, _prop_Key);

  InitPass(hProv, hSKey, pass, CALG_RC4);

  sz := Length(s);
  SetLength(FResult, sz);
  CryptDecrypt(hSKey, 0, true, 0, @s[1], @sz);
  move(s[1], FResult[1], sz);

  CryptDestroyKey(hSKey);
  CryptReleaseContext(hProv, 0);

  _hi_CreateEvent(_Data, @_event_onDeCrypt, FResult);
end;

procedure THICryptography._work_doDeCrypt3; // DES_56
begin
  DeCrypt_Block_MS_Enhanced_Prov(_Data, CALG_DES);
end;

procedure THICryptography._work_doDeCrypt4;
begin
  DeCrypt_Block_MS_Enhanced_Prov(_Data, CALG_3DES_112); // 3DES_112
end;

procedure THICryptography._work_doDeCrypt5;
begin
  DeCrypt_Block_MS_Enhanced_Prov(_Data, CALG_3DES); // 3DES_168
end;

procedure THICryptography._var_Result;
begin
   dtString(_Data, FResult);
end;

end.
