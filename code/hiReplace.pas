unit hiReplace;

interface

uses Kol,Share,Debug;

{$I def.inc}

type
  THIReplace = class(TDebug)
   private
    Str:string;
    Pos:integer;
    function TestRep(P:integer):boolean;
   public
    _prop_SubStr:string;
    _prop_DestStr:string;

    _data_dest:THI_Event;
    _data_sub_str:THI_Event;
    _data_str:THI_Event;
    _data_Skip:THI_Event;
    _event_onReplace:THI_Event;

    procedure _work_doReplace(var _Data:TData; Index:word);
    procedure _var_CurentStr(var _Data:TData; Index:word);
    procedure _var_CurentPos(var _Data:TData; Index:word);
  end;

implementation

function THIReplace.TestRep(P:integer):boolean;
begin
  Pos := P;
  Result := ToIntegerEvent(_data_Skip)=0;
end;

procedure THIReplace._work_doReplace;
var substr,dest:string;
begin
   Str := ReadString(_Data,_data_str,'');
   substr := ReadString(_Data,_data_sub_str,_prop_SubStr);
   dest := ReadString(_Data,_data_dest,_prop_DestStr);                                
   {$ifdef _PROTECT_MAX_}
   if str <> '' then
   {$endif}
     Replace(Str,substr,dest,TestRep);
   _hi_CreateEvent(_Data,@_event_onReplace,Str);
end;

procedure THIReplace._var_CurentStr;
begin
  dtString(_Data,Str);
end;

procedure THIReplace._var_CurentPos;
begin
  dtInteger(_Data,Pos);
end;

end.
