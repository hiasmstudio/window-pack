unit hiWinInfo;

interface

uses Windows, Kol, Share, Debug;

type
  THIWinInfo = class(TDebug)
   private
    AHandle: DWORD;
    FClassName: array [0..MAXCHAR - 1] of Char;
    FCaption: array [0..MAXCHAR - 1] of Char;
    FLanguageName: array [0..MAXCHAR - 1] of Char;
    FLeft, FTop, FWidth, FHeight: integer;
    FClientLeft, FClientTop, FClientWidth, FClientHeight: integer;
    FContext: integer;
    FParentHandle, FIsWindow, FIsZoomed, FIsEnabled, FIsVisible: integer;    
    FThreadID, FProcessID, FControlID: Dword;
    Icon: PIcon;
   public

    _data_Handle: THI_Event;
    _event_onWinInfo: THI_Event;

    constructor Create;
    destructor Destroy; override;

    procedure _work_doWinInfo(var _Data:TData; Index:word);
    procedure _var_ClassName(var _Data:TData; Index:word);
    procedure _var_Caption(var _Data:TData; Index:word);
    procedure _var_LanguageName(var _Data:TData; Index:word);
    procedure _var_Left(var _Data:TData; Index:word);
    procedure _var_Top(var _Data:TData; Index:word);
    procedure _var_Width(var _Data:TData; Index:word);
    procedure _var_Height(var _Data:TData; Index:word);
    procedure _var_ThreadID(var _Data:TData; Index:word);
    procedure _var_ProcessID(var _Data:TData; Index:word);
    procedure _var_ControlID(var _Data:TData; Index:word);
    procedure _var_Icon(var _Data:TData; Index:word);
    procedure _var_ClientLeft(var _Data:TData; Index:word);
    procedure _var_ClientTop(var _Data:TData; Index:word);
    procedure _var_ClientWidth(var _Data:TData; Index:word);
    procedure _var_ClientHeight(var _Data:TData; Index:word);
    procedure _var_Context(var _Data:TData; Index:word);
    procedure _var_IsWindow(var _Data:TData; Index:word);
    procedure _var_IsZoomed(var _Data:TData; Index:word);
    procedure _var_IsEnabled(var _Data:TData; Index:word);
    procedure _var_IsVisible(var _Data:TData; Index:word);
    procedure _var_ParentHandle(var _Data:TData; Index:word);    
  
  end;

implementation

constructor THIWinInfo.Create;
begin
  inherited;
  Icon:= NewIcon;
end;  

destructor THIWinInfo.Destroy;
begin
  Icon.free;
  ReleaseDC(AHandle, FContext); 
  inherited;
end;  

procedure THIWinInfo._work_doWinInfo;
var
  ARect: TRect;
begin

  AHandle := ReadInteger(_Data, _data_Handle);

  GetClassName(AHandle, FClassName, MAXCHAR);
  GetWindowText(AHandle, FCaption, MAXCHAR);

  FThreadID := GetWindowThreadProcessId(AHandle, @FProcessID);
         
  AttachThreadInput(GetCurrentThreadId, FThreadID, True);
  VerLanguageName(GetKeyboardLayout(FThreadID) and $FFFF, FLanguageName, MAXCHAR);
  AttachThreadInput(GetCurrentThreadId, FThreadID, False);

  GetWindowRect(AHandle, ARect);
  FLeft := ARect.Left; 
  FTop := ARect.Top;
  FWidth := ARect.Right - ARect.Left;
  FHeight := ARect.Bottom - ARect.Top;
   
  GetClientRect(AHandle, ARect);

  FClientLeft := ARect.Left; 
  FClientTop := ARect.Top;
  FClientWidth := ARect.Right - ARect.Left;
  FClientHeight := ARect.Bottom - ARect.Top;
  
  ReleaseDC(AHandle, FContext); 
  FContext := GetWindowDC(AHandle);

  FIsWindow := ord(IsWindow(AHandle));
  FIsVisible := ord(IsWindowVisible(AHandle));
  FIsEnabled := ord(IsWindowEnabled(AHandle));
  
  case ord(IsIconic(AHandle)) of
    0: FIsZoomed := ord(IsZoomed(AHandle)) + 1;
    1: FIsZoomed := 0;    
  end;

  FControlID := GetDlgCtrlID(AHandle);
    
  Icon.Clear;
  Icon.Handle:= GetClassLong(AHandle, GCL_HICON);
  
  FParentHandle := GetParent(AHandle);
  _hi_onEvent(_event_onWinInfo);

end;

procedure THIWinInfo._var_ClassName;
begin
  dtString(_Data, string(FClassName));
end;

procedure THIWinInfo._var_Caption;
begin
  dtString(_Data, string(FCaption));
end;

procedure THIWinInfo._var_LanguageName;
begin
  dtString(_Data, FLanguageName);
end;

procedure THIWinInfo._var_Left;
begin
  dtInteger(_Data, FLeft);
end;

procedure THIWinInfo._var_Top;
begin
  dtInteger(_Data, FTop);
end;

procedure THIWinInfo._var_Width;
begin
  dtInteger(_Data, FWidth);
end;

procedure THIWinInfo._var_Height;
begin
  dtInteger(_Data, FHeight);
end;

procedure THIWinInfo._var_ThreadID;
begin
  dtInteger(_Data, FThreadID);
end;

procedure THIWinInfo._var_ProcessID;
begin
  dtInteger(_Data, FProcessID);
end;

procedure THIWinInfo._var_ControlID;
begin
  dtInteger(_Data, FControlID);
end;

procedure THIWinInfo._var_Icon;
begin
  dtIcon(_Data, Icon);
end;

procedure THIWinInfo._var_ClientLeft;
begin
  dtInteger(_Data, FClientLeft);
end;

procedure THIWinInfo._var_ClientTop;
begin
  dtInteger(_Data, FClientTop);
end;

procedure THIWinInfo._var_ClientWidth;
begin
  dtInteger(_Data, FClientWidth);
end;

procedure THIWinInfo._var_ClientHeight;
begin
  dtInteger(_Data, FClientHeight);
end;

procedure THIWinInfo._var_Context;
begin
  dtInteger(_Data, FContext);
end;

procedure THIWinInfo._var_IsWindow;
begin
  dtInteger(_Data, FIsWindow);
end;

procedure THIWinInfo._var_IsZoomed;
begin
  dtInteger(_Data, FIsZoomed);
end;

procedure THIWinInfo._var_IsEnabled;
begin
  dtInteger(_Data, FIsEnabled);
end;

procedure THIWinInfo._var_IsVisible;
begin
  dtInteger(_Data, FIsVisible);
end;

procedure THIWinInfo._var_ParentHandle;
begin
  dtInteger(_Data, FParentHandle);
end;

end.
