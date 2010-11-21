unit hiDirectShowPlayer;

interface

uses Windows,Kol,Share,Debug,dshow;

type
  THIDirectShowPlayer = class(TDebug)
   private
	MyGraphBuilder : IGraphBuilder;
	VideoWindow : IVideoWindow;
	MyMediaControl : IMediaControl;
	MyMediaPosition : IMediaPosition;
	BasicVideo: IBasicVideo;
	MediaEvent: IMediaEvent;
	ho: HWND;
    th:PThread;

    function Execute(Sender:PThread): Integer;
   public  
    _prop_Filename:string;
                
    _data_Handle:THI_Event;
    _data_FileName:THI_Event;
    _event_onEndPlay:THI_Event;

    procedure _work_doPlay(var _Data:TData; Index:word);
    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _work_doFullScreen(var _Data:TData; Index:word);
    procedure _var_Position(var _Data:TData; Index:word);
    procedure _var_Length(var _Data:TData; Index:word);
  end;

implementation

uses ActiveX;

function THIDirectShowPlayer.Execute(Sender:PThread): Integer;
var
  evCode:LongInt;
begin
    repeat
      MediaEvent.WaitForCompletion(1000, evCode);
      if evCode = EC_COMPLETE then 
        _hi_onEvent(_event_onEndPlay);
    until Sender.Terminated or (MyGraphBuilder = nil);
    Result := 0;
end;

procedure THIDirectShowPlayer._work_doPlay;
var fn:string;
    h:cardinal;
begin
   _work_doClose(_data, 0);          
   fn := Share.ReadString(_Data, _data_FileName, _prop_Filename);
   ho := Share.ReadInteger(_Data, _data_Handle);

    CoInitialize(nil);
    
	CoCreateInstance(CLSID_FilterGraph,nil,CLSCTX_INPROC_SERVER,IID_IGraphBuilder,MyGraphBuilder);

	MyGraphBuilder.RenderFile(PWideChar(WideString(fn)),nil);

	MyGraphBuilder.QueryInterface(IID_IVideoWindow,VideoWindow);

	VideoWindow.put_Owner(ho);
	VideoWindow.put_WindowStyle(WS_CHILD OR WS_CLIPSIBLINGS);
	
	MyGraphBuilder.QueryInterface(IID_IMediaControl,MyMediaControl);
	MyGraphBuilder.QueryInterface(IID_IMediaPosition,MyMediaPosition);
	
	MyGraphBuilder.QueryInterface(IID_IBasicVideo,BasicVideo);
	MyGraphBuilder.QueryInterface(IID_IMediaEvent,MediaEvent);

	MyMediaControl.Run;
//	MediaEvent.WaitForCompletion(INFINITE, evCode);

    if Assigned(th) then
      th.Free;
 
    th := {$ifdef F_P}NewThreadforFPC{$else}NewThread{$endif};
    th.OnExecute := Execute;
    th.Resume;
end;

procedure THIDirectShowPlayer._work_doPosition;
begin
    MyMediaPosition.put_CurrentPosition(ToReal(_Data));
end;

procedure THIDirectShowPlayer._work_doClose;
begin
    if not assigned(MyGraphBuilder) then exit;
    
    MyMediaControl.Stop;
//    MyMediaControl.Release;
//    MyMediaPosition.Release;
//    BasicVideo.Release;
//    MediaEvent.Release;
//    MyGraphBuilder.Release;
    MyGraphBuilder := nil;
    
    th.Free;
    th := nil;
end;

procedure THIDirectShowPlayer._work_doFullScreen;
var r:TRect;
    w,h:longint;
    VideoAspect,ParentAspect:real;
    NewHeight, NewWidth, NewPosLeft, NewPosTop:integer;   
begin
    GetClientRect(ho, r);
    BasicVideo.GetVideoSize(w, h);
    
    VideoAspect := h / w;
	ParentAspect := r.bottom / r.right;

    NewPosTop := 0;
    NewPosLeft := 0;
	if (VideoAspect > ParentAspect) then
	  begin
		NewHeight := r.bottom;
		NewWidth := round(NewHeight / VideoAspect);
		NewPosLeft := round((r.right - NewWidth) / 2);
	  end
	else if (VideoAspect < ParentAspect) then
	  begin
		NewWidth := r.right;
		NewHeight := Round(NewWidth * VideoAspect);
		NewPosTop := round(abs(r.bottom - NewHeight) / 2);
	  end
	else
	  begin
		NewWidth := r.right;
		NewHeight := r.bottom;
	  end;
	
    VideoWindow.SetWindowPosition(NewPosLeft, NewPosTop, NewWidth, NewHeight);
    MyMediaControl.Run;
end;

procedure THIDirectShowPlayer._var_Position;
var d:double;
begin
  MyMediaPosition.get_CurrentPosition(d);
  dtReal(_Data, d);
end;

procedure THIDirectShowPlayer._var_Length;
var d:double;
begin
  MyMediaPosition.get_Duration(d);
  dtReal(_Data, d);
end;

end.
