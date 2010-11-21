unit hiCeNotify;

interface

uses Windows,Kol,ActiveX,KOLComObj,Share,Debug;

type

  IDccManSink = interface(IUnknown)
    ['{A7B88840-A812-11CF-8011-00A0C90A8F78}']
    function OnLogIpAddr(dwIpAddr: DWORD): HRESULT; stdcall;
    function OnLogTerminated: HRESULT; stdcall;
    function OnLogActive: HRESULT; stdcall;
    function OnLogInactive: HRESULT; stdcall;
    function OnLogAnswered: HRESULT; stdcall;
    function OnLogListen: HRESULT; stdcall;
    function OnLogDisconnection: HRESULT; stdcall;
    function OnLogError: HRESULT; stdcall;
  end;

  IDccMan = interface(IUnknown)
    ['{A7B88841-A812-11CF-8011-00A0C90A8F78}']
    function Advise(DccSink: IDccManSink; var pdwContext: DWORD): HRESULT; stdcall;
    function Unadvise(dwContext: DWORD): HRESULT; stdcall;
    function ShowCommSettings: HRESULT; stdcall;
  end;

  THICeNotify = class(TDebug)
   private
    dccMan : IDccMan;
    dccManSink : IDccManSink;
    dccContext : DWORD;
    fWaiting, fInited, fConnected: Boolean;
    IpAsStr: String;
    procedure OpenSes;
    procedure CloseSes;
   public
    _event_onNotify:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure ResProcA(ResVar: Byte);
    procedure _work_doStartMonitoring(var _Data:TData; Index:word);
    procedure _work_doStopMonitoring(var _Data:TData; Index:word);
    procedure _work_doSettings(var _Data:TData; Index:word);
    procedure _var_Connected(var _Data:TData; Index:word);
    procedure _var_RemoteIP(var _Data:TData; Index:word);
  end;

  TDccManSink = class(TInterfacedObject, IDccManSink)
   public
    function OnLogIpAddr(dwIpAddr: DWORD): HRESULT; stdcall;
    function OnLogTerminated: HRESULT; stdcall;
    function OnLogActive: HRESULT; stdcall;
    function OnLogInactive: HRESULT; stdcall;
    function OnLogAnswered: HRESULT; stdcall;
    function OnLogListen: HRESULT; stdcall;
    function OnLogDisconnection: HRESULT; stdcall;
    function OnLogError: HRESULT; stdcall;
  end;

var ASInfoServ: THICeNotify;

implementation

const
  CLSID_DccMan: TGUID = '{499C0C20-A766-11cf-8011-00A0C90A8F78}';

constructor THICeNotify.Create;
begin
  inherited Create;
  fWaiting := false;
  fInited := false;
  fConnected := false;
  ASInfoServ := Self;
end;

destructor THICeNotify.Destroy;
begin
  CloseSes;
  inherited Destroy;
end;

procedure THICeNotify.OpenSes;
begin
  if not fInited then
  begin
   CoInitialize(nil);
   dccMan := CreateComObject(CLSID_DccMan) as IDccMan;
   fInited := true;
  end;
end;

procedure THICeNotify.CloseSes;
begin
  if fWaiting then dccMan.Unadvise(dccContext);
  if fInited then CoUninitialize;
  fWaiting := false;
  fInited := false;
  fConnected := false;
end;

procedure THICeNotify.ResProcA;
begin
  _hi_OnEvent(_event_onNotify,ResVar);
end;

procedure THICeNotify._work_doStartMonitoring;
begin
  if not fWaiting then
  begin
   OpenSes;
   dccManSink := TDccManSink.Create; //(Self);
   dccContext := 0;
   dccMan.Advise(dccManSink, dccContext);
   fWaiting := true;
  end;
end;

procedure THICeNotify._work_doStopMonitoring;
begin
  CloseSes;
end;

procedure THICeNotify._work_doSettings;
begin
  OpenSes;
  dccMan.ShowCommSettings;
end;

procedure THICeNotify._var_Connected;
begin
  dtInteger(_Data,Byte(fConnected));
end;

procedure THICeNotify._var_RemoteIP;
begin
  if fConnected then
    dtString(_Data,IpAsStr)
     else dtNull(_Data);
end;

function TDccManSink.OnLogIpAddr;
{Indicates that an Internet Protocol (IP) address has been established for
 communication between the desktop computer and the Windows CE“based device.}
begin
  ASInfoServ.IpAsStr := Int2str(LoByte(LoWord(dwIpAddr))) + '.' +
                        Int2str(HiByte(LoWord(dwIpAddr))) + '.' +
                        Int2str(LoByte(HiWord(dwIpAddr))) + '.' +
                        Int2str(HiByte(HiWord(dwIpAddr)));
  ASInfoServ.fConnected := True; //At this point, the connection is considered to be completely established.
  ASInfoServ.ResProcA(1);
end;

function TDccManSink.OnLogTerminated;
{Indicates that the Windows CE connection manager has been shut down.}
begin
  ASInfoServ.ResProcA(6);
end;

function TDccManSink.OnLogActive;
{Indicates that a connection is established between the client application and the connection manager.}
begin
  ASInfoServ.ResProcA(4);
end;

function TDccManSink.OnLogInactive;
{Indicates a disconnection, or disconnected state, between
 the desktop computer and the Windows CE“based device.}
begin
  ASInfoServ.ResProcA(5);
end;

function TDccManSink.OnLogAnswered;
{Indicates that the Windows CE connection manager has detected the communications interface.}
begin
  ASInfoServ.ResProcA(3);
end;

function TDccManSink.OnLogListen;
{Indicates that a connection is waiting to be established between
 the desktop computer and the Windows CE“based device.}
begin
  ASInfoServ.ResProcA(2);
end;

function TDccManSink.OnLogDisconnection;
{Indicates that the connection manager has terminated the connection between
 the desktop computer and the Windows CE“based-device.}
begin
  if ASInfoServ.fConnected then ASInfoServ.ResProcA(0);
  ASInfoServ.fConnected := false;
end;

function TDccManSink.OnLogError;
{Indicates that the connection manager failed to start communications between
 the desktop computer and the Windows CE“based device.}
begin
  ASInfoServ.ResProcA(7);
end;

end.
