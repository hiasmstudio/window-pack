unit hiUseHiDLL;

interface

uses Windows,Kol,Share,Debug,hiDLL;

type
  //TdllProc = procedure (var _Data:TValue; Index:word); cdecl;
  //TdllInitProc = procedure (var _Data:TValue; Index:word; Param:pointer); cdecl;
  //TdllInit = procedure (Event,Data:TdllInitProc; Param:pointer); cdecl;

  THIUseHiDLL = class(TDebug)
   private
    FID:cardinal;
    FdoWork,FGetVar:T_hi_dllInitProc;
    dp:pointer;

    procedure SetName(const Name:string);
    procedure SetEventCount(value:word);
    procedure SetDataCount(value:word);
   public
    _event_Event:array of THI_Event;
    _data_Data:array of THI_Event;

    procedure _Dll_Event(var _Data:TData; Index:word);
    procedure _Dll_Data(var _Data:TData; Index:word);

    destructor Destroy; override;
    procedure _work_Work(var _Data:TData; Index:word);
    procedure _var_Var(var _Data:TData; Index:word);
    property _prop_DLLName:string write SetName;

    property _prop_EventCount:word write SetEventCount;
    property _prop_DataCount:word write SetDataCount;
  end;

implementation

destructor THIUseHiDLL.Destroy;
begin
   if FID > 0 then
     FreeLibrary(FID);
   inherited;
end;

procedure THIUseHiDLL.SetEventCount;
begin
   SetLength(_event_Event,Value);
   //FEventCount := Value;
end;

procedure THIUseHiDLL.SetDataCount;
begin
   SetLength(_data_Data,Value);
   //FDataCount := Value;
end;

procedure dll_Event(var _Data:TData; Index:word; Param:pointer);
var dt:TData;
begin // xxx: ????
  dtNull(dt);
  dt.data_type := _data.data_type;
  dt.idata := _data.idata;
  dt.sdata := pchar(@_data.sdata[1]);
  dt.rdata := _data.rdata;
  THIUseHiDLL(Param)._Dll_Event(dt,Index);
end;

procedure dll_Data(var _Data:TData; Index:word; Param:pointer);
begin
  THIUseHiDLL(Param)._Dll_Data(_Data,Index);
end;

procedure THIUseHiDLL.SetName;
var InitProc:T_hi_DllInit;
begin
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

procedure THIUseHiDLL._work_Work(var _Data:TData; Index:word);
begin
   if Assigned(FdoWork) then
     FdoWork(_Data,Index,dp);
end;

procedure THIUseHiDLL._var_Var(var _Data:TData; Index:word);
begin
   if Assigned(FGetVar) then
    FGetVar(_Data,Index,dp);
end;

procedure THIUseHiDLL._Dll_Event(var _Data:TData; Index:word);
begin
   _hi_OnEvent(_event_Event[Index],_data);
end;

procedure THIUseHiDLL._Dll_Data(var _Data:TData; Index:word);
begin
   _ReadData(_Data,_data_Data[Index]);
end;

end.
