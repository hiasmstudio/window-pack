unit hiType_If;

interface

uses Kol,Share,Debug,If_Arg;

type
  THIType_If = class(TDebug)
   private
    function Cmp(t1,t2:PType; mode:integer):boolean;
   public
    _prop_Mode:byte;
    _prop_CompareCount:boolean;
    _prop_CompareIndex:boolean;

    _data_GType2:THI_Event;
    _data_GType1:THI_Event;
    _event_onError:THI_Event;
    _event_onFalse:THI_Event;
    _event_onTrue:THI_Event;

    procedure _work_doCompare(var _Data:TData; Index:word);
  end;

implementation

procedure THIType_If._work_doCompare;
var typ1,typ2:PType;
    
begin
  typ1 := ReadType(_Data,_data_GType1);
  typ2 := ReadType(_Data,_data_GType2);
  if Cmp(typ1,typ2,_prop_mode) then _hi_OnEvent_(_event_onTrue,_Data)
  else _hi_OnEvent_(_event_onFalse,_Data); 
end;

function THIType_If.Cmp;
var op1,op2:TData;
    i,idx:integer;
begin
  Result := false;
  if (t1 = nil) or (t2 = nil) then begin
    CallTypeError('',_event_onError,TYPE_ERR_INVALID_TYPE);
    Exit;
  end;
  if t1.name <> t2.name then Exit;
  if _prop_CompareCount and (t1.count <> t2.count) then Exit;
  for i := 0 to t1.count-1 do begin
    op1 := t1.data[i]^;
    if not _prop_CompareIndex then begin
      idx := t2.IndexOf(t1.NameOf[i]);
      if idx = -1 then Exit else op2 := t2.data[idx]^;
    end else
      if t1.NameOf[i] = t2.NameOf[i] then op2 := t2.data[i]^
      else Exit;
    if not Compare(op1,op2,mode) then Exit;
  end;
  Result := true;
end;

end.
