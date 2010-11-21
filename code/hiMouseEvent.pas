unit hiMouseEvent;

interface

uses Windows,Kol,Share,Debug;

type
  THIMouseEvent = class(TDebug)
   private
   public
    _prop_Button:integer;
    _prop_WheelDelta:integer;

    _data_Y:THI_Event;
    _data_X:THI_Event;
    _data_Button:THI_Event;
    _data_WheelDelta:THI_Event;

    procedure _work_doClick(var _Data:TData; Index:word);
    procedure _work_doMouseDown(var _Data:TData; Index:word);
    procedure _work_doMouseUp(var _Data:TData; Index:word);
    procedure _work_doMove(var _Data:TData; Index:word);
    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _work_doWheel(var _Data:TData; Index:word);
    procedure _work_doVisible(var _Data:TData; Index:word);
    procedure _var_MouseX(var _Data:TData; Index:word);
    procedure _var_MouseY(var _Data:TData; Index:word);
    procedure _var_Handle(var _Data:TData; Index:word);
  end;

implementation

const
  _mdown:array[1..3]of cardinal = (MOUSEEVENTF_LEFTDOWN,MOUSEEVENTF_RIGHTDOWN,MOUSEEVENTF_MIDDLEDOWN);
  _mup:array[1..3]of cardinal = (MOUSEEVENTF_LEFTUP,MOUSEEVENTF_RIGHTUP,MOUSEEVENTF_MIDDLEUP);

procedure THIMouseEvent._work_doClick;
var b:byte;
    pos:TPoint;
begin
   b := ReadInteger(_Data,_data_Button,_prop_Button);
   GetCursorPos(pos);
   mouse_event(_mdown[b],pos.x,pos.y,0,0);
   mouse_event(_mup[b],pos.x,pos.y,0,0);
end;

procedure THIMouseEvent._work_doMouseDown;
var b:byte;
    pos:TPoint;
begin
   b := ReadInteger(_Data,_data_Button,_prop_Button);
   GetCursorPos(pos);
   mouse_event(_mdown[b],pos.x,pos.y,0,0);
end;

procedure THIMouseEvent._work_doMouseUp;
var b:byte;
    pos:TPoint;
begin
   b := ReadInteger(_Data,_data_Button,_prop_Button);
   GetCursorPos(pos);
   mouse_event(_mup[b],pos.x,pos.y,0,0);
end;

procedure THIMouseEvent._work_doMove;
var pos:TPoint;
begin
   GetCursorPos(pos);
   inc(Pos.X,ReadInteger(_Data,_data_X,0));
   inc(Pos.Y,ReadInteger(_Data,_data_Y,0));
   SetCursorPos(pos.x,pos.y);
   //mouse_event(MOUSEEVENTF_MOVE,ReadInteger(_Data,_data_X,0),ReadInteger(_Data,_data_Y,0),0,0);
end;

procedure THIMouseEvent._work_doPosition;
var pos:TPoint;
begin
   Pos.X := ReadInteger(_Data,_data_X,0);
   Pos.Y := ReadInteger(_Data,_data_Y,0);
   SetCursorPos(pos.x,pos.y);
   //mouse_event(MOUSEEVENTF_MOVE,ReadInteger(_Data,_data_X,0)-pos.x,ReadInteger(_Data,_data_Y,0)-pos.y,0,0);
end;

procedure THIMouseEvent._work_doWheel;
begin
   mouse_event(MOUSEEVENTF_WHEEL,0,0,ReadInteger(_Data,_data_WheelDelta,_prop_WheelDelta),0);
end;

procedure THIMouseEvent._work_doVisible;
begin
  ShowCursor(ReadBool(_Data));
end;

procedure THIMouseEvent._var_MouseX;
var pos:TPoint;
begin
   GetCursorPos(pos);
   dtInteger(_Data,Pos.x);
end;

procedure THIMouseEvent._var_MouseY;
var pos:TPoint;
begin
   GetCursorPos(pos);
   dtInteger(_Data,Pos.y);
end;

procedure THIMouseEvent._var_Handle;
var pos:TPoint;
begin
   GetCursorPos(pos);
   dtInteger(_Data,WindowFromPoint(pos));
end;

end.
