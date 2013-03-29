unit hiChanelToIndex;
{05.01.2005}
interface

uses Kol,Share,Debug;

type
  THIChanelToIndex = class(TDebug)
   private
    dt:TData;
   public
    _prop_Count:integer;
    _event_onIndex:THI_Event;

    procedure doWork(var _Data:TData; Index:word);
    procedure _var_Data(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_EndIdx(var _Data:TData; Index:word); 
  end;

implementation

procedure THIChanelToIndex.doWork(var _Data:TData; Index:word);
begin
   dt:=_Data;
   _hi_CreateEvent(_Data,@_event_onIndex,Index);
end;

procedure THIChanelToIndex._var_Data(var _Data:TData; Index:word);
begin
   _Data:=dt;
end;


procedure THIChanelToIndex._var_Count;
begin
  dtInteger(_Data, _prop_Count);
end;

procedure THIChanelToIndex._var_EndIdx;    
begin
  dtInteger(_Data, _prop_Count - 1);
end;

end.
