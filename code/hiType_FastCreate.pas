unit hiType_FastCreate;

interface

uses Kol,Share,Debug;

type
  THIType_FastCreate = class(TDebug)
   private
    Varsl:PStrList;
    fname:string;
    TypeV:PType;
    DfVar:array of string;
    
    procedure SetVars(val:string);
    procedure SetName(val:string);
    procedure SetType(s:boolean);
   public
    _data_Vars:array of THI_Event;
    
    constructor Create;
    destructor  Destroy; override;

    procedure doName(var _Data:TData; Index:word);
    procedure doClear(var _Data:TData; Index:word);
    procedure FType(var _Data:TData; Index:word);
    
    property _prop_Name:string read fname write SetName;
    property _prop_Vars:string write SetVars;
    property _prop_StorageType:boolean write SetType;
  end;

implementation

constructor THIType_FastCreate.Create;
begin
  inherited Create;
  Varsl := NewStrList;
end;

destructor THIType_FastCreate.Destroy;
begin
  Varsl.Free;
  TypeV.Free;
  inherited Destroy;
end;

procedure THIType_FastCreate.SetType;
begin
  if s then TypeV := NewStorageType else TypeV := NewType;
  TypeV.name := #0;
end;

procedure THIType_FastCreate.SetVars;
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

procedure THIType_FastCreate.SetName;
begin
  fName := LowerCase(val);
end;

procedure THIType_FastCreate.doName;
begin
  SetName(ToString(_data));
  TypeV.name := _prop_name;
end;

procedure THIType_FastCreate.doClear;
begin
  TypeV.Clear;
  TypeV.name := #0;
end;

procedure THIType_FastCreate.FType;
var i:integer;
    dt,ddt:TData;
begin
  TypeV.Clear;
  TypeV.name := LowerCase(_prop_name);
  for i := 0 to Varsl.Count-1 do begin
    if DfVar[i] <> '' then dtString(ddt,DfVar[i]) else dtNull(ddt);
    dt := ReadMTData(_Data,_data_Vars[i],@ddt);
    TypeV.Add(Varsl.Items[i],@dt);
  end;
  dtType(_Data,TypeV);
end;

end.
