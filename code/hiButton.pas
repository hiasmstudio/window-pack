unit hiButton;

interface

uses Windows,Messages,Kol,Share,Win;

{$I share.inc}

type
 THIButton = class(THIWin)
   private
     procedure _OnClick(Obj:PObj);
   public
     _event_onClick:THI_Event;
     _prop_Data:TData;
     _prop_Caption:string;
     _prop_DefaultBtn:byte; // изменен тип с boolean на byte
     _prop_RespondToEnter:boolean;
     
     procedure Init; override;
     procedure _work_doCaption(var _Data:TData; Index:word);
 end;

implementation

function WndProcBtnReturnClick( Self_: PControl; var Msg: TMsg; var Rslt: Integer ): Boolean;
begin
  Result := FALSE;
  if ((Msg.message = WM_KEYDOWN) or (Msg.message = WM_KEYUP) or
      (Msg.message = WM_CHAR)) and (Msg.wParam = 13) then
    Msg.wParam := 32;
end;

procedure THIButton.Init;
begin
   Control := NewButton(FParent,_prop_Caption);
   Control.OnClick := _OnClick;
//   Control.DefaultBtn := _prop_DefaultBtn;
   Control.Style := Control.Style or BS_MULTILINE;
   if (_prop_RespondToEnter) and (_prop_DefaultBtn = 1) then
     Control.AttachProc( WndProcBtnReturnClick );
   inherited;
   Case _prop_DefaultBtn of
     0: Control.DefaultBtn := true;
     2: Control.CancelBtn  := true;
   end;
end;

procedure THIButton._work_doCaption;
begin
   Control.Caption := ToString(_Data);
end;

procedure THIButton._OnClick;
begin
  _hi_OnEvent_(_event_onClick,_prop_Data);
end;

end.