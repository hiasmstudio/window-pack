unit hiGE_GameTick;

interface

uses Kol,Share,Debug;

type
  THIGE_GameTick = class(TDebug)
   private
     FCount:integer;
   public
    _prop_Count:integer;
    _prop_RandomValue:integer;

    _event_onTick:THI_Event;

    procedure _work_doTick(var _Data:TData; Index:word);
  end;

implementation

procedure THIGE_GameTick._work_doTick;
begin
   inc(FCount);
   if FCount = _prop_Count then
     begin
       FCount := 0;
       if (_prop_RandomValue = 0)or(Random(_prop_RandomValue) = 0) then
         _hi_onEvent(_event_onTick);
     end;
end;

end.
