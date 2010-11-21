unit hiDropFile;

interface

uses Kol,Share,Windows,ShellAPI,messages,Debug;

type
  THIDropFile = class(TDebug)
   private
     Fp:PControl;
     OldMessage:TOnMessage;

     function onMessage( var Msg: TMsg; var Rslt: Integer ): Boolean;
     procedure Init;
   public
    //_data_Handle:THI_Event;
    _event_onEndDrop:THI_Event;
    _event_onDropFile:THI_Event;
    _event_onStartDrop:THI_Event;

    constructor Create(Control:PControl);
    destructor Destroy; override;
    procedure _work_doAccept(var _Data:TData; Index:word);
  end;

implementation

constructor THIDropFile.Create;
begin
   inherited Create;
   Fp := Control;
   OldMessage := Control.OnMessage;
   Control.OnMessage := onMessage;
   InitAdd(Init);
end;

procedure THIDropFile.Init;
begin
   DragAcceptFiles(FP.GetWindowHandle,true);
end;

destructor THIDropFile.Destroy;
begin
   Fp.OnMessage := OldMessage;
   DragAcceptFiles(FP.Handle,false);
   inherited Destroy;
end;

procedure THIDropFile._work_doAccept;
begin
   DragAcceptFiles(FP.Handle,ReadBool(_Data));
end;

function THIDropFile.onMessage;
var f:string;
    i,count:word;
begin
  case Msg.message of
   WM_DROPFILES:
    begin
       _hi_OnEvent(_event_onStartDrop);
       Count := DragQueryFile(Msg.WParam,Cardinal(-1),nil,0);
       for i := 0 to Count-1 do
        begin
         SetLength(f,MAX_PATH);
         SetLength(f,DragQueryFile(Msg.WParam,i,@f[1],MAX_PATH-1));
         _hi_onEvent(_event_onDropFile,f);
        end;
       DragFinish(Msg.WParam);
       _hi_OnEvent(_event_onEndDrop);
    end;
  end;
  Result := _hi_OnMessage(OldMessage,Msg,Rslt);
end;

end.
