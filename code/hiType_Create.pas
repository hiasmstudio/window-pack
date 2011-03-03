unit hiType_Create;

interface

uses Kol,Share,Debug;

type  
  THIType_Create = class(TDebug)
   private
     Varsl:PStrList;
     TypeV:PType;
     fName:string;
     DfVar:array of string;
     
     procedure SetVars(Val:string);
     procedure SetName(val:string);
     procedure SetType(s:boolean);
   public
    onCreate:THI_Event;
    
    _data_Vars:array of THI_Event;
    
    _prop_DefData:TData;

    constructor Create;
    destructor Destroy; override;
    procedure doCreate(var _Data:TData; Index:word);
    procedure doName(var _Data:TData; Index:word);
    procedure doClear(var _Data:TData; Index:word);
    procedure FType(var _Data:TData; Index:word);
    
    property  _prop_Vars:string write SetVars;
    property  _prop_Name:string read fName write SetName;
    property  _prop_StorageType:boolean write SetType;
  end;

implementation

constructor THIType_Create.Create;
begin
  inherited Create;
  Varsl := NewStrList;
end;

destructor THIType_Create.Destroy;
begin
  Varsl.Free;
  TypeV.Free;
  inherited Destroy;
end;

procedure THIType_Create.SetType;
begin
  if s then TypeV := NewStorageType else TypeV := NewType;
  TypeV.name := #0;
end;

procedure THIType_Create.SetVars;
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

procedure THIType_Create.SetName;
begin
  fName := LowerCase(val);
end;

procedure THIType_Create.doName;
begin
  SetName(ToString(_data));
  if TypeV.name <> #0 then TypeV.name := _prop_name;
end;

procedure THIType_Create.doCreate;
var i:integer;
    dt,ddt:TData;
begin
  TypeV.Clear;
  TypeV.name := _prop_name;
  for i := 0 to Varsl.Count-1 do begin
    if _prop_DefData.data_type <> data_null then ddt := _prop_DefData
     else if DfVar[i] <> '' then dtString(ddt,DfVar[i]) else dtNull(ddt);
    dt := ReadMTData(_Data,_data_Vars[i],@ddt);
    TypeV.Add(Varsl.Items[i],@dt);
  end;  
  _hi_OnEvent(onCreate,TypeV);
end;

procedure THIType_Create.doClear;
begin
  TypeV.Clear;
  TypeV.name := #0;
end;

procedure THIType_Create.FType;
begin
  dtType(_Data,TypeV);
end;

end.
