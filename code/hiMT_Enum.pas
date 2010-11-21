unit hiMT_Enum;

interface

uses Kol,Share,Debug;

type
  THIMT_Enum = class(TDebug)
   private
    FStop:boolean;
    Item:TData;
    Ind:integer;
   public
    _data_MT:THI_Event;
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


procedure THIMT_Enum._work_doEnum;
Var p: PData;
    l: PList;
    k: integer;
    mt:TData;
begin
  FStop := false;
  mt:=ReadMTData(_Data, _data_MT);

  if mt.data_type=data_null then exit;
  l:=NewList;
  p:=@mt;
  while (p<>nil)and(p.data_type<>data_null) do begin
    l.Add(p);
    p := p.ldata;
  end;
  if _prop_Type = 0 then begin
    k := 1;
    Ind := 0;
  end else begin
    k := -1;
    Ind := l.Count-1;
  end;
    
  while (ind>=0)and(ind<l.Count) do begin
    dtData(item,PData(l.items[ind])^);
    _hi_OnEvent_(_event_onItem,item);
    if FStop then break;
    inc(Ind,k);
  end;
  l.free;
  if FStop and _prop_onBreakEnable then
    _hi_CreateEvent(_Data,@_event_onBreak)
  else
    _hi_CreateEvent(_Data,@_event_onEndEnum);
end;

procedure THIMT_Enum._work_doStop;
begin
  FStop := true;
end;

procedure THIMT_Enum._var_Item;
begin
  dtData(_Data,Item);
end;

procedure THIMT_Enum._var_Index;
begin
  dtInteger(_Data,Ind);
end;

end.
