unit hiApplication;

interface

uses Kol,Share,Windows,Debug;

type
  THIApplication = class(TDebug)
   private
    Arr:PArray;
    procedure SetInfo(const Value:string);
    function Read(Var Item:TData; var Val:TData):boolean;
    function Count:integer;
   public
    _prop_Wait:boolean;
    _event_onTerminate:THI_Event;

    destructor Destroy; override;
    procedure _var_AppFileName(var _Data:TData; Index:word);
    procedure _var_Params(var _Data:TData; Index:word);
    procedure _work_doProcessMessages(var _Data:TData; Index:word);
    procedure _work_doLoopMessages(var _Data:TData; Index:word);
    procedure _work_doInfo(var _Data:TData; Index:word);
    property _prop_Info:string write SetInfo;
  end;

implementation

destructor THIApplication.Destroy;
begin
   if Arr <> nil then dispose(Arr);
   inherited; 
end;

procedure THIApplication.SetInfo;
begin
   if (Assigned(Applet))and(Value<>'') then
     Applet.Caption := Value;
end;

procedure THIApplication._var_AppFileName;
var s:string;
begin
   SetLength(s,1024);
   SetLength(s,GetModuleFileName(HInstance,PChar(@s[1]),1024));
   dtString(_Data,s);
end;

function THIApplication.Read;
var
  ind:integer;
begin
  ind := ToIntIndex(Item);
  if(ind >= 0 )and(ind < ParamCount)then
    dtString(Val,ParamStr(ind+1))
  else dtNull(Val);
  Result := _IsStr(Val);
end;

function THIApplication.Count;
begin
   Result := ParamCount;
end;

procedure THIApplication._var_Params;
begin
  if Arr = nil then
   Arr := CreateArray(nil,read,count,nil);
  dtArray(_Data,Arr);
end;

procedure THIApplication._work_doProcessMessages;
begin
  if Assigned(Applet)and(not AppletTerminated) then begin
    if _prop_Wait then WaitMessage;
    Applet.ProcessMessages;
  end;
  if AppletTerminated then _hi_CreateEvent(_Data,@_event_onTerminate);
end;

procedure THIApplication._work_doLoopMessages;
var Msg:TMsg;
begin
  while GetMessage( Msg,0, 0, 0 ) do
    begin
     TranslateMessage( Msg );
     DispatchMessage( Msg );
    end;
end;

procedure THIApplication._work_doInfo;
begin
  SetInfo(ToString(_Data));
end;

end.
