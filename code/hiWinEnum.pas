unit hiWinEnum;

interface

uses Kol,Share,Windows,Debug;

type
  THIWinEnum = class(TDebug)
   private
    FClassName:string;
    FStop:boolean;
    FHandle:HWND;

    function ReadParam:string;
   public
    _prop_VisibleOnly:byte;
    _data_Caption:THI_Event;
    _event_onEndEnum:THI_Event;
    _event_onFindWindow:THI_Event;

    procedure _work_doEnum(var _Data:TData; Index:word);
    procedure _work_doFind(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _var_Handle(var _Data:TData; Index:word);
    procedure _var_ClassName(var _Data:TData; Index:word);
    procedure _var_GetActiveWindow(var _Data:TData; Index:word);
  end;

implementation

function THIWinEnum.ReadParam;
begin
   SetLength(Result,512);
   SetLength(Result,GetWindowText(FHandle,@Result[1],512));
   SetLength(FClassName,512);
   SetLength(FClassName,Windows.GetClassName(FHandle,@FClassname[1],512));
end;

procedure THIWinEnum._work_doFind;
begin
   FHandle := FindWindow(nil,PChar(readstring(_Data,_data_Caption,'')));
   if FHandle > 0 then
     _hi_OnEvent(_event_onFindWindow,ReadParam);
end;

procedure THIWinEnum._work_doEnum;
var
  fl:boolean;
begin                              //'ProgMan','Program Manager'
   FStop := false;
   FHandle := GetWindow(FindWindow('tooltips_class32',''), GW_HWNDFIRST);
   while not FStop and( FHandle <> 0 ) do
    begin
      fl := true;

      if _prop_VisibleOnly = 0 then
        fl := fl and IsWindowVisible(FHandle);

      if fl then _hi_OnEvent(_event_onFindWindow,ReadParam);

      FHandle := GetWindow(FHandle,GW_HWNDNEXT);
    end;
   _hi_OnEvent(_event_onEndEnum);
end;

procedure THIWinEnum._work_doStop;
begin
   FStop := true;
end;

procedure THIWinEnum._var_Handle;
begin
  dtInteger(_Data,FHandle);
end;

procedure THIWinEnum._var_ClassName;
begin
  dtString(_Data,FClassName);
end;

procedure THIWinEnum._var_GetActiveWindow;
begin
  dtInteger(_Data,GetForegroundWindow);
end;

end.
