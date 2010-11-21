unit hiType_MultiData;

interface

uses Kol,Share,Debug;

type
  THIType_MultiData = class(TDebug)
   private
    Varsl:PStrList;
    fName:string;
    onError:PHI_Event;
    
    procedure SetVars(Val:string);
    procedure SetName(Val:string);
   public
    GType:THI_Event;
    
    _event_Vars:array of THI_Event;
    
    constructor Create;
    destructor Destroy; override;

    procedure doSeparate(var _Data:TData; Index:word);
    procedure doName(var _Data:TData; Index:word);
    
    property _prop_Vars:string write SetVars;
    property _prop_Name:string read fName write SetName;
  end;

implementation

constructor THIType_MultiData.Create;
begin
  inherited Create;
  Varsl := NewStrList;
end;

destructor THIType_MultiData.Destroy;
begin
  Varsl.Free;
  inherited Destroy;
end;

procedure THIType_MultiData.SetVars;
var i:integer;
begin
  Varsl.Text := LowerCase(Val);
  SetLength(_event_Vars,Varsl.count);
  i := Varsl.IndexOf('##onerror');
  if i > -1 then onError := @_event_Vars[i]
  else onError := nil;
end;

procedure THIType_MultiData.SetName;
begin
  fName := LowerCase(Val);
end;

procedure THIType_MultiData.doSeparate;
var i,idx:integer;
    typ:PType;
begin
  typ := ReadType(_Data,GType);
  if typ <> nil then
    if typ.name = _prop_Name then
      for i := 0 to high(_event_vars) do
       if Varsl.Items[i] <> '##onerror' then begin
        idx := typ.IndexOf(Varsl.Items[i]);
        if idx = -1 then if onError <> nil then CallTypeError(Varsl.Items[i],onError^,TYPE_ERR_NONEXIST_VAR)
         else else if typ.Data[idx].data_type <> data_null then
            _hi_OnEvent_(_event_Vars[i],typ.Data[idx]^);//без буфферизации значение становится = TData.ldata
       end else 
    else if onError <> nil then CallTypeError(_prop_Name,onError^,TYPE_ERR_DIFF_TYPE)
  else if onError <> nil then CallTypeError('',onError^,TYPE_ERR_INVALID_TYPE);
end;

procedure THIType_MultiData.doName;
begin
  SetName(ToString(_Data));
end;

end.
