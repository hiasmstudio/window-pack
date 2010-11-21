unit hiType_FastMem;

interface

uses Kol,Share,Debug;

type
  THIType_FastMem = class(TDebug)
   private
    Varsl:PStrList;
    fName:string;
    
    procedure SetVars(str:string);
    procedure SetName(val:string);
   public
    onError:THI_Event;
    GType:THI_Event;
    
    constructor Create;
    destructor  Destroy; override;
    
    procedure _var_Vars(var _Data:TData; Index:word);

    property _prop_Vars:string write SetVars;
    property _prop_Name:string read fName write SetName;
  end;

implementation

constructor THIType_FastMem.Create;
begin
  inherited Create;
  Varsl := NewStrList;
end;

destructor THIType_FastMem.Destroy;
begin
  Varsl.Free;
  inherited Destroy;
end;

procedure THIType_FastMem.SetVars;
begin
  Varsl.Text := LowerCase(str);
end;

procedure THIType_FastMem.SetName;
begin
  fName := LowerCase(val);
end;

procedure THIType_FastMem._var_Vars;
var i:integer;
    typ:PType;
begin
  typ := ReadType(_Data,GType);
  if typ <> nil then
    if typ.name = _prop_Name then begin
      i := typ.IndexOf(Varsl.Items[index]);
      if i = -1 then
        CallTypeError(Varsl.Items[index],onError,TYPE_ERR_NONEXIST_VAR)
      else _Data := typ.data[i]^;
    end else CallTypeError(_prop_Name,onError,TYPE_ERR_DIFF_TYPE)
  else CallTypeError('',onError,TYPE_ERR_INVALID_TYPE);
end;

end.
