unit hiPosition;

interface

uses Kol,Share,Debug;

type
  THIPosition = class(TDebug)
   private
    FPos:integer;
   public
    _prop_Target:string;
    _prop_StartPos:integer;
    _prop_ZeroPos:byte;
    _prop_ShortSearch:byte;

    _data_StartPos:THI_Event;
    _data_Target:THI_Event;
    _data_Str:THI_Event;
    _event_onSearch:THI_Event;

    procedure _work_doSearch(var _Data:TData; Index:word);
    procedure _work_doReset(var _Data:TData; Index:word);
    procedure _var_Position(var _Data:TData; Index:word);
  end;

implementation

procedure THIPosition._work_doSearch;
var
   Target,Str:string;
begin
   Str := ReadString(_Data,_data_Str,'');
   Target := ReadString(_Data,_data_Target,_prop_Target);
   if (_prop_ShortSearch = 1)or(FPos = 0) then
     FPos := ReadInteger(_Data,_data_StartPos,_prop_StartPos)
   else inc(FPos,Length(Target)); // здесь определяем позицию следующего поиска

   if FPos <= 0 then FPos := 1; //это для дуракоустойчивости

   if (Str <> '')and(Target <> '') then
     FPos := PosEx(Target,Str,FPos)
   else FPos := 0;

   if (_prop_ZeroPos = 0)or( FPos > 0) then
     _hi_CreateEvent(_Data,@_event_onSearch,Fpos);
end;

procedure THIPosition._work_doReset;
begin
  FPos := 0;
end;

procedure THIPosition._var_Position;
begin
   dtInteger(_Data,FPos);
end;

end.
