unit hiType_RW;

interface

uses Kol,Share,Debug;

type
  THIType_RW = class(TDebug)
   private
    FData:TData;
   public
    _prop_Name:string;

    _event_onRead:THI_Event;
    _event_onError:THI_Event;
    _data_Value:THI_Event;
    _data_Name:THI_Event;
    _data_GType:THI_Event;

    destructor Destroy; override;
    procedure _work_doRead(var _Data:TData; Index:word);
    procedure _work_doWrite(var _Data:TData; Index:word);
    procedure _work_doAdd(var _Data:TData; Index:word);
    procedure _work_doDelete(var _Data:TData; Index:word);
    procedure _work_doClear(var _Data:TData; Index:word);
    procedure _var_Item(var _Data:TData; Index:word);
    procedure _var_Count(var _Data:TData; Index:word);
    procedure _var_TypeName(var _Data:TData; Index:word);
  end;

implementation

destructor THIType_RW.Destroy;
begin
  FreeData(@FData);
end;

procedure THIType_RW._work_doRead;
var typ:PType;
    idx:integer;
begin
  typ := ReadType(_Data,_data_Gtype);
  if typ <> nil then begin
    idx := typ.IndexOf(LowerCase(ReadString(_Data,_data_Name,_prop_Name)));
    if idx <> -1 then begin
      CopyData(@FData,typ.data[idx]);
      _hi_onEvent_(_event_onRead,FData);
    end else CallTypeError('',_event_onError,TYPE_ERR_NONEXIST_VAR);  
  end else CallTypeError('',_event_onError,TYPE_ERR_INVALID_TYPE);
end;

procedure THIType_RW._work_doWrite;
var typ:PType;
    dt,ddt:TData;
    idx:integer;
begin
  dtNull(ddt);
  typ := ReadType(_Data,_data_Gtype);
  if typ <> nil then begin 
    idx := typ.IndexOf(LowerCase(ReadString(_Data,_data_Name,_prop_Name)));
    if idx <> -1 then begin
      dt := ReadMTData(_Data,_data_Value,@ddt);
      typ.data[idx] := @dt;
    end else CallTypeError('',_event_onError,TYPE_ERR_NONEXIST_VAR);  
  end else CallTypeError('',_event_onError,TYPE_ERR_INVALID_TYPE);
end;

procedure THIType_RW._work_doAdd;
var typ:PType;
    dt,ddt:TData;
    nm:string;
begin
  dtNull(ddt);
  typ := ReadType(_Data,_data_Gtype);
  if typ <> nil then begin
    nm := LowerCase(ReadString(_Data,_data_Name,_prop_Name));
    if typ.IndexOf(nm) = -1 then begin
      dt := ReadMTData(_Data,_data_Value,@ddt);
      typ.add(nm,@dt);
    end else CallTypeError('',_event_onError,TYPE_ERR_ALREXIST_VAR);  
  end else CallTypeError('',_event_onError,TYPE_ERR_INVALID_TYPE);
end;

procedure THIType_RW._work_doDelete;
var typ:PType;
    idx:integer;
begin
  typ := ReadType(_Data,_data_Gtype);
  if typ <> nil then begin
    idx := typ.IndexOf(LowerCase(ReadString(_Data,_data_Name,_prop_Name)));
    if idx <> -1 then typ.delete(idx)
    else CallTypeError('',_event_onError,TYPE_ERR_NONEXIST_VAR);  
  end else CallTypeError('',_event_onError,TYPE_ERR_INVALID_TYPE);
end;

procedure THIType_RW._work_doClear;
var typ:PType;
begin
  typ := ReadType(_Data,_data_Gtype);
  if typ <> nil then typ.Clear  
  else CallTypeError('',_event_onError,TYPE_ERR_INVALID_TYPE);
end;

procedure THIType_RW._var_Item;
begin
  _Data := FData;
end;

procedure THIType_RW._var_Count;
var typ:PType;
begin
  typ := ReadType(_Data,_data_Gtype);
  dtInteger(_Data,0);
  if typ <> nil then dtInteger(_Data,typ.Count)  
  else CallTypeError('',_event_onError,TYPE_ERR_INVALID_TYPE);
end;

procedure THIType_RW._var_TypeName;
var typ:PType;
begin
  typ := ReadType(_Data,_data_Gtype);
  dtString(_Data,'');
  if typ <> nil then dtString(_Data,typ.name) 
  else CallTypeError('',_event_onError,TYPE_ERR_INVALID_TYPE);
end;

end.
