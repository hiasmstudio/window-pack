unit hiCopy;

interface

uses Kol,Share,Debug;

type
  THICopy = class(TDebug)
   private
   public
    _prop_Position:integer;
    _prop_Count:integer;
    _prop_Direction:byte;

    _data_Count:THI_Event;
    _data_Position:THI_Event;
    _data_Str:THI_Event;
    _event_onCopy:THI_Event;

    procedure _work_doCopy(var _Data:TData; Index:word);
  end;

implementation

procedure THICopy._work_doCopy;
var   str:string;
      Pos,Count:integer;
begin
   str := ReadString(_Data,_data_Str,'');
   if str <> '' then begin
      Pos := ReadInteger(_Data, _data_Position, _prop_Position); 
      Count := ReadInteger(_Data, _data_Count, _prop_Count);
      case _prop_Direction of
        1: Pos := Length(str) - Count - Pos + 2;
      end;   
      if Pos <= 0 then begin 
         Inc(Count, Pos-1);
         Pos := 1;
      end;
      _hi_CreateEvent(_Data, @_event_onCopy, Copy(str,Pos,Count));
   end;
end;

end.
