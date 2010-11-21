unit hiClipboardHook;

interface

uses Share,Windows,kol,Messages,Debug;

type
  THIClipboardHook = class(TDebug)
   private
    FNextViewerHandle:integer;
    FEnable:boolean;
    Parent:PControl;
    OldMessage:TOnMessage;

    function onMessage( var Msg: TMsg; var Rslt: Integer ): Boolean;
    procedure LoadBitmap;
    procedure Init;
   public
    _prop_DataStream:byte;
    _prop_NextHook:byte;

    _data_Text:THI_Event;
    _data_LockHook:THI_Event;
    _data_Handle:THI_Event;
    _event_onBitmap:THI_Event;
    _event_onChange:THI_Event;

    constructor Create(Control:PControl);
    procedure _work_doSetText(var _Data:TData; Index:word);
    procedure _work_doPut(var _Data:TData; Index:word);
  end;

implementation

constructor THIClipboardHook.Create;
begin
   inherited Create;
   Parent := control;
   OldMessage := Control.OnMessage;
   Control.OnMessage := OnMessage;
   InitAdd(Init);
end;

procedure THIClipboardHook.Init;
begin
    FNextViewerHandle := SetClipboardViewer(Parent.Handle);
    FEnable := true
end;

procedure THIClipboardHook.LoadBitmap;
var bmp:PBitmap;
begin
  bmp := NewBitmap(0,0);
  bmp.PasteFromClipboard;
  _hi_OnEvent(_event_onBitmap,bmp);
  bmp.Free;
end;

function THIClipboardHook.onMessage;
begin
  Result := true;
  case Msg.message of
    WM_DRAWCLIPBOARD:
      if FEnable then begin
        if IsClipboardFormatAvailable(CF_BITMAP) then LoadBitmap
        else if IsClipboardFormatAvailable(CF_TEXT) then begin
          if _prop_DataStream = 0 then _hi_OnEvent(_event_onChange)
          else _hi_OnEvent(_event_onChange,Clipboard2Text);
        end;
        if ReadInteger(_data_Empty,_data_LockHook,_prop_NextHook) = 0 then begin
          FEnable := false;
          Rslt := SendMessage(FNextViewerHandle,WM_DRAWCLIPBOARD,0,0);
          FEnable := true;
        end else Rslt := 0;
        Result := true;
        exit;
      end;
    WM_DESTROY:
      begin
        FEnable := false;
        ChangeClipboardChain(Parent.Handle, FNextViewerHandle);
      end;
    WM_CHANGECBCHAIN:
      begin
        if msg.wParam = FNextViewerHandle then begin
          FNextViewerHandle := msg.lParam;
          Rslt := 0;
        end else
          Rslt := SendMessage(FNextViewerHandle, WM_CHANGECBCHAIN, msg.wParam, msg.lParam);
        exit;
      end;
  end;
  Result := _hi_OnMessage(OldMessage,Msg,Rslt);
end;

procedure THIClipboardHook._work_doSetText;
begin
   FEnable := false;
   Text2Clipboard(ReadString(_Data,_data_Text,''));
   FEnable := true;
end;

procedure THIClipboardHook._work_doPut;
var h:integer;
begin
   FEnable := false;
   h := ReadInteger(_Data,_data_Handle,0);
   if h > 0 then
     SetForegroundWindow(h);
   keybd_event(VK_CONTROL,0,0,0);
   keybd_event(86,0,0,0);
   keybd_event(86,0,KEYEVENTF_KEYUP,0);
   keybd_event(VK_CONTROL,0,KEYEVENTF_KEYUP,0);
   FEnable := true;
end;

end.
