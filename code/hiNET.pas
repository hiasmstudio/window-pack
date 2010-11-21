unit hiNET;

interface

uses Windows,Share,Debug;

type
  THINET = class(TDebug)
   private
   public
    procedure _var_Network(var _Data:TData; Index:word);
    procedure _var_Internet(var _Data:TData; Index:word);
  end;

implementation

uses WinSock;

procedure THINET._var_Network;
begin
  dtInteger(_Data,GetSystemMetrics(SM_NETWORK));
end;

procedure THINET._var_Internet;
begin
  UPD_Init;
  dtInteger(_Data,integer(GetHostByName('ya.ru') <> nil));
  UPD_Clear
end;

end.
