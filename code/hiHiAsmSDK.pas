unit hiHiAsmSDK;

interface

uses Windows,Messages,Kol,Share,Debug,Win;

type
  PPChar = ^PChar;
  _sdk_init = procedure(h:cardinal); cdecl;
  _sdk_msg = function(msg:pointer):integer; cdecl;
  _sdk_command = procedure(cmd:PChar; param:PPChar); cdecl;
  THIHiAsmSDK = class(THIWin)
   private
    lib:cardinal;
    sdk_init:_sdk_init;
    sdk_msg:_sdk_msg;
    sdk_command:_sdk_command;
   
    function _OnMessage( var Msg: TMsg; var Rslt: Integer ): Boolean; override;
   public
    _data_Command:THI_Event;
    _data_Param:THI_Event;
    
    procedure Init; override;
    destructor Destroy; override;
    procedure _work_doLoadFromFile(var _Data:TData; Index:word);
    procedure _work_doSaveToFile(var _Data:TData; Index:word);
    procedure _work_doCommand(var _Data:TData; Index:word);
  end;

implementation

destructor THIHiAsmSDK.Destroy;
begin
   FreeLibrary(lib);
   inherited;
end;

function THIHiAsmSDK._OnMessage( var Msg: TMsg; var Rslt: Integer ): Boolean;
var _msg:array[0..2] of cardinal;
begin
  _msg[0] := Msg.message;
  _msg[1] := Msg.wParam;
  _msg[2] := Msg.lParam;

  Result := true;
  rslt := 0;
  //if(Msg.message <> WM_PAINT)and(Msg.message <> WM_HSCROLL)and(Msg.message <> WM_LBUTTONDOWN)and(Msg.message <> WM_LBUTTONUP)and(Msg.message <> WM_MOUSEMOVE)
  //  or(sdk_msg(@_msg[0]) = 0) then
  if Assigned(sdk_msg) then
    sdk_msg(@_msg[0]);
  Result := Inherited _OnMessage(Msg,Rslt);
end;

procedure THIHiAsmSDK.Init;
begin
   Control := NewPanel(FParent, esNone);
   //Control := NewPaintbox(FParent);
   inherited;
   lib := LoadLibrary('hiasm.dll');
   
   sdk_init := _sdk_init(GetProcAddress(lib, 'sdk_init'));
   if not Assigned(sdk_init) then
     _debug('Library hiasm.dll not found!');
   sdk_msg := _sdk_msg(GetProcAddress(lib, 'sdk_msg'));
   sdk_command := _sdk_command(GetProcAddress(lib, 'sdk_command'));
   
   sdk_init(Control.Handle);
end;

procedure THIHiAsmSDK._work_doLoadFromFile;
var s:PChar;
begin   
   s := PChar(ToString(_data)); 
   sdk_command('openfile', @s);
end;

procedure THIHiAsmSDK._work_doSaveToFile;
var s:PChar;
begin   
   s := PChar(ToString(_data));
   sdk_command('savefile', @s);
end;

procedure THIHiAsmSDK._work_doCommand;
var s:PChar;
    cmd:string;
begin   
   cmd := ReadString(_Data,_data_Command,'');
   s := PChar(ReadString(_Data,_data_Param,''));
   sdk_command(PChar(cmd), @s);
end;

end.