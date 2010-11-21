unit hiInsert;

interface

uses Kol,Share,Debug;

type
  THIInsert = class(TDebug)
   private
   public
    _prop_Str:string;
    _prop_SubStr:string;
    _prop_Position:integer;
    _prop_Direction:byte;

    _data_Position:THI_Event;
    _data_SubStr:THI_Event;
    _data_Str:THI_Event;
    _event_onInsert:THI_Event;

    procedure _work_doInsert(var _Data:TData; Index:word);
  end;

implementation

procedure THIInsert._work_doInsert;
var
   str,substr:string;
   Pos:integer;
begin
    str := ReadString(_Data,_data_Str,_prop_Str);
    if str <> '' then
     begin
       substr := ReadString(_Data,_data_SubStr,_prop_SubStr);
       Pos := ReadInteger(_Data,_data_Position,_prop_Position);
       case _prop_Direction of
         1: Pos := Length(str) - Pos + 2;
       end;   
       Insert(substr,str,pos);
       _hi_CreateEvent(_Data,@_event_onInsert,str);
     end;
end;

end.
