unit hiMutex;

interface

uses Kol,Share,Windows,Debug;

type
  THIMutex = class(TDebug)
  private
    MutexHandle:  THandle;
  public
    destructor Destroy; override;
  public
    //??? А другие способы получения имени?
    //??? Сообщения об ошибках
    _prop_Name:string;

    _data_Name: THI_Event;

    _event_onCreated: THI_Event;
    _event_onAlreadyExists: THI_Event;
    _event_onReleased: THI_Event;
    _event_onOpened: THI_Event;
    _event_onError: THI_Event;

    procedure _work_doCreateMutex(var _Data:TData; Index:word);
    procedure _work_doCreateAndRelease(var _Data:TData; Index:word);
    procedure _work_doReleaseMutex(var _Data:TData; Index:word);
    procedure _work_doOpenMutex(var _Data:TData; Index:word);

    procedure _var_Handle(var _Data:TData; Index:word);
  end;

implementation

destructor THIMutex.Destroy;
begin
  if MutexHandle <> 0 then CloseHandle(MutexHandle);
  inherited;
end;

procedure THIMutex._work_doCreateMutex;
var
  MutexName: string;
begin
  MutexName := ReadString(_data,_data_Name,_prop_Name);

  MutexHandle := CreateMutex(nil, TRUE, PChar(MutexName));
  if MutexHandle = 0 then
    _hi_OnEvent(_event_onError, {$ifdef F_P}integer{$endif}(GetLastError))
  else
    if GetLastError = ERROR_ALREADY_EXISTS then
     begin
      _hi_OnEvent(_event_onAlreadyExists);
      MutexHandle := 0;
     end
    else
      _hi_OnEvent(_event_onCreated);
end;

procedure THIMutex._work_doCreateAndRelease;
begin
  _work_doCreateMutex(_Data, Index);
  _work_doReleaseMutex(_Data, Index);
end;

procedure THIMutex._work_doReleaseMutex;
begin
  if MutexHandle <> 0 then 
    if CloseHandle(MutexHandle) = FALSE then 
      _hi_OnEvent(_event_onError, {$ifdef F_P}integer{$endif}(GetLastError))
    else
     begin
       _hi_OnEvent(_event_onReleased);    
       MutexHandle := 0;
     end;
end;

procedure THIMutex._work_doOpenMutex;
var
  MutexName: string;
begin
  MutexName := ReadString(_data,_data_Name,_prop_Name);

  MutexHandle := OpenMutex(0, FALSE, PChar(MutexName));
  if MutexHandle = 0 then 
    _hi_OnEvent(_event_onError, {$ifdef F_P}integer{$endif}(GetLastError))
  else
    _hi_OnEvent(_event_onOpened);
end;

procedure THIMutex._var_Handle;
begin
  dtInteger(_Data,MutexHandle);
end;

end.
