unit hiCryptography;

interface

uses Windows, Kol, Share, Debug, MSCryptoAPI;

const
  CRYPT_MODE   = 0;
  DECRYPT_MODE = 1;
  
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
    function InitPass(var hProv: HCRYPTPROV; var hSKey: HCRYPTKEY; pass: string; alg: LongWord; Provider: PChar; ProvType: LongWord): Integer;
    procedure CryptXOR(var _Data:TData; Mode: Byte);
    procedure Crypt_Decrypt_MS_Prov(var _Data:TData; alg: LongWord; Mode: Byte; Provider: PChar; ProvType: LongWord);     
   public
    _prop_Mode:byte;
    _prop_HashMode:byte;
    _prop_Key:string;

    _data_Key:THI_Event;
    _data_Data:THI_Event;
    _data_DataCrypt:THI_Event;    
    _event_onCrypt:THI_Event;
    _event_onDeCrypt:THI_Event;
    _event_onError:THI_Event;        

    procedure _work_doCrypt0(var _Data:TData; Index:word);  // XOR
    procedure _work_doCrypt1(var _Data:TData; Index:word);  // RC2
    procedure _work_doCrypt2(var _Data:TData; Index:word);  // RC4
    procedure _work_doCrypt3(var _Data:TData; Index:word);  // DES56
    procedure _work_doCrypt4(var _Data:TData; Index:word);  // 3DES112
    procedure _work_doCrypt5(var _Data:TData; Index:word);  // 3DES168                    
    procedure _work_doCrypt6(var _Data:TData; Index:word);  // AES128    
    procedure _work_doCrypt7(var _Data:TData; Index:word);  // AES192
    procedure _work_doCrypt8(var _Data:TData; Index:word);  // AES256        
    procedure _work_doCrypt9(var _Data:TData; Index:word);  // CYLINK_MEK        

    procedure _work_doDeCrypt0(var _Data:TData; Index:word);  // XOR
    procedure _work_doDeCrypt1(var _Data:TData; Index:word);  // RC2
    procedure _work_doDeCrypt2(var _Data:TData; Index:word);  // RC4
    procedure _work_doDeCrypt3(var _Data:TData; Index:word);  // DES56
    procedure _work_doDeCrypt4(var _Data:TData; Index:word);  // 3DES112
    procedure _work_doDeCrypt5(var _Data:TData; Index:word);  // 3DES168                    
    procedure _work_doDeCrypt6(var _Data:TData; Index:word);  // AES128    
    procedure _work_doDeCrypt7(var _Data:TData; Index:word);  // AES192
    procedure _work_doDeCrypt8(var _Data:TData; Index:word);  // AES256        
    procedure _work_doDeCrypt9(var _Data:TData; Index:word);  // CYLINK_MEK        


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

procedure THICryptography.CryptXOR;
var rc:PThreadRec;
    i,c,a:integer;
    id:LongWord;
    key:string;
    lpSystemInfo:_SYSTEM_INFO;
    lst:PList;
begin
   Case Mode of
     0: FResult := ReadString(_Data, _data_Data);
     1: FResult := ReadString(_Data, _data_DataCrypt);
   end;       

   key := ReadString(_Data, _data_Key, _prop_Key);
   if length(key) = 0 then
   begin
     _hi_CreateEvent(_Data, @_event_onError, ERROR_INCORRECT_KEY);
     exit;  
   end;
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

   Case Mode of
     0: _hi_onEvent(_event_onCrypt, FResult);
     1: _hi_onEvent(_event_onDeCrypt, FResult);
   end;

   for i := 0 to c-1 do
     begin
       CloseHandle(FEvents[i]);
       dispose(PThreadRec(lst.Items[i]));
     end;
   lst.Free;   

end;

procedure THICryptography._work_doCrypt0;
begin
  CryptXOR(_Data, CRYPT_MODE);
end;

procedure THICryptography._work_doDeCrypt0;
begin
  CryptXOR(_Data, DECRYPT_MODE);
end;

// ============================================ MS CryptoAPI ==========================================

function THICryptography.InitPass;
var
  hash: HCRYPTHASH;
  hashalg: LongWord;  
begin
  hash := 0;
  Case _prop_HashMode of
    0: hashalg := CALG_MD5;
    1: hashalg := CALG_SHA;
    else
       hashalg := CALG_SHA;            
  end;

  Result := NO_ERROR;
  if CryptAcquireContext(@hProv, nil, Provider, ProvType, CRYPT_VERIFYCONTEXT) then
  begin
    if CryptCreateHash(hProv, hashalg, 0, 0, @hash) then
    begin
      if CryptHashData(hash, @pass[1], length(pass), 0) then
      begin
        if not CryptDeriveKey(hProv, alg, hash, 0, @hSKey) then
          Result := ERROR_DERIVE_KEY
      end    
      else
        Result := ERROR_HASH_DATA
    end      
    else
      Result := ERROR_CREATE_HASH
  end    
  else  
    Result := ERROR_ACQUIRE_CONTEXT;
  if hash <> 0 then CryptDestroyHash(hash);
end;

procedure THICryptography.Crypt_Decrypt_MS_Prov; // Universal Algorithm
var
  ln, sz: LongWord;
  pass: string; 
  hProv: HCRYPTPROV;
  hSKey: HCRYPTKEY;
  Err: integer;
begin
  hSKey := 0;
  hProv := 0;
  Err := NO_ERROR;
