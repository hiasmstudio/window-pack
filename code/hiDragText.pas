unit hiDragText;

interface

uses Windows,Kol,Share,DropSourcek,Debug;

type
  THIDragText = class(TDebug)
   private
     fDrop: TDropTextSource;
     procedure onDropEvent(Sender: TObject; DragType: TDragType; var ContinueDrop: Boolean);
     procedure onFeedbackEvent(Sender: TObject; Effect: LongInt; var UseDefaultCursors: Boolean);
   public
    _data_Text:THI_Event;
    _event_onResult:THI_Event;
    _event_onDrop:THI_Event;
    _event_onFeedBack:THI_Event;
    _prop_DragDefaultCursor:Boolean;
    _prop_Copy:Boolean;
    _prop_Move:Boolean;
    _prop_Link:Boolean;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doDrag(var _Data:TData; Index:word);
    procedure _work_doDragDefaultCursor(var _Data:TData; Index:word);
  end;

implementation

constructor THIDragText.Create;
begin
   inherited Create;
   fDrop := TDropTextSource.Create;
   fDrop.OnFeedback := onFeedbackEvent;
   fDrop.OnDrop := onDropEvent;
end;

destructor THIDragText.Destroy;
begin
   if Assigned(fDrop) then fDrop.destroy;
   inherited Destroy;
end;

procedure THIDragText.onFeedbackEvent;
begin
  UseDefaultCursors := _prop_DragDefaultCursor;
  _hi_onEvent(_event_onFeedBack,integer(Effect));
end;

procedure THIDragText.onDropEvent;
begin
  _hi_onEvent(_event_onDrop,integer(DragType));
end;

procedure THIDragText._work_doDrag;
var
  res: TDragResult;
  Text: string;
begin
  Text := ReadString(_Data,_data_Text);
  if Text='' then exit;
  fDrop.Text := Text;
  fDrop.Dragtypes := [];
  if _prop_Copy then fDrop.Dragtypes := [dtCopy];
  if _prop_Move then fDrop.Dragtypes := fDrop.Dragtypes + [dtMove];
  res := fDrop.Execute;
  _hi_onEvent(_event_onResult,integer(res));
end;

procedure THIDragText._work_doDragDefaultCursor;
begin
  _prop_DragDefaultCursor := ReadBool(_Data);
end;

end.
