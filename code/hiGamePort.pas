unit hiGamePort;

interface

uses Kol,Share,mmsystem,Debug;

type
  THIGamePort = class(TDebug)
   private
     PInfo:PJoyInfoEx;
   public
    _event_onButtons:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doCheck(var _Data:TData; Index:word);
    procedure _var_X(var _Data:TData; Index:word);
    procedure _var_Y(var _Data:TData; Index:word);
    procedure _var_Z(var _Data:TData; Index:word);
    procedure _var_R(var _Data:TData; Index:word);
  end;

implementation

constructor THIGamePort.Create;
begin
   inherited;
   New(PInfo);
end;

destructor THIGamePort.Destroy;
begin
   Dispose(PInfo);
   inherited;
end;

procedure THIGamePort._work_doCheck;
var err:integer;
begin
   PInfo.dwSize := sizeof(TJoyInfoEx);
   PInfo.dwFlags := JOYCAPS_HASZ or JOYCAPS_HASR or JOYCAPS_HASU or JOYCAPS_HASV or JOY_RETURNBUTTONS;
   err := joyGetPosEx(0,PInfo);
   _hi_OnEvent(_event_onButtons,integer(PInfo.wButtons));
end;

procedure THIGamePort._var_X;
begin
  dtInteger(_Data,PInfo.wXpos);
end;

procedure THIGamePort._var_Y;
begin
  dtInteger(_Data,PInfo.wYpos);
end;

procedure THIGamePort._var_Z;
begin
  dtInteger(_Data,PInfo.wZpos);
end;

procedure THIGamePort._var_R;
begin
  dtInteger(_Data,PInfo.dwRpos);
end;

end.
