unit HiImportSessionKey;

interface

uses Windows, kol, Share, Debug, MSCryptoAPI;

type
 THiImportSessionKey = class(TDebug)
   private
     FSessionKey: string;
   public

     _data_ExchangeKey: THI_Event;
     _data_KeyPair: THI_Event;
     
     _event_onError: THI_Event;
     _event_onResult: THI_Event;
     
     procedure _work_doImportSessionKey(var _Data:TData; Index:word);
     procedure _var_SessionKey(var _Data:TData; Index:word);
 end;

implementation

procedure THiImportSessionKey._work_doImportSessionKey;
var
  hProv: HCRYPTPROV;
  PrivatKey, SessionKey: HCRYPTKEY;
  dwKeyBlobLen, dwExchangeKeyBlobLen, dwSessionKeyLen: LongWord;
  ExchangeKeyBlob, KeyBlob: string; 
  Err: Integer;
begin
  Err := 0;
  SessionKey := 0;
  PrivatKey := 0;
  hProv := 0;
  if CryptAcquireContext(@hProv, nil, 0, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) then
  begin
    KeyBlob := ReadString(_Data, _data_KeyPair);
    dwKeyBlobLen := Length(KeyBlob);
    ExchangeKeyBlob := ReadString(_Data, _data_ExchangeKey);
    dwExchangeKeyBlobLen := Length(ExchangeKeyBlob);
    if (dwKeyBlobLen <> 0) and (dwExchangeKeyBlobLen <> 0) then
    begin
      if CryptImportKey(hProv, @KeyBlob[1], dwKeyBlobLen, 0, 0, @PrivatKey) then
      begin
        if CryptImportKey (hProv, @ExchangeKeyBlob[1], dwExchangeKeyBlobLen, PrivatKey, CRYPT_EXPORTABLE, @SessionKey) then
        begin
          if CryptExportKey(SessionKey, 0, PLAINTEXTKEYBLOB, 0, nil, @dwSessionKeyLen) then
          begin
            SetLength(FSessionKey, dwSessionKeyLen);
            if not CryptExportKey(SessionKey, 0, PLAINTEXTKEYBLOB, 0, @FSessionKey[1], @dwSessionKeyLen) then
              Err := ERROR_EXPORT_SESSIONKEY;            
          end
          else
            Err := ERROR_EXPORT_SESSIONKEY;
        end
        else
          Err := ERROR_IMPORT_EXCHANGEKEY;
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
    _hi_CreateEvent(_Data, @_event_onResult, FSessionKey);

end;

procedure THiImportSessionKey._var_SessionKey;
begin
  dtString(_Data, FSessionKey);
end;

end.