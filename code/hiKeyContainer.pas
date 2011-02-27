unit hiKeyContainer;

interface

uses Windows, Kol, Share, Debug, MSCryptoAPI;

type
 THiKeyContainer = class(TDebug)
   private
     FKeyPair,
     FPublicKey: string;
   public
     _prop_Name: string;
     _prop_ImportKeyPair: Byte;
    
     _data_Name: THI_Event;
     _data_ImportKeyPair: THI_Event;
     
     _event_onError: THI_Event;
     _event_onCreateKeyContainer: THI_Event;
     _event_onDeleteKeyContainer: THI_Event;
     _event_onImportKeyPair: THI_Event;
     _event_onExportKeyPair: THI_Event;
     
     procedure _work_doCreateKeyContainer(var _Data:TData; Index:word);
     procedure _work_doDeleteKeyContainer(var _Data:TData; Index:word);
     procedure _work_doImportKeyPair(var _Data:TData; Index:word);
     procedure _work_doExportKeyPair(var _Data:TData; Index:word);     

     procedure _var_KeyPair(var _Data:TData; Index:word);
     procedure _var_PublicKey(var _Data:TData; Index:word);
 end;

implementation

procedure THiKeyContainer._work_doCreateKeyContainer;
var
  hProv: HCRYPTPROV;
  Name: string;
  Err: Integer;
begin
  Err := NO_ERROR;
  hProv := 0;
  
  Name := ReadString(_Data, _data_Name, _prop_Name);
  if Name <> '' then
  begin
    if not CryptAcquireContext(@hProv, @Name[1], 0, PROV_RSA_FULL, 0) then
    begin
      if CryptAcquireContext(@hProv, @Name[1], 0, PROV_RSA_FULL, CRYPT_NEWKEYSET) then
        _hi_CreateEvent(_Data, @_event_onCreateKeyContainer)
      else 
        Err := ERROR_CREATE_CONTAINER;
    end
    else
      Err := ERROR_CONTAINER_ALREADY_EXISTS;
  end
  else
    Err := ERROR_WRONG_CONTAINER_NAME;    

  if hProv <> 0 then CryptReleaseContext(hProv, 0);

  if Err <> NO_ERROR then _hi_CreateEvent(_Data, @_event_onError, Err);
end;

procedure THiKeyContainer._work_doDeleteKeyContainer;
var
  hProv: HCRYPTPROV;
  Name: string;
  Err: Integer;
begin
  Err := NO_ERROR;
  hProv := 0;

  Name := ReadString(_Data, _data_Name, _prop_Name);
  if Name <> '' then
  begin
    if CryptAcquireContext(@hProv, @Name[1], 0, PROV_RSA_FULL, 0) then
    begin
      if CryptAcquireContext(@hProv, @Name[1], 0, PROV_RSA_FULL, CRYPT_DELETEKEYSET) then
        _hi_CreateEvent(_Data, @_event_onDeleteKeyContainer)
      else 
        Err := ERROR_DELETE_CONTAINER;
    end
    else
      Err := ERROR_CONTAINER_NOT_EXISTS;
  end
  else
    Err := ERROR_WRONG_CONTAINER_NAME;

  if hProv <> 0 then CryptReleaseContext(hProv, 0);

  if Err <> NO_ERROR then _hi_CreateEvent(_Data, @_event_onError, Err);
end;

procedure THiKeyContainer._work_doImportKeyPair;
var
  hProv: HCRYPTPROV;
  PrivatKey: HCRYPTKEY;
  dwKeyBlobLen: LongWord;
  Name, KeyBlob: string;
  Err: Integer;
begin
  Err := NO_ERROR;
  hProv := 0;
  PrivatKey := 0;
  
  Name := ReadString(_Data, _data_Name, _prop_Name);
  if Name <> '' then
  begin
    KeyBlob := ReadString(_Data, _data_ImportKeyPair);
    dwKeyBlobLen := Length(KeyBlob);
    if dwKeyBlobLen <> 0 then
    begin 
      if CryptAcquireContext(@hProv, @Name[1], 0, PROV_RSA_FULL, 0) then
      begin
        if CryptImportKey(hProv, @KeyBlob[1], dwKeyBlobLen, 0, CRYPT_EXPORTABLE, @PrivatKey) then
          _hi_CreateEvent(_Data, @_event_onImportKeyPair)
        else 
          Err := ERROR_IMPORT_KEYPAIR;
      end
      else    
        Err := ERROR_ACQUIRE_CONTEXT;
    end
    else
      Err := ERROR_INVALID_PARAMETER;
  end
  else     
    Err := ERROR_WRONG_CONTAINER_NAME;

  if hProv <> 0 then CryptReleaseContext(hProv, 0);
  if PrivatKey <> 0 then CryptDestroyKey(PrivatKey);
  
  if Err <> NO_ERROR then _hi_CreateEvent(_Data, @_event_onError, Err);
end;

procedure THiKeyContainer._work_doExportKeyPair;
var
  hProv: HCRYPTPROV;
  KeyPair: HCRYPTKEY;
  PrivatKey: HCRYPTKEY;  
  dwKeyPairBlobLen, dwPublicKeyBlobLen: LongWord;
  dtkp, dtpk: TData;
  Err: Integer;  
  Name: string;
begin
  Err := NO_ERROR;
  hProv := 0;
  KeyPair := 0;
  PrivatKey := 0;  

  Name := ReadString(_Data, _data_Name, _prop_Name);
  if Name <> '' then
  begin
       
    if CryptAcquireContext(@hProv, @Name[1], 0, PROV_RSA_FULL, CRYPT_SILENT) then
    begin
      if CryptGetUserKey(hProv, AT_KEYEXCHANGE, @KeyPair) then
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
        Err := ERROR_GET_USER_KEY;
  end
  else    
    Err :=  ERROR_ACQUIRE_CONTEXT;
  end
  else     
    Err := ERROR_WRONG_CONTAINER_NAME;

  if hProv <> 0 then CryptReleaseContext(hProv, 0);
  if PrivatKey <> 0 then CryptDestroyKey(PrivatKey);
  if KeyPair <> 0 then CryptDestroyKey(KeyPair);

  if Err <> NO_ERROR then
    _hi_CreateEvent(_Data, @_event_onError, Err)
  else
  begin
    dtString(dtkp, FKeyPair);
    dtString(dtpk, FPublicKey);
    dtkp.ldata := @dtpk;
    _hi_onEvent_(_event_onExportKeyPair, dtkp);
  end;  
end;

procedure THiKeyContainer._var_KeyPair;
begin
   dtString(_Data, FKeyPair);
end;

procedure THiKeyContainer._var_PublicKey;
begin
   dtString(_Data, FPublicKey);
end;

end.
