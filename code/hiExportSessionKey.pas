unit HiExportSessionKey;

interface

uses Windows, kol, Share, Debug, MSCryptoAPI;

type
 THiExportSessionKey = class(TDebug)
   private
     FSessionKey,
     FExchangeKey: string;
   public
     _prop_GenKeyMode: Byte;
     _prop_Key: string;

     _data_Key: THI_Event;
     _data_PublicKey: THI_Event;
     
     _event_onError: THI_Event;
     _event_onResult: THI_Event;
     
     procedure _work_doExportSessionKey(var _Data:TData; Index:word);
     procedure _work_doGenKeyMode(var _Data:TData; Index:word);

     procedure _var_SessionKey(var _Data:TData; Index:word);
     procedure _var_ExchangeKey(var _Data:TData; Index:word);                    
 end;

implementation

procedure THiExportSessionKey._work_doExportSessionKey;
var
  hProv: HCRYPTPROV;
  PublicKey, SessionKey: HCRYPTKEY;
  hash: HCRYPTHASH;
  dwKeyBlobLen, dwSessionKeyLen, dwExchangeKeyLen: LongWord;
  KeyBlob, pass: string;
  Err: Integer;
  dtsk, dtek: TData; 
begin
  Err := 0;
  Hash := 0;
  SessionKey := 0;
  PublicKey := 0;
  hProv := 0;
TRY
  if CryptAcquireContext(@hProv, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) then
  begin  
    KeyBlob := ReadString(_Data, _data_PublicKey);
    dwKeyBlobLen := Length(KeyBlob);
    if dwKeyBlobLen <> 0 then 
    begin
      pass := ReadString(_Data, _data_Key, _prop_Key);
      if CryptCreateHash(hProv, CALG_SHA, 0, 0, @Hash) then
      begin
        if CryptHashData(Hash, @pass[1], length(pass), 0) then
        begin
          Case _prop_GenKeyMode of
            0: if not CryptDeriveKey(hProv, CALG_3DES, Hash, CRYPT_EXPORTABLE, @SessionKey) then
               begin
                 Err := ERROR_DERIVE_KEY;
                 exit;
               end;  
            1: if not CryptGenKey(hProv, CALG_3DES, CRYPT_EXPORTABLE, @SessionKey) then
               begin
                 Err := ERROR_GENERATION_KEY;
                 exit;
               end;
          end;  
          if CryptImportKey(hProv, @KeyBlob[1], dwKeyBlobLen, 0, 0, @PublicKey) then
          begin
            if CryptExportKey(SessionKey, 0, PLAINTEXTKEYBLOB, 0, nil, @dwSessionKeyLen) then
            begin
              SetLength(FSessionKey, dwSessionKeyLen);
              if CryptExportKey(SessionKey, 0, PLAINTEXTKEYBLOB, 0, @FSessionKey[1], @dwSessionKeyLen) then
              begin
                if CryptExportKey(SessionKey, PublicKey, SIMPLEBLOB, 0, nil, @dwExchangeKeyLen) then
                begin
                  SetLength(FExchangeKey, dwExchangeKeyLen);
                  if not CryptExportKey(SessionKey, PublicKey, SIMPLEBLOB, 0, @FExchangeKey[1], @dwExchangeKeyLen) then
                    Err := ERROR_EXPORT_EXCHANGEKEY;
                end
                else
                  Err := ERROR_EXPORT_EXCHANGEKEY;
              end
              else
                Err := ERROR_EXPORT_SESSIONKEY;                  
            end
            else
              Err := ERROR_EXPORT_SESSIONKEY;
          end
          else
            Err := ERROR_IMPORT_PUBLICKEY;
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

FINALLY
  if Hash <> 0 then CryptDestroyHash(Hash);
  if SessionKey <> 0 then CryptDestroyKey(SessionKey); 
  if PublicKey <> 0 then CryptDestroyKey(PublicKey);     
  if hProv <> 0 then CryptReleaseContext(hProv, 0);

  if Err <> NO_ERROR then
    _hi_CreateEvent(_Data, @_event_onError, Err)
  else
  begin
    dtString(dtsk, FSessionKey);
    dtString(dtek, FExchangeKey);
    dtsk.ldata := @dtek;
    _hi_onEvent_(_event_onResult, dtsk);
  end;
END;    
end;

procedure THiExportSessionKey._work_doGenKeyMode;
begin
  _prop_GenKeyMode := ToInteger(_Data);
end;

procedure THiExportSessionKey._var_SessionKey;
begin
  dtString(_Data, FSessionKey);
end;

procedure THiExportSessionKey._var_ExchangeKey;
begin
  dtString(_Data, FExchangeKey);
end; 

end.