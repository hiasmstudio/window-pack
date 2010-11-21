unit hiCeWinExec;

interface

uses Kol,KOLRapi,Share,Windows,Debug;

type
  THICeWinExec = class(TDebug)
   private
   public
    _prop_Param:string;
    _prop_FileName:string;

    _data_Params:THI_Event;
    _data_FileName:THI_Event;
    _event_onExec:THI_Event;

    procedure _work_doExec(var _Data:TData; Index:word);
  end;

implementation

procedure THICeWinExec._work_doExec;
var FN,params:PWideChar;
    p: TProcessInformation;
    bResult:Boolean;
begin
   Fn := StringToOleStr(ReadString(_Data,_data_FileName,_prop_FileName));
   Params := StringToOleStr(ReadString(_Data,_data_Params,_prop_Param));
   bResult := CeCreateProcess(Fn,Params, nil, nil, false, 0, nil, nil, nil, @p);
   //if _prop_Wait = true then WaitForSingleObject(p.hProcess, INFINITE);
   _hi_onEvent(_event_onExec,byte(bResult));
end;

end.
