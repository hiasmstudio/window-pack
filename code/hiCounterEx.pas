unit hiCounterEx;

interface

uses Kol,Share,Debug;

type
  Increment  = procedure of object;
  Decrement  = procedure of object;
  ThroughMax = procedure of object; 
  ThroughMin = procedure of object;  

type
  THICounterEx = class(TDebug)
   private
     FCounter:integer;
     FDirect: byte;
     FThrough: boolean;
     FunctionDirect: procedure of object;
     ReverseFunctionDirect: procedure of object;     
     FunctionThroughMax: procedure of object;
     FunctionThroughMin: procedure of object;     
     procedure SetDirect(Value: byte);
     procedure SetThrough(Value: boolean);     
     procedure Increment;
     procedure Decrement;
     procedure ThroughMax;
     procedure ThroughMin;     
     procedure DummyThrough;     
   public
    _prop_Min: integer;
    _prop_Max: integer;
    _prop_Step: integer;
    
    _event_onNext: THI_Event;
    _event_onThroughMax: THI_Event;
    _event_onThroughMin: THI_Event;        

    property _prop_Direct: byte read FDirect write SetDirect;
    property _prop_Through: boolean read FThrough write SetThrough;

    procedure _work_doNext(var _Data:TData; Index:word);
    procedure _work_doPrev(var _Data:TData; Index:word);
    procedure _work_doReset(var _Data:TData; Index:word);
    procedure _work_doMax(var _Data:TData; Index:word);
    procedure _work_doMin(var _Data:TData; Index:word);
    procedure _work_doValue(var _Data:TData; Index:word);
    procedure _work_doStep(var _Data:TData; Index:word);
    procedure _work_doDirect(var _Data:TData; Index:word);        
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_Min(var _Data:TData; Index:word); 
    procedure _var_Max(var _Data:TData; Index:word);     
    procedure _var_Direct(var _Data:TData; Index:word);    
    property _prop_Default:integer write FCounter;
  end;

implementation

procedure THICounterEx.Increment;
begin
  inc(FCounter, _prop_Step);
  if FCounter > _prop_Max then
  begin
    FCounter := _prop_Min;
    FunctionThroughMax;    
  end  
end;

procedure THICounterEx.Decrement;
begin
  dec(FCounter, _prop_Step);
  if FCounter < _prop_Min then
  begin
    FCounter := _prop_Max;
    FunctionThroughMin;
  end;  
end;

procedure THICounterEx.ThroughMax;
begin
  _hi_onEvent(_event_onThroughMax);
end;

procedure THICounterEx.ThroughMin;
begin
  _hi_onEvent(_event_onThroughMin);
end;

procedure  THICounterEx.DummyThrough;
begin
end;

procedure THICounterEx.SetDirect;
begin
  FDirect := Value;
  if FDirect = 0 then
  begin
    FunctionDirect        := Increment;
    ReverseFunctionDirect := Decrement;
  end   
  else
  begin
    FunctionDirect        := Decrement;
    ReverseFunctionDirect := Increment;
  end;            
end;

procedure THICounterEx.SetThrough;
begin
  FThrough := Value;
  if FThrough then
  begin
    FunctionThroughMax := ThroughMax;
    FunctionThroughMin := ThroughMin;    
  end  
  else
  begin
    FunctionThroughMax := DummyThrough;
    FunctionThroughMin := DummyThrough;    
  end;    
end;

procedure THICounterEx._work_doNext;
begin
  FunctionDirect;
  _hi_CreateEvent(_Data, @_event_onNext, FCounter);
end;

procedure THICounterEx._work_doPrev;
begin
  ReverseFunctionDirect;
  _hi_CreateEvent(_Data, @_event_onNext, FCounter);
end;

procedure THICounterEx._work_doReset;
begin
  if FDirect = 0 then
    FCounter := _prop_Min
  else
    FCounter := _prop_Max;
end;

procedure THICounterEx._work_doValue;
begin
  FCounter := ToInteger(_Data);
end;

procedure THICounterEx._work_doMax;
begin
  _prop_Max := ToInteger(_Data);
end;

procedure THICounterEx._work_doMin;
begin
  _prop_Min := ToInteger(_Data);
end;

procedure THICounterEx._work_doStep;
begin
  _prop_Step := ToInteger(_Data);
end;

procedure THICounterEx._work_doDirect;
begin
  _prop_Direct := ToInteger(_Data);
end;

procedure THICounterEx._var_Count;
begin
  dtInteger(_Data, FCounter);
end;

procedure THICounterEx._var_Direct;
begin
  dtInteger(_Data, FDirect);
end;

procedure THICounterEx._var_Max;
begin
  dtInteger(_Data, _prop_Max);
end;

procedure THICounterEx._var_Min;
begin
  dtInteger(_Data, _prop_Min);
end;

end.
