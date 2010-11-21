unit hiCase;

interface

uses Kol,Share,If_arg,Debug;

type
  THICase = class(TDebug)
   private
   FData:TData;
   public
    _prop_Value:TData;
    _event_onTrue:THI_Event;
    _event_onNextCase:THI_Event;

    property  _prop_DataOnTrue:TData write FData;
    procedure _work_doCase(var _Data:TData; Index:word);
    procedure _work_doDataOnTrue(var _Data:TData; Index:word);
  end;

implementation

procedure THICase._work_doCase;
var dt:TData;
begin
  dt := _Data;
  if Compare(ReadFromThread(_Data),_prop_Value,0) then
     _hi_OnEvent_(_event_onTrue, FData)
  else 
     _hi_OnEvent(_event_onNextCase,dt);
end;

procedure THICase._work_doDataOnTrue; begin FData:= _Data; end;

end.