unit hiFileStream;

interface

uses Kol,Share,windows,Debug;

type
  THIFileStream = class(TDebug)
   private
    Fs:PStream;
    procedure Open(var _Data:TData);
   public
    _prop_FileName:string;
    _prop_Mode:byte;
    _prop_AutoCopy:boolean;

    _data_FileName:THI_Event;
    _event_onLoad:THI_Event;

    procedure _work_doOpen(var _Data:TData; Index:word);
    procedure _work_doClose(var _Data:TData; Index:word);
    procedure _work_doCopyFromStream(var _Data:TData; Index:word);
    procedure _work_doPosition(var _Data:TData; Index:word);
    procedure _var_Stream(var _Data:TData; Index:word);
    procedure _var_Size(var _Data:TData; Index:word);
    procedure _var_Position(var _Data:TData; Index:word);
  end;

implementation


procedure THIFileStream._work_doOpen;
begin
  Open(_Data);
  _hi_CreateEvent(_Data,@_event_onLoad,Fs);
end;

procedure THIFileStream.Open;
var fn:string;
begin
  Free_And_Nil(Fs);
  fn := ReadString(_Data,_data_FileName,_prop_FileName);
  if _prop_Mode = 2 then
    Fs := NewReadWriteFileStream(fn)
  else if _prop_Mode = 1 then
    Fs := NewWriteFileStream(fn)
  else if FileExists(Fn) then
    Fs := NewReadFileStream(Fn)
  else
    MessageBox(ReadHandle,PChar('File <'+fn+'> not found!'),'File stream Error',MB_OK);
end;

procedure THIFileStream._work_doClose;
begin
  Free_And_Nil(Fs);
end;

procedure THIFileStream._work_doCopyFromStream;
var s:PStream;O:boolean;
begin
  O := (not Assigned(Fs))and _prop_AutoCopy;
  if O then Open(_Data);
  if Assigned(Fs) and _isStream(_Data) then begin
    if _prop_Mode = 0 then
      MessageBox(0,'Please set Mode property to Write','File stream Error',MB_OK)
    else begin
      s := ToStream(_Data);
      s.Position := 0;
      if (_prop_Mode=2)and O then Fs.Position := Fs.Size;
      Stream2Stream(Fs,s,s.Size);
    end;
  end;
  if O then Free_And_Nil(Fs);
end;

procedure THIFileStream._work_doPosition;
begin
  if Assigned(Fs) then
    Fs.Position := ToInteger(_Data);
end;

procedure THIFileStream._var_Stream;
begin
  dtNull(_Data);
  if Assigned(Fs) then dtStream(_Data,Fs)
end;

procedure THIFileStream._var_Size;
begin
  dtNull(_Data);
  if Assigned(Fs) then dtInteger(_Data,Fs.Size)
end;

procedure THIFileStream._var_Position;
begin
  dtNull(_Data);
  if Assigned(Fs) then dtInteger(_Data,Fs.Position)
end;

end.
