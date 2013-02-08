unit hiKeyEvent;

interface

uses Kol,Share,Windows,Debug;

type
  THIKeyEvent = class(TDebug)
   private
    old: HWND;
    function key(code:integer):integer;

   public
    _prop_Code:integer;
    _prop_Alt:integer;
    _prop_Ctrl:integer;
    _prop_Shift:integer;

    _data_Handle:THI_Event;
    _data_Code:THI_Event;
    _data_Alt:THI_Event;
    _data_Ctrl:THI_Event;
    _data_Shift:THI_Event;
    
    procedure _work_doPress(var _Data:TData; Index:word);
    procedure _work_doPressDown(var _Data:TData; Index:word);
    procedure _work_doPressUp(var _Data:TData; Index:word);

    procedure _var_isShift(var _Data:TData; Index:word);
    procedure _var_isLShift(var _Data:TData; Index:word);
    procedure _var_isRShift(var _Data:TData; Index:word);
    procedure _var_isCtrl(var _Data:TData; Index:word);
    procedure _var_isLCtrl(var _Data:TData; Index:word);
    procedure _var_isRCtrl(var _Data:TData; Index:word);
    procedure _var_isAlt(var _Data:TData; Index:word);
    procedure _var_isLAlt(var _Data:TData; Index:word);
    procedure _var_isRAlt(var _Data:TData; Index:word);
    procedure _var_isWinkey(var _Data:TData; Index:word);
    procedure _var_isLWinkey(var _Data:TData; Index:word);
    procedure _var_isRWinkey(var _Data:TData; Index:word);
  end;

implementation

procedure THIKeyEvent._work_doPress;
var code,ScanCode:word;
    shift, ctrl, alt: integer;
begin
   old := GetForegroundWindow;
   SetForegroundWindow(ReadInteger(_Data,_data_Handle,0));
   code := ReadInteger(_Data,_data_Code,_prop_Code);
   ScanCode := Lo(MapVirtualKey(Code,0));
   
   shift := ReadInteger(_Data,_data_Shift,_prop_Shift);
   ctrl := ReadInteger(_Data,_data_Ctrl,_prop_Ctrl);
   alt := ReadInteger(_Data,_data_Alt,_prop_Alt);
   
   if shift = 1 then keybd_event(16,0,1,0);
   if ctrl = 1 then keybd_event(17,0,1,0);
   if alt = 1 then keybd_event(18,0,1,0);
   
   keybd_event(code,ScanCode,1,0);
   keybd_event(Code,ScanCode,3,0);
   
   if alt = 1 then keybd_event(18,0,3,0);
   if ctrl = 1 then keybd_event(17,0,3,0);
   if shift = 1 then keybd_event(16,0,3,0);
   SetForegroundWindow(old);
end;

procedure THIKeyEvent._work_doPressDown;
begin
   old:=GetForegroundWindow;
   SetForegroundWindow(ReadInteger(_Data,_data_Handle,0));
   keybd_event(ReadInteger(_Data,_data_Code,_prop_Code),0,1,0);
   SetForegroundWindow(old);
end;

procedure THIKeyEvent._work_doPressUp;
begin
   old:=GetForegroundWindow;
   SetForegroundWindow(ReadInteger(_Data,_data_Handle,0));
   keybd_event(ReadInteger(_Data,_data_Code,_prop_Code),0,3,0);
   SetForegroundWindow(old);
end;                       

function THIKeyEvent.key;
begin
   Result:=0;
   if GetKeyState(code)<0 then Result:=1;
end;

procedure THIKeyEvent._var_isShift;
begin
   dtInteger(_Data,key(16));
end;

procedure THIKeyEvent._var_isLShift;
begin
   dtInteger(_Data,key(160));
end;

procedure THIKeyEvent._var_isRShift;
begin
   dtInteger(_Data,key(161));
end;


procedure THIKeyEvent._var_isCtrl;
begin
   dtInteger(_Data,key(17));
end;

procedure THIKeyEvent._var_isLCtrl;
begin
   dtInteger(_Data,key(162));
end;

procedure THIKeyEvent._var_isRCtrl;
begin
   dtInteger(_Data,key(163));
end;

procedure THIKeyEvent._var_isAlt;
begin
   dtInteger(_Data,key(18));
end;

procedure THIKeyEvent._var_isLAlt;
begin
   dtInteger(_Data,key(164));
end;

procedure THIKeyEvent._var_isRAlt;
begin
   dtInteger(_Data,key(165));
end;

procedure THIKeyEvent._var_isWinkey;
begin
   dtInteger(_Data,byte((key(91)+key(92))>0));
end;

procedure THIKeyEvent._var_isLWinkey;
begin
   dtInteger(_Data,key(91));
end;

procedure THIKeyEvent._var_isRWinkey;
begin
   dtInteger(_Data,key(92));
end;

end.
