unit hiEnCrypt;

interface

uses Windows, Kol, Share, Debug, MSCryptoAPI;

type
  THIEnCrypt = class(TDebug)
   private
    FResult: string;
    function InitPass(var hProv: HCRYPTPROV; var hSKey: HCRYPTKEY; pass: string; alg: LongWord; Provider: PChar; ProvType: LongWord): Integer;
    procedure EnCrypt_MS_Prov(var _Data:TData; alg: LongWord; Provider: PChar; ProvType: LongWord);
   public
    _prop_Mode:byte;
    _prop_HashMode:byte;
    _prop_Key:string;

    _data_Key:THI_Event;
    _data_Data:THI_Event;
    _event_onEnCrypt:THI_Event;
    _event_onError:THI_Event;

    procedure _work_doEnCrypt0(var _Data:TData; Index:word);  // RC2
    procedure _work_doEnCrypt1(var _Data:TData; Index:word);  // RC4
    procedure _work_doEnCrypt2(var _Data:TData; Index:word);  // DES56
    procedure _work_doEnCrypt3(var _Data:TData; Index:word);  // 3DES112
    procedure _work_doEnCrypt4(var _Data:TData; Index:word);  // 3DES168
    procedure _work_doEnCrypt5(var _Data:TData; Index:word);  // AES128
    procedure _work_doEnCrypt6(var _Data:TData; Index:word);  // AES192
    procedure _work_doEnCrypt7(var _Data:TData; Index:word);  // AES256
    procedure _work_doEnCrypt8(var _Data:TData; Index:word);  // CYLINK_MEK

    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

// ============================================ MS CryptoAPI ==========================================

function THIEnCrypt.InitPass;
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

procedure THIEnCrypt.EnCrypt_MS_Prov; // Universal Algorithm
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
  FResult := ReadString(_Data, _data_Data) + #0;

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

  ln := sz;
  CryptEncrypt(hSKey, 0, true, 0, @FResult[1], @ln, sz);
  if GetLastError = ERROR_MORE_DATA then
  begin
    SetLength(FResult, ln);
    CryptEncrypt(hSKey, 0, true, 0, @FResult[1], @sz, ln);
  end
  else if GetLastError <> NO_ERROR then
    Err := ERROR_ENCRYPT;

  SetLength(FResult, sz);
  if Err <> NO_ERROR then exit;
  
  _hi_onEvent(_event_onEnCrypt, FResult);

FINALLY
  if hSKey <> 0 then CryptDestroyKey(hSKey);
  if hProv <> 0 then CryptReleaseContext(hProv, 0);

  if Err <> NO_ERROR then
    _hi_CreateEvent(_Data, @_event_onError, Err);
END;    
end;

//-------------------------------------------- Crypt ---------------------------------------------------

procedure THIEnCrypt._work_doEnCrypt0; // RC2
begin
  EnCrypt_MS_Prov(_Data, CALG_RC2, MS_ENHANCED_PROV, PROV_RSA_FULL);
end;

procedure THIEnCrypt._work_doEnCrypt1; // RC4
begin
  EnCrypt_MS_Prov(_Data, CALG_RC4, MS_ENHANCED_PROV, PROV_RSA_FULL);
end;

procedure THIEnCrypt._work_doEnCrypt2; // DES56
begin
  EnCrypt_MS_Prov(_Data, CALG_DES, MS_ENHANCED_PROV, PROV_RSA_FULL);
end;

procedure THIEnCrypt._work_doEnCrypt3; // 3DES112
begin
  EnCrypt_MS_Prov(_Data, CALG_3DES_112, MS_ENHANCED_PROV, PROV_RSA_FULL);
end;

procedure THIEnCrypt._work_doEnCrypt4; // 3DES168
begin
  EnCrypt_MS_Prov(_Data, CALG_3DES, MS_ENHANCED_PROV, PROV_RSA_FULL);
end;

procedure THIEnCrypt._work_doEnCrypt5; // AES128
begin
  EnCrypt_MS_Prov(_Data, CALG_AES_128, MS_ENH_RSA_AES_PROV, PROV_RSA_AES);
end;

procedure THIEnCrypt._work_doEnCrypt6; // AES192
begin
  EnCrypt_MS_Prov(_Data, CALG_AES_192, MS_ENH_RSA_AES_PROV, PROV_RSA_AES);
end;

procedure THIEnCrypt._work_doEnCrypt7; // AES256
begin
  EnCrypt_MS_Prov(_Data, CALG_AES_256, MS_ENH_RSA_AES_PROV, PROV_RSA_AES);
end;

procedure THIEnCrypt._work_doEnCrypt8; // CYLINK_MEK
begin
  EnCrypt_MS_Prov(_Data, CALG_CYLINK_MEK, MS_DEF_DH_SCHANNEL_PROV, PROV_DH_SCHANNEL);
end;

procedure THIEnCrypt._var_Result;
begin
   dtString(_Data, FResult);
end;

end.