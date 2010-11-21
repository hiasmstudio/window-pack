unit hiType_Array;

interface

uses Kol,Share,Debug;

type
  THIType_Array = class(TDebug)
   private
    NameList:PStrList;
    NameArr:PArray;
    Arr:PArray;
    Typ:PType;
    
    procedure NSet(Var Item:TData; var Val:TData);
    function  NGet(Var Item:TData; var Val:TData):boolean;
    function  NCount:integer;
    procedure NAdd(var Val:TData);
    
    procedure VSet(var Item:TData; var Val:TData);
    function  VGet(Var Item:TData; var Val:TData):boolean;
    function  VCount:integer;
    procedure VAdd(var Val:TData);
   public
    _prop_UseName:boolean;

    _event_onError:THI_Event;
    _event_onLoad:THI_Event;
    _data_GType:THI_Event;

    constructor Create;
    destructor Destroy; override;
    procedure _work_doLoad(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _work_doClearVars(var _Data:TData; Index:word);
    procedure _work_doUseName(var _Data:TData; Index:word);
    procedure _var_Array(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_NameArray(var _Data:TData; Index:word);
    procedure _var_Name(var _Data:TData; Index:word);
  end;

implementation

constructor THIType_Array.Create;
begin
  inherited Create;
  NameList := NewStrList;
end;

destructor THIType_Array.Destroy;
begin
  NameList.Free;
  if Arr <> nil then dispose(Arr);
  if NameArr <> nil then dispose(NameArr);
  typ := nil;
  inherited Destroy;
end;

procedure THIType_Array._work_doUseName;
begin
  _prop_UseName := ReadBool(_Data);
end;

procedure THIType_Array._work_doLoad;
var tdt:TData;
begin
  tdt := _Data;
  typ := ReadType(_Data,_data_GType);
  if typ = nil then CallTypeError('',_event_onError,TYPE_ERR_INVALID_TYPE);
  _hi_OnEvent_(_event_onLoad,tdt);
end;

procedure THIType_Array._work_doClear;
begin
  typ := nil;
end;

procedure THIType_Array._work_doClearVars;
begin
  if typ = nil then CallTypeError('',_event_onError,TYPE_ERR_NOTLOADED)
  else typ.clear;
end;


procedure THIType_Array.NSet;
begin
  if (typ <> nil) and (ToInteger(item) < typ.count) then
    typ.NameOf[ToInteger(item)] := LowerCase(ToString(val));
end;

function  THIType_Array.NGet;
begin
  if (typ <> nil) and (item.data_type = data_int) and (ToInteger(item) < typ.count) then begin 
    dtString(Val,typ.NameOf[ToInteger(item)]);
    Result := true;
  end else Result := false;
end;

function THIType_Array.NCount;
begin
  Result := -1;
  if typ <> nil then Result := typ.count;
end;

procedure THIType_Array.NAdd;
var dt:TData;
begin
  dtNull(dt);
  if typ <> nil then typ.Add(LowerCase(ToString(val)),@dt);
end;


procedure THIType_Array.VSet;
var idx:integer;
begin
  if typ <> nil then
    if _prop_UseName then begin
      idx := typ.IndexOf(LowerCase(ToString(item)));
      if idx <> -1 then typ.data[idx] := @Val;
    end else begin
      idx := ToInteger(item);
      if (idx >= 0) and (idx < typ.count) then
        typ.data[idx] := @Val;
    end;
end;

function  THIType_Array.VGet;
var idx :integer;
begin
  result := false;
  if typ <> nil then
    if _prop_usename then begin
      idx := typ.IndexOf(LowerCase(ToString(item)));
      if idx <> -1 then begin
        Val := typ.data[idx]^;
        Result := true;
      end;
    end else begin
      idx := ToInteger(item);
      if (idx >= 0) and (idx < typ.count) then begin
        Val := typ.data[idx]^;
        Result := true;
      end;
    end;
end;

function THIType_Array.VCount;
begin
  if typ <> nil then Result := typ.count
  else Result := -1;
end;

procedure THIType_Array.VAdd;
begin
  if (typ <> nil) and (val.ldata <> nil) then typ.Add(LowerCase(ToString(val)),val.ldata);
end;


procedure THIType_Array._var_Array;
begin
  if Arr = nil then Arr := CreateArray(VSet,VGet,VCount,VAdd);
  dtArray(_Data,Arr);
end;

procedure THIType_Array._var_Count;
begin
  if typ = nil then dtInteger(_Data,-1)
  else dtInteger(_Data,typ.count);
end;

procedure THIType_Array._var_NameArray;
begin
  if NameArr = nil then NameArr := CreateArray(NSet,NGet,NCount,NAdd);
  dtArray(_Data,NameArr);
end;

procedure THIType_Array._var_Name;
begin
  if typ = nil then dtNull(_Data)
  else dtString(_Data,typ.name)
end;

end.
