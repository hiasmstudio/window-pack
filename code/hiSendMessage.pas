unit hiSendMessage;

interface

uses Kol,Windows,Share,Debug,Messages;

const
 WM_NULL = Messages.WM_NULL;
 WM_USER = Messages.WM_USER;
 WM_MOVE = Messages.WM_MOVE;
 WM_SIZE = Messages.WM_SIZE;
 WM_SETREDRAW = Messages.WM_SETREDRAW;
 WM_ACTIVATE = Messages.WM_ACTIVATE;
 WM_CHILDACTIVATE = Messages.WM_CHILDACTIVATE;
 WM_CLOSE = Messages.WM_CLOSE;
 WM_COMMAND = Messages.WM_COMMAND;
 CB_SELECTSTRING = Messages.CB_SELECTSTRING;
 WM_SETTEXT = Messages.WM_SETTEXT;
 WM_PAINT = Messages.WM_PAINT;
 WM_SETFONT = Messages.WM_SETFONT;
 WM_GETTEXT = Messages.WM_GETTEXT;
 WM_FONTCHANGE = Messages.WM_FONTCHANGE;

type
  THISendMessage = class(TDebug)
   private
   public
    _prop_Message:cardinal;
    _prop_WParam:integer;
    _prop_LParam:integer;

    _data_Message:THI_Event;
    _data_LParam:THI_Event;
    _data_WParam:THI_Event;
    _data_Handle:THI_Event;
    _event_onSend:THI_Event;

    procedure _work_doSendMessage(var _Data:TData; Index:word);
  end;

implementation

procedure THISendMessage._work_doSendMessage;
var h:HWND;
    w,l:cardinal;
begin
  h := ReadInteger(_Data,_data_Handle,0);
  w := ReadInteger(_Data,_data_WParam,_prop_WParam);
  l := ReadInteger(_Data,_data_LParam,_prop_LParam);
  _hi_CreateEvent(_Data,@_event_onSend, integer(SendMessage(h,ReadInteger(_Data,_data_Message,_prop_Message),w,l)) );
end;

end.
