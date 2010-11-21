unit hiCeFileStream;

interface

uses Kol,KolRapi,Share,windows,Debug;

type
  THICeFileStream = class(TDebug)
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

procedure THICeFileStream._work_doOpen;
begin
  Open(_Data);
  _hi_CreateEvent(_Data,@_event_onLoad,Fs);
end;

procedure THICeFileStream.Open;
var fn:string;
begin
  Free_And_Nil(Fs);
  fn := ReadString(_Data,_data_FileName,_prop_FileName);
  if _prop_Mode = 2 then
    Fs := NewCeReadWriteFileStream(StringToOleStr(fn))
  else if _prop_Mode = 1 then
    Fs := NewCeWriteFileStream(StringToOleStr(fn))
  else if CeFileExists(StringToOleStr(Fn)) then
    Fs := NewCeReadFileStream(StringToOleStr(Fn))
  else
    MessageBox(ReadHandle,PChar('File <'+fn+'> not found!'),'File stream Error',MB_OK);
end;

procedure THICeFileStream._work_doClose;
begin
  Free_And_Nil(Fs);
end;

procedure THICeFileStream._work_doCopyFromStream;
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

procedure THICeFileStream._work_doPosition;
begin
  if Assigned(Fs) then
    Fs.Position := ToInteger(_Data);
end;

procedure THICeFileStream._var_Stream;
begin
  dtNull(_Data);
  if Assigned(Fs) then dtStream(_Data,Fs)
end;

procedure THICeFileStream._var_Size;
begin
  dtNull(_Data);
  if Assigned(Fs) then dtInteger(_Data,Fs.Size)
end;

procedure THICeFileStream._var_Position;
begin
  dtNull(_Data);
  if Assigned(Fs) then dtInteger(_Data,Fs.Position)
end;

end.
