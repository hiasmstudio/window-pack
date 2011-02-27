unit hiKeyPairsGen;

interface

uses Windows, Kol, Share, Debug, MSCryptoAPI;

type
 THiKeyPairsGen = class(TDebug)
   private
     FKeyPair,
     FPublicKey: string;
   public
     _prop_GenerateMode: Byte;
     _prop_LengthKey: Byte;
    
     _data_ReexportKeyPair: THI_Event;
     _event_onError: THI_Event;
     _event_onResult: THI_Event;
     
     procedure _work_doKeyPair(var _Data:TData; Index:word);
     procedure _work_doReexportKeyPair(var _Data:TData; Index:word);
     procedure _work_doGenerateMode(var _Data:TData; Index:word);
     procedure _work_doLengthKey(var _Data:TData; Index:word);          

     procedure _var_KeyPair(var _Data:TData; Index:word);
     procedure _var_PublicKey(var _Data:TData; Index:word);
 end;

implementation

procedure THiKeyPairsGen._work_doKeyPair;
var
  hProv: HCRYPTPROV;
  KeyPair: HCRYPTKEY;
  dwKeyPairBlobLen, dwPublicKeyBlobLen, algid, flag: LongWord;
  dtkp, dtpk: TData;
  Err: Integer;  
begin
  Err := NO_ERROR;
  hProv := 0;
  KeyPair := 0;
  
  if CryptAcquireContext(@hProv, nil, 0, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) then
  begin
    Case _prop_LengthKey of
      0: flag :=  RSA384BIT_KEY OR CRYPT_EXPORTABLE;
      1: flag :=  RSA512BIT_KEY OR CRYPT_EXPORTABLE;
      2: flag :=  RSA1024BIT_KEY OR CRYPT_EXPORTABLE;
      3: flag :=  RSA2048BIT_KEY OR CRYPT_EXPORTABLE;
      4: flag :=  RSA4096BIT_KEY OR CRYPT_EXPORTABLE
    else
      flag :=  RSA1024BIT_KEY OR CRYPT_EXPORTABLE;
    end;

    Case _prop_GenerateMode of
      0: algid := AT_KEYEXCHANGE;
      1: algid := AT_SIGNATURE
    else  
      algid := AT_KEYEXCHANGE;
    end;
  
    if CryptGenKey(hProv, algid, flag, @KeyPair) then  
    begin
      if CryptExportKey(KeyPair, 0, PRIVATEKEYBLOB, 0, nil, @dwKeyPairBlobLen) then
      begin
        SetLength(FKeyPair, dwKeyPairBlobLen);
        if CryptExportKey(KeyPair, 0, PRIVATEKEYBLOB, 0, @FKeyPair[1], @dwKeyPairBlobLen) then
        begin
          if CryptExportKey(KeyPair, 0, PUBLICKEYBLOB, 0, nil, @dwPublicKeyBlobLen) then
          begin
            SetLength(FPublicKey, dwPublicKeyBlobLen);
            if not CryptExportKey(KeyPair, 0, PUBLICKEYBLOB, 0, @FPublicKey[1], @dwPublicKeyBlobLen) then
              Err := ERROR_EXPORT_PUBLICKEY; 
          end
          else
            Err := ERROR_EXPORT_PUBLICKEY;
        end
        else
          Err := ERROR_EXPORT_KEYPAIR;
      end
      else
        Err := ERROR_EXPORT_KEYPAIR;
    end
    else
      Err := ERROR_GENERATION_KEY; 
  end
  else
    Err := ERROR_ACQUIRE_CONTEXT;
      
  if KeyPair <> 0 then CryptDestroyKey(KeyPair);   
  if hProv <> 0 then CryptReleaseContext(hProv, 0);

  if Err <> NO_ERROR then
    _hi_CreateEvent(_Data, @_event_onError, Err)
  else
  begin
    dtString(dtkp, FKeyPair);
    dtString(dtpk, FPublicKey);
    dtkp.ldata := @dtpk;
    _hi_onEvent_(_event_onResult, dtkp);
  end;  
end;

procedure THiKeyPairsGen._work_doReexportKeyPair;
var
  hProv: HCRYPTPROV;
  PrivatKey, SessionKey: HCRYPTKEY;
  dwKeyBlobLen, dwPublicKeyBlobLen: LongWord;
  dtkp, dtpk: TData; 
  Err: Integer;
begin
  Err := 0;
  SessionKey := 0;
  PrivatKey := 0;
  hProv := 0;
  if CryptAcquireContext(@hProv, nil, 0, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) then
  begin
    FKeyPair := ReadString(_Data, _data_ReexportKeyPair);
    dwKeyBlobLen := Length(FKeyPair);

    if dwKeyBlobLen <> 0 then
    begin
      if CryptImportKey(hProv, @FKeyPair[1], dwKeyBlobLen, 0, CRYPT_EXPORTABLE, @PrivatKey) then
      begin
        if CryptExportKey(PrivatKey, 0, PUBLICKEYBLOB, 0, nil, @dwPublicKeyBlobLen) then
        begin
          SetLength(FPublicKey, dwPublicKeyBlobLen);
          if not CryptExportKey(PrivatKey, 0, PUBLICKEYBLOB, 0, @FPublicKey[1], @dwPublicKeyBlobLen) then
            Err := ERROR_EXPORT_PUBLICKEY;
        end
        else
          Err := ERROR_EXPORT_PUBLICKEY;
      end
      else
        Err := ERROR_IMPORT_KEYPAIR;
    end
    else
      Err := ERROR_INVALID_PARAMETER;
  end
  else
    Err := ERROR_ACQUIRE_CONTEXT; 

  if SessionKey <> 0 then CryptDestroyKey(SessionKey); 
  if PrivatKey <> 0 then CryptDestroyKey(PrivatKey);     
  if hProv <> 0 then CryptReleaseContext(hProv, 0);

  if Err <> NO_ERROR then
    _hi_CreateEvent(_Data, @_event_onError, Err)
  else
  begin
    dtString(dtkp, FKeyPair);
    dtString(dtpk, FPublicKey);
    dtkp.ldata := @dtpk;
    _hi_onEvent_(_event_onResult, dtkp);
  end;  

end;

procedure THiKeyPairsGen._work_doGenerateMode;
begin
  _prop_GenerateMode := ToInteger(_Data);
end;

procedure THiKeyPairsGen._work_doLengthKey;          
begin
  _prop_LengthKey := ToInteger(_Data);
end;

procedure THiKeyPairsGen._var_KeyPair;
begin
   dtString(_Data, FKeyPair);
end;

procedure THiKeyPairsGen._var_PublicKey;
begin
   dtString(_Data, FPublicKey);
end;

end.
