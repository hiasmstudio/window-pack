unit hiEnvVars;

interface

uses Windows, Kol, Share, Debug;

type
  THIEnvVars = class(TDebug)
   private
    Res: string;
   public
    _prop_String: string;
    _prop_Name: string;
    _prop_Value: string;
    
    _data_String,
    _data_Name,
    _data_Value,
    _event_onExpand,
    _event_onEnum,
    _event_onEndEnum,
    _event_onGet:THI_Event;

    procedure _work_doExpand(var _Data:TData; Index:word);
    procedure _work_doEnum(var _Data:TData; Index:word);
    procedure _work_doGet(var _Data:TData; Index:word);
    procedure _work_doSet(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);
    
    procedure _var_Result(var _Data:TData; Index:word);
  end;

implementation

procedure THIEnvVars._work_doExpand;
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
  _hi_CreateEvent(_Data, @_event_onExpand, Res);    
end;

procedure THIEnvVars._work_doEnum;
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
        _hi_OnEvent(_event_onEnum, Res);
      end;   
      Inc(i, l + 1);      
    until l = 0;  
    FreeEnvironmentStrings(EnvBlock);
  end;
  _hi_CreateEvent(_Data, @_event_onEndEnum);
end;

procedure THIEnvVars._work_doGet;
var
  Sz: Cardinal;
  N: string;
begin
  Res := '';
  N := ReadString(_Data, _data_Name, _prop_Name);
  Sz := GetEnvironmentVariable(@N[1], nil, 0);
  if Sz <> 0 then
  begin
    SetLength(Res, Sz);
    GetEnvironmentVariable(@N[1], @Res[1], Sz);
    SetLength(Res, StrLen(@Res[1])); 
    _hi_CreateEvent(_Data, @_event_onGet, Res);  
  end;  
end;

procedure THIEnvVars._work_doSet;
begin
  SetEnvironmentVariable(@ReadString(_Data, _data_Name, _prop_Name)[1], @ReadString(_Data, _data_Value, _prop_Value)[1]);
end;

procedure THIEnvVars._work_doDelete;
begin
  SetEnvironmentVariable(@ReadString(_Data, _data_Name, _prop_Name)[1], nil);
end;

procedure THIEnvVars._var_Result;
begin
  dtString(_Data, Res);
end;

end.