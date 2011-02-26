unit HiCreateSignature;

interface

uses Windows, kol, Share, Debug, MSCryptoAPI;

type
 THiCreateSignature = class(TDebug)
   private
     FSignature: string;
   public
     _prop_HashMode: Byte;

     _data_Data: THI_Event;
     _data_KeyPair: THI_Event;

     _event_onError: THI_Event;
     _event_onResult: THI_Event;
     
     procedure _work_doCreateSignature(var _Data:TData; Index:word);
     procedure _work_doHashMode(var _Data:TData; Index:word);
     procedure _var_Signature(var _Data:TData; Index:word);
 end;

implementation

procedure THiCreateSignature._work_doCreateSignature;
var
  hProv: HCRYPTPROV;
  SignHash: HCRYPTHASH;
  PrivatKey: HCRYPTKEY;  
  dwDataForHashLen, dwKeyBlobLen, dwSignatureLen, algidhash: LongWord;
  Err: Integer;   
  DataForHash, KeyBlob: string;
begin
  Err := NO_ERROR;
  hProv := 0;
  SignHash := 0;
  PrivatKey := 0;
  
  if CryptAcquireContext(@hProv, nil, MS_ENHANCED_PROV, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) then
  begin
    DataForHash := ReadString(_Data, _data_Data);
    dwDataForHashLen := Length(DataForHash);
    if dwDataForHashLen <> 0 then
    begin    
      Case _prop_HashMode of
        0: algidhash := CALG_MD5;
        1: algidhash := CALG_SHA
      else   
        algidhash := CALG_SHA;
      end;
    
      if CryptCreateHash(hProv, algidhash, 0, 0, @SignHash) then
      begin
        if CryptHashData(SignHash, @DataForHash[1], dwDataForHashLen, 0) then
        begin
          KeyBlob := ReadString(_Data, _data_KeyPair);
          dwKeyBlobLen := Length(KeyBlob);
          if dwKeyBlobLen <> 0 then
          begin
            if CryptImportKey(hProv, @KeyBlob[1], dwKeyBlobLen, 0, 0, @PrivatKey) then
            begin
              if CryptSignHash(SignHash, AT_SIGNATURE, nil, 0, nil, @dwSignatureLen) then
              begin
                SetLength(FSignature, dwSignatureLen);  
                if not CryptSignHash(SignHash, AT_SIGNATURE, nil, 0, @FSignature[1], @dwSignatureLen) then 
                  Err := ERROR_SIGNED_HASH;
              end
              else
                Err := ERROR_SIGNED_HASH;
            end
            else
              Err := ERROR_IMPORT_KEYPAIR;
          end
          else
            Err := ERROR_INVALID_PARAMETER;
        end
        else
          Err := ERROR_HASH_DATA;
      end
      else
        Err := ERROR_CREATE_HASH;
    end
    else
      Err := ERROR_INVALID_PARAMETER;
  end
  else
    Err := ERROR_ACQUIRE_CONTEXT;

  if SignHash <> 0 then CryptDestroyHash(SignHash);
  if PrivatKey <> 0 then CryptDestroyKey(PrivatKey);     
  if hProv <> 0 then CryptReleaseContext(hProv, 0);
  
  if Err <> NO_ERROR then
    _hi_CreateEvent(_Data, @_event_onError, Err)
  else
    _hi_CreateEvent(_Data, @_event_onResult, FSignature);
end;

procedure THiCreateSignature._work_doHashMode;
begin
  _prop_HashMode := ToInteger(_Data);
end;

procedure THiCreateSignature._var_Signature;
begin
  dtString(_Data, FSignature);
end;

end.