unit hiMoveWindow;

interface

uses Kol,Share,Windows,Messages,Debug;

type
  THIMoveWindow = class(TDebug)
   private
   public
    _data_Handle:THI_Event;

    procedure _work_doMove(var _Data:TData; Index:word);
  end;

implementation

procedure THIMoveWindow._work_doMove;
var wnd:HWND;
begin       
   wnd := ReadInteger(_Data,_data_Handle,0);
   ReleaseCapture;
   SendMessage(wnd,WM_SYSCOMMAND, $F012, 0);
end;

end.
