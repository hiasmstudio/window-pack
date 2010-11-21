unit hiPosWindow;

interface

uses Kol,Share,Windows,Debug;

type
  THIPosWindow = class(TDebug)
   private
   public
    _prop_Left:integer;
    _prop_Top:integer;

    _data_Top:THI_Event;
    _data_Left:THI_Event;
    _data_Handle:THI_Event;

    procedure _work_doLeft(var _Data:TData; Index:word);
    procedure _work_doTop(var _Data:TData; Index:word);
    procedure _var_CurrentLeft(var _Data:TData; Index:word);
    procedure _var_CurrentTop(var _Data:TData; Index:word);
  end;

implementation


procedure THIPosWindow._work_doLeft;
var
   h:THandle;
   t:tagWINDOWPLACEMENT;
begin
   h := ReadInteger(_Data,_data_Handle,0);
   t.length := sizeof(t);
   GetWindowPlacement(h,@t);
   SetWindowPos(h,0,ReadInteger(_Data,_data_Left,_prop_Left),t.rcNormalPosition.Top,0,0,SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
end;

procedure THIPosWindow._work_doTop;
var
    h:THandle;
    t:tagWINDOWPLACEMENT;
begin
   h := ReadInteger(_Data,_data_Handle,0);
   t.length := sizeof(t);
   GetWindowPlacement(h,@t);
   SetWindowPos(h,0,t.rcNormalPosition.Left,ReadInteger(_Data,_data_Top,_prop_Top),0,0,SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
end;

procedure THIPosWindow._var_CurrentLeft;
var
    h:HWND;
    t:tagWINDOWPLACEMENT;
//    r:TRect;
begin
//   h := ReadInteger(_Data,_data_Handle,0);
//   GetWindowRect(h,r);
//   dtInteger(_Data,r.left);

   h := ReadInteger(_Data,_data_Handle,0);

   t.length := sizeof(t);
   GetWindowPlacement(h,@t);
   
   dtInteger(_Data,t.rcNormalPosition.Left);
end;

procedure THIPosWindow._var_CurrentTop;
var
    h:THandle;
    t:tagWINDOWPLACEMENT;
//    r:TRect;
begin
   {
   h := ReadInteger(_Data,_data_Handle,0);
   GetWindowRect(h,r);
   dtInteger(_Data,r.Top);
   }
   h := ReadInteger(_Data,_data_Handle,0);

   t.length := sizeof(t);
   GetWindowPlacement(h,@t);
   
   dtInteger(_Data,t.rcNormalPosition.Top);
end;

end.
