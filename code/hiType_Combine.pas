unit hiType_Combine;

interface

uses Kol,Share,Debug;

type
  THIType_Combine = class(TDebug)
   private
    FCount:integer;
    TypeV:PType;
    
    procedure SetCount(Val:integer);
   public
    _prop_ReplaceData:boolean;

    GType:array of THI_Event;
    
    _event_onCombine:THI_Event;
    _event_onError:THI_Event;
    
    constructor Create;
    destructor  Destroy; override;

    procedure _work_doCombine(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _var_FType(var _Data:TData; Index:word);
    property  _prop_Count:integer write SetCount;
  end;

implementation

constructor THIType_Combine.Create;
begin
  inherited Create;
  TypeV := NewType;
end;

destructor THIType_Combine.Destroy;
begin
  TypeV.Free;
  inherited Destroy;
end;

procedure THIType_Combine.SetCount;
begin
  FCount := Val;
  SetLength(GType,Val);
end;

procedure THIType_Combine._work_doCombine;
var typ:PType;
    i,i2,idx,fidx:integer;
begin
  TypeV.Clear;
  TypeV.name := #0;
  fidx := 0;
  typ := ReadType(_Data,GType[fidx]);
  while (typ = nil) and (fidx < FCount-1) do begin
    CallTypeError('GType' + int2str(fidx + 1),_event_onError,TYPE_ERR_INVALID_TYPE);
    inc(fidx);
    typ := ReadType(_Data,GType[fidx]);
  end;
  if fidx < FCount then begin
    TypeV.name := typ.name;
    for i := 0 to typ.count-1 do TypeV.Add(typ.NameOf[i],typ.data[i]);
    for i := fidx+1 to FCount-1 do begin
      typ := ReadType(_Data,GType[i]);
      if typ = nil then CallTypeError('GType' + int2str(i+1),_event_onError,TYPE_ERR_INVALID_TYPE)
      else 
        for i2 := 0 to typ.count-1 do begin
          idx := TypeV.IndexOf(typ.Name[i2]);
          if idx = -1 then TypeV.Add(typ.NameOf[i2],typ.data[i2])
          else if _prop_ReplaceData then TypeV.Data[idx] := typ.data[i2];
        end;
    end;
  end;
  _hi_OnEvent(_event_onCombine,TypeV);
end;

procedure THIType_Combine._work_doClear;
begin
  TypeV.Clear;
  TypeV.name := #0;
end;

procedure THIType_Combine._var_FType;
begin
  dtType(_Data,TypeV);
end;

end.
