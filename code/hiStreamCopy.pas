unit hiStreamCopy;

interface

uses Kol,Share,Debug;

type
  THIStreamCopy = class(TDebug)
   private
   public
    _prop_Count:integer;

    _event_onCopy:THI_Event;
    _data_Count:THI_Event;
    _data_Source:THI_Event;
    _data_Dest:THI_Event;

    procedure _work_doCopy(var _Data:TData; Index:word);
  end;

implementation

procedure THIStreamCopy._work_doCopy;
var
  st1,st2:PStream;
  Count:cardinal;
  Pos:cardinal;
begin
   st1 := ReadStream(_Data,_data_Dest,nil);
   st2 := ReadStream(_Data,_data_Source,nil);
   Count := ReadInteger(_Data,_data_Count,_prop_Count);
   if(st1 <> nil)and(st2 <> nil)then
    begin
      pos := st2.Position;
      Stream2Stream(st1,st2,Count);
      _hi_OnEvent(_event_onCopy,integer(st2.Position - pos));
    end;
end;

end.
