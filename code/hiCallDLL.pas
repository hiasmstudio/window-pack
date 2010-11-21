unit hiCallDLL;

interface

uses Kol,Share,Windows,Debug;

type
  TdllProc = procedure (var _Data:TValue; Index:word); cdecl;
  TdllInitProc = procedure (var _Data:TValue; Index:word; Param:pointer); cdecl;
  TdllInit = procedure (Event,Data:TdllInitProc; Param:pointer); cdecl;
  THICallDLL = class(TDebug)
   private
     FID:Cardinal;
     FEventCount:word;
     FDataCount:word;
     FWork:TdllProc;
     FVar:TdllProc;

     procedure SetEventCount(value:word);
     procedure SetDataCount(value:word);
     procedure SetDLLName(const value:string);
   public
    _prop_WorkCount:integer;
    _prop_VarCount:integer;
    onEvent:array of THI_Event;
    Data:array of THI_Event;

    procedure _Dll_Event(var _Data:TData; Index:word);
    procedure _Dll_Data(var _Data:TData; Index:word);

    procedure doEvent(var _Data:TData; Index:word);
    procedure EVar(var _Data:TData; Index:word);
    property _prop_EventCount:word write SetEventCount;
    property _prop_DataCount:word write SetDataCount;
    property _prop_DLLName:string write SetDLLName;
  end;

  function DataToValue(const Data:TData):TValue;
  function ValueToData(const Val:TValue):TData;

implementation

function DataToValue(const Data:TData):TValue;
begin
   Result.vtype := Data.Data_type;
   case Result.vtype of
    data_null: Result.vdata := nil;
    data_int : Result.vdata := @Data.idata;
    data_str : Result.vdata := PChar(Data.sdata + #0);
    data_real: Result.vdata := @data.rdata;
   end;
end;

function ValueToData(const Val:TValue):TData;
begin
   case Val.vtype of
     data_null: dtNull(Result);
     data_int : dtInteger(Result,integer(Val.vdata^));
     data_str : dtString(Result,PChar(Val.vdata));
     data_real: dtReal(Result,Real(Val.vdata^));
   end;
end;

procedure THICallDLL.SetEventCount;
begin
   SetLength(onEvent,Value);
   FEventCount := Value;
end;

procedure THICallDLL.SetDataCount;
begin
   SetLength(Data,Value);
   FDataCount := Value;
end;

procedure THICallDLL._Dll_Event;
begin
  if Index < FEventCount then
    _hi_OnEvent(onEvent[index],_Data)
  else dtNull(_Data);
end;

procedure THICallDLL._Dll_Data;
begin
   if Index < FDataCount then
     _Data := ReadData(_Data,Data[index])
   else dtNull(_Data);
end;

procedure dll_Event(var _Data:TValue; Index:word; Param:pointer); cdecl;
var dt:TData;
begin
  dt := ValueToData(_Data);
  THICallDLL(Param)._Dll_Event(dt,Index);
end;

procedure dll_Data(var _Data:TValue; Index:word; Param:pointer); cdecl;
var dt:TData;
begin
  dt := ValueToData(_Data);
  THICallDLL(Param)._Dll_Data(dt,Index);
  _Data := DataToValue(dt);
end;

procedure THICallDLL.SetDLLName;
var di:TdllInit;
    fn:string;
begin
   fn := ReadFileName(Value);
   if FileExists(fn) then
    begin
     FID := LoadLibrary(PChar(fn));
     FWork := TdllProc(GetProcAddress(FID,'doWork'));
     FVar := TdllProc(GetProcAddress(FID,'GetVar'));
     di := tdllInit(GetProcAddress(FID,'DllInit'));
     if Assigned(di) then
      di(dll_Event,dll_Data,self);
    end;
end;

procedure THICallDLL.doEvent;
var Val:TValue;
begin
   if Assigned(FWork) then
    begin
      Val := DataToValue(_Data);
      FWork(Val,Index);
    end;
end;

procedure THICallDLL.EVar;
var Val:TValue;
begin
   if Assigned(FVar) then
    begin
      Val := DataToValue(_Data);
      FVar(Val,Index);
      _Data := ValueToData(Val);
    end;
end;

end.
