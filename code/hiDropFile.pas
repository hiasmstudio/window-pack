unit hiDropFile;

interface

uses Windows,Kol,Share,ShellAPI,Messages,DropSourcek,Debug;

type
  THIDropFile = class(TDebug)
   private
     Fp:PControl;
     OldMessage:TOnMessage;
     fDrop: TDropFileSource;

     function onMessage( var Msg: TMsg; var Rslt: Integer ): Boolean;
     procedure Init;
     procedure onDropEvent(Sender: TObject; DragType: TDragType; var ContinueDrop: Boolean);
     procedure onFeedbackEvent(Sender: TObject; Effect: LongInt; var UseDefaultCursors: Boolean);
   public
    //_data_Handle:THI_Event;
    _event_onEndDrop:THI_Event;
    _event_onDropFile:THI_Event;
    _event_onStartDrop:THI_Event;
    _data_List:THI_Event;
    _event_onResult:THI_Event;
    _event_onDrop:THI_Event;
    _event_onFeedBack:THI_Event;
    _prop_DragDefaultCursor:Boolean;
    _prop_Copy:Boolean;
    _prop_Move:Boolean;
    _prop_Link:Boolean;

    constructor Create(Control:PControl);
    destructor Destroy; override;
    procedure _work_doAccept(var _Data:TData; Index:word);
    procedure _work_doDrag(var _Data:TData; Index:word);
    procedure _work_doDragDefaultCursor(var _Data:TData; Index:word);
  end;

implementation

constructor THIDropFile.Create;
begin
   inherited Create;
   Fp := Control;
   OldMessage := Control.OnMessage;
   Control.OnMessage := onMessage;
   InitAdd(Init);
   fDrop := TDropFileSource.Create;
   fDrop.OnFeedback := onFeedbackEvent;
   fDrop.OnDrop := onDropEvent;
end;

procedure THIDropFile.Init;
begin
   DragAcceptFiles(FP.GetWindowHandle,true);
end;

destructor THIDropFile.Destroy;
begin
   Fp.OnMessage := OldMessage;
   DragAcceptFiles(FP.Handle,false);
   if fDrop <> nil then fDrop.destroy;
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

procedure THIDropFile.onFeedbackEvent;
begin
  UseDefaultCursors := _prop_DragDefaultCursor;
  _hi_onEvent(_event_onFeedBack,integer(Effect));
end;

procedure THIDropFile.onDropEvent;
begin
  _hi_onEvent(_event_onDrop,integer(DragType));
end;

procedure THIDropFile._work_doDrag;
var
  res: TDragResult;
  Item: TData;
  eIndex: TData;
  i: integer;
  Arr: PArray;
begin
  Arr := ReadArray(_data_List);
  if Arr=nil then exit;
  fDrop.Files.Clear;
  for i:=0 to Arr._Count-1 do begin
    dtInteger(eIndex,i);
    Arr._Get(eIndex,Item);
    fDrop.Files.Add(ToString(Item))
  end;
  // fDrop.Dragtypes := [dtCopy,dtMove,dtLink];
  fDrop.Dragtypes := [];
  if _prop_Copy then fDrop.Dragtypes := [dtCopy];
  if _prop_Move then fDrop.Dragtypes := fDrop.Dragtypes + [dtMove];
  if _prop_Link then fDrop.Dragtypes := fDrop.Dragtypes + [dtLink];
  res := fDrop.Execute;
  _hi_onEvent(_event_onResult,integer(res));
end;

procedure THIDropFile._work_doDragDefaultCursor;
begin
  _prop_DragDefaultCursor := ReadBool(_Data);
end;

end.
