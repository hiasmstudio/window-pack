unit hiPlayMIDI;

interface

uses Windows,Kol,Share,Debug,BASS,MMSystem;

type
  THIPlayMIDI = class(TDebug)
   private
    fFileName : string;
    buf: array[0..256] of char;
    pos: array[0..256] of char;
   public

    _prop_FileName:string;
    _data_FileName:THI_Event;
    _event_onEndPlay:THI_Event;
    _event_onStop:THI_Event;
    
    constructor Create;
    destructor Destroy; override;   
    procedure _work_doPlay(var _Data:TData; Index:word);
    procedure _work_doPause(var _Data:TData; Index:word);
    procedure _work_doResume(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _var_Length(var _Data:TData; Index:word);    
  end;

var
   Tag: Longint;
   Wnd: HWND;
   Resume: boolean = false;
   Play: boolean = false;
implementation

function WndProcMIDI( Sender: PControl; var Msg: TMsg; var Rslt: Integer ): Boolean;
var   fTag:THIPlayMIDI; 
begin
   Result := false;
   fTag := THIPlayMIDI(Tag);   
   if Msg.Message = MM_MCINOTIFY then
      if Msg.wParam = MCI_NOTIFY_SUCCESSFUL then begin
         if Play then
            _hi_onEvent(fTag._event_onEndPlay)
         else
            _hi_onEvent(fTag._event_onStop);
         Play := false;   
      end;
end;

constructor THIPlayMIDI.Create;
begin
   inherited;
   Wnd := 0;   
   if not Assigned(Applet) then exit;
   Wnd := Applet.Handle;
   Applet.AttachProc( WndProcMIDI );
   Tag := Longint(Self);
end;

destructor THIPlayMIDI.Destroy;
begin
   MCISendString(PChar('close midi wait'), nil, 0, 0);
   inherited;
end;

// Play Midi
procedure THIPlayMIDI._work_doPlay;
begin
   MCISendString(PChar('close midi wait'), nil, 0, 0);
   fFileName := ReadString(_Data,_data_FileName,_prop_FileName);
   if (fFileName = '') or not FileExists(fFileName) then exit;
   MCISendString(PChar('open ' + fFileName + ' type sequencer alias midi wait'), nil, 0, 0);
   MCISendString(PChar('set midi time format milliseconds wait'), nil, 0, 0);
   buf[0] := #0;
   pos[0] := #0;
   MCISendString(PChar('status midi length wait'), @buf, 256, 0);
   Play := true;
   MCISendString(PChar('play midi notify'), nil, 0, Wnd);
   Resume := false;
end;

// Pause Midi
procedure THIPlayMIDI._work_doPause;
begin
   if (fFileName = '') or not FileExists(fFileName) then exit;
   if not Resume then begin
      MCISendString(PChar('pause midi wait'), nil, 0, 0);
      MCISendString(PChar('status midi position wait'), @pos, 256, 0);      
      Resume := true;   
   end;
end;

// Resume Midi
procedure THIPlayMIDI._work_doResume;
begin
   if (fFileName = '') or not FileExists(fFileName) then exit;
   if Resume then begin
      MCISendString(PChar('play midi from ' + string(pos) +' notify'), nil, 0, Wnd);
      Resume := false;
   end;      
end;

// Stop Midi
procedure THIPlayMIDI._work_doStop;
begin
   if (fFileName = '') or not FileExists(fFileName) then exit;
   if not Play then exit; 
   Play := false;
   MCISendString(PChar('stop midi notify'), nil, 0, Wnd);
   MCISendString(PChar('close midi wait'), nil, 0, 0);
   buf[0] := #0;
   pos[0] := #0;
end;

procedure THIPlayMIDI._var_Length;
begin
   dtNull(_Data);
   if string(buf) <> '' then dtInteger(_Data, str2int(string(buf)));
end;

end.