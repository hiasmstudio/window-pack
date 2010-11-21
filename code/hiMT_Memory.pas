unit hiMT_Memory;

interface

uses Kol,Share,Debug;

type
  THIMT_Memory = class(TDebug)
   private
    FData:TData;
   public
    _event_onData:THI_Event;

    destructor Destroy; override;
    procedure _work_doValue(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _var_Value(var _Data:TData; Index:word);
  end;

implementation

destructor THIMT_Memory.Destroy;
begin
  FreeData(@FData);
  inherited;
end;

procedure THIMT_Memory._work_doValue;
begin
  FreeData(@FData);
  CopyData(@FData,@_Data);
  _hi_CreateEvent(_Data,@_event_onData,FData);
end;

procedure THIMT_Memory._work_doClear;
begin
  FreeData(@FData);
  dtNull(FData);
  _hi_CreateEvent(_Data,@_event_onData);
end;

procedure THIMT_Memory._var_Value;
begin
  _Data := FData;
end;

end.
