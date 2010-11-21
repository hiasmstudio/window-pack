unit hiType_MultiMem;

interface

uses Kol,Share,Debug;

type
  THIType_MultiMem = class(TDebug)
   private
    Varsl:PStrList;
    Vars :array of TData;
    fName:string;
    
    procedure SetVars(str:string);
    procedure SetName(val:string);
   public
    onMem:THI_Event;
    onError:THI_Event;
    
    GType:THI_Event;
    
    constructor Create;
    destructor Destroy; override;

    procedure doMem(var _Data:TData; Index:word);
    procedure doClear(var _Data:TData; Index:word);
    procedure doName(var _Data:TData; Index:word);
    
    procedure _var_vars(var _Data:TData; Index:word);
    
    property _prop_Vars:string write SetVars;
    property _prop_Name:string read fName write SetName;
  end;

implementation

constructor THIType_MultiMem.Create;
begin
  inherited Create;
  Varsl := NewStrList;
end;

destructor THIType_MultiMem.Destroy;
var i:integer;
begin
  Varsl.Free;
  for i := 0 to high(vars) do begin
    FreeData(@vars[i]);
    dtNull(vars[i]);
  end;
  inherited Destroy;
end;

procedure THIType_MultiMem.SetVars;
var i:integer;
begin
  Varsl.Text := LowerCase(str);
  SetLength(vars,Varsl.Count);
  for i := 0 to Varsl.count-1 do dtNull(vars[i]);
end;

procedure THIType_MultiMem.SetName;
begin
  fName := LowerCase(val);
end;

procedure THIType_MultiMem.doName;
begin
  SetName(ToString(_Data));
end;

procedure THIType_MultiMem.doMem;
var i,idx:integer;
    typ:PType;
    tdt:TData;
begin
  tdt := _Data;
  typ := ReadType(_Data,GType);
  for i := 0 to high(vars) do begin
    FreeData(@vars[i]);
    dtNull(vars[i]);
  end;
  if typ <> nil then
    if typ.name = _prop_Name then
      for i := 0 to high(vars) do begin
        idx := typ.IndexOf(Varsl.Items[i]);
        if idx = -1 then
          CallTypeError(Varsl.Items[i],onError,TYPE_ERR_NONEXIST_VAR)
        else CopyData(@vars[i],typ.data[idx]);
      end
    else CallTypeError(_prop_Name,onError,TYPE_ERR_DIFF_TYPE)
  else CallTypeError('',onError,TYPE_ERR_INVALID_TYPE);
  _hi_OnEvent_(onMem,tdt);
end;

procedure THIType_MultiMem.doClear;
var i:integer;
begin
  for i := 0 to high(vars) do begin
    FreeData(@vars[i]);
    dtNull(vars[i]);
  end;
end;

procedure THIType_MultiMem._var_Vars;
begin
  _Data := vars[index];
end;

end.
