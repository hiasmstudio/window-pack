unit hiDynamicHiDLL;

interface

uses Windows,Kol,Share,Debug,hiDLL;

type
  //TdllProc = procedure (var _Data:TValue; Index:word); cdecl;
  //TdllInitProc = procedure (var _Data:TValue; Index:word; Param:pointer); cdecl;
  //TdllInit = procedure (Event,Data:TdllInitProc; Param:pointer); cdecl;

  TILoadDllManager = record
    loaddll   : procedure(const Name:string) of object;
    unloaddll : procedure of object;
    getfid    : function : cardinal of object;
  end;
  ILoadDllManager = ^TILoadDllManager;

  THIDynamicHiDLL = class(TDebug)
   private
    ldm: TILoadDllManager;
    FID:cardinal;
    FdoWork,FGetVar:T_hi_dllInitProc;
    dp:pointer;

    procedure unloaddll;
    function getfid: cardinal;
    procedure loaddll(const Name:string);
    procedure SetEventCount(value:word);
    procedure SetDataCount(value:word);
   public
    _prop_Name:string;
    _event_Event:array of THI_Event;
    _data_Data:array of THI_Event;

    function getInterfaceLoadDllManager: ILoadDllManager;

    procedure _Dll_Event(var _Data:TData; Index:word);
    procedure _Dll_Data(var _Data:TData; Index:word);

    constructor Create;
    destructor Destroy; override;
    procedure _work_Work(var _Data:TData; Index:word);
    procedure _var_Var(var _Data:TData; Index:word);

    property _prop_EventCount:word write SetEventCount;
    property _prop_DataCount:word write SetDataCount;
  end;

implementation

function THIDynamicHiDLL.getInterfaceLoadDllManager;
begin
  Result := @ldm;
end;

procedure THIDynamicHiDLL.unloaddll;
begin
   if FID > 0 then
   begin
     FreeLibrary(FID);
     FdoWork := nil;
     FGetVar := nil;
   end;  
end;

function THIDynamicHiDLL.getfid;
begin
   Result := FID;
end;

constructor THIDynamicHiDLL.Create;
begin
   inherited;
   ldm.loaddll := loaddll;
   ldm.unloaddll := unloaddll;
   ldm.getfid := getfid;      
end;

destructor THIDynamicHiDLL.Destroy;
begin
   unloaddll;
   inherited;
end;

procedure THIDynamicHiDLL.SetEventCount;
begin
   SetLength(_event_Event,Value);
   //FEventCount := Value;
end;

procedure THIDynamicHiDLL.SetDataCount;
begin
   SetLength(_data_Data,Value);
   //FDataCount := Value;
end;

procedure dll_Event(var _Data:TData; Index:word; Param:pointer);
var dt:TData;
begin // xxx: ????
  dt.data_type := _data.data_type;
  dt.idata := _data.idata;
  dt.sdata := pchar(@_data.sdata[1]);
  dt.rdata := _data.rdata;
  THIDynamicHiDLL(Param)._Dll_Event(dt,Index);
end;

procedure dll_Data(var _Data:TData; Index:word; Param:pointer);
begin
  THIDynamicHiDLL(Param)._Dll_Data(_Data,Index);
end;

procedure THIDynamicHiDLL.loaddll;
var InitProc:T_hi_DllInit;
begin
  unloaddll;
  FID := LoadLibrary(PChar(Name));
  if FID > 0 then
   begin
     InitProc := GetProcAddress(FID,'_hi_DllInit');
     if Assigned(InitProc) then
      begin
        InitProc(dll_Event,dll_Data,Self,dp);
        FdoWork := GetProcAddress(FID,'_hi_doWork');
        FGetVar := GetProcAddress(FID,'_hi_GetVar');
      end;
   end;
end;

procedure THIDynamicHiDLL._work_Work(var _Data:TData; Index:word);
begin
   if Assigned(FdoWork) then
     FdoWork(_Data,Index,dp);
end;

procedure THIDynamicHiDLL._var_Var(var _Data:TData; Index:word);
begin
   if Assigned(FGetVar) then
    FGetVar(_Data,Index,dp);
end;

procedure THIDynamicHiDLL._Dll_Event(var _Data:TData; Index:word);
begin
   _hi_OnEvent(_event_Event[Index],_data);
end;

procedure THIDynamicHiDLL._Dll_Data(var _Data:TData; Index:word);
begin
   _ReadData(_Data,_data_Data[Index]);
end;

end.