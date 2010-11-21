unit hiFilePart;

interface

uses Kol,Share,Debug;

type
  THIFilePart = class(TDebug)
   private
   public
    _prop_ExtPoint:byte;
    _prop_NameWOExt:byte;

    _data_FileName:THI_Event;
    _event_onExt:THI_Event;
    _event_onName:THI_Event;
    _event_onPath:THI_Event;

    procedure _work_doPart(var _Data:TData; Index:word);
  end;

implementation

procedure THIFilePart._work_doPart;
var s:string;
begin
   s := ReadString(_Data,_data_FileName,'');
   if s = '' then exit;

   // Dir name
   _hi_OnEvent(_event_onPath,ExtractFilePath(s));
   // file name
   if _prop_NameWOExt = 0 then
     _hi_OnEvent(_event_onName,ExtractFileNameWOext(s))
   else _hi_OnEvent(_event_onName,ExtractFileName(s));
   // ext name
   s := ExtractFileExt(s);
   if _prop_ExtPoint = 1 then delete(s,1,1);
   _hi_CreateEvent(_Data,@_event_onExt,s);
end;

end.
