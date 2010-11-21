unit hiStack;

interface

uses Kol,Share,Debug;

type
  THIStack = class(TDebug)
   private
    FData:TData;
    FDefault:TData;
    FList:PList;

    procedure SetDefault(Data:TData);
   public
    _prop_IgnorEmpty:boolean;
    _data_Data:THI_Event;
    _event_onPush:THI_Event;
    _event_onPop:THI_Event;
    _event_onEmpty:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doPush(var _Data:TData; Index:word);
    procedure _work_doPop(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _var_Value(var _Data:TData; Index:word);
    procedure _var_Peek(var _Data:TData; Index:word);
    property _prop_Default:TData write SetDefault;
  end;

implementation

constructor THIStack.Create;
begin
  inherited;
  FList := newlist;
end;

destructor THIStack.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure THIStack.SetDefault;
begin
   FDefault := Data;
   FData := FDefault;
end;

procedure THIStack._work_doPush;
var dt:PData;
begin
  FData := ReadData(_Data,_data_Data);
  new(dt);
  dtData(dt^,FData);
  FList.Add(dt);
  _hi_CreateEvent_(_Data,@_event_onPush);
end;

procedure THIStack._work_doPop;
var dt:PData;
begin
  if FList.Count > 0 then begin
    dt := PData(FList.Items[FList.Count-1]);
    FData := dt^;
    dispose(dt);
    FList.Delete(FList.Count-1);
  end else if _prop_IgnorEmpty then begin
    _hi_CreateEvent(_Data,@_event_onEmpty);
    Exit;
  end else FData := FDefault;
  _hi_CreateEvent(_Data,@_event_onPop,FData);
end;

procedure THIStack._work_doClear;
var i:integer;
begin
  for i := 0 to FList.Count-1 do
    dispose(pdata(FList.Items[i]));
  FList.Clear;
end;

procedure THIStack._var_Value;
begin
  _Data := FData;
end;

procedure THIStack._var_Peek;
begin
  if FList.Count > 0 then
    _Data := PData(FList.Items[FList.Count-1])^
  else
    _Data := FDefault;  
end;

end.
