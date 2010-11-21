unit hiCounter;

interface

uses Kol,Share,Debug;

type
  THICounter = class(TDebug)
   private
     FCounter:integer;
     FFirst:boolean;
   public
    _prop_Min:integer;
    _prop_Max:integer;
    _prop_Step:integer;
    _prop_Type:byte;
    _data_Min:THI_Event;
    _data_Max:THI_Event;
    _data_Step:THI_Event;    
    _event_onNext:THI_Event;

    constructor Create;
    procedure _work_doNext(var _Data:TData; Index:word);
    procedure _work_doPrev(var _Data:TData; Index:word);
    procedure _work_doReset(var _Data:TData; Index:word);
    procedure _work_doMax(var _Data:TData; Index:word);
    procedure _work_doMin(var _Data:TData; Index:word);
    procedure _work_doValue(var _Data:TData; Index:word);
    procedure _work_doStep(var _Data:TData; Index:word);    
    procedure _var_Count(var _Data:TData; Index:word);
    property _prop_Default:integer write FCounter;
  end;

implementation

constructor THICounter.Create;
begin
   inherited Create;
   FFirst := true;
end;

procedure THICounter._work_doNext;
begin  {
   if FFirst then
    begin
     //if _prop_Type = 0 then
     // FCounter := _prop_Min
     //else FCounter := _prop_Max;
     FCounter := _prop_Default;
     FFirst := false;
    end;
   }
   if _prop_Type = 0 then
    begin
     inc(FCounter,_prop_Step);
     if FCounter > _prop_Max then
       FCounter := _prop_Min;
    end
   else
    begin
     dec(FCounter,_prop_Step);
     if FCounter < _prop_Min then
       FCounter := _prop_Max;
    end;
   //_hi_OnEvent(_event_onNext,FCounter);
   _hi_CreateEvent(_Data,@_event_onNext,FCounter);

end;

procedure THICounter._work_doPrev;
var old:byte;
begin
   old := _prop_Type;
   _prop_Type := integer(not boolean(old));
  _work_doNext(_Data,Index);
  _prop_Type := old;
end;

procedure THICounter._work_doReset;
begin
   if _prop_Type = 0 then
      FCounter := _prop_Min
   else FCounter := _prop_Max;
end;

procedure THICounter._work_doValue;
begin
  FCounter := ToInteger(_Data);
end;

procedure THICounter._work_doMax;
begin
    _prop_Max := ReadInteger(_Data,_data_Max,0);
end;

procedure THICounter._work_doMin;
begin
    _prop_Min := ReadInteger(_Data,_data_Min,0);
end;

procedure THICounter._work_doStep;
begin
    _prop_Step := ReadInteger(_Data,_data_Step,0);
end;

procedure THICounter._var_Count;
begin
    dtInteger(_Data,FCounter);
end;

end.