TRY
  Case Mode of
    0: FResult := ReadString(_Data, _data_Data) + #0;
    1: FResult := ReadString(_Data, _data_DataCrypt) + #0;
  end;  

  SetLength(FResult, Length(FResult) - 1); 
  sz := Length(FResult);
  pass := ReadString(_Data, _data_Key, _prop_Key);
  if length(pass) = 0 then
  begin
    Err := ERROR_INCORRECT_KEY;
    exit;  
  end; 
  Err := InitPass(hProv, hSKey, pass, alg, Provider, ProvType);
  if Err <> NO_ERROR then exit;

  Case Mode of
    0: begin
         ln := sz;
         CryptEncrypt(hSKey, 0, true, 0, @FResult[1], @ln, sz);
         if GetLastError = ERROR_MORE_DATA then
         begin
           SetLength(FResult, ln);
           CryptEncrypt(hSKey, 0, true, 0, @FResult[1], @sz, ln);
         end
         else
           Err := ERROR_ENCRYPT;
       end;
    1: if not CryptDecrypt(hSKey, 0, true, 0, @FResult[1], @sz) then
         Err := ERROR_DECRYPT;
  end;     

  SetLength(FResult, sz);
  if Err <> NO_ERROR then exit;

  Case Mode of
    0: _hi_onEvent(_event_onCrypt, FResult);
    1: _hi_onEvent(_event_onDeCrypt, FResult);
  end;  

FINALLY
  if hSKey <> 0 then CryptDestroyKey(hSKey);
  if hProv <> 0 then CryptReleaseContext(hProv, 0);

  if Err <> NO_ERROR then
    _hi_CreateEvent(_Data, @_event_onError, Err);
END;    
end;

//-------------------------------------------- Crypt ---------------------------------------------------

procedure THICryptography._work_doCrypt1; // RC2
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_RC2, CRYPT_MODE, MS_ENHANCED_PROV, PROV_RSA_FULL);
end;

procedure THICryptography._work_doCrypt2; // RC4
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_RC4, CRYPT_MODE, MS_ENHANCED_PROV, PROV_RSA_FULL);  
end;

procedure THICryptography._work_doCrypt3; // DES56
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_DES, CRYPT_MODE, MS_ENHANCED_PROV, PROV_RSA_FULL);
end;

procedure THICryptography._work_doCrypt4; // 3DES112
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_3DES_112, CRYPT_MODE, MS_ENHANCED_PROV, PROV_RSA_FULL);
end;

procedure THICryptography._work_doCrypt5; // 3DES168
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_3DES, CRYPT_MODE, MS_ENHANCED_PROV, PROV_RSA_FULL);
end;

procedure THICryptography._work_doCrypt6; // AES128
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_AES_128, CRYPT_MODE, MS_ENH_RSA_AES_PROV, PROV_RSA_AES);
end;

procedure THICryptography._work_doCrypt7; // AES192
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_AES_192, CRYPT_MODE, MS_ENH_RSA_AES_PROV, PROV_RSA_AES);
end;

procedure THICryptography._work_doCrypt8; // AES256
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_AES_256, CRYPT_MODE, MS_ENH_RSA_AES_PROV, PROV_RSA_AES);
end;

procedure THICryptography._work_doCrypt9; // CYLINK_MEK
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_CYLINK_MEK, CRYPT_MODE, MS_DEF_DH_SCHANNEL_PROV, PROV_DH_SCHANNEL);
end;

//-------------------------------------------- DeCrypt ---------------------------------------------------

procedure THICryptography._work_doDeCrypt1; // RC2
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_RC2, DECRYPT_MODE, MS_ENHANCED_PROV, PROV_RSA_FULL);
end;

procedure THICryptography._work_doDeCrypt2; // RC4
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_RC4, DECRYPT_MODE, MS_ENHANCED_PROV, PROV_RSA_FULL);  
end;

procedure THICryptography._work_doDeCrypt3; // DES56
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_DES, DECRYPT_MODE, MS_ENHANCED_PROV, PROV_RSA_FULL);
end;

procedure THICryptography._work_doDeCrypt4; // 3DES112
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_3DES_112, DECRYPT_MODE, MS_ENHANCED_PROV, PROV_RSA_FULL);
end;

procedure THICryptography._work_doDeCrypt5; // 3DES168
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_3DES, DECRYPT_MODE, MS_ENHANCED_PROV, PROV_RSA_FULL);
end;

procedure THICryptography._work_doDeCrypt6; // AES128
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_AES_128, DECRYPT_MODE, MS_ENH_RSA_AES_PROV, PROV_RSA_AES);
end;

procedure THICryptography._work_doDeCrypt7; // AES192
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_AES_192, DECRYPT_MODE, MS_ENH_RSA_AES_PROV, PROV_RSA_AES);
end;

procedure THICryptography._work_doDeCrypt8; // AES256
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_AES_256, DECRYPT_MODE, MS_ENH_RSA_AES_PROV, PROV_RSA_AES);
end;

procedure THICryptography._work_doDeCrypt9; // CYLINK_MEK
begin
  Crypt_Decrypt_MS_Prov(_Data, CALG_CYLINK_MEK, DECRYPT_MODE, MS_DEF_DH_SCHANNEL_PROV, PROV_DH_SCHANNEL);
end;

procedure THICryptography._var_Result;
begin
   dtString(_Data, FResult);
end;

end.
