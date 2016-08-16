unit hiSysMenu;

interface

uses Share,Windows,Debug;

type
  THISysMenu = class(TDebug)
   private
    hHandle:Thandle;
    Style: Longint;
   public
    _data_Handle:THI_Event;
    _event_onPopupSysMenu:THI_Event;

    procedure _work_doHideCloseButton(var _Data:TData; Index:word);
    procedure _work_doHideMinimizeButton(var _Data:TData; Index:word); 
    procedure _work_doHideMaximizeButton(var _Data:TData; Index:word);
    procedure _work_doHideSYSMENU(var _Data:TData; Index:word);
    procedure _work_doShowCloseButton(var _Data:TData; Index:word);
    procedure _work_doShowMinimizeButton(var _Data:TData; Index:word);
    procedure _work_doShowMaximizeButton(var _Data:TData; Index:word);    
    procedure _work_doShowSYSMENU(var _Data:TData; Index:word);	
    procedure _work_doPopupSysMenu(var _Data:TData; Index:word);    
  end;

implementation

procedure THISysMenu._work_doHideCloseButton;
var 
   mHandle:Hmenu;
begin
   hHandle := ReadInteger(_Data,_data_Handle,0);
   if (hHandle <> 0) then mHandle := GetSystemMenu(hHandle, FALSE) else mHandle := 0;

   if (mHandle <> 0) then begin
      Windows.EnableMenuItem(mHandle, SC_CLOSE, MF_DISABLED or MF_GRAYED);
      DrawMenuBar (hHandle);
   end;
end;

procedure THISysMenu._work_doHideMinimizeButton;
begin
   hHandle := ReadInteger(_Data,_data_Handle,0);
   if (hHandle <> 0) then begin
      Style := GetWindowLong(hHandle, GWL_STYLE);
      SetWindowLong(hHandle, GWL_STYLE, Style And Not WS_MINIMIZEBOX);
      DrawMenuBar (hHandle);
   end;
end;

procedure THISysMenu._work_doHideMaximizeButton;
begin
   hHandle := ReadInteger(_Data,_data_Handle,0);
   if (hHandle <> 0) then begin
      Style := GetWindowLong(hHandle, GWL_STYLE);
      SetWindowLong(hHandle, GWL_STYLE, Style And Not WS_MAXIMIZEBOX);
      DrawMenuBar (hHandle);
   end;
end;
            
procedure THISysMenu._work_doHideSYSMENU;
begin
   hHandle := ReadInteger(_Data,_data_Handle,0);
   if (hHandle <> 0) then
    begin
      Style := GetWindowLong(hHandle, GWL_STYLE);
      SetWindowLong(hHandle, GWL_STYLE, Style And not WS_SYSMENU );
      DrawMenuBar (hHandle);
    end;
end;

procedure THISysMenu._work_doShowCloseButton;
var 
   mHandle:Hmenu;
begin
   hHandle := ReadInteger(_Data,_data_Handle,0);
   if (hHandle <> 0) then mHandle := GetSystemMenu(hHandle, FALSE) else mHandle := 0;

   if (mHandle <> 0) then begin
      Windows.EnableMenuItem(mHandle, SC_CLOSE, MF_ENABLED);
      DrawMenuBar (hHandle);
   end;
end;
 
procedure THISysMenu._work_doShowMinimizeButton;
begin
   hHandle := ReadInteger(_Data,_data_Handle,0);
   if (hHandle <> 0) then begin
      Style := GetWindowLong(hHandle, GWL_STYLE);
      SetWindowLong(hHandle, GWL_STYLE, Style or WS_MINIMIZEBOX);
      DrawMenuBar (hHandle);
   end;
end;

procedure THISysMenu._work_doShowMaximizeButton;
begin
   hHandle := ReadInteger(_Data,_data_Handle,0);
   if (hHandle <> 0) then begin
      Style := GetWindowLong(hHandle, GWL_STYLE);
      SetWindowLong(hHandle, GWL_STYLE, Style or WS_MAXIMIZEBOX);
      DrawMenuBar (hHandle);
   end;
end;

procedure THISysMenu._work_doShowSYSMENU;
begin
   hHandle := ReadInteger(_Data,_data_Handle,0);
   if (hHandle <> 0) then
    begin
      Style := GetWindowLong(hHandle, GWL_STYLE);
      SetWindowLong(hHandle, GWL_STYLE, Style or WS_SYSMENU );
      DrawMenuBar (hHandle);
    end;
end;

procedure THISysMenu._work_doPopupSysMenu;
var
  pos: TPoint;
  LItem: integer;
  LMenu: HMENU;  
begin
  hHandle := ReadInteger(_Data,_data_Handle,0);
  GetCursorPos(pos);
  LMenu := GetSystemMenu(hHandle, false);      
  with pos do
    LItem := integer(TrackPopupMenu(LMenu, TPM_LEFTBUTTON or
                                     TPM_RIGHTBUTTON or TPM_RETURNCMD,
                                     x, y, 0, hHandle, nil));
  _hi_onEvent(_event_onPopupSysMenu, LItem);
end;

end.