unit hiCeDirTools;

interface

uses Windows,Kol,KolRapi,Share,Debug;

type
  THICeDirTools = class(TDebug)
   private
   public
    _data_Dest:THI_Event;
    _data_Source:THI_Event;
    _event_onOK:THI_Event;

    procedure _work_doCreate(var _Data:TData; Index:word);
    procedure _work_doRename(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);
    procedure _work_doExists(var _Data:TData; Index:word);
    procedure _work_doGetSize(var _Data:TData; Index:word);
  end;

implementation

procedure THICeDirTools._work_doCreate;
var s:string;
    b:byte;
begin
  s := ReadString(_Data,_data_Source,'');
  b := byte(CeCreateDirectory(StringToOleStr(s),nil));
  _hi_CreateEvent(_Data,@_event_onOK,b);
end;

procedure THICeDirTools._work_doRename;
var s:string;
    b:byte;
begin
  s := ReadString(_Data,_data_Source,'');
  b := Byte(CeMoveFile(StringToOleStr(s),StringToOleStr(ReadString(_Data,_data_Dest,''))));
  _hi_CreateEvent(_Data,@_event_onOK,b);
end;

procedure THICeDirTools._work_doDelete;
var b: byte;
begin
  b := Byte(CeRemoveDirectory(StringToOleStr(ReadString(_Data,_data_Source))));
  _hi_CreateEvent(_Data,@_event_onOK,b);
end;

procedure THICeDirTools._work_doExists;
var s:string;
begin
  s := ReadString(_Data,_data_Source,'');
  _hi_CreateEvent(_Data,@_event_onOK,integer(CeDirectoryExists(StringToOleStr(s))) + 2 * integer(CeFileExists(StringToOleStr(s))));
end;

type T=record L,H:integer end;

procedure THICeDirTools._work_doGetSize;
var Sz:Int64;
    DirName:String;
begin
  DirName := ReadString(_Data,_data_Source,'');
  if DirName[Length(DirName)] = '\' then Delete(DirName,Length(DirName),1);
  Sz := CeDirSize(StringToOleStr(DirName));
  if (T(Sz).H = 0) and (T(Sz).L >= 0) then dtInteger(_Data,T(Sz).L)
  else dtReal(_Data,Sz);
  _hi_CreateEvent_(_Data,@_event_onOK);
end;

end.
