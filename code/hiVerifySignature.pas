unit HiVerifySignature;

interface

uses Windows, kol, Share, Debug, MSCryptoAPI;

type
 THiVerifySignature = class(TDebug)
   private

   public
     _prop_HashMode: Byte;

     _data_Data: THI_Event;
     _data_PublicKey: THI_Event;
     _data_Signature: THI_Event;     

     _event_onError: THI_Event;
     _event_onResult: THI_Event;
     
     procedure _work_doVerifySignature(var _Data:TData; Index:word);
     procedure _work_doHashMode(var _Data:TData; Index:word);
 end;

implementation

procedure THiVerifySignature._work_doVerifySignature;
var
  hProv: HCRYPTPROV;
  PublicKey: HCRYPTKEY;
  SignHash: HCRYPTHASH;
  dwDataForHashLen, dwKeyBlobLen, dwSignatureBlobLen, algidhash: LongWord;
  DataForHash, SignatureBlob, KeyBlob: string;
  Err: Integer; 
  Valid: LongBool;
begin
  Err := NO_ERROR;
  Valid := false;
  hProv := 0;
  SignHash := 0;
  PublicKey := 0;
  
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
          KeyBlob := ReadString(_Data, _data_PublicKey);
          dwKeyBlobLen := Length(KeyBlob);
          if dwKeyBlobLen <> 0 then
          begin  
            if CryptImportKey(hProv, @KeyBlob[1], dwKeyBlobLen, 0, 0, @PublicKey) then
            begin
              SignatureBlob := ReadString(_Data, _data_Signature);
              dwSignatureBlobLen := Length(SignatureBlob);
              if dwSignatureBlobLen <> 0 then
                Valid := CryptVerifySignature(SignHash, @SignatureBlob[1], dwSignatureBlobLen, PublicKey, nil, 0)
              else
                Err := ERROR_INVALID_PARAMETER;  
            end
            else
              Err := ERROR_IMPORT_PUBLICKEY;
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
  if PublicKey <> 0 then CryptDestroyKey(PublicKey);   
  if hProv <> 0 then CryptReleaseContext(hProv, 0);

  if Err <> NO_ERROR then
    _hi_CreateEvent(_Data, @_event_onError, Err)
  else
    _hi_CreateEvent(_Data, @_event_onResult, integer(Valid));
end;

procedure THiVerifySignature._work_doHashMode;
begin
  _prop_HashMode := ToInteger(_Data);
end;

end.