unit hiCeCallDLL;

interface

uses Kol,KolRapi,Share,Debug,Windows;

type
  THICeCallDLL = class(TDebug)
   private
    cbOut:DWORD;
    pbOut:Pointer;
   public
    _prop_DLLName:string;
    _prop_FuncName:string;

    _data_DLLName:THI_Event;
    _data_FuncName:THI_Event;
    _data_Param:THI_Event;
    _event_onEnd:THI_Event;

    procedure _work_doCall(var _Data:TData; Index:word);
    procedure _var_Data(var _Data:TData; Index:word);
    
  end;

implementation

procedure THICeCallDLL._work_doCall;
var nResult,nBuffSize:integer;
    sLibName,sFuncName:PWideChar;
    sParam:String;
begin
  sLibName := StringToOleStr(ReadString(_Data,_data_DLLName,_prop_DLLName));
  sFuncName := StringToOleStr(ReadString(_Data,_data_FuncName,_prop_FuncName));
  sParam := ReadString(_Data,_data_Param,'');
  nBuffSize := Length(sParam);
  nResult := CeRapiInvoke(sLibName,sFuncName,nBuffSize,@sParam[1],cbOut,pbOut,nil,0);
  _hi_OnEvent(_event_onEnd,nResult);
end;

procedure THICeCallDLL._var_Data;
begin
  if Integer(cbOut) > 0 then
    dtString(_Data,PChar(pbOut)) else
      dtNull(_Data);
end;

end.
