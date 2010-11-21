unit hiCMD_State;

interface

uses Kol,Share,Debug,hiCommandCenter;

type
  THICMD_State = class(TDebug)
   private
   public
    _prop_CommandCenter:ICommandCenter;
    _prop_Name:string;
    _prop_Enabled:integer;
    _prop_Checked:integer;

    _data_Checked:THI_Event;
    _data_Enabled:THI_Event;
    _data_Name:THI_Event;
    _event_onSetState:THI_Event;

    procedure _work_doSetState(var _Data:TData; Index:word);
  end;

implementation

procedure THICMD_State._work_doSetState;
var n:string;
    e,c:integer;
begin
   n := ReadString(_Data, _data_Name, _prop_Name);
   e := ReadInteger(_Data, _data_Enabled, _prop_Enabled);
   c := ReadInteger(_Data, _data_Checked, _prop_Checked);
   _prop_CommandCenter.state(n, e <> 0, c <> 0);
   _hi_onEvent(_event_onSetState);
end;

end.
