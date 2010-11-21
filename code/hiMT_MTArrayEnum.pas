unit hiMT_MTArrayEnum; { Компонент MT_MTArrayEnum (перебор всех элемнтов массива MT-потоков) ver 1.00 }

interface

uses Kol,Share,Debug;

type
  ThiMT_MTArrayEnum = class(TDebug)
   private
    FStop:boolean;
    Item:TData;
    eIndex:TData;
   public
    _data_Array:THI_Event;
    _event_onItem:THI_Event;
    _event_onEndEnum:THI_Event;
    _event_onBreak:THI_Event;
    _prop_Type:byte;
    _prop_onBreakEnable:boolean;

    procedure _work_doEnum(var _Data:TData; Index:word);
    procedure _work_doStop(var _Data:TData; Index:word);
    procedure _var_Item(var _Data:TData; Index:word);
    procedure _var_Index(var _Data:TData; Index:word);
  end;

implementation

procedure ThiMT_MTArrayEnum._work_doEnum;
var Arr:PArray;
    k,Ind:integer;
begin
   FStop := false;
   Arr := ReadArray(_data_Array);
   if Arr = nil then  exit;
   if _prop_Type = 0 then begin
      k := 1;
      Ind := 0;
   end else begin
      k := -1;
      Ind := Arr._Count-1;
   end;
   dtInteger(eIndex,Ind);

   while Arr._Get(eIndex,Item) do begin
      _hi_OnEvent_(_event_onItem,Item);
      if FStop then break;
      inc(Ind,k);
      dtInteger(eIndex,Ind);
   end;
   if FStop and _prop_onBreakEnable then
      _hi_CreateEvent(_Data,@_event_onBreak)
   else
     _hi_CreateEvent(_Data,@_event_onEndEnum);
end;

procedure ThiMT_MTArrayEnum._work_doStop;
begin
  FStop := true;
end;

procedure ThiMT_MTArrayEnum._var_Item;
begin
   _Data := Item;
end;

procedure ThiMT_MTArrayEnum._var_Index;
begin 
  dtData(_Data,eIndex);
end;

end.