unit hiEvents;

interface

uses Windows,Kol,Share,Debug;

type
  THIEvents = class(TDebug)
   private
    FEvent:cardinal;
   public
    _prop_Name:string;

    _event_onCreate:THI_Event;

    destructor Destroy; override;

    procedure _work_doCreate(var _Data:TData; Index:word);
    procedure _work_doSet(var _Data:TData; Index:word);
    procedure _work_doReset(var _Data:TData; Index:word);
    procedure _work_doDestroy(var _Data:TData; Index:word);
    procedure _var_ObjHandle(var _Data:TData; Index:word);
  end;

implementation

destructor THIEvents.Destroy;
begin
   CloseHandle(FEvent);
   inherited;
end;

procedure THIEvents._work_doCreate;
begin
   CloseHandle(FEvent);
   FEvent := CreateEvent(nil,true,false,PChar(_prop_Name));
   _hi_CreateEvent(_Data,@_event_onCreate);
end;

procedure THIEvents._work_doSet;
begin
   SetEvent(FEvent);
end;

procedure THIEvents._work_doReset;
begin
   ResetEvent(FEvent);
end;

procedure THIEvents._work_doDestroy;
begin
   CloseHandle(FEvent);
end;

procedure THIEvents._var_ObjHandle;
begin
   dtInteger(_Data,FEvent);
end;

end.
