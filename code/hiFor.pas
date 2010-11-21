unit hiFor;

interface

uses Kol,Share,Debug;

type
  THIFor = class(TDebug)
   private
    i:integer;
    FStop:boolean;
   public
    _prop_Start:integer;
    _prop_End:integer;
    _prop_Step:integer;
    _prop_IncludeEnd:boolean;
    _prop_InData:boolean;
    _prop_onBreakEnable:boolean;
    _data_End:THI_Event;
    _data_Start:THI_Event;
    _event_onEvent:THI_Event;
    _event_onStop:THI_Event;
    _event_onBreak:THI_Event;

    procedure _work_doFor(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _work_doStep(var _Data:TData; Index:word);
    procedure _var_Position(var _Data:TData; Index:word);
  end;

implementation

procedure THIFor._work_doFor;
var rEnd,st:integer;
begin
  if not _prop_InData then dtNULL(_Data);
  FStop := false;
  i := ReadInteger(_Data,_data_Start,_prop_Start);
  rEnd := ReadInteger(_Data,_data_End,_prop_End);
  st := _prop_Step;
  if st > 0 then begin
    if not _prop_IncludeEnd then dec(rEnd);
    while i <= rEnd do begin
      _hi_OnEvent(_event_onEvent,i);
      if FStop then break;
      inc(i,st);
    end
  end else if st < 0 then begin
    if not _prop_IncludeEnd then inc(rEnd);
    while i >= rEnd do begin
      _hi_OnEvent(_event_onEvent,i);
      if FStop then break;
      inc(i,st)
    end
  end;
  if FStop and _prop_onBreakEnable then
    _hi_CreateEvent(_Data,@_event_onBreak)
  else
    _hi_CreateEvent(_Data,@_event_onStop,i);
end;

procedure THIFor._work_doStop;
begin
  FStop := true;
end;

procedure THIFor._work_doStep;
begin
  _prop_Step := ToInteger(_Data);
end;

procedure THIFor._var_Position;
begin
  dtInteger(_Data,i);
end;

end.
