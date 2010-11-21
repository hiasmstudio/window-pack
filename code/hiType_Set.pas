unit hiType_Set;

interface

uses Kol,Share,Debug;

type
  THIType_Set = class(TDebug)
   private
    varsl:PStrList;
    fName:string;
    DfVar:array of string;
    
    procedure SetVars(val:string);
    procedure SetName(val:string);
   public
    _prop_DefData:TData;
    _prop_GTypeEnabled:boolean;

    onError:THI_Event;
    onSet:THI_Event;
    
    _data_Vars:array of THI_Event;
    
    constructor Create;
    destructor  Destroy; override;
    procedure doSet(var _Data:TData; Index:word);
    procedure doName(var _Data:TData; Index:word);
    
    property _prop_Vars:string write SetVars;
    property _prop_Name:string read fName write SetName;
  end;

implementation

constructor THIType_Set.Create;
begin
  inherited Create;
  Varsl := NewStrList;
end;

destructor THIType_Set.Destroy;
begin
  Varsl.Free;
  inherited Destroy;
end;

procedure THIType_Set.SetVars;
var i:integer;
    nm,itm:string;
begin
  Varsl.Text := val;
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

procedure THIType_Set.SetName;
begin
  fName := LowerCase(val);
end;

procedure THIType_Set.doName;
begin
  SetName(ToString(_Data));
end;

procedure THIType_Set.doSet;
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
          if idx <> -1 then begin 
            if _prop_DefData.data_type <> data_null then ddt := _prop_DefData
              else if DfVar[i] <> '' then dtString(ddt,DfVar[i]) else dtNull(ddt);
            dt := ReadMTData(_Data,_data_Vars[i],@ddt);
            typ.Data[idx] := @dt;
          end
          else CallTypeError(itm,onError,TYPE_ERR_NONEXIST_VAR);
        end;
      end;
    end else CallTypeError(_prop_Name,onError,TYPE_ERR_DIFF_TYPE)
  else CallTypeError('',onError,TYPE_ERR_INVALID_TYPE);
  _hi_OnEvent_(onSet,tdt);
end;

end.
