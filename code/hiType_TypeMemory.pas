unit hiType_TypeMemory;

interface

uses Kol,Share,Debug;

type
  THIType_TypeMemory = class(TDebug)
   private
    TypeV:PType;
   public
    _data_GType:THI_Event;
    
    _event_onCopy:THI_Event;
    _event_onError:THI_Event;
    
    constructor Create;
    destructor Destroy; override;
    procedure _work_doCopy(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _var_FType(var _Data:TData; Index:word);
  end;

implementation

constructor THIType_TypeMemory.Create;
begin
  inherited Create;
end;

destructor THIType_TypeMemory.Destroy;
begin
  if TypeV <> nil then TypeV.Free;
  inherited Destroy;
end;

procedure THIType_TypeMemory._work_doCopy;
var typ:PType;
    i:integer;
    tdt:TData;
begin
  tdt := _Data;
  if TypeV <> nil then TypeV.Free;
  typ := ReadType(_Data,_data_GType);
  if typ^ is TStorageType then TypeV := NewStorageType else TypeV := NewType;
  TypeV.Name := #0;
  if typ <> nil then begin
    TypeV.name := typ.name;
    for i := 0 to typ.count-1 do TypeV.Add(typ.NameOf[i],typ.data[i]);
  end else CallTypeError('',_event_onError,TYPE_ERR_INVALID_TYPE);
  _hi_OnEvent_(_event_onCopy,tdt);
end;

procedure THIType_TypeMemory._work_doClear;
begin
  TypeV.Clear;
  TypeV.Name := #0;
end;

procedure THIType_TypeMemory._var_FType;
begin
  dtType(_Data,TypeV);
end;

end.
