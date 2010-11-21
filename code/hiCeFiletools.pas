unit hiCeFileTools;

interface

uses Kol,Share,KolRapi,windows,Debug;

type
  THICeFileTools = class(TDebug)
   private
   public
    _data_NewFileName:THI_Event;
    _data_FileName:THI_Event;
    _event_onEnd:THI_Event;

    procedure _work_doMove(var _Data:TData; Index:word);
    procedure _work_doCopy(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);
    procedure _work_doFileExists(var _Data:TData; Index:word);
  end;

implementation


procedure THICeFileTools._work_doMove;
var
   F1,F2:PWideChar;
begin
   F1 := StringToOleStr(ReadString(_Data,_data_FileName,''));
   F2 := StringToOleStr(ReadString(_Data,_data_NewFileName,''));
   CeMoveFile(F1,F2);
   if CeFileExists(F2) then
     _hi_CreateEvent(_Data,@_event_onEnd);
end;

procedure THICeFileTools._work_doCopy;
var
   F1,F2:PWideChar;
begin
   F1 := StringToOleStr(ReadString(_Data,_data_FileName,''));
   F2 := StringToOleStr(ReadString(_Data,_data_NewFileName,''));
   CeCopyFile(F1,F2,false);
   if CeFileExists(F2) then
     _hi_CreateEvent(_Data,@_event_onEnd);
end;

procedure THICeFileTools._work_doDelete;
var F1:PWideChar;
begin
   F1 := StringToOleStr(ReadString(_Data,_data_FileName,''));
   CeDeleteFile(F1);
   if not CeFileExists(F1) then
     _hi_CreateEvent(_Data,@_event_onEnd);
end;

procedure THICeFileTools._work_doFileExists;
begin
   _hi_CreateEvent(_Data,@_event_onEnd,integer(CeFileExists(StringToOleStr(ReadString(_Data,_data_FileName,'')))));
end;

end.
