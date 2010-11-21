unit hiType_Delete;

interface

uses Kol,Share,Debug;

type
  THIType_Delete = class(TDebug)
   private
    Vars:PStrList;
    fName:string;
    
    procedure SetVars(val:string);
    procedure SetName(val:string);
   public
    _event_onError:THI_Event;
    _event_onDelete:THI_Event;
    
    _data_GType:THI_Event;
    
    constructor Create;
    destructor  Destroy; override;
    procedure _work_doDelete(var _Data:TData; Index:word);
    procedure _work_doName(var _Data:TData; Index:word);
    procedure _work_doVars(var _Data:TData; Index:word);
    property  _prop_Vars:string write SetVars;
    property  _prop_Name:string read fName write SetName; 
  end;

implementation

constructor THIType_Delete.Create;
begin
  inherited Create;
  Vars := NewStrList;
end;

destructor THIType_Delete.Destroy;
begin
  Vars.Free;
  inherited Destroy;
end;

procedure THIType_Delete.SetVars;
begin
  Vars.Text := LowerCase(val);
end;

procedure THIType_Delete.SetName;
begin
  fName := LowerCase(val);
end;

procedure THIType_Delete._work_doName;
begin
  SetName(ToString(_Data));
end;

procedure THIType_Delete._work_doDelete;
var typ:PType;
    tdt:TData;
    i,idx:integer;
    itm:string;
begin
  tdt := _Data;
  typ := ReadType(_Data,_data_GType);
  if typ <> nil then
    if typ.name = _prop_name then
      for i := 0 to Vars.count-1 do begin
        itm := Vars.Items[i];
        idx := typ.IndexOf(itm);
        if idx <> -1 then typ.Delete(idx)
        else CallTypeError(itm,_event_onError,TYPE_ERR_NONEXIST_VAR);
      end
    else CallTypeError(_prop_Name,_event_onError,TYPE_ERR_DIFF_TYPE)
  else CallTypeError('',_event_onError,TYPE_ERR_INVALID_TYPE);
  _hi_OnEvent_(_event_onDelete,tdt);
end;

procedure THIType_Delete._work_doVars;
begin
  SetVars(ToString(_Data));
end;

end.
