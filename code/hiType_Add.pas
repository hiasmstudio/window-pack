unit hiType_Add;

interface

uses Kol,Share,Debug;

type
  THIType_Add = class(TDebug)
   private
    Varsl:PStrList;
    fName:string;
    DfVar:array of string;
    
    procedure SetVars(Val:string);
    procedure SetName(val:string);
   public
    _prop_DefData:TData;
    _prop_GTypeEnabled:boolean;
    
    _data_Vars:array of THI_Event;

    onError:THI_Event;
    onAdd:THI_Event;
    
    constructor Create;
    destructor Destroy; override;

    procedure doAdd(var _Data:TData; Index:word);
    procedure doName(var _Data:TData; Index:word);
    property  _prop_Vars:string write SetVars;
    property  _prop_Name:string read fName write SetName;
  end;

implementation

constructor THIType_Add.Create;
begin
  inherited Create;
  Varsl := NewStrList;
end;

destructor THIType_Add.destroy;
begin
  Varsl.Free;
  inherited Destroy;
end;

procedure THIType_Add.SetVars;
var i:integer;
    nm,itm:string;
begin
  Varsl.Text := Val;
  SetLength(_data_Vars,Varsl.count);
  SetLength(DfVar,Varsl.count);
//установка значений DfVar
  for i := 0 to high(DfVar) do begin
    itm := Varsl.Items[i];
    if pos('=',itm) > 0 then begin
      nm := GetTok(itm,'=');
      DfVar[i] := itm;
      Varsl.Items[i] := LowerCase(nm);
    end else begin
      DfVar[i] := '';
      Varsl.Items[i] := LowerCase(Varsl.Items[i]);
    end;
  end;
end;

procedure THIType_Add.SetName;
begin
  fName := LowerCase(val);
end;

procedure THIType_Add.doName;
begin
  SetName(ToString(_Data));
end;

procedure THIType_Add.doAdd;
var i,idx:integer;
    dt,tdt,ddt:TData;
    typ:PType;
    itm:string;
begin
  tdt := _Data;
  if (Varsl.IndexOf('gtype') = -1) or (not _prop_GTypeEnabled) then typ := ReadType(_Data,NULL)
  else typ := ReadType(_Data,_data_Vars[Varsl.IndexOf('gtype')]);
  if typ <> nil then
    if typ.name = _prop_name then begin
      for i := 0 to Varsl.count-1 do begin
        itm := Varsl.Items[i];
        if (itm <> 'gtype') or (not _prop_GTypeEnabled) then begin
          idx := typ.IndexOf(itm);
          if idx = -1 then begin 
            if _prop_DefData.data_type <> data_null then ddt := _prop_DefData
             else if DfVar[i] <> '' then dtString(ddt,DfVar[i]) else dtNull(ddt);
            dt := ReadMTData(_Data,_data_Vars[i],@ddt);
            typ.Add(itm,@dt);
          end
          else CallTypeError(itm,onError,TYPE_ERR_ALREXIST_VAR);
        end;
      end;
    end else CallTypeError(_prop_name,onError,TYPE_ERR_DIFF_TYPE)
  else CallTypeError('',onError,TYPE_ERR_INVALID_TYPE);
  _hi_onEvent_(onAdd,tdt);
end;

end.
