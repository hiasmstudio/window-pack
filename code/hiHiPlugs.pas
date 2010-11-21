unit hihiPlugs;

interface

uses Kol,Share;

type
  TWork = function(ID:Cardinal; const Data:string; Index:byte):TData;
  TParam = record
     ID:Cardinal;
     Handle:cardinal;
     Desktop:function(Index:smallint):TValue;
  end;
  PParam = ^TParam;
  THIhiPlugs = class
   private
    Arr:PArray;
    function Read(Var Item:TData; var Val:TData):boolean;
    function Count:integer;
   public
    Param:PParam;
    doWork:TWork;

    _event_onCommand:THI_Event;
    _event_onKeyDown:THI_Event;
    _event_onInit:THI_Event;
    _event_onChat:THI_Event;
    _event_onCmdEnabled:THI_Event;
    _event_onCmdCompleting:THI_Event;
    _event_onPanelEvent:THI_Event;

    procedure onEvent(var _Data:TData; Index:word);
    procedure Init;
    destructor Destroy; override;
    procedure _work_doDebug(var _Data:TData; Index:word);
    procedure _work_doOpen(var _Data:TData; Index:word);
    procedure _work_doInterface(var _Data:TData; Index:word);
    procedure _work_doChat(var _Data:TData; Index:word);
    procedure _work_doCommand(var _Data:TData; Index:word);
    procedure _work_doCmdEnabled(var _Data:TData; Index:word);
    procedure _work_doRegPanel(var _Data:TData; Index:word);
    procedure _work_doCmdUpdate(var _Data:TData; Index:word);
    procedure _var_FileName(var _Data:TData; Index:word);
    procedure _var_Handle(var _Data:TData; Index:word);
    procedure _var_Desktop(var _Data:TData; Index:word);
  end;

implementation

procedure THIhiPlugs.onEvent;
begin
   case Index of
    0: _hi_OnEvent(_event_onCommand,_Data);
    1: _hi_OnEvent(_event_onKeyDown,_Data);
    2: _hi_OnEvent(_event_onChat,_Data);
    3: _hi_OnEvent(_event_onCmdEnabled,_Data);
    4: _hi_OnEvent(_event_onCmdCompleting,_Data);
    5: _hi_OnEvent(_event_onPanelEvent,_Data);
   end;
end;

procedure THIhiPlugs.Init;
begin
  EventOn;
  GHandle := Param.Handle;
  InitDo;
  _hi_OnEvent(_event_onInit);
end;

destructor THIhiPlugs.Destroy;
begin
   if Arr <> nil then dispose(Arr);
end; 

procedure THIhiPlugs._work_doDebug;
begin
   doWork(Param.ID,ToString(_Data),0);
end;

procedure THIhiPlugs._work_doOpen;
begin
   doWork(Param.ID,ToString(_Data),1);
end;

procedure THIhiPlugs._work_doInterface;
begin
   doWork(Param.ID,ToString(_Data),2);
end;

procedure THIhiPlugs._work_doChat;
begin
   doWork(Param.ID,ToString(_Data),3);
end;

procedure THIhiPlugs._work_doCommand;
begin
   doWork(Param.ID,ToString(_Data),4);
end;

procedure THIhiPlugs._work_doCmdEnabled;
begin
   doWork(Param.ID,ToString(_Data),5);
end;

procedure THIhiPlugs._work_doRegPanel;
begin
   doWork(Param.ID,ToString(_Data),6);
end;

procedure THIhiPlugs._work_doCmdUpdate;
begin
   doWork(Param.ID,ToString(_Data),7);
end;

procedure THIhiPlugs._var_FileName;
begin
  dtString(_data, string(Param.Desktop(0).vdata^));
end;

procedure THIhiPlugs._var_Handle;
begin
  dtInteger(_data,Param.Handle);
end;

function THIhiPlugs.Read;
begin
  Result := true;
  with Param.Desktop(ToInteger(Item)) do
   case vtype of
    data_int: dtInteger(val, integer(vdata));
    data_str: dtString(val, string(vdata^));
    else Result := false;
   end;
end;

function THIhiPlugs.Count;
begin
   Result := integer(Param.Desktop(-1).vdata);
end;

procedure THIhiPlugs._var_Desktop;
begin
  if Arr = nil then
   Arr := CreateArray(nil,read,count,nil);
  dtArray(_Data,Arr); 
end;

end.
