unit HiEnumKeyContainers;

interface

uses Windows, kol, Share, Debug, MSCryptoAPI;

type
 THiEnumKeyContainers = class(TDebug)
   private
     FNameKeyContainer: string;
   public
    
     _event_onError: THI_Event;
     _event_onEnumKeyContainers: THI_Event;
     
     procedure _work_doEnumKeyContainers(var _Data:TData; Index:word);

     procedure _var_Name(var _Data:TData; Index:word);
 end;

implementation

procedure THiEnumKeyContainers._work_doEnumKeyContainers;
var
  hProv: HCRYPTPROV;
  ln, dwDataLen, Flag: LongWord;
begin
  hProv := 0;
  if CryptAcquireContext(@hProv, nil, 0, PROV_RSA_FULL, 0) then
  begin
    Flag := CRYPT_FIRST;
    if CryptGetProvParam(hProv, PP_ENUMCONTAINERS, nil, @dwDataLen, Flag) then
    begin
      SetLength(FNameKeyContainer, dwDataLen);
      while CryptGetProvParam(hProv, PP_ENUMCONTAINERS, @FNameKeyContainer[1], @dwDataLen, Flag) do
      begin
        Flag := CRYPT_NEXT;
        ln := 1;
        while (ln <= dwDataLen) and (FNameKeyContainer[ln] <> #0) do inc(ln);
        SetLength(FNameKeyContainer, ln - 1);
        _hi_OnEvent(_event_onEnumKeyContainers, FNameKeyContainer); 
        SetLength(FNameKeyContainer, dwDataLen);
      end;
    end
    else  
      _hi_CreateEvent(_Data, @_event_onError, ERROR_NO_CONTAINERS);
  end
  else
    _hi_CreateEvent(_Data, @_event_onError, ERROR_ACQUIRE_CONTEXT);  
  if hProv <> 0 then CryptReleaseContext(hProv, 0);
end;

procedure THiEnumKeyContainers._var_Name;
begin
  dtString(_Data, FNameKeyContainer);
end; 

end.