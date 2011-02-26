unit hiKeyPairsGen;

interface

uses Windows, Kol, Share, Debug, MSCryptoAPI;

type
 THiKeyPairsGen = class(TDebug)
   private
     FKeyPairs,
     FPublicKey: string;
   public
     _prop_GenerateMode: Byte;
     _prop_LengthKey: Byte;
    
     _event_onError: THI_Event;
     _event_onResult: THI_Event;
     
     procedure _work_doKeyPair(var _Data:TData; Index:word);

     procedure _var_KeyPair(var _Data:TData; Index:word);
     procedure _var_PublicKey(var _Data:TData; Index:word);
 end;

implementation

procedure THiKeyPairsGen._work_doKeyPair;
var
  hProv: HCRYPTPROV;
  KeyPairs: HCRYPTKEY;
  dwKeyPairsBlobLen, dwPublicKeyBlobLen, algid, flag: LongWord;
  dtkp, dtpk: TData;
  Err: Integer;  
begin
  Err := NO_ERROR;
  hProv := 0;
  KeyPairs := 0;
  
  if CryptAcquireContext(@hProv, nil, MS_ENHANCED_PROV, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) then
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
  
    if CryptGenKey(hProv, algid, flag, @KeyPairs) then  
    begin
      if CryptExportKey(KeyPairs, 0, PRIVATEKEYBLOB, 0, nil, @dwKeyPairsBlobLen) then
      begin
        SetLength(FKeyPairs, dwKeyPairsBlobLen);
        if CryptExportKey(KeyPairs, 0, PRIVATEKEYBLOB, 0, @FKeyPairs[1], @dwKeyPairsBlobLen) then
        begin
          if CryptExportKey(KeyPairs, 0, PUBLICKEYBLOB, 0, nil, @dwPublicKeyBlobLen) then
          begin
            SetLength(FPublicKey, dwPublicKeyBlobLen);
            if not CryptExportKey(KeyPairs, 0, PUBLICKEYBLOB, 0, @FPublicKey[1], @dwPublicKeyBlobLen) then
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
      
  if KeyPairs <> 0 then CryptDestroyKey(KeyPairs);   
  if hProv <> 0 then CryptReleaseContext(hProv, 0);

  if Err <> NO_ERROR then
    _hi_CreateEvent(_Data, @_event_onError, Err)
  else
  begin
    dtString(dtkp, FKeyPairs);
    dtString(dtpk, FPublicKey);
    dtkp.ldata := @dtpk;
    _hi_onEvent_(_event_onResult, dtkp);
  end;  
end;

procedure THiKeyPairsGen._var_KeyPair;
begin
   dtString(_Data, FKeyPairs);
end;

procedure THiKeyPairsGen._var_PublicKey;
begin
   dtString(_Data, FPublicKey);
end;

end.
