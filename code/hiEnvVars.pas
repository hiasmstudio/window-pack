unit hiEnvVars;

interface

uses Windows, Kol, Share, Debug;

type
  THIEnvVars = class(TDebug)
   private
    Res: string;
   public
    _prop_String: string;
    _prop_NameEnv: string;
    _prop_NewEnvVal: string;
    
    _data_String,
    _data_NameEnv,
    _data_NewEnvVal,
    _event_onExpandEnv,
    _event_onEnumEnv,
    _event_onEndEnumEvn,
    _event_onGetEnv:THI_Event;

    procedure _work_doExpandEnv(var _Data:TData; Index:word);
    procedure _work_doEnumEnv(var _Data:TData; Index:word);
    procedure _work_doGetEnv(var _Data:TData; Index:word);
    procedure _work_doSetEnv(var _Data:TData; Index:word);
    procedure _work_doDelEnv(var _Data:TData; Index:word);
    
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

procedure THIEnvVars._work_doExpandEnv;
var
  Sz: Cardinal;
  Src: string;
begin
  Res := '';
  Src := ReadString(_Data, _data_String, _prop_String);
  Sz := ExpandEnvironmentStrings(@Src[1], nil, 0);
  SetLength(Res, Sz);
  ExpandEnvironmentStrings(@Src[1], @Res[1], Sz);
  SetLength(Res, StrLen(@Res[1])); 
  _hi_CreateEvent(_Data, @_event_onExpandEnv, Res);    
end;

procedure THIEnvVars._work_doEnumEnv;
var
  EnvBlock: PChar;
  i, l :integer;
begin
  EnvBlock := nil; 
  EnvBlock := GetEnvironmentStrings;
  if EnvBlock <> nil then
  begin
    i := 0;    
    l := 0;    
    repeat
      l := StrLen(@EnvBlock[i]);
      if l > 0 then
      begin
        SetLength(Res, l);
        StrCopy(@Res[1], @EnvBlock[i]);
        _hi_OnEvent(_event_onEnumEnv, Res);
      end;   
      Inc(i, l + 1);      
    until l = 0;  
    FreeEnvironmentStrings(EnvBlock);
  end;
  _hi_CreateEvent(_Data, @_event_onEndEnumEvn);
end;

procedure THIEnvVars._work_doGetEnv;
var
  Sz: Cardinal;
  N: string;
begin
  Res := '';
  N := ReadString(_Data, _data_NameEnv, _prop_NameEnv);
  Sz := GetEnvironmentVariable(@N[1], nil, 0);
  if Sz <> 0 then
  begin
    SetLength(Res, Sz);
    GetEnvironmentVariable(@N[1], @Res[1], Sz);
    SetLength(Res, StrLen(@Res[1])); 
    _hi_CreateEvent(_Data, @_event_onGetEnv, Res);  
  end;  
end;

procedure THIEnvVars._work_doSetEnv;
begin
  SetEnvironmentVariable(@ReadString(_Data, _data_NameEnv, _prop_NameEnv)[1], @ReadString(_Data, _data_NewEnvVal, _prop_NewEnvVal)[1]);
end;

procedure THIEnvVars._work_doDelEnv;
begin
  SetEnvironmentVariable(@ReadString(_Data, _data_NameEnv, _prop_NameEnv)[1], nil);
end;

procedure THIEnvVars._var_Result;
begin
  dtString(_Data, Res);
end;

end.