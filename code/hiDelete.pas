unit hiDelete;

interface

uses Kol,Share,Debug;

type
  THIDelete = class(TDebug)
   private
   public
    _prop_Position:integer;
    _prop_Count:integer;
    _prop_Direction:byte;    

    _data_Count:THI_Event;
    _data_Position:THI_Event;
    _data_Str:THI_Event;
    _event_onDelete:THI_Event;

    procedure _work_doDelete(var _Data:TData; Index:word);
  end;

implementation


procedure THIDelete._work_doDelete;
var
   str:string;
   Pos,Count:integer;
begin
    str := ReadString(_Data,_data_Str,'');
    if str <> '' then
     begin
       Pos := ReadInteger(_data,_data_Position,_prop_Position);
       Count := ReadInteger(_data,_data_Count,_prop_Count);
       case _prop_Direction of
         1: Pos := Length(str) - Count - Pos + 2;
       end;   
       Delete(str,Pos,Count);
       _hi_OnEvent(_event_onDelete,str);
     end;
end;

end.
