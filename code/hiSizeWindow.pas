unit hiSizeWindow; 

interface 

uses kol,Windows,Share,Debug;

type 
  THISizeWindow = class(TDebug)
   private
   public
    _prop_Width:integer;
     _prop_Height:integer;

     _data_Height:THI_Event;
     _data_Width:THI_Event;
     _data_Handle:THI_Event;

     procedure _work_doWidth(var _Data:TData; Index:word);
     procedure _work_doHeight(var _Data:TData; Index:word);
     procedure _var_CurrentWidth(var _Data:TData; Index:word);
     procedure _var_CurrentHeight(var _Data:TData; Index:word);
  end;

implementation 

procedure THISizeWindow._work_doWidth; 
var 
  h:THandle;
  r:TRect;
begin
  h := ReadInteger(_Data,_data_Handle,0);
  GetWindowRect(h,r);
  SetWindowPos(h,0,0,0,ReadInteger(_Data,_data_Width,0),r.Bottom-r.Top,SWP_NOMOVE or SWP_NOZORDER);
end; 

procedure THISizeWindow._work_doHeight; 
var 
  h:THandle;
  r:TRect;
begin 
  h := ReadInteger(_Data,_data_Handle,0);
  GetWindowRect(h,r);
  SetWindowPos(h,0,0,0,r.Right-r.Left,ReadInteger(_Data,_data_Height,0),SWP_NOMOVE or SWP_NOZORDER);
end; 

procedure THISizeWindow._var_CurrentWidth; 
var 
  h:THandle;
  r:TRect;
begin 
  h := ReadInteger(_Data,_data_Handle,0);
  GetWindowRect(h,r);
  dtInteger(_Data,r.Right - r.Left);
end;

procedure THISizeWindow._var_CurrentHeight; 
var 
  h:THandle;
  r:TRect;
begin 
  h := ReadInteger(_Data,_data_Handle,0);
  GetWindowRect(h,r);
  dtInteger(_Data,r.Bottom - r.Top);
end; 

end.
