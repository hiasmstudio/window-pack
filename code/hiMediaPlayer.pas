unit hiMediaPlayer;

interface

uses Kol,Share,Media,Windows,Messages,mmsystem,Debug;

type
  THIMediaPlayer = class(TDebug)
   private
    FMedia:PKOLMediaPlayer;
    oldMessage:TOnMessage;
    WndH:HWND;
    Th:PTimer;
    //procedure onEndPlay( Sender: PKOLMediaPlayer; NotifyValue: TMPNotifyValue );
    //function _OnMes( var Msg: TMsg; var Rslt: Integer ): Boolean;
    procedure _OnEnd(Sender:PObj);
    procedure SetVideoScale(Value:byte);
   public
    _prop_Filename:string;
    _data_FileName:THI_Event;
    _data_Handle:THI_Event;
    _event_onEndPlay:THI_Event;

    constructor Create{(Control:PControl)};
    destructor Destroy; override;
    procedure _work_doPlay(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _work_doPause(var _Data:TData; Index:word);
    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _var_Position(var _Data:TData; Index:word);
    procedure _var_Length(var _Data:TData; Index:word);
    property _prop_VideoScale:byte write SetVideoScale;
  end;

implementation

constructor THIMediaPlayer.Create;
begin
   inherited Create;
   FMedia := NewKOLMediaPlayer('',ReadHandle);
   FMedia.DeviceType := mmAutoSelect;
   FMedia.Display := ReadHandle;

   Th := NewTimer(300);
   Th.OnTimer := _OnEnd;
   //FMedia.OnNotify := onEndPlay;
   //SetWindowLong(FMedia.Display,GWL_WNDPROC,);
   //oldMessage := Control.OnMessage;
   //Control.OnMessage := _OnMes;
end;

procedure THIMediaPlayer._OnEnd;
begin
   if FMedia.Position = FMedia.Length then
    begin
      th.Enabled := false;
      _hi_OnEvent(_event_onEndPlay);        
    end;
end;

{
function  THIMediaPlayer._OnMes;
begin
   if Msg.message = MM_MCINOTIFY then
    if FMedia.Position = FMedia.Length then
     _hi_OnEvent(_event_onEndPlay);
   Result := oldMessage(Msg,Rslt);
end;
}
procedure THIMediaPlayer.SetVideoScale;
begin
   FMedia.Scale := Value;
end;

destructor THIMediaPlayer.Destroy;
begin
   FMedia.Free;
   inherited Destroy;
end;

procedure THIMediaPlayer._work_doPlay;
var
   FName:string;
begin
   FName := ReadString(_Data,_data_FileName,_prop_FileName);
   WndH := ReadInteger(_Data,_data_Handle,0);
   if FileExists(FName) then
    begin
     FMedia.Close;
     FMedia.FileName := FName;
     FMedia.Open;
     FMedia.Play(WndH,0,FMedia.Length);
     //debug(int2str(FMedia.Length));
     Th.Enabled := true;
    end;
end;

procedure THIMediaPlayer._work_doStop;
begin
   FMedia.Stop;
   FMedia.Position := 0;
   th.Enabled := false;
end;

procedure THIMediaPlayer._work_doClose;
begin       
   _work_doStop(_Data,0);
   FMedia.Close;
end;

procedure THIMediaPlayer._work_doPause;
begin
   FMedia.Pause := not FMedia.Pause;
   th.Enabled := not FMedia.Pause;
end;

procedure THIMediaPlayer._work_doPosition;
begin
   if FMedia.Length > 0 then
    begin
      FMedia.Position := ToInteger(_Data);
      FMedia.Play(WndH,0,FMedia.Length);
    end;
end;

procedure THIMediaPlayer._var_Position;
begin
    dtInteger(_Data,FMedia.Position);
end;

procedure THIMediaPlayer._var_Length;
begin
    dtInteger(_Data,FMedia.Length);
end;

{
procedure THIMediaPlayer.onEndPlay;
begin
  _hi_OnEvent(_event_onEndPlay);
end;
}

end.
